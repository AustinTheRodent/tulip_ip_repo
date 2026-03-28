
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_add is
  generic
  (
    G_EXP_LEN   : integer range 4 to 16 := 8;
    G_MANT_LEN  : integer range 16 to 32 := 24
  );
  port
  (
    clk         : in std_logic;
    reset       : in std_logic;

    din1        : in std_logic_vector(G_EXP_LEN+G_MANT_LEN-1 downto 0);
    din2        : in std_logic_vector(G_EXP_LEN+G_MANT_LEN-1 downto 0);
    din_valid   : in std_logic;

    dout        : out std_logic_vector(G_EXP_LEN+G_MANT_LEN-1 downto 0);
    dout_valid  : out std_logic
  );
end entity;

architecture rtl of fp_add is

  signal sign1        : std_logic;
  signal exp1         : unsigned(G_EXP_LEN-1 downto 0);
  signal mant1        : unsigned(G_MANT_LEN-1 downto 0);
  signal sign2        : std_logic;
  signal exp2         : unsigned(G_EXP_LEN-1 downto 0);
  signal mant2        : unsigned(G_MANT_LEN-1 downto 0);

  signal sign1_swap   : std_logic;
  signal exp1_swap    : unsigned(G_EXP_LEN-1 downto 0);
  signal mant1_swap   : unsigned(G_MANT_LEN-1 downto 0);
  signal sign2_swap   : std_logic;
  signal exp2_swap    : unsigned(G_EXP_LEN-1 downto 0);
  signal mant2_swap   : unsigned(G_MANT_LEN-1 downto 0);

  -- g is tenths digit
  -- r is hundredths digit
  -- s is anything less than the hundedths
  signal g            : std_logic;
  signal r            : std_logic;
  signal s            : std_logic;

  signal frac         : std_logic_vector(3 downto 0);
  signal grs          : std_logic_vector(3 downto 0);
  signal g_frac       : std_logic;
  signal r_frac       : std_logic;
  signal s_frac       : std_logic;

  signal shift        : unsigned(G_EXP_LEN-1 downto 0);

  signal mant2_shift  : unsigned(G_MANT_LEN-1 downto 0);
  signal mant_added   : unsigned(G_MANT_LEN+1-1 downto 0);
  signal mant_shifted : unsigned(G_MANT_LEN+2+1-1 downto 0);
  signal mant_norm    : unsigned(G_MANT_LEN+1-1 downto 0);
  signal mant_round0  : unsigned(G_MANT_LEN+1-1 downto 0);
  signal mant_round1  : unsigned(G_MANT_LEN+1-1 downto 0);
  signal exp_added    : unsigned(G_EXP_LEN+1-1 downto 0);
  signal exp_norm     : unsigned(G_EXP_LEN-1 downto 0);
  signal exp_round    : unsigned(G_EXP_LEN-1 downto 0);
  signal sign_round   : std_logic;
  signal g_norm       : std_logic;
  signal r_norm       : std_logic;
  signal s_norm       : std_logic;

  signal lshift_count : unsigned(7 downto 0);

  constant C_Z        : std_logic_vector(64-(G_MANT_LEN+1)-1 downto 0) := (others => '0');
  constant C_ZL       : unsigned(7 downto 0) := to_unsigned(64-G_MANT_LEN-1, 8);

