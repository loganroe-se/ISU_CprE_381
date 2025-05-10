-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- adder.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of 1-bit full adder.
--
-- 8/23/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
  port(i_Ci         : in std_logic;
       i_A          : in std_logic;
       i_B          : in std_logic;
       o_O          : out std_logic;
       o_Co         : out std_logic);
end adder;

architecture structural of adder is
  signal xor1Out, and1Out, and2Out : std_logic;
  component xorg2 is
    port(i_A         : in std_logic;
        i_B          : in std_logic;
        o_F          : out std_logic);
  end component;

  component andg2 is
    port(i_A         : in std_logic;
        i_B          : in std_logic;
        o_F          : out std_logic);
  end component;

  component org2 is
    port(i_A         : in std_logic;
        i_B          : in std_logic;
        o_F          : out std_logic);
  end component;

begin
    xor_gate1: xorg2
        port map(i_A => i_A,
                 i_B => i_B,
                 o_F => xor1Out);
    xor_gate2: xorg2
        port map(i_A => xor1Out,
                 i_B => i_Ci,
                 o_F => o_O);
    and_gate1: andg2
        port map(i_A => i_A,
                 i_B => i_B,
                 o_F => and1Out);
    and_gate2: andg2
        port map(i_A => xor1Out,
                 i_B => i_Ci,
                 o_F => and2Out);
    or_gate: org2
        port map(i_A => and1Out,
                 i_B => and2Out,
                 o_F => o_Co);
end structural;