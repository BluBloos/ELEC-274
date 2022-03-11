# directives from my boy Manji
#   modular subroutines
#   save the register values, duh..  

.text
.global _start  
.org 0x00000

# Done.
_start:
    movi sp, 0x7FFC
    movi r2, str1
    call PrintString # print("L3 for Noah Cabral") 
    movi r2, list 
    ldw r3, n(r0)
    call TrendBetweenItems
_end:
    br _end


# takes in list_ptr, n_items
TrendBetweenItems:
    # r2 = list_ptr
    # r3 = n_items

    subi sp, sp, 28
    stw r2, 0(sp)
    stw r3, 4(sp)
    stw r4, 8(sp)
    stw r5, 12(sp)
    stw r6, 16(sp)
    stw r7, 20(sp) 
    stw ra, 24(sp)

    mov r4, r2 # list_ptr needs to change loc beacuse r2 is borked is used when calling print routines

    # print("trend between items:")
    movi r2, str2
    call PrintString

    # init last item = 0
    mov r5, r0

    TrendBetweenItems_for:

        # print("...")
        movi r2, str3
        call PrintString

        ldw r6, 0(r4) # grab list_ptr[i]
        sub r7, r6, r5 # diff = list_ptr[i] - last_item

        TrendBetweenItems_if:
            bge r7, r0, TrendBetweenItems_elseif
            movi r2, 0x5C # 0x5C = '\\'
            call PrintChar
            br TrendBetweenItems_endif
        TrendBetweenItems_elseif:
            ble r7, r0, TrendBetweenItems_else
            movi r2, 0x2F # 0x2F = '/'
            call PrintChar
            br TrendBetweenItems_endif
        TrendBetweenItems_else:
            movi r2, 0x2D # 0x2D = '-'
            call PrintChar
        TrendBetweenItems_endif:

        mov r5, r6 # last_item = list_ptr[i]        

        addi r4, r4, 4 # list_ptr++
        subi r3, r3, 1 
        bgt r3, r0, TrendBetweenItems_for  

    TrendBetweenItems_endfor:

    # PrintChat('\n')
    movi r2, 0xA 
    call PrintChar

    ldw r2, 0(sp)
    ldw r3, 4(sp)
    ldw r4, 8(sp)
    ldw r5, 12(sp)
    ldw r6, 16(sp)
    ldw r7, 20(sp) 
    ldw ra, 24(sp)
    addi sp, sp, 28

    ret

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

.org 0x1000  
n: .word 6
list: .word -1, 8, 3, 3, 5, 7
str1: .asciz "L3 for Noah Cabral\n"
str2: .asciz "trend between items:"
str3: .asciz "..."
