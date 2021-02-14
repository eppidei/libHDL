library IEEE;

use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba2.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

-- type rAxi4LiteMoSi is record
-- WAddrCh : rAxi4LiteWAddrMoSi;
-- WDataCh : rAxi4LiteWDataMoSi;
-- WRespCh	: rAxi4LiteWRespMoSi;
-- RAddrCh : rAxi4LiteRAddrMoSi;
-- RDataCh : rAxi4LiteRDataMoSi;
-- end record;

entity eAXIFFArray is
generic (
    gRegSpaceDepth        : integer;
    gRegWidth             : integer;
    gRegMemAlignment      : integer;
	gAXI_AWIDWidth 		  : integer
);
port (
    --APB
    iGlobalAXI  : in  rGlobalAxi4;
    iS_AXI      : in  rAxi4LiteMoSi( rAxi4LiteWAddrMoSi ( AWADDR(gRegWidth-1 downto 0),
														  AWPROT(gRegWidth/8-1 downto 0),
														  AWVALID(gRegWidth-1 downto 0),
																						) ),
															
															
																						);
    oS_AXI        : out rAxi4LiteMiSo( PRDATA(gRegWidth-1 downto 0));
    -- Register Local IF
    iFFArrayIn  : in  arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0));
    oFFArrayOut : out arFFDataStream(0 to gRegSpaceDepth-1)(Data(gRegWidth-1 downto 0))  
);
end eAXIFFArray;