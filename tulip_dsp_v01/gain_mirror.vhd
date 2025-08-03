library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gain_mirror is
  generic
  (
    G_DWIDTH      : integer range 8 to 64 := 24
  );
  port
  (
    clk                         : in  std_logic;
    reset                       : in  std_logic;
    bypass                      : in  std_logic;

    s_gain_stream_tdata         : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_gain_stream_tvalid        : in  std_logic;
    s_gain_stream_tready        : out std_logic;

    s_modulation_stream_tdata   : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_modulation_stream_tvalid  : in  std_logic;
    s_modulation_stream_tready  : out std_logic;

    m_axis_tdata                : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_axis_tvalid               : out std_logic;
    m_axis_tready               : in  std_logic
  );
end entity;

architecture rtl of gain_mirror is

  signal s_avg_tdata   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal s_avg_tvalid  : std_logic;
  signal s_avg_tready  : std_logic;
  signal m_avg_tdata   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal m_avg_tvalid  : std_logic;
  signal m_avg_tready  : std_logic;

  signal s_g_tdata   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal s_g_tvalid  : std_logic;
  signal s_g_tready  : std_logic;
  signal m_g_tdata   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal m_g_tvalid  : std_logic;
  signal m_g_tready  : std_logic;

begin

  s_avg_tdata           <= s_gain_stream_tdata;
  s_avg_tvalid          <= s_gain_stream_tvalid;
  s_gain_stream_tready  <= s_avg_tready;

  u_avg_amplitude : entity work.avg_amplitude
  generic map
  (
    G_DWIDTH      => G_DWIDTH
  )
  port map
  (
    clk           => clk,
    reset         => reset,
    bypass        => '0',

    s_axis_tdata  => s_avg_tdata,
    s_axis_tvalid => s_avg_tvalid,
    s_axis_tready => s_avg_tready,

    m_axis_tdata  => m_avg_tdata,
    m_axis_tvalid => m_avg_tvalid,
    m_axis_tready => m_avg_tready
  );

  m_avg_tready <= '1';

  s_g_tdata                   <= s_modulation_stream_tdata;
  s_g_tvalid                  <= s_modulation_stream_tvalid;
  s_modulation_stream_tready  <= s_g_tready when bypass = '0' else m_axis_tready;

  u_gain : entity work.gain_stage
  generic map
  (
    G_INTEGER_BITS  => 0,
    G_DECIMAL_BITS  => G_DWIDTH,
    G_DWIDTH        => G_DWIDTH
  )
  port map
  (
    clk         => clk,
    reset       => reset,
    enable      => '1',

    gain        => m_avg_tdata,

    din         => s_g_tdata,
    din_valid   => s_g_tvalid,
    din_ready   => s_g_tready,

    dout        => m_g_tdata,
    dout_valid  => m_g_tvalid,
    dout_ready  => m_g_tready
  );

  m_axis_tdata  <= m_g_tdata when bypass = '0' else s_modulation_stream_tdata;
  m_axis_tvalid <= m_g_tvalid when bypass = '0' else s_modulation_stream_tvalid;
  m_g_tready    <= m_axis_tready;

end rtl;

