library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity delay is
    generic
    (
        constant DWIDTH : natural range 1 to 64
    );
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        bypass : in std_logic;
        
        sample_delay : in std_logic_vector(15 downto 0);
        gain : in std_logic_vector(15 downto 0);
        
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

architecture rtl of delay is

    component simple_dual_port_ram_single_clock is
        generic 
        (
            DATA_WIDTH : natural := 8;
            ADDR_WIDTH : natural := 6
        );
        port 
        (
            clk		: in std_logic;
            raddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
            waddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
            data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
            we		: in std_logic := '1';
            q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
        );
    end component;
    
    constant GAIN_RES : natural := 8; -- [bits]
    constant AWIDTH : natural := 16;
    constant MAX_SAMPLE_DELAY : natural := 2**AWIDTH-1;
    constant MAX_VALUE : integer := 2**(DWIDTH-1)-1;
    constant MIN_VALUE : integer := -2**(DWIDTH-1);
    
    signal din_addr : natural range 0 to MAX_SAMPLE_DELAY;
    signal dout_addr : natural range 0 to MAX_SAMPLE_DELAY;
    signal we : std_logic;
    
    --signal din_scaled : unsigned
    signal gain_int : signed(GAIN_RES downto 0);
    signal delay : std_logic;
    signal buffer_filled : std_logic;
    signal use_buffer : std_logic;
    signal refill_buf : std_logic;
    signal tx_done : std_logic;
    signal sample_delay_corrected : unsigned(15 downto 0);
    
    signal din_ready_int : std_logic;
    signal dout_valid_int : std_logic;
    signal dout_last_int : std_logic;
    signal rom_q : std_logic_vector(DWIDTH-1 downto 0);
    signal dout_buf : std_logic_vector(DWIDTH-1 downto 0);
    signal dout_int : std_logic_vector(DWIDTH-1 downto 0);
    signal delay_output : std_logic_vector(DWIDTH-1 downto 0);
    signal delay_output_scaled : signed(DWIDTH+GAIN_RES downto 0);
    signal delay_input : std_logic_vector(DWIDTH-1 downto 0);
    signal delay_input_clipped : signed(DWIDTH downto 0);
    signal delay_input_clp_sz: signed(DWIDTH-1 downto 0);
    
    signal reset_ram : std_logic;
    signal reset_ram_counter : integer range 0 to 2**AWIDTH;

begin
    
    sample_delay_corrected <= (others => '0') when unsigned(sample_delay) = 0
                              else unsigned(sample_delay) - 1;
    
    dout_addr <= din_addr - to_integer(sample_delay_corrected) when din_addr >= to_integer(sample_delay_corrected)
                 else MAX_SAMPLE_DELAY - (to_integer(sample_delay_corrected) - din_addr);
    
    din_ready <= din_ready_int;
    din_ready_int <= '0' when reset_ram = '1' else
                     dout_ready when tx_done = '0' else 
                     '0';
    
    dout_valid_int <= '0' when reset_ram = '1' else
                      din_valid when tx_done = '0' else 
                      '0';
    
    dout_valid <= dout_valid_int;
    dout_last_int <= din_last;
    dout_last <= dout_last_int;
    
    delay_output <= dout_buf when use_buffer = '1' else rom_q;
    
    gain_int <= signed('0' & gain(GAIN_RES-1 downto 0));
    
    delay_output_scaled <= signed(delay_output)*gain_int;
    
    delay_input_clipped <= to_signed(to_integer(signed(din))+to_integer(delay_output_scaled(GAIN_RES+DWIDTH-1 downto GAIN_RES)), delay_input_clipped'length) when reset_ram = '0' else (others => '0');
    delay_input_clp_sz <= delay_input_clipped(DWIDTH-1 downto 0);
    delay_input <= std_logic_vector(to_signed(MIN_VALUE, DWIDTH)) when to_integer(delay_input_clipped) < MIN_VALUE else
                   std_logic_vector(to_signed(MAX_VALUE, DWIDTH)) when to_integer(delay_input_clipped) > MAX_VALUE else
                   std_logic_vector(delay_input_clp_sz);
    
    dout_int <= delay_input when bypass = '0' else din;
    dout <= dout_int;
    
    we <= din_valid and din_ready_int when reset_ram = '0' else '1';

    p_rom_sync : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                delay <= '0';
                buffer_filled <= '0';
                dout_buf <= (others => '0');
                use_buffer <= '0';
                refill_buf <= '0';
            elsif reset_ram = '0' then
                if delay = '0' then
                    delay <= '1';
                elsif buffer_filled = '0' then 
                    dout_buf <= rom_q;
                    buffer_filled <= '1';
                    use_buffer <= '1';
                elsif use_buffer = '1' and dout_valid_int = '1' and dout_ready = '1' then
                    refill_buf <= '0';
                    dout_buf <= rom_q;
                    use_buffer <= '0';
                elsif use_buffer = '0' and dout_valid_int = '1' and dout_ready = '1' then
                    refill_buf <= '0';
                    dout_buf <= rom_q;
                else
                    if refill_buf = '0' then
                        dout_buf <= rom_q;
                        refill_buf <= '1';
                    end if;
                    use_buffer <= '1';
                end if;
            end if;
        end if;
    end process;

    p_din_addr : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                din_addr <= 0;
                reset_ram <= '1';
                reset_ram_counter <= 0;
            elsif reset_ram = '0' then
                if din_valid = '1' and din_ready_int = '1' then
                    if din_addr = MAX_SAMPLE_DELAY then
                        din_addr <= 0;
                    else
                        din_addr <= din_addr + 1;
                    end if;
                end if;
            else
                if reset_ram_counter = 2**AWIDTH then
                    reset_ram <= '0';
                    din_addr <= 0;
                else
                    reset_ram_counter <= reset_ram_counter + 1;
                    if din_addr /= MAX_SAMPLE_DELAY then
                        din_addr <= din_addr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    p_tx_done : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                tx_done <= '0';
            else
                if din_last = '1' and din_valid = '1' then
                    tx_done <= '1';
                end if;
            end if;
        end if;
    end process;
    
    ram : simple_dual_port_ram_single_clock
        generic map
        (
            DATA_WIDTH => DWIDTH,
            ADDR_WIDTH => AWIDTH
        )
        port map
        (
            clk => clk,
            raddr => dout_addr,
            waddr => din_addr,
            data => delay_input,
            we => we,
            q => rom_q
        );

end rtl;