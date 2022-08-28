-- SPI slave module
-- Notes:
--      CPOL = 0
--      CPHA = 0

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_slave is
    generic
    (
        constant DWIDTH : natural range 1 to 32;
        constant MSB_FIRST : natural range 0 to 1 -- 0=LSB_FIRST
    );
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        
        chip_select : in std_logic;
        spi_clk : in std_logic;
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

architecture rtl of spi_slave is

    type spi_state_t is (idle, tx_rx, finish, done);
    signal spi_state : spi_state_t;
    
    signal chip_select_cross_0 : std_logic;
    signal chip_select_cross_1 : std_logic;
    signal spi_clk_cross_0 : std_logic;
    signal spi_clk_cross_1 : std_logic;
    
    signal din_reg : std_logic_vector(DWIDTH-1 downto 0);
    signal dout_reg : std_logic_vector(DWIDTH-1 downto 0);
    signal spi_clk_rising_edge : std_logic;
    signal bit_counter : natural range 0 to DWIDTH-1;
    
    signal din_ready_int : std_logic;
    signal dout_valid_int : std_logic;
    signal dout_last_int : std_logic;
    signal dout_last_hold : std_logic;
    
    signal dout_valid_hold : std_logic;
    signal din_ready_hold : std_logic;

begin

    din_ready <= din_ready_int;
    dout_valid <= dout_valid_int;
    dout_last <= dout_last_int;

    
    --din_ready_int <= dout_ready when spi_state = finish else '0';
    --dout_valid_int <= din_valid when spi_state = finish else '0';
    
    din_ready_int <= '1' when (spi_state = finish) or (din_ready_hold = '1')else '0';
    dout_valid_int <= '1' when (spi_state = finish) or (dout_valid_hold = '1') else '0';
    
    dout_last_int <= '1' when ((spi_state = finish and din_last = '1') or (dout_last_hold = '1')) and dout_valid_int = '1' else
                     '0'; --din_last;
    
    dout <= dout_reg;

    p_cs_cross : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                chip_select_cross_0 <= '1';
                chip_select_cross_1 <= '1';
                
                spi_clk_cross_1 <= '0';
                spi_clk_cross_0 <= '0';
            else
                chip_select_cross_0 <= chip_select;
                chip_select_cross_1 <= chip_select_cross_0;
                
                spi_clk_cross_0 <= spi_clk;
                spi_clk_cross_1 <= spi_clk_cross_0;
            end if;
        end if;
    end process;

    p_state_machine : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                spi_state <= idle;
                spi_clk_rising_edge <= '0';
                bit_counter <= 0;
                --din_reg <= (others => '0');
                dout_reg <= (others => '0');
                spi_data_out <= '0';
            else
                case (spi_state) is
                    when idle =>
                        if chip_select_cross_1 = '0' then
                            spi_state <= tx_rx;
                            if MSB_FIRST = 1 then
                                spi_data_out <= din_reg(DWIDTH-1);
                            else
                                spi_data_out <= din_reg(0);
                            end if;
                        end if;

                    when tx_rx =>
                        if chip_select_cross_1 = '1' then
                            spi_state <= finish;
                            bit_counter <= 0;
                            spi_clk_rising_edge <= '0';
                            spi_data_out <= '0';
                        end if;

                        if spi_clk_cross_1 = '1' and spi_clk_rising_edge = '0' then
                            spi_clk_rising_edge <= '1';
                            if bit_counter = DWIDTH-1 then
                                bit_counter <= DWIDTH-1;
                            else
                                bit_counter <= bit_counter+1;
                            end if;

                            if MSB_FIRST = 1 then
                                dout_reg(DWIDTH-1 - bit_counter) <= spi_data_in;
                            else
                                dout_reg(bit_counter) <= spi_data_in;
                            end if;
                        elsif spi_clk_cross_1 = '0' then
                            spi_clk_rising_edge <= '0';
                            if MSB_FIRST = 1 then
                                spi_data_out <= din_reg(DWIDTH-1 - bit_counter);
                            else
                                spi_data_out <= din_reg(bit_counter);
                            end if;
                        end if;

                    when finish =>
                        if din_last = '1' then
                            spi_state <= done;
                        else
                            spi_state <= idle;
                        end if;
                        --if din_valid = '1' and din_ready_int = '1' and
                        --   dout_valid_int = '1' and dout_ready = '1' then
                        --
                        --
                        --    din_reg <= din;
                        --end if;

                    when done =>
                        spi_state <= done;

                end case;
            end if;
        end if;
    end process;
    
    p_din_dout_reg : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                dout_valid_hold <= '0';
                din_ready_hold <= '1';
                din_reg <= (others => '0');
            else
                if dout_valid_int = '1' and dout_ready = '1' then
                    dout_valid_hold <= '0';
                elsif spi_state = finish then
                    dout_valid_hold <= '1';
                end if;
                
                if din_valid= '1' and din_ready_int = '1' then
                    din_reg <= din;
                    din_ready_hold <= '0';
                elsif spi_state = finish then
                    din_ready_hold <= '1';
                end if;
            end if;
        end if;
    end process;
    
    p_last : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                dout_last_hold <= '0';
            else
                if din_last = '1' then
                    dout_last_hold <= '1';
                elsif dout_valid_int = '1' and dout_ready = '1' then
                    dout_last_hold <= '0';
                end if;
            end if;
        end if;
    end process;

end rtl;
















