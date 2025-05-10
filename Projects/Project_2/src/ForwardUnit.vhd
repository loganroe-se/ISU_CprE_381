-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- ForwardUnit.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit register
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ForwardUnit is
  generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_IDRegRS     : in std_logic_vector(N-1 downto 0);
       i_IDRegRT     : in std_logic_vector(N-1 downto 0);
       i_EXRegRS     : in std_logic_vector(N-1 downto 0);
       i_EXRegRD     : in std_logic_vector(N-1 downto 0);
       i_EXRegWrite  : in std_logic;
       i_MemRegRD    : in std_logic_vector(N-1 downto 0);
       i_MemRegWrite : in std_logic;
       i_IDJRSel     : in std_logic;
       i_EXJRSel     : in std_logic;
       o_ForwardA    : out std_logic_vector(1 downto 0);
       o_ForwardB    : out std_logic_vector(1 downto 0);
       o_JRForwardA  : out std_logic;
       o_JRForwardB  : out std_logic);
end ForwardUnit;

architecture structural of ForwardUnit is
  signal s_xorOutRS, s_xorOutRT :std_logic_vector(N-1 downto 0);
  signal s_MemIDXorOutRS, s_EXIDXorOutRS :std_logic_vector(N-1 downto 0);
  signal s_notequalRS, s_orRS : std_logic;
  signal s_MemIDXorOutRT, s_EXIDXorOutRT :std_logic_vector(N-1 downto 0);
  signal s_notequalRT, s_orRT : std_logic;
  signal s_ForwardA, s_ForwardA2, s_ForwardB, s_ForwardB2 : std_logic_vector(1 downto 0);
  signal s_JRequal1, s_JRequal2 : std_logic;
  signal s_ZeroCheck1, s_ZeroCheck2 : std_logic;
  signal s_ForwardAOut, s_ForwardBOut : std_logic_vector(1 downto 0);

begin

s_xorOutRS <= i_EXRegRD xor i_IDRegRS;
s_xorOutRT <= i_EXRegRD xor i_IDRegRT;

with i_EXRegWrite & s_xorOutRS select 
    s_ForwardA <= "10" when "100000",
                  "00" when others;

with i_EXRegWrite & s_xorOutRT select 
    s_ForwardB <= "10" when "100000",
                  "00" when others;

--RS conditional

s_MemIDXorOutRS <= i_MemRegRD xor i_IDRegRS;
s_EXIDXorOutRS <= i_EXRegRD xor i_IDRegRS;

with s_EXIDXorOutRS select 
    s_notequalRS <= '0' when "00000",
                    '1' when others;

s_orRS <= s_notequalRS or not i_EXRegWrite;

with i_MemRegWrite & s_MemIDXorOutRS & s_orRS select 
    s_ForwardA2 <= "01" when "1000001",
                   "00" when others;

-- RT conditional

s_MemIDXorOutRT <= i_MemRegRD xor i_IDRegRT;
s_EXIDXorOutRT <= i_EXRegRD xor i_IDRegRT;

with s_EXIDXorOutRT select 
    s_notequalRT <= '0' when "00000",
                    '1' when others;

s_orRT <= s_notequalRT or not i_EXRegWrite;

with i_MemRegWrite & s_MemIDXorOutRT & s_orRT select 
    s_ForwardB2 <= "01" when "1000001",
                   "00" when others;

-- Check if the registers are the zeroth register
s_ZeroCheck1 <= '1' when i_IDRegRS = "00000" else '0';
s_ZeroCheck2 <= '1' when i_IDRegRT = "00000" else '0'; 

-- Determine which value to output
with s_ForwardA select
    s_ForwardAOut <= s_ForwardA  when "10",
                     s_ForwardA2 when others;
with s_ForwardB select
    s_ForwardBOut <= s_ForwardB  when "10",
                     s_ForwardB2 when others;

o_ForwardA <= "11" when s_ZeroCheck1 = '1' else s_ForwardAOut;
o_ForwardB <= "11" when s_ZeroCheck2 = '1' else s_ForwardBOut;

-- Jump register forwarding
s_JRequal1 <= '1' when i_EXRegRS = i_MemRegRD else '0';
o_JRForwardA <= '1' when i_EXJRSel and i_MemRegWrite and s_JRequal1 else '0';

s_JRequal2 <= '1' when i_IDRegRS = i_MemRegRD else '0';
o_JRForwardB <= '1' when i_IDJRSel and i_MemRegWrite and s_JRequal2 else '0';

end structural;
