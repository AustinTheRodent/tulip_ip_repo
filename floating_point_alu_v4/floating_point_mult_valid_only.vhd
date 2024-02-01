library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity floating_point_mult_valid_only is
  port
  (
    clk             : in  std_logic;
    reset           : in  std_logic;
    enable          : in  std_logic;

    din1            : in  std_logic_vector(31 downto 0);
    din2            : in  std_logic_vector(31 downto 0);
    din_valid       : in  std_logic;

    dout            : out std_logic_vector(31 downto 0);
    dout_valid      : out std_logic
  );
end entity;

architecture rtl of floating_point_mult_valid_only is

  constant C_EXP_BIAS         : integer := 127;
  constant C_EXP_LEN          : integer := 8; -- [bits]
  constant C_MANT_LEN         : integer := 23; -- [bits], without implied 1

  signal din1_sign            : std_logic;
  signal din1_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din1_mantissa        : std_logic_vector(C_MANT_LEN downto 0);
  signal din2_sign            : std_logic;
  signal din2_exponent        : std_logic_vector(C_EXP_LEN-1 downto 0);
  signal din2_mantissa        : std_logic_vector(C_MANT_LEN downto 0);

  signal sign                 : std_logic;
  signal sign_buff            : std_logic;

  signal exponent_added       : std_logic_vector(C_EXP_LEN+1 downto 0);
  signal exponent_added_buff  : std_logic_vector(C_EXP_LEN+1 downto 0);
  signal exponent_norm        : std_logic_vector(C_EXP_LEN+1 downto 0);
  signal exponent_ufl         : std_logic;
  signal exponent_ofl         : std_logic;
  signal exponent_short       : std_logic_vector(C_EXP_LEN-1 downto 0);

  signal mantissa_mult        : std_logic_vector((C_MANT_LEN+1)*2-1 downto 0);
  signal mantissa_mult_buff   : std_logic_vector((C_MANT_LEN+1)*2-1 downto 0);
  signal mantissa_norm        : std_logic_vector((C_MANT_LEN+1)*2-1 downto 0);
  signal mantissa_round       : std_logic_vector((C_MANT_LEN+1)*2-1 downto 0);
  signal mantissa_short       : std_logic_vector(C_MANT_LEN downto 0);
  signal mantissa_mult_ofl    : std_logic;

begin

  din1_sign     <= din1(din1'left);
  din1_exponent <= din1(din1'left-1 downto din1'left-C_EXP_LEN);
  din1_mantissa <= '1' & din1(C_MANT_LEN-1 downto 0);

  din2_sign     <= din2(din2'left);
  din2_exponent <= din2(din2'left-1 downto din2'left-C_EXP_LEN);
  din2_mantissa <= '1' & din2(C_MANT_LEN-1 downto 0);

  sign <=
    '0' when unsigned(din1) = 0 or unsigned(din2) = 0 else
    din1_sign xor din2_sign;

  exponent_added <=
    (others => '0') when unsigned(din1) = 0 or unsigned(din2) = 0 else
    std_logic_vector(unsigned("00" & din1_exponent) + unsigned("00" & din2_exponent) - to_unsigned(C_EXP_BIAS, C_EXP_LEN+2));

  mantissa_mult <=
    (others => '0') when unsigned(din1) = 0 or unsigned(din2) = 0 else
    std_logic_vector(unsigned(din1_mantissa) * unsigned(din2_mantissa));

  p_buffer : process(clk)
  begin
    if rising_edge(clk) then
      sign_buff           <= sign;
      exponent_added_buff <= exponent_added;
      mantissa_mult_buff  <= mantissa_mult;
      dout_valid          <= din_valid;
    end if;
  end process;

  mantissa_mult_ofl   <= mantissa_mult_buff(mantissa_mult_buff'left);

  exponent_norm <=
    exponent_added_buff when mantissa_mult_ofl = '0' else
    std_logic_vector(unsigned(exponent_added_buff) + 1);

  exponent_ufl <= exponent_norm(exponent_norm'left);
  exponent_ofl <= exponent_norm(exponent_norm'left-1);

  mantissa_norm <=
    std_logic_vector(shift_right(unsigned(mantissa_mult_buff), C_MANT_LEN)) when mantissa_mult_ofl = '0' else
    std_logic_vector(shift_right(unsigned(mantissa_mult_buff), C_MANT_LEN+1));

  mantissa_round <= mantissa_norm;
    --mantissa_norm when exponent_ofl = '0' and mantissa_mult_buff(C_MANT_LEN-1) = '0' else
    --mantissa_norm when exponent_ofl = '1' and mantissa_mult_buff(C_MANT_LEN) = '0' else
    --std_logic_vector(unsigned(mantissa_norm) + 1);
    -- todo: this causes an error when rounding causes an overflow... fuck

  exponent_short <=
    (others => '0') when exponent_ufl = '1' else
    (others => '1') when exponent_ofl = '1' else
    exponent_norm(exponent_short'range);

  mantissa_short <=
    (others => '0') when exponent_ufl = '1' or exponent_ofl = '1' else
    mantissa_round(mantissa_short'range);

  dout <= sign_buff & exponent_short & mantissa_short(C_MANT_LEN-1 downto 0);

end rtl;
