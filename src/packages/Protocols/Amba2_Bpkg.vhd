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

procedure procConnectSlaveAPBMiSo ( signal APBMiSo   : out rAPBMiSo;
                                    signal PREADY    : in std_logic;       
                                    signal PRDATA    : in std_logic_vector;           
                                    signal PSLVERR   : in std_logic   ) is
begin
APBMiSo.PREADY  <= PREADY  ;
APBMiSo.PRDATA  <= PRDATA  ;
APBMiSo.PSLVERR <= PSLVERR ;
end procedure procConnectSlaveAPBMiSo;
    
procedure procConnectSlaveAPBMoSi ( signal APBMoSi : in rAPBMoSi ;
                                    signal PPROT   : out std_logic_vector(2 downto 0);
                                    signal PSELx   : out std_logic;                   
                                    signal PENABLE : out std_logic;                  
                                    signal PWRITE  : out std_logic;                 
                                    signal PWDATA  : out std_logic_vector;           
                                    signal PSTRB   : out std_logic_vector;           
                                    signal PADDR   : out std_logic_vector  ) is
begin
PPROT    <= APBMoSi.PPROT   ;
PSELx    <= APBMoSi.PSELx   ;
PENABLE  <= APBMoSi.PENABLE ;
PWRITE   <= APBMoSi.PWRITE  ;
PWDATA   <= APBMoSi.PWDATA  ;
PSTRB    <= APBMoSi.PSTRB   ;
PADDR    <= APBMoSi.PADDR   ;
end procedure procConnectSlaveAPBMoSi;

end package body Amba3;