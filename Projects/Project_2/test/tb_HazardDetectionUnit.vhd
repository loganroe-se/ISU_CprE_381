-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_HazardDetectionUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- forwarding unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_HazardDetectionUnit is
  generic(gCLK_HPER   : time := 50 ns;
          N : integer := 5);
end tb_HazardDetectionUnit;

architecture behavior of tb_HazardDetectionUnit is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component HazardDetectionUnit
    generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_IDMemRead  : in std_logic;
        i_IDRegRT     : in std_logic_vector(N-1 downto 0);
        i_IFRegRS     : in std_logic_vector(N-1 downto 0);
        i_IFRegRT     : in std_logic_vector(N-1 downto 0);
        o_PCWrite     : out std_logic;
        o_IFIDWrite   : out std_logic;
        o_MuxSel      : out std_logic;
        o_IFRegOut    : out std_logic_vector(1 downto 0);
        o_IDRegOut    : out std_logic_vector(1 downto 0);
        o_EXRegOut    : out std_logic_vector(1 downto 0);
        o_MemRegOut   : out std_logic_vector(1 downto 0));
  end component;

  signal s_CLK : std_logic := '0';
  signal s_IDRegRT, s_IFRegRS, s_IFRegRT : std_logic_vector(N-1 downto 0) := "00000";
  signal s_IDMemRead : std_logic := '0';
  signal s_PCWrite, s_IFIDWrite, s_MuxSel : std_logic;

begin

  DUT: ForwardUnit 
  port map(i_IDMemRead   => s_IDMemRead,
           i_IDRegRT     => s_IDRegRT,
           i_IFRegRS     => s_IFRegRS,
           i_IFRegRT     => s_IFRegRT,
           o_PCWrite     => s_PCWrite,
           o_IFIDWrite   => s_IFIDWrite,
           o_MuxSel      => s_MuxSel);

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



  end process;
end behavior;
