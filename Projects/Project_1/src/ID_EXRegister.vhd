-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- ID_EXRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an ID/EX register
--              
-- 11/06/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity ID_EXRegister is
  generic(N : integer := 32);
  port(i_CLK            : in std_logic;
       i_RST            : in std_logic;
       i_JumpAddr       : in std_logic_vector(N-1 downto 0);
       i_NextAddr       : in std_logic_vector(N-1 downto 0);
       i_BranchImm      : in std_logic_vector(N-1 downto 0);
       i_ControlBus     : in std_logic_vector(10 downto 0);
       i_RegfileRS      : in std_logic_vector(N-1 downto 0);
       i_RegfileRT      : in std_logic_vector(N-1 downto 0);
       i_ImmExt         : in std_logic_vector(N-1 downto 0);
       i_Shamt          : in std_logic_vector(4 downto 0);
       o_JumpAddr       : out std_logic_vector(N-1 downto 0);
       o_NextAddr       : out std_logic_vector(N-1 downto 0);
       o_BranchImm      : out std_logic_vector(N-1 downto 0);
       o_ControlBus     : out std_logic_vector(10 downto 0);
       o_RegfileRS      : out std_logic_vector(N-1 downto 0);
       o_RegfileRT      : out std_logic_vector(N-1 downto 0);
       o_ImmExt         : out std_logic_vector(N-1 downto 0);
       o_Shamt          : out std_logic_vector(4 downto 0));
end ID_EXRegister;

architecture structural of ID_EXRegister is

  component register_N is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;
  
begin
  JumpAddr: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_JumpAddr,
             o_Out    => o_JumpAddr);

  NextAddr: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_NextAddr,
             o_Out    => o_NextAddr);

  BranchImm: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_BranchImm,
             o_Out    => o_BranchImm);

  ControlBus: register_N
    generic map(N => 11)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_ControlBus,
             o_Out    => o_ControlBus);

  RegfileRS: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_RegfileRS,
             o_Out    => o_RegfileRS);

  RegfileRT: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_RegfileRT,
             o_Out    => o_RegfileRT);

  ImmExt: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_ImmExt,
             o_Out    => o_ImmExt);

  Shamt: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => '1',
             i_Data   => i_Shamt,
             o_Out    => o_Shamt);
end structural;
