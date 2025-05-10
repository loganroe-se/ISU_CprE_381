-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_ForwardUnit.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- forwarding unit.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_ForwardUnit is
  generic(gCLK_HPER   : time := 50 ns;
          N : integer := 5);
end tb_ForwardUnit;

architecture behavior of tb_ForwardUnit is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component ForwardUnit
    generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_IDRegRS    : in std_logic_vector(N-1 downto 0);
        i_IDRegRT     : in std_logic_vector(N-1 downto 0);
        i_EXRegRD     : in std_logic_vector(N-1 downto 0);
        i_EXRegWrite  : in std_logic;
        i_MemRegRD    : in std_logic_vector(N-1 downto 0);
        i_MemRegWrite : in std_logic;
        o_ForwardA    : out std_logic_vector(1 downto 0);
        o_ForwardB    : out std_logic_vector(1 downto 0));
  end component;

  signal s_CLK : std_logic := '0';
  signal s_IDRegRS, s_IDRegRT, s_EXRegRD, s_MemRegRD : std_logic_vector(N-1 downto 0) := "00000";
  signal s_EXRegWrite, s_MemRegWrite : std_logic := '0';
  signal s_ForwardA, s_ForwardB : std_logic_vector(1 downto 0);

begin

  DUT: ForwardUnit 
  port map(i_IDRegRS     => s_IDRegRS,
           i_IDRegRT     => s_IDRegRT,
           i_EXRegRD     => s_EXRegRD,
           i_EXRegWrite  => s_EXRegWrite,
           i_MemRegRD    => s_MemRegRD,
           i_MemRegWrite => s_MemRegWrite,
           o_ForwardA    => s_ForwardA,
           o_ForwardB    => s_ForwardB);

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
    -- ========== Test EX/MEM Forwarding ==========
    -- Test ForwardA = 2 <- Should work
    s_EXRegWrite  <= '1';
    s_EXRegRD     <= "10101";
    s_IDRegRS     <= "10101";
    wait for gCLK_HPER*2;

    -- Test ForwardA = 2 <- Shouldn't work
    s_EXRegWrite  <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardA = 2 <- Shouldn't work
    s_EXRegWrite  <= '1';
    s_EXRegRD     <= "01010";
    wait for gCLK_HPER*2;

    -- Clean up left over values
    s_IDRegRS     <= "00000";

    -- Test ForwardB = 2 <- Should work
    s_IDRegRT     <= "01010";
    wait for gCLK_HPER*2;

    -- Test ForwardB = 2 <- Shouldn't work
    s_EXRegWrite  <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardB = 2 <- Shouldn't work
    s_EXRegWrite  <= '1';
    s_EXRegRD     <= "10101";
    wait for gCLK_HPER*2;

    -- Clean up left over values
    s_IDRegRT     <= "00000";

    -- ========== Test MEM/WB Forwarding ==========
    -- Test ForwardA = 1 <- Should work -- MemWrite = 1 && MemRegRd == IDRegRs && EXRegRD != IDRegRs
    s_MemRegWrite <= '1';
    s_MemRegRD    <= "10101";
    s_IDRegRS     <= "10101";
    s_EXRegRD     <= "01010";
    wait for gCLK_HPER*2;

    -- Test ForwardA = 1 <- Should work -- MemWrite = 1 && MemRegRD == IDRegRS && EXRegWrite = 0
    s_EXRegRD     <= "10101";
    s_EXRegWrite  <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardA = 1 <- Shouldn't work -- MemRegWrite = 0
    s_MemRegWrite <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardA = 1 <- Shouldn't work -- MemRegRD != IDRegRs
    s_MemRegWrite <= '1';
    s_MemRegRD    <= "01010";
    wait for gCLK_HPER*2;

    -- Test ForwardB = 1 <- Should work -- MemWrite = 1 && MemRegRd == IDRegRt && EXRegRD != IDRegRt
    s_MemRegWrite <= '1';
    s_MemRegRD    <= "10101";
    s_IDRegRT     <= "10101";
    s_EXRegRD     <= "01010";
    wait for gCLK_HPER*2;

    -- Test ForwardB = 1 <- Should work -- MemWrite = 1 && MemRegRD == IDRegRT && EXRegWrite = 0
    s_EXRegRD     <= "10101";
    s_EXRegWrite  <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardB = 1 <- Shouldn't work -- MemRegWrite = 0
    s_MemRegWrite <= '0';
    wait for gCLK_HPER*2;

    -- Test ForwardB = 1 <- Shouldn't work -- MemRegRD != IDRegRt
    s_MemRegWrite <= '1';
    s_MemRegRD    <= "01010";
    wait for gCLK_HPER*2;

  end process;
end behavior;
