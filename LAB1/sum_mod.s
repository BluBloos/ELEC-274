/*
TODO(Noah): This here is the new desired pseudocode that our assembly program
should conform to.

sum = 0
for i = 0 to N-1 do
    if (list[i] > 0) then
        sum = sum + list[i]
    end if
end for

list = [ 12, -2, 7, -1, 2  ]
expected sum = 12 + 7 + 2 = 21 = 0x15
*/
 

.text
.global _start  
.org 0x00000

_start:
    ldw r2, N(r0)
    movi r3, LIST 
    movi r4, 0 # sum = 0
 LOOP:
 IF:
    ldw r5, 0(r3) # r5 = list[i]
    ble r5, r0, END_IF 
 THEN:
    add r4, r4, r5
 END_IF:
    addi r3, r3, 4 # i++
    subi r2, r2, 1  
    bgt r2, r0, LOOP
 LOOP_END:
    stw r4, SUM(r0) 

_end:
    br _end

# okay so .org directive makes things exist in machine code
# output at a specific location in the .exe
.org 0x1000  

SUM: .skip 4
N: .word 5

# hex value is -2 in two's compliment
LIST: .word 12, 0xFFFFFFFE, 7, -1, 2 
    .end

