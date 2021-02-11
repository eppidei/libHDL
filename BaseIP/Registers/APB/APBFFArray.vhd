library IEEE;

use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba2.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

entity eAPBFFArray is
generic (
    gRegSpaceDepth        : integer;
    gRegWidth             : integer;
    gRegMemAlignment      : integer
);
port (
    --APB
    iGlobalAPB  : in  rGlobalAPB;
    iAPB        : in  rAPBMoSi( PWDATA(gRegWidth-1 downto 0),
                               PSTRB(gRegWidth/8-1 downto 0) ,
                               PADDR((gRegWidth)-1 downto 0));
    oAPB        : out rAPBMiSo( PRDATA(gRegWidth-1 downto 0));
    -- Register Local IF
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0));
    oFFArrayOut : out arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0))  
);
end eAPBFFArray;

architecture aMixed of eAPBFFArray is
--APB local signals
type tAPBSTATE is (SETUP_ST,ACCESS_ST);
signal stAPB : tAPBSTATE;

signal sWriteEnaApb      : std_logic; -- write enable condition
signal sPeripheralSelEna : std_logic;

--Connecting signals
signal sGlobalFabFF : rGlobalFab;
signal sarFFArrayIn  : arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0)); 
signal saFFOut       : aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);
-- memory indexing
signal siIdx        : integer range 0 to gRegSpaceDepth-1:= 0;--initialized for preventing simulator time 0 errors

constant cMAXBIT_ADDRESSABLE32 : integer := fNextPow2(gRegSpaceDepth-1);

signal sClkEn_AlwaysEnable : std_logic := cHIGH;
signal sSrstInactive        : std_logic := cLOW;

begin
assert siIdx<gRegSpaceDepth report "Address " & to_hstring(iAPB.PADDR) & " is out of range" severity error;

gem_MemAlignment : if (gRegMemAlignment=32) generate

siIdx <= to_integer(unsigned(iAPB.PADDR(cMAXBIT_ADDRESSABLE32+2-1 downto 2)));
assert (cMAXBIT_ADDRESSABLE32+2-1<iAPB.PADDR'length) report "Register space to high for being addresses" severity error;

else generate

assert gRegMemAlignment=32 report "Register are not aligned on 32bit" severity ERROR;

end generate gem_MemAlignment;

lab_OutAPB  : oAPB.PRDATA       <= saFFOut(siIdx);
lab_PLSVERR : oAPB.PSLVERR      <='0';
lab_PERENA  : sPeripheralSelEna <= iAPB.PENABLE and iAPB.PSELx;
lab_WENA    : sWriteEnaApb      <= sPeripheralSelEna and iAPB.PWRITE;

gen_muxin : for MuxIdx in 0 to gRegSpaceDepth-1 generate

sarFFArrayIn(MuxIdx).Data     <= iAPB.PWDATA when (MuxIdx=siIdx and sWriteEnaApb='1')  else iFFArrayIn(MuxIdx).Data;
sarFFArrayIn(MuxIdx).WriteEna <= sWriteEnaApb when MuxIdx=siIdx  else iFFArrayIn(MuxIdx).WriteEna; 

end generate gen_muxin;

gen_muxout : for MuxIdx in 0 to gRegSpaceDepth-1 generate

oFFArrayOut(MuxIdx).Data     <= saFFOut(MuxIdx);
oFFArrayOut(MuxIdx).WriteEna <= sWriteEnaApb when MuxIdx=siIdx else '0'; --just redirect APB access in case needs to be handled

end generate gen_muxout;

proc_GlobFabMemR : procConnectGlobalFab (sGlobalFabFF,
                                         iGlobalAPB.PCLK,
                                         sClkEn_AlwaysEnable,
                                         sSrstInactive,
                                         iGlobalAPB.PRESETN);


Inst_FFRegisters : entity work.eFFRegisters
generic map(
    gRegSpaceDepth        => gRegSpaceDepth,
    gRegWidth             => gRegWidth
    )
port map(
    iGlobalFab   => sGlobalFabFF,
    iFFArrayIn   => sarFFArrayIn,
    oFFArrayOut  => saFFOut
);

pSM : process(iGlobalAPB.PCLK)
      begin
      if rising_edge(iGlobalAPB.PCLK) then
          if iGlobalAPB.PRESETn=cHIGHN then
            stAPB       <= SETUP_ST;
            oAPB.PREADY <= '1';
          else
            case stAPB is
                when SETUP_ST  =>   oAPB.PREADY <= '1';
                                    stAPB       <= SETUP_ST;
                                    if iAPB.PSELx='1' then
                                        oAPB.PREADY <= '1';
                                        stAPB       <= ACCESS_ST;
                                    end if;
                when ACCESS_ST => if iAPB.PENABLE='1' then
                                        oAPB.PREADY <= '0'; 
                                        stAPB       <= SETUP_ST;
                                    end if;
            end case;
          end if;
      end if;
end process pSM;


end aMixed;