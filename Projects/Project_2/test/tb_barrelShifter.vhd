-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- tb_addSub_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the barrelShifter unit.
--              
-- 10/2/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  
library std;
use std.env.all;                
use std.textio.all;             

entity tb_barrelShifter is
  generic(gCLK_HPER : time := 10 ns;
          N : integer := 32;
          A : integer := 5);
end tb_barrelShifter;

architecture mixed of tb_barrelShifter is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- Define barrelShifter component
component barrelShifter is
  port(i_In         : in std_logic_vector(N-1 downto 0);
       i_Shamt      : in std_logic_vector(A-1 downto 0);
       i_ShiftType  : in std_logic;
       i_ShiftDir   : in std_logic;
       o_Out        : out std_logic_vector(N-1 downto 0));
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';
signal s_ShiftType, s_ShiftDir : std_logic := '0';
signal s_Shamt        : std_logic_vector(A-1 downto 0) := "00000";
signal s_In, s_Out    : std_logic_vector(N-1 downto 0) := x"00000000";
begin

  DUT0: barrelShifter
  port map(
            i_In        => s_In,
            i_Shamt     => s_Shamt,
            i_ShiftType => s_ShiftType,
            i_ShiftDir  => s_ShiftDir,
            o_Out       => s_Out);
  
  --This first process is to setup the clock for the test bench
  P_CLK: process
  begin
    CLK <= '1';         -- clock starts at 1
    wait for gCLK_HPER; -- after half a cycle
    CLK <= '0';         -- clock becomes a 0 (negative edge)
    wait for gCLK_HPER; -- after half a cycle, process begins evaluation again
  end process;

  -- This process resets the sequential components of the design.
  -- It is held to be 1 across both the negative and positive edges of the clock
  -- so it works regardless of whether the design uses synchronous (pos or neg edge)
  -- or asynchronous resets.
  P_RST: process
  begin
  	reset <= '0';   
    wait for gCLK_HPER/2;
	reset <= '1';
    wait for gCLK_HPER*2;
	reset <= '0';
	wait;
  end process;  
  
  -- Assign inputs for each test case.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Layout:
    -- Test 1/2: SLL
    -- Test 3/4: SRL
    -- Test 5/6: SRA

    -- Test case 1:
    -- Test shifting left by 2 (multiplying by 4) with an input of 12
    s_In        <= x"0000000C";
    s_Shamt     <= "00010";
    wait for gCLK_HPER*2;
    -- Expect: 48 because the input of 12 with a shift left of 2

    -- Test case 2:
    -- Test shifting left by 1 (multiplying by 2) with an input of 15000
    s_In        <= x"00003A98";
    s_Shamt     <= "00001";
    wait for gCLK_HPER*2;
    -- Expect: 30000 because the input of 15000 with a shift left of 1 


    -- Set shift direction to right
    s_ShiftDir  <= '1';

    -- Test case 3:
    -- Test shifting right by 2 (dividing by 4) with an input of 12
    s_In        <= x"0000000C";
    s_Shamt     <= "00010";
    wait for gCLK_HPER*2;
    -- Expect: 3 because the input of 12 with a shift right of 2

    -- Test case 4:
    -- Test shifting right by 1 (dividing by 2) with an input of 2,147,483,722
    s_In        <= x"8000004A";
    s_Shamt     <= "00001";
    wait for gCLK_HPER*2;
    -- Expect: 1,073,741,861 because the input of 2,147,483,722 with a shift right of 1 logical


    -- Set shift type to arithmetic
    s_ShiftType <= '1';

    -- Test case 5:
    -- Test shifting right by 2 (dividing by 4) with an input of 12
    s_In        <= x"0000000C";
    s_Shamt     <= "00010";
    wait for gCLK_HPER*2;
    -- Expect: 3 because the input of 12 with a shift right of 2

    -- Test case 6:
    -- Test shifting right by 1 (dividing by 2) with an input of 2,147,483,722
    s_In        <= x"8000004A";
    s_Shamt     <= "00001";
    wait for gCLK_HPER*2;
    -- Expect: 3,221,225,509 because the input of 2,147,483,722 with a shift left of 1 arithmetic
  
    -- run 125
  end process;

end mixed;