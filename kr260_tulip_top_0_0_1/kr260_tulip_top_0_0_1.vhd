--                                                        ┌───────────────────┐
--                                                        │                   │
--                                                        │         PS        │
--                                                        │                   │
--                                                        └───┬───────────┬───┘
--                                                            ▲           │
--                                                            │           ▼
--                       ┌────────────────┐               ┌───┴──┐     ┌──┴───┐
--            ┌──────┐   │                │   ┌──────┐    │DMA RX│     │DMA TX│
--          ┌─┤DMA TX├◄──┤       PS       ├◄──┤DMA RX├◄┐  └───┬──┘     └──┬───┘
--          │ └──────┘   │                │   └──────┘ │      ▲           │
--          │            └────────────────┘            │      │           ▼
--          │   ┌──────────────────────────────────┐   │   ┌──┴─┐       ┌─┴──┐
--          └──►┼────────┐   ┌─────────────────────┼───┘   │FIFO│       │FIFO│
--              │        │   │                     │       └──┬─┘       └─┬──┘
--              │        │   │                     │          ▲           │
--              │        └──┤│├─────┐              │          │           ▼
-- ┌────┐       │     /├─────┘      └─────►┤\      │    ┌───┐ │  ┌───┐   ┌┴┐  ┌────┐  ┌───┐
-- │ADC ├───────┼───►| │                   │ |─────┼───►┤DSP├─┴──┤_/_├──►┤+├─►┤FIFO├─►┤DAC│
-- └────┘       │     \├──────────────────►┤/      │    └───┘    └───┘   └─┘  └────┘  └───┘
--              │                                  │
--              └──────────────────────────────────┘

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.axil_reg_file_pkg.all;

