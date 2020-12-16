#; fibonacci sequence
# alexis ugalde

.data
#;	System Service Codes
	SYSTEM_EXIT = 10
	SYSTEM_PRINT_INTEGER = 1
	SYSTEM_PRINT_STRING = 4
	SYSTEM_READ_INTEGER = 5
	numcalls: .word 0
	
#;	Strings
	fibPrompt: .asciiz "Calculate Fibonacci sequence number (1-46): "
	badFibNum: .asciiz "Number must be between 1 and 46. \n"
    calls: .asciiz " function calls required. \n"
    endLine: .asciiz "\n"
    fibOutput: .asciiz "Top Down Fibonacci("
    fibPart2: .asciiz "): "

    bottomUpOutput: .asciiz "Bottom Up Fibonacci("
    wtf: .asciiz "wtf"

.text
.globl main
.ent main
main:
    checkBounds:
        #;	Ask for n
        li $v0, SYSTEM_PRINT_STRING
        la $a0, fibPrompt
        syscall
        
        # read 
        li $v0, SYSTEM_READ_INTEGER
        syscall

        #;	Check that input is within specified bounds
        blt $v0, 1, badFig    # if n < 1 
        bgt $v0, 46, badFig   # if n > 46
        b acceptedBounds        
        badFig:
            # print err msg
            li $v0, SYSTEM_PRINT_STRING
            la $a0, badFibNum
            syscall
            b checkBounds   #; will  re promt until not <5 && >80

			move $s0, $v0   #; n

                
        acceptedBounds: 
        move $s0, $v0
        move $a0, $s0
        la $a1, numcalls
        jal topDown
        move $s1, $v0
        
        li $v0, SYSTEM_PRINT_STRING
        la $a0, fibOutput
        syscall
        li $v0, SYSTEM_PRINT_INTEGER
        move $a0, $s0
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, fibPart2
        syscall
        li $v0, SYSTEM_PRINT_INTEGER
        move $a0, $s1
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, endLine
        syscall
        la $t0, numcalls
        lw $t1, ($t0)
        li $v0, SYSTEM_PRINT_INTEGER
        move $a0, $t1
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, calls
        syscall
        la $t0, numcalls
        sw $zero, ($t0)
        move $a0, $s0
        li $a1, 1
        li $a2, 1
        li $a3, 0
        la $t0, numcalls
        sub $sp, $sp, 4
        sw $t0, ($sp)
        jal bottomUp
        add $sp, $sp, 4
        move $s1, $v0
        li $v0, SYSTEM_PRINT_STRING
        la $a0, bottomUpOutput
        syscall
        li $v0, SYSTEM_PRINT_INTEGER
        move $a0, $s0
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, fibPart2
        syscall
        li $v0, SYSTEM_PRINT_INTEGER
        move $a0, $s1
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, endLine
        syscall
        la $t0, numcalls
        lw $a0, ($t0)
        li $v0, SYSTEM_PRINT_INTEGER
        syscall
        li $v0, SYSTEM_PRINT_STRING
        la $a0, calls
        syscall
        
        
	endProgram:
	li $v0, SYSTEM_EXIT
	syscall
.end main


.globl topDown
.ent topDown
topDown:
#; The arguments to the function must be (in order):
#; 1. n = a0
#; 2. The number of function calls made by-reference a1

    sub $sp, $sp, 4
    sw $ra, ($sp)    

    lw $t0, ($a1)   # getting the number of calls
    add $t0, $t0, 1 # incrementing number of calls
    sw $t0, ($a1)

    beq $a0, 0 baseCase1
    b baseCase2
    baseCase1:
        li $v0, 0 # load 0 in return register v0
        b endFib
    baseCase2:
        bne $a0, 1, recursiveCall
        li $v0, 1
        b endFib

    recursiveCall:
        # preserving the value of $a0
        sub $sp, $sp, 4
        sw $a0, ($sp)

        sub $a0, $a0, 1 # n - 1
        move $a1, $a1
        jal topDown     # return value in $v0

        # restoring the value of a0 into t0
        lw $a0, ($sp)
        add $sp, $sp, 4

        # storing 1st recursive result onto the stack
        sub $sp, $sp, 4
        sw $v0, ($sp)

        # preserve value of a0
        sub $sp, $sp, 4
        sw $a0, ($sp)

        sub $a0, $a0, 2
        move $a1, $a1
        jal topDown     # return value in v0

        # restore value of a0
        lw $a0, ($sp)
        add $sp, $sp, 4

        lw $t0, ($sp) # n-1 return value in t0
        add $sp, $sp, 4

        add $v0, $t0, $v0
    endFib:
        lw $ra, ($sp)
        add $sp, $sp, 4
        jr $ra
.end topDown
#;

.globl bottomUp
.ent bottomUp
bottomUp:
#; a0 = final value n to calculate
#; a1 = current n 
#; a2 = value generated previously f(n-1) as an integer
#; a3 = value generated previously f(n-2) as an integer
#; a4 = number of function calls made by-reference

#; access fifth arg with frame pointer 
#; Use 1 as the value for argument 2 on the initial call 
#; and pick appropriate values for arguments 3 and 4.
    sub $sp, $sp, 4
    sw $ra, ($sp)
    sub $sp, $sp, 4
    sw $fp, ($sp)
    add $fp, $sp, 8

    add $a1, $a1, 1
    checkBaseCase:
        bne $a1, $a0, incrementNumCalls
        li $v0, 1
        b endFib2

    incrementNumCalls:
        lw $t1, ($fp)
        lw $t0, ($t1)
        add $t0, $t0, 1
        sw $t0, ($t1)
        sw $t1, ($fp)

    recursiveCall2:        
        move $t0, $a2
        add $a2, $a3, $a2
        move $a3, $t0
        sub $sp, $sp, 4
        sw $t0, ($sp)

        lw $t1, ($fp)
        sub $sp, $sp, 4
        sw $t1, ($sp)

        jal bottomUp

        lw $t1, ($sp)
        add $sp, $sp, 4
        lw $t0, ($sp)
        add $sp, $sp, 4

        add $v0, $v0, $t0

    endFib2:
    lw $fp, ($sp)
    add $sp, 4
    lw $ra, ($sp)
    add $sp, $sp, 4
	jr $ra
.end bottomUp
