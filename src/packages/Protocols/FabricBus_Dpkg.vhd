library ieee;
use ieee.std_logic_1164.all;

package FabricBus is
--type definitions
    type aFFRegisters is array (natural range <>) of std_logic_vector;
    
    type rGlobalFab is record
        Clk        : std_logic;
        ClkEn      : std_logic;
        Srst       : std_logic;
        Srstn      : std_logic;
		Arst       : std_logic;
		Arstn      : std_logic;
    end record rGlobalFab;
    
    type rLocalMemIn is record
        Clk        : std_logic;
        Srst       : std_logic;
        Ena        : std_logic;
        WriteEna   : std_logic;
        Strobe     : std_logic_vector;
        Address    : std_logic_vector;
        Data       : std_logic_vector;
    end record rLocalMemIn;
    
    type rFFDataStream is record 
        Data        : std_logic_vector;
		Strobe      : std_logic_vector;
        WriteEna    : std_logic;
    end record rFFDataStream;
    
    type arFFDataStream is array (natural range <>) of rFFDataStream;
    
     type rLocalMemOut is record
        Data       : std_logic_vector;
    end record rLocalMemOut;
    
    type rLocalMemArrayOut is array (natural range <>) of rLocalMemOut;
--procedure definition       
procedure procConnectGlobalFab ( signal oGlobalFab : out rGlobalFab;
                                 signal iClock      : in std_logic; 
                                 signal iClockEna   : in std_logic; 
                                 signal iSreset     : in std_logic;
                                 signal iSresetn    : in std_logic;
								 signal iAreset     : in std_logic;
                                 signal iAresetn    : in std_logic);
procedure procConnectLocalMemIn( signal oLocalMemIn : out rLocalMemIn;
                                 signal Clk          : in std_logic; 
                                 signal Srst         : in std_logic; 
                                 signal Ena          : in std_logic;
                                 signal WriteEna     : in std_logic;
                                 signal Address      : in std_logic_vector;
                                 signal Data         : in std_logic_vector); 
    
end package FabricBus;

