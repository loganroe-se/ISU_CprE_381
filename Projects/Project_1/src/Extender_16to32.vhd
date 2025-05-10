-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Extender_16to32.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a Extender_16to32.
--
-- 8/23/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity Extender_16to32 is
  port(i_ZeroSignSel       : in std_logic;
       i_Data              : in std_logic_vector(15 downto 0);
       o_Out               : out std_logic_vector(31 downto 0));
end Extender_16to32;

architecture dataflow of Extender_16to32 is
begin
  process(i_ZeroSignSel, i_Data) is
  begin
    if (i_ZeroSignSel = '0') then o_Out <= std_logic_vector(resize(unsigned(i_Data(15 downto 0)), 32));

    elsif (i_ZeroSignSel = '1') then o_Out <= std_logic_vector(resize(signed(i_Data(15 downto 0)), 32));

    end if;
  end process;
end dataflow;