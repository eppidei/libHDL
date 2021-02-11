library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.FabricBus.all;
use work.Constants.all;

entity eFFRegisters is
generic (
    gRegSpaceDepth        : integer;
    gRegWidth             : integer 
    );
port (
    iGlobalFab  : in  rGlobalFab;
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0));
    oFFArrayOut : out aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0)
);
end eFFRegisters;

architecture aBehavioral of eFFRegisters is

signal srMemory : aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);

begin

lab_out : oFFArrayOut <= srMemory;

pFFMem : process(iGlobalFab.Clk)
        begin
        if rising_edge(iGlobalFab.Clk) then
            if  iGlobalFab.Srst=cHIGH then
                srMemory <= ( others=> (others=>'0'));
            elsif iGlobalFab.Srstn=cHIGHN then
                srMemory <= ( others=> (others=>'0'));
            else
                if iGlobalFab.ClkEn=cHIGH then
                    for Idx in 0 to gRegSpaceDepth-1 loop
                        if iFFArrayIn(Idx).WriteEna='1' then
                            srMemory(Idx)   <= iFFArrayIn(Idx).Data;
                        end if;
                    end loop;
                end if;
            end if;
        end if;
end process pFFMem;

end aBehavioral;