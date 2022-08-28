library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_buffer is
    generic
    (
        constant DWIDTH : integer := 8
    );
    port
    (
        clk : in std_logic;
        reset: in std_logic;
        enable : in std_logic;
    
        din : in std_logic_vector(DWIDTH-1 downto 0);
        din_valid : in std_logic;
        din_last : in std_logic;
        din_ready : out std_logic;
        
        dout : out std_logic_vector(DWIDTH-1 downto 0);
        dout_valid : out std_logic;
        dout_last : out std_logic;
        dout_ready : in std_logic
    );
end axis_buffer;

architecture rtl of axis_buffer is

    signal din_ready_int : std_logic;
    signal dout_valid_int : std_logic;
    signal dout_last_int : std_logic;
    
    signal get_buffer : std_logic;
    signal buffered : std_logic;
    signal dout_buffer : std_logic_vector(DWIDTH-1 downto 0);
    

begin
    
    din_ready_int <= dout_ready or get_buffer;
    din_ready <= din_ready_int;
    
    dout_valid_int <= (din_valid or dout_last_int) and buffered;
    dout_valid <= dout_valid_int;
    
    dout <= dout_buffer;
    
    dout_last <= dout_last_int;
    
    p_last : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                dout_last_int <= '0';
            else
                if dout_last_int = '1' and dout_valid_int = '1' and dout_ready = '1' then
                    dout_last_int <= '0';
                elsif din_last = '1' and din_valid = '1' and din_ready_int = '1' then
                    dout_last_int <= '1';
                end if;
            end if;
        end if;
    end process;
    
    p_buffer : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                get_buffer <= '0';
                buffered <= '0';
                dout_buffer <= (others => '0');
            else
                if buffered = '0' and get_buffer = '0' then
                    get_buffer <= '1';
                elsif buffered = '0' and get_buffer = '1' then
                    if din_ready_int = '1' and din_valid = '1' then
                        get_buffer <= '0';
                        buffered <= '1';
                        dout_buffer <= din;
                    end if;
                elsif buffered = '1' then
                    if dout_valid_int = '1' and dout_ready = '1' then
                        dout_buffer <= din;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    
end rtl;