/*
- Program should write to variables in memory to reflect the pseudocode spec.
- Position the executable code at memory address 0x30.
- data at memory address 0x2000
- The data directives should initialize B to 2,   K to 3 ,   W to 4,   and X to 5.

- Determine what the final values of the variables should be, based on the initial values above.
J = (2) + 1 = 3
H = ((4) * (3)) - (3) = 9
F = 9 - (4) + 5 = 10

- Verify the correctness of your program by test execution and memory inspection 
to confirm that the variable values match your determination above.
- In the space below, copy/paste your complete program. It should be free of syntax errors.

J = B + 1
H = (W * J) - K
F = H - W + X

*/

.text

.global _start  
.org 0x30

_start:

    # NOTE(Noah): You can see that there are many redudancies due to the use of 
    # data locations for the variables J and H. These are intermediate values and as such
    # may be stored in registers.
    #
    # Of course, this is assuming that F is the only desired output. Maybe the intention of this code
    # is to also return values J and H? Who knows.

    # J = B + 1
    ldw r2, B(r0) # r0 and r1 are reserved so we start our register allocs with r2
    addi r3, r2, 1
    stw r3, J(r0)

    # H = (W * J) - K
    ldw r2, W(r0)
    ldw r3, J(r0)
    mul r2, r2, r3
    ldw r3, K(r0)
    sub r2, r2, r3
    stw r2, H(r0)

    # F = H - W + X
    ldw r2, H(r0)
    ldw r3, W(r0)
    sub r2, r2, r3
    ldw r3, X(r0)
    add r2, r2, r3
    stw r2, F(r0)

_end:
    br _end


.org 0x2000
B: .word 2
K: .word 3
W: .word 4
X: .word 5
J: .word 0
H: .word 0
F: .word 0