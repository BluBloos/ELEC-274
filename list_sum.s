.text

# .global directive used to export _start 
# symbol for linking.
.global _start  

.org 0x0000

_start:
    ldw r2, N(r0) # what is this instruction?
    movi r3, LIST #??
    movi r4, 0 # presume this is a move integer into r4 register
 LOOP:
    ldw r5, 0(r3)
    add r4, r4, r5 # add r4 and r5 and store in r4?
    addi r3, r3, 4 # add with integer literal?
    subi r2, r2, 1
    bgt r2, r0, LOOP # is this like a "branch" statement?
    stw r4, SUM(r0) # okay so this is like store wide?
_end:
    br _end # break statement? or like "branch return"?

# okay so .org directive makes things exist in machine code
# output at a specific location in the .exe
.org 0x1000  

SUM: .skip 4 # so this "reserves"  4 bytes of space.
N: .word 5
# hex value is -2 in two's compliment
LIST: .word 12, 0xFFFFFFFE, 7, -1, 2 
    .end

