-------------------------------------------------------------------------
-- Logan Roe and Nathan Reff
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a MIPS_Processor implementation.

-- 10/11/2023
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.MIPS_types.all;

entity MIPS_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  MIPS_Processor;


architecture structure of MIPS_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- TODO: You may add any additional signals or components your implementation 
  --       requires below this comment
  
  -- PC Register Stalls
  signal s_PCStall : std_logic := '0';

  component PCRegister is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_Stall      : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;

  -- Adder Signals
  signal s_Adder1, s_Adder2 : std_logic_vector(N-1 downto 0);

  component adder_N is
    generic(N : integer := 32);
    port(i_Ci         : in std_logic;
         i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0);
         o_Co         : out std_logic;
         o_OF         : out std_logic);
  end component;
  
  -- With Select Signals
  signal s_WithSel3 : std_logic;
  signal s_WithSel2 : std_logic_vector(N-1 downto 0);

  -- Mux signals
  signal s_Mux1 : std_logic_vector(4 downto 0);
  signal s_Mux2, s_Mux4, s_Mux5, s_Mux6 : std_logic_vector(N-1 downto 0);

  component mux2t1_N is
    generic(N : integer := 32);
    port(i_S          : in std_logic;
         i_D0         : in std_logic_vector(N-1 downto 0);
         i_D1         : in std_logic_vector(N-1 downto 0);
         o_O          : out std_logic_vector(N-1 downto 0));
  end component;

  -- Register File signals
  signal s_OutRS, s_OutRT  : std_logic_vector(N-1 downto 0);

  component regFile is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
         i_RST        : in std_logic;
         i_WE         : in std_logic;
         i_Data       : in std_logic_vector(N-1 downto 0);
         i_RD         : in std_logic_vector(4 downto 0);
         i_Read_RS    : in std_logic_vector(4 downto 0);
         i_Read_RT    : in std_logic_vector(4 downto 0);
         o_OutRS      : out std_logic_vector(N-1 downto 0);
         o_OutRT      : out std_logic_vector(N-1 downto 0));
  end component;

  -- Control Unit Signals
  signal s_RegDst, s_Jump, s_JRSel, s_Branch            : std_logic;
  signal s_MemToReg, s_ALUSrc                           : std_logic;
  signal s_ALUControl                                   : std_logic_vector(3 downto 0);

  component controlLogic is
    port(i_Opcode     : in std_logic_vector(5 downto 0);
         i_Funct      : in std_logic_vector(5 downto 0);
         o_Halt       : out std_logic;
         o_RegDst     : out std_logic;
         o_Jump       : out std_logic;
         o_JRSel      : out std_logic;
         o_Branch     : out std_logic;
         o_MemToReg   : out std_logic;
         o_ALUControl : out std_logic_vector(3 downto 0);
         o_MemWrite   : out std_logic;
         o_ALUSrc     : out std_logic;
         o_RegWrite   : out std_logic);
  end component;

  -- Extender Signals
  signal s_ExtOut : std_logic_vector(N-1 downto 0);

  component Extender_16to32 is
    port(i_ZeroSignSel       : in std_logic;
         i_Data              : in std_logic_vector(15 downto 0);
         o_Out               : out std_logic_vector(31 downto 0));
  end component;

  -- Shifter Signals
  signal s_ShiftLeft1 : std_logic_vector(27 downto 0);
  signal s_ShiftLeft2 : std_logic_vector(N-1 downto 0);

  component barrelShifter is
    generic(N : integer := 32;
            A : integer := 5);
    port(i_In         : in std_logic_vector(N-1 downto 0);
         i_Shamt      : in std_logic_vector(A-1 downto 0);
         i_ShiftType  : in std_logic;
         i_ShiftDir   : in std_logic;
         o_Out        : out std_logic_vector(N-1 downto 0));
  end component;

  -- ALU Signals
  signal s_ALUResult : std_logic_vector(N-1 downto 0);
  signal s_Zero, s_CarryOut, s_TempOvfl : std_logic;

  component ALU is
    generic(N : integer := 32);
    port(i_ALUControl : in std_logic_vector(3 downto 0);
         i_A          : in std_logic_vector(N-1 downto 0);
         i_B          : in std_logic_vector(N-1 downto 0);
         i_Shamt      : in std_logic_vector(4 downto 0);
         o_Result     : out std_logic_vector(N-1 downto 0);
         o_Zero       : out std_logic;
         o_Co         : out std_logic;
         o_Overflow   : out std_logic);
  end component;

  -- IF/ID Register Signals
  signal s_oAdder1, s_oInst : std_logic_vector(N-1 downto 0);

  component IF_IDRegister is
    generic(N : integer := 32);
    port(i_CLK        : in std_logic;
        i_RST        : in std_logic;
        i_Stall      : in std_logic;
        i_Flush      : in std_logic;
        i_NextAddr   : in std_logic_vector(N-1 downto 0);
        i_InstrAddr  : in std_logic_vector(N-1 downto 0);
        o_NextAddr   : out std_logic_vector(N-1 downto 0);
        o_InstrAddr  : out std_logic_vector(N-1 downto 0));
  end component;

  -- ID/EX Register Signals
  signal s_oJumpAddress, s_ooAdder1, s_oShiftLeft2 : std_logic_vector(N-1 downto 0);
  signal s_ControlBus : std_logic_vector(11 downto 0);
  signal s_oOutRS, s_oOutRT, s_oExtOut : std_logic_vector(N-1 downto 0);
  signal s_Shamt : std_logic_vector(4 downto 0);
  signal s_oMux1 : std_logic_vector(4 downto 0);
  signal s_oRegWr : std_logic;
  signal s_RegLocRS, s_RegLocRT : std_logic_vector(4 downto 0);

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
  end component;

  -- Signals for EX/Mem Register
  signal s_ooJumpAddress, s_oooAdder1, s_oAdder2 : std_logic_vector(N-1 downto 0);
  signal s_oControlBus : std_logic_vector(10 downto 0);
  signal s_ooOutRS, s_ooOutRT, s_oALUResult : std_logic_vector(N-1 downto 0);
  signal s_oZero, s_oTempOvfl : std_logic;
  signal s_oRegLocRS, s_oWithSel1 : std_logic_vector(4 downto 0);

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
  end component;

  -- Signals for Mem/WB Register
  signal s_oMemToReg : std_logic;
  signal s_oDMemOut, s_oWithSel2 : std_logic_vector(N-1 downto 0);
  signal s_ooWithSel1 : std_logic_vector(4 downto 0);
  signal s_ooControlBus : std_logic_vector(2 downto 0);

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
        i_Ovfl           : in std_logic;
        o_ControlBus     : out std_logic_vector(2 downto 0);
        o_MemOut         : out std_logic_vector(N-1 downto 0);
        o_JalOut         : out std_logic_vector(N-1 downto 0);
        o_RegWrAddr      : out std_logic_vector(4 downto 0);
        o_Ovfl           : out std_logic);
  end component;

  -- Signals for ForwardUnit
  signal s_ForwardA, s_ForwardB : std_logic_vector(1 downto 0);
  signal s_JRForwardA, s_JRForwardB : std_logic;

  component ForwardUnit is
    generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_IDRegRS    : in std_logic_vector(4 downto 0);
        i_IDRegRT     : in std_logic_vector(4 downto 0);
        i_EXRegRS     : in std_logic_vector(4 downto 0);
        i_EXRegRD     : in std_logic_vector(4 downto 0);
        i_EXRegWrite  : in std_logic;
        i_MemRegRD    : in std_logic_vector(4 downto 0);
        i_MemRegWrite : in std_logic;
        i_IDJRSel     : in std_logic;
        i_EXJRSel     : in std_logic;
        o_ForwardA    : out std_logic_vector(1 downto 0);
        o_ForwardB    : out std_logic_vector(1 downto 0);
        o_JRForwardA  : out std_logic;
        o_JRForwardB  : out std_logic);
  end component;

  -- Signals for HazardDetectionUnit
  signal s_IFRegOut, s_IDRegOut, s_EXRegOut, s_MemRegOut : std_logic_vector(1 downto 0) := "00";

  component HazardDetectionUnit is
    generic(N : integer := 5); -- Generic of type integer for input/output data width. Default value is 32.
    port(i_IDMemRead   : in std_logic;
         i_IDRegRT     : in std_logic_vector(4 downto 0);
         i_IFRegRS     : in std_logic_vector(4 downto 0);
         i_IFRegRT     : in std_logic_vector(4 downto 0);
         i_BranchJump  : in std_logic;
         o_PCStall     : out std_logic;
         o_IFRegOut    : out std_logic_vector(1 downto 0); --bit 1 is flush and bit 0 is stall
         o_IDRegOut    : out std_logic_vector(1 downto 0);
         o_EXRegOut    : out std_logic_vector(1 downto 0);
         o_MemRegOut   : out std_logic_vector(1 downto 0));
  end component;

  -- Extra Signals
  signal s_JumpAddress, s_Addr : std_logic_vector(N-1 downto 0);
  signal s_AndOut, s_oDMemWr, s_TempHalt : std_logic;
  signal s_AddrSel : std_logic := '0';
  signal s_WithSel1 : std_logic_vector(4 downto 0);
  signal s_WithSel5, s_WithSel6 : std_logic_vector(N-1 downto 0);
  signal s_WithSel7 : std_logic_vector(11 downto 0);
  signal s_JRForwardAOutput, s_JRForwardBOutput : std_logic_vector(N-1 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

  -- With Select (Red #4 on schematic)
  with s_AddrSel select
    s_Addr <= s_Mux6   when '1',
              s_Adder1 when others;

  -- PC Register
  PCReg: PCRegister
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_Stall       => s_PCStall,
             i_Data        => s_Addr,
             o_Out         => s_NextInstAddr);

  -- Adder Pc + 4 (Purple #1 on schematic)
  Adder1: adder_N
    port map(i_Ci          => '0',
             i_A           => s_IMemAddr,
             i_B           => x"00000004",
             o_O           => s_Adder1,
             o_Co          => open,
             o_OF          => open);

  -- IF/ID Register
  IF_ID: IF_IDRegister
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_Stall       => s_IFRegOut(0),
             i_Flush       => s_IFRegOut(1),
             i_NextAddr    => s_Adder1,
             i_InstrAddr   => s_Inst,
             o_NextAddr    => s_oAdder1,
             o_InstrAddr   => s_oInst);

  -- Shift left 2 (Green #1 on schematic)
  Shiftleft1: barrelShifter
    generic map(N => 28,
                A => 5)
    port map(i_In          => "00" & s_oInst(25 downto 0),
             i_Shamt       => "00010",
             i_ShiftType   => '0',
             i_ShiftDir    => '0',
             o_Out         =>  s_ShiftLeft1);
    
  -- Concenate to get the jump address
  s_JumpAddress <= s_oAdder1(31 downto 28) & s_ShiftLeft1(27 downto 0);

  -- Control Unit
  controlUnit: controlLogic
    port map(i_Opcode      => s_oInst(31 downto 26),
             i_Funct       => s_oInst(5 downto 0),
             o_Halt        => s_TempHalt,
             o_RegDst      => s_RegDst,
             o_Jump        => s_Jump,
             o_JRSel       => s_JRSel,
             o_Branch      => s_Branch,
             o_MemToReg    => s_MemToReg,
             o_ALUControl  => s_ALUControl,
             o_MemWrite    => s_oDMemWr,
             o_ALUSrc      => s_ALUSrc,
             o_RegWrite    => s_oRegWr);

  -- With Select To Determine Zero/Sign Extension
  with s_ALUSrc & s_ALUControl select
    s_WithSel3 <= '0' when "10000" | "10001" | "10010",
                  '1' when others;

  -- Sign-Extender
  signExt: Extender_16to32
    port map(i_ZeroSignSel => s_WithSel3,
             i_Data        => s_oInst(15 downto 0),
             o_Out         => s_ExtOut);

  -- Shift left 2 (Green #2 on the schematic)
  Shiftleft2: barrelShifter
    generic map(N => 32,
                A => 5)
    port map(i_In          => s_ExtOut,
             i_Shamt       => "00010",
             i_ShiftType   => '0',
             i_ShiftDir    => '0',
             o_Out         =>  s_ShiftLeft2);

  -- Mux (Blue #1 on the schematic)
  Mux1: mux2t1_N
    generic map(N => 5)
    port map(i_S           => s_RegDst,
             i_D0          => s_oInst(20 downto 16),
             i_D1          => s_oInst(15 downto 11),
             o_O           => s_Mux1);

  -- Register File
  registerFile: regFile
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_WE          => s_RegWr,
             i_Data        => s_RegWrData,
             i_RD          => s_RegWrAddr,
             i_Read_RS     => s_oInst(25 downto 21),
             i_Read_RT     => s_oInst(20 downto 16),
             o_OutRS       => s_OutRS,
             o_OutRT       => s_OutRT);

  -- ID/EX Register
  ID_EX: ID_EXRegister
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_Stall       => s_IDRegOut(0),
             i_Flush       => s_IDRegOut(1),
             i_JumpAddr    => s_JumpAddress,
             i_NextAddr    => s_oAdder1,
             i_BranchImm   => s_ShiftLeft2,
             i_ControlBus  => s_oRegWr & s_TempHalt & s_Jump & s_JRSel & s_Branch & s_MemToReg & s_ALUControl & s_oDMemWr & s_ALUSrc,
             i_RegfileRS   => s_OutRS,
             i_RegfileRT   => s_OutRT,
             i_ImmExt      => s_ExtOut,
             i_Shamt       => s_oInst(10 downto 6),
             i_RegAddrSel  => s_Mux1,
             i_RegLocRS    => s_oInst(25 downto 21),
             i_RegLocRT    => s_oInst(20 downto 16),
             o_JumpAddr    => s_oJumpAddress,
             o_NextAddr    => s_ooAdder1,
             o_BranchImm   => s_oShiftLeft2,
             o_ControlBus  => s_ControlBus,
             o_RegfileRS   => s_oOutRS,
             o_RegfileRT   => s_oOutRT,
             o_ImmExt      => s_oExtOut,
             o_Shamt       => s_Shamt,
             o_RegAddrSel  => s_oMux1,
             o_RegLocRS    => s_RegLocRS,
             o_RegLocRT    => s_RegLocRT);

  -- Adder (Purple #2 on the schematic)
  Adder2: adder_N
    port map(i_Ci          => '0',
              i_A          => s_ooAdder1,
              i_B          => s_oShiftLeft2,
              o_O          => s_Adder2,
              o_Co         => open,
              o_OF         => open);

  -- With Select (Red #5 on the schematic)
  with s_ForwardA select
    s_WithSel5 <= s_RegWrData  when "01",
                  s_oALUResult when "10",
                  x"00000000"  when "11",
                  s_oOutRS     when others;

  -- With Select (Red #6 on the schematic)
  with s_ForwardB select
    s_WithSel6 <= s_RegWrData  when "01",
                  s_oALUResult when "10",
                  x"00000000"  when "11",
                  s_oOutRT     when others;
  
  -- Mux - Immediate Select (Blue #2 on the schematic)
  Mux2: mux2t1_N
    port map(i_S           => s_ControlBus(0),
             i_D0          => s_WithSel6,
             i_D1          => s_oExtOut,
             o_O           => s_Mux2);

  -- ALU
  ALU1: ALU
    port map(i_ALUControl  => s_ControlBus(5 downto 2),
             i_A           => s_WithSel5,
             i_B           => s_Mux2,
             i_Shamt       => s_Shamt,
             o_Result      => s_ALUResult,
             o_Zero        => s_Zero,
             o_Co          => s_CarryOut,
             o_Overflow    => s_TempOvfl);

  -- Assign the result to the output
  oALUOut <= s_ALUResult;

  -- With Select (Red #1 on the schematic)
  with s_ControlBus(5 downto 2) select
    s_WithSel1 <= "11111" when "1111",
                   s_oMux1  when others;

  -- When statement to determine forwarding for JR
  s_JRForwardBOutput <= s_RegWrData when s_JRForwardB = '1' else s_oOutRS;

  -- Ex/Mem Register
  Ex_Mem: EX_MemRegister
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_Stall       => s_EXRegOut(0),
             i_Flush       => s_EXRegOut(1),
             i_JumpAddr    => s_oJumpAddress,
             i_NextAddr    => s_ooAdder1,
             i_BranchAddr  => s_Adder2,
             i_ControlBus  => s_ControlBus(11 downto 1),
             i_RegFileRS   => s_JRForwardBOutput,
             i_RegFileRT   => s_WithSel6,
             i_ALUZero     => s_Zero,
             i_ALUResult   => s_ALUResult,
             i_RegLocRS    => s_RegLocRS,
             i_RegWrAddr   => s_WithSel1,
             i_Ovfl        => s_TempOvfl,
             o_JumpAddr    => s_ooJumpAddress,
             o_NextAddr    => s_oooAdder1,
             o_BranchAddr  => s_oAdder2,
             o_ControlBus  => s_oControlBus,
             o_RegFileRS   => s_ooOutRS,
             o_RegFileRT   => s_ooOutRT,
             o_ALUZero     => s_oZero,
             o_ALUResult   => s_oALUResult,
             o_RegLocRS    => s_oRegLocRS,
             o_RegWrAddr   => s_oWithSel1,
             o_Ovfl        => s_oTempOvfl);

  -- And the branch and zero values
  s_AndOut <= s_oControlBus(6) and s_oZero;

  -- Mux (Blue #4 on the schematic)
  Mux4: mux2t1_N
    generic map(N => 32)
    port map(i_S           => s_AndOut,
             i_D0          => s_oooAdder1,
             i_D1          => s_oAdder2,
             o_O           => s_Mux4);
  
  -- Mux (Blue #5 on the schematic)
  Mux5: mux2t1_N
    generic map(N => 32)
    port map(i_S           => s_oControlBus(8),
             i_D0          => s_Mux4,
             i_D1          => s_ooJumpAddress,
             o_O           => s_Mux5);

  -- When statement to determine forwarding for JR
  s_JRForwardAOutput <= s_RegWrData when s_JRForwardA = '1' else s_ooOutRS;

  -- Mux (Blue #6 on the schematic)
  Mux6: mux2t1_N
    generic map(N => 32)
    port map(i_S           => s_oControlBus(7),
             i_D0          => s_Mux5,
             i_D1          => s_JRForwardAOutput,
             o_O           => s_Mux6);

  -- Assign variables for Dmem
  s_DMemWr  <= s_oControlBus(0);
  s_DMemAddr <= s_oALUResult;
  s_DMemData <= s_ooOutRT;

  -- With Select (Red #2 on the schematic)
  with s_oControlBus(4 downto 1) select
    s_WithSel2 <= s_oooAdder1  when "1111",
                  s_oALUResult when others;

  -- Get the address select value
  s_AddrSel <= s_AndOut or s_oControlBus(8) or s_oControlBus(7);

  -- Mem/WB Register
  Mem_WB: Mem_WBRegister
    port map(i_CLK         => iCLK,
             i_RST         => iRST,
             i_Stall       => s_MemRegOut(0),
             i_Flush       => s_MemRegOut(1),
             i_ControlBus  => s_oControlBus(9) & s_oControlBus(10) & s_oControlBus(5),
             i_MemOut      => s_DMemOut,
             i_JalOut      => s_WithSel2,
             i_RegWrAddr   => s_oWithSel1,
             i_Ovfl        => s_oTempOvfl,
             o_ControlBus  => s_ooControlBus,
             o_MemOut      => s_oDMemOut,
             o_JalOut      => s_oWithSel2,
             o_RegWrAddr   => s_ooWithSel1,
             o_Ovfl        => s_Ovfl);

  -- Assign the halt signal
  s_Halt <= s_ooControlBus(2);

  -- Assign the register write
  s_RegWr <= s_ooControlBus(1);

  -- Assign the reigster write address
  s_RegWrAddr <= s_ooWithSel1;

  -- Mux - MemToReg (Blue #3 on the schematic)
  Mux3: mux2t1_N
    port map(i_S           => s_ooControlBus(0),
             i_D0          => s_oWithSel2,
             i_D1          => s_oDMemOut,
             o_O           => s_RegWrData);

  -- Forwarding Unit
  forward: ForwardUnit
    port map(i_IDRegRS     => s_RegLocRS,
             i_IDRegRT     => s_RegLocRT,
             i_EXRegRS     => s_oRegLocRS,
             i_EXRegRD     => s_oWithSel1,
             i_EXRegWrite  => s_oControlBus(10),
             i_MemRegRD    => s_ooWithSel1,
             i_MemRegWrite => s_ooControlBus(1),
             i_IDJRSel     => s_ControlBus(8),
             i_EXJRSel     => s_oControlBus(7),
             o_ForwardA    => s_ForwardA,
             o_ForwardB    => s_ForwardB,
             o_JRForwardA  => s_JRForwardA,
             o_JRForwardB  => s_JRForwardB);

  -- Hazard Detection Unit
  hazard: HazardDetectionUnit
    port map(i_IDMemRead   => s_ControlBus(6), -- MemToReg control
             i_IDRegRT     => s_RegLocRT,
             i_IFRegRS     => s_oInst(25 downto 21),
             i_IFRegRT     => s_oInst(20 downto 16),
             i_BranchJump  => s_AddrSel,
             o_PCStall     => s_PCStall, 
             o_IFRegOut    => s_IFRegOut,
             o_IDRegOut    => s_IDRegOut,
             o_EXRegOut    => s_EXRegOut,
             o_MemRegOut   => s_MemRegOut);

end structure;