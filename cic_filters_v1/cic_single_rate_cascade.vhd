library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cic_single_rate_cascade is
  generic
  (
    G_COMB_DEPTH          : integer range 3 to 8192 := 1024;
    G_NUM_STAGES          : integer := 3;
    G_DIN_DWIDTH          : integer := 24
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    bypass                : in  std_logic;

    s_cic_cascade_tdata   : in  std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    s_cic_cascade_tvalid  : in  std_logic;
    s_cic_cascade_tready  : out  std_logic;

    m_cic_cascade_tdata   : out std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    m_cic_cascade_tvalid  : out std_logic;
    m_cic_cascade_tready  : in  std_logic
  );
end entity;

architecture rtl of cic_single_rate_cascade is

  type cic_data_t is array (0 to G_NUM_STAGES-1) of std_logic_vector(G_DIN_DWIDTH-1 downto 0);

  signal s_cic_tdata  : cic_data_t;
  signal s_cic_tvalid : std_logic_vector(G_NUM_STAGES-1 downto 0);
  signal s_cic_tready : std_logic_vector(G_NUM_STAGES-1 downto 0);
  signal m_cic_tdata  : cic_data_t;
  signal m_cic_tvalid : std_logic_vector(G_NUM_STAGES-1 downto 0);
  signal m_cic_tready : std_logic_vector(G_NUM_STAGES-1 downto 0);

begin

  s_cic_tdata(0)                <= s_cic_cascade_tdata;
  s_cic_tvalid(0)               <= s_cic_cascade_tvalid;
  s_cic_cascade_tready          <= s_cic_tready(0);

  m_cic_cascade_tdata           <= m_cic_tdata(G_NUM_STAGES-1);
  m_cic_cascade_tvalid          <= m_cic_tvalid(G_NUM_STAGES-1);
  m_cic_tready(G_NUM_STAGES-1)  <= m_cic_cascade_tready;

  gen_signal_connection : for i in 1 to G_NUM_STAGES-1 generate

    s_cic_tdata(i)    <= m_cic_tdata(i-1);
    s_cic_tvalid(i)   <= m_cic_tvalid(i-1);
    m_cic_tready(i-1) <= s_cic_tready(i);

  end generate;

  gen_stages : for i in 0 to G_NUM_STAGES-1 generate

    u_cic_single_rate : entity work.cic_single_rate
    generic map
    (
      G_COMB_DEPTH  => G_COMB_DEPTH,
      G_DIN_DWIDTH  => G_DIN_DWIDTH
    )
    port map
    (
      clk           => clk,
      reset         => reset,
      bypass        => bypass,

      s_cic_tdata   => s_cic_tdata(i),
      s_cic_tvalid  => s_cic_tvalid(i),
      s_cic_tready  => s_cic_tready(i),

      m_cic_tdata   => m_cic_tdata(i),
      m_cic_tvalid  => m_cic_tvalid(i),
      m_cic_tready  => m_cic_tready(i)
    );

  end generate;

end rtl;