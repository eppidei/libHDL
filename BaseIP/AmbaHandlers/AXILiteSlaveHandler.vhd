use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.amba2.all;
use work.FabricBus.all;
use work.constants.all;
use work.Utilities.all;

entity eAXILiteSlaveHandler is
generic (
	gSlaveReadLatency   : integer;
	gAXI_ADDRWidth 	    : integer;
	gAXI_DATAWidth 	    : integer;
	gAXI_WAddrIDWidht   : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_WDataIDWidht   : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_WRespIDWidht   : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_RAddrIDWidht   : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_RDataIDWidht   : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_WAddrUSERWidht : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_WDataUSERWidht : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_WRespUSERWidht : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_RAddrUSERWidht : integer:=1; --opt. fields set by default to 1 if not used
	gAXI_RDataUSERWidht : integer:=1  --opt. fields set by default to 1 if not used
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
    oAddress    : out std_logic_vector(gAXI_ADDRWidth-1 downto 0);
	oWEna       : out std_logic
);
end eAXILiteSlaveHandler;

--throughput limited version
architecture aArea of eAXILiteSlaveHandler is

signal svAddress : std_logic_vector(oAddress'range);

begin


pREAD : process(iGlobalAXI.ACLK)
begin
if (iGlobalAXI.ARESETn=HIGHN) then
	oS_AXI.RdAddrCh.ARREADY <= '1';
	svAddress				<= (others=>'0');
	RdState 				<= RD_SETUP_ST;
	oS_AXI.RdAddrCh.AR 		<= '1';
elsif rising_edge(iGlobalAXI.ACLK) then
	case RdState is
		when RD_SETUP_ST => RdState <= RD_SETUP_ST;
							if iS_AXI.RdAddrCh.ARVALID='1' then
								oS_AXI.RdAddrCh.ARREADY <= '0';
								RdState 				<= RD_ACCESS_ST;
								svAddress				<= iS_AXI.RdAddrCh.ARADDR;
							end if;
		when RD_ACCESS_ST => RdState <= RD_ACCESS_ST;
							 if iS_AXI.RdDataCh.RREADY = '1' then
							 
							 end if;
	end case;
end if;
end process pREAD;



end architecture aArea;