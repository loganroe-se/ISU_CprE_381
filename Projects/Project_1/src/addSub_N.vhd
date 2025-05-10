-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- addSub_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit ripple carry adder
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity addSub_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_AddSub     : in std_logic;
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0);
       o_Co         : out std_logic;
       o_OF         : out std_logic);

end addSub_N;

architecture structural of addSub_N is
  signal onesCompOut, muxOut : std_logic_vector(N-1 downto 0);
  
  component adder_N is
    generic(N : integer := 32);
    port(i_Ci         : in std_logic;
        i_A          : in std_logic_vector(N-1 downto 0);
        i_B          : in std_logic_vector(N-1 downto 0);
        o_O          : out std_logic_vector(N-1 downto 0);
        o_Co         : out std_logic;
        o_OF         : out std_logic);
  end component;

  component onesComp_N is
    generic(N : integer := 32);
    port(i_D        : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  component mux2t1_N is
    generic(N : integer := 32);
    port(i_S        : in std_logic;
       i_D0         : in std_logic_vector(N-1 downto 0);
       i_D1         : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0));
  end component;

begin
  onesComp: onesComp_N
    port map(i_D  => i_B,
             o_O  => onesCompOut);
  mux2t1: mux2t1_N
    port map(i_S  => i_AddSub,
             i_D0 => i_B,
             i_D1 => onesCompOut,
             o_O  => muxOut);
  adder: adder_N
    port map(i_Ci => i_AddSub,
             i_A  => i_A,
             i_B  => muxOut,
             o_O  => o_O,
             o_Co => o_Co,
             o_OF => o_OF);
end structural;
