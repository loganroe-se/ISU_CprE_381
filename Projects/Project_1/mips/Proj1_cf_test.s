# Assembly Code for Factorial Calculation using bne

# Data section
.data
    result:    .word 0
    number:    .word 5

# Text section
.text
    .globl main
    
# Load 0x7FFFEFFC
lui $sp, 0x7FFF
ori $sp, $sp, 0xEFFC
j main

# Summation function
Summation:
    # Summation prologue
    # Save registers and set up the stack frame
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $a0, 0($sp)

    # Summation calculation
    lw $a0, number
    li $v0, 1          # Initialize result to 1
    li $t1, 1          # Initialize a counter to 1

    loop:
        beq $t1, $a0, end  # if (counter == number) jump to end
        add $v0, $v0, $t1  # result += counter
        addi $t1, $t1, 1    # counter++
        bne $t1, $a0, loop  # if (counter != number) jump back to loop
        add $v0, $v0, $t1
    end:
    
    # Restore registers and clean up the stack
    lw $a0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    jr $ra

main:
    # Initialize result and call the summation function
    lw $a0, number
    jal Summation

    # Store the result in the "result" variable
    sw $v0, result
    
    # Print the result
    lw $a0, result
    li $v0, 1
    syscall

    # Exit the program
    halt
