.text
.global _start  
.org 0x00000

# Done.
_start:
    movi sp, 0x7FFC
    
    movi r2, init_msg
    call PrintString
    xor r2, r2, r2 # set to zero
    call PrintHexWord
    movi r2, 0xA
    call PrintChar
    movia r2, 0xA5A5
    call PrintHexWord
    movi r2, 0xA
    call PrintChar
    movia r2, 0xFFFFFFFF
    call PrintHexWord

_end:
    br _end

# this file contains reusable and modular subroutines that can be applied to 
# the development of arbitrary assembly programs. Needless to say, this file is
# incredibly useful.

# void PrintChar(char c)
PrintChar:
    # r2 = c
    subi sp, sp, 12
    stw r3, 0(sp)
    stw r4, 4(sp)
    stw r5, 8(sp) 
    # IO is mapped to memory.
    movia r3, 0x10001000 # data register, control/status reg 4 bytes up.
    PrintChar_poll:
        ldwio r4, 4(r3)
        movhi r5, 0xFFFF # the upper 16 bits of the control/status reg are the status bits.
        and r4, r4, r5
        beq r4, r0, PrintChar_poll # if the status bits give zero, not ready for printing.
    PrintChar_poll_end:
    stbio r2, 0(r3) 
    ldw r3, 0(sp)
    ldw r4, 4(sp)
    ldw r5, 8(sp)
    addi sp, sp, 12
    ret

# void PrintString(char *str)
PrintString:
    #r2 = msg
    subi sp, sp, 8
    stw r3, 0(sp)
    stw ra, 4(sp)
    mov r3, r2
    # go through each character
    PrintString_loop:
        ldb r2, 0(r3)
        beq r2, r0, PrintString_loop_end
        call PrintChar
        addi r3, r3, 1 # go to the next byte
        br PrintString_loop
    PrintString_loop_end:
    ldw r3, 0(sp)
    ldw ra, 4(sp)
    addi sp, sp, 8
    ret


PrintHexChar:
    subi sp, sp, 12
    stw r2, 0(sp)
    stw r3, 4(sp)
    stw ra, 8(sp)

    #r2 = 4 bit hex character in integer format.
    PrintHexChar_if:
    movi r3, 10
    blt r2, r3, PrintHexChar_else
    subi r2, r2, 10
    addi r2, r2, 'A'
    br PrintHexChar_endif
    PrintHexChar_else:
    addi r2, r2, '0'
    PrintHexChar_endif:
    call PrintChar
    
    ldw r2, 0(sp)
    ldw r3, 4(sp)
    ldw ra, 8(sp)
    addi sp, sp, 12
    ret

# This will print just 1 hexadecimal digit.
# void PrintHexByte(char n)
PrintHexByte:
    # r2 = n
    subi sp, sp, 12
    stw ra, 0(sp)
    stw r2, 4(sp)
    stw r3, 8(sp)

    mov r3, r2 # for safe keeping.

    ####### First char (MSB) ######
    andi r2, r3, 0xF0
    srli r2, r2, 4
    call PrintHexChar 
    ####### First char (MSB) ######

    ####### Second char (LSB) #######
    andi r2, r3, 0x0F
    call PrintHexChar
    ####### Second char (LSB) #######

    ldw ra, 0(sp)
    ldw r2, 4(sp)
    ldw r3, 8(sp)
    addi sp, sp, 12
    ret

# This will print 8 hexadecimal digits representing the value of a 32-bit word. 
# It will also pre-append a 0x in front of the hexadecimal value, because yknow, thats fun.
# void PrintHexWord(int32 val)
PrintHexWord:
    # r2 = val
    subi sp, sp, 12
    stw ra, 0(sp)
    stw r2, 4(sp)
    stw r3, 8(sp)

    # NOTE(Noah): We print the bytes MSB to LSB.
    # Hexadecimal is cool like that.
    mov r3, r2 # for safe keeping.

    movi r2, '0'
    call PrintChar
    movi r2, 'x'
    call PrintChar

    # First byte
    andhi r2, r3, 0xFF00
    srli r2, r2, 24
    call PrintHexByte

    # second byte
    andhi r2, r3, 0x00FF
    srli r2, r2, 16
    call PrintHexByte

    # third byte
    andi r2, r3, 0x0000FF00
    srli r2, r2, 8
    call PrintHexByte

    # fourth byte
    andi r2, r3, 0xFF
    call PrintHexByte

    ldw ra, 0(sp)
    ldw r2, 4(sp)
    ldw r3, 8(sp)
    addi sp, sp, 12
    ret

.org 0x1000  
init_msg: .asciz "Lab 4 Preparation\n"