library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_ALU is
    generic(gCLK_HPER : time := 10 ns;
            N : integer := 32);
end tb_ALU;

architecture mixed of tb_ALU is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Define ALU component
component ALU is
   port(i_ALUControl : in std_logic_vector(3 downto 0);
        i_A          : in std_logic_vector(N-1 downto 0);
        i_B          : in std_logic_vector(N-1 downto 0);
        i_Shamt      : in std_logic_vector(4 downto 0);
        o_Result     : out std_logic_vector(N-1 downto 0);
        o_Zero       : out std_logic;
        o_Co         : out std_logic;
        o_Overflow   : out std_logic);
end component;

signal CLK, reset               : std_logic := '0';
signal s_ALUControl             : std_logic_vector(3 downto 0) := "0000";
signal s_A, s_B                 : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_Shamt                  : std_logic_vector(4 downto 0) := "00000";
signal s_Result                 : std_logic_vector(N-1 downto 0) := x"00000000";
signal s_Zero, s_Co, s_Overflow : std_logic := '0'; 
begin

  DUT0: ALU
  port map(
            i_ALUControl    => s_ALUControl,
            i_A             => s_A,
            i_B             => s_B,
            i_Shamt         => s_Shamt,
            o_Result        => s_Result,
            o_Zero          => s_Zero,
            o_Co            => s_Co,
            o_Overflow      => s_Overflow);

  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  

  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2;

    --and, andi - expected output = x00000002
    s_ALUControl <= "0000";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --or, ori --expected output = x0000000b 
    s_ALUControl <= "0001"; 
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --xor, xori --expected output = x00000009 
    s_ALUControl <= "0010"; 
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --nor --expected output = xFFFFFFF4
    s_ALUControl <= "0011";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --add, addi, lw, sw --expected output = x0000000d
    s_ALUControl <= "0100";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --add, addi --expected output x00000000 OF = 1
    s_ALUControl <= "0100";
    s_A <= x"80000000";
    s_B <= x"80000000";
    wait for gCLK_HPER*2;

    --addu, addiu --expected output x00000000 OF = 0
    s_ALUControl <= "0101";
    s_A <= x"80000000";
    s_B <= x"80000000";
    wait for gCLK_HPER*2;

    --sub --expected output x00000007 OF = 0
    s_ALUControl <= "0110";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --sub --expected output x40000000 OF = 1
    s_ALUControl <= "0110";
    s_A <= x"80000000";
    s_B <= x"40000000";
    wait for gCLK_HPER*2;

    --subu --expected output x40000000 OF = 0
    s_ALUControl <= "0111";
    s_A <= x"80000000";
    s_B <= x"40000000";
    wait for gCLK_HPER*2;

    --beq not equal --expected output zero = 0
    s_ALUControl <= "1101";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --beq equal --expected output zero = 1
    s_ALUControl <= "1101";
    s_A <= x"00000003";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --bne equal --expected output zero = 0
    s_ALUControl <= "1000";
    s_A <= x"00000003";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --bne equal --expected output zero = 1
    s_ALUControl <= "1000";
    s_A <= x"00000003";
    s_B <= x"0000000a";
    wait for gCLK_HPER*2;

    --slt, slti -- less than --expected output 0x00000001
    s_ALUControl <= "1001";
    s_A <= x"00000003";
    s_B <= x"0000000a";
    wait for gCLK_HPER*2;

    --slt, slti -- not less than --expected output 0x00000000
    s_ALUControl <= "1001";
    s_A <= x"0000000a";
    s_B <= x"00000003";
    wait for gCLK_HPER*2;

    --sll --sll 2 --expected output 0x0000000c
    s_ALUControl <= "1010";
    s_B <= x"00000003";
    s_Shamt <= "00010";
    wait for gCLK_HPER*2;

    --srl --srl 2 --expected output 0x00000003
    s_ALUControl <= "1011";
    s_B <= x"0000000c";
    s_Shamt <= "00010";
    wait for gCLK_HPER*2;

    --sra --sra 4 --expected output 0xFF000003
    s_ALUControl <= "1100";
    s_B <= x"F0000030";
    s_Shamt <= "00100";
    wait for gCLK_HPER*2;

    --lui --expeted output 0x12340000
    s_ALUControl <= "1110";
    s_B <= x"00001234";
    wait for gCLK_HPER*2;

    -- run 405

  end process;

end mixed;