
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eq_iir is
  generic
  (
    G_BRAM_ADDRWIDTH      : integer range 4 to 12   := 8;
    G_NUM_BANDS           : integer range 2 to 128  := 2;
    G_NUM_B_TAPS          : integer range 2 to 255  := 3;
    G_NUM_A_TAPS          : integer range 2 to 255  := 3;
    G_TAP_INTEGER_BITS    : integer := 2;
    G_TAP_DWIDTH          : integer := 64; -- keep these large
    G_DWIDTH              : integer := 64; -- keep these large
    G_REFRESH_RATE        : integer := 4800; -- samples
    G_ADC_DWIDTH          : integer := 24
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    bypass                : in  std_logic;

    s_prog_b_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_b_tap_tvalid   : in  std_logic;
    s_prog_b_tap_tready   : out std_logic;
    prog_b_done           : out std_logic;

    s_prog_a_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_a_tap_tvalid   : in  std_logic;
    s_prog_a_tap_tready   : out std_logic;
    prog_a_done           : out std_logic;

    pedal_input           : in  std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);

    --s_eq_tdata          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_eq_tdata            : in  std_logic_vector(G_ADC_DWIDTH-1 downto 0);
    s_eq_tvalid           : in  std_logic;
    s_eq_tready           : out std_logic;

    --m_eq_tdata          : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_eq_tdata            : out std_logic_vector(G_ADC_DWIDTH-1 downto 0);
    m_eq_tvalid           : out std_logic;
    m_eq_tready           : in  std_logic
  );
end entity;

architecture rtl of eq_iir is

  type iir_filt_data_t is array (0 to G_NUM_BANDS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
  signal s_core_tdata   : iir_filt_data_t;
  signal s_core_tvalid  : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal s_core_tready  : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal m_core_tdata   : iir_filt_data_t;
  signal m_core_tvalid  : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal m_core_tready  : std_logic_vector(G_NUM_BANDS-1 downto 0);

  type iir_filt_tap_t is array (0 to G_NUM_BANDS-1) of std_logic_vector(G_TAP_DWIDTH-1 downto 0);
  signal a_tap_tdata    : iir_filt_data_t;
  signal a_tap_tvalid   : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal a_tap_tready   : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal b_tap_tdata    : iir_filt_data_t;
  signal b_tap_tvalid   : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal b_tap_tready   : std_logic_vector(G_NUM_BANDS-1 downto 0);

begin

  s_core_tdata(0) <= s_eq_tdata;
  s_core_tvalid(0) <= s_eq_tvalid;
  s_eq_tready <= s_core_tready(0);


  gen_interenal_sig_connect : for i in 1 to G_NUM_BANDS-1 generate
    s_core_tdata(i)     <= m_core_tdata(i-1);
    s_core_tvalid(i)    <= m_core_tready(i-1);
    m_core_tready(i-1)  <= s_core_tready(i);
  end generate;

  m_eq_tdata  <= m_core_tdata(G_NUM_BANDS-1);
  m_eq_tvalid <= m_core_tvalid(G_NUM_BANDS-1);
  m_core_tready(G_NUM_BANDS-1) <= m_eq_tready;

  gen_iir_series_bank : for i in 0 to G_NUM_BANDS-1 generate
    u_reprogrammable_iir_filt : entity work.reprogrammable_iir_filt
    generic map
    (
      G_PACK_TAPS_MSB_FIRST => false,
      G_NUM_B_TAPS          => G_NUM_B_TAPS,
      G_NUM_A_TAPS          => G_NUM_A_TAPS,
      G_TAP_INTEGER_BITS    => G_TAP_INTEGER_BITS,
      G_TAP_DWIDTH          => G_TAP_DWIDTH,
      G_DWIDTH              => G_DWIDTH
    )
    port map
    (
      clk                   => clk,
      reset                 => reset,
      bypass                => '0',

      s_prog_b_tap_tdata    => b_tap_tdata(i),
      s_prog_b_tap_tvalid   => b_tap_tvalid(i),
      s_prog_b_tap_tready   => b_tap_tready(i),
      prog_b_tap_done       => open,

      s_prog_a_tap_tdata    => a_tap_tdata(i),
      s_prog_a_tap_tvalid   => a_tap_tvalid(i),
      s_prog_a_tap_tready   => a_tap_tready(i),
      prog_a_tap_done       => open,

      s_iir_tdata           => s_core_tdata(i),
      s_iir_tvalid          => s_core_tvalid(i),
      s_iir_tready          => s_core_tready(i),
      s_iir_tlast           => '0',

      m_iir_tdata           => m_core_tdata(i),
      m_iir_tvalid          => m_core_tvalid(i),
      m_iir_tready          => m_core_tready(i),
      m_iir_tlast           => open
    );
  end generate;

end rtl;
