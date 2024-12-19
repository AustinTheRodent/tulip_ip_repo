--
--           ┌──┐     ┌─┐
-- xn────┬──►│b0├────►│+├────────────┬──────►yn
--       │   └──┘     └─┘            │
--       │             ▲             │
--       ▼             │             ▼
--     ┌───┐           │           ┌───┐
--     │ -1│           │           │ -1│
--     │Z  │           │           │Z  │
--     └─┬─┘ ┌──┐     ┌┴┐   ┌───┐  └─┬─┘
--       ├──►│b1├────►│+│◄──┤-a1│◄───┤
--       │   └──┘     └─┘   └───┘    │
--       ▼             ▲             ▼
--     ┌───┐           │           ┌───┐
--     │ -1│           │           │ -1│
--     │Z  │           │           │Z  │
--     └─┬─┘ ┌──┐     ┌┴┐   ┌───┐  └─┬─┘
--       └──►│b2├────►│+│◄──┤-a2│◄───┘
--           └──┘     └─┘   └───┘

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_filt is
  generic
  (
    G_NUM_B_TAPS        : integer range 2 to 255  := 16;
    G_NUM_A_TAPS        : integer range 2 to 255  := 16;
    G_TAP_INTEGER_BITS  : integer := 2;
    G_TAP_DWIDTH        : integer := 64;
    G_DWIDTH            : integer := 64
  );
  port
  (
    clk         : in  std_logic;
    reset       : in  std_logic;
    bypass      : in  std_logic;

    b_tap_val   : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    b_tap_addr  : in  std_logic_vector(7 downto 0);
    b_tap_wr    : in  std_logic;

    a_tap_val   : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    a_tap_addr  : in  std_logic_vector(7 downto 0);
    a_tap_wr    : in  std_logic;

    s_iir_tdata   : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_iir_tvalid  : in  std_logic;
    s_iir_tready  : out std_logic;
    s_iir_tlast   : in  std_logic;

    m_iir_tdata       : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_iir_tdata_full  : out std_logic_vector(G_DWIDTH+G_TAP_DWIDTH-1 downto 0);
    m_iir_tvalid      : out std_logic;
    m_iir_tready      : in  std_logic;
    m_iir_tlast       : out std_logic
  );
end entity;

architecture rtl of iir_filt is

  signal y_accum          : signed(G_DWIDTH+G_TAP_DWIDTH-1 downto 0);

  type x_store_t is array (0 to G_NUM_B_TAPS-1) of signed(G_DWIDTH-1 downto 0);
  signal x_store          : x_store_t;

  type y_store_t is array (0 to G_NUM_A_TAPS-1) of signed(G_DWIDTH-1 downto 0);
  signal y_store          : y_store_t;

  signal a_taps           : y_store_t;
  signal b_taps           : x_store_t;

  signal sm_loop_counter  : unsigned(7 downto 0);

  type state_t is
  (
    SM_INIT,
    SM_GET_INPUT, -- also set y = 0
    SM_A_ACCUM_MULT,
    SM_A_ACCUM_ADD,
    SM_B_ACCUM_MULT,
    SM_B_ACCUM_ADD,
    SM_SEND_OUTPUT
  );

  signal state : state_t;

  signal din_last_store : std_logic;

