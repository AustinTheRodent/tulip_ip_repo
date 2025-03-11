library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.waveshare_lcd_reg_file_pkg.all;

entity waveshare_lcd_controller is
  generic
  (
    G_SPI_MSB_FIRST   : natural range 0 to 1  := 1 -- 0=LSB_FIRST
  );
  port
  (
    chip_select       : out std_logic;
    dout_user         : out std_logic;
    spi_clk           : out std_logic;
    spi_data_out      : out std_logic;

    lcd_reset         : out std_logic;
    lcd_backlight_pwm : out std_logic;

    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------

    s_axil_aclk       : in  std_logic;
    s_axil_aresetn    : in  std_logic;

    s_axil_awaddr     : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axil_awvalid    : in  std_logic;
    s_axil_awready    : out std_logic;

    s_axil_wdata      : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axil_wstrb      : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axil_wvalid     : in  std_logic;
    s_axil_wready     : out std_logic;

    s_axil_bresp      : out std_logic_vector(1 downto 0);
    s_axil_bvalid     : out std_logic;
    s_axil_bready     : in  std_logic;

    s_axil_araddr     : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axil_arvalid    : in  std_logic;
    s_axil_arready    : out std_logic;

    s_axil_rdata      : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axil_rresp      : out std_logic_vector(1 downto 0);
    s_axil_rvalid     : out std_logic;
    s_axil_rready     : in  std_logic;

    ------------------------------------------------------------------------------------
    ------------------------------------------------------------------------------------

    s_axis_aclk       : in  std_logic;
    s_axis_aresetn    : in  std_logic;
    s_axis_tdata      : in  std_logic_vector(31 downto 0); -- s_axis_tdata <= USER & CHIP_SELECT & DATA
    s_axis_tvalid     : in  std_logic;
    s_axis_tready     : out std_logic;
    s_axis_tlast      : in  std_logic
  );
end entity;

architecture rtl of waveshare_lcd_controller is

  signal s_axis_core_tdata          : std_logic_vector(17 downto 0);

  signal pwm_clk_divider_counter    : unsigned(15 downto 0);
  --signal pwm_counter                : unsigned(15 downto 0);
  signal pwm_counter                : unsigned(7 downto 0);

  signal lcd_backlight_pwm_int      : std_logic;

  signal registers                  : reg_t;

  signal delay_counter              : unsigned(31 downto 0);
  signal gate_dma                   : std_logic;

  signal spi_core_transmission_len  : std_logic_vector(7 downto 0);
  signal spi_core_cs                : std_logic;
  signal spi_core_usr               : std_logic;

  signal s_axis_spi_tdata           : std_logic_vector(17 downto 0);
  signal s_axis_spi_tvalid          : std_logic;
  signal s_axis_spi_tready          : std_logic;
  signal s_axis_spi_tlast           : std_logic;

  signal m_axis_spi_tvalid          : std_logic;
  signal m_axis_spi_tlast           : std_logic;

