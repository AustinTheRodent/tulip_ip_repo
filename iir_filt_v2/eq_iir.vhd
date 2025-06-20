
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity eq_iir is
  generic
  (
    G_NUM_BANDS           : integer range 2 to 128  := 10;
    G_NUM_B_TAPS          : integer range 2 to 255  := 3;
    G_NUM_A_TAPS          : integer range 2 to 255  := 3;
    G_TAP_INTEGER_BITS    : integer := 2;
    G_TAP_DWIDTH          : integer := 64; -- keep these large
    G_DWIDTH              : integer := 64; -- keep these large
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

  signal a_tap_tvalid   : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal a_tap_done     : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal b_tap_tvalid   : std_logic_vector(G_NUM_BANDS-1 downto 0);
  signal b_tap_done     : std_logic_vector(G_NUM_BANDS-1 downto 0);

  signal gate_input     : std_logic;

  signal a_tap_prog_counter : unsigned(7 downto 0);
  signal b_tap_prog_counter : unsigned(7 downto 0);

begin

  s_core_tdata(0)   <= std_logic_vector(shift_left(resize(signed(s_eq_tdata), G_DWIDTH), G_DWIDTH - G_ADC_DWIDTH - G_TAP_INTEGER_BITS));
  s_core_tvalid(0)  <= s_eq_tvalid and gate_input;
  s_eq_tready       <= s_core_tready(0) and gate_input when bypass = '0' else m_eq_tready;

  gen_interenal_sig_connect : for i in 1 to G_NUM_BANDS-1 generate
    s_core_tdata(i)     <= m_core_tdata(i-1);
    s_core_tvalid(i)    <= m_core_tvalid(i-1);
    m_core_tready(i-1)  <= s_core_tready(i);
  end generate;

  m_eq_tdata                    <= std_logic_vector(resize(shift_right(signed(m_core_tdata(G_NUM_BANDS-1)), G_DWIDTH - G_ADC_DWIDTH - G_TAP_INTEGER_BITS), G_ADC_DWIDTH)) when bypass = '0' else s_eq_tdata;
  m_eq_tvalid                   <= m_core_tvalid(G_NUM_BANDS-1) when bypass = '0' else s_eq_tvalid;
  m_core_tready(G_NUM_BANDS-1)  <= m_eq_tready;

  s_prog_a_tap_tready <= not a_tap_done(G_NUM_BANDS-1);
  s_prog_b_tap_tready <= not b_tap_done(G_NUM_BANDS-1);

  b_state_machine : block
    type state_t is (init, program, run);
    signal state            : state_t;
    signal a_prog_counter   : unsigned(7 downto 0);
    signal b_prog_counter   : unsigned(7 downto 0);
    signal prog_a_done_int  : std_logic;
    signal prog_b_done_int  : std_logic;
  begin

    prog_a_done_int <= a_tap_done(G_NUM_BANDS-1);
    prog_b_done_int <= b_tap_done(G_NUM_BANDS-1);

    prog_a_done <= prog_a_done_int;
    prog_b_done <= prog_b_done_int;

    gen_a_v : for i in 0 to G_NUM_BANDS-1 generate
      a_tap_tvalid(i) <= s_prog_a_tap_tvalid when to_integer(a_prog_counter) = i else '0';
    end generate;

    gen_b_v : for i in 0 to G_NUM_BANDS-1 generate
      b_tap_tvalid(i) <= s_prog_b_tap_tvalid when to_integer(b_prog_counter) = i else '0';
    end generate;

    p_state_machine : process(clk)
    begin
      if rising_edge(clk) then

        if reset = '1' then
          state       <= init;
          gate_input  <= '0';

          a_prog_counter      <= (others => '0');
          b_prog_counter      <= (others => '0');
          a_tap_prog_counter  <= (others => '0');
          b_tap_prog_counter  <= (others => '0');

          a_tap_done          <= (others => '0');
          b_tap_done          <= (others => '0');
        else
          case state is
            when init =>
              state       <= program;
              a_tap_done  <= (others => '0');

            when program =>
              for i in 0 to G_NUM_BANDS-1 loop
                if to_integer(a_prog_counter) = i then
                  if s_prog_a_tap_tvalid = '1' and a_tap_done(G_NUM_BANDS-1) = '0' then
                    if a_tap_prog_counter = G_NUM_A_TAPS-1 then
                      a_tap_prog_counter  <= (others => '0');
                      a_prog_counter      <= a_prog_counter + 1;
                      a_tap_done(i)       <= '1';
                    else
                      a_tap_prog_counter <= a_tap_prog_counter + 1;
                    end if;
                  end if;
                end if;
              end loop;

              for i in 0 to G_NUM_BANDS-1 loop
                if to_integer(b_prog_counter) = i then
                  if s_prog_b_tap_tvalid = '1' and b_tap_done(G_NUM_BANDS-1) = '0' then
                    if b_tap_prog_counter = G_NUM_B_TAPS-1 then
                      b_tap_prog_counter  <= (others => '0');
                      b_prog_counter      <= b_prog_counter + 1;
                      b_tap_done(i)       <= '1';
                    else
                      b_tap_prog_counter <= b_tap_prog_counter + 1;
                    end if;
                  end if;
                end if;
              end loop;

              if prog_a_done_int = '1' and prog_b_done_int = '1' then
                gate_input  <= '1';
                state       <= run;
              end if;

            when others =>
              null;

          end case;
        end if;
      end if;
    end process;
  end block;

  gen_iir_series_bank : for i in 0 to G_NUM_BANDS-1 generate

    u_iir : entity work.iir_filt
    generic map
    (
      G_NUM_B_TAPS        => G_NUM_B_TAPS,
      G_NUM_A_TAPS        => G_NUM_A_TAPS,
      G_TAP_INTEGER_BITS  => G_TAP_INTEGER_BITS,
      G_TAP_DWIDTH        => G_TAP_DWIDTH,
      G_DWIDTH            => G_DWIDTH
    )
    port map
    (
      clk               => clk,
      reset             => reset,
      bypass            => '0',

      a_tap_val         => s_prog_a_tap_tdata,
      a_tap_addr        => std_logic_vector(a_tap_prog_counter),
      a_tap_wr          => a_tap_tvalid(i),

      b_tap_val         => s_prog_b_tap_tdata,
      b_tap_addr        => std_logic_vector(b_tap_prog_counter),
      b_tap_wr          => b_tap_tvalid(i),

      s_iir_tdata       => s_core_tdata(i),
      s_iir_tvalid      => s_core_tvalid(i),
      s_iir_tready      => s_core_tready(i),
      s_iir_tlast       => '0',

      m_iir_tdata       => m_core_tdata(i),
      m_iir_tdata_full  => open,
      m_iir_tvalid      => m_core_tvalid(i),
      m_iir_tready      => m_core_tready(i),
      m_iir_tlast       => open
    );

  end generate;

end rtl;
