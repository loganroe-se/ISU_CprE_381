-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_regFile.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the
-- N-bit register.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_regFile is
  generic(gCLK_HPER   : time := 50 ns;
    N : integer := 32);
end tb_regFile;

architecture behavior of tb_regFile is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;


  component regFile
    port(i_CLK        : in std_logic;
        i_RST        : in std_logic;
        i_WE         : in std_logic;
        i_Data       : in std_logic_vector(N-1 downto 0);
        i_RD         : in std_logic_vector(4 downto 0);
        i_Read_RS    : in std_logic_vector(4 downto 0);
        i_Read_RT    : in std_logic_vector(4 downto 0);
        o_OutRS      : out std_logic_vector(N-1 downto 0);
        o_OutRT      : out std_logic_vector(N-1 downto 0));
  end component;

  signal s_CLK, s_RST, s_WE : std_logic := '0';
  signal s_Data : std_logic_vector(N-1 downto 0) := x"00000000";
  signal s_RD, s_Read_RS, s_Read_RT : std_logic_vector (4 downto 0) := "00000";
  signal s_OutRS, s_OutRT : std_logic_vector(N-1 downto 0) := x"00000000";

begin

  DUT: regFile 
  port map(i_CLK      => s_CLK,
           i_RST      => s_RST,
           i_WE       => s_WE,
           i_Data     => s_Data,
           i_RD       => s_RD,
           i_Read_RS  => s_Read_RS,
           i_Read_RT  => s_Read_RT,
           o_OutRS    => s_OutRS,
           o_OutRT    => s_OutRT);

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
    -- Reset the register file and set write enable to 1
    s_RST     <= '1';
    s_WE      <= '1';
    wait for cCLK_PER;

    -- Store 0x00000001 in reigster 1
    s_RST     <= '0';
    s_Data    <= x"00000001";
    s_RD      <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x00000000 here since no read address is entered and the default is 00000  

    -- Store 0x00000002 in register 2
    s_RST     <= '0';
    s_Data    <= x"00000002";
    s_RD      <= "00010";
    wait for cCLK_PER;  
    -- Both outs should return 0x00000000 here since no read address is entered and the default is 00000 

    -- Read registers 1 and 2
    s_RST     <= '0';
    s_Read_RS <= "00001";
    s_Read_RT <= "00010";
    wait for cCLK_PER;  
    -- OutRS should return 0x00000001 and OutRT should return 0x00000002

    -- Reset the registers
    s_RST     <= '1';
    s_Read_RS <= "00001";
    s_Read_RT <= "00010";
    wait for cCLK_PER;  
    -- Both outs should return 0x00000000 here since a reset was just done

    -- Try to write to register 0 (shouldn't work)
    s_RST     <= '0';
    s_Data    <= x"00000001";
    s_RD      <= "00000";
    s_Read_RS <= "00000";
    s_Read_RT <= "00000";
    wait for cCLK_PER;  
    -- Both outs should return 0x00000000 here since register 0 should always be 0

    -- Check and ensure that register 0 cannot be written to
    s_RST     <= '0';
    s_Read_RS <= "00000";
    s_Read_RT <= "00000";
    wait for cCLK_PER;  
    -- Both outs should return 0x00000000 here since register 0 should always be 0

    -- Store 0x00000001 in reigster 1
    s_RST     <= '0';
    s_Data    <= x"00000001";
    s_RD      <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x00000000 here since no read address is entered and the default is 00000  

    -- Overwite value in reigster 1 with 0x10000000
    s_RST     <= '0';
    s_Data    <= x"10000000";
    s_RD      <= "00001";
    s_Read_RS <= "00001";
    s_Read_RT <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x00000001

    -- Read the value in register 1
    s_RST     <= '0';
    s_Read_RS <= "00001";
    s_Read_RT <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x10000000

    -- Reset the registers
    s_RST     <= '1';
    s_Read_RS <= "00001";
    s_Read_RT <= "00010";
    wait for cCLK_PER;  
    -- Both outs should return 0x00000000 here since a reset was just done

    -- Ensure that, if the write enable is 0, we cannot write
    s_RST     <= '0';
    s_WE      <= '0';
    s_Data    <= x"FFFFFFFF";
    s_RD      <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x00000000 because the registers were reset

    -- Ensure that writing did not occur in the previous step
    s_Read_RS <= "00001";
    s_Read_RT <= "00001";
    wait for cCLK_PER;
    -- Both outs should return 0x00000000 as the write enable is set to 0

    wait;
  end process;
  
end behavior;
