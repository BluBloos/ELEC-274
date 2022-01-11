.text

# .global directive used to export _start 
# symbol for linking.
.global _start  

.org 0x00000

_start:
    ldw r2, N(r0) # loads 32-bit word from memory address at byte_offset r0 from label N
    movi r3, LIST # moves a 16-bit signed immediate val into register and sign-extends to 32 bits
    movi r4, 0
 LOOP:
    ldw r5, 0(r3) # load current val from pointer to list in 43
    add r4, r4, r5 # add r4 and r5 and store in r4 (add current elem to sum)
    addi r3, r3, 4 # increment list pointer in r3 (4 bytes).
    subi r2, r2, 1 # decrement the 'i' var (begins at N)
    bgt r2, r0, LOOP # branch to loop top so long as i var is greater than 0 (still elements in list)
    stw r4, SUM(r0) # store the value of r4 in SUM memory address (because offset of zero).
_end:
    br _end # infinite lopp

# okay so .org directive makes things exist in machine code
# output at a specific location in the .exe
.org 0x1000  

SUM: .skip 4 # so this "reserves"  4 bytes of space.
N: .word 5
# hex value is -2 in two's compliment
LIST: .word 12, 0xFFFFFFFE, 7, -1, 2 
    .end

