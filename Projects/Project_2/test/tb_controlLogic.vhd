-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- tb_addSub_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the barrelShifter unit.
--              
-- 10/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
library std;
use std.env.all;                
use std.textio.all;             

entity tb_controlLogic is
  generic(gCLK_HPER : time := 10 ns); 
end tb_controlLogic;

architecture mixed of tb_controlLogic is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Define barrelShifter component
component controlLogic is
  port(i_Opcode     : in std_logic_vector(5 downto 0);
       i_Funct      : in std_logic_vector(5 downto 0);
       o_Halt       : out std_logic;
       o_RegDst     : out std_logic;
       o_Jump       : out std_logic;
       o_JRSel      : out std_logic;
       o_Branch     : out std_logic;
       o_MemToReg   : out std_logic;
       o_ALUControl : out std_logic_vector(3 downto 0);
       o_MemWrite   : out std_logic;
       o_ALUSrc     : out std_logic;
       o_RegWrite   : out std_logic);
  end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal s_Opcode, s_Funct : std_logic_vector(5 downto 0) := "000000";
signal s_Halt, s_RegDst, s_Jump, s_JRSel, s_Branch : std_logic := '0';
signal s_MemToReg, s_MemWrite, s_ALUSrc, s_RegWrite : std_logic := '0';
signal s_ALUControl : std_logic_vector(3 downto 0) := "0000";
begin

  DUT0: controlLogic
  port map(i_Opcode     => s_Opcode,
           i_Funct      => s_Funct,
           o_Halt       => s_Halt,
           o_RegDst     => s_RegDst,
           o_Jump       => s_Jump,
           o_JRSel      => s_JRSel,
           o_Branch     => s_Branch,
           o_MemToReg   => s_MemToReg,
           o_ALUControl => s_ALUControl,
           o_MemWrite   => s_MemWrite,
           o_ALUSrc     => s_ALUSrc,
           o_RegWrite   => s_RegWrite);  
  
  -- Assign inputs for each test case.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- All expected outputs will be listed in 13-bit format with the following formating:
    -- Bit-12: o_Halt
    -- Bit-11: o_RegDst
    -- Bit-10: o_Jump
    -- Bit-9: o_JRSel
    -- Bit-8: o_Branch
    -- Bit-7: o_MemToReg
    -- Bits-6-3: o_ALUControl
    -- Bit-2: o_MemWrite
    -- Bit-1: o_ALUSrc
    -- Bit-0: o_RegWrite
    -- Format: 000000'0000'000 <- where 'x' will resemble the ALU control

    -- R-Format instructions
    -- add
    s_Opcode <= "000000";
    s_Funct  <= "100000";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0100'001

    -- and
    s_Funct  <= "100100";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0000'001

    -- or
    s_Funct  <= "100101";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0001'001

    -- xor
    s_Funct  <= "100110";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0010'001

    -- nor
    s_Funct  <= "100111";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0011'001

    -- addu
    s_Funct  <= "100001";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0101'001

    -- sub
    s_Funct  <= "100010";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0110'001

    -- subu
    s_Funct  <= "100011";
    wait for gCLK_HPER*2;
    -- Expect: 010000'0111'001

    -- slt
    s_Funct  <= "101010";
    wait for gCLK_HPER*2;
    -- Expect: 010000'1001'001

    -- sll
    s_Funct  <= "000000";
    wait for gCLK_HPER*2;
    -- Expect: 010000'1010'001

    -- srl
    s_Funct  <= "000010";
    wait for gCLK_HPER*2;
    -- Expect: 010000'1011'001

    -- sra
    s_Funct  <= "000011";
    wait for gCLK_HPER*2;
    -- Expect: 010000'1100'001

    -- jr
    s_Funct  <= "001000";
    wait for gCLK_HPER*2;
    -- Expect: 010100'1111'000
    -- run 265


    -- Non R-Format instructions
    -- addi
    s_Funct  <= "000000";
    s_Opcode <= "001000";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0100'011

    -- lui
    s_Opcode <= "001111";
    wait for gCLK_HPER*2;
    -- Expect: 000001'1110'011

    -- lw
    s_Opcode <= "100011";
    wait for gCLK_HPER*2;
    -- Expect: 000001'0100'011

    -- sw
    s_Opcode <= "101011";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0100'110

    -- andi
    s_Opcode <= "001100";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0000'011

    -- ori
    s_Opcode <= "001101";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0001'011

    -- xori
    s_Opcode <= "001110";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0010'011

    -- addiu
    s_Opcode <= "001001";
    wait for gCLK_HPER*2;
    -- Expect: 000000'0101'011

    -- beq
    s_Opcode <= "000100";
    wait for gCLK_HPER*2;
    -- Expect: 000010'1101'010

    -- bne
    s_Opcode <= "000101";
    wait for gCLK_HPER*2;
    -- Expect: 000010'1000'010

    -- slti
    s_Opcode <= "001010";
    wait for gCLK_HPER*2;
    -- Expect: 000000'1001'011

    -- jal
    s_Opcode <= "000011";
    wait for gCLK_HPER*2;
    -- Expect: 001000'1111'011

    -- j
    s_Opcode <= "000010";
    wait for gCLK_HPER*2;
    -- Expect: 001000'1111'010

    -- halt
    s_Opcode <= "010100";
    wait for gCLK_HPER*2;
    -- Expect: 100000'0000'000
    -- run 545

  end process;

end mixed;