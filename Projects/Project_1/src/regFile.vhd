-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- regFile.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a 32 register file
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity regFile is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_WE         : in std_logic;
       i_Data       : in std_logic_vector(N-1 downto 0);
       i_RD         : in std_logic_vector(4 downto 0);
       i_Read_RS    : in std_logic_vector(4 downto 0);
       i_Read_RT    : in std_logic_vector(4 downto 0);
       o_OutRS      : out std_logic_vector(N-1 downto 0);
       o_OutRT      : out std_logic_vector(N-1 downto 0));

end regFile;

architecture structural of regFile is
  signal decoderOut : std_logic_vector(N-1 downto 0);
  type registerOut is array(0 to 31) of std_logic_vector(N-1 downto 0);
  signal s_regOut :registerOut;
  
  component register_N is
    port(i_CLK       : in std_logic;
        i_RST        : in std_logic;
        i_WE         : in std_logic;
        i_Data       : in std_logic_vector(N-1 downto 0);
        o_Out        : out std_logic_vector(N-1 downto 0));
  end component;

  component decoder is
    port(i_WE                : in std_logic;
        i_Data              : in std_logic_vector(4 downto 0);
        o_Out               : out std_logic_vector(31 downto 0));
  end component;

  component mux32t1 is
    port(i_Select          : in std_logic_vector(4 downto 0);
       i_D0, i_D1, i_D2, i_D3, i_D4, i_D5, i_D6, i_D7, i_D8, i_D9, i_D10, i_D11, i_D12, i_D13, i_D14, i_D15, i_D16, 
            i_D17, i_D18, i_D19, i_D20, i_D21, i_D22, i_D23, i_D24, i_D25, i_D26, i_D27, i_D28, i_D29, i_D30, i_D31 : in std_logic_vector(N-1 downto 0);
       o_Out               : out std_logic_vector(N-1 downto 0));
  end component;
  
begin
  decoder1: decoder
    port map(
        i_WE   => i_WE,
        i_Data => i_RD,
        o_Out  => decoderOut);

    register0: register_N port map(
                i_CLK      => i_CLK,
                i_RST      => '1',
                i_WE       => decoderOut(0),
                i_Data     => i_Data,
                o_Out      => s_regOut(0));

  G_NBit_REG: for i in 1 to N-1 generate
    registerI: register_N port map(
              i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => decoderOut(i),
              i_Data     => i_Data,
              o_Out      => s_regOut(i));
  end generate G_NBit_REG;

  muxRS: mux32t1
    port map(
        i_Select => i_Read_RS,
        i_D0     => s_regOut(0),
        i_D1     => s_regOut(1),
        i_D2     => s_regOut(2),
        i_D3     => s_regOut(3),
        i_D4     => s_regOut(4),
        i_D5     => s_regOut(5),
        i_D6     => s_regOut(6),
        i_D7     => s_regOut(7),
        i_D8     => s_regOut(8),
        i_D9     => s_regOut(9),
        i_D10    => s_regOut(10),
        i_D11    => s_regOut(11),
        i_D12    => s_regOut(12),
        i_D13    => s_regOut(13),
        i_D14    => s_regOut(14),
        i_D15    => s_regOut(15),
        i_D16    => s_regOut(16),
        i_D17    => s_regOut(17),
        i_D18    => s_regOut(18),
        i_D19    => s_regOut(19),
        i_D20    => s_regOut(20),
        i_D21    => s_regOut(21),
        i_D22    => s_regOut(22),
        i_D23    => s_regOut(23),
        i_D24    => s_regOut(24),
        i_D25    => s_regOut(25),
        i_D26    => s_regOut(26),
        i_D27    => s_regOut(27),
        i_D28    => s_regOut(28),
        i_D29    => s_regOut(29),
        i_D30    => s_regOut(30),
        i_D31    => s_regOut(31),
        o_Out    => o_OutRS);

muxRT: mux32t1
    port map(
        i_Select => i_Read_RT,
        i_D0     => s_regOut(0),
        i_D1     => s_regOut(1),
        i_D2     => s_regOut(2),
        i_D3     => s_regOut(3),
        i_D4     => s_regOut(4),
        i_D5     => s_regOut(5),
        i_D6     => s_regOut(6),
        i_D7     => s_regOut(7),
        i_D8     => s_regOut(8),
        i_D9     => s_regOut(9),
        i_D10    => s_regOut(10),
        i_D11    => s_regOut(11),
        i_D12    => s_regOut(12),
        i_D13    => s_regOut(13),
        i_D14    => s_regOut(14),
        i_D15    => s_regOut(15),
        i_D16    => s_regOut(16),
        i_D17    => s_regOut(17),
        i_D18    => s_regOut(18),
        i_D19    => s_regOut(19),
        i_D20    => s_regOut(20),
        i_D21    => s_regOut(21),
        i_D22    => s_regOut(22),
        i_D23    => s_regOut(23),
        i_D24    => s_regOut(24),
        i_D25    => s_regOut(25),
        i_D26    => s_regOut(26),
        i_D27    => s_regOut(27),
        i_D28    => s_regOut(28),
        i_D29    => s_regOut(29),
        i_D30    => s_regOut(30),
        i_D31    => s_regOut(31),
        o_Out    => o_OutRT);

end structural;
