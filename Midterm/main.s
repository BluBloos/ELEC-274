.text
.org 0x0
.global _start
_start:
_main:
    # NOTE(Noah): Very important to align the stack pointer
    movi sp, 0x7FFC 
    movi r2, DEST_VEC
    movi r3, VEC_A
    movi r4, VEC_B
    ldw r5, N(r0)
    ldw r6, MEM_VAL(r0)
    movi r7, 4 
    call VectorManipulation
    stw r2, POS_COUNT(r0)
    _end:
        br _end

# For each r list element i between 0 and n-1, 
# the required computation for this subroutine is  
# r[i] = t[i] + (a - s[i])  if  t[i] > b,  otherwise  
# r[i] = s[i] * t[i].
# 
# subroutine also maintains a count of number of items in r
# that are positive. This value is returned.
VectorManipulation:
    # r2 = r
    # r3 = s
    # r4 = t
    # r5 = n (size of each lists)
    # r6 = a 
    # r7 = b
    # r, s, and t are lists.

    mov r10, r0

    subi sp, sp, 24
    stw r3, 0(sp)
    stw r4, 4(sp)
    stw r5, 8(sp)
    stw r8, 12(sp)
    stw r9, 16(sp)
    stw r10, 20(sp)

    vm_for:
        vm_if:
            ldw r8, 0(r4)
            ble r8, r7, vm_else
            # r[i] = t[i] + (a - s[i])
            ldw r9, 0(r3)
            sub r9, r6, r9
            add r8, r8, r9
            br vm_end_if
        vm_else:
            # r[i] = s[i] * t[i]
            ldw r9, 0(r3)
            mul r8, r9, r8
        vm_end_if:
            stw r8, 0(r2)
            vm_if2:
                # NOTE(Noah): Here we are defining 
                # zero to be a positive number.
                blt r8, r0, vm_end_if2 
                addi r10, r10, 1
            vm_end_if2:
        addi r2, r2, 4
        addi r3, r3, 4
        addi r4, r4, 4
        subi r5, r5, 1
        bgt r5, r0, vm_for

    mov r2, r10
    ldw r3, 0(sp)
    ldw r4, 4(sp)
    ldw r5, 8(sp)
    ldw r8, 12(sp)
    ldw r9, 16(sp)
    ldw r10, 20(sp)
    addi sp, sp, 24

    ret

.data
.org 0x1000
N: .word 4
MEM_VAL: .word 8
DEST_VEC: .skip 16
VEC_A: .word -1,2,5,-3
VEC_B: .word 7,2,4,5
POS_COUNT: .word 0