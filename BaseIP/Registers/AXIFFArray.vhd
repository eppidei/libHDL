library IEEE;

use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba2.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

entity eAXIFFArray is
generic (
    gRegSpaceDepth    : natural;
    gRegWidth         : natural;
    gRegMemAlignment  : natural;
	gAXI_ADDRWidth 	  : natural;
	gAXI_DATAWidth 	  : natural
);
port (
    --APB
    iGlobalAXI  : in  rGlobalAxi4;
    iS_AXI      : in  rAxi4LiteMoSi( WAddrCh ( AWADDR(gAXI_ADDRWidth-1 downto 0)),
									 WDataCh ( WDATA(gAXI_DATAWidth-1 downto 0),
											   WSTRB(gAXI_DATAWidth/cBYTELEN-1 downto 0)),
									 RAddrCh ( ARADDR(gAXI_ADDRWidth-1 downto 0)) );  
    oS_AXI      : out rAxi4LiteMiSo( RDataCh ( RDATA(gAXI_DATAWidth-1 downto 0)) );
    -- Register Local IF
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0));
    oFFArrayOut : out arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0))  
);
end eAXIFFArray;

architecture aMixed of eAPBFFArray is

--Connecting signals
signal sGlobalFabFF  		: rGlobalFab;
signal sarFFArrayIn  		: arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0)); 
signal saFFOut       		: aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);

signal sClkEn_AlwaysEnable  : std_logic := cHIGH;
signal sSrstInactive        : std_logic := cLOW;
--internally generated axi signals
signal sRVALID 				: std_logic;
signal sARREADY 			: std_logic;

begin
proc_GlobFabMemR : procConnectGlobalFab (sGlobalFabFF,
                                         iGlobalAXI.PCLK,
                                         sClkEn_AlwaysEnable,
                                         sSrstInactive,
                                         iGlobalAXI.PRESETN);

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

sARREADY <= (not sRVALID) ot ;




end architecture aMixed;