begin

  sign1 <= din1(din1'left);
  sign2 <= din2(din1'left);

  exp1  <= unsigned(din1(G_EXP_LEN+G_MANT_LEN-2 downto G_MANT_LEN-1));
  exp2  <= unsigned(din2(G_EXP_LEN+G_MANT_LEN-2 downto G_MANT_LEN-1));

  mant1 <= unsigned('1' & din1(G_MANT_LEN-2 downto 0));
  mant2 <= unsigned('1' & din2(G_MANT_LEN-2 downto 0));

-------------------------------------------------------------

  sign1_swap  <= sign2 when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else sign1;
  sign2_swap  <= sign1 when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else sign2;

  exp1_swap   <= exp2  when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else exp1;
  exp2_swap   <= exp1  when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else exp2;

  mant1_swap  <= mant2 when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else mant1;
  mant2_swap  <= mant1 when (exp1 < exp2) or ((exp1 = exp2) and (mant1 < mant2)) else mant2;

-------------------------------------------------------------

  shift <= exp1_swap - exp2_swap;

  g <=
    mant2_swap(to_integer(shift)-1) when shift >= 1 and shift <= 24 else
    '0';

  r <=
    mant2_swap(to_integer(shift)-2) when shift >= 2 and shift <= 24 else
    '0';

  s <=
    '1' when shift >= 24 else
    '1' when mant2_swap(to_integer(shift)-3 downto 0) /= 0 and shift >= 3 else
    '0';

  mant2_shift <= shift_right(mant2_swap, to_integer(shift));

-------------------------------------------------------------

  grs   <= '0' & g & r & s;
  frac  <= std_logic_vector(unsigned(x"8") - unsigned(grs));

  process(clk)
  begin
    if rising_edge(clk) then

      if sign1_swap = sign2_swap then
        mant_added  <= resize(mant1_swap, G_MANT_LEN+1) + resize(mant2_shift, G_MANT_LEN+1);
        g_frac      <= g;
        r_frac      <= r;
        s_frac      <= s;
      elsif (g or r or s) = '1' then
        -- Compute the 'fractional' remainder for rounding
        -- 2's complement style: (1.000 - 0.GRS)
        mant_added  <= resize(mant1_swap - mant2_shift - 1, G_MANT_LEN+1);
        g_frac      <= frac(2);
        r_frac      <= frac(1);
        s_frac      <= frac(0);
      else
        mant_added  <= resize(mant1_swap - mant2_shift, G_MANT_LEN+1);
        g_frac      <= '0';
        r_frac      <= '0';
        s_frac      <= '0';
      end if;

      exp_added <= resize(exp1, G_EXP_LEN+1);

      sign_round <= sign1_swap;

      --mant_added <=
      --  mant1_swap + mant2_shift when sign1_swap = sign2_swap else
      --  mant1_swap - mant2_shift - 1 when (g or r or s) = '1' else
      --  mant1_swap - mant2_shift;
      --
      ---- Compute the 'fractional' remainder for rounding
      ---- 2's complement style: (1.000 - 0.GRS)
      --
      --g_frac <=
      --  g when sign1_swap = sign2_swap else
      --  frac(2) when (g or r or s) = '1' else
      --  '0';
      --
      --r_frac <=
      --  r when sign1_swap = sign2_swap else
      --  frac(1) when (g or r or s) = '1' else
      --  '0';
      --
      --s_frac <=
      --  s when sign1_swap = sign2_swap else
      --  frac(0) when (g or r or s) = '1' else
      --  '0';

    end if;
  end process;

-------------------------------------------------------------
  -- Normalization:

  lshift_count <= get_leading_zeros64(C_Z & std_logic_vector(mant_added)) - C_ZL;

  mant_shifted <= shift_left(mant_added & g_frac & r_frac, to_integer(lshift_count)-1);

  mant_norm <=
    shift_right(mant_added, 1) when lshift_count = 0 else
    mant_shifted(mant_shifted'left downto mant_shifted'length-mant_norm'length);

  exp_norm <=
    exp_added + 1 when lshift_count = 0 else
    exp_added - (lshift_count - 1);

  g_norm <=
    mant_added(0) when lshift_count = 0 else
    g_frac when lshift_count = 1 else
    r_frac when lshift_count = 2 else
    '0';

  r_norm <=
    g_frac when lshift_count = 0 else
    r_frac when lshift_count = 1 else
    '0';

  s_norm <=
    s_frac or r_frac when lshift_count = 0 else
    s_frac;

-------------------------------------------------------------

 -- Round to Nearest Even

  mant_round0 <=
    mant_norm + 1 when g = '1' and ((r or s) = '1' or mant_norm(0) = '1') else
    mant_norm;

  mant_round1 <=
    shift_right(mant_round0, 1) when mant_round0(mant_round0'left) = '1' else
    mant_round0;

  exp_round <=
    exp_norm + 1 when mant_round0(mant_round0'left) = '1' else
    exp_norm;

  dout <= sign_round & std_logic_vector(mant_round1(G_MANT_LEN-2 downto 0)) & std_logic_vector(exp_round(G_EXP_LEN-1 downto 0));

end rtl;

