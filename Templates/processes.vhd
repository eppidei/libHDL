------ Process with Async/sync rst , Async/sync rstn , ClkEn , Valid

p<Name> : process(iGlobalFab.Clk,iGlobalFab.Arst,iGlobalFab.Arstn)
	begin
	if iGlobalFab.Arst=cHIGH then
	elsif iGlobalFab.Arstn=cHIGH then
	elsif rising_edge(iGlobalFab.Clk) then
		if iGlobalFab.Srst = cHIGH then
		elsif iGlobalFab.Srstn = cHIGHN then
		else
			if iGlobalFab.ClkEn='1' then
				if iValid='1' then			
				end if;		
			end if;
		end if;
	end if;
end process p<Name>;

------ Process with sync rst , sync rstn , ClkEn , Valid

p<Name> : process(iGlobalFab.Clk)
	begin
	if rising_edge(iGlobalFab.Clk) then
		if iGlobalFab.Srst = cHIGH then
		elsif iGlobalFab.Srstn = cHIGHN then
		else
			if iGlobalFab.ClkEn='1' then
				if iValid='1' then			
				end if;		
			end if;
		end if;
	end if;
end process p<Name>;


------ Process with Async rst , Async rstn , ClkEn , Valid

p<Name> : process(iGlobalFab.Clk,iGlobalFab.Arst,iGlobalFab.Arstn)
	begin
	if iGlobalFab.Arst=cHIGH then
	elsif iGlobalFab.Arstn=cHIGH then
	elsif rising_edge(iGlobalFab.Clk) then
		if iGlobalFab.ClkEn='1' then
			if iValid='1' then			
			end if;		
		end if;
	end if;
end process p<Name>;