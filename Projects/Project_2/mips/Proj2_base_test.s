# Addi (add immediate) example
addi $s0, $zero, 10      # $s0 = 10

# Add example
add $t0, $s0, $s0       # $t0 = $s0 + $s0 = 20
    
# Addiu (add immediate unsigned) example
addiu $s1, $t0, 5       # $s1 = $t0 + 5 = 25

# Addu (add unsigned) example
addu $t1, $s1, $s0      # $t1 = $s1 + $s0 = 35

# And example
and $s2, $t1, $s1       # $s2 = $t1 & $s1 = 1

# Andi (and immediate) example
andi $t2, $s2, 0x0F     # $t2 = $s2 & 0x0F = 1

# Lui (load upper immediate) example
lui $s3, 0x1001         # $s3 = 0x1001 = 0x10010000

# Store Word (sw) example
sw $t1, 4($s3)

# Load Word (lw) example – memory: 0x1001001C
lw $t3, 4($s3)          # $t3 = Memory[$s3 + 4] = Mem[10010004] (preloaded: FFFFFF24)

# Nor example
nor $s4, $t3, $t2       # $s4 = ~($t3 | $t2) = ~(FFFFFF24 | 00000001) = 000000DA = 218
    
# Xor example
xor $t4, $s4, $s1       # $t4 = $s4 ^ $s1 = 000000F9 = 249
    
# Xori (xor immediate) example
xori $s5, $t4, 0x55    # $s5 = $t4 ^ 0x55 = 000000AC = 172
    
# Or example
or $t5, $s5, $s2      # $t5 = $s5 | $s2 = 000000AD = 173
    
# Ori (or immediate) example
ori $s6, $t5, 0xAA    # $s6 = $t5 | 0xAA = 000000AF = 175
    
# Set on Less Than (slt) example
slt $t6, $s6, $s1     # $t6 = ($s6 < $s1) ? 1 : 0 = 175 /< 35 = 0
    
# Set on Less Than Immediate (slti) example
slti $s7, $t6, 5      # $s7 = ($t6 < 5) ? 1 : 0 = 0 < 5 = 1
    
# Shift Left Logical (sll) example
sll $t7, $s7, 2       # $t7 = $s7 << 2 = 1 * 4 = 4
    
# Shift Right Logical (srl) example
srl $t0, $t7, 1       # $t0 = $t7 >> 1 = 4/2 = 2
    
# Shift Right Arithmetic (sra) example
sra $t8, $t0, 1       # $t8 = $t0 >> 1 (arithmetic shift) = 2/1 = 1
    
# Store Word (sw) example
sw $t8, 8($s3)         # Memory[$s3 + 8] = $t8 = Mem[FF000008] = 1
    
# Subtract example
sub $t1, $s6, $s5     # $t1 = $s6 - $s5 = 175 - 172 = 3
    
# Subtract Unsigned example
subu $t9, $t1, $t0    # $t9 = $t1 - $t0 = 3 - 2 = 1
    
# Branch Equal (beq) example
beq $t9, $t8, equal    # If $t9 == $t8, branch to "equal" label – 1 = 1, branch
    
# Jump (j) example
j end2 

equal:                      # Branch Not Equal (bne) example – memory address is 0x1001005C
bne $t9, $s0, not_equal     # If $t9 != $s0, branch to "not_equal" label – 1 != 10, branch

j end2                       # Will only execute if it does not branch in previous instruction

not_equal:                  # Memory address is 0x10010064
	jal jalTest
	j equal

jalTest:                    # Memory address is 0x1001006C
    beq $t9, $s0, end2 # 1 != 10, don’t branch
	addi $t9, $zero, 10 # on the second iteration of the bne instruction, it will not branch
	jr $ra

end2:
	halt
