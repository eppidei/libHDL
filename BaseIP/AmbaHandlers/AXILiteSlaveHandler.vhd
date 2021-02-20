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
	oWData		  : out std_logic_vector(gAXI_DATAWidth-1 downto 0);
	oRdData       : out std_logic_vector(gAXI_DATAWidth-1 downto 0);
    oWrAddress    : out std_logic_vector(gAXI_ADDRWidth-1 downto 0);
    oRdAddress    : out std_logic_vector(gAXI_ADDRWidth-1 downto 0);
	oWrStrobe     : out std_logic_vector(gAXI_DATAWidth/cBYTELEN-1 downto 0);
	oWEna         : out std_logic
);
end eAXILiteSlaveHandler;

--throughput limited version address and data phases tighted together
architecture aArea of eAXILiteSlaveHandler is


--Counter signals
signal sGlobalFab  		 : rGlobalFab;
signal sCountValid		 : std_logic;
signal sRstCount   		 : std_logic;
signal sCountTick		 : std_logic;
signal sCountValid		 : std_logic;
signal sCLK_ENABLED 	 : std_logic := cHIGH;
signal sSRSTN_DISABLED 	 : std_logic := cLOWN;
signal sARST_DISABLED 	 : std_logic := cLOW;
--Read SM
type RdChState is (RD_SETUP_ST,RD_LATENCY_ST,RD_ACCESS_ST);
signal stREADCH 		 : RdChState;
signal svRdAddress 	 	 : std_logic_vector(oAddress'range);
--Write SM
type WrChState is (WR_SETUP_ST,WR_ACCESS_ST);
signal stWRITECH : WrChState;
signal svWrAddress 	 	 : std_logic_vector(oAddress'range);
--signal sWrEna 			 : std_logic;

begin
---------------------------------------------------------------
------------------- WRITE CHANNELS ----------------------------
---------------------------------------------------------------

oWData	   			  <= iS_AXI.WrDataCh.WDATA;
oWrAddress 			  <= svWrAddress;
oWEna      			  <= iS_AXI.WrAddrCh.WVALID = cHIGH and oS_AXI.WrAddrCh.WREADY;
oS_AXI.WDataCh.RRESP  <= cAXIRESP_OKAY;

pWRITE : process(iGlobalAXI.ACLK,iGlobalAXI.ARESETn)
begin
if (iGlobalAXI.ARESETn=HIGHN) then
	oS_AXI.WrAddrCh.AWREADY <= cHIGH;
	oS_AXI.WrAddrCh.WREADY 	<= cLOW;
	svWrAddress				<= (others=>cLOW);
elsif rising_edge(iGlobalAXI.ACLK) then
	case stWRITECH is
		when WR_SETUP_ST	=>  stWRITECH <= WR_SETUP_ST;
								if iS_AXI.WrAddrCh.AWVALID = cHIGH then
									svWrAddress	 			<= iS_AXI.WrAddrCh.AWADDR;
									oS_AXI.WrAddrCh.AWREADY <= cLOW;
									oS_AXI.WrAddrCh.WREADY 	<= cHIGH;
								end if;
		when WR_ACCESS_ST 	=>  stWRITECH <= WR_ACCESS_ST;
								if iS_AXI.WrAddrCh.WVALID = cHIGH then
									oS_AXI.WrAddrCh.WREADY 	<= cLOW;
									stWRITECH 				<= WR_SETUP_ST;
								end if;

	end case;
end if;
end process pWRITE;
---------------------------------------------------------------
------------------- READ CHANNELS -----------------------------
---------------------------------------------------------------

lab_LatCntGlobConnect : procConnectGlobalFab ( sGlobalFab,
											   iGlobalAXI.ACLK, 
											   sCLKENABLED, 
											   sRstCount,
											   sSRSTN_DISABLED,
											   sARST_DISABLED,
											   iGlobalAXI.ARESETN);

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

--oS_AXI.RDataCh.RVALID <= cHIGH when stREADCH=RD_ACCESS_ST and iS_AXI.RdDataCh.RREADY = cHIGH
--						 else cLOW;
oS_AXI.RDataCh.RRESP  <= cAXIRESP_OKAY;

pREAD : process(iGlobalAXI.ACLK,iGlobalAXI.ARESETn)
begin
if (iGlobalAXI.ARESETn=HIGHN) then
	oS_AXI.RdAddrCh.ARREADY <= cHIGH;
	oS_AXI.RDataCh.RVALID   <= cLOW;
	svRdAddress				<= (others=>cLOW);
	stREADCH 				<= RD_SETUP_ST;
	oS_AXI.RdAddrCh.AR 		<= cHIGH;
	sCountValid             <= cLOW;
	sCountTick				<= cLOW;
	sRstCount               <= cLOW;
elsif rising_edge(iGlobalAXI.ACLK) then
	case stREADCH is
		when RD_SETUP_ST	=>  stREADCH 	 			<= RD_SETUP_ST;
								sCountValid  			<= cLOW;
								sRstCount    			<= cLOW;
								oS_AXI.RDataCh.RVALID	<= cLOW;
								if iS_AXI.RdAddrCh.ARVALID=cHIGH then
									oS_AXI.RdAddrCh.ARREADY <= cLOW;
									stREADCH 				<= RD_LATENCY_ST;
									svRdAddress				<= iS_AXI.RdAddrCh.ARADDR;
									assert (iS_AXI.RAddrCh.ARPROT="000") report "ignoring read access permissions" severity warning;
									sCountValid  			<= cHIGH;
								end if;
		when RD_LATENCY_ST	=>  stREADCH 	 <= RD_LATENCY_ST;
								if sCountTick=cHIGH then
									sCountValid 			<= cLOW;
									sRstCount   			<= cHIGH;
									oS_AXI.RDataCh.RVALID	<= cHIGH;
								end if;
		when RD_ACCESS_ST 	=>  stREADCH 	<= RD_ACCESS_ST;
								sRstCount   <= cLOW;
								if iS_AXI.RdDataCh.RREADY = cHIGH then
									stREADCH 	<= RD_SETUP_ST;
									oS_AXI.RDataCh.RVALID	<= cLOW;
								end if;
		when others 		=>  null;
	end case;
end if;
end process pREAD;
 
end architecture aArea;