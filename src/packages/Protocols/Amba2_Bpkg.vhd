library ieee;
use ieee.std_logic_1164.all;

package body Amba2 is

procedure procConnectGlobalAPB ( signal oGlobalAPB    : out rGlobalAPB; 
                                 signal iClock        : in std_logic; 
                                 signal iResetn       : in std_logic) is
begin
oGlobalAPB.PCLK      <= iClock;
oGlobalAPB.PRESETN   <= iResetn;
end procedure procConnectGlobalAPB;

procedure procConnectAPBMiSo ( signal iAPBMiSo   : in rAPBMiSo;
                               signal oPREADY    : out std_logic;       
                               signal oPRDATA    : out std_logic_vector;           
                               signal oPSLVERR   : out std_logic   ) is
begin
oPREADY  <= iAPBMiSo.PREADY;
oPRDATA  <= iAPBMiSo.PRDATA;
oPSLVERR <= iAPBMiSo.PSLVERR;
end procedure procConnectAPBMiSo;
    
procedure procConnectAPBMoSi ( signal oAPBMoSi : out rAPBMoSi ;
                               signal iPPROT   : in std_logic_vector(2 downto 0);
                               signal iPSELx   : in std_logic;                   
                               signal iPENABLE : in std_logic;                  
                               signal iPWRITE  : in std_logic;                 
                               signal iPWDATA  : in std_logic_vector;           
                               signal iPSTRB   : in std_logic_vector;           
                               signal iPADDR   : in std_logic_vector  ) is
begin
oAPBMoSi.PPROT      <= iPPROT;
oAPBMoSi.PSELx      <= iPSELx;
oAPBMoSi.PENABLE    <= iPENABLE;
oAPBMoSi.PWRITE     <= iPWRITE;
oAPBMoSi.PWDATA     <= iPWDATA;
oAPBMoSi.PSTRB      <= iPSTRB;
oAPBMoSi.PADDR      <= iPADDR;
end procedure procConnectAPBMoSi;

end package body Amba2;