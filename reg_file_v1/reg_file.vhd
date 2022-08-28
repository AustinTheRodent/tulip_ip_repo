library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package reg_file_pkg is

    constant REG_FILE_DATA_WIDTH : integer := 16;
    constant REG_FILE_ADDR_WIDTH : integer := 16;
    constant REG_FILE_MSB_FIRST : integer := 1;

    type reg_t is record
        ENABLE_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        ENABLE_REG_pulse : std_logic;

        CONTROL_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        CONTROL_REG_pulse : std_logic;

        STATUS_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RO

        IIR_A_TAP_MSB : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        IIR_A_TAP_MSB_pulse : std_logic;

        IIR_A_TAP : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        IIR_A_TAP_pulse : std_logic;

        IIR_B_TAP_MSB : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        IIR_B_TAP_MSB_pulse : std_logic;

        IIR_B_TAP : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        IIR_B_TAP_pulse : std_logic;

        ADC_OUTPUT_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RO

        LEDR_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        LEDR_REG_pulse : std_logic;

        HEX0_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX0_REG_pulse : std_logic;

        HEX1_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX1_REG_pulse : std_logic;

        HEX2_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX2_REG_pulse : std_logic;

        HEX3_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX3_REG_pulse : std_logic;

        HEX4_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX4_REG_pulse : std_logic;

        HEX5_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        HEX5_REG_pulse : std_logic;

        IIR_OUTPUT_REG : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RO

        SDRAM_ADDR : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_ADDR_pulse : std_logic;

        SDRAM_WR_DATA : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_WR_DATA_pulse : std_logic;

        SDRAM_RD_DATA : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RO

        SDRAM_BANK_ADDR : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_BANK_ADDR_pulse : std_logic;

        SDRAM_DATA_MASK : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_DATA_MASK_pulse : std_logic;

        SDRAM_ROW_ADDR_STROBE_N : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_ROW_ADDR_STROBE_N_pulse : std_logic;

        SDRAM_COL_ADDR_STROBE_N : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_COL_ADDR_STROBE_N_pulse : std_logic;

        SDRAM_CLK_EN : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_CLK_EN_pulse : std_logic;

        SDRAM_CLK : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_CLK_pulse : std_logic;

        SDRAM_WR_EN_N : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_WR_EN_N_pulse : std_logic;

        SDRAM_CS_N : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0); -- RW
        SDRAM_CS_N_pulse : std_logic;

    end record;

    type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;

entity reg_file is
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        
        transaction_en : in std_logic;
        rw : in std_logic; -- '0' = read, '1' = write
        rw_ready : out std_logic;
        
        reg_cs : in std_logic;
        reg_spi_clk : in std_logic;
        reg_miso : out std_logic;
        reg_mosi : in std_logic;

        STATUS_REG : in std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        ADC_OUTPUT_REG : in std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        IIR_OUTPUT_REG : in std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        SDRAM_RD_DATA : in std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);

        reg_out : out reg_t        

    );
end entity;

architecture rtl of reg_file is

    component spi_slave is
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
    end component;
    
    constant ENABLE_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 0;
    constant CONTROL_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 1;
    constant STATUS_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 2;
    constant IIR_A_TAP_MSB_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 3;
    constant IIR_A_TAP_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 4;
    constant IIR_B_TAP_MSB_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 5;
    constant IIR_B_TAP_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 6;
    constant ADC_OUTPUT_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 7;
    constant LEDR_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 8;
    constant HEX0_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 10;
    constant HEX1_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 11;
    constant HEX2_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 12;
    constant HEX3_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 13;
    constant HEX4_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 14;
    constant HEX5_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 15;
    constant IIR_OUTPUT_REG_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 16;
    constant SDRAM_ADDR_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 17;
    constant SDRAM_WR_DATA_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 18;
    constant SDRAM_RD_DATA_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 19;
    constant SDRAM_BANK_ADDR_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 20;
    constant SDRAM_DATA_MASK_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 21;
    constant SDRAM_ROW_ADDR_STROBE_N_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 22;
    constant SDRAM_COL_ADDR_STROBE_N_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 23;
    constant SDRAM_CLK_EN_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 24;
    constant SDRAM_CLK_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 25;
    constant SDRAM_WR_EN_N_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 26;
    constant SDRAM_CS_N_addr : integer range 0 to 2**REG_FILE_ADDR_WIDTH-1 := 27;

    signal transaction_state : transaction_state_t;
    signal reg_int : reg_t;

    signal rw_ready_int : std_logic;
    signal address : integer range -1 to 2**REG_FILE_ADDR_WIDTH-1;

    signal spi_slv_dout : std_logic_vector(REG_FILE_ADDR_WIDTH-1 downto 0);
    signal spi_slv_dout_valid : std_logic;
    signal spi_slv_din_valid : std_logic;
    signal spi_slv_din_ready : std_logic;
    signal spi_slv_din : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);

    signal transaction_en_cross_0 : std_logic;
    signal transaction_en_cross_1 : std_logic;
    signal rw_cross_0 : std_logic;
    signal rw_cross_1 : std_logic;

