-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- Mem_WBRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an MEM/WB register
--              
-- 11/06/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity Mem_WBRegister is
  generic(N : integer := 32);
  port(i_CLK            : in std_logic;
       i_RST            : in std_logic;
       i_Stall          : in std_logic;
       i_Flush          : in std_logic;
       i_ControlBus     : in std_logic_vector(2 downto 0);
       i_MemOut         : in std_logic_vector(N-1 downto 0);
       i_JalOut         : in std_logic_vector(N-1 downto 0);
       i_RegWrAddr      : in std_logic_vector(4 downto 0);
       i_Ovfl           : in std_logic;
       o_ControlBus     : out std_logic_vector(2 downto 0);
       o_MemOut         : out std_logic_vector(N-1 downto 0);
       o_JalOut         : out std_logic_vector(N-1 downto 0);
       o_RegWrAddr      : out std_logic_vector(4 downto 0);
       o_Ovfl           : out std_logic);
end Mem_WBRegister;

architecture structural of Mem_WBRegister is
  signal s_ControlBus : std_logic_vector(2 downto 0);
  signal s_MemOut, s_JalOut : std_logic_vector(N-1 downto 0);
  signal s_RegWrAddr : std_logic_vector(4 downto 0);
  signal s_Ovfl : std_logic;

  component register_N is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;

  component dffg is
    port(i_CLK        : in std_logic;     -- Clock input
        i_RST        : in std_logic;     -- Reset input
        i_WE         : in std_logic;     -- Write enable input
        i_D          : in std_logic;     -- Data value input
        o_Q          : out std_logic);   -- Data value output
  end component;  
  
begin

  -- Select between 0's and actual input
  with i_Flush select
    s_ControlBus <= i_ControlBus when '0',
                    "000" when others;
  with i_Flush select
    s_MemOut <= i_MemOut when '0',
                x"00000000" when others;
  with i_Flush select
    s_JalOut <= i_JalOut when '0',
                x"00000000" when others;
  with i_Flush select
    s_RegWrAddr <= i_RegWrAddr when '0',
                    "00000" when others;
  with i_Flush select
    s_Ovfl <= i_Ovfl  when '0',
                   '0' when others;

  ContorlBus: register_N
    generic map(N => 3)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_ControlBus,
             o_Out    => o_ControlBus);

  MemOut: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_MemOut,
             o_Out    => o_MemOut);

  JalOut: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_JalOut,
             o_Out    => o_JalOut);

  RegWrAddr: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegWrAddr,
             o_Out    => o_RegWrAddr);

  Ovfl: dffg 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_D        => s_Ovfl,
              o_Q        => o_Ovfl);
end structural;
