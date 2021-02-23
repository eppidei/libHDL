library ieee;
use ieee.std_logic_1164.all;

package Utilities is

function fNextpow2(a:in integer) return integer;
function fOneHot2Binary (
    One_Hot : std_logic_vector ;
    size    : natural
  ) return std_logic_vector;

end package Utilities;