entity kr260_tulip_top_0_0_1 is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(11 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(11 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    s_axis_dma_aclk     : in  std_logic;
    s_axis_dma_aresetn  : in  std_logic;
    s_axis_dma_tdata    : in  std_logic_vector(63 downto 0);
    s_axis_dma_tvalid   : in  std_logic;
    s_axis_dma_tready   : out std_logic;
    s_axis_dma_tlast    : in  std_logic;

    m_axis_dma_aclk     : in  std_logic;
    m_axis_dma_aresetn  : in  std_logic;
    m_axis_dma_tdata    : out std_logic_vector(63 downto 0);
    m_axis_dma_tvalid   : out std_logic;
    m_axis_dma_tready   : in  std_logic;
    m_axis_dma_tlast    : out std_logic;

    wm8960_i2c_sda        : inout std_logic;
    wm8960_i2c_sda_output : out   std_logic;
    wm8960_i2c_sclk       : out   std_logic;

    s_wawa_adc_aclk       : in  std_logic;
    s_wawa_adc_tdata      : in  std_logic_vector(15 downto 0);
    s_wawa_adc_tvalid     : in  std_logic;
    s_wawa_adc_tready     : out std_logic;

    bclk                  : in  std_logic;
    dac_lrclk             : in  std_logic;
    dac_data              : out std_logic;
    adc_lrclk             : in  std_logic;
    adc_data              : in  std_logic;

    s_axis_adc_aclk       : in  std_logic;
    s_axis_adc_aresetn    : in  std_logic;
    s_axis_adc_tdata      : in  std_logic_vector(63 downto 0);
    s_axis_adc_tvalid     : in  std_logic;
    s_axis_adc_tready     : out std_logic;
    --adc_l                 : in  std_logic_vector(31 downto 0);
    --adc_r                 : in  std_logic_vector(31 downto 0);
    --adc_valid             : in  std_logic;
    --adc_ready             : out std_logic;
    i2s_adc_error         : in  std_logic;
    i2s_sw_resetn_out     : out std_logic

  );
end entity;

architecture rtl of kr260_tulip_top_0_0_1 is

  constant C_ADC_RESOLUTION             : integer := 24;
  constant C_FP_DWIDTH                  : integer := 32;

  signal registers : reg_t;

  signal wm8960_i2c_din_ready           : std_logic_vector(0 downto 0);
  signal wm8960_i2c_dout_valid          : std_logic_vector(0 downto 0);
  signal wm8960_i2c_register_read_data  : std_logic_vector(8 downto 0);
  signal wm8960_i2c_acks                : std_logic_vector(2 downto 0);

  signal i2c_sda_output                 : std_logic;
  signal i2c_sda_input                  : std_logic;
  signal sda_is_output                  : std_logic;

  signal adc_l                          : std_logic_vector(31 downto 0);
  signal adc_r                          : std_logic_vector(31 downto 0);
  signal adc_ls_l                       : std_logic_vector(31 downto 0);
  signal adc_ls_r                       : std_logic_vector(31 downto 0);
  signal adc32_l                        : std_logic_vector(31 downto 0);
  signal adc32_r                        : std_logic_vector(31 downto 0);
  signal adc24_l                        : std_logic_vector((C_ADC_RESOLUTION-1) downto 0);
  signal adc24_r                        : std_logic_vector((C_ADC_RESOLUTION-1) downto 0);
  signal adc_l_buff                     : std_logic_vector(31 downto 0);
  signal adc_r_buff                     : std_logic_vector(31 downto 0);
  signal adc_valid                      : std_logic;

  signal dac_24l                        : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dac_24r                        : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dac_32l                        : std_logic_vector(31 downto 0);
  signal dac_32r                        : std_logic_vector(31 downto 0);
  signal dac_32l_ls                     : std_logic_vector(31 downto 0);
  signal dac_32r_ls                     : std_logic_vector(31 downto 0);
  signal dac_l                          : std_logic_vector(31 downto 0);
  signal dac_r                          : std_logic_vector(31 downto 0);
  signal dac_ready                      : std_logic;

  --signal i2s_adc_error                  : std_logic_vector;
  signal i2s_dac_error                  : std_logic_vector(0 downto 0);

  constant C_I2S_FIFO_AWIDTH            : integer := 3;
  signal i2s_fifo_din                   : std_logic_vector(C_ADC_RESOLUTION*2-1 downto 0);
  signal i2s_fifo_din_valid             : std_logic;
  signal i2s_fifo_din_ready             : std_logic;
  signal i2s_fifo_dout                  : std_logic_vector(C_ADC_RESOLUTION*2-1 downto 0);
  signal i2s_fifo_dout_valid            : std_logic;
  signal i2s_fifo_dout_ready            : std_logic;
  signal i2s_fifo_used                  : std_logic_vector(C_I2S_FIFO_AWIDTH downto 0);
  signal i2s_sw_resetn                  : std_logic;

  constant C_I2S_2_PS_FIFO_AWIDTH       : integer := 9;
  signal i2s_2_ps_fifo_din              : std_logic_vector(2*C_ADC_RESOLUTION-1 downto 0);
  signal i2s_2_ps_fifo_din_valid        : std_logic;
  signal i2s_2_ps_fifo_din_ready        : std_logic;
  signal i2s_2_ps_fifo_dout             : std_logic_vector(2*C_ADC_RESOLUTION-1 downto 0);
  signal i2s_2_ps_fifo_dout24_l         : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal i2s_2_ps_fifo_dout24_r         : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal i2s_2_ps_fifo_dout_l           : std_logic_vector(31 downto 0);
  signal i2s_2_ps_fifo_dout_r           : std_logic_vector(31 downto 0);
  signal i2s_2_ps_fifo_dout_valid       : std_logic;
  signal i2s_2_ps_fifo_dout_ready       : std_logic;
  signal i2s_2_ps_fifo_used             : std_logic_vector(C_I2S_2_PS_FIFO_AWIDTH downto 0);
  signal i2s_2_ps_sw_resetn             : std_logic;

  constant C_PS_2_I2S_FIFO_AWIDTH       : integer := 9;
  signal ps_2_i2s_fifo_din              : std_logic_vector(2*C_ADC_RESOLUTION-1 downto 0);
  signal ps_2_i2s_fifo_din_valid        : std_logic;
  signal ps_2_i2s_fifo_din_ready        : std_logic;
  signal ps_2_i2s_fifo_dout             : std_logic_vector(2*C_ADC_RESOLUTION-1 downto 0);
  signal ps_2_i2s_fifo_dout_l           : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal ps_2_i2s_fifo_dout_r           : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal ps_2_i2s_fifo_dout_valid       : std_logic;
  signal ps_2_i2s_fifo_dout_ready       : std_logic;
  signal ps_2_i2s_fifo_used             : std_logic_vector(C_I2S_2_PS_FIFO_AWIDTH downto 0);
  signal ps_2_i2s_fifo_avail            : std_logic_vector(C_I2S_2_PS_FIFO_AWIDTH downto 0);
  signal ps_2_i2s_sw_resetn             : std_logic;

  signal lut_prog_din_ready             : std_logic_vector(0 downto 0);
  signal lut_prog_din_done              : std_logic_vector(0 downto 0);

  signal usr_fir_taps_prog_din_ready    : std_logic_vector(0 downto 0);
  signal usr_fir_taps_prog_done         : std_logic_vector(0 downto 0);

  signal reverb_taps_prog_din_ready     : std_logic_vector(0 downto 0);
  signal reverb_taps_prog_done          : std_logic_vector(0 downto 0);

  signal vibrato_freq_offset_prog_done   : std_logic_vector(0 downto 0);
  signal vibrato_freq_offset_prog_ready  : std_logic_vector(0 downto 0);
  signal vibrato_freq_deriv_prog_done    : std_logic_vector(0 downto 0);
  signal vibrato_freq_deriv_prog_ready   : std_logic_vector(0 downto 0);
  signal vibrato_chirp_depth_prog_done   : std_logic_vector(0 downto 0);
  signal vibrato_chirp_depth_prog_ready  : std_logic_vector(0 downto 0);
  signal vibrato_gain_prog_done          : std_logic_vector(0 downto 0);
  signal vibrato_gain_prog_ready         : std_logic_vector(0 downto 0);



  signal chorus_lfo_freq_prog_done       : std_logic_vector(0 downto 0);
  signal chorus_lfo_freq_prog_ready      : std_logic_vector(0 downto 0);
  signal chorus_lfo_depth_prog_done      : std_logic_vector(0 downto 0);
  signal chorus_lfo_depth_prog_ready     : std_logic_vector(0 downto 0);
  signal chorus_avg_delay_prog_done      : std_logic_vector(0 downto 0);
  signal chorus_avg_delay_prog_ready     : std_logic_vector(0 downto 0);
  signal chorus_gain_prog_done           : std_logic_vector(0 downto 0);
  signal chorus_gain_prog_ready          : std_logic_vector(0 downto 0);

  signal wawa_prog_b_done                : std_logic_vector(0 downto 0);
  signal wawa_prog_b_ready               : std_logic_vector(0 downto 0);
  signal wawa_prog_a_done                : std_logic_vector(0 downto 0);
  signal wawa_prog_a_ready               : std_logic_vector(0 downto 0);

  signal dsp_l_din                      : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dsp_l_din_valid                : std_logic;
  signal dsp_l_din_ready                : std_logic;
  signal dsp_l_dout                     : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dsp_lm_dout                    : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dsp_l_dout_valid               : std_logic;
  signal dsp_l_dout_ready               : std_logic;
  signal dsp_r_din                      : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dsp_r_din_valid                : std_logic;
  signal dsp_r_din_ready                : std_logic;
  signal dsp_r_dout                     : std_logic_vector(C_ADC_RESOLUTION-1 downto 0);
  signal dsp_r_dout_valid               : std_logic;
  signal dsp_r_dout_ready               : std_logic;
  signal dsp_sw_resetn                  : std_logic;

  signal tick_us                        : std_logic_vector(31 downto 0);
  signal tick_ms                        : std_logic_vector(31 downto 0);

  signal s_wawa_adc_tdata_sub           : unsigned(15 downto 0);
  signal s_wawa_adc_tdata_mult          : unsigned(31 downto 0);
  signal s_wawa_adc_tdata_rs            : unsigned(31 downto 0);
  signal s_wawa_adc_tdata_store         : std_logic_vector(7 downto 0);

begin

  p_wawa_adc : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_wawa_adc_tvalid = '1' then
        s_wawa_adc_tdata_sub <= unsigned(s_wawa_adc_tdata)-unsigned(registers.TULIP_DSP_WAWA_ADC_OFFS.MIN_OFFSET);
      end if;

      s_wawa_adc_tdata_mult   <= s_wawa_adc_tdata_sub * unsigned(registers.TULIP_DSP_WAWA_ADC_OFFS.GAIN);
      s_wawa_adc_tdata_rs     <= shift_right(s_wawa_adc_tdata_mult, 12);
      s_wawa_adc_tdata_store  <= std_logic_vector(resize(s_wawa_adc_tdata_rs, 8));

    end if;
  end process;

  s_wawa_adc_tready <= '1';

  u_reg_file : entity work.axil_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      a_axi_aresetn => s_axi_aresetn,

      s_VERSION_VERSION                           => (others => '0'),
      s_VERSION_VERSION_v                         => '0',

      s_I2C_STATUS_DIN_READY                      => wm8960_i2c_din_ready,
      s_I2C_STATUS_DIN_READY_v                    => '1',

      s_I2C_STATUS_DOUT_VALID                     => wm8960_i2c_dout_valid,
      s_I2C_STATUS_DOUT_VALID_v                   => '1',

      s_I2C_STATUS_ACK_2                          => wm8960_i2c_acks(2 downto 2),
      s_I2C_STATUS_ACK_2_v                        => wm8960_i2c_dout_valid(0),

      s_I2C_STATUS_ACK_1                          => wm8960_i2c_acks(1 downto 1),
      s_I2C_STATUS_ACK_1_v                        => wm8960_i2c_dout_valid(0),

      s_I2C_STATUS_ACK_0                          => wm8960_i2c_acks(0 downto 0),
      s_I2C_STATUS_ACK_0_v                        => wm8960_i2c_dout_valid(0),

      s_I2C_STATUS_REGISTER_RD_DATA               => wm8960_i2c_register_read_data,
      s_I2C_STATUS_REGISTER_RD_DATA_v             => wm8960_i2c_dout_valid(0),

      s_I2S_STATUS_ADC_ERROR(0)                   => i2s_adc_error,
      s_I2S_STATUS_ADC_ERROR_v                    => '1',

      s_I2S_STATUS_DAC_ERROR                      => i2s_dac_error,
      s_I2S_STATUS_DAC_ERROR_v                    => '1',

      s_I2S_FIFO_FIFO_USED                        => std_logic_vector(resize(unsigned(i2s_fifo_used), 16)),
      s_I2S_FIFO_FIFO_USED_v                      => '1',

      s_I2S_2_PS_FIFO_COUNT_FIFO_USED             => std_logic_vector(resize(unsigned(i2s_2_ps_fifo_used), 16)),
      s_I2S_2_PS_FIFO_COUNT_FIFO_USED_v           => '1',

      s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L         => i2s_2_ps_fifo_dout_l,
      s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_v       => '1',

      s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R         => i2s_2_ps_fifo_dout_r,
      s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_v       => '1',

      s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE        => std_logic_vector(resize(unsigned(ps_2_i2s_fifo_avail), 16)),
      s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_v      => '1',

      s_TULIP_DSP_STATUS_LUT_PROG_DONE            => lut_prog_din_done,
      s_TULIP_DSP_STATUS_LUT_PROG_DONE_v          => '1',

      s_TULIP_DSP_STATUS_LUT_PROG_READY           => lut_prog_din_ready,
      s_TULIP_DSP_STATUS_LUT_PROG_READY_v         => '1',

      s_TULIP_DSP_STATUS_FIR_TAP_DONE             => usr_fir_taps_prog_done,
      s_TULIP_DSP_STATUS_FIR_TAP_DONE_v           => '1',

      s_TULIP_DSP_STATUS_FIR_TAP_READY            => usr_fir_taps_prog_din_ready,
      s_TULIP_DSP_STATUS_FIR_TAP_READY_v          => '1',

      s_TULIP_DSP_STATUS_REVERB_PROG_DONE         => reverb_taps_prog_done,
      s_TULIP_DSP_STATUS_REVERB_PROG_DONE_v       => '1',

      s_TULIP_DSP_STATUS_REVERB_PROG_READY        => reverb_taps_prog_din_ready,
      s_TULIP_DSP_STATUS_REVERB_PROG_READY_v      => '1',

      s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE    => vibrato_freq_offset_prog_done,
      s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE_v  => '1',

      s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY   => vibrato_freq_offset_prog_ready,
      s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY_v => '1',

      s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE     => vibrato_freq_deriv_prog_done,
      s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE_v   => '1',

      s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY    => vibrato_freq_deriv_prog_ready,
      s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY_v  => '1',

      s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE    => vibrato_chirp_depth_prog_done,
      s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE_v  => '1',

      s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY   => vibrato_chirp_depth_prog_ready,
      s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY_v => '1',

      s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE           => vibrato_gain_prog_done,
      s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE_v         => '1',

      s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY          => vibrato_gain_prog_ready,
      s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY_v        => '1',

      s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE        => chorus_lfo_freq_prog_done,
      s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE_v      => '1',

      s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY       => chorus_lfo_freq_prog_ready,
      s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY_v     => '1',

      s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE       => chorus_lfo_depth_prog_done,
      s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE_v     => '1',

      s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY      => chorus_lfo_depth_prog_ready,
      s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY_v    => '1',

      s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE       => chorus_avg_delay_prog_done,
      s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE_v     => '1',

      s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY      => chorus_avg_delay_prog_ready,
      s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY_v    => '1',

      s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE            => chorus_gain_prog_done,
      s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE_v          => '1',

      s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY           => chorus_gain_prog_ready,
      s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY_v         => '1',

      s_TULIP_DSP_STATUS_WAWA_PROG_A_READY                => wawa_prog_a_ready,
      s_TULIP_DSP_STATUS_WAWA_PROG_A_READY_v              => '1',

      s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE                 => wawa_prog_a_done,
      s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE_v               => '1',

      s_TULIP_DSP_STATUS_WAWA_PROG_B_READY                => wawa_prog_b_ready,
      s_TULIP_DSP_STATUS_WAWA_PROG_B_READY_v              => '1',

      s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE                 => wawa_prog_b_done,
      s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE_v               => '1',

      s_COUNTER_US_TICK_US    => tick_us,
      s_COUNTER_US_TICK_US_v  => '1',

      s_COUNTER_MS_TICK_MS    => tick_ms,
      s_COUNTER_MS_TICK_MS_v  => '1',

      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,

      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,

      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,

      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,

      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,

      registers_out => registers
    );

  p_tick_us : process(s_axi_aclk)
    variable v_counter : unsigned(7 downto 0);
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        tick_us   <= (others => '0');
        v_counter := (others => '0');
      else
        if registers.COUNTER_RESETS_REG_wr_pulse = '1' and registers.COUNTER_RESETS.RESET_US(0) = '1' then
          tick_us   <= (others => '0');
          v_counter := (others => '0');
        else
          if v_counter >= to_unsigned(199, v_counter'length) then
            tick_us   <= std_logic_vector(unsigned(tick_us)+1);
            v_counter := (others => '0');
          else
            v_counter := v_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  p_tick_ms : process(s_axi_aclk)
    variable v_counter : unsigned(17 downto 0);
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        tick_ms   <= (others => '0');
        v_counter := (others => '0');
      else
        if registers.COUNTER_RESETS_REG_wr_pulse = '1' and registers.COUNTER_RESETS.RESET_MS(0) = '1' then
          tick_ms   <= (others => '0');
          v_counter := (others => '0');
        else
          if v_counter >= to_unsigned(199999, v_counter'length) then
            tick_ms   <= std_logic_vector(unsigned(tick_ms)+1);
            v_counter := (others => '0');
          else
            v_counter := v_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  IOBUF_i2c : IOBUF
    generic map
    (
      DRIVE       => 12,
      IOSTANDARD  => "DEFAULT",
      SLEW        => "SLOW"
    )
    port map
    (
      O           => i2c_sda_input,       -- Buffer output
      IO          => wm8960_i2c_sda,      -- Buffer inout port (connect directly to top-level port)
      I           => i2c_sda_output,      -- Buffer input
      T           => (not sda_is_output)  -- 3-state enable input, high=input, low=output
    );

  wm8960_i2c_sda_output <= i2c_sda_output;

  u_wm8960_i2c : entity work.wm8960_i2c
    generic map
    (
      G_CLK_DIVIDER         => 1000
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => (not s_axi_aresetn),
      enable                => std_logic(registers.CONTROL.SW_RESETN(0)),

      din_device_address    => registers.I2C_CONTROL.DEVICE_ADDRESS,
      din_rd_wr             => std_logic(registers.I2C_CONTROL.I2C_IS_READ(0)),
      din_register_address  => registers.I2C_CONTROL.REGISTER_ADDRESS,
      din_register_data     => registers.I2C_CONTROL.REGISTER_WR_DATA,
      din_valid             => registers.I2C_CONTROL_REG_wr_pulse,
      din_ready             => wm8960_i2c_din_ready(0),

      i2c_sda_output        => i2c_sda_output,
      i2c_sda_input         => i2c_sda_input,
      sda_is_output         => sda_is_output,
      i2c_sclk              => wm8960_i2c_sclk,

      dout_register_data    => wm8960_i2c_register_read_data,
      dout_acks_received    => wm8960_i2c_acks,
      dout_valid            => wm8960_i2c_dout_valid(0),
      dout_ready            => '1'
    );

  i2s_sw_resetn <= std_logic(registers.CONTROL.SW_RESETN(0)) and std_logic(registers.CONTROL.I2S_ENABLE(0));
  i2s_sw_resetn_out <= i2s_sw_resetn;

--  u_i2s_to_parallel : entity work.i2s_to_parallel
--    generic map
--    (
--      G_NUM_POSEDGE => 3, -- used for debounce filter
--      G_DWIDTH      => 32,
--      G_LSB_FIRST   => false
--    )
--    port map
--    (
--      clk           => s_axi_aclk,
--      reset         => (not s_axi_aresetn),
--      enable        => i2s_sw_resetn,
--
--      error         => i2s_adc_error,
--
--      bclk          => bclk,
--      lrclk         => adc_lrclk,
--      serial_din    => adc_data,
--
--      dout_left     => adc_l,
--      dout_right    => adc_r,
--      dout_valid    => adc_valid,
--      dout_ready    => '1'
--    );

  adc_l             <= s_axis_adc_tdata(63 downto 32);
  adc_r             <= s_axis_adc_tdata(31 downto  0);
  adc_valid         <= s_axis_adc_tvalid;
  s_axis_adc_tready <= dsp_l_din_ready;

--  adc_ls_l            <= std_logic_vector(shift_left(unsigned(adc_l), 1));
--  adc_ls_r            <= std_logic_vector(shift_left(unsigned(adc_r), 1));
--
--  adc32_l             <= std_logic_vector(shift_right(signed(adc_ls_l), 8));
--  adc32_r             <= std_logic_vector(shift_right(signed(adc_ls_r), 8));

  adc24_l             <= adc_l(adc24_l'range);
  adc24_r             <= adc_r(adc24_r'range);

  dsp_sw_resetn <= std_logic(registers.CONTROL.SW_RESETN(0)) and std_logic(registers.CONTROL.DSP_ENABLE(0));

  --polynomial_taps_prog_din        <= x"3F800000";
  --polynomial_taps_prog_din_valid  <= '1';

  dsp_l_din <= adc24_l;
  dsp_r_din <= adc24_r;

  dsp_l_din_valid <= adc_valid;
  dsp_r_din_valid <= adc_valid;

  u_tulip_dsp : entity work.tulip_dsp
    port map
    (
      clk                                 => s_axi_aclk,
      reset                               => (not s_axi_aresetn),
      global_sw_resetn                    => dsp_sw_resetn,

      lut_tf_sw_resetn                    => registers.TULIP_DSP_CONTROL.SW_RESETN_LUT_TF(0),
      usr_fir_sw_resetn                   => registers.TULIP_DSP_CONTROL.SW_RESETN_USR_FIR(0),
      reverb_sw_resetn                    => registers.TULIP_DSP_CONTROL.SW_RESETN_REVERB(0),
      tremelo_sw_resetn                   => registers.TULIP_DSP_CONTROL.SW_RESETN_TREMELO(0),
      wawa_sw_resetn                      => registers.TULIP_DSP_CONTROL.SW_RESETN_WAWA(0),
      vibrato_sw_resetn                   => registers.TULIP_DSP_CONTROL.SW_RESETN_VIBRATO(0),
      chorus_sw_resetn                    => registers.TULIP_DSP_CONTROL.SW_RESETN_CHORUS(0),

      bypass                              => registers.TULIP_DSP_CONTROL.BYPASS(0),
      bypass_chorus                       => registers.TULIP_DSP_CONTROL.BYPASS_CHORUS(0),
      bypass_tremelo                      => registers.TULIP_DSP_CONTROL.BYPASS_TREMELO(0),
      bypass_wawa                         => registers.TULIP_DSP_CONTROL.BYPASS_WAWA(0),
      bypass_vibrato                      => registers.TULIP_DSP_CONTROL.BYPASS_VIBRATO(0),
      bypass_reverb                       => registers.TULIP_DSP_CONTROL.BYPASS_REVERB(0),
      bypass_lut_tf                       => registers.TULIP_DSP_CONTROL.BYPASS_LUT_TF(0),
      bypass_usr_fir                      => registers.TULIP_DSP_CONTROL.BYPASS_USR_FIR(0),

      input_gain                          => registers.TULIP_DSP_INPUT_GAIN.INTEGER_BITS & registers.TULIP_DSP_INPUT_GAIN.DECIMAL_BITS,
      output_gain                         => registers.TULIP_DSP_OUTPUT_GAIN.INTEGER_BITS & registers.TULIP_DSP_OUTPUT_GAIN.DECIMAL_BITS,

      symmetric_mode                      =>registers.TULIP_DSP_CONTROL.SYMMETRIC_MODE(0),

      lut_prog_din                        => registers.TULIP_DSP_LUT_PROG.LUT_PROG_VAL,
      lut_prog_din_valid                  => registers.TULIP_DSP_LUT_PROG_REG_wr_pulse,
      lut_prog_din_ready                  => lut_prog_din_ready(0),
      lut_prog_din_done                   => lut_prog_din_done(0),

      usr_fir_taps_prog_din               => registers.TULIP_DSP_USR_FIR_PROG.FIR_TAP_VALUE,
      usr_fir_taps_prog_din_valid         => registers.TULIP_DSP_USR_FIR_PROG_REG_wr_pulse,
      usr_fir_taps_prog_din_ready         => usr_fir_taps_prog_din_ready(0),
      usr_fir_taps_prog_done              => usr_fir_taps_prog_done(0),

      reverb_feedback_right_shift         => registers.TULIP_DSP_REVERB_SCALE.FEEDBACK_RIGHT_SHIFT,
      reverb_feedback_gain                => registers.TULIP_DSP_REVERB_SCALE.FEEDBACK_GAIN,
      reverb_feedforward_gain             => registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN.FEEDFORWARD_GAIN,

      reverb_taps_prog_din                => registers.TULIP_DSP_REVERB_PROG.REVERB_TAP_VALUE,
      reverb_taps_prog_din_valid          => registers.TULIP_DSP_REVERB_PROG_REG_wr_pulse,
      reverb_taps_prog_din_ready          => reverb_taps_prog_din_ready(0),
      reverb_taps_prog_done               => reverb_taps_prog_done(0),

      tremelo_rate                        => registers.TULIP_DSP_TREMELO_RATE.RATE,
      tremelo_depth                       => registers.TULIP_DSP_TREMELO_DEPTH.DEPTH,

      prog_wawa_b_tap_tdata               => registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB.DATA & registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB.DATA,                -- [63:0]
      prog_wawa_b_tap_tvalid              => registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse,
      prog_wawa_b_tap_tready              => wawa_prog_b_ready(0),
      prog_wawa_b_done                    => wawa_prog_b_done(0),

      prog_wawa_a_tap_tdata               => registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB.DATA & registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB.DATA,                -- [63:0]
      prog_wawa_a_tap_tvalid              => registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse,
      prog_wawa_a_tap_tready              => wawa_prog_a_ready(0),
      prog_wawa_a_done                    => wawa_prog_a_done(0),

      wawa_input                          => s_wawa_adc_tdata_store, -- [7:0]

      prog_vibrato_gain_din               => registers.TULIP_DSP_VIBRATO_GAIN.GAIN,
      prog_vibrato_gain_din_valid         => registers.TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse,
      prog_vibrato_gain_din_ready         => vibrato_gain_prog_ready,
      prog_vibrato_gain_din_done          => vibrato_gain_prog_done,

      prog_vibrato_chirp_depth_din        => registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH.CHIRP_DEPTH,
      prog_vibrato_chirp_depth_din_valid  => registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse,
      prog_vibrato_chirp_depth_din_ready  => vibrato_chirp_depth_prog_ready,
      prog_vibrato_chirp_depth_din_done   => vibrato_chirp_depth_prog_done,

      prog_vibrato_freq_deriv_din         => registers.TULIP_DSP_VIBRATO_FREQ_DERIV.FREQ_DERIV,
      prog_vibrato_freq_deriv_din_valid   => registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse,
      prog_vibrato_freq_deriv_din_ready   => vibrato_freq_deriv_prog_ready,
      prog_vibrato_freq_deriv_din_done    => vibrato_freq_deriv_prog_done,

      prog_vibrato_freq_offset_din        => registers.TULIP_DSP_VIBRATO_FREQ_OFFSET.FREQ_OFFSET,
      prog_vibrato_freq_offset_din_valid  => registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse,
      prog_vibrato_freq_offset_din_ready  => vibrato_freq_offset_prog_ready,
      prog_vibrato_freq_offset_din_done   => vibrato_freq_offset_prog_done,

      prog_chorus_gain_din                => registers.TULIP_DSP_CHORUS_GAIN.GAIN,
      prog_chorus_gain_din_valid          => registers.TULIP_DSP_CHORUS_GAIN_REG_wr_pulse,
      prog_chorus_gain_din_ready          => chorus_gain_prog_ready,
      prog_chorus_gain_din_done           => chorus_gain_prog_done,

      prog_chorus_avg_delay_din           => registers.TULIP_DSP_CHORUS_AVG_DELAY.AVG_DELAY,
      prog_chorus_avg_delay_din_valid     => registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse,
      prog_chorus_avg_delay_din_ready     => chorus_avg_delay_prog_ready,
      prog_chorus_avg_delay_din_done      => chorus_avg_delay_prog_done,

      prog_chorus_lfo_depth_din           => registers.TULIP_DSP_CHORUS_LFO_DEPTH.LFO_DEPTH,
      prog_chorus_lfo_depth_din_valid     => registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse,
      prog_chorus_lfo_depth_din_ready     => chorus_lfo_depth_prog_ready,
      prog_chorus_lfo_depth_din_done      => chorus_lfo_depth_prog_done,

      prog_chorus_lfo_freq_din            => registers.TULIP_DSP_CHORUS_LFO_FREQ.LFO_FREQ,
      prog_chorus_lfo_freq_din_valid      => registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse,
      prog_chorus_lfo_freq_din_ready      => chorus_lfo_freq_prog_ready,
      prog_chorus_lfo_freq_din_done       => chorus_lfo_freq_prog_done,

      din                                 => dsp_l_din,
      din_valid                           => dsp_l_din_valid,
      din_ready                           => dsp_l_din_ready,

      dout                                => dsp_l_dout,
      dout_valid                          => dsp_l_dout_valid,
      dout_ready                          => dsp_l_dout_ready
    );

  dsp_lm_dout <= (others => '0') when registers.CONTROL.DSP_MUTE(0) = '1' else dsp_l_dout;

  i2s_fifo_din <=
    dsp_lm_dout & dsp_lm_dout when ps_2_i2s_fifo_dout_valid = '0' else
    std_logic_vector(signed(dsp_lm_dout)+signed(ps_2_i2s_fifo_dout_l)) & std_logic_vector(signed(dsp_lm_dout)+signed(ps_2_i2s_fifo_dout_r));

  i2s_fifo_din_valid  <= dsp_l_dout_valid;
  dsp_l_dout_ready    <= i2s_fifo_din_ready;
  --dsp_r_dout_ready    <= i2s_fifo_din_ready;

  u_i2s_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => C_I2S_FIFO_AWIDTH,
      G_DATA_WIDTH    => 2*C_ADC_RESOLUTION,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => i2s_sw_resetn,

      din             => i2s_fifo_din,
      din_valid       => i2s_fifo_din_valid,
      din_ready       => i2s_fifo_din_ready,
      din_last        => '0',

      used            => i2s_fifo_used,

      dout            => i2s_fifo_dout,
      dout_valid      => i2s_fifo_dout_valid,
      dout_ready      => i2s_fifo_dout_ready,
      dout_last       => open
    );

  dac_24l              <= i2s_fifo_dout(C_ADC_RESOLUTION*2-1 downto C_ADC_RESOLUTION);
  dac_24r              <= i2s_fifo_dout(C_ADC_RESOLUTION-1 downto 0);

  dac_32l              <= std_logic_vector(resize(signed(dac_24l), 32));
  dac_32r              <= std_logic_vector(resize(signed(dac_24r), 32));

  dac_32l_ls           <= std_logic_vector(shift_left(signed(dac_32l), 8));
  dac_32r_ls           <= std_logic_vector(shift_left(signed(dac_32r), 8));

  dac_l                <= '0' & dac_32l_ls(dac_32l_ls'left-1 downto 0);
  dac_r                <= '0' & dac_32r_ls(dac_32r_ls'left-1 downto 0);

  i2s_fifo_dout_ready  <= dac_ready;

  u_parallel_to_i2s : entity work.parallel_to_i2s
    generic map
    (
      G_NUM_POSEDGE => 3, -- used for debounce filter
      G_DWIDTH      => 32,
      G_LSB_FIRST   => false
    )
    port map
    (
      clk           => s_axi_aclk,
      reset         => (not s_axi_aresetn),
      enable        => i2s_sw_resetn,

      error         => i2s_dac_error(0),

      din_left      => dac_l,
      din_right     => dac_r,
      din_valid     => '1',
      din_ready     => dac_ready,

      bclk          => bclk,
      lrclk         => dac_lrclk,
      serial_dout   => dac_data
    );

  i2s_2_ps_sw_resetn        <= std_logic(registers.CONTROL.SW_RESETN(0)) and std_logic(registers.CONTROL.I2S_2_PS_ENABLE(0));
  i2s_2_ps_fifo_din         <= dsp_lm_dout & dsp_lm_dout;
  i2s_2_ps_fifo_din_valid   <= dsp_l_dout_valid and dsp_l_dout_ready;

  u_i2s_2_ps_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => C_I2S_2_PS_FIFO_AWIDTH,
      G_DATA_WIDTH    => 2*C_ADC_RESOLUTION,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => i2s_2_ps_sw_resetn,

      din             => i2s_2_ps_fifo_din,
      din_valid       => i2s_2_ps_fifo_din_valid,
      din_ready       => i2s_2_ps_fifo_din_ready,
      din_last        => '0',

      used            => i2s_2_ps_fifo_used,

      dout            => i2s_2_ps_fifo_dout,
      dout_valid      => i2s_2_ps_fifo_dout_valid,
      dout_ready      => i2s_2_ps_fifo_dout_ready,
      dout_last       => open
    );

  i2s_2_ps_fifo_dout24_l    <= i2s_2_ps_fifo_dout(2*C_ADC_RESOLUTION-1 downto C_ADC_RESOLUTION);
  i2s_2_ps_fifo_dout24_r    <= i2s_2_ps_fifo_dout(C_ADC_RESOLUTION-1 downto 0);

  i2s_2_ps_fifo_dout_l      <= std_logic_vector(resize(signed(i2s_2_ps_fifo_dout24_l), i2s_2_ps_fifo_dout_l'length));
  i2s_2_ps_fifo_dout_r      <= std_logic_vector(resize(signed(i2s_2_ps_fifo_dout24_r), i2s_2_ps_fifo_dout_r'length));

  m_axis_dma_tdata <= i2s_2_ps_fifo_dout_l & i2s_2_ps_fifo_dout_r;
  m_axis_dma_tvalid <= i2s_2_ps_fifo_dout_valid;
  i2s_2_ps_fifo_dout_ready  <= registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse or m_axis_dma_tready;


  ps_2_i2s_sw_resetn  <= std_logic(registers.CONTROL.SW_RESETN(0)) and std_logic(registers.CONTROL.PS_2_I2S_ENABLE(0));
  ps_2_i2s_fifo_din <=
    std_logic_vector(resize(signed(registers.PS_2_I2S_FIFO_WRITE_L.FIFO_VALUE_L), C_ADC_RESOLUTION)) &
    std_logic_vector(resize(signed(registers.PS_2_I2S_FIFO_WRITE_R.FIFO_VALUE_R), C_ADC_RESOLUTION)) when registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse = '1' else
    std_logic_vector(resize(signed(s_axis_dma_tdata(63 downto 32)), C_ADC_RESOLUTION)) &
    std_logic_vector(resize(signed(s_axis_dma_tdata(31 downto  0)), C_ADC_RESOLUTION));

  ps_2_i2s_fifo_din_valid <= registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse or s_axis_dma_tvalid;
  s_axis_dma_tready <= ps_2_i2s_fifo_din_ready;

  u_ps_2_i2s_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => C_PS_2_I2S_FIFO_AWIDTH,
      G_DATA_WIDTH    => 2*C_ADC_RESOLUTION,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => ps_2_i2s_sw_resetn,

      din             => ps_2_i2s_fifo_din,
      din_valid       => ps_2_i2s_fifo_din_valid,
      din_ready       => ps_2_i2s_fifo_din_ready,
      din_last        => '0',

      used            => ps_2_i2s_fifo_used,

      dout            => ps_2_i2s_fifo_dout,
      dout_valid      => ps_2_i2s_fifo_dout_valid,
      dout_ready      => ps_2_i2s_fifo_dout_ready,
      dout_last       => open
    );

  ps_2_i2s_fifo_avail <= std_logic_vector(to_unsigned(2**C_PS_2_I2S_FIFO_AWIDTH-1, ps_2_i2s_fifo_used'length) - unsigned(ps_2_i2s_fifo_used));

  ps_2_i2s_fifo_dout_ready <=  i2s_fifo_din_valid and i2s_fifo_din_ready;

  ps_2_i2s_fifo_dout_l <= ps_2_i2s_fifo_dout(2*C_ADC_RESOLUTION-1 downto C_ADC_RESOLUTION);
  ps_2_i2s_fifo_dout_r <= ps_2_i2s_fifo_dout(C_ADC_RESOLUTION-1 downto 0);

end rtl;
