library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dc_blocker_cic is
  port
  (
    clk                : in  std_logic;
    reset              : in  std_logic;
    bypass             : in  std_logic;

    s_dc_block_tdata   : in  std_logic_vector(23 downto 0);
    s_dc_block_tvalid  : in  std_logic;
    s_dc_block_tready  : out  std_logic;

    m_dc_block_tdata   : out std_logic_vector(23 downto 0);
    m_dc_block_tvalid  : out std_logic;
    m_dc_block_tready  : in  std_logic
  );
end entity;

architecture rtl of dc_blocker_cic is

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  signal s_obuff_tdata        : std_logic_vector(23 downto 0);
  signal s_obuff_tvalid       : std_logic;
  signal s_obuff_tready       : std_logic;
  signal m_obuff_tdata        : std_logic_vector(23 downto 0);
  signal m_obuff_tvalid       : std_logic;
  signal m_obuff_tready       : std_logic;

  signal s_buff_tdata         : std_logic_vector(23 downto 0);
  signal s_buff_tvalid        : std_logic;
  signal s_buff_tready        : std_logic;
  signal m_buff_tdata         : std_logic_vector(23 downto 0);
  signal m_buff_tvalid        : std_logic;
  signal m_buff_tready        : std_logic;

  signal s_cic_cascade_tdata  : std_logic_vector(23 downto 0);
  signal s_cic_cascade_tvalid : std_logic;
  signal s_cic_cascade_tready : std_logic;
  signal m_cic_cascade_tdata  : std_logic_vector(23 downto 0);
  signal m_cic_cascade_tvalid : std_logic;
  signal m_cic_cascade_tready : std_logic;

begin

  s_buff_tdata          <= s_dc_block_tdata;
  s_cic_cascade_tdata   <= s_dc_block_tdata;
  s_buff_tvalid         <= s_dc_block_tvalid and s_buff_tready and s_cic_cascade_tready;
  s_cic_cascade_tvalid  <= s_dc_block_tvalid and s_buff_tready and s_cic_cascade_tready;
  s_dc_block_tready     <=
    m_dc_block_tready when bypass = '1' else
    s_dc_block_tvalid and s_buff_tready and s_cic_cascade_tready;

  u_din_buffer : entity work.axis_buffer
  generic map
  (
    G_DWIDTH    => 24
  )
  port map
  (
    clk         => clk,
    reset       => reset,
    enable      => '1',

    din         => s_buff_tdata,
    din_valid   => s_buff_tvalid,
    din_ready   => s_buff_tready,
    din_last    => '0',

    dout        => m_buff_tdata,
    dout_valid  => m_buff_tvalid,
    dout_ready  => m_buff_tready,
    dout_last   => open
  );

  u_cic_single_rate_cascade : entity work.cic_single_rate_cascade
  generic map
  (
    G_COMB_DEPTH          => 1024,
    G_NUM_STAGES          => 3,
    G_SINGLE_STAGE_RS     => 10,
    G_DWIDTH              => 24
  )
  port map
  (
    clk                   => clk,
    reset                 => reset,
    bypass                => '0',

    s_cic_cascade_tdata   => s_cic_cascade_tdata,
    s_cic_cascade_tvalid  => s_cic_cascade_tvalid,
    s_cic_cascade_tready  => s_cic_cascade_tready,

    m_cic_cascade_tdata   => m_cic_cascade_tdata,
    m_cic_cascade_tvalid  => m_cic_cascade_tvalid,
    m_cic_cascade_tready  => m_cic_cascade_tready
  );

  s_obuff_tdata         <= std_logic_vector(signed(m_buff_tdata)-signed(m_cic_cascade_tdata));
  s_obuff_tvalid        <= m_cic_cascade_tvalid and m_buff_tvalid and s_obuff_tready;
  m_cic_cascade_tready  <= s_obuff_tvalid and s_obuff_tready;
  m_buff_tready         <= s_obuff_tvalid and s_obuff_tready;

  u_dout_buffer : entity work.axis_buffer
  generic map
  (
    G_DWIDTH    => 24
  )
  port map
  (
    clk         => clk,
    reset       => reset,
    enable      => '1',

    din         => s_obuff_tdata,
    din_valid   => s_obuff_tvalid,
    din_ready   => s_obuff_tready,
    din_last    => '0',

    dout        => m_obuff_tdata,
    dout_valid  => m_obuff_tvalid,
    dout_ready  => m_obuff_tready,
    dout_last   => open
  );

  m_dc_block_tdata  <=
    s_dc_block_tdata when bypass = '1' else
    m_obuff_tdata;

  m_dc_block_tvalid <=
    s_dc_block_tvalid when bypass = '1' else
    m_obuff_tvalid;

  m_obuff_tready    <= m_dc_block_tready;

end rtl;