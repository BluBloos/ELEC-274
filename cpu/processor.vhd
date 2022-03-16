-- ------------------------------------------------------
-- processor.vhd: code for a 32-bit processor that
-- implements a small subset of RISC-style instructions;
-- machine encoding of instructions is based on Nios II
--
-- Naraig Manjikian
-- February 2012
-- ------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.my_components.all;
-- 'my_components' package has declaration for 32-bit register

entity processor is
  port (
    clk          : in std_logic;
    reset_n      : in std_logic;
    mem_addr_out : out std_logic_vector(31 downto 0);
    mem_data_out : out std_logic_vector(31 downto 0);
    mem_data_in  : in  std_logic_vector(31 downto 0);
    mem_read     : out std_logic;
    mem_write    : out std_logic;
    ifetch_out   : out std_logic
  );
end entity;

-- ------------------------------------------------------

architecture synth of processor is

-- outputs from registers in instruction-fetch section and datapath
signal PC_out, IR_out : std_logic_vector(31 downto 0);
signal PC_Temp_out    : std_logic_vector(31 downto 0);
signal RA_out, RB_out, RM_out : std_logic_vector(31 downto 0);
signal RX_out, RY_out, RZ_out : std_logic_vector(31 downto 0);

-- combinational output from separate adder associated with PC register
signal PC_adder_out   : std_logic_vector(31 downto 0);

-- input/output signals for ALU (which is combinational logic)
signal ALU_op  : std_logic_vector(3 downto 0);
signal ALU_out : std_logic_vector(31 downto 0);
signal ALU_zero_out, ALU_neg_out : std_logic;

-- outputs from multiplexers in instruction-fetch section and datapath 
signal MuxB_out   : std_logic_vector(31 downto 0);
signal MuxC_out   : std_logic_vector(4 downto 0);
signal MuxINC_out : std_logic_vector(31 downto 0);
signal MuxMA_out  : std_logic_vector(31 downto 0);
signal MuxPC_out  : std_logic_vector(31 downto 0);
signal MuxY_out   : std_logic_vector(31 downto 0);

-- one-hot step counter outputs for control logic
signal T1, T2, T3, T4, T5 : std_logic;

-- outputs from instruction decoder  
signal INS_addi, INS_br, INS_ldw, INS_stw : std_logic;

-- input/output signals for register file, including register-specific signals
--  that are internal to the register file
--  (although the instructor's preference is to consided the 5-bit fields
--   as register _identifiers_, they are labelled as 'address' for consistency
--   with the textbook and lecture content based on textbook)
signal Address_A, Address_B, Address_C : std_logic_vector(4 downto 0);
signal regfile_A_out, regfile_B_out    : std_logic_vector(31 downto 0);
signal RF_write : std_logic;
signal r1_write : std_logic;
signal r1_out   : std_logic_vector(31 downto 0);

-- bit fields from instruction register output (some of fields overlap)
signal IR_opcode : std_logic_vector(5 downto 0);
signal IR_src1   : std_logic_vector(4 downto 0);
signal IR_src2   : std_logic_vector(4 downto 0);
signal IR_dest   : std_logic_vector(4 downto 0);
signal IR_imm16  : std_logic_vector(15 downto 0);

-- 32-bit immediate generated from 16-bit immediate in instruction  
signal imm32  : std_logic_vector(31 downto 0);

-- multiplexer input selection control signals
signal B_select   : std_logic;  
signal C_select   : std_logic_vector(1 downto 0);
signal INC_select : std_logic;
signal MA_select  : std_logic;
signal PC_select  : std_logic;
signal Y_select   : std_logic_vector(1 downto 0);

-- load-enable signals for registers in instruction-fetch section
--  (apart from the programmable-visible registers in the register file,
--   the basic processing unit design does not require other load-enables;
--   the internal registers in the datapath can capture input data on
--   every clock edge; with the IR contents stable for several cycles,
--   the contents captured by those datapath register on every edge
--   will be the same until IR changes for the next instruction)
signal PC_en, PC_Temp_en : std_logic;
signal IR_en : std_logic;

-- ============================================================================

begin

-- instantiate registers in the instruction-fetch section and the datapath;
-- establish signal connections for the ports using the implicit technique
--  in VHDL syntax (i.e., by position in the list of declared ports)


-- .....................  CLK  RESET_N  EN          D              Q ........... 

     PC : reg32 port map (clk, reset_n, PC_en,      MuxPC_out,     PC_out);
PC_Temp : reg32 port map (clk, reset_n, PC_Temp_en, PC_out,        PC_Temp_out);
     IR : reg32 port map (clk, reset_n, IR_en,      mem_data_in,   IR_out);
     RA : reg32 port map (clk, reset_n, '1',        regfile_A_out, RA_out);
     RB : reg32 port map (clk, reset_n, '1',        regfile_B_out, RB_out);
     RM : reg32 port map (clk, reset_n, '1',        RB_out,        RM_out);
     RY : reg32 port map (clk, reset_n, '1',        MuxY_out,      RY_out);
     RZ : reg32 port map (clk, reset_n, '1',        ALU_out,       RZ_out);

     
-- the register file is defined below, but consists in this description
--   of just a single read/write register (r1);
-- all other registers, including register r0, return a value of zero;
-- to add more registers, use register r1 as a template to:
--   (a) introduce appropriate signal definitions before the 'begin' above,
--   (b) introduce appropriate register storage instantiations,
--   (c) extend the two output ports with cases for additional registers, and
--   (d) define the logic for additional  write signals for new registers
     
-- instantiation of storage for programmer-visible general-purpose registers
--  (initially, we have just one register r1;
--   no actual logic is needed for register r0)
r1 : reg32 port map (clk, reset_n, r1_write,   RY_out,        r1_out);

