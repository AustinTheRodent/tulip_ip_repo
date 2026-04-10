
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_mult is
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

architecture rtl of fp_mult is

  constant C_BIAS     : signed := to_signed(2**(G_EXP_LEN-1)-1, G_EXP_LEN+2);

  signal sign1        : std_logic;
  signal exp1         : unsigned(G_EXP_LEN-1 downto 0);
  signal exp1_signed  : signed(G_EXP_LEN+1 downto 0);
  signal mant1        : unsigned(G_MANT_LEN-1 downto 0);
  signal sign2        : std_logic;
  signal exp2         : unsigned(G_EXP_LEN-1 downto 0);
  signal exp2_signed  : signed(G_EXP_LEN+1 downto 0);
  signal mant2        : unsigned(G_MANT_LEN-1 downto 0);

  signal mant_mult        : unsigned(G_MANT_LEN*2-1 downto 0);
  signal mant_mult_rs     : unsigned(G_MANT_LEN*2-1 downto 0);
  signal mant_mult_norm   : unsigned(G_MANT_LEN*2-1 downto 0);
  signal mant_mult_round0 : unsigned(G_MANT_LEN*2-1 downto 0);
  signal mant_mult_round1 : unsigned(G_MANT_LEN*2-1 downto 0);
  signal exp_mult         : signed(G_EXP_LEN+1 downto 0);
  signal exp_norm         : signed(G_EXP_LEN+1 downto 0);
  signal exp_round0       : signed(G_EXP_LEN+1 downto 0);
  signal exp_round1       : signed(G_EXP_LEN+1 downto 0);
  signal sign_mult        : std_logic;

  signal g            : std_logic;
  signal r            : std_logic;
  signal s            : std_logic;
  signal g_norm       : std_logic;
  signal r_norm       : std_logic;
  signal s_norm       : std_logic;

  signal lsb          : std_logic;

begin

  sign1 <= din1(din1'left);
  sign2 <= din2(din1'left);

  exp1  <= unsigned(din1(G_EXP_LEN+G_MANT_LEN-2 downto G_MANT_LEN-1));
  exp2  <= unsigned(din2(G_EXP_LEN+G_MANT_LEN-2 downto G_MANT_LEN-1));

  exp1_signed <= signed("00" & exp1);
  exp2_signed <= signed("00" & exp2);

  mant1 <= unsigned('1' & din1(G_MANT_LEN-2 downto 0));
  mant2 <= unsigned('1' & din2(G_MANT_LEN-2 downto 0));

-------------------------------------------------------------

  process(clk)
  begin
    if rising_edge(clk) then
      mant_mult   <= mant1 * mant2;
      exp_mult    <= exp1_signed + exp2_signed - C_BIAS;
      sign_mult   <= sign1 xor sign2;
      dout_valid  <= din_valid;
    end if;
  end process;

-------------------------------------------------------------
  -- Normalization:

  mant_mult_rs <= shift_right(mant_mult, G_MANT_LEN-1);

  g <= mant_mult(G_MANT_LEN-2);
  r <= mant_mult(G_MANT_LEN-3);
  s <=
    '1' when mant_mult(G_MANT_LEN-4 downto 0) /= 0 else
    '0';

  g_norm <=
    mant_mult_rs(0) when mant_mult_rs(G_MANT_LEN) = '1' else
    g;

  r_norm <=
    g when mant_mult_rs(G_MANT_LEN) = '1' else
    r;

  s_norm <=
    s or r when mant_mult_rs(G_MANT_LEN) = '1' else
    s;

  mant_mult_norm <=
    shift_right(mant_mult_rs, 1) when mant_mult_rs(G_MANT_LEN) = '1' else
    mant_mult_rs;

  exp_norm <=
    exp_mult + 1 when mant_mult_rs(G_MANT_LEN) = '1' else
    exp_mult;

-------------------------------------------------------------
 -- Round to Nearest Even

  lsb <= mant_mult_norm(0);

  mant_mult_round0 <=
    mant_mult_norm + 1 when (g_norm = '1') and ((r_norm or s_norm) = '1' or lsb = '1') else
    mant_mult_norm;

  mant_mult_round1 <=
    shift_right(mant_mult_round0, 1) when mant_mult_round0(G_MANT_LEN) = '1' else
    mant_mult_round0;

  exp_round0 <=
    exp_norm + 1 when mant_mult_round0(G_MANT_LEN) = '1' else
    exp_norm;

  exp_round1 <=
    to_signed((2**G_EXP_LEN) - 1, exp_round1'length) when exp_round0 >= 2**G_EXP_LEN else
    exp_round0;

  dout <=
    (others => '0') when exp_mult < 0 else
    sign_mult & std_logic_vector(exp_round1(G_EXP_LEN-1 downto 0)) & std_logic_vector(mant_mult_round1(G_MANT_LEN-2 downto 0));

end rtl;


















