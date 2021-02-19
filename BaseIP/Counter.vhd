library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Utilities.all;
use work.Constants.all;

entity eCounterFixedValue is
generic (
gCountVal 		: natural ;
gImplementation : string
);
port (
iGlobalFab      : in rGlobalFab;
iValid          : in std_logic;
oCountVal       : out std_logic_vector(fNextPow2(gCountVal)-1 downto 0);
oCountTick      : out std_logic
);
end entity eCounterFixedValue;

architecture aBehavioural of eCounterFixedValue is
signal suCountSR  			: unsigned(gCountVal downto 0);
signal suCount  			: unsigned(oCountVal'range);
begin

genTinyCount : if gImplementation="SR" generate

oCountTick <= suCountSR(suCountSR'left);
oCountVal  <= fOneHot2Binary(std_logic_vector(suCountSR),suCountSR'length);

	pCountSR : process(iGlobalFab.Clk)
	begin
	if iGlobalFab.Srst = cHIGH then
		suCountSR	<= to_unsigned(1,suCountSR'length);
	elsif iGlobalFab.Srstn = cHIGHN then
		suCountSR	<= to_unsigned(1,suCountSR'length);
	elsif rising_edge(iGlobalFab.Clk) then
		if iGlobalFab.ClkEn='1' then
			if iValid='1' then
				for i in suCountSR'left downto 0 loop
					if i==0 then
						suCountSR(i) <= suCountSR(suCountSR'left);
					else
						suCountSR(i) <= suCountSR(i-1);
					end if;
				end loop;			
			end if;		
		end if;
	end if;
	end process pCountSR;

else

oCountTick <= '1' when else ;

	pCountSR : process(iGlobalFab.Clk)
	begin
	if iGlobalFab.Srst = cHIGH then
		suCount	<= to_unsigned(0,suCount'length);
	elsif iGlobalFab.Srstn = cHIGHN then
		suCount	<= to_unsigned(0,suCount'length);
	elsif rising_edge(iGlobalFab.Clk) then
		if iGlobalFab.ClkEn='1' then
			if iValid='1' then
					suCount	<= suCount + to_unsigned(1,suCount'length);
			end if;		
		end if;
	end if;
	end process pCountSR;

end generate genTinyCount;


end architecture aBehavioural;
