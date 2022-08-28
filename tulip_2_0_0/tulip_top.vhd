library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;

-- Entity definition
entity tulip_top is
	port
  (
    CLOCK_50                : in    std_logic;
    reset                   : in    std_logic;
    HEX0                    : out   std_logic_vector(7 downto 0);
    HEX1                    : out   std_logic_vector(7 downto 0);
    HEX2                    : out   std_logic_vector(7 downto 0);
    HEX3                    : out   std_logic_vector(7 downto 0);
    HEX4                    : out   std_logic_vector(7 downto 0);
    HEX5                    : out   std_logic_vector(7 downto 0);
    IN_GPIO                 : in    std_logic_vector(33 downto 18);
    OUT_GPIO                : out   std_logic_vector(10 downto 0);
    LEDR                    : out   std_logic_vector(9 downto 0);

    SDRAM_ADDR              : out   std_logic_vector(12 downto 0);
    SDRAM_DATA              : inout std_logic_vector(15 downto 0);
    SDRAM_BANK_ADDR         : out   std_logic_vector(1 downto 0);
    SDRAM_UDQM              : out   std_logic;
    SDRAM_LDQM              : out   std_logic;
    SDRAM_ROW_ADDR_STROBE_N : out   std_logic;
    SDRAM_COL_ADDR_STROBE_N : out   std_logic;
    SDRAM_CLK_EN            : out   std_logic;
    SDRAM_CLK               : out   std_logic;
    SDRAM_WR_EN_N           : out   std_logic;
    SDRAM_CS_N              : out   std_logic;

    reg_transaction_en      : in    std_logic;
    reg_rw                  : in    std_logic; -- '0' = read, '1' = write
    reg_rw_ready            : out   std_logic;
    reg_cs                  : in    std_logic;
    reg_spi_clk             : in    std_logic;
    reg_miso                : out   std_logic;
    reg_mosi                : in    std_logic
	);
end entity;

