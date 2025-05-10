-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- tb_stage_register.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a simple VHDL testbench for the stage 
-- registers.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_stage_register is
  generic(gCLK_HPER   : time := 50 ns;
    N : integer := 32);
end tb_stage_register;

architecture behavior of tb_stage_register is
  
  -- Calculate the clock period as twice the half-period
  constant cCLK_PER  : time := gCLK_HPER * 2;

    component IF_IDRegister is
        generic(N : integer := 32); -- Generic of type integer for input/output data width. Default value is 32.
        port(i_CLK        : in std_logic;
            i_RST        : in std_logic;
            i_Stall      : in std_logic;
            i_Flush      : in std_logic;
            i_NextAddr   : in std_logic_vector(N-1 downto 0);
            i_InstrAddr  : in std_logic_vector(N-1 downto 0);
            o_NextAddr   : out std_logic_vector(N-1 downto 0);
            o_InstrAddr  : out std_logic_vector(N-1 downto 0));
    end component;

    component ID_EXRegister is
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
            o_JumpAddr       : out std_logic_vector(N-1 downto 0);
            o_NextAddr       : out std_logic_vector(N-1 downto 0);
            o_BranchImm      : out std_logic_vector(N-1 downto 0);
            o_ControlBus     : out std_logic_vector(11 downto 0);
            o_RegfileRS      : out std_logic_vector(N-1 downto 0);
            o_RegfileRT      : out std_logic_vector(N-1 downto 0);
            o_ImmExt         : out std_logic_vector(N-1 downto 0);
            o_Shamt          : out std_logic_vector(4 downto 0);
            o_RegAddrSel     : out std_logic_vector(4 downto 0));
    end component;

    component EX_MemRegister is
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
            i_RegWrAddr  : in std_logic_vector(4 downto 0);
            o_JumpAddr   : out std_logic_vector(N-1 downto 0);
            o_NextAddr   : out std_logic_vector(N-1 downto 0);
            o_BranchAddr : out std_logic_vector(N-1 downto 0);
            o_ControlBus : out std_logic_vector(10 downto 0);
            o_RegFileRS  : out std_logic_vector(N-1 downto 0);
            o_RegFileRT  : out std_logic_vector(N-1 downto 0);
            o_ALUZero    : out std_logic;
            o_ALUResult  : out std_logic_vector(N-1 downto 0);
            o_RegWrAddr  : out std_logic_vector(4 downto 0));
    end component;

    component Mem_WBRegister is
        generic(N : integer := 32);
        port(i_CLK            : in std_logic;
            i_RST            : in std_logic;
            i_Stall          : in std_logic;
            i_Flush          : in std_logic;
            i_ControlBus     : in std_logic_vector(2 downto 0);
            i_MemOut         : in std_logic_vector(N-1 downto 0);
            i_JalOut         : in std_logic_vector(N-1 downto 0);
            i_RegWrAddr      : in std_logic_vector(4 downto 0);
            o_ControlBus     : out std_logic_vector(2 downto 0);
            o_MemOut         : out std_logic_vector(N-1 downto 0);
            o_JalOut         : out std_logic_vector(N-1 downto 0);
            o_RegWrAddr      : out std_logic_vector(4 downto 0));
    end component;

  signal s_CLK : std_logic;

  -- IF_ID Register Signals
  -- Input
  signal s_IF_RST, s_IF_Stall, s_IF_Flush : std_logic;
  signal s_IF_NextAddr, s_IF_InstrAddr : std_logic_vector(N-1 downto 0);

  -- Output
  signal s_IF_oNextAddr, s_IF_oInstrAddr : std_logic_vector(N-1 downto 0);

  -- ID_EX Register Signals
  -- Input
  signal s_ID_RST, s_ID_Stall, s_ID_Flush : std_logic;
  signal s_ID_JumpAddr, s_ID_NextAddr, s_ID_BranchImm : std_logic_vector(N-1 downto 0);
  signal s_ID_ControlBus : std_logic_vector(11 downto 0);
  signal s_ID_RegfileRS, s_ID_RegfileRT, s_ID_ImmExt : std_logic_vector(N-1 downto 0);
  signal s_ID_Shamt, s_ID_RegAddrSel : std_logic_vector(4 downto 0);

  -- Output
  signal s_ID_oJumpAddr, s_ID_oNextAddr, s_ID_oBranchImm : std_logic_vector(N-1 downto 0);
  signal s_ID_oControlBus : std_logic_vector(11 downto 0);
  signal s_ID_oRegfileRS, s_ID_oRegfileRT, s_ID_oImmExt : std_logic_vector(N-1 downto 0);
  signal s_ID_oShamt, s_ID_oRegAddrSel : std_logic_vector(4 downto 0);

  -- EX_Mem Register Signals
  --inputs
  signal s_EX_RST, s_EX_Stall, s_EX_Flush : std_logic;
  signal s_EX_JumpAddr, s_EX_NextAddr, s_EX_BranchAddr, s_EX_RegFileRS, s_EX_RegFileRT, s_EX_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_EX_ControlBus : std_logic_vector(10 downto 0);
  signal s_EX_ALUZero : std_logic;
  signal s_EX_RegWrAddr : std_logic_vector(4 downto 0);

   --outputs
  signal s_EX_oJumpAddr, s_EX_oNextAddr, s_EX_oBranchAddr, s_EX_oRegFileRS, s_EX_oRegFileRT, s_EX_oALUResult : std_logic_vector(N-1 downto 0);
  signal s_EX_oControlBus : std_logic_vector(10 downto 0);
  signal s_EX_oALUZero : std_logic;
  signal s_EX_oRegWrAddr : std_logic_vector(4 downto 0);
 
   --Mem_WB Register Signals
   --inputs
  signal s_Mem_RST, s_Mem_Stall, s_Mem_Flush : std_logic;
  signal s_Mem_ControlBus : std_logic_vector(2 downto 0);
  signal s_Mem_MemOut, s_Mem_JalOut : std_logic_vector(N-1 downto 0);
  signal s_Mem_RegWrAddr : std_logic_vector(4 downto 0);
 
 --outputs
  signal s_Mem_oControlBus : std_logic_vector(2 downto 0);
  signal s_Mem_oMemOut, s_Mem_oJalOut : std_logic_vector(N-1 downto 0);
  signal s_Mem_oRegWrAddr : std_logic_vector(4 downto 0);

