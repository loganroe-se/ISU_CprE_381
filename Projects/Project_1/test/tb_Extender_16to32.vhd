-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_Extender_16to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- 16:32 extender.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_Extender_16to32 is
  generic(gCLK_HPER   : time := 50 ns);
end tb_Extender_16to32;

architecture behavior of tb_Extender_16to32 is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component Extender_16to32
    port(i_ZeroSignSel       : in std_logic;
        i_Data              : in std_logic_vector(15 downto 0);
        o_Out               : out std_logic_vector(31 downto 0));
  end component;

  signal s_CLK, s_ZeroSignSel   : std_logic := '0';
  signal s_Data                 : std_logic_vector(15 downto 0) := x"0000";
  signal s_Out                  : std_logic_vector(31 downto 0) := x"00000000";

begin

  DUT: Extender_16to32 
  port map(i_ZeroSignSel     => s_ZeroSignSel,
           i_Data            => s_Data,
           o_Out             => s_Out);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- Test zero extension
    s_ZeroSignSel <= '0';
    s_Data        <= x"6107";
    wait for gCLK_HPER;
    -- Expect: 0x00006107

    -- Test zero extension
    s_Data        <= x"FFFF";
    wait for gCLK_HPER;
    -- Expect: 0x0000FFFF

    -- Test sign extension
    s_ZeroSignSel <= '1';
    s_Data        <= x"6107";
    wait for gCLK_HPER;
    -- Expect: 0x00006107

    -- Test sign extension
    s_Data        <= x"FFFF";
    wait for gCLK_HPER;
    -- Expect: 0xFFFFFFFF

    wait;
  end process;
  
end behavior;
