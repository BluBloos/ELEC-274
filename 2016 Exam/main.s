/*
The goal is to develop a complete Nios 2 assembly-language program that uses the 
JTAG UART of the DE0 Basic Computer.

The program must first print "Type a lowercase character a-z:" and then wait for
the user to type a character. Use a loop in the main program to ensure that only a lowercase
character is accepted. All other characters should be ignored.

When a valid lowercase character is accepted, that character should be printed. The main program 
must then count the number of occurences of that lowercase character in a predefined string in
the memory, and simply write that count value as a word to a location in the memory.
 */

.text
.org 0x0000
.global _start
_start:
main:

    # need to make the stack word-aligned, that means a multiple of 4 (RAM is byte addressable)!
    # as one word in NIOS system is 32 bits, 4 bytes.
    movi sp, 0x7FFC

_end:
    br _end


# Gets char in r2.
PrintChar:

    subi sp, sp, ?

    PrintChar_Loop:


    PrintChar_LoopEnd:




    addi sp, sp, ?
    ret 


GetChar:

PrintString:

.data
.org 0x1000
COUNT: .word 0
WORD: .asciz "Type a lowercase character a-z:"
TEST_STR: .asciz "a test string of characters" 