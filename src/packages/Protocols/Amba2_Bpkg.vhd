library ieee;
use ieee.std_logic_1164.all;

package body Amba3 is

procedure procConnectGlobalAPB ( signal oGlobalAPB    : out rGlobalAPB; 
                                 signal iClock        : in std_logic; 
                                 signal iResetn       : in std_logic) is
begin
oGlobalAPB.PCLK      <= iClock;
oGlobalAPB.PRESETN   <= iResetn;
end procedure procConnectGlobalAPB;

procedure procConnectSlaveAPBMiSo ( signal APBMiSo   : in rAPBMiSo;
                                    signal PREADY    : out std_logic;       
                                    signal PRDATA    : out std_logic_vector;           
                                    signal PSLVERR   : out std_logic   ) is
begin
PREADY   <= APBMiSo.PREADY  ;
PRDATA   <= APBMiSo.PRDATA  ;
PSLVERR  <= APBMiSo.PSLVERR ;
end procedure procConnectSlaveAPBMiSo;
    
procedure procConnectSlaveAPBMoSi ( signal APBMoSi : out rAPBMoSi ;
                                    signal PPROT   : in std_logic_vector(2 downto 0);
                                    signal PSELx   : in std_logic;                   
                                    signal PENABLE : in std_logic;                  
                                    signal PWRITE  : in std_logic;                 
                                    signal PWDATA  : in std_logic_vector;           
                                    signal PSTRB   : in std_logic_vector;           
                                    signal PADDR   : in std_logic_vector  ) is
begin
APBMoSi.PPROT    <= PPROT   ;
APBMoSi.PSELx    <= PSELx   ;
APBMoSi.PENABLE  <= PENABLE ;
APBMoSi.PWRITE   <= PWRITE  ;
APBMoSi.PWDATA   <= PWDATA  ;
APBMoSi.PSTRB    <= PSTRB   ;
APBMoSi.PADDR    <= PADDR   ;
end procedure procConnectSlaveAPBMoSi;

end package body Amba3;