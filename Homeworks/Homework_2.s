.data
str1_Test1: .asciiz "Testing"
str2_Test1: .asciiz "123\n"
str1_Test2: .asciiz "\nTesting "
str2_Test2: .asciiz "Spaces . . .\n"
str1_Test3: .asciiz "\n*!(#%*!@#%)"
str2_Test3: .asciiz " This is going to be a very long string to test the code and ensure it works with long strings too.\n"
str1: .space 512	# Used for output
str2: .space 512	# Used for output
.align 2
.text
.globl main

main:
	la $a0, str1			# Assign destination address to a0
	la $a1, str1_Test1		# Put the first part of the string in a1
	jal strcat_Implementation	# Concatenate
	
	la $a1, str2_Test1		# Put the second part of the string in a1
	jal strcat_Implementation	# Concatenate
	
	# Print out the first result
	li $v0, 4
	la $a0, str1
	syscall
	
	la $a0, str2			# Assign destination address to a0
	la $a1, str1_Test2		# Put the first part of the string in a1
	jal strcat_Implementation	# Concatenate
	
	la $a1, str2_Test2		# Put the second part of the string in a1
	jal strcat_Implementation	# Concatenate
	
	# Print out the second result
	li $v0, 4
	la $a0, str2
	syscall
	
	la $a0, str1_Test3
	la $a1, str2_Test3		# Put the second part of the string in a1
	jal strcat_Implementation	# Concatenate
	
	# Print out the third result
	li $v0, 4
	la $a0, str1_Test3
	syscall
		
	# Exit program
	li $v0, 10
	syscall
	
# It is expected for a0 to have the destination pointer and a1 to have the source pointer
# Final result will be in a0
strcat_Implementation:
	la $a2, ($a0)			# Load the destination string into $a2
	li $t1, -1			# Set inital count to -1 to ignore null character
Loop:
	lb $t0, 0($a2)			# Load next byte
	addi $a2, $a2, 1		# Increment count of the string
	addi $t1, $t1 1			# Increment result
	bne $t0, $zero, Loop		# If not at the end of the string, repeat steps above
	
	add $a0, $a0, $t1		# Start the destination pointer at the correct spot
L1:	
	lb $v0, 0($a1)			# Get current byte
	beqz $v0, L2			# Done if the string is at 0 now
	sb $v0, 0($a0)			# Store current byte
	addi $a0, $a0, 1		# Increment the destination pointer
	addi $a1, $a1, 1		# Increment the source pointer
	j L1			 	# Jump back to L1 to loop
L2:
	sb $zero, 0($a0)
	jr $ra				# return