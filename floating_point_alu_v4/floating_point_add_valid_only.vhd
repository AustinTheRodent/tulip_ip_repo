library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_add_valid_only is
  port
  (
    clk             : in  std_logic;

    din1            : in  std_logic_vector(31 downto 0);
    din2            : in  std_logic_vector(31 downto 0);
    din_valid       : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic
  );
end entity;

architecture rtl of floating_point_add_valid_only is

  function encode_bit_pairs
  (
    input_vector : in std_logic_vector(1 downto 0)
  ) return std_logic_vector is
  begin
    case input_vector is
      when "00" =>
        return "10";
      when "01" =>
        return "01";
      when others =>
        return "00";
    end case;
  end function;

  function assemble
  (
    input_vector_left   : in std_logic_vector;
    input_vector_right  : in std_logic_vector
  ) return std_logic_vector is
    variable v_left_bits  : std_logic_vector(1 downto 0);
    variable v_zeros      : std_logic_vector(input_vector_left'range);
  begin
    v_left_bits := input_vector_left(input_vector_left'left) & input_vector_right(input_vector_right'left);
    v_zeros     := (others => '0');
    case v_left_bits is
      when "11" =>
        return '1' & v_zeros;
      when "01" =>
        return '0' & input_vector_left;
      when "00" =>
        return '0' & input_vector_left;
      when others =>
        return "01" & input_vector_right(input_vector_right'left-1 downto 0);
    end case;
  end function;

  function get_leading_zeros32
  (
    input_vector : in std_logic_vector(31 downto 0)
  ) return unsigned is

    type two_bit_pairs_t    is array (15 downto 0) of std_logic_vector(1 downto 0);
    type three_bit_array_t  is array ( 7 downto 0) of std_logic_vector(2 downto 0);
    type four_bit_array_t   is array ( 3 downto 0) of std_logic_vector(3 downto 0);
    type five_bit_array_t   is array ( 1 downto 0) of std_logic_vector(4 downto 0);

    variable v_two_bit_pairs    : two_bit_pairs_t;
    variable v_three_bit_array  : three_bit_array_t;
    variable v_four_bit_array   : four_bit_array_t;
    variable v_five_bit_array   : five_bit_array_t;
    variable v_output           : std_logic_vector(5 downto 0);
    variable v_return_value     : std_logic_vector(7 downto 0);

  begin

    for i in 15 downto 0 loop
      v_two_bit_pairs(i) := encode_bit_pairs(input_vector((i+1)*2-1 downto (i+1)*2-2));
    end loop;

    for i in 7 downto 0 loop
      v_three_bit_array(i) := assemble(v_two_bit_pairs((i+1)*2-1), v_two_bit_pairs((i+1)*2-2));
    end loop;

    for i in 3 downto 0 loop
      v_four_bit_array(i) := assemble(v_three_bit_array((i+1)*2-1), v_three_bit_array((i+1)*2-2));
    end loop;

    for i in 1 downto 0 loop
      v_five_bit_array(i) := assemble(v_four_bit_array((i+1)*2-1), v_four_bit_array((i+1)*2-2));
    end loop;

    v_output := assemble(v_five_bit_array(1), v_five_bit_array(0));
    v_return_value := "00" & v_output;
    return unsigned(v_return_value);

  end function;

  constant C_EXP_LEN          : integer := 8; -- [bits]
  constant C_MANT_LEN         : integer := 23; -- [bits], without implied 1

  signal din1_sign            : std_logic;
  signal din1_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_exponent_norm   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_exp_norm_buff   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_mantissa        : std_logic_vector(C_MANT_LEN downto 0);
  signal din1_mantissa_norm   : std_logic_vector(C_MANT_LEN downto 0);
  signal din2_sign            : std_logic;
  signal din2_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din2_exponent_norm   : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din2_mantissa        : std_logic_vector(C_MANT_LEN downto 0);
  signal din2_mantissa_norm   : std_logic_vector(C_MANT_LEN downto 0);

  signal d1_exp_islarger      : std_logic;
  signal d2_exp_islarger      : std_logic;

  signal exponent_diff        : unsigned(C_EXP_LEN-1 downto 0);

  signal mantissa_added       : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_added_buff  : std_logic_vector(C_MANT_LEN+1 downto 0);

  signal lefthand_count_final : unsigned(7 downto 0);

  signal sign                 : std_logic;
  signal sign_buff            : std_logic;

  signal exponent_norm        : std_logic_vector(C_EXP_LEN+1 downto 0);
  signal exponent_short       : std_logic_vector(C_EXP_LEN-1 downto 0);

  signal mantissa_norm        : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_round       : std_logic_vector(C_MANT_LEN+1 downto 0);
  signal mantissa_short       : std_logic_vector(C_MANT_LEN downto 0);

begin

  din1_sign     <= din1(din1'left);
  din1_exponent <= din1(din1'left-1 downto din1'left-C_EXP_LEN);
  din1_mantissa <= '1' & din1(C_MANT_LEN-1 downto 0);

  din2_sign     <= din2(din2'left);
  din2_exponent <= din2(din2'left-1 downto din2'left-C_EXP_LEN);
  din2_mantissa <= '1' & din2(C_MANT_LEN-1 downto 0);

  d1_exp_islarger <=
    '1' when unsigned(din1_exponent) > unsigned(din2_exponent) else
    '0';

  d2_exp_islarger <= not d1_exp_islarger;

  exponent_diff <=
    unsigned(din1_exponent) - unsigned(din2_exponent) when d1_exp_islarger = '1' else
    unsigned(din2_exponent) - unsigned(din1_exponent);

  din1_mantissa_norm <=
    (others => '0') when unsigned(din1(din1'left-1 downto 0)) = 0 else
    std_logic_vector(shift_right(unsigned(din1_mantissa), to_integer(exponent_diff))) when d2_exp_islarger = '1' else
    din1_mantissa;

  din2_mantissa_norm <=
    (others => '0') when unsigned(din2(din2'left-1 downto 0)) = 0 else
    std_logic_vector(shift_right(unsigned(din2_mantissa), to_integer(exponent_diff))) when d1_exp_islarger = '1' else
    din2_mantissa;

  din1_exponent_norm <=
    std_logic_vector(unsigned(din1_exponent) + exponent_diff) when d2_exp_islarger = '1' else
    din1_exponent;

  din2_exponent_norm <=
    std_logic_vector(unsigned(din2_exponent) + exponent_diff) when d1_exp_islarger = '1' else
    din2_exponent;

  mantissa_added <=
    --(others => '0') when 
    std_logic_vector(unsigned('0' & din1_mantissa_norm) + unsigned('0' & din2_mantissa_norm)) when din1_sign = din2_sign else
    std_logic_vector(unsigned('0' & din1_mantissa_norm) - unsigned('0' & din2_mantissa_norm)) when
      din1_sign /= din2_sign and unsigned(din1_mantissa_norm) >= unsigned(din2_mantissa_norm) else
    std_logic_vector(unsigned('0' & din2_mantissa_norm) - unsigned('0' & din1_mantissa_norm));

  sign <=
    '0' when din1_sign = '0' and din2_sign = '0' else
    '0' when din1_sign = '0' and din2_sign = '1' and din1_mantissa_norm >= din2_mantissa_norm else
    '0' when din1_sign = '1' and din2_sign = '0' and din2_mantissa_norm >= din1_mantissa_norm else
    '1';

  p_buffer : process(clk)
  begin
    if rising_edge(clk) then
      sign_buff           <= sign;
      din1_exp_norm_buff  <= din1_exponent_norm;
      mantissa_added_buff <= mantissa_added;
      dout_valid          <= din_valid;
    end if;
  end process;

  lefthand_count_final <= get_leading_zeros32( "0000000" & mantissa_added_buff) - x"07";

  mantissa_norm <=
    std_logic_vector(shift_right(unsigned(mantissa_added_buff), 1)) when lefthand_count_final = 0 else
    std_logic_vector(shift_left(unsigned(mantissa_added_buff), to_integer(lefthand_count_final - 1)));

  mantissa_round <= mantissa_norm;
    --std_logic_vector(unsigned(mantissa_norm) + 1) when lefthand_count_final = 0 and mantissa_added_buff(0) = '1' else
    --mantissa_norm;
    -- todo: this causes an error when rounding causes an overflow... fuck

  exponent_norm <=
    (others => '0') when unsigned(mantissa_norm) = 0 else
    std_logic_vector(unsigned("00" & din1_exp_norm_buff) + 1) when lefthand_count_final = 0 else
    std_logic_vector(unsigned("00" & din1_exp_norm_buff) - (lefthand_count_final - 1));

  exponent_short <=
    (others => '0') when exponent_norm(exponent_norm'left) = '1' else
    (others => '1') when exponent_norm(exponent_norm'left-1) = '1' else
    exponent_norm(exponent_short'range);

  mantissa_short <=
    (others => '0') when exponent_norm(exponent_norm'left) = '1' else
    (others => '0') when exponent_norm(exponent_norm'left-1) = '1' else
    mantissa_round(mantissa_short'range);

  dout <= sign_buff & exponent_short & mantissa_short(C_MANT_LEN-1 downto 0);

end rtl;
