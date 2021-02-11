library ieee;
use ieee.std_logic_1164.all;

package body FabricBus is

procedure procConnectGlobalFab ( signal oGlobalFab  : out rGlobalFab;
                                 signal iClock      : in std_logic; 
                                 signal iClockEna   : in std_logic; 
                                 signal iSreset     : in std_logic;
                                 signal iSresetn    : in std_logic)  is
begin
oGlobalFab.Clk     <= iClock;
oGlobalFab.Srstn   <= iSresetn;
oGlobalFab.Srst    <= iSreset;
oGlobalFab.ClkEn   <= iClockEna;
end procedure;

procedure procConnectLocalMemIn( signal oLocalMemIn  : out rLocalMemIn;
                                 signal Clk          : in std_logic; 
                                 signal Srst         : in std_logic; 
                                 signal Ena          : in std_logic;
                                 signal WriteEna     : in std_logic;
                                 signal Address      : in std_logic_vector;
                                 signal Data         : in std_logic_vector) is
begin

oLocalMemIn.Clk      <= Clk;
oLocalMemIn.Srst     <= Srst;
oLocalMemIn.Ena      <= Ena;
oLocalMemIn.WriteEna <= WriteEna;
oLocalMemIn.Address  <= Address;
oLocalMemIn.Data     <= Data;
end procedure;
end package body FabricBus;