architecture rtl of tulip_top is

  --component spi_master is
  --    generic
  --    (
  --        constant DWIDTH : natural range 1 to 32;
  --        constant MSB_FIRST : natural range 0 to 1; -- 0=LSB_FIRST
  --        constant FPGA_CLK_FREQ : natural range 1000000 to 100000000; -- Hz
  --        constant SPI_CLK_FREQ : natural range 1000 to 10000000 --Hz
  --    );
  --    port
  --    (
  --        clk : in std_logic;
  --        reset : in std_logic;
  --        enable : in std_logic;
  --
  --        chip_select : out std_logic;
  --        spi_clk : out std_logic;
  --        spi_data_out : out std_logic;
  --        spi_data_in : in std_logic;
  --
  --        din : in std_logic_vector(DWIDTH-1 downto 0);
  --        din_valid : in std_logic;
  --        din_last : in std_logic;
  --        din_ready : out std_logic;
  --
  --        dout : out std_logic_vector(DWIDTH-1 downto 0);
  --        dout_valid : out std_logic;
  --        dout_last : out std_logic;
  --        dout_ready : in std_logic
  --    );
  --end component;
  --
  --component iir_filt is
  --    generic
  --    (
  --        constant DWIDTH : integer range 1 to 64;
  --        constant TAP_RES : integer range 16 to 32; -- always signed
  --        constant NUM_TAPS : integer range 1 to 32
  --    );
  --    port
  --    (
  --        clk : in std_logic;
  --        reset : in std_logic;
  --        enable : in std_logic;
  --        bypass : in std_logic;
  --
  --        din : in std_logic_vector(DWIDTH-1 downto 0);
  --        din_valid : in std_logic;
  --        din_ready : out std_logic;
  --        din_last : in std_logic;
  --
  --        dout : out std_logic_vector(DWIDTH-1 downto 0);
  --        dout_valid : out std_logic;
  --        dout_ready : in std_logic;
  --        dout_last : out std_logic;
  --
  --        enable_program_taps : in std_logic;
  --
  --        tap_a_in : in std_logic_vector(TAP_RES downto 0);
  --        tap_a_valid : in std_logic;
  --        tap_a_done : out std_logic;
  --
  --        tap_b_in : in std_logic_vector(TAP_RES downto 0);
  --        tap_b_valid : in std_logic;
  --        tap_b_done : out std_logic
  --    );
  --end component;
  --
  --component throttle is
  --    generic
  --    (
  --        constant DWIDTH : natural := 16;
  --        constant DIVIDE_BY : natural range 1 to 65535
  --    );
  --
  --    port
  --    (
  --        clk : in std_logic;
  --        reset : in std_logic;
  --        enable : in std_logic;
  --        bypass : in std_logic;
  --
  --        din : in std_logic_vector(DWIDTH-1 downto 0);
  --        din_valid : in std_logic;
  --        din_last : in std_logic;
  --        din_ready : out std_logic;
  --
  --        dout : out std_logic_vector(DWIDTH-1 downto 0);
  --        dout_valid : out std_logic;
  --        dout_last : out std_logic;
  --        dout_ready : in std_logic
  --    );
  --end component;
  --
  --component delay is
  --    generic
  --    (
  --        constant DWIDTH : natural range 1 to 64
  --    );
  --    port
  --    (
  --        clk : in std_logic;
  --        reset : in std_logic;
  --        enable : in std_logic;
  --        bypass : in std_logic;
  --
  --        sample_delay : in std_logic_vector(15 downto 0);
  --        gain : in std_logic_vector(15 downto 0);
  --
  --        din : in std_logic_vector(DWIDTH-1 downto 0);
  --        din_valid : in std_logic;
  --        din_last : in std_logic;
  --        din_ready : out std_logic;
  --
  --        dout : out std_logic_vector(DWIDTH-1 downto 0);
  --        dout_valid : out std_logic;
  --        dout_last : out std_logic;
  --        dout_ready : in std_logic
  --    );
  --end component;

  component reg_file is
    port
    (
        clk             : in  std_logic;
        reset           : in  std_logic;

        transaction_en  : in  std_logic;
        rw              : in  std_logic; -- '0' = read, '1' = write
        rw_ready        : out std_logic;

        reg_cs          : in  std_logic;
        reg_spi_clk     : in  std_logic;
        reg_miso        : out std_logic;
        reg_mosi        : in  std_logic;

        STATUS_REG      : in  std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        ADC_OUTPUT_REG  : in  std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        IIR_OUTPUT_REG  : in  std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
        SDRAM_RD_DATA   : in  std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);

        reg_out : out reg_t
    );
  end component;

  constant FPGA_CLK_RATE : natural range 1000000 to 100000000 := 50000000; -- Hz
  constant SAMPLE_RATE : natural range 10000 to 100000000 := 50000; -- Hz

  constant DAC_RES : natural range 1 to 32 := 16;
  constant DAC_MAX : unsigned(DAC_RES-1 downto 0) := (others => '1');

  constant SPI_SAMP_DWIDTH : natural range 1 to 32 := 24;
  constant SPI_SAMP_CLK_GPIO : natural range 0 to 35 := 0;
  constant SPI_SAMP_CS_GPIO : natural range 0 to 35 := 1;
  constant SPI_SAMP_MISO_GPIO : natural range 0 to 35 := 18;
  constant SPI_SAMP_MOSI_GPIO : natural range 0 to 35 := 2;

  constant IIR_TAP_RES : integer range 16 to 32 := 16; -- [bits]
  constant IIR_NUM_TAPS : integer range 1 to 7 := 3; -- [bits]
  constant MAX_IIR_VAL : std_logic_vector(DAC_RES-1 downto 0) := (DAC_RES-1 => '1', others => '0');

  -- register constants and signals:
    --  ENABLE_REG:
    constant IIR_ENABLE : integer := 0;

    -- CONTROL_REG:
    constant IIR_ENABLE_PROGRAM : integer := 0;

    -- STATUS_REG:
    signal STATUS_REG_INT : std_logic_vector(REG_FILE_DATA_WIDTH-1 downto 0);
    constant IIR_TAP_A_DONE : integer := 0;
    constant IIR_TAP_B_DONE : integer := 1;

    signal ledr_int     :  std_logic_vector(9 downto 0);
    type hex_integer_t is array(0 to 5) of integer range -1 to 16;
    type hex_pins_t is array(0 to 5) of std_logic_vector(7 downto 0);
    signal hex_integer  : hex_integer_t;
    signal hex_pins     : hex_pins_t;

  --signal spi_master_din_valid : std_logic;
  --signal spi_master_din_ready : std_logic;
  --signal spi_master_dout_valid : std_logic;
  --signal spi_master_dout_ready : std_logic;
  --signal spi_samp_cs : std_logic;
  --signal spi_samp_clk : std_logic;
  --signal spi_samp_miso : std_logic;
  --signal spi_samp_mosi : std_logic;
  --signal spi_samp_din : std_logic_vector(SPI_SAMP_DWIDTH-1 downto 0);
  --signal spi_samp_dout : std_logic_vector(SPI_SAMP_DWIDTH-1 downto 0);
  --signal spi_samp_integer : integer;
  --
  --signal max_iir_val_integer : integer;
  --signal iir_din : std_logic_vector(DAC_RES-1 downto 0);
  --signal iir_din_valid : std_logic;
  --signal iir_din_ready : std_logic;
  --signal iir_din_last : std_logic;
  --signal iir_dout : std_logic_vector(DAC_RES-1 downto 0);
  --signal iir_dout_valid : std_logic;
  --signal iir_dout_ready : std_logic;
  --signal iir_dout_last : std_logic;
  --signal iir_enable_prog_taps : std_logic;
  --signal iir_tap_a : std_logic_vector(IIR_TAP_RES downto 0);
  ----signal iir_tap_a_valid : std_logic;
  ----signal iir_tap_a_valid_int : std_logic;
  --signal iir_tap_a_done_int : std_logic;
  --signal iir_tap_b : std_logic_vector(IIR_TAP_RES downto 0);
  ----signal iir_tap_b_valid : std_logic;
  ----signal iir_tap_b_valid_int : std_logic;
  --signal iir_tap_b_done_int : std_logic;
  --signal tap_a_counter : integer range 0 to IIR_NUM_TAPS;
  --signal tap_b_counter : integer range 0 to IIR_NUM_TAPS;
  --
  --signal delay_din : std_logic_vector(DAC_RES-1 downto 0);
  --signal delay_din_valid : std_logic;
  --signal delay_din_last : std_logic;
  --signal delay_din_ready : std_logic;
  --signal delay_dout : std_logic_vector(DAC_RES-1 downto 0);
  --signal delay_dout_valid : std_logic;
  --signal delay_dout_last : std_logic;
  --signal delay_dout_ready : std_logic;
  --
  --signal throttle_din : std_logic_vector(DAC_RES-1 downto 0);
  --signal throttle_dout : std_logic_vector(DAC_RES-1 downto 0);
  --signal throttle_din_valid : std_logic;
  --signal throttle_din_ready : std_logic;
  --signal throttle_dout_valid : std_logic;
  --signal throttle_dout_ready : std_logic;

  signal registers              : reg_t;
  signal reg_transaction_en_int : std_logic;
  signal reg_rw_int             : std_logic; -- '0' = read, '1' = write
  signal reg_rw_ready_int       : std_logic;
  signal reg_cs_int             : std_logic;
  signal reg_spi_clk_int        : std_logic;
  signal reg_miso_int           : std_logic;
  signal reg_mosi_int           : std_logic;

