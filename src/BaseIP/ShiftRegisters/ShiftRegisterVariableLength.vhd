library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Utilities.all;
use work.Constants.all;

entity eShiftRegisterVariableLength is
generic (
gMaxShiftDepth 		: natural ;
gDataWidth	 		: natural 
);
port (
iGlobalFab      : in rGlobalFab;
iValid          : in std_logic;
iLatency        : in natural;
iShift          : in std_logic_vector(gDataWidth-1 downto 0);
oShift 			: out std_logic_vector(gDataWidth-1 downto 0)
);
end entity eShiftRegisterVariableLength;

----------------------------------------
---------- FF ARCHITECTURE -------------
----------------------------------------

architecture aBehaviouralFF of eShiftRegisterVariableLength is

signal saShiftRegister : aFFRegisters(0 to gMaxShiftDepth-1)(gDataWidth-1 downto 0);

begin

lab_output : oShift <= iShift when iLatency=0 else saShiftRegister(iLatency-1);

pSR : process(iGlobalFab.Clk)
begin
if rising_edge(iGlobalFab.Clk) then
	if iGlobalFab.Srst = cHIGH then
		saShiftRegister	<= (others=> (others=>'0'));
	elsif iGlobalFab.Srstn = cHIGHN then
		saShiftRegister	<= (others=> (others=>'0'));
	else
		if iGlobalFab.ClkEn='1' then
			if iValid='1' then
				for i in saShiftRegister'high downto saShiftRegister'low loop
					if i==saShiftRegister'low then
						saShiftRegister(i) <= iShift;
					else
						saShiftRegister(i) <= saShiftRegister(i-1);
					end if;
				end loop;			
			end if;		
		end if;
	end if;
end if;
end process pSR;

end architecture aBehaviouralFF;

----------------------------------------
---------- RAM ARCHITECTURE -------------
----------------------------------------

architecture behav of e_var_len_delay_line is

    signal s_w_address         : unsigned(nextpow2(g_max_latency) - 1 downto 0);
    signal s_r_address         : unsigned(nextpow2(g_max_latency) - 1 downto 0);
    signal s_out               : std_logic_vector(g_nbit - 1 downto 0);
    signal s_data_a            : std_logic_vector(g_nbit - 1 downto 0);
    signal s_dv_int, s_dv_int2 : std_logic;
    signal siguRADDRCNT        : signed(nextpow2(g_max_latency) downto 0);
    signal s_state             : std_logic;
begin

    out_data : outp_o <= inp_i when latency_i = 0
        else s_data_a when latency_i = 1
        else (outp_o'range => '0') when s_state = '0'
        else s_out;
    dv : dv_o         <= enable_i when latency_i = 0
        else s_dv_int when latency_i = 1
        else s_dv_int2;

    i_delay_ram : entity work.e_dual_port_block_Ram
        generic map(
            InitVal          => 0,
            gDEPTH           => 2**nextpow2(g_max_latency),
            gImplementation  => gIMPLEMENTATION,
            gWIDTH           => g_nbit,
            g_registered_out => "false"
        )
        port map(
            clk   => clk_i,
            ena   => enable_i,
            enb   => enable_i,
            wea   => enable_i,
            web   => '0',
            addra => (s_w_address),
            ssra  => srst_i,
            ssrb  => srst_i,
            addrb => (s_r_address),
            dia   => inp_i,
            dib   => (others => '0'),
            doa   => s_data_a,
            dob   => s_out
        );

    p_w_machine : process(clk_i, arst_i)
    begin
        if (arst_i = cARSTHIGH) then
            s_w_address  <= unsigned(to_signed(0, s_w_address'length));
            s_r_address  <= unsigned(to_signed(0, s_r_address'length));
            s_dv_int     <= '0';
            s_dv_int2    <= '0';
            siguRADDRCNT <= -to_signed(latency_i, siguRADDRCNT'length) + to_signed(2, siguRADDRCNT'length);
            s_state      <= '0';
        elsif rising_edge(clk_i) then
            if srst_i = cSRSTHIGH then
                s_w_address  <= unsigned(to_signed(0, s_w_address'length));
                s_r_address  <= unsigned(to_signed(0, s_r_address'length));
                siguRADDRCNT <= -to_signed(latency_i, siguRADDRCNT'length) + to_signed(2, siguRADDRCNT'length);
                s_state      <= '0';
            else
                s_dv_int  <= enable_i;
                s_dv_int2 <= s_dv_int;
                if enable_i = cCLKENHIGH then
                    if s_state = '0' and siguRADDRCNT < 0 then
                        siguRADDRCNT <= siguRADDRCNT + 1;
                    elsif siguRADDRCNT = 0 then
                        s_state <= '1';
                    end if;

                    s_w_address <= s_w_address + 1;
                    s_r_address <= unsigned(signed(s_w_address) - to_signed(latency_i, s_r_address'length) + to_signed(2, s_r_address'length));
                end if;
            end if;
        end if;
    end process p_w_machine;

end architecture behav;