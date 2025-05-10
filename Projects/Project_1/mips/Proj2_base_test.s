# Addi (add immediate) example
addi $s0, $zero, 10      # $s0 = 10

# Addiu (add immediate unsigned) example
addiu $s1, $zero, 6       # $s1 = 6

# nop
sll $zero, $zero, 0

# Addu (add unsigned) example
addu $t1, $s0, $zero      # $t1 = $s0 = 10

# And example
and $s2, $s0, $s1       # $s2 = $s0 & $s1 = 10 & 6 = 2

# Andi (and immediate) example
andi $t2, $s1, 0x0F     # $t2 = $s1 & 0x0F = 6

# Lui (load upper immediate) example
lui $s3, 0x1001         # $s3 = 0x1001 = 0x10010000

# nop
sll $zero, $zero, 0

# nop
sll $zero, $zero, 0

# Store Word (sw) example
sw $t1, 4($s3)

# nop
sll $zero, $zero, 0

# nop
sll $zero, $zero, 0

# Load Word (lw) example – memory: 0x1001001C
lw $t3, 4($s3)          # $t3 = Memory[$s3 + 4] = Mem[10010004] (preloaded: FFFFFF24)

# nop
sll $zero, $zero, 0

# nop
sll $zero, $zero, 0

# Nor example
nor $s4, $t3, $t2       # $s4 = ~($t3 | $t2) = ~(FFFFFF24 | 00000006) = 000000D6 = 214

# Xor example
xor $t4, $s0, $s1       # $t4 = $s0 ^ $s1 = 000000009 = 9
    
# Xori (xor immediate) example
xori $s5, $s0, 0x55    # $s5 = $s0 ^ 0x55 = 0000005F = 95

# Or example
or $t5, $s0, $s1      # $t5 = $s0 | $s1 = 0000000E = 14

# Ori (or immediate) example
ori $s6, $s0, 0x1   # $s6 = $t5 | 0xAA = 0000000B = 11

# Set on Less Than (slt) example
slt $t6, $s0, $s1     # $t6 = ($s0 < $s1) ? 1 : 0 = 10 /< 6 = 0

# Set on Less Than Immediate (slti) example
slti $s7, $s0, 11     # $s7 = ($s0 < 11) ? 1 : 0 = 10 < 11 = 1

# Shift Left Logical (sll) example
sll $t7, $s0, 2       # $t7 = $s0 << 2 = 10 * 4 = 40

# Shift Right Logical (srl) example
srl $t0, $s0, 1       # $t0 = $s0 >> 1 = 10/2 = 5

# Shift Right Arithmetic (sra) example
sra $t8, $s1, 1       # $t8 = $t0 >> 1 (arithmetic shift) = 6/2 = 3

# Subtract example
sub $s6, $s6, $t4     # $t1 = $s6 - $s5 = 11 - 9 = 2

# Subtract Unsigned example
subu $t9, $s0, $s1   # $t9 = $s0 - $s1 = 10 - 6 = 4

# Branch Equal (beq) example
beq $t1, $s0, equal    # If $t1 == $s0, branch to "equal" label – 1 = 1, branch

# Jump (j) example
j end2 

equal:                      # Branch Not Equal (bne) example – memory address is 0x1001005C
bne $s1, $s0, not_equal     # If $s1 != $s0, branch to "not_equal" label – 6 != 10, branch

j end2                       # Will only execute if it does not branch in previous instruction

not_equal:                  # Memory address is 0x10010064
	jal jalTest
	j equal

jalTest:                    # Memory address is 0x1001006C
    beq $t9, $s0, end2 # 4 != 10, don’t branch
	addi $t9, $zero, 10 # on the second iteration of the bne instruction, it will not branch
	jr $ra

end2:
	halt