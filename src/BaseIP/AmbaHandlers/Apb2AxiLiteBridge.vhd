library ieee;
use ieee.std_logic_1164.all;

use work.Constants.all;
use work.axi4.all;
use work.amba2.all;

entity eApb2AxiLiteBridge is
port (

iGlobal     : in rGlobalAPB;
--APB Slave
iApb        : in rAPBMoSi;
oApb        : out rAPBMiSo;
--Axi Lite Master
oAxiLite    : out rAxi4LiteMoSi;
iAxiLite    : out rAxi4LiteMiSo

);
end entity eApb2AxiLiteBridge;

architecture aBehavioral of eApb2AxiLiteBridge is

type StateT is (IDLE,WADDRESS,RADDRESS,WDATA,RDATA);
signal sState : StateT;

begin


oAxiLite.WAddrCh.AWADDR <= iApb.PADDR ;--and iApb.PWRITE;
oAxiLite.WAddrCh.AWPROT <= iApb.PPROT ;--and iApb.PWRITE;
oAxiLite.RAddrCh.ARADDR <= iApb.PADDR ;--and not(iApb.PWRITE);
oAxiLite.RAddrCh.ARPROT <= iApb.PPROT ;--and not(iApb.PWRITE);
oAxiLite.WDataCh.WVALID <= iApb.PENABLE when sState=WDATA else cLOW;--and not(iApb.PWRITE);
oAxiLite.WDataCh.WSTRB  <= iApb.PSTRB ;-- when sState=WDATA else (oAxiLite.WDataCh.WSTRB´range=>'0');--and not(iApb.PWRITE);
oAxiLite.WDataCh.WDATA  <= iApb.PWDATA ;--when sState=WDATA else (oAxiLite.WDataCh.WDATA´range=>'0');--and not(iApb.PWRITE);
oAxiLite.WRespCh.BREADY <= '1';--and not(iApb.PWRITE);

oApb.PSLVERR            <= cHIGH when iAxiLite.WRespCh.BVALID='1' and iAxiLite.WRespCh.BRESP/="00" else
                            cHIGH when iAxiLite.RDataCh.RVALID='1' and iAxiLite.RDataCh.RRESP/="00" else
                            cLOW;
oApb.PREADY             <= iAxiLite.WDataCh.WREADY when sState=WDATA else
                            iAxiLite.RDataCh.RVALID when (sState=RDATA and iApb.PENABLE=cHIGH) else
                            '0';
oApb.PRDATA             <= iAxiLite.RDataCh.RDATA;

pFSM : process(iGlobal.PCLK)
begin
if rising_edge(iGlobal.PCLK) then
    if (iGlobal.PRESETn=cLOW) then
        sState                   <= IDLE;
        oAxiLite.WAddrCh.AWVALID <= cLOW;
        oAxiLite.RAddrCh.ARVALID <= cLOW;
        oAxiLite.RDataCh.RREADY  <= cLOW;  
    else
        case sState is 

        when IDLE =>  sState <= IDLE;
                      oAxiLite.WAddrCh.AWVALID <= cLOW;
                      oAxiLite.RAddrCh.ARVALID <= cLOW;
                      if iApb.PSELx=cHIGH then
                        if iApb.PWRITE=cHIGH then
                            oAxiLite.WAddrCh.AWVALID <= cHIGH;
                            sState <= WADDRESS;
                        else
                            oAxiLite.RAddrCh.ARVALID <= cHIGH;
                            sState <= RADDRESS;
                        end if;                

                     end if;
        when WADDRESS => sState <= WDATA;
                         oAxiLite.WAddrCh.AWVALID <= cHIGH;
                        if iAxiLite.WAddrCh.AWREADY=cHIGH then
                            sState <= WDATA;
                            oAxiLite.WAddrCh.AWVALID <= cLOW;
                        end if;
        when RADDRESS => sState <= RDATA;
                         oAxiLite.RAddrCh.ARVALID <= cHIGH;
                         oAxiLite.RDataCh.RREADY <= cLOW;  
                         if iAxiLite.RAddrCh.ARREADY=cHIGH then
                            oAxiLite.RAddrCh.ARVALID <= cLOW;
                            oAxiLite.RDataCh.RREADY <= cHIGH;   
                            sState <= RDATA;
                         end if;
        when WDATA    => sState <= WDATA; 
                        if iAxiLite.WDataCh.WREADY=cHIGH then
                            sState <= IDLE;
                        end if;
        when RDATA    => oAxiLite.RDataCh.RREADY <= cHIGH;
                         sState <= RDATA;
                         if iAxiLite.RDataCh.RVALID=cHIGH then
                            oAxiLite.RDataCh.RREADY <= cLOW;
                            sState <= IDLE;
                         end if;
        when others => null;

        end case ;
    end if;
end if;
end process;

end aBehavioral;

