-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_decoder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- 5:32 decoder.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_decoder is
  generic(gCLK_HPER   : time := 50 ns);
end tb_decoder;

architecture behavior of tb_decoder is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component decoder
    port(i_WE                : in std_logic;
         i_Data              : in std_logic_vector(4 downto 0);
         o_Out               : out std_logic_vector(31 downto 0));
  end component;

  signal s_CLK, s_WE  : std_logic := '0';
  signal s_Data       : std_logic_vector(4 downto 0) := "00000";
  signal s_Out        : std_logic_vector(31 downto 0) := x"00000000";

begin

  DUT: decoder 
  port map(i_WE     => s_WE,
           i_Data   => s_Data,
           o_Out    => s_Out);

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
    -- Test input 0
    s_WE    <= '1';
    s_Data  <= "00000";
    wait for cCLK_PER;
    -- Expected out: 0x00000001

    -- Test input 1
    s_Data  <= "00001";
    wait for cCLK_PER; 
    -- Expected out: 0x00000002

    -- Test input 7
    s_Data  <= "00111";
    wait for cCLK_PER;  
    -- Expected out: 0x00000080

    -- Test input 8  
    s_Data  <= "01000";
    wait for cCLK_PER;  
    -- Expected out: 0x00000100

    -- Test input 23
    s_Data  <= "10111";
    wait for cCLK_PER;  
    -- Expected out: 0x00800000

    -- Test input 24
    s_Data  <= "11000";
    wait for cCLK_PER;  
    -- Expected out: 0x01000000

    -- Test input 30
    s_Data  <= "11110";
    wait for cCLK_PER;  
    -- Expected out: 0x40000000

    -- Test input 31
    s_Data  <= "11111";
    wait for cCLK_PER;  
    -- Expected out: 0x80000000

    -- Try writing with write enable of 0
    s_WE    <= '0';
    s_Data  <= "10101";
    wait for cCLK_PER;
    -- Expected out: 0x00000000

    wait;
  end process;
  
end behavior;
