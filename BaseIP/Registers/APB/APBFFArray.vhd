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
    gRegMemAlignment      : integer;
	gAPBWDATAWidth        : integer;
	gAPBRDATAWidth        : integer;
	gAPBADDRWidth         : integer
);
port (
    --APB
    iGlobalAPB  : in  rGlobalAPB;
    iS_APB      : in  rAPBMoSi( PWDATA(gAPBWDATAWidth-1 downto 0),
                                PSTRB(gAPBWDATAWidth/cBYTELEN-1 downto 0),
                                PADDR((gAPBADDRWidth)-1 downto 0));
    oS_APB      : out rAPBMiSo( PRDATA(gAPBRDATAWidth-1 downto 0));
    -- Register Local IF
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0));
    oFFArrayOut : out arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0))  
);
end eAPBFFArray;

architecture aMixed of eAPBFFArray is
constant cMAXBIT_ADDRESSABLE32 : integer := fNextPow2(gRegSpaceDepth-1);
--APB local signals
type tAPBSTATE is (SETUP_ST,ACCESS_ST);
signal stAPB 				: tAPBSTATE;

signal sWriteEnaApb      	: std_logic; -- write enable condition
signal sPeripheralSelEna 	: std_logic;

--Connecting signals
signal sGlobalFabFF  		: rGlobalFab;
signal sarFFArrayIn  		: arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0)); 
signal saFFOut       		: aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);
-- memory indexing
signal siIdx         		: integer range 0 to gRegSpaceDepth-1:= 0;--initialized for preventing simulator time 0 errors

signal sClkEn_AlwaysEnable  : std_logic := cHIGH;
signal sSrstInactive        : std_logic := cLOW;

begin
-------------------------------
------ Input Checks  --------
-------------------------------
assert gRegWidth<=gAPBWDATAWidth report "Address " & to_hstring(iS_APB.PADDR) & " is out of range" severity error;
-------------------------------
------ Out Assignemnt  --------
-------------------------------
lab_OutAPB  : oS_APB.PRDATA       <= saFFOut(siIdx);
lab_PLSVERR : oS_APB.PSLVERR      <='0';
------------------------------
------ Internal Assignemnt  --
-------------------------------
lab_PERENA  	 : sPeripheralSelEna 	<= iS_APB.PENABLE and iS_APB.PSELx;
lab_WENA    	 : sWriteEnaApb      	<= sPeripheralSelEna and iS_APB.PWRITE;
proc_GlobFabMemR : procConnectGlobalFab (sGlobalFabFF,
                                         iGlobalAPB.PCLK,
                                         sClkEn_AlwaysEnable,
                                         sSrstInactive,
                                         iGlobalAPB.PRESETN);
		----------------------------
		------ Mux Select   --------
		----------------------------

gem_MemAlignment : if (gRegMemAlignment=32) generate

siIdx <= to_integer(unsigned(iS_APB.PADDR(cMAXBIT_ADDRESSABLE32+2-1 downto 2)));
assert (cMAXBIT_ADDRESSABLE32+2-1<iS_APB.PADDR'length) report "Register space to high for being addresses" severity error;
assert siIdx<gRegSpaceDepth report "Address " & to_hstring(iS_APB.PADDR) & " is out of range" severity error;
else generate

assert gRegMemAlignment=32 report "Register are not aligned on 32bit" severity ERROR;

end generate gem_MemAlignment;

		----------------------------
		------ In Out Muxes --------
		----------------------------

gen_muxin : for MuxIdx in 0 to gRegSpaceDepth-1 generate

sarFFArrayIn(MuxIdx).Data     <= iS_APB.PWDATA when (MuxIdx=siIdx and sWriteEnaApb='1')  else iFFArrayIn(MuxIdx).Data;
sarFFArrayIn(MuxIdx).WriteEna <= sWriteEnaApb when MuxIdx=siIdx  else iFFArrayIn(MuxIdx).WriteEna; 

end generate gen_muxin;

gen_muxout : for MuxIdx in 0 to gRegSpaceDepth-1 generate

oFFArrayOut(MuxIdx).Data     <= saFFOut(MuxIdx);
oFFArrayOut(MuxIdx).WriteEna <= sWriteEnaApb when MuxIdx=siIdx else '0'; --just redirect APB access in case needs to be handled

end generate gen_muxout;

----------------------------
------ Registers -----------
----------------------------

Inst_FFRegisters : entity work.eFFRegisters
generic map(
    gRegSpaceDepth  => gRegSpaceDepth,
    gRegWidth       => gRegWidth
    )
port map(
    iGlobalFab      => sGlobalFabFF,
    iFFArrayIn      => sarFFArrayIn,
    oFFArrayOut     => saFFOut
);

----------------------------
------ APB Control ---------
----------------------------

pSM : process(iGlobalAPB.PCLK)
      begin
      if rising_edge(iGlobalAPB.PCLK) then
          if iGlobalAPB.PRESETn=cHIGHN then
            stAPB       	<= SETUP_ST;
            oS_APB.PREADY 	<= '1';
          else
            case stAPB is
                when SETUP_ST  => oS_APB.PREADY 	<= '1';
                                  stAPB       		<= SETUP_ST;
                                  if iS_APB.PSELx='1' then
									  oS_APB.PREADY 	<= '1';
									  stAPB       		<= ACCESS_ST;
                                  end if;
                when ACCESS_ST => if iS_APB.PENABLE='1' then
									oS_APB.PREADY 	<= '0'; 
									stAPB       	<= SETUP_ST;
                                  end if;
            end case;
          end if;
      end if;
end process pSM;


end aMixed;