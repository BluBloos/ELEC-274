# NOTE(Noah): The task for todays lab is to implement the following program.
# NOTE(Noah): We note that the calling convetion is simply r2, r3, etc. r2 for a return value.
# NOTE(Noah): We want to make sure to follow the systematic procedure for IF statements and LOOPS.
#   This basically means using labels.
 
/* globals:  list_a, list_b, n,
               delta, below_count 

  main::
    GenerateListValues(list_a, list_b, n, delta)
    below_count = CountBelowValues(list_b, n, 8)

  GenerateListValues(alst, blst, n, d)::
    for i = 0 to n-1 do
      blst[i] = ComputeResult(alst[i], d)
    end for

  ComputeResult(aval, d)::
    return 3 * aval - d

  CountBelowValues(list, n, threshold)::
    count = 0
    for i = 0 to n-1 do
      if (list[i] < threshold) then
        count = count + 1
      end if
    end for
    return count
*/

.text
.global _start
.org 0x0
_start:
    # GenerateListValues(list_a, list_b, n, delta)
    movi r2, list_a # this works
    movi r3, list_b
    ldw r4, n(r0)
    ldw r5, delta(r0)
    call GenerateListValues
    # CountBelowValues(list_b, n, 8)
    movi r2, list_b
    ldw r3, n(r0)
    movi r4, 8
    call CountBelowValues
    stw r2, below_count(r0)
_end:
    br _end

# void GenerateListValues(int *alist, int *blst, int n, int d)
GenerateListValues:
    # r2 = alist
    # r3 = blst
    # r4 = n
    # r5 = d
    /* NOTE(Noah): To save performance and to remove the need for caching
       registers on each subroutine call to ComputeResult, simply move the 
       func params to "far-away" regsiters. We can also directly move d into
       r3. */
    mov r6, r2 # r6 = alist
    mov r7, r3 # r7 = blist
    mov r3, r5 # r3 = d
    GenerateListValues_FOR:
        # blist[i] = ComputeResult(alst[i], d)
        ldw r2, 0(r6)
        mov r8, ra /* cache ra so it doesn't get "clobbered" */
        call ComputeResult
        mov ra, r8
        stw r2, 0(r7)
        /* loop body ends here */
        subi r4, r4, 1 # n--
        addi r6, r6, 4 # alist++
        addi r7, r7, 4 # blist++
        bgt r4, r0, GenerateListValues_FOR
    GenerateListValues_END_FOR:
    ret

# NOTE(Noah): I love how efficient this is! :)
# int ComputeResult(int aval, int d)
ComputeResult:
    # r2 = aval
    # r3 = d
    muli r2, r2, 3
    sub r2, r2, r3
    ret

# int CountBelowValues(int *list, int n, int threshold) 
CountBelowValues:
    # r2 = *list
    # r3 = n 
    # r4 = threshold
    mov r5, r0 # init count
    CountBelowValues_FOR:
        CountBelowValues_IF:
        ldw r6, 0(r2) # *list
        bge r6, r4, CountBelowValues_END_IF 
        addi r5, r5, 1
        CountBelowValues_END_IF:
        subi r3, r3, 1 # n--
        addi r2, r2, 4 # list++
        bgt r3, r0, CountBelowValues_FOR
    CountBelowValues_END_FOR:
    mov r2, r5 # return count
    ret

.org 0x1000 # this is an addr byte aligned with word size = 4 bytes
n: .word 5
list_a: .word 1, 2, 3, 4, 5
list_b: .word 0, 0, 0, 0, 0 
delta: .word 3
below_count: .word 0 