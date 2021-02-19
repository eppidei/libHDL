use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba2.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

entity eAXILiteSlaveHandler is
generic (
	gSlaveReadLatency   : natural;
	gAXI_ADDRWidth 	    : natural;
	gAXI_DATAWidth 	    : natural;
	gAXI_WAddrIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_WDataIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_WRespIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_RAddrIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_RDataIDWidht   : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_WAddrUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_WDataUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_WRespUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_RAddrUSERWidht : natural:=1; --opt. fields set by default to 1 if not used
	gAXI_RDataUSERWidht : natural:=1  --opt. fields set by default to 1 if not used
);
port (
    --APB
    iGlobalAXI  : in  rGlobalAxi4;
    iS_AXI      : in  rAxi4LiteMoSi( WAddrCh ( AWADDR(gAXI_ADDRWidth-1 downto 0),
											   AWOPTIONAL ( AWID(gAXI_WAddrIDWidht-1 downto 0),
														    AWUSER(gAXI_WAddrUSERWidht-1 downto 0))
											 ),
									 WDataCh ( WDATA(gAXI_DATAWidth-1 downto 0),
											   WSTRB(gAXI_DATAWidth/cBYTELEN-1 downto 0),
											   WOPTIONAL ( WID(gAXI_WDataIDWidht-1 downto 0),
														   WUSER(gAXI_WDataUSERWidht-1 downto 0))
											 ),
									 RAddrCh ( ARADDR(gAXI_ADDRWidth-1 downto 0),
											   AROPTIONAL ( AWID(gAXI_WAddrIDWidht-1 downto 0),
														    AWUSER(gAXI_WAddrUSERWidht-1 downto 0))
											 )
									 );  
    oS_AXI      : out rAxi4LiteMiSo( RDataCh ( RDATA(gAXI_DATAWidth-1 downto 0)),
									 WRespCh ( BOPTIONAL ( BID(gAXI_WRespIDWidht-1 downto 0) ,
														   BUSER(gAXI_WRespUSERWidht-1 downto 0))
											 )
									);
    -- Register Local IF
    oWrAddress    : out std_logic_vector(gAXI_ADDRWidth-1 downto 0);
    oRdAddress    : out std_logic_vector(gAXI_ADDRWidth-1 downto 0);
	oWEna         : out std_logic
);
end eAXILiteSlaveHandler;

--throughput limited version address and data phases tighted together
architecture aArea of eAXILiteSlaveHandler is

signal svAddress 	: std_logic_vector(oAddress'range);
--Counter signals
signal sGlobalFab   : rGlobalFab;
signal sCountValid	: std_logic;
signal sRstCount    : std_logic;
signal sCountTick	: std_logic;
signal sCountValid	: std_logic;

begin

procConnectGlobalFab ( sGlobalFab,
					 iGlobalAXI.ACLK, 
					 signal iClockEna   : in std_logic; 
					 signal iSreset     : in std_logic;
					 signal iSresetn    : in std_logic);

iLatencyCount : work.eCounterFixedValue
generic map(
gCountVal 		=> gSlaveReadLatency-1, -- m1 because 1tick delay is in the state transition
gImplementation => "SR"
);
port map(
iGlobalFab      => sGlobalFab,
iValid          => sCountValid,
oCountVal       => open,
oCountTick      => sCountTick 
);

oS_AXI.RDataCh.RVALID <= cHIGH when RdState=RD_ACCESS_ST and iS_AXI.RdDataCh.RREADY = cHIGH
						 else cLOW;
oS_AXI.RDataCh.RRESP  <= cAXIRESP_OKAY;

pREAD : process(iGlobalAXI.ACLK,iGlobalAXI.ARESETn)
begin
if (iGlobalAXI.ARESETn=HIGHN) then
	oS_AXI.RdAddrCh.ARREADY <= cHIGH;
	svAddress				<= (others=>cLOW);
	RdState 				<= RD_SETUP_ST;
	oS_AXI.RdAddrCh.AR 		<= cHIGH;
	sCountValid             <= cLOW;
	sCountTick				<= cLOW;
	sRstCount               <= cLOW;
elsif rising_edge(iGlobalAXI.ACLK) then
	case RdState is
		when RD_SETUP_ST	=>  RdState 	 <= RD_SETUP_ST;
								sCountValid  <= cLOW;
								sRstCount    <= cLOW;
								if iS_AXI.RdAddrCh.ARVALID=cHIGH then
									oS_AXI.RdAddrCh.ARREADY <= cLOW;
									RdState 				<= RD_LATENCY_ST;
									svAddress				<= iS_AXI.RdAddrCh.ARADDR;
									assert (iS_AXI.RAddrCh.ARPROT="000") report "ignoring read access permissions" severity warning;
									sCountValid  			<= cHIGH;
								end if;
		when RD_LATENCY_ST	=>  RdState 	 <= RD_LATENCY_ST;
								if sCountTick=cHIGH then
									sCountValid <= cLOW;
									sRstCount   <= cHIGH;
								end if;
		when RD_ACCESS_ST 	=>  RdState 	<= RD_ACCESS_ST;
								sRstCount   <= cLOW;
								if iS_AXI.RdDataCh.RREADY = cHIGH then
									RdState 	<= RD_SETUP_ST;
								end if;
	end case;
end if;
end process pREAD;



end architecture aArea;