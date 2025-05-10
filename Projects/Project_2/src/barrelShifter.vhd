library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrelShifter is
  generic(N : integer := 32;
          A : integer := 5);
  port(i_In         : in std_logic_vector(N-1 downto 0);
       i_Shamt      : in std_logic_vector(A-1 downto 0);
       i_ShiftType  : in std_logic;
       i_ShiftDir   : in std_logic;
       o_Out        : out std_logic_vector(N-1 downto 0));

end barrelShifter;

architecture structural of barrelShifter is
begin
    process(i_ShiftType, i_ShiftDir, i_In, i_Shamt)
        variable s_ShamtInt : integer;
    begin
        -- Convert i_Shamt to integer
        s_ShamtInt := to_integer(unsigned(i_Shamt));

        -- If shift amount is zero, skip all other operations
        if(s_ShamtInt = 0) then
            o_Out <= i_In;
        else
            if(i_ShiftDir <= '0') then
                o_Out(N-1 downto s_ShamtInt) <= i_In(N-(1 + s_ShamtInt) downto 0);
                o_Out((s_ShamtInt - 1) downto 0) <= (others => '0');
            else
                if(i_ShiftType <= '0') then
                    o_Out(N-1-s_ShamtInt downto 0) <= i_In(N-1 downto s_ShamtInt);
                    o_Out(N-1 downto N-s_ShamtInt) <= (others => '0');
                else
                    o_Out(N-1-s_ShamtInt downto 0) <= i_In(N-1 downto s_ShamtInt);
                    o_Out(N-1 downto N-s_ShamtInt) <= (others => i_In(N-1));
                end if;
            end if;
        end if;
    end process;
end structural;
