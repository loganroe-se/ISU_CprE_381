.data
str1: .asciiz "Please enter an index to average:\n"
str2: .asciiz "Please enter an index to save to:\n"
.align 2
vals: .word 25 1 4 10 381 42 100 60 0 12
.text
.globl main

main:
# Start program
addi $s1, $zero, 0 # s1 is ouput value
inputs:
# Request some user input:
li $v0, 4
la $a0, str1
syscall
# Read some user input:
li $v0, 5
syscall

# Copy value over to $s2
ori $s2, $v0, 0

# Request some user input:
li $v0, 4
la $a0, str1
syscall
# Read some user input:
li $v0, 5
syscall

# Copy value over to $s3
ori $s3, $v0, 0

# Request some user input:
li $v0, 4
la $a0, str2
syscall
# Read some user input:
li $v0, 5
syscall

# Copy value over to $s4
ori $s4, $v0, 0

# Store array address
la $t3, vals

# Add the two chosen values into a temporary register
sll $t4, $s2, 2 # Multiply by 4 to get the right addressing
lw $t0, vals($t4)
sll $t4, $s3, 2
lw $t1, vals($t4)
add $t2, $t0, $t1

# Divide the added values by 2 to get the average
srl $t2, $t2, 1

# Store the average in the requested location
sll $t4, $s4, 2
sw $t2, vals($t4)

# Output the average
li $v0, 1
addi $a0, $t2, 0
syscall
# Exit program
li $v0, 10
syscall