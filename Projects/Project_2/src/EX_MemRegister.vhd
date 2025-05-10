-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- EX_MemRegister.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an N-bit register
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity EX_MemRegister is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_Stall      : in std_logic;
       i_Flush      : in std_logic;
       i_JumpAddr   : in std_logic_vector(N-1 downto 0);
       i_NextAddr   : in std_logic_vector(N-1 downto 0);
       i_BranchAddr : in std_logic_vector(N-1 downto 0);
       i_ControlBus : in std_logic_vector(10 downto 0);
       i_RegFileRS  : in std_logic_vector(N-1 downto 0);
       i_RegFileRT  : in std_logic_vector(N-1 downto 0);
       i_ALUZero    : in std_logic;
       i_ALUResult  : in std_logic_vector(N-1 downto 0);
       i_RegLocRS   : in std_logic_vector(4 downto 0);
       i_RegWrAddr  : in std_logic_vector(4 downto 0);
       i_Ovfl       : in std_logic;
       o_JumpAddr   : out std_logic_vector(N-1 downto 0);
       o_NextAddr   : out std_logic_vector(N-1 downto 0);
       o_BranchAddr : out std_logic_vector(N-1 downto 0);
       o_ControlBus : out std_logic_vector(10 downto 0);
       o_RegFileRS  : out std_logic_vector(N-1 downto 0);
       o_RegFileRT  : out std_logic_vector(N-1 downto 0);
       o_ALUZero    : out std_logic;
       o_ALUResult  : out std_logic_vector(N-1 downto 0);
       o_RegLocRS   : out std_logic_vector(4 downto 0);
       o_RegWrAddr  : out std_logic_vector(4 downto 0);
       o_Ovfl       : out std_logic);
end EX_MemRegister;

architecture structural of EX_MemRegister is
  signal s_JumpAddr, s_NextAddr, s_BranchAddr, s_RegFileRS, s_RegFileRT, s_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_ControlBus : std_logic_vector(10 downto 0);
  signal s_ALUZero, s_Ovfl : std_logic;
  signal s_RegLocRS, s_RegWrAddr : std_logic_vector(4 downto 0);

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
    s_JumpAddr <= i_JumpAddr  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_NextAddr <= i_NextAddr  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_BranchAddr <= i_BranchAddr  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_ControlBus <= i_ControlBus  when '0',
                   "00000000000" when others;
  with i_Flush select
    s_RegFileRS <= i_RegFileRS  when '0',
                  x"00000000" when others;
  with i_Flush select
    s_RegFileRT <= i_RegFileRT  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_ALUZero <= i_ALUZero  when '0',
                   '0' when others;
  with i_Flush select
    s_ALUResult <= i_ALUResult  when '0',
                   x"00000000" when others;
  with i_Flush select
    s_RegLocRS <= i_RegLocRS  when '0',
                   "00000" when others;
  with i_Flush select
    s_RegWrAddr <= i_RegWrAddr  when '0',
                   "00000" when others;
  with i_Flush select
    s_Ovfl <= i_Ovfl  when '0',
                   '0' when others;

  JumpAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_JumpAddr,
              o_Out      => o_JumpAddr);

  NextAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_NextAddr,
              o_Out      => o_NextAddr);

  BranchAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_BranchAddr,
              o_Out      => o_BranchAddr);

  ControlBusReg: register_N 
  generic map(N => 11)
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_ControlBus,
              o_Out      => o_ControlBus);

  RegFileRS: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_RegFileRS,
              o_Out      => o_RegFileRS);

  RegFileRT: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_RegFileRT,
              o_Out      => o_RegFileRT);

  ALUZero: dffg 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_D        => s_ALUZero,
              o_Q        => o_ALUZero);

  ALUResult: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => not i_Stall,
              i_Data     => s_ALUResult,
              o_Out      => o_ALUResult);

  RegLocRS: register_N
    generic map(N => 5)
    port map(i_CLK    => i_CLK,
             i_RST    => i_RST,
             i_WE     => not i_Stall,
             i_Data   => s_RegLocRS,
             o_Out    => o_RegLocRS);

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
