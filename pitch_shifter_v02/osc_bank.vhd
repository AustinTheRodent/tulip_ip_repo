library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity osc_bank is
  generic
  (
    G_FREQ_MULT_INT : integer := 4;
    G_FREQ_MULT_DEC : integer := 12;
    G_DATA_WIDTH  : integer := 16;
    G_NUM_OSC     : integer := 128
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;

    freq_mult             : in  std_logic_vector(15 downto 0); -- fixed point 4.12

    s_axis_tdata          : in  std_logic_vector(255 downto 0);
    s_axis_tvalid         : in  std_logic;
    s_axis_tready         : out std_logic;

    m_axis_tdata          : out std_logic_vector(23 downto 0);
    m_axis_tvalid         : out std_logic;
    m_axis_tready         : in  std_logic
  );
end entity;

architecture rtl of osc_bank is

  type ROM is array (integer range <>) of std_logic_vector (G_DATA_WIDTH-1 downto 0);

  function initialize_ROM
  (
    num_osc : in integer
  ) return ROM is
    variable a        : real;
    variable b        : real;
    variable ret_rom  : ROM(0 to num_osc-1);
  begin

    for i in 0 to integer(num_osc)-1 loop

      a           := cos((MATH_PI/2.0) * (real(i)/(num_osc)));
      b           := real(a) * real(2**(G_DATA_WIDTH-1));

      if b >= real(2**(G_DATA_WIDTH-1)) then
        b := real(2**(G_DATA_WIDTH-1)-1);
      end if;

      ret_rom(i) := std_logic_vector(to_signed(integer(b), G_DATA_WIDTH));

    end loop;

    return ret_rom;

  end function;

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  signal mem : ROM(0 to G_NUM_OSC-1) := initialize_ROM(G_NUM_OSC);

  --type counter_bank_t is array (0 to G_NUM_OSC-1) of unsigned(8+clog2(G_NUM_OSC)-1 downto 0);
  --signal osc_counter_bank : counter_bank_t;

  signal global_counter : unsigned(G_FREQ_MULT_DEC+clog2(G_NUM_OSC)-1 downto 0);
  signal synth_counter  : unsigned(clog2(G_NUM_OSC)-1 downto 0);
  signal gs_mult        : unsigned(global_counter'length + synth_counter'length - 1 downto 0);
  signal gs_mult_rs     : unsigned(gs_mult'range);
  signal gs_mult_short  : unsigned(2+clog2(G_NUM_OSC)-1 downto 0);
  --signal gs_mult2       : unsigned(gs_mult_short'length + freq_mult'length - 1 downto 0);
  --signal gs_mult2_rs    : unsigned(gs_mult_short'length + freq_mult'length - 1 downto 0);
  --signal gs_mult2_short : unsigned(2+clog2(G_NUM_OSC)-1 downto 0);

  signal s_axis_tready_int : std_logic;

  type state_t is (SM_INIT, SM_GET_INPUT, SM_CALC_0, SM_WAIT_FOR_CALC, SM_REGISTER_OUTPUT, SM_SEND_OUTPUT);
  signal state : state_t;

  signal calc_valid   : std_logic;
  signal calc_valid0  : std_logic;
  signal calc_valid1  : std_logic;
  --signal calc_valid2  : std_logic;

  signal test_sig       : unsigned(G_DATA_WIDTH-1 downto 0);
  signal test_sig2      : unsigned(G_DATA_WIDTH-1 downto 0);
  signal test_sig_quad  : signed(G_DATA_WIDTH-1 downto 0);

  type osc_bank_array_t is array (0 to G_NUM_OSC-1) of signed(G_DATA_WIDTH-1 downto 0);
  signal osc_bank_array   : osc_bank_array_t;
  signal osc_bank_counter : unsigned(15 downto 0);

  signal accum_osc_out : signed(clog2(G_NUM_OSC)+G_DATA_WIDTH-1 downto 0);
  signal reset_accum_osc_out : std_logic;

  signal accum_osc_out_registered : signed(clog2(G_NUM_OSC)+G_DATA_WIDTH-1 downto 0);

begin

  process(clk)
  begin
    if rising_edge(clk) then
      calc_valid0 <= calc_valid;
      gs_mult     <= global_counter * synth_counter;
    end if;
  end process;

  gs_mult_rs    <= shift_right(gs_mult, G_FREQ_MULT_DEC-2); -- G_FREQ_MULT_DEC for the G_FREQ_MULT_DEC decimal bits in freq_mult and 2 because using 1/4 of sine LUT
  gs_mult_short <= gs_mult_rs(gs_mult_short'range);

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        osc_bank_counter <= (others => '0');
      else
        if calc_valid1 = '1' then
          if osc_bank_counter = G_NUM_OSC-1 then
            osc_bank_counter  <= (others => '0');
          else
            osc_bank_counter  <= osc_bank_counter + 1;
          end if;

          osc_bank_array(to_integer(osc_bank_counter)) <= test_sig_quad;

        end if;
      end if;
    end if;
  end process;

  test_sig  <= unsigned(mem(to_integer(gs_mult_short(clog2(G_NUM_OSC)-1 downto 0))));
  test_sig2 <= unsigned(mem(G_NUM_OSC-to_integer(gs_mult_short(clog2(G_NUM_OSC)-1 downto 0))-1));

  b_tmp : block
    constant C_SINE_ONE : signed(test_sig'length downto 0) := to_signed(2**(test_sig'length-1),test_sig'length+1);
    signal gs_case : std_logic_vector(1 downto 0);
  begin

    gs_case <= std_logic_vector(gs_mult_short(gs_mult_short'left downto gs_mult_short'left-1));

    process(clk)
    begin
      if rising_edge(clk) then

        calc_valid1 <= calc_valid0;

        case gs_case is
          when "00" =>
            test_sig_quad <= signed(test_sig);
          when "01" =>
            test_sig_quad <= -signed(test_sig2);
          when "10" =>
            test_sig_quad <= -signed(test_sig);
          when others =>
            test_sig_quad <= signed(test_sig2);
        end case;
      end if;
    end process;

  end block;

  p_accum_osc : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or reset_accum_osc_out = '1' then
        accum_osc_out <= (others => '0');
      else
        if calc_valid1 = '1' then
          accum_osc_out <= accum_osc_out + test_sig_quad;
        end if;
      end if;
    end if;
  end process;


  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        s_axis_tready   <= '0';
        m_axis_tvalid   <= '0';
        calc_valid      <= '0';
        reset_accum_osc_out <= '1';
        global_counter  <= (others => '0');
        state           <= SM_INIT;
      else
        case state is
          when SM_INIT =>
            s_axis_tready <= '1';
            reset_accum_osc_out <= '1';
            state         <= SM_GET_INPUT;

          when SM_GET_INPUT =>
            if s_axis_tvalid = '1' then
              calc_valid    <= '1';
              reset_accum_osc_out <= '0';
              synth_counter <= (others => '0');
              state         <= SM_CALC_0;
            end if;

          when SM_CALC_0 =>
            if synth_counter = G_NUM_OSC-1 then
              calc_valid      <= '0';
              state           <= SM_WAIT_FOR_CALC;
            else
              synth_counter <= synth_counter + 1;
            end if;

          when SM_WAIT_FOR_CALC =>
            if calc_valid1 = '1' and osc_bank_counter = G_NUM_OSC-1 then
              state           <= SM_REGISTER_OUTPUT;
            end if;

          when SM_REGISTER_OUTPUT =>
            accum_osc_out_registered  <= accum_osc_out;
            global_counter            <= global_counter + unsigned(freq_mult);
            m_axis_tvalid             <= '1';
            state                     <= SM_SEND_OUTPUT;


          when SM_SEND_OUTPUT =>
            if  m_axis_tready = '1' then
              s_axis_tready <= '1';
              reset_accum_osc_out <= '1';
              state         <= SM_GET_INPUT;
            end if;

        end case;
      end if;
    end if;
  end process;

--  process(clk)
--  begin
--    if rising_edge(clk) then
--      if reset = '1' then
--        for i in 0 to G_NUM_OSC-1 loop
--          osc_counter_bank(i) <= (others => '0');
--        end if;
--      else
--        if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
--          for i in 0 to G_NUM_OSC-1 loop
--            osc_counter_bank(i) <= osc_counter_bank(i) + i;
--          end if;
--        end if;
--      end if;
--    end if;
--  end process;


end rtl;
