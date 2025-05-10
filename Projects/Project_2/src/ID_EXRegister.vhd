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
       i_Stall          : in std_logic;
       i_Flush          : in std_logic;
       i_JumpAddr       : in std_logic_vector(N-1 downto 0);
       i_NextAddr       : in std_logic_vector(N-1 downto 0);
       i_BranchImm      : in std_logic_vector(N-1 downto 0);
       i_ControlBus     : in std_logic_vector(11 downto 0);
       i_RegfileRS      : in std_logic_vector(N-1 downto 0);
       i_RegfileRT      : in std_logic_vector(N-1 downto 0);
       i_ImmExt         : in std_logic_vector(N-1 downto 0);
       i_Shamt          : in std_logic_vector(4 downto 0);
       i_RegAddrSel     : in std_logic_vector(4 downto 0);
       i_RegLocRS       : in std_logic_vector(4 downto 0);
       i_RegLocRT       : in std_logic_vector(4 downto 0);
       o_JumpAddr       : out std_logic_vector(N-1 downto 0);
       o_NextAddr       : out std_logic_vector(N-1 downto 0);
       o_BranchImm      : out std_logic_vector(N-1 downto 0);
       o_ControlBus     : out std_logic_vector(11 downto 0);
       o_RegfileRS      : out std_logic_vector(N-1 downto 0);
       o_RegfileRT      : out std_logic_vector(N-1 downto 0);
       o_ImmExt         : out std_logic_vector(N-1 downto 0);
       o_Shamt          : out std_logic_vector(4 downto 0);
       o_RegAddrSel     : out std_logic_vector(4 downto 0);
       o_RegLocRS       : out std_logic_vector(4 downto 0);
       o_RegLocRT       : out std_logic_vector(4 downto 0));
end ID_EXRegister;

architecture structural of ID_EXRegister is
  signal s_JumpAddr, s_NextAddr, s_BranchImm, s_RegfileRS, s_RegfileRT, s_ImmExt : std_logic_vector(N-1 downto 0);
  signal s_ControlBus : std_logic_vector(11 downto 0);
  signal s_Shamt, s_RegAddrSel, s_RegLocRS, s_RegLocRT : std_logic_vector(4 downto 0);

  component register_N is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;
  
begin

  -- Select between 0's and actual input
  with i_Flush select
    s_JumpAddr <= i_JumpAddr  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_NextAddr <= i_NextAddr  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_BranchImm <= i_BranchImm  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_ControlBus <= i_ControlBus  when '0',
                   x"000" when others;
  with i_Flush select
    s_RegfileRS <= i_RegfileRS  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_RegfileRT <= i_RegfileRT  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_ImmExt <= i_ImmExt  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_Shamt <= i_Shamt  when '0',
                   "00000" when others;
  with i_Flush select
    s_RegAddrSel <= i_RegAddrSel  when '0',
                   "00000" when others;
  with i_Flush select
    s_RegLocRS <= i_RegLocRS  when '0',
                   "00000" when others;
  with i_Flush select
    s_RegLocRT <= i_RegLocRT  when '0',
                   "00000" when others;

  JumpAddr: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_JumpAddr,
             o_Out    => o_JumpAddr);

  NextAddr: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_NextAddr,
             o_Out    => o_NextAddr);

  BranchImm: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_BranchImm,
             o_Out    => o_BranchImm);

  ControlBus: register_N
    generic map(N => 12)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_ControlBus,
             o_Out    => o_ControlBus);

  RegfileRS: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegfileRS,
             o_Out    => o_RegfileRS);

  RegfileRT: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegfileRT,
             o_Out    => o_RegfileRT);

  ImmExt: register_N
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_ImmExt,
             o_Out    => o_ImmExt);

  Shamt: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_Shamt,
             o_Out    => o_Shamt);

  RegAddrSel: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegAddrSel,
             o_Out    => o_RegAddrSel);

  RegLocRS: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegLocRS,
             o_Out    => o_RegLocRS);

  RegLocRT: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegLocRT,
             o_Out    => o_RegLocRT);
end structural;
