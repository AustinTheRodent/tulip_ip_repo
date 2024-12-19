library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wawa_bram is
  generic
  (
    G_ADDR_WIDTH  : integer := 10;
    G_DATA_WIDTH  : integer := 64
    --G_WORD_WIDTH  : integer := 32
  );
  port
  (
    clk                   : in  std_logic;

    wr_data               : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    wr_address            : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    wr_valid              : in  std_logic;

    rd_data               : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    rd_address            : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    rd_din_valid          : in  std_logic;
    rd_dout_valid         : out std_logic

  );
end entity;

architecture rtl of wawa_bram is

  type ram_t is array (0 to 2**G_ADDR_WIDTH-1) of std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal ram : ram_t;

begin

  p_wr : process(clk)
  begin
    if rising_edge(clk) then
      if wr_valid = '1' then
        ram(to_integer(unsigned(wr_address))) <= wr_data;
      end if;
    end if;
  end process;

  p_rd : process(clk)
  begin
    if rising_edge(clk) then
      rd_data <= ram(to_integer(unsigned(rd_address)));
      rd_dout_valid <= rd_din_valid;
    end if;
  end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wawa_iir is
  generic
  (
    G_BRAM_ADDRWIDTH      : integer range 4 to 12   := 8;
    G_NUM_B_TAPS          : integer range 2 to 255  := 16;
    G_NUM_A_TAPS          : integer range 2 to 255  := 16;
    G_TAP_INTEGER_BITS    : integer := 2;
    G_TAP_DWIDTH          : integer := 64;
    G_DWIDTH              : integer := 64
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    bypass                : in  std_logic;

    s_prog_b_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_b_tap_address  : in  std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);
    s_prog_b_tap_index    : in  std_logic_vector(7 downto 0);
    s_prog_b_tap_tvalid   : in  std_logic;

    s_prog_a_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_a_tap_address  : in  std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);
    s_prog_a_tap_index    : in  std_logic_vector(7 downto 0);
    s_prog_a_tap_tvalid   : in  std_logic;

    s_wawa_tdata          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_wawa_tvalid         : in  std_logic;
    s_wawa_tready         : out std_logic;
    s_wawa_tlast          : in  std_logic;

    m_wawa_tdata          : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_wawa_tvalid         : out std_logic;
    m_wawa_tready         : in  std_logic;
    m_wawa_tlast          : out std_logic
  );
end entity;

architecture rtl of wawa_iir is

  signal b_tap_bram_register        : std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal b_tap_bram_register_valid  : std_logic;
  signal a_tap_bram_register        : std_logic_vector(G_NUM_A_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal a_tap_bram_register_valid  : std_logic;

  signal b_tap_index_int      : integer range 0 to 255;
  signal a_tap_index_int      : integer range 0 to 255;

begin

  b_tap_index_int <= to_integer(unsigned(s_prog_b_tap_index));

  p_b_tap_register : process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(s_prog_b_tap_index) < G_NUM_B_TAPS and s_prog_b_tap_tvalid = '1' then
        b_tap_bram_register(G_TAP_DWIDTH*(b_tap_index_int+1)-1 downto G_TAP_DWIDTH*b_tap_index_int) <= s_prog_b_tap_tdata;
      end if;
      b_tap_bram_register_valid <= s_prog_b_tap_tvalid;
    end if;
  end process;

  p_a_tap_register : process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(s_prog_a_tap_index) < G_NUM_A_TAPS and s_prog_a_tap_tvalid = '1' then
        a_tap_bram_register(G_TAP_DWIDTH*(a_tap_index_int+1)-1 downto G_TAP_DWIDTH*a_tap_index_int) <= s_prog_a_tap_tdata;
      end if;
      a_tap_bram_register_valid <= s_prog_a_tap_tvalid;
    end if;
  end process;

  u_b_tap_bram : entity work.wawa_bram
  generic map
  (
    G_ADDR_WIDTH  => G_BRAM_ADDRWIDTH,
    G_DATA_WIDTH  => G_NUM_B_TAPS*G_TAP_DWIDTH
  )
  port map
  (
    clk           => clk,

    wr_data       => b_tap_bram_register,
    wr_address    => s_prog_b_tap_address,
    wr_valid      => b_tap_bram_register_valid,

    rd_data       => open,
    rd_address    => (others => '0'),
    rd_din_valid  => '0',
    rd_dout_valid => open
  );

  u_a_tap_bram : entity work.wawa_bram
  generic map
  (
    G_ADDR_WIDTH  => G_BRAM_ADDRWIDTH,
    G_DATA_WIDTH  => G_NUM_A_TAPS*G_TAP_DWIDTH
  )
  port map
  (
    clk           => clk,

    wr_data       => a_tap_bram_register,
    wr_address    => s_prog_a_tap_address,
    wr_valid      => a_tap_bram_register_valid,

    rd_data       => open,
    rd_address    => (others => '0'),
    rd_din_valid  => '0',
    rd_dout_valid => open
  );

end rtl;
