library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
    generic
    (
        constant DWIDTH : natural range 1 to 32;
        constant MSB_FIRST : natural range 0 to 1; -- 0=LSB_FIRST
        constant FPGA_CLK_FREQ : natural range 1000000 to 100000000; -- Hz
        constant SPI_CLK_FREQ : natural range 1000 to 10000000 --Hz
    );
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        
        chip_select : out std_logic;
        spi_clk : out std_logic;
        spi_data_out : out std_logic;
        spi_data_in : in std_logic;
        
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

architecture rtl of spi_master is

    type spi_state_t is (idle, tx_rx, finish, done);
    signal spi_state : spi_state_t;
    
    signal din_reg : std_logic_vector(DWIDTH-1 downto 0);
    signal spi_counter : natural range 0 to 100000;
    constant spi_divider : natural range 0 to 100000 := FPGA_CLK_FREQ/SPI_CLK_FREQ;
    constant spi_divider_half : natural range 0 to 100000 := spi_divider/2;
    signal data_count : natural range 0 to 32;
    signal rx_reg : std_logic_vector(DWIDTH-1 downto 0);
    signal spi_data_in_cross_0 : std_logic;
    signal spi_data_in_cross_1 : std_logic;

    signal din_last_hold : std_logic;

    signal din_ready_int : std_logic;
    signal dout_valid_int : std_logic;

begin
    
    din_ready <= din_ready_int;
    dout_valid <= dout_valid_int;
    
    p_din_cross : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                spi_data_in_cross_1 <= '0';
                spi_data_in_cross_0 <= '0';
            else
                spi_data_in_cross_0 <= spi_data_in;
                spi_data_in_cross_1 <= spi_data_in_cross_0;
            end if;
        end if;
    end process;
    
    p_state_machine : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                spi_state <= idle;
                chip_select <= '1';
                spi_clk <= '0';
                spi_data_out <= '0';
                din_ready_int <= '0';
                dout_valid_int <= '0';
                spi_counter <= 0;
                din_last_hold <= '0';
                din_reg <= (others => '0');
                rx_reg <= (others => '0');
                dout <= (others => '0');
                --dout_last <= '0';
            else
                case spi_state is
                    when idle =>
                        --dout_valid_int <= '0';
                        if dout_valid_int = '1' and dout_ready = '1' then
                            dout_valid_int <= '0';
                        end if;
                        
                        if din_ready_int = '1' and din_valid = '1' then
                            din_ready_int <= '0';
                            din_reg <= din;
                            chip_select <= '0';
                            spi_state <= tx_rx;
                            if din_last = '1' then
                                din_last_hold <= '1';
                            end if;
                        else
                            din_ready_int <= '1';
                            chip_select <= '1';
                        end if;
                        
                    when tx_rx =>
                        if MSB_FIRST = 1 then
                            spi_data_out <= din_reg(DWIDTH-data_count-1);
                        else
                            spi_data_out <= din_reg(data_count);
                        end if;
                        if spi_counter = spi_divider then
                            data_count <= data_count + 1;
                            if data_count = DWIDTH - 1 then
                                spi_state <= finish;
                                dout <= rx_reg;
                            end if;
                            spi_counter <= 0;
                            spi_clk <= '0';
                        elsif spi_counter = spi_divider_half then
                            if MSB_FIRST = 1 then
                                rx_reg(DWIDTH-data_count-1) <= spi_data_in_cross_1;
                            else
                                rx_reg(data_count) <= spi_data_in_cross_1;
                            end if;
                            spi_counter <= spi_counter + 1;
                            spi_clk <= '1';
                        else
                            spi_counter <= spi_counter + 1;
                        end if;
                            
                    when finish =>
                        data_count <= 0;
                        spi_counter <= 0;
                        din_reg <= (others => '0');
                        chip_select <= '1';
    
                        dout_valid_int <= '1';
                        din_ready_int <= '1';

                        if din_last_hold = '1' then
                            spi_state <= done;
                        else
                            spi_state <= idle;
                        end if;



                        --if dout_valid_int = '1' and dout_ready = '1' then
                        --    if din_last_hold = '1' then
                        --        spi_state <= done;
                        --    else
                        --        spi_state <= idle;
                        --    end if;
                        --    rx_reg <= (others => '0');
                        --    dout_valid_int <= '0';
                        --    dout_last <= '0';
                        --else
                        --    if din_last_hold = '1' then
                        --        dout_last <= '1';
                        --    end if;
                        --    dout_valid_int <= '1';
                        --end if;
                        
                    when done =>
                        if din_valid = '1' and din_ready_int = '1' then
                            din_ready_int <= '0';
                        end if;
                        
                        if dout_valid_int = '1' and dout_ready = '1' then
                            dout_valid_int <= '0';
                        end if;
                        
                        spi_state <= done;
                        
                end case;
            end if;
        end if;
    end process;
    
    dout_last <= '1' when din_last_hold = '1' and dout_valid_int = '1' else '0';

end rtl;
















