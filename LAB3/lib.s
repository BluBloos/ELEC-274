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