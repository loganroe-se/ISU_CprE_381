-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- IF_IDRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit register
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity IF_IDRegister is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_Stall      : in std_logic;
       i_Flush      : in std_logic;
       i_NextAddr   : in std_logic_vector(N-1 downto 0);
       i_InstrAddr  : in std_logic_vector(N-1 downto 0);
       o_NextAddr   : out std_logic_vector(N-1 downto 0);
       o_InstrAddr  : out std_logic_vector(N-1 downto 0));
end IF_IDRegister;

architecture structural of IF_IDRegister is
  signal s_NextAddr, s_InstrAddr : std_logic_vector(N-1 downto 0);

  component register_N is
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;
  
begin

  -- Select between 0's and actual input
  with i_Flush select
    s_NextAddr <= i_NextAddr  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_InstrAddr <= i_InstrAddr when '0',
                   x"00000000" when others;

  NextAddrReg: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_NextAddr,
              o_Out      => o_NextAddr);

  InstrAddrReg: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_InstrAddr,
              o_Out      => o_InstrAddr);

end structural;
