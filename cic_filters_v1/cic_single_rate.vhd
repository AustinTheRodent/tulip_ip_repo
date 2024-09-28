library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cic_single_rate is
  generic
  (
    G_COMB_DEPTH      : integer range 3 to 8192 := 1024;
    G_SINGLE_STAGE_RS : integer := 10;
    G_DIN_DWIDTH      : integer := 24;
    G_DOUT_DWIDTH     : integer := 24
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;
    bypass        : in  std_logic;

    s_cic_tdata   : in  std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    s_cic_tvalid  : in  std_logic;
    s_cic_tready  : out  std_logic;

    m_cic_tdata   : out std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    m_cic_tvalid  : out std_logic;
    m_cic_tready  : in  std_logic
  );
end entity;

architecture rtl of cic_single_rate is

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  constant C_INTEGRATOR_DOUT_WIDTH  : integer := G_DIN_DWIDTH + clog2(G_COMB_DEPTH);
  constant C_COMB_DWIDTH            : integer := G_DIN_DWIDTH + 1;


  signal s_comb_tdata         : std_logic_vector(C_COMB_DWIDTH-1 downto 0);
  signal s_comb_tvalid        : std_logic;
  signal s_comb_tready        : std_logic;
  signal m_comb_tdata         : std_logic_vector(C_COMB_DWIDTH-1 downto 0);
  signal m_comb_tvalid        : std_logic;
  signal m_comb_tready        : std_logic;

  signal s_integrator_tdata   : std_logic_vector(C_COMB_DWIDTH-1 downto 0);
  signal s_integrator_tvalid  : std_logic;
  signal s_integrator_tready  : std_logic;
  signal m_integrator_tdata   : std_logic_vector(C_INTEGRATOR_DOUT_WIDTH-1 downto 0);
  signal m_integrator_tvalid  : std_logic;
  signal m_integrator_tready  : std_logic;



begin

  s_comb_tdata  <= std_logic_vector(resize(signed(s_cic_tdata), C_COMB_DWIDTH));
  s_comb_tvalid <= s_cic_tvalid;
  s_cic_tready  <= s_comb_tready;

  u_comb : entity work.comb
  generic map
  (
    G_COMB_DEPTH  => G_COMB_DEPTH,
    G_COMB_DWIDTH => C_COMB_DWIDTH,
    G_DIN_DWIDTH  => C_COMB_DWIDTH,
    G_DOUT_DWIDTH => C_COMB_DWIDTH
  )
  port map
  (
    clk           => clk,
    reset         => reset,
    bypass        => bypass,

    s_comb_tdata  => s_comb_tdata,
    s_comb_tvalid => s_comb_tvalid,
    s_comb_tready => s_comb_tready,

    m_comb_tdata  => m_comb_tdata,
    m_comb_tvalid => m_comb_tvalid,
    m_comb_tready => m_comb_tready
  );

  --s_integrator_tdata  <= m_comb_tdata;
  --s_integrator_tvalid <= m_comb_tvalid;
  --m_comb_tready       <= s_integrator_tready;

  u_buffer : entity work.axis_buffer
  generic map
  (
    G_DWIDTH    => m_comb_tdata'length
  )
  port map
  (
    clk         => clk,
    reset       => reset,
    enable      => '1',

    din         => m_comb_tdata,
    din_valid   => m_comb_tvalid,
    din_ready   => m_comb_tready,
    din_last    => '0',

    dout        => s_integrator_tdata,
    dout_valid  => s_integrator_tvalid,
    dout_ready  => s_integrator_tready,
    dout_last   => open
  );

  u_integrator : entity work.integrator
  generic map
  (
    G_INTEGRATOR_DWIDTH => C_INTEGRATOR_DOUT_WIDTH,
    G_DIN_DWIDTH        => C_COMB_DWIDTH,
    G_DOUT_DWIDTH       => C_INTEGRATOR_DOUT_WIDTH
  )
  port map
  (
    clk                 => clk,
    reset               => reset,
    bypass              => bypass,

    s_integrator_tdata  => s_integrator_tdata,
    s_integrator_tvalid => s_integrator_tvalid,
    s_integrator_tready => s_integrator_tready,

    m_integrator_tdata  => m_integrator_tdata,
    m_integrator_tvalid => m_integrator_tvalid,
    m_integrator_tready => m_integrator_tready
  );

  m_cic_tdata         <= std_logic_vector(resize(shift_right(signed(m_integrator_tdata), G_SINGLE_STAGE_RS), G_DOUT_DWIDTH));
  m_cic_tvalid        <= m_integrator_tvalid;
  m_integrator_tready <= m_cic_tready;

end rtl;