.text
.org 0x0
.global _start

_start:
_main:
    movia sp, 0x7FFC # sufficiently high addr for stack.
    movi r2, msg
    call print
_end:
    br _end

# takes in the string to print via r2
print:
    #r2 = msg
    subi sp, sp, 16
    stw r3, 12(sp)
    stw r4, 8(sp)
    stw r5, 4(sp)
    stw r6, 0(sp)
    # so we go the good old memory mapped IO things going on here.
    # good fun.
    movia r3, 0x10001000 # data register, control/status reg 4 bytes up.
    # go through each character
    print_loop:
        ldb r4, 0(r2)
        beq r4, r0, print_loop_end
        # print the character
        print_poll:
            ldwio r5, 4(r3)
            movhi r6, 0xFFFF
            and r5, r5, r6
            beq r5, r0, print_poll # if the status bit is zero, not ready for printing.
        print_poll_end:
        stbio r4, 0(r3)
        addi r2, r2, 1 # go to the next byte
        br print_loop
    print_loop_end:  
    ldw r3, 12(sp)
    ldw r4, 8(sp)
    ldw r5, 4(sp)
    ldw r6, 0(sp)
    addi sp, sp, 16  
    ret

.data
.org 0x1000
msg: .asciz "Hello, World!\n" 