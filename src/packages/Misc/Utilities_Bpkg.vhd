library ieee;
use ieee.numeric_std.all;

package body Utilities is

function fNextpow2(a:in integer) return integer is	
variable b: integer :=0;
begin
    if a>1 then
        for i in 0 to 30 loop		
		  if (2**i<a) then
		      b:=b+1;
		  end if;
		end loop;
	elsif a=1 then
		b:=1;
	else
	   assert false report " Value " & integer'image(a) & "is not supported in nextpow2 function " & LF & CR &
		" if the Value is 0 we are returning 1 in order to not create negative length vectors " & LF & CR &
		" Please double check if this choice does not harm the design !!!!!!!!!!!!!!!"
	   severity warning;
	   if a=0 then 
		b:=1; 
	   end if;
	end if;	   
return b;	   
end function fNextpow2;

function fOneHot2Binary (
    One_Hot : std_logic_vector ;
    size    : natural
  ) return std_logic_vector is

    variable Bin_Vec_Var : std_logic_vector(size-1 downto 0);

  begin

    Bin_Vec_Var := (others => '0');

    for I in One_Hot'range loop
      if One_Hot(I) = '1' then
        Bin_Vec_Var := Bin_Vec_Var or std_logic_vector(to_unsigned(I,size));
      end if;
    end loop;
    return Bin_Vec_Var;
  end function;


end package body Utilities;