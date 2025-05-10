-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- PCRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a PC register
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity PCRegister is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_Stall      : in std_logic;
       i_Data       : in std_logic_vector(N-1 downto 0);
       o_Out        : out std_logic_vector(N-1 downto 0));

end PCRegister;

architecture structural of PCRegister is
    signal s_Data : std_logic_vector(N-1 downto 0);

  component register_N is
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;
  
begin
    with i_RST select
        s_Data <= x"00400000" when '1',
                  i_Data      when others;

    reg: register_N
        port map(i_CLK  => i_CLK,
                 i_RST  => '0',
                 i_WE   => not i_Stall,
                 i_Data => s_Data,
                 o_Out  => o_Out);
end structural;
