-- todo: actual dout last

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity throttle is

    generic 
    (
        constant DWIDTH : natural := 16;
        constant DIVIDE_BY : natural range 1 to 65535
    );

    port 
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        bypass : in std_logic;
                
        din : in std_logic_vector(DWIDTH-1 downto 0);
        din_valid : in std_logic;
        din_last : in std_logic;
        din_ready : out std_logic;
        
        dout : out std_logic_vector(DWIDTH-1 downto 0);
        dout_valid : out std_logic;
        dout_last : out std_logic;
        dout_ready : in std_logic
    );

end entity;

architecture rtl of throttle is

    signal samp_rate_counter : natural range 0 to 2047;
    
    signal dout_valid_int : std_logic;
    signal din_ready_int : std_logic;
    signal begin_count : std_logic;

begin

    dout_last <= '0'; -- todo: actual dout last
    dout_valid <= dout_valid_int;
    din_ready <= din_ready_int;

    p_sample_rate_gen : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                samp_rate_counter <= 0;
                dout_valid_int <= '1';
                dout <= (others => '0');
                din_ready_int <= '0';
                begin_count <= '0';
            else
                
                if din_valid = '1' and din_ready_int = '1' then
                    dout <= din;
                    din_ready_int <= '0';
                end if;
                
                if dout_valid_int = '1' and dout_ready = '1' then
                    begin_count <= '1';
                    dout_valid_int <= '0';
                    samp_rate_counter <= samp_rate_counter + 1;
                end if;
                
                if begin_count = '1' then
                    if samp_rate_counter = 0 then
                        dout_valid_int <= '1';
                        
                        samp_rate_counter <= samp_rate_counter + 1;
                    
                    elsif samp_rate_counter = DIVIDE_BY-1 then
                        samp_rate_counter <= 0;
                        din_ready_int <= '1';
                        if dout_valid_int = '1' and dout_ready = '1' then
                            dout_valid_int <= '0';
                        end if;
                        
                    else
                        samp_rate_counter <= samp_rate_counter + 1;
                        if dout_valid_int = '1' and dout_ready = '1' then
                            dout_valid_int <= '0';
                        end if;
                        
                    end if;
                end if;
            end if;
        end if;
    end process;


end rtl;