begin

  p_prog_b_taps : process(clk)
  begin
    if rising_edge(clk) then
      if b_tap_wr = '1' and unsigned(b_tap_addr) < G_NUM_B_TAPS then
        b_taps(to_integer(unsigned(b_tap_addr))) <= signed(b_tap_val);
      end if;
    end if;
  end process;

  p_prog_a_taps : process(clk)
  begin
    if rising_edge(clk) then
      if a_tap_wr = '1' and unsigned(a_tap_addr) < G_NUM_A_TAPS then
        a_taps(to_integer(unsigned(a_tap_addr))) <= signed(a_tap_val);
      end if;
    end if;
  end process;

  s_iir_tready <=
    m_iir_tready when bypass = '1' else
    '1' when state = SM_GET_INPUT
    else '0';

  m_iir_tdata <=
    s_iir_tdata when bypass = '1' else
    std_logic_vector(resize(shift_right(y_accum, G_TAP_DWIDTH-G_TAP_INTEGER_BITS-1), G_DWIDTH));

  m_iir_tdata_full <= std_logic_vector(y_accum);

  m_iir_tvalid <=
    s_iir_tvalid when bypass = '1' else
    '1' when state = SM_SEND_OUTPUT else
    '0';

  m_iir_tlast <=
    s_iir_tlast when bypass = '1' else
    '1' when state = SM_SEND_OUTPUT and din_last_store = '1' else
    '0';

  p_state_machine : process(clk)
    variable v_mult_input_tap   : signed(G_TAP_DWIDTH-1 downto 0);
    variable v_mult_input_store : signed(G_DWIDTH-1 downto 0);
    variable v_mult_output      : signed(G_DWIDTH+G_TAP_DWIDTH-1 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' or bypass = '1' then
        for i in 0 to G_NUM_B_TAPS-1 loop
          x_store(i) <= (others => '0');
        end loop;

        for i in 0 to G_NUM_A_TAPS-1 loop
          y_store(i) <= (others => '0');
        end loop;

        din_last_store  <= '0';
        state           <= SM_INIT;

      else
        case state is
          when SM_INIT =>
            state <= SM_GET_INPUT;

          when SM_GET_INPUT =>
            if s_iir_tvalid = '1' then
              sm_loop_counter     <= to_unsigned(1, sm_loop_counter'length);
              y_accum             <= (others => '0');
              x_store(0)          <= signed(s_iir_tdata);
              din_last_store      <= s_iir_tlast;
              v_mult_input_tap    := a_taps(1);
              v_mult_input_store  := y_store(1);
              state               <= SM_A_ACCUM_MULT;
            end if;

          when SM_A_ACCUM_MULT =>
            sm_loop_counter <= sm_loop_counter + 1;
            v_mult_output   := v_mult_input_tap * v_mult_input_store;
            state           <= SM_A_ACCUM_ADD;

          when SM_A_ACCUM_ADD =>
            y_accum <= y_accum - v_mult_output;
            if sm_loop_counter = G_NUM_A_TAPS then
              sm_loop_counter     <= (others => '0');
              v_mult_input_tap    := b_taps(0);
              v_mult_input_store  := x_store(0);
              state               <= SM_B_ACCUM_MULT;
            else
              v_mult_input_tap    := a_taps(to_integer(sm_loop_counter));
              v_mult_input_store  := y_store(to_integer(sm_loop_counter));
              state               <= SM_A_ACCUM_MULT;
            end if;

          when SM_B_ACCUM_MULT =>
            sm_loop_counter <= sm_loop_counter + 1;
            v_mult_output   := v_mult_input_tap * v_mult_input_store;
            state           <= SM_B_ACCUM_ADD;

          when SM_B_ACCUM_ADD =>
            y_accum <= y_accum + v_mult_output;
            if sm_loop_counter = G_NUM_B_TAPS then
              sm_loop_counter     <= (others => '0');
              state               <= SM_SEND_OUTPUT;
            else
              v_mult_input_tap    := b_taps(to_integer(sm_loop_counter));
              v_mult_input_store  := x_store(to_integer(sm_loop_counter));
              state               <= SM_B_ACCUM_MULT;
            end if;

          when SM_SEND_OUTPUT =>
            if m_iir_tready = '1' then

              din_last_store  <= '0';

              for i in 1 to G_NUM_B_TAPS-1 loop
                x_store(i)    <= x_store(i-1);
              end loop;

              y_store(1)      <= resize(shift_right(y_accum, G_TAP_DWIDTH-G_TAP_INTEGER_BITS-1), G_DWIDTH);
              for i in 2 to G_NUM_A_TAPS-1 loop
                y_store(i)    <= y_store(i-1);
              end loop;

              state           <= SM_GET_INPUT;

            end if;

        end case;
      end if;
    end if;
  end process;

end rtl;
