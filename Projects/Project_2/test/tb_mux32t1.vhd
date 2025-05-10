-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_mux32t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- 32:1 mux.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mux32t1 is
  generic(gCLK_HPER   : time := 50 ns;
          N : integer := 32);
end tb_mux32t1;

architecture behavior of tb_mux32t1 is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component mux32t1
    port(i_Select            : in std_logic_vector(4 downto 0);
        i_D0, i_D1, i_D2, i_D3, i_D4, i_D5, i_D6, i_D7, i_D8, i_D9, i_D10, i_D11, i_D12, i_D13, i_D14, i_D15, i_D16, 
            i_D17, i_D18, i_D19, i_D20, i_D21, i_D22, i_D23, i_D24, i_D25, i_D26, i_D27, i_D28, i_D29, i_D30, i_D31 : in std_logic_vector(N-1 downto 0);
        o_Out               : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_CLK    : std_logic := '0';
  signal s_Select : std_logic_vector(4 downto 0) := "00000";
  signal s_D0, s_D1, s_D2, s_D3, s_D4, s_D5, s_D6, s_D7, s_D8, s_D9, s_D10, s_D11, s_D12, s_D13, s_D14, s_D15, s_D16, 
            s_D17, s_D18, s_D19, s_D20, s_D21, s_D22, s_D23, s_D24, s_D25, s_D26, s_D27, s_D28, s_D29, s_D30, s_D31 : std_logic_vector(N-1 downto 0) := x"00000000";
  signal s_Out    : std_logic_vector(31 downto 0) := x"00000000";

begin

  DUT: mux32t1 
  port map(i_Select   => s_Select,
           i_D0       => s_D0,
           i_D1       => s_D1,
           i_D2       => s_D2,
           i_D3       => s_D3,
           i_D4       => s_D4,
           i_D5       => s_D5,
           i_D6       => s_D6,
           i_D7       => s_D7,
           i_D8       => s_D8,
           i_D9       => s_D9,
           i_D10      => s_D10,
           i_D11      => s_D11,
           i_D12      => s_D12,
           i_D13      => s_D13,
           i_D14      => s_D14,
           i_D15      => s_D15,
           i_D16      => s_D16,
           i_D17      => s_D17,
           i_D18      => s_D18,
           i_D19      => s_D19,
           i_D20      => s_D20,
           i_D21      => s_D21,
           i_D22      => s_D22,
           i_D23      => s_D23,
           i_D24      => s_D24,
           i_D25      => s_D25,
           i_D26      => s_D26,
           i_D27      => s_D27,
           i_D28      => s_D28,
           i_D29      => s_D29,
           i_D30      => s_D30,
           i_D31      => s_D31,
           o_Out      => s_Out);

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
    -- Initalize inputs
    s_D0  <= x"00000000";
    s_D1  <= x"00000001";
    s_D2  <= x"00000002";
    s_D3  <= x"00000003";
    s_D4  <= x"00000004";
    s_D5  <= x"00000005";
    s_D6  <= x"00000006";
    s_D7  <= x"00000007";
    s_D8  <= x"00000008";
    s_D9  <= x"00000009";
    s_D10 <= x"0000000a";
    s_D11 <= x"0000000b";
    s_D12 <= x"0000000c";
    s_D13 <= x"0000000d";
    s_D14 <= x"0000000e";
    s_D15 <= x"0000000f";
    s_D16 <= x"00000010";
    s_D17 <= x"00000011";
    s_D18 <= x"00000012";
    s_D19 <= x"00000013";
    s_D20 <= x"00000014";
    s_D21 <= x"00000015";
    s_D22 <= x"00000016";
    s_D23 <= x"00000017";
    s_D24 <= x"00000018";
    s_D25 <= x"00000019";
    s_D26 <= x"0000001a";
    s_D27 <= x"0000001b";
    s_D28 <= x"0000001c";
    s_D29 <= x"0000001d";
    s_D30 <= x"0000001e";
    s_D31 <= x"0000001f";

    -- Test input 0
    s_Select  <= "00000";
    wait for cCLK_PER;
    -- Expected out: 0x00000000

    -- Test input 1
    s_Select  <= "00001";
    wait for cCLK_PER; 
    -- Expected out: 0x00000001

    -- Test input 7
    s_Select  <= "00111";
    wait for cCLK_PER;  
    -- Expected out: 0x00000007

    -- Test input 8  
    s_Select  <= "01000";
    wait for cCLK_PER;  
    -- Expected out: 0x00000008

    -- Test input 23
    s_Select  <= "10111";
    wait for cCLK_PER;  
    -- Expected out: 0x00000017

    -- Test input 24
    s_Select  <= "11000";
    wait for cCLK_PER;  
    -- Expected out: 0x01000018

    -- Test input 30
    s_Select  <= "11110";
    wait for cCLK_PER;  
    -- Expected out: 0x4000001e

    -- Test input 31
    s_Select  <= "11111";
    wait for cCLK_PER;  
    -- Expected out: 0x8000001f

    wait;
  end process;
  
end behavior;
