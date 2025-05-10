addi $t0, $zero, 10
lui $s0, 0x1001
sw $t0, 4($s0)
lw $t1, 4($s0)
addi $t2, $t1, 5
halt