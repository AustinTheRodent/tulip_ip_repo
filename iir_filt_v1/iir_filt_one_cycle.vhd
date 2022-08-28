library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_filt is
  generic
  (
    G_DWIDTH            : integer range 16 to 64  := 16;
    G_DEGREE            : integer range 2 to 8    := 8;
    G_TAP_INT_BITS      : integer range 2 to 16   := 8;
    G_TAP_DECIMAL_BITS  : integer range 2 to 24   := 16
  );
  port
  (
    clk         : in  std_logic;
    reset       : in  std_logic;
    enable      : in  std_logic;
    bypass      : in  std_logic;

    b_tap_val   : in  std_logic_vector(G_TAP_INT_BITS+G_TAP_DECIMAL_BITS-1 downto 0);
    b_tap_wr    : in  std_logic;
    b_tap_done  : out std_logic;

    a_tap_val   : in  std_logic_vector(G_TAP_INT_BITS+G_TAP_DECIMAL_BITS-1 downto 0);
    a_tap_wr    : in  std_logic;
    a_tap_done  : out std_logic;

    din         : in  std_logic_vector(G_DWIDTH-1 downto 0);
    din_valid   : in  std_logic;
    din_ready   : out std_logic;
    din_last    : in  std_logic;

    dout        : out std_logic_vector(G_DWIDTH-1 downto 0);
    dout_valid  : out std_logic;
    dout_ready  : in  std_logic;
    dout_last   : out std_logic
  );
end entity;

architecture rtl of iir_filt is

  signal dout_int       : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_valid_int : std_logic;
  signal dout_last_int  : std_logic;
  signal din_ready_int  : std_logic;
  signal b_tap_done_int : std_logic;
  signal a_tap_done_int : std_logic;

  signal dout_int_long  : std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS+G_DEGREE-1 downto 0);
  signal dout_int_shift : std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS+G_DEGREE-1 downto 0);
  signal dout_int_short : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_int_round : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_int_clip  : std_logic_vector(G_DWIDTH-1 downto 0);

  type taps_reg_t is array(0 to G_DEGREE-1) of std_logic_vector(G_TAP_INT_BITS+G_TAP_DECIMAL_BITS-1 downto 0);
  signal taps_reg_b : taps_reg_t;
  signal taps_reg_a : taps_reg_t;

  type mul_wire_t is array(0 to G_DEGREE-1) of std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS-1 downto 0);
  signal mul_wire_b : mul_wire_t;
  signal mul_wire_a : mul_wire_t;

  type add_wire_t is array(0 to G_DEGREE-2) of std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS+G_DEGREE-1 downto 0);
  signal add_wire : add_wire_t;

  signal zeros : std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS+G_DEGREE-1 downto 0);

  type delay_reg_t is array(0 to G_DEGREE-2) of std_logic_vector(G_DWIDTH+G_TAP_INT_BITS+G_TAP_DECIMAL_BITS+G_DEGREE-1 downto 0);
  signal delay_reg : delay_reg_t;

  --type state_t is (calc_b)

begin

  zeros <= (others => '0');

  mul_wire_a(0) <= (others => '0');

  p_program_a_taps : process(clk)
    variable v_taps_counter : integer range 0 to G_DEGREE;
  begin
    if rising_edge(clK) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-1 loop
          taps_reg_a(i) <= (others => '0');
        end loop;
        a_tap_done_int <= '0';
        v_taps_counter := 1;
      else
        if a_tap_wr = '1' and a_tap_done_int = '0' then
          taps_reg_a(v_taps_counter) <= a_tap_val;
          if v_taps_counter = G_DEGREE-1 then
            a_tap_done_int <= '1';
          end if;
          v_taps_counter := v_taps_counter + 1;
        end if;
      end if;
    end if;
  end process;

  p_program_b_taps : process(clk)
    variable v_taps_counter : integer range 0 to G_DEGREE;
  begin
    if rising_edge(clK) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-1 loop
          taps_reg_b(i) <= (others => '0');
        end loop;
        b_tap_done_int <= '0';
        v_taps_counter := 0;
      else
        if b_tap_wr = '1' and b_tap_done_int = '0' then
          taps_reg_b(v_taps_counter) <= b_tap_val;
          if v_taps_counter = G_DEGREE-1 then
            b_tap_done_int <= '1';
          end if;
          v_taps_counter := v_taps_counter + 1;
        end if;
      end if;
    end if;
  end process;

  g_mult_b_taps : for i in 0 to G_DEGREE-1 generate
    mul_wire_b(i) <= std_logic_vector(signed(taps_reg_b(i))*signed(din));
  end generate;

  g_mult_a_taps : for i in 1 to G_DEGREE-1 generate
    mul_wire_a(i) <= std_logic_vector((signed(not taps_reg_a(i))+1)*signed(dout_int));
  end generate;


  add_wire(G_DEGREE-2) <= std_logic_vector(signed(mul_wire_b(G_DEGREE-1)) + signed(mul_wire_a(G_DEGREE-1)) + signed(zeros));

  g_add_wires : for i in G_DEGREE-3 downto 0 generate
    add_wire(i) <= std_logic_vector(signed(mul_wire_b(i+1)) + signed(mul_wire_a(i+1)) + signed(delay_reg(i+1)));
  end generate;

  p_delay_reg : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-2 loop
          delay_reg(i) <= (others => '0');
        end loop;
      else
        if din_valid = '1' and din_ready_int = '1' then
          for i in 0 to G_DEGREE-2 loop
            delay_reg(i) <= add_wire(i);
          end loop;
        end if;
      end if;
    end if;
  end process;

  dout_int_long   <= std_logic_vector(signed(delay_reg(0)) + signed(mul_wire_b(0)));
  dout_int_shift  <= std_logic_vector(shift_right(signed(dout_int_long), G_TAP_DECIMAL_BITS));
  dout_int_short  <= dout_int_shift(dout_int'range);

  dout_int_round <=
    std_logic_vector(signed(dout_int_short) + 1) when dout_int_long(G_TAP_DECIMAL_BITS-1) = '1' else
    dout_int_short;

  dout_int_clip <=
    (others => '0')                                                       when to_integer(signed(dout_int_round)) = 0 else
    std_logic_vector(shift_left(to_unsigned(1, G_DWIDTH), G_DWIDTH-1)-1)  when dout_int_long(dout_int_long'length-1) = '0' and dout_int_round(G_DWIDTH-1) = '1' else
    std_logic_vector(shift_left(to_unsigned(1, G_DWIDTH), G_DWIDTH-1))    when dout_int_long(dout_int_long'length-1) = '1' and dout_int_round(G_DWIDTH-1) = '0' else
    dout_int_round;

  dout_int <=
    din when bypass = '1' else
    dout_int_clip;

  dout_valid_int <=
    din_valid when bypass = '1' else
    din_valid when b_tap_done_int = '1' and a_tap_done_int = '1' else
    '0';

  dout_last_int <=
    din_last  when bypass = '1' else
    din_last  when b_tap_done_int = '1' and a_tap_done_int = '1' else
    '0';

  din_ready_int <=
    dout_ready  when bypass = '1' else
    dout_ready  when b_tap_done_int = '1' and a_tap_done_int = '1' else
    '0';

  dout        <= dout_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;
  din_ready   <= din_ready_int;

  a_tap_done  <= a_tap_done_int;
  b_tap_done  <= b_tap_done_int;

end rtl;
