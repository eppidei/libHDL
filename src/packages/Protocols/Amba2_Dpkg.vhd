library ieee;
use ieee.std_logic_1164.all;
package Amba3 is
--type definitions
type rGlobalAPB is record
    PCLK        : std_logic; --The rising edge of PCLK times all transfers on the APB.
    PRESETn     : std_logic; --System bus equivalent Reset. The APB reset signal is active LOW. 
                             --This signal is normally connected directly to the system bus reset signal.
end record rGlobalAPB;

type rAPBMoSi is record
    PPROT : std_logic_vector(2 downto 0); --APB4 only bridge Protection type. This signal indicates the normal, privileged, or secure
                                          --protection level of the transaction and whether the transaction is a data access
                                          --or an instruction access.
    PSELx : std_logic;                    --APB bridge Select. The APB bridge unit generates this signal to each peripheral bus slave.
                                          --It indicates that the slave device is selected and that a data transfer is required.
                                          --There is a PSELx signal for each slave.
    PENABLE : std_logic;                  --APB bridge Enable. This signal indicates the second and subsequent cycles of an APB
                                          --transfer.
    PWRITE  : std_logic;                  --APB bridge Direction. This signal indicates an APB write access when HIGH and an APB
                                          --read access when LOW.
    PWDATA  : std_logic_vector;           --APB bridge Write data. This bus is driven by the peripheral bus bridge unit during write
                                          --cycles when PWRITE is HIGH. This bus can be up to 32 bits wide.
    PSTRB   : std_logic_vector;           --APB4 only bridge Write strobes. This signal indicates which byte lanes to update during a write
                                          --transfer. There is one write strobe for each eight bits of the write data bus.
                                          --Therefore, PSTRB[n] corresponds to PWDATA[(8n + 7):(8n)]. Write
                                          --strobes must not be active during a read transfer.
    PADDR   : std_logic_vector;           --APB bridge Address. This is the APB address bus. It can be up to 32 bits wide and is driven
                                          --by the peripheral bus bridge unit.
end record rAPBMoSi;

type rAPBMiSo is record
    PREADY : std_logic;                   --Slave interface Ready. The slave uses this signal to extend an APB transfer.
    PRDATA : std_logic_vector;            --Slave interface Read Data. The selected slave drives this bus during read cycles when
                                          --PWRITE is LOW. This bus can be up to 32-bits wide.
    PSLVERR : std_logic;                  --Slave interface This signal indicates a transfer failure. APB peripherals are not required to
                                          --support the PSLVERR pin. This is true for both existing and new APB
                                          --peripheral designs. Where a peripheral does not include this pin then the
                                          --appropriate input to the APB bridge is tied LOW.
end record rAPBMiSo;

procedure procConnectGlobalAPB ( signal oGlobalAPB   : out rGlobalAPB; 
                                 signal iClock        : in std_logic; 
                                 signal iResetn       : in std_logic); 

procedure procConnectSlaveAPBMiSo ( signal APBMiSo   : in rAPBMiSo;
                                    signal PREADY    : out std_logic;       
                                    signal PRDATA    : out std_logic_vector;           
                                    signal PSLVERR   : out std_logic   );

procedure procConnectSlaveAPBMoSi ( signal APBMoSi : out rAPBMoSi ;
                                    signal PPROT   : in std_logic_vector(2 downto 0);
                                    signal PSELx   : in std_logic;                   
                                    signal PENABLE : in std_logic;                  
                                    signal PWRITE  : in std_logic;                 
                                    signal PWDATA  : in std_logic_vector;           
                                    signal PSTRB   : in std_logic_vector;           
                                    signal PADDR   : in std_logic_vector  );
end package Amba3;


