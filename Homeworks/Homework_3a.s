.data
str_Input: .asciiz "Please enter a positive integer to calculate Fibonacci's number with: "
str_OutputPrompt: .asciiz "\nHere is Fibonacci's number for the entered integer: "
str_Output: .space 512	# Used for output
.align 2
.text
.globl main

main:
	# Request some user input:
	li $v0, 4
	la $a0, str_Input
	syscall
	# Read some user input:
	li $v0, 5
	syscall
	
	# Call the function to find Fibonacci's number
	move $a0, $v0			# Move the read in integer into the argument register for the function
	jal iterative_Fibonacci		# Jump and link to the iterative Fibonacci function
	move $t0, $v0			# Move the output to a temporary register
	
	# Print out the prompt to give Fibonacci's number
	li $v0, 4
	la $a0, str_OutputPrompt
	syscall
	
	# Print out Fibonacci's number
	li $v0, 1
	move $a0, $t0
	syscall
		
	# Exit program
	li $v0, 10
	syscall
	
# It is expected for a0 to have the integer to find Fibonacci's number for
# Final result will be in v0
iterative_Fibonacci:
	# Initalize the three starting values
	addi $t0, $zero, 0
	addi $t1, $zero, 1
	add $t2, $t0, $t1
	
	# If the integer is one of the first three values, return it, otherwise, loop
	beq $a0, $t1, firstNum
	addi $t3, $zero, 2		# Put 2 in regstier t3
	beq $a0, $t3, secondNum
	addi $t3, $zero, 3		# Put 3 in regstier t3
	beq $a0, $t3, secondNum		# Due to the second and third numbers both being 1, the same code can be used (secondNum here)
	
	# If it got past the previous checks, the entered integer is greater than 3, so start the loop to find the number
	addi $t3, $zero, 3		# Initialize count to 3
	j findNum			# Call the loop to find the number
	
firstNum:
	move $v0, $t0			# Set the return value to 0
	j EXIT				# Return
	
secondNum:
	move $v0, $t1			# Set the return value to 1
	j EXIT				# Return
	
findNum:
	move $t0, $t1			# Move the second stored value to the now first stored value
	move $t1, $t2			# Move the third stored value to the now second stored value
	add $t2, $t0, $t1		# Get the next number in the sequence
	addi $t3, $t3, 1		# Increment count register
	bne $t3, $a0, findNum		# If not at the requested integer yet, loop
	
	# If at the correct integer, assign the return value and exit
	move $v0, $t2
	j EXIT
	
EXIT:
	jr $ra				# Return to where this was called from