library IEEE;

use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi4.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

entity eAXIFFArray is
generic (
    gRegSpaceDepth    : natural;
    gRegWidth         : natural;
    gRegMemAlignment  : natural;
    gAXI_ADDRWidth    : natural;
    gAXI_DATAWidth    : natural
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
constant cMAXBIT_ADDRESSABLE32 : integer := fNextPow2(gRegSpaceDepth-1);
--Connecting signals
signal sGlobalFabFF         : rGlobalFab;
signal sarFFArrayIn         : arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0),
                                                                    Strobe(gRegWidth/cBYTELEN-1 downto 0)); 
signal saFFOut              : aFFRegisters(0 to gRegSpaceDepth-1)(gRegWidth-1 downto 0);

signal sClkEn_AlwaysEnable  : std_logic := cHIGH;
signal sSrstInactive        : std_logic := cLOW;
signal sSrstnInactive        : std_logic := cLOWN;
signal sArstInactive        : std_logic := cLOW;
--internally generated axi signals
signal sRVALID              : std_logic;
signal sARREADY             : std_logic;

signal sRdAddress           : std_logic_vector(gAXI_DATAWidth-1 downto 0);
signal sWrAddress           : std_logic_vector(gAXI_DATAWidth-1 downto 0);
signal sWena                : std_logic;

signal siIdxW               : integer range 0 to gRegSpaceDepth-1:= 0;
signal siIdxR               : integer range 0 to gRegSpaceDepth-1:= 0;

begin
proc_GlobFabMemR : procConnectGlobalFab (sGlobalFabFF,
                                         iGlobalAXI.PCLK,
                                         sClkEn_AlwaysEnable,
                                         sSrstInactive,
                                         sSrstnInactive,
                                         sArstInactive,
                                         iGlobalAXI.PRESETN);

iAXILiteHandler : entity work.eAXILiteSlaveHandler
generic map(
    gSlaveReadLatency   => 1,
    gAXI_ADDRWidth 	    => gAXI_ADDRWidth ,
    gAXI_DATAWidth 	    => gAXI_DATAWidth
    -- gAXI_WAddrIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_WDataIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_WRespIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_RAddrIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_RDataIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_WAddrUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_WDataUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_WRespUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_RAddrUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
    -- gAXI_RDataUSERWidht : natural:=1  --opt. fields set by default to 1 if not used
)
port map(
    --APB
    iGlobalAXI  => iGlobalAXI,
    iS_AXI      => iS_AXI,
    oS_AXI      => oS_AXI,
    -- Register Local IF
    oWData      => ,
    oRdData     => ,
    oWrAddress  => sWrAddress,
    oRdAddress  => sRdAddress,
    oWEna       => sWena
);

gem_MemAlignment : if (gRegMemAlignment=32) generate

siIdxW <= to_integer(unsigned(iS_AXI.WAddrCh.AWADDR(cMAXBIT_ADDRESSABLE32+2-1 downto 2)));
assert (cMAXBIT_ADDRESSABLE32+2-1<iS_AXI.WAddrCh.AWADDR'length) report "Register space to high for being addresses" severity error;
assert siIdxW<gRegSpaceDepth report "Address " & to_hstring(iS_AXI.WAddrCh.AWADDR) & " is out of range" severity error;

siIdxR <= to_integer(unsigned(iS_AXI.RAddrCh.ARADDR(cMAXBIT_ADDRESSABLE32+2-1 downto 2)));
assert (cMAXBIT_ADDRESSABLE32+2-1<iS_AXI.RAddrCh.ARADDR'length) report "Register space to high for being addresses" severity error;
assert siIdxR<gRegSpaceDepth report "Address " & to_hstring(iS_AXI.RAddrCh.ARADDR) & " is out of range" severity error;

else generate

assert gRegMemAlignment=32 report "Register are not aligned on 32bit" severity ERROR;

end generate gem_MemAlignment;

----------------------------
------ Registers -----------
----------------------------

Inst_FFRegisters : entity work.eFFRegisters
generic map(
    gRegSpaceDepth  => gRegSpaceDepth,
    gRegWidth       => gRegWidth,
    gIsStrobeEnabled=> TRUE
    )
port map(
    iGlobalFab      => sGlobalFabFF,
    iFFArrayIn      => sarFFArrayIn,
    oFFArrayOut     => saFFOut
);

end architecture aMixed;