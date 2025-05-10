.data
.align 2
.text
.globl main

main:
	# Initialize values -- Note: i and j initializations happen in the code from part a
	addi $s0, $zero, 10		# Initialize a to 10
	addi $s1, $zero, 1		# Initialize b to 1
	addi $s2, $zero, 0x10010000 	# Initialize s2 to be base address
	
	# Nested for loop implementation
	addi $t0, $zero, 0
	j Test1
Loop1:
	addi $t1, $zero, 0
	beq $zero, $zero Test2

Loop2:
	add $t3, $t0, $t1
	sll $t2, $t1, 3
	add $t2, $t2, $s2
	sw $t3, 0($t2)
	addi $t1, $t1, 1

Test2:
	slt $t2, $t1, $s1
	bne $t2, $zero, Loop2
	addi $t0, $t0, 1

Test1:
	slt $t2, $t0, $s0
	bne $t2, $zero, Loop1
		
	# Exit program
	li $v0, 10
	syscall