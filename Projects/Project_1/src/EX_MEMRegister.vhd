-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- EX_MEMRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an EX/MEM register
--              
-- 11/06/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MEMRegister is
  generic(N : integer := 32);
  port(i_CLK            : in std_logic;
       i_RST            : in std_logic;
       i_MemToReg       : in std_logic;
       i_MemOut         : in std_logic_vector(N-1 downto 0);
       i_JalOut         : in std_logic_vector(N-1 downto 0);
       o_MemToReg       : out std_logic;
       o_MemOut         : out std_logic_vector(N-1 downto 0);
       o_JalOut         : out std_logic_vector(N-1 downto 0));
end EX_MEMRegister;

architecture structural of EX_MEMRegister is

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
  MemToReg: dffg
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_D      => i_MemToReg,
             o_Q      => o_MemToReg);

  MemOut: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_MemOut,
             o_Out    => o_MemOut);

  JalOut: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_JalOut,
             o_Out    => o_JalOut);
end structural;
