-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- mux32t1.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a dataflow 
-- mux32t1.
--
-- 8/23/23
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux32t1 is
  generic(N : integer := 32);
  port(i_Select            : in std_logic_vector(4 downto 0);
       i_D0, i_D1, i_D2, i_D3, i_D4, i_D5, i_D6, i_D7, i_D8, i_D9, i_D10, i_D11, i_D12, i_D13, i_D14, i_D15, i_D16, 
            i_D17, i_D18, i_D19, i_D20, i_D21, i_D22, i_D23, i_D24, i_D25, i_D26, i_D27, i_D28, i_D29, i_D30, i_D31 : in std_logic_vector(N-1 downto 0);
       o_Out               : out std_logic_vector(N-1 downto 0));
end mux32t1;

architecture dataflow of mux32t1 is

begin
    with i_Select select
        o_Out <= i_D0  when "00000",
                 i_D1  when "00001",
                 i_D2  when "00010",
                 i_D3  when "00011",
                 i_D4  when "00100",
                 i_D5  when "00101",
                 i_D6  when "00110",
                 i_D7  when "00111",
                 i_D8  when "01000",
                 i_D9  when "01001",
                 i_D10 when "01010",
                 i_D11 when "01011",
                 i_D12 when "01100",
                 i_D13 when "01101",
                 i_D14 when "01110",
                 i_D15 when "01111",
                 i_D16 when "10000",
                 i_D17 when "10001",
                 i_D18 when "10010",
                 i_D19 when "10011",
                 i_D20 when "10100",
                 i_D21 when "10101",
                 i_D22 when "10110",
                 i_D23 when "10111",
                 i_D24 when "11000",
                 i_D25 when "11001",
                 i_D26 when "11010",
                 i_D27 when "11011",
                 i_D28 when "11100",
                 i_D29 when "11101",
                 i_D30 when "11110",
                 i_D31 when "11111",
                 i_D0  when others;

end dataflow;