begin

  IF_ID: IF_IDRegister 
  port map(i_CLK        => s_CLK, 
           i_RST        => s_IF_RST,
           i_Stall      => s_IF_Stall,
           i_Flush      => s_IF_Flush,
           i_NextAddr   => s_IF_NextAddr,
           i_InstrAddr  => s_IF_InstrAddr,
           o_NextAddr   => s_IF_oNextAddr,
           o_InstrAddr  => s_IF_oInstrAddr);

  ID_EX: ID_EXRegister 
  port map(i_CLK        => s_CLK, 
           i_RST        => s_ID_RST,
           i_Stall      => s_ID_Stall,
           i_Flush      => s_ID_Flush,
           i_JumpAddr   => s_ID_JumpAddr,
           i_NextAddr   => s_ID_NextAddr,
           i_BranchImm  => s_ID_BranchImm,
           i_ControlBus => s_ID_ControlBus,
           i_RegfileRS  => s_ID_RegfileRS,
           i_RegfileRT  => s_ID_RegfileRT,
           i_ImmExt     => s_ID_ImmExt,
           i_Shamt      => s_ID_Shamt,
           i_RegAddrSel => s_ID_RegAddrSel,
           o_JumpAddr   => s_ID_oJumpAddr,
           o_NextAddr   => s_ID_oNextAddr,
           o_BranchImm  => s_ID_oBranchImm,
           o_ControlBus => s_ID_oControlBus,
           o_RegfileRS  => s_ID_oRegfileRS,
           o_RegfileRT  => s_ID_oRegfileRT,
           o_ImmExt     => s_ID_oImmExt,
           o_Shamt      => s_ID_oShamt,
           o_RegAddrSel => s_ID_oRegAddrSel);

 EX_Mem: EX_MemRegister
  port map(i_CLK          => s_CLK,
           i_RST          => s_EX_RST,
           i_Stall        => s_EX_Stall,
           i_Flush        => s_EX_Flush,
           i_JumpAddr     => s_EX_JumpAddr,
           i_NextAddr     => s_EX_NextAddr,
           i_BranchAddr   => s_EX_BranchAddr,
           i_ControlBus   => s_EX_ControlBus,
           i_RegFileRS    => s_EX_RegFileRS,
           i_RegFileRT    => s_EX_RegFileRT,
           i_ALUZero      => s_EX_ALUZero,
           i_ALUResult    => s_EX_ALUResult,
           i_RegWrAddr    => s_EX_RegWrAddr,
           o_JumpAddr     => s_EX_oJumpAddr,
           o_NextAddr     => s_EX_oNextAddr,
           o_BranchAddr   => s_EX_oBranchAddr,
           o_ControlBus   => s_EX_oControlBus,
           o_RegFileRS    => s_EX_oRegFileRS,
           o_RegFileRT    => s_EX_oRegFileRT,
           o_ALUZero      => s_EX_oALUZero,
           o_ALUResult    => s_EX_oALUResult,
           o_RegWrAddr    => s_EX_oRegWrAddr);

  Mem_WB: Mem_WBRegister
  port map(i_CLK          => s_CLK,
           i_RST          => s_Mem_RST,
           i_Stall        => s_Mem_Stall,
           i_Flush        => s_Mem_Flush,
           i_ControlBus   => s_Mem_ControlBus,
           i_MemOut       => s_Mem_MemOut,
           i_JalOut       => s_Mem_JalOut,
           i_RegWrAddr    => s_Mem_RegWrAddr,
           o_ControlBus   => s_Mem_oControlBus,
           o_MemOut       => s_Mem_oMemOut,
           o_JalOut       => s_Mem_oJalOut,
           o_RegWrAddr    => s_Mem_oRegWrAddr);

  -- This process sets the clock value (low for gCLK_HPER, then high
  -- for gCLK_HPER). Absent a "wait" command, processes restart 
  -- at the beginning once they have reached the final statement.
  P_CLK: process
  begin
    s_CLK <= '0';
    wait for gCLK_HPER;
    s_CLK <= '1';
    wait for gCLK_HPER;
  end process;
  
  -- Testbench process  
  P_TB: process
  begin
    -- ==================== IF_ID Register Testing ====================
    -- Reset the register
    s_IF_Stall <= '0';
    s_IF_Flush <= '0';
    s_IF_RST <= '1';
    wait for gCLK_HPER*2;

    -- Basic register testing
    s_IF_RST        <= '0';
    s_IF_NextAddr   <= x"00001234";
    s_IF_InstrAddr  <= x"00004321";
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test the reset
    s_IF_RST <= '1';
    wait for gCLK_HPER*2;

    -- ==================== ID_EX Register Testing ====================
    -- Reset the register
    s_ID_Stall <= '0';
    s_ID_Flush <= '0';
    s_ID_RST <= '1';
    wait for gCLK_HPER*2;

    -- Basic register testing
    s_ID_RST        <= '0';
    s_ID_JumpAddr   <= x"00001234";
    s_ID_NextAddr   <= x"00001235";
    s_ID_BranchImm  <= x"00010101";
    s_ID_ControlBus <= x"123";
    s_ID_RegfileRS  <= x"12340000";
    s_ID_RegfileRT  <= x"43210000";
    s_ID_ImmExt     <= x"00123400";
    s_ID_Shamt      <= "10101";
    s_ID_RegAddrSel <= "01010";
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test the reset
    s_ID_RST <= '1';
    wait for gCLK_HPER*2;

    -- ==================== Ex_Mem Register Testing ====================
    -- Reset the register
    s_EX_Stall <= '0';
    s_EX_Flush <= '0';
    s_EX_RST <= '1';
    wait for gCLK_HPER*2;

    -- Basic register testing
    s_EX_RST        <= '0';
    s_EX_JumpAddr   <= x"00001234";
    s_EX_NextAddr   <= x"00001235";
    s_EX_BranchAddr <= x"00010101";
    s_EX_ControlBus <= "10101010101";
    s_EX_RegfileRS  <= x"12340000";
    s_EX_RegfileRT  <= x"43210000";
    s_EX_ALUZero    <= '1';
    s_EX_ALUResult  <= x"01010101";
    s_EX_RegWrAddr  <= "01010";
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test the reset
    s_EX_RST <= '1';
    wait for gCLK_HPER*2;

    -- ==================== Ex_Mem Register Testing ====================
    -- Reset the register
    s_Mem_Stall <= '0';
    s_Mem_Flush <= '0';
    s_Mem_RST <= '1';
    wait for gCLK_HPER*2;

    -- Basic register testing
    s_Mem_RST        <= '0';
    s_Mem_ControlBus <= "101";
    s_Mem_MemOut     <= x"12340000";
    s_Mem_JalOut     <= x"43210000";
    s_Mem_RegWrAddr  <= "01010";
    wait for gCLK_HPER*2;
    wait for gCLK_HPER*2;

    -- Test the reset
    s_Mem_RST <= '1';
    wait for gCLK_HPER*2;

    -- ======================================== Final Register Testing ========================================
    -- Set all resets to 0
    s_IF_RST  <= '0';
    s_ID_RST  <= '0';
    s_EX_RST  <= '0';
    s_Mem_RST <= '0';
    wait for gCLK_HPER*2;

    -- Assign values to go from 1st to 3rd and 2nd to 4th
    s_IF_NextAddr   <= x"00001234";
    s_ID_NextAddr   <= s_IF_oNextAddr;
    s_ID_RegAddrSel <= "10101";
    wait for gCLK_HPER*2;
    s_EX_NextAddr   <= s_ID_oNextAddr;
    s_EX_RegWrAddr  <= s_ID_oRegAddrSel;
    wait for gCLK_HPER*2;
    s_Mem_RegWrAddr <= s_EX_oRegWrAddr;
    wait for gCLK_HPER*2;

    -- Test stall
    s_IF_Stall  <= '1';
    s_ID_Stall  <= '0';
    s_EX_Stall  <= '0';
    s_Mem_Stall <= '0';
    wait for gCLK_HPER*10;

    -- Test flush
    s_IF_Stall <= '0';
    s_IF_Flush <= '1';
    s_ID_Stall <= '0';
    s_ID_Flush <= '1';
    s_EX_Stall <= '0';
    s_EX_Flush <= '1';
    s_Mem_Stall <= '0';
    s_Mem_Flush <= '1';
    wait for gCLK_HPER*2;

  end process;
  
end behavior;
