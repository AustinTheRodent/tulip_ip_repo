library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tremelo is
  generic
  (
    G_DWIDTH          : integer := 16
  );
  port
  (
    clk               : in  std_logic;
    reset             : in  std_logic;
    bypass            : in  std_logic;

    tremelo_rate      : in  std_logic_vector(G_DWIDTH-1 downto 0);
    tremelo_depth     : in  std_logic_vector(G_DWIDTH-1 downto 0);

    s_tremelo_tdata   : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_tremelo_tvalid  : in  std_logic;
    s_tremelo_tready  : out std_logic;

    m_tremelo_tdata   : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_tremelo_tvalid  : out std_logic;
    m_tremelo_tready  : in  std_logic
  );
end entity;

architecture rtl of tremelo is

  constant C_ONE              : signed(1 downto 0) := "01";
  constant C_DDS_OFFSET       : signed(G_DWIDTH-1 downto 0) := shift_left(resize(C_ONE, G_DWIDTH), G_DWIDTH-2);

  signal s_tremelo_tready_int : std_logic;

  signal m_tremelo_tdata_int  : std_logic_vector(G_DWIDTH-1 downto 0);
  signal m_tremelo_tvalid_int : std_logic;

  signal dds_din              : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dds_din_valid        : std_logic;
  signal dds_din_ready        : std_logic;
  signal dds_dout_re          : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dds_dout_im          : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dds_dout_valid       : std_logic;
  signal dds_dout_valid_delay : std_logic;
  signal dds_dout_ready       : std_logic;

  signal mult_a               : signed(G_DWIDTH-1 downto 0);
  signal mult_b               : signed(G_DWIDTH-1 downto 0);
  signal mult_c               : signed(2*G_DWIDTH-1 downto 0);

  signal dds_dout_re_half     : signed(G_DWIDTH-1 downto 0);
  signal dds_dout_re_scale    : signed(2*G_DWIDTH-1 downto 0);

  type state_t is (SM_INIT, SM_GET_INPUT, SM_GET_DDS, SM_DELAY, SM_MULT, SM_SEND_OUTPUT);
  signal state : state_t;

begin

  s_tremelo_tready  <= s_tremelo_tready_int when bypass = '0' else m_tremelo_tready;
  m_tremelo_tdata   <= m_tremelo_tdata_int when bypass = '0' else s_tremelo_tdata;
  m_tremelo_tvalid  <= m_tremelo_tvalid_int when bypass = '0' else s_tremelo_tvalid;

  p_mult : process(clk)
  begin
    if rising_edge(clk) then
      dds_dout_valid_delay  <= dds_dout_valid;
      dds_dout_re_scale     <= dds_dout_re_half*signed(tremelo_depth);
      mult_c                <= mult_a*mult_b;
    end if;
  end process;


  dds_din       <= tremelo_rate;
  dds_din_valid <= '1';

  u_dds_taylor : entity work.dds_taylor
  generic map
  (
    G_DIN_WIDTH       => G_DWIDTH,
    G_DOUT_WIDTH      => G_DWIDTH,
    G_COMPLEX_OUTPUT  => 0
  )
  port map
  (
    clk               => clk,
    reset             => reset,
    enable            => '1',

    din               => dds_din,
    din_valid         => dds_din_valid,
    din_ready         => dds_din_ready,

    dout_re           => dds_dout_re,
    dout_im           => dds_dout_im,
    dout_valid        => dds_dout_valid,
    dout_ready        => dds_dout_ready
  );

  dds_dout_re_half  <= shift_right(signed(dds_dout_re), 1);
  --dds_dout_re_scale <= dds_dout_re_half*

  p_state_machine : process(clk)
    --variable v_delay_count : unsigned(3 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        s_tremelo_tready_int  <= '0';
        dds_dout_ready    <= '0';
        state             <= SM_INIT;
      else
        case (state) is
          when SM_INIT =>
            s_tremelo_tready_int  <= '1';
            dds_dout_ready    <= '0';
            state             <= SM_GET_INPUT;

          when SM_GET_INPUT =>
            if s_tremelo_tvalid = '1' then
              s_tremelo_tready_int  <= '0';

              mult_a            <= signed(s_tremelo_tdata);
              state             <= SM_GET_DDS;
            end if;

          when SM_GET_DDS =>
            if dds_dout_valid_delay = '1' then
              dds_dout_ready  <= '1';
              mult_b          <= resize(shift_right(dds_dout_re_scale, G_DWIDTH-1) + C_DDS_OFFSET, mult_b'length);
              state           <= SM_DELAY;
            end if;

          when SM_DELAY =>
            dds_dout_ready  <= '0';
            state           <= SM_MULT;

          when SM_MULT =>
            m_tremelo_tdata_int <= std_logic_vector(resize(shift_right(mult_c, G_DWIDTH-1), G_DWIDTH));
            m_tremelo_tvalid_int  <= '1';
            state             <= SM_SEND_OUTPUT;

          when SM_SEND_OUTPUT =>
            if m_tremelo_tready = '1' then
              s_tremelo_tready_int  <= '1';
              m_tremelo_tvalid_int  <= '0';
              state             <= SM_INIT;
            end if;

          when others =>
            state <= SM_INIT;

        end case;
      end if;
    end if;
  end process;


end rtl;

