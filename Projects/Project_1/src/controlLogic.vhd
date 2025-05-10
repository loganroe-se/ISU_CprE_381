-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- controlLogic.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of control logic.
--
-- 10/04/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity controlLogic is
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
end controlLogic;

architecture behavioral of controlLogic is
    signal s_RFormat, s_concatControls : std_logic_vector(12 downto 0);
begin
    -- if else statement to check for the function code and see if it is a jump register function code? if we can input function code
    -- then we only need a few with select statements because all opcodes of 000000 (R-format) every output is the same (excluding jr)

    -- Selects which of the R-format instructions are being used, if any
    with i_Opcode & i_Funct select
        s_RFormat <= "0100000100001" when "000000100000",
                     "0100000000001" when "000000100100",
                     "0100000001001" when "000000100101", 
                     "0100000010001" when "000000100110",
                     "0100000011001" when "000000100111",
                     "0100000101001" when "000000100001",
                     "0100000110001" when "000000100010",
                     "0100000111001" when "000000100011",
                     "0100001001001" when "000000101010",
                     "0100001010001" when "000000000000",
                     "0100001011001" when "000000000010",
                     "0100001100001" when "000000000011",
                     "0101001111000" when "000000001000",
                     "0000000000000" when others;

    -- Selects the final concatenated output, which is the output of the previous with-select if R-format
    with i_Opcode select
        s_concatControls <= s_RFormat when "000000",
                            "0000000100011" when "001000",
                            "0000001110011" when "001111",
                            "0000010100011" when "100011",
                            "0000000100110" when "101011",
                            "0000000000011" when "001100",
                            "0000000001011" when "001101",
                            "0000000010011" when "001110",
                            "0000000101011" when "001001",
                            "0000101101000" when "000100",
                            "0000101000000" when "000101",
                            "0000001001011" when "001010",
                            "0010001111011" when "000011",
                            "0010001111010" when "000010",
                            "1000000000000" when "010100",   -- halt
                            "0000000000000" when others;

    -- Assign the individual values from the concatenated output to their corresponding values
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
    o_Halt                   <= s_concatControls(12);
    o_RegDst                 <= s_concatControls(11);
    o_Jump                   <= s_concatControls(10);
    o_JRSel                  <= s_concatControls(9);
    o_Branch                 <= s_concatControls(8);
    o_MemToReg               <= s_concatControls(7);
    o_ALUControl(3 downto 0) <= s_concatControls(6 downto 3);
    o_MemWrite               <= s_concatControls(2);
    o_ALUSrc                 <= s_concatControls(1);
    o_RegWrite               <= s_concatControls(0);
end behavioral;