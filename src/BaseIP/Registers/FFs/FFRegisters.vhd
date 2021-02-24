library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.FabricBus.all;
use work.Constants.all;

entity eFFRegisters is
generic (
    gRegSpaceDepth        : integer;
    gRegWidth             : integer;
    gIsStrobeEnabled      : boolean
    );
port (
    iGlobalFab  : in  rGlobalFab;
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0),
                                                            Strobe(gRegWidth/cBYTELEN-1 downto 0));
    oFFArrayOut : out aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0)
);
end eFFRegisters;

architecture aBehavioral of eFFRegisters is
--type tStrobe    is array (0 to gRegSpaceDepth-1) of std_logic_vector(gRegWidth/cBYTELEN-1 downto 0);
signal srMemory : aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);
--signal svStrobe : tStrobe;

begin

lab_out : oFFArrayOut <= srMemory;

-- gen_strobe : if gIsStrobeEnabled=TRUE and mod(gRegWidth,cBYTELEN)=0 generate --use strobe only on byte multiples

    -- gen_strobe_connection : for i in 0 to gRegSpaceDepth-1 generate
                                -- svStrobe(i)    <= iFFArrayIn(i).Strobe;
    -- end generate gen_strobe_connection;

-- else generate --set strobe to ones 

     -- gen_strobe_connection : for i in 0 to gRegSpaceDepth-1 generate
                                -- svStrobe(i)    <= (gRegWidth/cBYTELEN-1 downto 0=>cHIGH);
    -- end generate gen_strobe_connection;

-- end generate gen_strobe;


pFFMem : process(iGlobalFab.Clk,iGlobalFab.Arst,iGlobalFab.Arstn)
        begin
        if iGlobalFab.Arst=cHIGH then
            srMemory <= ( others=> (others=>cLOW));
        elsif iGlobalFab.Arstn=cHIGHN then
            srMemory <= ( others=> (others=>cLOW));
        elsif rising_edge(iGlobalFab.Clk) then
            if  iGlobalFab.Srst=cHIGH then
                srMemory <= ( others=> (others=>cLOW));
            elsif iGlobalFab.Srstn=cHIGHN then
                srMemory <= ( others=> (others=>cLOW));
            else
                if iGlobalFab.ClkEn=cHIGH then
                    for Idx in 0 to gRegSpaceDepth-1 loop
                        --we hope being a static condition synthesizer optimize away 
                        -- otherwise we need to explicitely split the two cases.
                        if gIsStrobeEnabled=TRUE and (gRegWidth mod cBYTELEN)=0 then
                            if iFFArrayIn(Idx).WriteEna='1' then
                                for k in 0 to gRegWidth/cBYTELEN-1 loop
                                    if iFFArrayIn(Idx).Strobe(k)=cHIGH then
                                        srMemory(Idx)((k+1)*cBYTELEN-1 downto k*cBYTELEN) <= iFFArrayIn(Idx).Data((k+1)*cBYTELEN-1 downto k*cBYTELEN);
                                    end if;
                                end loop;
                            end if;
                            
                        else
                            if iFFArrayIn(Idx).WriteEna=cHIGH then
                                srMemory(Idx)   <= iFFArrayIn(Idx).Data;
                            end if;
                        end if;
                    end loop;
                end if;
            end if;
        end if;
end process pFFMem;

end aBehavioral;