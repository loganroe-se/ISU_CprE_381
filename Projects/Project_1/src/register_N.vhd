-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- register_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit register
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity register_N is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_WE         : in std_logic;
       i_Data       : in std_logic_vector(N-1 downto 0);
       o_Out        : out std_logic_vector(N-1 downto 0));

end register_N;

architecture structural of register_N is
  
  component dffg is
    port(i_CLK        : in std_logic;     -- Clock input
         i_RST        : in std_logic;     -- Reset input
         i_WE         : in std_logic;     -- Write enable input
         i_D          : in std_logic;     -- Data value input
         o_Q          : out std_logic);   -- Data value output
  end component;
  
begin
  G_NBit_REG: for i in 0 to N-1 generate
    regI: dffg port map(
              i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => i_WE,
              i_D        => i_Data(i),
              o_Q        => o_Out(i));
  end generate G_NBit_REG;
end structural;
