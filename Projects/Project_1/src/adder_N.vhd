-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- adder_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit ripple carry adder
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity adder_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_Ci         : in std_logic;
       i_A          : in std_logic_vector(N-1 downto 0);
       i_B          : in std_logic_vector(N-1 downto 0);
       o_O          : out std_logic_vector(N-1 downto 0);
       o_Co         : out std_logic;
       o_OF         : out std_logic);

end adder_N;

architecture structural of adder_N is
  signal carry : std_logic_vector(N downto 0);

  component adder is
    port(i_Ci         : in std_logic;
        i_A          : in std_logic;
        i_B          : in std_logic;
        o_O          : out std_logic;
        o_Co         : out std_logic);
  end component;

begin
  carry(0) <= i_Ci;
  G_NBit_adder: for i in 0 to N-1 generate
    adderLoop: adder port map(
        i_Ci  => carry(i),
        i_A   => i_A(i),
        i_B   => i_B(i),
        o_O   => o_O(i),
        o_Co  => carry(i+1));
  end generate G_NBit_adder;

  o_Co <= carry(N);  
  o_OF <= carry(N-1) xor carry(N);
end structural;