-- generate the two independent output ports for the register file
--  using the 5-bit register identifiers to choose the correct output value
regfile_A_out <=    r1_out when (Address_A = "00001")
              else (others => '0'); -- output zero by default; covers r0
              
regfile_B_out <=    r1_out when (Address_B = "00001")
              else (others => '0'); -- output zero by default; covers r0

-- define logic for register-specific write signal (i.e., load-enable)
r1_write <=   '1' when (RF_write = '1' and Address_C = "00001")
         else '0';

-- address inputs (identifiers) for register file (two outputs, one input)
Address_A <= IR_src1;
Address_B <= IR_src2;
Address_C <= MuxC_out;

-- for the control logic, this process defines a step counter;     
--  a single '1' rotates through five flip-flops to reflect current time step
one_hot_step_counter: process (clk, reset_n)
begin
	if (reset_n = '0') then
		T1 <= '1';  T2 <= '0';  T3 <= '0';  T4 <= '0';  T5 <= '0';
	elsif (rising_edge (clk)) then
		T1 <= T5;   T2 <= T1;   T3 <= T2;   T4 <= T3;   T5 <= T4;
	end if;
end process;

-- this process describes the combinational logic behavior of the ALU;
-- the ALU performs the specified operation; status flags reflect its result
ALU : process (RA_out, MuxB_out, ALU_op)
begin
	case ALU_op is
		when "0000" =>
			ALU_out <= RA_out + MuxB_out; -- specific for addition
		when others =>
			ALU_out <= RA_out + MuxB_out; -- default (also addition)
	end case;
end process;

-- status signals to characterize current ALU output
ALU_neg_out  <= ALU_out(31); -- the sign bit
ALU_zero_out <=   '1' when (ALU_out = "00000000000000000000000000000000")
             else '0';

-- add selected value to current PC register output
-- (could be either 4 or a branch offset)
PC_adder : process (PC_out, MuxINC_out)
begin
	PC_adder_out <= PC_out + MuxINC_out;
end process;

-- extend 16-bit immediate from instructionto a 32-bit value
-- (currently does sign extension, but adding more instructions
--  will also require zero extension, hence a control input must be
--  introduced so that the body of the loop below will fill the upper
--  16 bits with either zeros or the IR_imm(15) sign bit value)
imm32_generator : process (IR_imm16)
variable i : integer;
begin
	imm32(15 downto 0) <= IR_imm16; -- lower bits are the same
	for i in 31 downto 16 loop
		imm32(i) <= IR_imm16(15);   -- upper bits are copy of sign bit
    end loop;
end process;

-- these are the various multiplexers in the datapath;
-- each has its relevant control input

MuxB_out <=   imm32 when (B_select = '1')
         else RB_out;

MuxC_out <=   IR_dest     when (C_select = "01")
         else IR_src2;
         -- does not presently support link register for calls

MuxINC_out <=   imm32 when (INC_select = '1')
           else "00000000000000000000000000000100";  -- value 4

MuxMA_out <=   PC_out when (MA_select = '1')
          else RZ_out;

MuxPC_out <=   PC_adder_out when (PC_select = '1')
          else RA_out;
            
MuxY_out <=   PC_Temp_out when (Y_select = "10")
         else mem_data_in when (Y_select = "01")
         else RZ_out;

-- extract the bit fields from the instruction register
IR_src1   <= IR_out(31 downto 27);
IR_src2   <= IR_out(26 downto 22);
IR_dest   <= IR_out(21 downto 17);
IR_imm16  <= IR_out(21 downto 6);
IR_opcode <= IR_out(5 downto 0);
  
-- generate the outputs for instruction opcode decoder
INS_addi  <= '1' when (IR_opcode = "000100") else '0';
INS_br    <= '1' when (IR_opcode = "000110") else '0';
INS_ldw   <= '1' when (IR_opcode = "010111") else '0';
INS_stw   <= '1' when (IR_opcode = "010101") else '0';

-- generate memory control signals
mem_read  <= T1 or (T4 and INS_ldw);
mem_write <= T4 and INS_stw;

-- generate multiplexer control signals
B_select   <=   '1';           -- for now, always select imm32 as ALU input  
C_select   <=   "00";          -- for now, always select src2 as dest register
INC_select <=   T3 and INS_br; -- use imm32 offset for br, otherwise +4
MA_select  <=   T1;            -- use PC for ifetch, otherwise RZ
PC_select  <=   '1';           -- for now, always use PC_adder_out
Y_select   <=   "01" when (T4 = '1' and INS_ldw = '1') -- data from memory
           else "00";          -- common case to select register RY contents
                               -- for now, call instructions are not supported

-- load enable for PC register; asserted only for instr-fetch or for branch;
--   this would need further refinement to handle any memory delay during fetch
PC_en <= T1 or (T3 and INS_br);

-- load enable for PC_Temp register
PC_Temp_en <= T3;  -- should actually be: T3 and INS_call, when call supported 

-- load enable for instruction register; asserted only for instr-fetch
--  (no refinement needed to handle memory delay; keep capturing until
--   last one, which is the final valid result from memory)
IR_en <= T1;

-- determine operation performed by ALU
ALU_op <= "0000"; -- always addition (the only operation presently supported);
                  --  with more instructions, this statement would become
                  --  a when-else to handle different cases

-- outputs to memory
mem_addr_out <= MuxMA_out;  -- from multiplexer choosing proper address value
mem_data_out <= RM_out;     -- from internal register hold data for write

-- modification of a programmable-visible general-purpose register
--  occurs only in the last step and only for certain instructions
RF_write <= T5 and (INS_ldw or INS_addi);

-- for observation purposes in output waveforms, use the assertion of T1 signal
--  as a marker for the start of each instruction
ifetch_out <= T1;
          
end architecture;