begin

    --OUT_GPIO(SPI_SAMP_CS_GPIO) <= spi_samp_cs;
    --OUT_GPIO(SPI_SAMP_CLK_GPIO) <= spi_samp_clk;
    --OUT_GPIO(SPI_SAMP_MOSI_GPIO) <= spi_samp_mosi;
    --spi_samp_miso <= IN_GPIO(SPI_SAMP_MISO_GPIO);

    --spi_samp_integer <= to_integer(unsigned(spi_samp_dout(17 downto 2)));
    --max_iir_val_integer <= to_integer(unsigned(MAX_IIR_VAL));
    --iir_din <= std_logic_vector(to_signed(spi_samp_integer - max_iir_val_integer, DAC_RES));
    --iir_din_valid <= spi_master_dout_valid;
    --spi_master_dout_ready <= iir_din_ready;
    --
    --delay_din <= iir_dout;
    --delay_din_valid <= iir_dout_valid;
    --iir_dout_ready <= delay_din_ready;
    --
    --throttle_din <= delay_dout;
    --throttle_din_valid <= delay_dout_valid;
    --delay_dout_ready <= throttle_din_ready;
    --
    ----spi_samp_din <= x"00" & throttle_dout;
    --spi_samp_din <= std_logic_vector(to_unsigned((to_integer(signed(throttle_dout))+max_iir_val_integer), DAC_RES+8));
    --spi_master_din_valid <= throttle_dout_valid;
    --throttle_dout_ready <= spi_master_din_ready;

    --i_spi_master : spi_master
    --    generic map
    --    (
    --        DWIDTH => SPI_SAMP_DWIDTH,
    --        MSB_FIRST => 1, -- 0=LSB_FIRST
    --        FPGA_CLK_FREQ => FPGA_CLK_RATE, -- Hz
    --        SPI_CLK_FREQ => 2000000 --Hz
    --    )
    --    port map
    --    (
    --        clk => CLOCK_50,
    --        reset => reset,
    --        --enable => registers.ENABLE_REG(IIR_ENABLE),
    --        enable => '1',
    --
    --        chip_select => spi_samp_cs,
    --        spi_clk => spi_samp_clk,
    --        spi_data_out => spi_samp_mosi,
    --        spi_data_in => spi_samp_miso,
    --
    --        din => spi_samp_din,
    --        din_valid => spi_master_din_valid,
    --        din_last => '0',
    --        din_ready => spi_master_din_ready,
    --
    --        dout => spi_samp_dout,
    --        dout_valid => spi_master_dout_valid,
    --        dout_last => open,
    --        dout_ready => spi_master_dout_ready
    --    );

    --iir_tap_a <= registers.IIR_A_TAP_MSB(0) & registers.IIR_A_TAP;
    --iir_tap_b <= registers.IIR_B_TAP_MSB(0) & registers.IIR_B_TAP;
    --iir_enable_prog_taps <= registers.CONTROL_REG(IIR_ENABLE_PROGRAM);
    --
    --i_iir_filt : iir_filt
    --    generic map
    --    (
    --        DWIDTH => DAC_RES,
    --        TAP_RES => IIR_TAP_RES, -- always signed
    --        NUM_TAPS => IIR_NUM_TAPS
    --    )
    --    port map
    --    (
    --        clk => CLOCK_50,
    --        reset => reset,
    --        enable => '1',
    --        bypass => '1',
    --
    --        din => iir_din,
    --        din_valid => iir_din_valid,
    --        din_ready => iir_din_ready,
    --        din_last => '0',
    --
    --        dout => iir_dout,
    --        dout_valid => iir_dout_valid,
    --        dout_ready => iir_dout_ready,
    --        dout_last => open,
    --
    --        enable_program_taps => iir_enable_prog_taps,--registers.CONTROL_REG(IIR_ENABLE_PROGRAM),
    --
    --        tap_a_in => iir_tap_a,
    --        tap_a_valid => registers.IIR_A_TAP_pulse,
    --        tap_a_done => iir_tap_a_done_int,
    --
    --        tap_b_in => iir_tap_b,
    --        tap_b_valid => registers.IIR_B_TAP_pulse,
    --        tap_b_done => iir_tap_b_done_int
    --    );
    --
    ---- todo: add gain block

    --i_delay : delay
    --    generic map
    --    (
    --        DWIDTH => DAC_RES
    --    )
    --    port map
    --    (
    --        clk => CLOCK_50,
    --        reset => reset,
    --        enable => '1',
    --        bypass => '1',
    --
    --        sample_delay => x"61A8",
    --        gain => x"0040",
    --
    --        din => delay_din,
    --        din_valid => delay_din_valid,
    --        din_last => '0',
    --        din_ready => delay_din_ready,
    --
    --        dout => delay_dout,
    --        dout_valid => delay_dout_valid,
    --        dout_last => open,
    --        dout_ready => delay_dout_ready
    --    );
    --
    --i_throttle : throttle
    --    generic map
    --    (
    --        DWIDTH => DAC_RES,
    --        DIVIDE_BY => FPGA_CLK_RATE/SAMPLE_RATE
    --    )
    --    port map
    --    (
    --        clk => CLOCK_50,
    --        reset => reset,
    --        enable => '1',
    --        bypass => '0',
    --
    --        din => throttle_din,
    --        din_valid => throttle_din_valid,
    --        din_last => '0',
    --        din_ready => throttle_din_ready,
    --
    --        dout => throttle_dout,
    --        dout_valid => throttle_dout_valid,
    --        dout_last => open,
    --        dout_ready => throttle_dout_ready
    --    );

