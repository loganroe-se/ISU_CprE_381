-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_register_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- N-bit register.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_register_N is
  generic(gCLK_HPER   : time := 50 ns;
    N : integer := 32);
end tb_register_N;

architecture behavior of tb_register_N is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component register_N
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_CLK, s_RST, s_WE : std_logic;
  signal s_Data : std_logic_vector(N-1 downto 0);
  signal s_Out : std_logic_vector(N-1 downto 0) := x"00000000";

begin

  DUT: register_N 
  port map(i_CLK    => s_CLK, 
           i_RST    => s_RST,
           i_WE     => s_WE,
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
    -- Reset the register
    s_RST   <= '1';
    s_WE    <= '0';
    s_Data  <= x"00000000";
    wait for cCLK_PER;

    -- Store 0x12345678
    s_RST   <= '0';
    s_WE    <= '1';
    s_Data  <= x"12345678";
    wait for cCLK_PER;  

    -- Keep 0x12345678
    s_RST   <= '0';
    s_WE    <= '0';
    s_Data  <= x"00000000";
    wait for cCLK_PER;  

    -- Store 0xFFFFFFFF  
    s_RST   <= '0';
    s_WE    <= '1';
    s_Data  <= x"FFFFFFFF";
    wait for cCLK_PER;  

    -- Keep 0xFFFFFFFF
    s_RST   <= '0';
    s_WE    <= '0';
    s_Data  <= x"00000000";
    wait for cCLK_PER;  

    -- Reset the register
    s_RST   <= '1';
    s_WE    <= '0';
    s_Data  <= x"12345678";
    wait for cCLK_PER;  

    wait;
  end process;
  
end behavior;
