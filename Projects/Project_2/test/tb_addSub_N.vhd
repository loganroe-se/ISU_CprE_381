-------------------------------------------------------------------------
-- Logan Roe & Nathan Reff
-------------------------------------------------------------------------
-- tb_addSub_N.vhd
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the addSub_N unit.
--              
-- 08/30/2023
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;  -- For logic types I/O
library std;
use std.env.all;                -- For hierarchical/external signals
use std.textio.all;             -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
entity tb_addSub_N is
  generic(gCLK_HPER : time := 10 ns);   -- Generic for half of the clock cycle period
end tb_addSub_N;

architecture mixed of tb_addSub_N is

-- Define the total clock period time
constant cCLK_PER  : time := gCLK_HPER * 2;

-- We will be instantiating our design under test (DUT), so we need to specify it
-- component interface.
-- TODO: change component declaration as needed.
component addSub_N is
  port(i_AddSub     : in std_logic;
       i_A          : in std_logic_vector(3 downto 0);
       i_B          : in std_logic_vector(3 downto 0);
       o_O          : out std_logic_vector(3 downto 0);
       o_Co         : out std_logic);
end component;

-- Create signals for all of the inputs and outputs of the file that you are testing
-- := '0' or := (others => '0') just make all the signals start at an initial value of zero
signal CLK, reset : std_logic := '0';

-- TODO: change input and output signals as needed.
signal s_AddSub  : std_logic := '0';
signal s_iA      : std_logic_vector(3 downto 0) := x"0";
signal s_iB      : std_logic_vector(3 downto 0) := x"0";
signal s_oO      : std_logic_vector(3 downto 0) := x"0";
signal s_oCo     : std_logic := '0';

begin

  -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
  -- input or output. Note that DUT0 is just the name of the instance that can be seen 
  -- during simulation. What follows DUT0 is the entity name that will be used to find
  -- the appropriate library component during simulation loading.
  DUT0: addSub_N
  port map(
            i_AddSub => s_AddSub,
            i_A      => s_iA,
            i_B      => s_iB,
            o_O      => s_oO,
            o_Co     => s_oCo);
  --You can also do the above port map in one line using the below format: http://www.ics.uci.edu/~jmoorkan/vhdlref/compinst.html

  
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
  -- TODO: add test cases as needed.
  P_TEST_CASES: process
  begin
    wait for gCLK_HPER/2; -- for waveform clarity, I prefer not to change inputs on clk edges

    -- Test case 1:
    s_AddSub  <= '0';
    s_iA      <= x"0";
    s_iB      <= x"0";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 0 and s_oCo should be 0

    -- Test case 2:
    s_AddSub  <= '0';
    s_iA      <= x"4";
    s_iB      <= x"3";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 7 and s_oCo should be 0

    -- Test case 3:
    s_AddSub  <= '0';
    s_iA      <= x"F";
    s_iB      <= x"1";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 0 and s_oCo should be 1

    -- Test case 4:
    s_AddSub  <= '0';
    s_iA      <= x"F";
    s_iB      <= x"F";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be E and s_oCo should be 1

    -- Test case 5:
    s_AddSub  <= '0';
    s_iA      <= x"A";
    s_iB      <= x"B";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 5 and s_oCo should be 1

    -- Test case 6:
    s_AddSub  <= '0';
    s_iA      <= x"A";
    s_iB      <= x"5";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be F and s_oCo should be 0

    wait for gCLK_HPER*8;

    -- Subtraction Testing
    -- Test case 7:
    s_AddSub  <= '1';
    s_iA      <= x"0";
    s_iB      <= x"0";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 0 and s_oCo should be 1

    -- Test case 8:
    s_AddSub  <= '1';
    s_iA      <= x"4";
    s_iB      <= x"3";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 1 and s_oCo should be 1

    -- Test case 9:
    s_AddSub  <= '1';
    s_iA      <= x"F";
    s_iB      <= x"1";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be E and s_oCo should be 1

    -- Test case 10:
    s_AddSub  <= '1';
    s_iA      <= x"F";
    s_iB      <= x"F";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 0 and s_oCo should be 1

    -- Test case 11:
    s_AddSub  <= '1';
    s_iA      <= x"B";
    s_iB      <= x"A";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be 1 and s_oCo should be 1

    -- Test case 12:
    s_AddSub  <= '1';
    s_iA      <= x"F";
    s_iB      <= x"0";
    wait for gCLK_HPER*2;
    -- Expect: s_oO should be F and s_oCo should be 1
  end process;

end mixed;