----------------------------------------------------------------------
-- register interface

  reg_transaction_en_int  <= reg_transaction_en;
  reg_rw_int              <= reg_rw; -- '0' = read, '1' = write
  reg_rw_ready            <= reg_rw_ready_int;
  reg_cs_int              <= reg_cs;
  reg_spi_clk_int         <= reg_spi_clk;
  reg_miso                <= reg_miso_int;
  reg_mosi_int            <= reg_mosi;


  SDRAM_ADDR              <= registers.SDRAM_ADDR(12 downto 0);
  SDRAM_DATA              <= (others => 'Z') when unsigned(registers.SDRAM_WR_EN_N) = 1 else registers.SDRAM_WR_DATA;
  SDRAM_BANK_ADDR         <= registers.SDRAM_BANK_ADDR(1 downto 0);
  SDRAM_UDQM              <= registers.SDRAM_DATA_MASK(0);
  SDRAM_LDQM              <= registers.SDRAM_DATA_MASK(1);
  SDRAM_ROW_ADDR_STROBE_N <= registers.SDRAM_ROW_ADDR_STROBE_N(0);
  SDRAM_COL_ADDR_STROBE_N <= registers.SDRAM_COL_ADDR_STROBE_N(0);
  SDRAM_CLK_EN            <= registers.SDRAM_CLK_EN(0);
  SDRAM_CLK               <= registers.SDRAM_CLK(0);
  SDRAM_WR_EN_N           <= registers.SDRAM_WR_EN_N(0);
  SDRAM_CS_N              <= registers.SDRAM_CS_N(0);

  --STATUS_REG_INT(IIR_TAP_A_DONE) <= iir_tap_a_done_int;
  --STATUS_REG_INT(IIR_TAP_B_DONE) <= iir_tap_b_done_int;

  --LEDR(9 downto 0) <= registers.LEDR_REG(9 downto 0);
  LEDR(9 downto 0) <= "0000000011";

  hex_integer(0) <= to_integer(unsigned(registers.HEX0_REG(3 downto 0))) when to_integer(unsigned(registers.HEX0_REG)) < 16 else
                    -1 when registers.HEX0_REG = x"FFFE" else
                    16;
  hex_integer(1) <= to_integer(unsigned(registers.HEX1_REG(3 downto 0))) when to_integer(unsigned(registers.HEX1_REG)) < 16 else
                    -1 when registers.HEX1_REG = x"FFFE" else
                    16;
  hex_integer(2) <= to_integer(unsigned(registers.HEX2_REG(3 downto 0))) when to_integer(unsigned(registers.HEX2_REG)) < 16 else
                    -1 when registers.HEX2_REG = x"FFFE" else
                    16;
  hex_integer(3) <= to_integer(unsigned(registers.HEX3_REG(3 downto 0))) when to_integer(unsigned(registers.HEX3_REG)) < 16 else
                    -1 when registers.HEX3_REG = x"FFFE" else
                    16;
  hex_integer(4) <= to_integer(unsigned(registers.HEX4_REG(3 downto 0))) when to_integer(unsigned(registers.HEX4_REG)) < 16 else
                    -1 when registers.HEX4_REG = x"FFFE" else
                    16;
  hex_integer(5) <= to_integer(unsigned(registers.HEX5_REG(3 downto 0))) when to_integer(unsigned(registers.HEX5_REG)) < 16 else
                    -1 when registers.HEX5_REG = x"FFFE" else
                    16;

  HEX0 <= hex_pins(0);
  HEX1 <= hex_pins(1);
  HEX2 <= hex_pins(2);
  HEX3 <= hex_pins(3);
  HEX4 <= hex_pins(4);
  HEX5 <= hex_pins(5);

  p_hex_mux : process(CLOCK_50)
  begin
    if rising_edge(CLOCK_50) then
      if reset = '1' then
        for i in 0 to 5 loop
          hex_pins(i) <= (others => '1');
        end loop;
      else
        for i in 0 to 5 loop
          case (hex_integer(i)) is
            when 0 =>
              hex_pins(i) <= "11000000";
            when 1 =>
              hex_pins(i) <= "11111001";
            when 2 =>
              hex_pins(i) <= "10100100";
            when 3 =>
              hex_pins(i) <= "10110000";
            when 4 =>
              hex_pins(i) <= "10011001";
            when 5 =>
              hex_pins(i) <= "10010010";
            when 6 =>
              hex_pins(i) <= "10000010";
            when 7 =>
              hex_pins(i) <= "11111000";
            when 8 =>
              hex_pins(i) <= "10000000";
            when 9 =>
              hex_pins(i) <= "10010000";
            when 10 =>
              hex_pins(i) <= "10001000";
            when 11 =>
              hex_pins(i) <= "10000011";
            when 12 =>
              hex_pins(i) <= "11000110";
            when 13 =>
              hex_pins(i) <= "10100001";
            when 14 =>
              hex_pins(i) <= "10000110";
            when 15 =>
              hex_pins(i) <= "10001110";
            when 16 =>
              hex_pins(i) <= "11111111";
            when -1 =>
              hex_pins(i) <= "10111111";
            when others =>
              hex_pins(i) <= "11111111";
          end case;
        end loop;
      end if;
    end if;
  end process;

  u_reg_file : reg_file
    port map
    (
      clk             => CLOCK_50,
      reset           => reset,

      transaction_en  => reg_transaction_en_int,
      rw              => reg_rw_int, -- '0' = read, '1' = write
      rw_ready        => reg_rw_ready_int,

      reg_cs          => reg_cs_int,
      reg_spi_clk     => reg_spi_clk_int,
      reg_miso        => reg_miso_int,
      reg_mosi        => reg_mosi_int,

      STATUS_REG      => STATUS_REG_INT,
      ADC_OUTPUT_REG  => (others => '0'),
      IIR_OUTPUT_REG  => (others => '0'),
      SDRAM_RD_DATA   => SDRAM_DATA,

      reg_out         => registers
    );

end rtl;
