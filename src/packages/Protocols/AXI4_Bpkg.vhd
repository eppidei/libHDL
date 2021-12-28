library ieee;
use ieee.std_logic_1164.all;

package body AXI4 is



procedure procConnectMaster_AXILiteMiSo ( signal AxiLiteMiSo   : out rAxi4LiteMiSo;	
                                          signal m_axi_awready : in std_logic;	
                                          signal m_axi_wready  : in std_logic;	
                                          signal m_axi_bresp   : in std_logic_vector;	
                                          signal m_axi_bvalid  : in std_logic;
                                          signal m_axi_arready : in std_logic;
                                          signal m_axi_rdata   : in std_logic_vector;	
                                          signal m_axi_rresp   : in std_logic_vector;
                                          signal m_axi_rvalid  : in std_logic ) is
begin
AxiLiteMiSo.WAddrCh.AWREADY<= m_axi_awready;
AxiLiteMiSo.WDataCh.WREADY <= m_axi_wready  ;
AxiLiteMiSo.WRespCh.BRESP <= m_axi_bresp  ;
AxiLiteMiSo.WRespCh.BVALID <= m_axi_bvalid  ;
AxiLiteMiSo.RAddrCh.ARREADY<= m_axi_arready ;
AxiLiteMiSo.RDataCh.RDATA  <= m_axi_rdata   ;
AxiLiteMiSo.RDataCh.RRESP  <= m_axi_rresp   ;
AxiLiteMiSo.RDataCh.RVALID <= m_axi_rvalid  ;

end procedure procConnectMaster_AXILiteMiSo;

procedure procConnectSlave_AXILiteMiSo ( signal AxiLiteMiSo   : in rAxi4LiteMiSo;	
                                         signal m_axi_awready : out std_logic;	
                                         signal m_axi_wready  : out std_logic;	
                                         signal m_axi_bresp   : out std_logic_vector;	
                                         signal m_axi_bvalid  : out std_logic;
                                         signal m_axi_arready : out std_logic;
                                         signal m_axi_rdata   : out std_logic_vector;	
                                         signal m_axi_rresp   : out std_logic_vector;
                                         signal m_axi_rvalid  : out std_logic ) is
begin
m_axi_awready <= AxiLiteMiSo.WAddrCh.AWREADY;
m_axi_wready  <= AxiLiteMiSo.WDataCh.WREADY ;
m_axi_bresp   <= AxiLiteMiSo.WRespCh.BRESP  ;
m_axi_bvalid  <= AxiLiteMiSo.WRespCh.BVALID ;
m_axi_arready <= AxiLiteMiSo.RAddrCh.ARREADY;
m_axi_rdata   <= AxiLiteMiSo.RDataCh.RDATA  ;
m_axi_rresp   <= AxiLiteMiSo.RDataCh.RRESP  ;
m_axi_rvalid  <= AxiLiteMiSo.RDataCh.RVALID ;

end procedure procConnectSlave_AXILiteMiSo;

procedure procConnectMaster_AXILiteMoSi ( signal AxiLiteMoSi   : in rAxi4LiteMoSi;	
                                          signal m_axi_awaddr  : out std_logic_vector;	
                                          signal m_axi_awprot  : out std_logic_vector;	
                                          signal m_axi_awvalid : out std_logic;		
                                          signal m_axi_wdata   : out std_logic_vector;	
                                          signal m_axi_wstrb   : out std_logic_vector;	
                                          signal m_axi_wvalid  : out std_logic;
                                          signal m_axi_bready  : out std_logic; 
                                          signal m_axi_araddr  : out std_logic_vector;	
                                          signal m_axi_arprot  : out std_logic_vector;
                                          signal m_axi_arvalid : out std_logic;                          
                                          signal m_axi_rready  : out std_logic ) is

begin
m_axi_awaddr  <=AxiLiteMoSi.WAddrCh.AWADDR ;
m_axi_awprot  <=AxiLiteMoSi.WAddrCh.AWPROT ;
m_axi_awvalid <=AxiLiteMoSi.WAddrCh.AWVALID;
m_axi_wdata   <=AxiLiteMoSi.WDataCh.WDATA  ;
m_axi_wstrb   <=AxiLiteMoSi.WDataCh.WSTRB  ;
m_axi_wvalid  <=AxiLiteMoSi.WDataCh.WVALID ;
m_axi_bready  <=AxiLiteMoSi.WRespCh.BREADY ;
m_axi_araddr  <=AxiLiteMoSi.RAddrCh.ARADDR ;
m_axi_arprot  <=AxiLiteMoSi.RAddrCh.ARPROT ;
m_axi_arvalid <=AxiLiteMoSi.RAddrCh.ARVALID;
m_axi_rready  <=AxiLiteMoSi.RDataCh.RREADY ;

end procedure procConnectMaster_AXILiteMoSi;

procedure procConnectSlave_AXILiteMoSi ( signal AxiLiteMoSi    : out rAxi4LiteMoSi;	
                                          signal m_axi_awaddr  : in std_logic_vector;	
                                          signal m_axi_awprot  : in std_logic_vector;	
                                          signal m_axi_awvalid : in std_logic;		
                                          signal m_axi_wdata   : in std_logic_vector;	
                                          signal m_axi_wstrb   : in std_logic_vector;	
                                          signal m_axi_wvalid  : in std_logic;
                                          signal m_axi_bready  : in std_logic; 
                                          signal m_axi_araddr  : in std_logic_vector;	
                                          signal m_axi_arprot  : in std_logic_vector;
                                          signal m_axi_arvalid : in std_logic;                          
                                          signal m_axi_rready  : in std_logic ) is

begin
AxiLiteMoSi.WAddrCh.AWADDR <=m_axi_awaddr  ;
AxiLiteMoSi.WAddrCh.AWPROT <=m_axi_awprot  ;
AxiLiteMoSi.WAddrCh.AWVALID<=m_axi_awvalid ;
AxiLiteMoSi.WDataCh.WDATA  <=m_axi_wdata   ;
AxiLiteMoSi.WDataCh.WSTRB  <=m_axi_wstrb   ;
AxiLiteMoSi.WDataCh.WVALID <=m_axi_wvalid  ;
AxiLiteMoSi.WRespCh.BREADY <=m_axi_bready  ;
AxiLiteMoSi.RAddrCh.ARADDR <=m_axi_araddr  ;
AxiLiteMoSi.RAddrCh.ARPROT <=m_axi_arprot  ;
AxiLiteMoSi.RAddrCh.ARVALID<=m_axi_arvalid ;
AxiLiteMoSi.RDataCh.RREADY <=m_axi_rready  ;

end procedure procConnectSlave_AXILiteMoSi;

end package body AXI4;