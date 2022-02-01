# NOTE(Noah): To just to flex at how good I am at assembly programming,
# note that I did not use any refences at all when writing this program.
# just off memory.

/* 
pseudocode for program:
list = [34, 0, 57, 91, 0]
zeros = 0
for elem in list:
    if elem == 0:
        zeros++
*/

.org 0x0

.global _start

_start:

    ldw r2, N(r0) # list counter
    mov r3, r0 # list pointer

    LOOP:
        ldw r4, LIST(r3)
        bne r4, r0, END_IF # if branch

        # zeros++
        ldw r4, ZEROS(r0)
        addi r4, r4, 1
        stw r4, ZEROS(r0) 
        
        END_IF:
        subi r2, r2, 1
        addi r3, r3, 4
        bgt r2, r0, LOOP

    END: # inf loop to stall the program
        br END


# big question, is this number a multiple of 4 (word size), and this
# the data is word aligned? The answer is yes.
.org 0x1000
ZEROS: .skip 4 # I mean, the return value could be somewhere else, but this is what we are going to do :)
LIST: .word 34, 0, 57, 91, 0
N: .word 5