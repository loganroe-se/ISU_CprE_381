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

entity Mem_WBRegister is
  generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
  port(i_CLK        : in std_logic;
       i_RST        : in std_logic;
       i_JumpAddr   : in std_logic_vector(N-1 downto 0);
       i_NextAddr   : in std_logic_vector(N-1 downto 0);
       i_BranchAddr : in std_logic_vector(N-1 downto 0);
       i_ControlBus : in std_logic_vector(9 downto 0);
       i_RegFileRS  : in std_logic_vector(N-1 downto 0);
       i_RegFileRT  : in std_logic_vector(N-1 downto 0);
       i_ALUZero    : in std_logic;
       i_ALUResult  : in std_logic_vector(N-1 downto 0);
       o_JumpAddr   : out std_logic_vector(N-1 downto 0);
       o_NextAddr   : out std_logic_vector(N-1 downto 0);
       o_BranchAddr : out std_logic_vector(N-1 downto 0);
       o_ControlBus : out std_logic_vector(9 downto 0);
       o_RegFileRS  : out std_logic_vector(N-1 downto 0);
       o_RegFileRT  : out std_logic_vector(N-1 downto 0);
       o_ALUZero    : out std_logic;
       o_ALUResult  : out std_logic_vector(N-1 downto 0));
end Mem_WBRegister;

architecture structural of Mem_WBRegister is
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
  JumpAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_JumpAddr,
              o_Out      => o_JumpAddr);

  NextAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_NextAddr,
              o_Out      => o_NextAddr);

  BranchAddr: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_BranchAddr,
              o_Out      => o_BranchAddr);

  ControlBusReg: register_N 
  generic map(N => 10)
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_ControlBus,
              o_Out      => o_ControlBus);

  RegFileRS: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_RegFileRS,
              o_Out      => o_RegFileRS);

  RegFileRT: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_RegFileRT,
              o_Out      => o_RegFileRT);

  ALUZero: dffg 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_D        => i_ALUZero,
              o_Q        => o_ALUZero);

  ALUResult: register_N 
    port map (i_CLK      => i_CLK,
              i_RST      => i_RST,
              i_WE       => '1',
              i_Data     => i_ALUResult,
              o_Out      => o_ALUResult);

end structural;
