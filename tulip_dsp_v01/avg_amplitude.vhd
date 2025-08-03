library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity avg_amplitude is
  generic
  (
    G_DWIDTH      : integer range 8 to 64 := 24
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;
    bypass        : in  std_logic;

    s_axis_tdata  : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_axis_tvalid : in  std_logic;
    s_axis_tready : out std_logic;

    m_axis_tdata  : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic
  );
end entity;

architecture rtl of avg_amplitude is

  signal tdata_abs : signed(G_DWIDTH-1 downto 0);
  signal tdata_sqr : signed(2*G_DWIDTH-1 downto 0);

  type mul_state_t is (SM_INIT, SM_GET_INPUT, SM_MULTIPLY, SM_PASS_OUTPUT);
  signal mul_state : mul_state_t;

  signal s_axis_tready_int  : std_logic;
  signal mul_valid_s0       : std_logic;
  signal mul_valid          : std_logic;

  signal s_cic_tdata        : std_logic_vector(2*G_DWIDTH-1 downto 0);
  signal s_cic_tvalid       : std_logic;
  signal s_cic_tready       : std_logic;
  signal m_cic_tdata        : std_logic_vector(2*G_DWIDTH-1 downto 0);
  signal m_cic_tvalid       : std_logic;
  signal m_cic_tready       : std_logic;

  signal s_sqrt_tdata       : std_logic_vector(2*G_DWIDTH-1 downto 0);
  signal s_sqrt_tvalid      : std_logic;
  signal s_sqrt_tready      : std_logic;
  signal m_sqrt_tdata       : std_logic_vector(2*G_DWIDTH-1 downto 0);
  signal m_sqrt_tvalid      : std_logic;
  signal m_sqrt_tready      : std_logic;

begin

  s_axis_tready <= s_axis_tready_int;


  p_multiply : process(clk)
  begin
    if rising_edge(clk) then
      mul_valid_s0  <= s_axis_tvalid and s_axis_tready_int;
      mul_valid     <= mul_valid_s0;

      tdata_abs <= abs(signed(s_axis_tdata));
      tdata_sqr <= tdata_abs*tdata_abs;
    end if;
  end process;

  p_mul_state : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        mul_state <= SM_INIT;
        s_axis_tready_int <= '0';
        s_cic_tvalid      <= '0';
      else
        case mul_state is
          when SM_INIT =>
            mul_state         <= SM_GET_INPUT;
            s_axis_tready_int <= '1';

          when SM_GET_INPUT =>
            if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
              mul_state         <= SM_MULTIPLY;
              s_axis_tready_int <= '0';
            end if;

          when SM_MULTIPLY =>
            if mul_valid = '1' then
              mul_state       <= SM_PASS_OUTPUT;
              s_cic_tdata     <= std_logic_vector(tdata_sqr);
              s_cic_tvalid    <= '1';
            end if;

          when SM_PASS_OUTPUT =>
            if s_cic_tvalid = '1' and s_cic_tready = '1' then
              mul_state         <= SM_GET_INPUT;
              s_cic_tvalid      <= '0';
              s_axis_tready_int <= '1';
            end if;

          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process;

  u_cic_single_rate : entity work.cic_single_rate
  generic map
  (
    G_COMB_DEPTH      => 512,
    G_SINGLE_STAGE_RS => 9,
    G_DIN_DWIDTH      => 2*G_DWIDTH,
    G_DOUT_DWIDTH     => 2*G_DWIDTH
  )
  port map
  (
    clk           => clk,
    reset         => reset,
    bypass        => '0',

    s_cic_tdata   => s_cic_tdata,
    s_cic_tvalid  => s_cic_tvalid,
    s_cic_tready  => s_cic_tready,

    m_cic_tdata   => m_cic_tdata,
    m_cic_tvalid  => m_cic_tvalid,
    m_cic_tready  => m_cic_tready
  );

  s_sqrt_tdata  <= m_cic_tdata;
  s_sqrt_tvalid <= m_cic_tvalid;
  m_cic_tready  <= s_sqrt_tready;

  u_sqrt : entity work.sqrt
  generic map
  (
    G_DWIDTH  => G_DWIDTH*2
  )
  port map
  (
    clk            => clk,
    reset          => reset,

    s_axis_tdata   => s_sqrt_tdata,
    s_axis_tvalid  => s_sqrt_tvalid,
    s_axis_tready  => s_sqrt_tready,

    m_axis_tdata   => m_sqrt_tdata,
    m_axis_tvalid  => m_sqrt_tvalid,
    m_axis_tready  => m_sqrt_tready
  );

  m_axis_tdata  <= m_sqrt_tdata(m_axis_tdata'range);
  m_axis_tvalid <= m_sqrt_tvalid;
  m_sqrt_tready <= m_axis_tready;

end rtl;