begin

  p_buffer_pwm : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      lcd_backlight_pwm <= lcd_backlight_pwm_int;
    end if;
  end process;

  lcd_backlight_pwm_int <=
    '0' when registers.WAVESHARE_LCD_CONTROL.SW_RESETN = '0' or s_axil_aresetn = '0' or pwm_counter >= unsigned(registers.PWM_CONTROLLER.ANALOG_VALUE) else
    '1';

  p_delay_counter : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      if s_axil_aresetn = '0' or registers.WAVESHARE_LCD_CONTROL.SW_RESETN = '0' or unsigned(registers.WAVESHARE_SPI_TX_DELAY.DELAY) = 0 then
        delay_counter <= (others => '0');
        gate_dma      <= '1';
      else
        if s_axis_spi_tvalid = '1' and s_axis_spi_tready = '1' then
          gate_dma      <= '0';
        elsif m_axis_spi_tvalid = '1' then
          delay_counter <= delay_counter + 1;
        else
          if delay_counter = unsigned(registers.WAVESHARE_SPI_TX_DELAY.DELAY)-1 then
            delay_counter <= (others => '0');
            gate_dma      <= '1';
          elsif delay_counter > 0 then
            delay_counter <= delay_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  p_pwm : process(s_axil_aclk)
  begin
    if rising_edge(s_axil_aclk) then
      if s_axil_aresetn = '0' or registers.WAVESHARE_LCD_CONTROL.SW_RESETN = '0' then
        pwm_clk_divider_counter <= (others => '0');
        pwm_counter             <= (others => '0');
      else
        if unsigned(registers.PWM_CONTROLLER.CLOCK_DIVIDER) < 2 or pwm_clk_divider_counter >= unsigned(registers.PWM_CONTROLLER.CLOCK_DIVIDER)-1 then
          pwm_clk_divider_counter <= (others => '0');
          pwm_counter             <= pwm_counter + 1;
        else
          pwm_clk_divider_counter <= pwm_clk_divider_counter + 1;
        end if;
      end if;
    end if;
  end process;

  lcd_reset <= registers.WAVESHARE_LCD_CONTROL.SW_RESETN;


  u_waveshare_lcd_reg_file : entity work.waveshare_lcd_reg_file
  port map
  (
    s_axi_aclk    => s_axil_aclk,
    s_axi_aresetn => s_axil_aresetn,

    s_WAVESHARE_LCD_STATUS_SPI_S_VALID      => s_axis_spi_tvalid,
    s_WAVESHARE_LCD_STATUS_SPI_S_VALID_v    => '1',

    s_WAVESHARE_LCD_STATUS_SPI_S_READY      => s_axis_spi_tready,
    s_WAVESHARE_LCD_STATUS_SPI_S_READY_v    => '1',

    s_WAVESHARE_LCD_STATUS_SPI_M_VALID      => m_axis_spi_tvalid,
    s_WAVESHARE_LCD_STATUS_SPI_M_VALID_v    => '1',


    s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST    => s_axis_spi_tlast,
    s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST_v  => registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_S_LAST,

    s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID   => m_axis_spi_tvalid,
    s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID_v => registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_M_VALID,

    s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST    => m_axis_spi_tlast,
    s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST_v  => registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_M_LAST,


    s_axi_awaddr  => s_axil_awaddr,
    s_axi_awvalid => s_axil_awvalid,
    s_axi_awready => s_axil_awready,

    s_axi_wdata   => s_axil_wdata,
    s_axi_wstrb   => s_axil_wstrb,
    s_axi_wvalid  => s_axil_wvalid,
    s_axi_wready  => s_axil_wready,

    s_axi_bresp   => s_axil_bresp,
    s_axi_bvalid  => s_axil_bvalid,
    s_axi_bready  => s_axil_bready,

    s_axi_araddr  => s_axil_araddr,
    s_axi_arvalid => s_axil_arvalid,
    s_axi_arready => s_axil_arready,

    s_axi_rdata   => s_axil_rdata,
    s_axi_rresp   => s_axil_rresp,
    s_axi_rvalid  => s_axil_rvalid,
    s_axi_rready  => s_axil_rready,

    registers_out => registers
  );

  spi_core_transmission_len <=
    registers.WAVESHARE_SPI_TX_LEN.LEN when registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE = '1' else
    x"08"  when unsigned(s_axis_tdata(31 downto 24)) = 0 else
    x"10";

  s_axis_core_tdata(17)           <= '0'    when unsigned(s_axis_tdata(23 downto 16)) = 0 else '1';
  s_axis_core_tdata(16)           <= '1';
  s_axis_core_tdata(15 downto 0)  <= s_axis_tdata(15 downto 0);

  s_axis_spi_tdata <=
    s_axis_core_tdata when registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE = '0' else
    registers.WAVESHARE_LCD_SPI_DATA.DATA;

  s_axis_spi_tvalid <=
    s_axis_tvalid when registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE = '0' and gate_dma = '1' else
    registers.WAVESHARE_LCD_SPI_DATA_wr_pulse;

  s_axis_tready <=
    s_axis_spi_tready when registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE = '0' and gate_dma = '1' else
    '0';

  s_axis_spi_tlast <=
    s_axis_tlast when registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE = '0' else
    '0';

  chip_select <=
    spi_core_cs when registers.WAVESHARE_LCD_CONTROL.MANUAL_CS_USR_MODE = '0' else
    registers.WAVESHARE_SPI_CS_USR.CS;

  dout_user <=
    spi_core_usr when registers.WAVESHARE_LCD_CONTROL.MANUAL_CS_USR_MODE = '0' else
    registers.WAVESHARE_SPI_CS_USR.USR;


  u_spi_master : entity work.spi_master
  generic map
  (
    G_MAX_DWIDTH      => 16,
    G_USER_WIDTH      => 1,
    G_CHIP_SEL_WIDTH  => 1
  )
  port map
  (
    chip_select(0)    => spi_core_cs,--chip_select,
    dout_user(0)      => spi_core_usr,--dout_user,
    spi_clk           => spi_clk,
    spi_data_out      => spi_data_out,
    spi_data_in       => '0',

    data_phase        => registers.WAVESHARE_LCD_CONTROL.DATA_PHASE,
    clk_polarity      => registers.WAVESHARE_LCD_CONTROL.CLK_POL,
    msb_first         => registers.WAVESHARE_LCD_CONTROL.MSB_FIRST,
    cs_back_delay     => registers.WAVESHARE_SPI_CS_BACK_DELAY.DELAY,
    cs_front_delay    => registers.WAVESHARE_SPI_CS_FRONT_DELAY.DELAY,
    spi_divider       => registers.WAVESHARE_SPI_CLK_DIVIDER.DELAY,
    transmission_len  => spi_core_transmission_len,

    s_axis_aclk       => s_axis_aclk,
    s_axis_aresetn    => s_axis_aresetn,
    s_axis_tdata      => s_axis_spi_tdata,
    s_axis_tvalid     => s_axis_spi_tvalid,
    s_axis_tready     => s_axis_spi_tready,
    s_axis_tlast      => s_axis_spi_tlast,

    m_axis_aclk       => s_axis_aclk,
    m_axis_aresetn    => s_axis_aresetn,
    m_axis_tdata      => open,
    m_axis_tvalid     => m_axis_spi_tvalid,
    m_axis_tready     => '1',
    m_axis_tlast      => m_axis_spi_tlast
  );

end rtl;
