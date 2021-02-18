library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Utilities.all;
use work.Constants.all;

entity eShiftRegisterFixedLength is
generic (
gShiftDepth 		: integer ;
gDataWidth	 		: integer 
);
port (
iGlobalFab      : in rGlobalFab;
iValid          : in std_logic;
iShift          : in std_logic_vector(gDataWidth-1 downto 0);
oShift 			: out std_logic_vector(gDataWidth-1 downto 0)
);
end entity eShiftRegisterFixedLength;

architecture aBehaviouralFF of eShiftRegisterFixedLength is

signal saShiftRegister : aFFRegisters(0 to gShiftDepth-1)(gDataWidth-1 downto 0);

begin

lab_output : oShift <= saShiftRegister(saShiftRegister'high);

pSR : process(iGlobalFab.Clk)
begin
if iGlobalFab.Srst = cHIGH then
	saShiftRegister	<= (others=> (others=>'0'));
elsif iGlobalFab.Srstn = cHIGHN then
	saShiftRegister	<= (others=> (others=>'0'));
elsif rising_edge(iGlobalFab.Clk) then
	if iGlobalFab.ClkEn='1' then
		if iValid='1' then
			for i in saShiftRegister'high downto saShiftRegister'low loop
				if i==saShiftRegister'low then
					saShiftRegister(i) <= iShift;
				else
					saShiftRegister(i) <= saShiftRegister(i-1);
				end if;
			end loop;			
		end if;		
	end if;
end if;
end process pSR;

end architecture aBehaviouralFF;