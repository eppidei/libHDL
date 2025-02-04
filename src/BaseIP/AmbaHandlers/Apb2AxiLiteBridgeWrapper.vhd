library ieee;
use ieee.std_logic_1164.all;

use work.Constants.all;
use work.axi4.all;
use work.amba3.all;

entity eApb2AxiLiteBridgeWrapper is
generic (
    gADDRWidth      : natural:= 32;
    gDATAWidth      : natural:= 32
);
port (
iClk          : in std_logic;
iResetn       : in std_logic;     
-- APB slave   
s_apb_pprot   : in std_logic_vector(2 downto 0);
s_apb_pselx   : in std_logic;                    
s_apb_penable : in std_logic;                                                        
s_apb_pwrite  : in std_logic;                  
s_apb_pwdata  : in std_logic_vector(gDATAWidth-1 downto 0);           
s_apb_pstrb   : in std_logic_vector(gDATAWidth/cBYTELEN-1 downto 0);           
s_apb_paddr   : in std_logic_vector(gADDRWidth-1 downto 0); 
s_apb_pready  : out std_logic;                   
s_apb_prdata  : out std_logic_vector(gDATAWidth-1 downto 0);                                                
s_apb_pslverr : out std_logic; 
-- AXI Lite Master
m_axi_awaddr  : out std_logic_vector(gADDRWidth-1 downto 0);	
m_axi_awprot  : out std_logic_vector(2 downto 0);	
m_axi_awvalid : out std_logic;		
m_axi_awready : in std_logic;	
m_axi_wdata   : out std_logic_vector(gDATAWidth-1 downto 0);	
m_axi_wstrb   : out std_logic_vector(gDATAWidth/cBYTELEN-1 downto 0);	
m_axi_wvalid  : out std_logic;
m_axi_wready  : in std_logic;	
m_axi_bresp   : in std_logic_vector(1 downto 0);	
m_axi_bvalid  : in std_logic;
m_axi_bready  : out std_logic; 
m_axi_araddr  : out std_logic_vector(gADDRWidth-1 downto 0);	
m_axi_arprot  : out std_logic_vector(2 downto 0);
m_axi_arvalid : out std_logic;
m_axi_arready : in std_logic;
m_axi_rready  : out std_logic;	
m_axi_rdata   : in std_logic_vector(gDATAWidth-1 downto 0);	
m_axi_rresp   : in std_logic_vector(1 downto 0);
m_axi_rvalid  : in std_logic
);
end entity eApb2AxiLiteBridgeWrapper;

architecture aRTL of eApb2AxiLiteBridgeWrapper is

constant cAXI_WAddrIDWidht   : natural := 1;
constant cAXI_WDataIDWidht   : natural := 1;
constant cAXI_WAddrUSERWidht : natural := 1;
constant cAXI_WDataUSERWidht : natural := 1;
constant cAXI_RAddrUSERWidht : natural := 1;
constant cAXI_RAddrIDWidht   : natural := 1;
constant cAXI_RDataUSERWidht : natural := 1;
constant cAXI_RDataIDWidht   : natural := 1;
constant cAXI_WRespIDWidht   : natural := 1;
constant cAXI_WRespUSERWidht : natural := 1;

signal sGlobalAPB   : rGlobalAPB;
signal sAxiLiteMiSo : rAxi4LiteMiSo( RDataCh ( RDATA(gDATAWidth-1 downto 0),
                                               ROPTIONAL(RID(cAXI_RDataIDWidht-1 downto 0),
                                                         RUSER(cAXI_RDataUSERWidht-1 downto 0))
                                                         ),
									 WRespCh ( BOPTIONAL ( BID(cAXI_WRespIDWidht-1 downto 0) ,
														   BUSER(cAXI_WRespUSERWidht-1 downto 0))
											 )
									);
signal sAxiLiteMoSi : rAxi4LiteMoSi( WAddrCh ( AWADDR(gADDRWidth-1 downto 0),
											   AWOPTIONAL ( AWID(cAXI_WAddrIDWidht-1 downto 0),
														    AWUSER(cAXI_WAddrUSERWidht-1 downto 0))
											 ),
									 WDataCh ( WDATA(gDATAWidth-1 downto 0),
											   WSTRB(gDATAWidth/cBYTELEN-1 downto 0),
											   WOPTIONAL ( WID(cAXI_WDataIDWidht-1 downto 0),
														   WUSER(cAXI_WDataUSERWidht-1 downto 0))
											 ),
									 RAddrCh ( ARADDR(gADDRWidth-1 downto 0),
											   AROPTIONAL ( ARID(cAXI_RAddrIDWidht-1 downto 0),
														    ARUSER(cAXI_RAddrUSERWidht-1 downto 0))
											 )
									 );

signal sAPBMoSi : rAPBMoSi (PWDATA(gDATAWidth-1 downto 0),
                            PSTRB(gDATAWidth/cBYTELEN-1 downto 0),
                            PADDR(gADDRWidth-1 downto 0));
signal sAPBMiSo : rAPBMiSo (PRDATA(gDATAWidth-1 downto 0));

begin

procConnectGlobalAPB ( sGlobalAPB, 
                       iClk, 
                       iResetn);
procConnectSlaveAPBMiSo ( sAPBMiSo,
                                s_apb_pready    ,
                                s_apb_prdata    ,           
                                s_apb_pslverr   );
procConnectSlaveAPBMoSi ( sAPBMoSi ,
                          s_apb_pprot   ,
                          s_apb_pselx   ,
                          s_apb_penable ,
                          s_apb_pwrite  ,
                          s_apb_pwdata  ,
                          s_apb_pstrb   ,
                          s_apb_paddr   );
procConnectMaster_AXILiteMiSo (  sAxiLiteMiSo,  	
                                m_axi_awready ,	
                                m_axi_wready  ,	
                                m_axi_bresp   ,	
                                m_axi_bvalid  , 
                                m_axi_arready ,
                                m_axi_rdata   ,	
                                m_axi_rresp   ,
                                m_axi_rvalid  );
procConnectMaster_AXILiteMoSi ( sAxiLiteMoSi   ,	
                                m_axi_awaddr  ,	
                                m_axi_awprot  ,	
                                m_axi_awvalid ,		
                                m_axi_wdata   ,	
                                m_axi_wstrb   ,	
                                m_axi_wvalid  ,
                                m_axi_bready  ,	
                                m_axi_araddr  ,	
                                m_axi_arprot  ,
                                m_axi_arvalid ,                          
                                m_axi_rready  );

iApb2AxiLiteBridge : entity work.eApb2AxiLiteBridge
generic map(
gAPB_ADDRWidth   => gADDRWidth,
gAPB_DATAWidth   => gDATAWidth,
gAXI_ADDRWidth 	 => gADDRWidth,
gAXI_DATAWidth 	 => gDATAWidth
)
port map (
iGlobal     => sGlobalAPB,
--APB Slave
iS_Apb        => sAPBMoSi ,
oS_Apb        => sAPBMiSo ,
--Axi Lite Master
oM_AxiLite    => sAxiLiteMoSi,
iM_AxiLite    => sAxiLiteMiSo 

);


end architecture aRTL;