addi $t0, $zero, 5
addi $t1, $zero, 5
beq $t0, $t1, test
end:
	halt
test:
	addi $t2, $zero, 2
	j end