-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- ALU.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an ALU.
--              
-- 10/09/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
  generic(N : integer := 32);
  port(i_ALUControl : in std_logic_vector(3 downto 0);
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       i_Shamt      : in std_logic_vector(4 downto 0);
       o_Result     : out std_logic_vector(N-1 downto 0);
       o_Zero       : out std_logic;
       o_Co         : out std_logic;
       o_Overflow   : out std_logic);

end ALU;

architecture structural of ALU is
    signal s_and, s_or, s_nor, s_xor   : std_logic_vector(N-1 downto 0);
    signal s_barrelShifter, s_lui      : std_logic_vector(N-1 downto 0);
    signal s_addSubOut, s_slt          : std_logic_vector(N-1 downto 0);
    signal s_BSSel                     : std_logic_vector(1 downto 0);
    signal s_addSubSel, s_carryOut     : std_logic;
    signal s_shiftType, s_shiftDir     : std_logic;
    signal s_zeroLog, s_OF             : std_logic;

    component BarrelShifter is
        generic(N : integer := 32;
                A : integer := 5);
        port(i_In         : in std_logic_vector(N-1 downto 0);
            i_Shamt       : in std_logic_vector(A-1 downto 0);
            i_ShiftType   : in std_logic;
            i_ShiftDir    : in std_logic;
            o_Out         : out std_logic_vector(N-1 downto 0));
    end component;

    component addSub_N is
        generic(N : integer := 32);
        port(i_AddSub     : in std_logic;
            i_A          : in std_logic_vector(N-1 downto 0);
            i_B          : in std_logic_vector(N-1 downto 0);
            o_O          : out std_logic_vector(N-1 downto 0);
            o_Co         : out std_logic;
            o_OF         : out std_logic);
    end component;

begin
    -- Logic components - and/or/nor/xor
    s_and <= i_A and i_B;
    s_or  <= i_A or i_B;
    s_nor <= not s_or;
    s_xor <= i_A xor i_B;

    -- Sll/srl/sra select
    with i_ALUControl select
        s_BSSel <= "00" when "1010",
                   "01" when "1011",
                   "11" when "1100",
                   "00" when others;

    -- Assign barrel shifter select signals
    s_shiftType <= s_BSSel(1);
    s_shiftDir  <= s_BSSel(0);

    -- Barrel shifter - sll/srl/sra
    shiftBS: BarrelShifter
        port map(
            i_In        => i_B,
            i_Shamt     => i_Shamt,
            i_ShiftType => s_shiftType,
            i_ShiftDir  => s_shiftDir,
            o_Out       => s_barrelShifter);

    -- Add/sub select - based on beq, bne, sub, subu, slt
    with i_ALUControl select
        s_addSubSel <= '1' when "0110" | "0111" | "1000" | "1101" | "1001",
                       '0' when others;

    -- Add/sub component - add/addi/lw/sw/addu/addiu/sub/subu/beq/bne
    addSub: addSub_N
        port map(
            i_AddSub    => s_addSubSel,
            i_A         => i_A,
            i_B         => i_B,
            o_O         => s_addSubOut,
            o_Co        => s_carryOut,
            o_OF        => s_OF);

    o_Co <= s_carryOut;

    -- Determine overflow - based on add, addi, sub, lw, sw, beq, bne, slt
    with i_ALUControl select
        o_Overflow <= s_OF when "0100" | "0110" | "1101" | "1000" | "1001",
                       '0' when others;

    -- Barrel shifter for lui
    luiBS: BarrelShifter
        port map(
            i_In        => i_B,
            i_Shamt     => "10000",
            i_ShiftType => '0',
            i_ShiftDir  => '0',
            o_Out       => s_lui);

    -- Branching - beq/bne
    with s_addSubOut select
        s_zeroLog <= '1' when x"00000000",
                     '0' when others;

    with s_zeroLog & i_ALUControl select
        o_Zero    <= '1' when "11101" | "01000",
                     '0' when others;

    -- Set less than
    with s_addSubOut(N-1) & i_ALUControl select
        s_slt     <= x"00000001" when "11001",
                     x"00000000" when others;

    -- Select which of the calculated values to use based on the instruction
    with i_ALUControl select
        o_Result <= s_and           when "0000",
                    s_or            when "0001",
                    s_xor           when "0010",
                    s_nor           when "0011",
                    s_addSubOut     when "0100" | "0101" | "0110" | "0111", --add, addi, lw, sw, addu, addiu, sub, subu
                    s_slt           when "1001",
                    s_barrelShifter when "1010" | "1011" | "1100", --sll, srl, sra
                    s_lui           when "1110",
                    x"00000000"     when others; -- beq, bne, jal, jr, j
end structural;
