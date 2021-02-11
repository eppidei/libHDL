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
	   assert false report " NULL RANGE in nextpow2 function " severity warning;
	end if;	   
return b;	   
end function fNextpow2;


end package body Utilities;