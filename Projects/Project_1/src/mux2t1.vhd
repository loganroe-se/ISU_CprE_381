-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux2t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a behavioral 
-- two to one multiplexer operating on given inputs. 
--
-- 8/23/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is

  port(i_S              : in std_logic;
       i_D0             : in std_logic;
       i_D1             : in std_logic;
       o_O              : out std_logic);
end mux2t1;

architecture structural of mux2t1 is
  signal t1, t2, t3 : std_logic;
  component invg is
     port(i_A     : in std_logic;
          o_F     : out std_logic);
  end component;

  component andg2 is
     port(i_A          : in std_logic;
          i_B          : in std_logic;
          o_F          : out std_logic);
  end component;

  component org2 is
     port(i_A          : in std_logic;
          i_B          : in std_logic;
          o_F          : out std_logic);
  end component;

begin
  not_gate: invg
     port map(i_A => i_S,
	      o_F => t1);
  and_gate1: andg2
     port map(i_A => i_D0,
	      i_B => t1,
	      o_F => t2);
  and_gate2: andg2
     port map(i_A => i_D1,
	      i_B => i_S,
	      o_F => t3);
  or_gate: org2
     port map(i_A => t3,
	      i_B => t2,
	      o_F => o_O);
end structural;