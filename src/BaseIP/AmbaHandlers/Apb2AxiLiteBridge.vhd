library ieee;
use ieee.std_logic_1164.all;

use work.Constants.all;
use work.axi4.all;
use work.amba3.all;

entity eApb2AxiLiteBridge is
generic (
    gAPB_ADDRWidth      : natural;
    gAPB_DATAWidth      : natural;
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

iGlobal     : in rGlobalAPB;
--APB Slave
iS_Apb        : in rAPBMoSi (PWDATA(gAPB_DATAWidth-1 downto 0),PSTRB(gAPB_DATAWidth/cBYTELEN-1 downto 0),PADDR(gAPB_ADDRWidth-1 downto 0));
oS_Apb        : out rAPBMiSo (PWDATA(gAPB_DATAWidth-1 downto 0));
--Axi Lite Master
oM_AxiLite    : out rAxi4LiteMoSi( WAddrCh ( AWADDR(gAXI_ADDRWidth-1 downto 0),
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
iM_AxiLite    : in rAxi4LiteMiSo( RDataCh ( RDATA(gAXI_DATAWidth-1 downto 0)),
									 WRespCh ( BOPTIONAL ( BID(gAXI_WRespIDWidht-1 downto 0) ,
														   BUSER(gAXI_WRespUSERWidht-1 downto 0))
											 )
									)

);
end entity eApb2AxiLiteBridge;

architecture aBehavioral of eApb2AxiLiteBridge is

type StateT is (IDLE,WADDRESS,RADDRESS,WDATA,RDATA);
signal sState : StateT;

begin


oM_AxiLite.WAddrCh.AWADDR <= iS_Apb.PADDR ;--and iS_Apb.PWRITE;
oM_AxiLite.WAddrCh.AWPROT <= iS_Apb.PPROT ;--and iS_Apb.PWRITE;
oM_AxiLite.RAddrCh.ARADDR <= iS_Apb.PADDR ;--and not(iS_Apb.PWRITE);
oM_AxiLite.RAddrCh.ARPROT <= iS_Apb.PPROT ;--and not(iS_Apb.PWRITE);
oM_AxiLite.WDataCh.WVALID <= iS_Apb.PENABLE when sState=WDATA else cLOW;--and not(iS_Apb.PWRITE);
oM_AxiLite.WDataCh.WSTRB  <= iS_Apb.PSTRB ;-- when sState=WDATA else (oM_AxiLite.WDataCh.WSTRB´range=>'0');--and not(iS_Apb.PWRITE);
oM_AxiLite.WDataCh.WDATA  <= iS_Apb.PWDATA ;--when sState=WDATA else (oM_AxiLite.WDataCh.WDATA´range=>'0');--and not(iS_Apb.PWRITE);
oM_AxiLite.WRespCh.BREADY <= '1';--and not(iS_Apb.PWRITE);

oS_Apb.PSLVERR            <= cHIGH when iM_AxiLite.WRespCh.BVALID='1' and iM_AxiLite.WRespCh.BRESP/="00" else
                            cHIGH when iM_AxiLite.RDataCh.RVALID='1' and iM_AxiLite.RDataCh.RRESP/="00" else
                            cLOW;
oS_Apb.PREADY             <= iM_AxiLite.WDataCh.WREADY when sState=WDATA else
                            iM_AxiLite.RDataCh.RVALID when (sState=RDATA and iS_Apb.PENABLE=cHIGH) else
                            '0';
oS_Apb.PRDATA             <= iM_AxiLite.RDataCh.RDATA;

pFSM : process(iGlobal.PCLK)
begin
if rising_edge(iGlobal.PCLK) then
    if (iGlobal.PRESETn=cLOW) then
        sState                   <= IDLE;
        oM_AxiLite.WAddrCh.AWVALID <= cLOW;
        oM_AxiLite.RAddrCh.ARVALID <= cLOW;
        oM_AxiLite.RDataCh.RREADY  <= cLOW;  
    else
        case sState is 

        when IDLE =>  sState <= IDLE;
                      oM_AxiLite.WAddrCh.AWVALID <= cLOW;
                      oM_AxiLite.RAddrCh.ARVALID <= cLOW;
                      if iS_Apb.PSELx=cHIGH then
                        if iS_Apb.PWRITE=cHIGH then
                            oM_AxiLite.WAddrCh.AWVALID <= cHIGH;
                            sState <= WADDRESS;
                        else
                            oM_AxiLite.RAddrCh.ARVALID <= cHIGH;
                            sState <= RADDRESS;
                        end if;                

                     end if;
        when WADDRESS => sState <= WDATA;
                         oM_AxiLite.WAddrCh.AWVALID <= cHIGH;
                        if iM_AxiLite.WAddrCh.AWREADY=cHIGH then
                            sState <= WDATA;
                            oM_AxiLite.WAddrCh.AWVALID <= cLOW;
                        end if;
        when RADDRESS => sState <= RDATA;
                         oM_AxiLite.RAddrCh.ARVALID <= cHIGH;
                         oM_AxiLite.RDataCh.RREADY <= cLOW;  
                         if iM_AxiLite.RAddrCh.ARREADY=cHIGH then
                            oM_AxiLite.RAddrCh.ARVALID <= cLOW;
                            oM_AxiLite.RDataCh.RREADY <= cHIGH;   
                            sState <= RDATA;
                         end if;
        when WDATA    => sState <= WDATA; 
                        if iM_AxiLite.WDataCh.WREADY=cHIGH then
                            sState <= IDLE;
                        end if;
        when RDATA    => oM_AxiLite.RDataCh.RREADY <= cHIGH;
                         sState <= RDATA;
                         if iM_AxiLite.RDataCh.RVALID=cHIGH then
                            oM_AxiLite.RDataCh.RREADY <= cLOW;
                            sState <= IDLE;
                         end if;
        when others => null;

        end case ;
    end if;
end if;
end process;

end architecture aBehavioral;

