-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- HazardUnit.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit register
--             
-- 08/30/2023
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;


entity HazardDetectionUnit is
 generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
 port(i_IDMemRead   : in std_logic;
      i_IDRegRT     : in std_logic_vector(N-1 downto 0);
      i_IFRegRS     : in std_logic_vector(N-1 downto 0);
      i_IFRegRT     : in std_logic_vector(N-1 downto 0);
      i_BranchJump  : in std_logic;
      o_PCStall     : out std_logic;
      o_IFRegOut    : out std_logic_vector(1 downto 0); --bit 1 is flush and bit 0 is stall
      o_IDRegOut    : out std_logic_vector(1 downto 0);
      o_EXRegOut    : out std_logic_vector(1 downto 0);
      o_MemRegOut   : out std_logic_vector(1 downto 0));
end HazardDetectionUnit;


architecture structural of HazardDetectionUnit is
signal s_equal1, s_equal2 : std_logic;
signal s_IFRegOutComb : std_logic_vector(1 downto 0);
signal s_PCStall : std_logic;

begin


--detecting stalls
s_equal1 <= '1' when i_IDRegRT = i_IFRegRS else '0';
s_equal2 <= '1' when i_IDRegRT = i_IFRegRT else '0';
s_IFRegOutComb(0) <= i_IDMemRead and (s_equal1 or s_equal2);
--o_IDRegOut(1) <= i_IDMemRead and (s_equal1 or s_equal2);
s_PCStall <= i_IDMemRead and (s_equal1 or s_equal2);

--flushing
s_IFRegOutComb(1) <= i_BranchJump;
o_IFRegOut <= "10" when s_IFRegOutComb = "11" else s_IFRegOutComb; 
o_PCStall <= '0' when s_IFRegOutComb = "11" else s_PCStall;
--o_IDRegOut(1) <= i_BranchJump;
o_EXRegOut(1) <= i_BranchJump;

-- Stall/flush
o_IDRegOut(1) <= (i_IDMemRead and (s_equal1 or s_equal2)) or i_BranchJump;

-- Set MemRegOut so it has a value
o_MemRegOut <= "00";

end structural;