begin

    p_domain_cross : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                transaction_en_cross_0 <= '0';
                transaction_en_cross_1 <= '0';
                
                rw_cross_0 <= '0';
                rw_cross_1 <= '0';
            else
                transaction_en_cross_0 <= transaction_en;
                transaction_en_cross_1 <= transaction_en_cross_0;
                
                rw_cross_0 <= rw;
                rw_cross_1 <= rw_cross_0;
            end if;
        end if;
    end process;
    
    reg_out <= reg_int;
    rw_ready <= rw_ready_int;

    spi_slv_din <=
        reg_int.ENABLE_REG when address = ENABLE_REG_addr else
        reg_int.CONTROL_REG when address = CONTROL_REG_addr else
        reg_int.STATUS_REG when address = STATUS_REG_addr else
        reg_int.IIR_A_TAP_MSB when address = IIR_A_TAP_MSB_addr else
        reg_int.IIR_A_TAP when address = IIR_A_TAP_addr else
        reg_int.IIR_B_TAP_MSB when address = IIR_B_TAP_MSB_addr else
        reg_int.IIR_B_TAP when address = IIR_B_TAP_addr else
        reg_int.ADC_OUTPUT_REG when address = ADC_OUTPUT_REG_addr else
        reg_int.LEDR_REG when address = LEDR_REG_addr else
        reg_int.HEX0_REG when address = HEX0_REG_addr else
        reg_int.HEX1_REG when address = HEX1_REG_addr else
        reg_int.HEX2_REG when address = HEX2_REG_addr else
        reg_int.HEX3_REG when address = HEX3_REG_addr else
        reg_int.HEX4_REG when address = HEX4_REG_addr else
        reg_int.HEX5_REG when address = HEX5_REG_addr else
        reg_int.IIR_OUTPUT_REG when address = IIR_OUTPUT_REG_addr else
        reg_int.SDRAM_ADDR when address = SDRAM_ADDR_addr else
        reg_int.SDRAM_WR_DATA when address = SDRAM_WR_DATA_addr else
        reg_int.SDRAM_RD_DATA when address = SDRAM_RD_DATA_addr else
        reg_int.SDRAM_BANK_ADDR when address = SDRAM_BANK_ADDR_addr else
        reg_int.SDRAM_DATA_MASK when address = SDRAM_DATA_MASK_addr else
        reg_int.SDRAM_ROW_ADDR_STROBE_N when address = SDRAM_ROW_ADDR_STROBE_N_addr else
        reg_int.SDRAM_COL_ADDR_STROBE_N when address = SDRAM_COL_ADDR_STROBE_N_addr else
        reg_int.SDRAM_CLK_EN when address = SDRAM_CLK_EN_addr else
        reg_int.SDRAM_CLK when address = SDRAM_CLK_addr else
        reg_int.SDRAM_WR_EN_N when address = SDRAM_WR_EN_N_addr else
        reg_int.SDRAM_CS_N when address = SDRAM_CS_N_addr else
        (others => '0');

    p_write_reg : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                reg_int.ENABLE_REG <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.ENABLE_REG_pulse <= '0';
                reg_int.CONTROL_REG <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.CONTROL_REG_pulse <= '0';
                reg_int.IIR_A_TAP_MSB <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.IIR_A_TAP_MSB_pulse <= '0';
                reg_int.IIR_A_TAP <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.IIR_A_TAP_pulse <= '0';
                reg_int.IIR_B_TAP_MSB <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.IIR_B_TAP_MSB_pulse <= '0';
                reg_int.IIR_B_TAP <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.IIR_B_TAP_pulse <= '0';
                reg_int.LEDR_REG <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.LEDR_REG_pulse <= '0';
                reg_int.HEX0_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX0_REG_pulse <= '0';
                reg_int.HEX1_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX1_REG_pulse <= '0';
                reg_int.HEX2_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX2_REG_pulse <= '0';
                reg_int.HEX3_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX3_REG_pulse <= '0';
                reg_int.HEX4_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX4_REG_pulse <= '0';
                reg_int.HEX5_REG <= std_logic_vector(to_unsigned(65535, REG_FILE_DATA_WIDTH));
                reg_int.HEX5_REG_pulse <= '0';
                reg_int.SDRAM_ADDR <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_ADDR_pulse <= '0';
                reg_int.SDRAM_WR_DATA <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_WR_DATA_pulse <= '0';
                reg_int.SDRAM_BANK_ADDR <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_BANK_ADDR_pulse <= '0';
                reg_int.SDRAM_DATA_MASK <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_DATA_MASK_pulse <= '0';
                reg_int.SDRAM_ROW_ADDR_STROBE_N <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_ROW_ADDR_STROBE_N_pulse <= '0';
                reg_int.SDRAM_COL_ADDR_STROBE_N <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_COL_ADDR_STROBE_N_pulse <= '0';
                reg_int.SDRAM_CLK_EN <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_CLK_EN_pulse <= '0';
                reg_int.SDRAM_CLK <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_CLK_pulse <= '0';
                reg_int.SDRAM_WR_EN_N <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_WR_EN_N_pulse <= '0';
                reg_int.SDRAM_CS_N <= std_logic_vector(to_unsigned(0, REG_FILE_DATA_WIDTH));
                reg_int.SDRAM_CS_N_pulse <= '0';

            else
                if transaction_state = write_reg and
                   spi_slv_dout_valid = '1' and
                   rw_cross_1 = '1' and
                   transaction_en_cross_1 = '1' and
                   rw_ready_int = '1' then
                    case (address) is 
                        when ENABLE_REG_addr =>
                            reg_int.ENABLE_REG <= spi_slv_dout;
                            reg_int.ENABLE_REG_pulse <= '1';
                        when CONTROL_REG_addr =>
                            reg_int.CONTROL_REG <= spi_slv_dout;
                            reg_int.CONTROL_REG_pulse <= '1';
                        when IIR_A_TAP_MSB_addr =>
                            reg_int.IIR_A_TAP_MSB <= spi_slv_dout;
                            reg_int.IIR_A_TAP_MSB_pulse <= '1';
                        when IIR_A_TAP_addr =>
                            reg_int.IIR_A_TAP <= spi_slv_dout;
                            reg_int.IIR_A_TAP_pulse <= '1';
                        when IIR_B_TAP_MSB_addr =>
                            reg_int.IIR_B_TAP_MSB <= spi_slv_dout;
                            reg_int.IIR_B_TAP_MSB_pulse <= '1';
                        when IIR_B_TAP_addr =>
                            reg_int.IIR_B_TAP <= spi_slv_dout;
                            reg_int.IIR_B_TAP_pulse <= '1';
                        when LEDR_REG_addr =>
                            reg_int.LEDR_REG <= spi_slv_dout;
                            reg_int.LEDR_REG_pulse <= '1';
                        when HEX0_REG_addr =>
                            reg_int.HEX0_REG <= spi_slv_dout;
                            reg_int.HEX0_REG_pulse <= '1';
                        when HEX1_REG_addr =>
                            reg_int.HEX1_REG <= spi_slv_dout;
                            reg_int.HEX1_REG_pulse <= '1';
                        when HEX2_REG_addr =>
                            reg_int.HEX2_REG <= spi_slv_dout;
                            reg_int.HEX2_REG_pulse <= '1';
                        when HEX3_REG_addr =>
                            reg_int.HEX3_REG <= spi_slv_dout;
                            reg_int.HEX3_REG_pulse <= '1';
                        when HEX4_REG_addr =>
                            reg_int.HEX4_REG <= spi_slv_dout;
                            reg_int.HEX4_REG_pulse <= '1';
                        when HEX5_REG_addr =>
                            reg_int.HEX5_REG <= spi_slv_dout;
                            reg_int.HEX5_REG_pulse <= '1';
                        when SDRAM_ADDR_addr =>
                            reg_int.SDRAM_ADDR <= spi_slv_dout;
                            reg_int.SDRAM_ADDR_pulse <= '1';
                        when SDRAM_WR_DATA_addr =>
                            reg_int.SDRAM_WR_DATA <= spi_slv_dout;
                            reg_int.SDRAM_WR_DATA_pulse <= '1';
                        when SDRAM_BANK_ADDR_addr =>
                            reg_int.SDRAM_BANK_ADDR <= spi_slv_dout;
                            reg_int.SDRAM_BANK_ADDR_pulse <= '1';
                        when SDRAM_DATA_MASK_addr =>
                            reg_int.SDRAM_DATA_MASK <= spi_slv_dout;
                            reg_int.SDRAM_DATA_MASK_pulse <= '1';
                        when SDRAM_ROW_ADDR_STROBE_N_addr =>
                            reg_int.SDRAM_ROW_ADDR_STROBE_N <= spi_slv_dout;
                            reg_int.SDRAM_ROW_ADDR_STROBE_N_pulse <= '1';
                        when SDRAM_COL_ADDR_STROBE_N_addr =>
                            reg_int.SDRAM_COL_ADDR_STROBE_N <= spi_slv_dout;
                            reg_int.SDRAM_COL_ADDR_STROBE_N_pulse <= '1';
                        when SDRAM_CLK_EN_addr =>
                            reg_int.SDRAM_CLK_EN <= spi_slv_dout;
                            reg_int.SDRAM_CLK_EN_pulse <= '1';
                        when SDRAM_CLK_addr =>
                            reg_int.SDRAM_CLK <= spi_slv_dout;
                            reg_int.SDRAM_CLK_pulse <= '1';
                        when SDRAM_WR_EN_N_addr =>
                            reg_int.SDRAM_WR_EN_N <= spi_slv_dout;
                            reg_int.SDRAM_WR_EN_N_pulse <= '1';
                        when SDRAM_CS_N_addr =>
                            reg_int.SDRAM_CS_N <= spi_slv_dout;
                            reg_int.SDRAM_CS_N_pulse <= '1';
                        when others =>
                            reg_int.ENABLE_REG <= reg_int.ENABLE_REG;
                            reg_int.CONTROL_REG <= reg_int.CONTROL_REG;
                            reg_int.IIR_A_TAP_MSB <= reg_int.IIR_A_TAP_MSB;
                            reg_int.IIR_A_TAP <= reg_int.IIR_A_TAP;
                            reg_int.IIR_B_TAP_MSB <= reg_int.IIR_B_TAP_MSB;
                            reg_int.IIR_B_TAP <= reg_int.IIR_B_TAP;
                            reg_int.LEDR_REG <= reg_int.LEDR_REG;
                            reg_int.HEX0_REG <= reg_int.HEX0_REG;
                            reg_int.HEX1_REG <= reg_int.HEX1_REG;
                            reg_int.HEX2_REG <= reg_int.HEX2_REG;
                            reg_int.HEX3_REG <= reg_int.HEX3_REG;
                            reg_int.HEX4_REG <= reg_int.HEX4_REG;
                            reg_int.HEX5_REG <= reg_int.HEX5_REG;
                            reg_int.SDRAM_ADDR <= reg_int.SDRAM_ADDR;
                            reg_int.SDRAM_WR_DATA <= reg_int.SDRAM_WR_DATA;
                            reg_int.SDRAM_BANK_ADDR <= reg_int.SDRAM_BANK_ADDR;
                            reg_int.SDRAM_DATA_MASK <= reg_int.SDRAM_DATA_MASK;
                            reg_int.SDRAM_ROW_ADDR_STROBE_N <= reg_int.SDRAM_ROW_ADDR_STROBE_N;
                            reg_int.SDRAM_COL_ADDR_STROBE_N <= reg_int.SDRAM_COL_ADDR_STROBE_N;
                            reg_int.SDRAM_CLK_EN <= reg_int.SDRAM_CLK_EN;
                            reg_int.SDRAM_CLK <= reg_int.SDRAM_CLK;
                            reg_int.SDRAM_WR_EN_N <= reg_int.SDRAM_WR_EN_N;
                            reg_int.SDRAM_CS_N <= reg_int.SDRAM_CS_N;

                    end case;
                else
                    reg_int.ENABLE_REG_pulse <= '0';
                    reg_int.CONTROL_REG_pulse <= '0';
                    reg_int.IIR_A_TAP_MSB_pulse <= '0';
                    reg_int.IIR_A_TAP_pulse <= '0';
                    reg_int.IIR_B_TAP_MSB_pulse <= '0';
                    reg_int.IIR_B_TAP_pulse <= '0';
                    reg_int.LEDR_REG_pulse <= '0';
                    reg_int.HEX0_REG_pulse <= '0';
                    reg_int.HEX1_REG_pulse <= '0';
                    reg_int.HEX2_REG_pulse <= '0';
                    reg_int.HEX3_REG_pulse <= '0';
                    reg_int.HEX4_REG_pulse <= '0';
                    reg_int.HEX5_REG_pulse <= '0';
                    reg_int.SDRAM_ADDR_pulse <= '0';
                    reg_int.SDRAM_WR_DATA_pulse <= '0';
                    reg_int.SDRAM_BANK_ADDR_pulse <= '0';
                    reg_int.SDRAM_DATA_MASK_pulse <= '0';
                    reg_int.SDRAM_ROW_ADDR_STROBE_N_pulse <= '0';
                    reg_int.SDRAM_COL_ADDR_STROBE_N_pulse <= '0';
                    reg_int.SDRAM_CLK_EN_pulse <= '0';
                    reg_int.SDRAM_CLK_pulse <= '0';
                    reg_int.SDRAM_WR_EN_N_pulse <= '0';
                    reg_int.SDRAM_CS_N_pulse <= '0';

                end if;
            end if;
        end if;
    end process;

    reg_int.STATUS_REG <= STATUS_REG;
    reg_int.ADC_OUTPUT_REG <= ADC_OUTPUT_REG;
    reg_int.IIR_OUTPUT_REG <= IIR_OUTPUT_REG;
    reg_int.SDRAM_RD_DATA <= SDRAM_RD_DATA;

    p_transaction_sm : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                transaction_state <= get_addr;
                rw_ready_int <= '0';
                spi_slv_din_valid <= '0';
                address <= -1;
            else
                case(transaction_state) is 
                    when get_addr =>
                        rw_ready_int <= '0';
                        if spi_slv_dout_valid = '1' then
                            address <= to_integer(unsigned(spi_slv_dout));
                            transaction_state <= load_reg;
                            spi_slv_din_valid <= '1';
                        end if;
                        
                    when load_reg =>
                        if spi_slv_din_ready = '1' then
                            spi_slv_din_valid <= '0';
                            if rw_cross_1 = '1' then
                                transaction_state <= write_reg;
                            else
                                transaction_state <= read_reg;
                            end if; 
                        end if;
                        
                    when write_reg =>
                        rw_ready_int <= '1';
                        if spi_slv_dout_valid = '1' then
                            transaction_state <= get_addr;
                        end if;
                        
                    when read_reg =>
                        rw_ready_int <= '1';
                        if spi_slv_dout_valid = '1' then
                            transaction_state <= get_addr;
                        end if;
                            
                    when others =>
                        transaction_state <= get_addr;
                        
                end case;
                
                if transaction_en_cross_1 = '0' then
                    transaction_state <= get_addr;
                end if;
                
            end if;
        end if;
    end process;

    u_spi_slave : spi_slave
        generic map
        (
            DWIDTH => REG_FILE_DATA_WIDTH,
            MSB_FIRST => REG_FILE_MSB_FIRST
        )
        port map
        (
            clk => clk,
            reset => reset,
            enable => '1',
            
            chip_select => reg_cs,
            spi_clk => reg_spi_clk,
            spi_data_out => reg_miso,
            spi_data_in => reg_mosi,
            
            din => spi_slv_din,
            din_valid => spi_slv_din_valid,
            din_last => '0',
            din_ready => spi_slv_din_ready,
            
            dout => spi_slv_dout,
            dout_valid => spi_slv_dout_valid,
            dout_last => open,
            dout_ready => '1'
        );

end rtl;
