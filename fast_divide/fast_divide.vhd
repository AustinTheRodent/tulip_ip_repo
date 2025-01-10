library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fast_divide_unit is
  generic
  (
    G_I           : integer := 15;
    G_DWIDTH      : integer := 16
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;

    valid_in      : in  std_logic;
    N_in          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    D_in          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    N_approx_in   : in  std_logic_vector(G_DWIDTH-1 downto 0);
    Q_in          : in  std_logic_vector(G_DWIDTH-1 downto 0);

    valid_out     : out std_logic;
    N_out         : out std_logic_vector(G_DWIDTH-1 downto 0);
    D_out         : out std_logic_vector(G_DWIDTH-1 downto 0);
    N_approx_out  : out std_logic_vector(G_DWIDTH-1 downto 0);
    Q_out         : out std_logic_vector(G_DWIDTH-1 downto 0)
  );
end entity;

architecture rtl of fast_divide_unit is

  constant C_ONE        : unsigned(0 downto 0) := "1";

  signal D_long         : unsigned(2*G_DWIDTH-1 downto 0);
  signal N_approx_long  : unsigned(2*G_DWIDTH-1 downto 0);
  signal tmp            : unsigned(2*G_DWIDTH-1 downto 0);
  signal r              : std_logic;

begin

  D_long        <= shift_left(resize(unsigned(D_in), D_long'length), G_I);
  N_approx_long <= resize(unsigned(N_approx_in), N_approx_long'length);

  tmp           <= D_long + N_approx_long;

  r             <= '1' when tmp <= unsigned(N_in) else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        valid_out <= '0';
      else
        valid_out <= valid_in;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then

      D_out     <= D_in;
      N_out     <= N_in;

      if r = '1' then
        N_approx_out  <= std_logic_vector(resize(tmp, N_approx_out'length));
        Q_out         <= Q_in or std_logic_vector(resize(C_ONE, G_DWIDTH));
      else
        N_approx_out  <= N_approx_in;
        Q_out         <= Q_in;
      end if;

    end if;
  end process;


end rtl;

---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fast_divide is
  generic
  (
    G_DWIDTH      : integer := 16
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;

    valid_in      : in  std_logic;
    N_in          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    D_in          : in  std_logic_vector(G_DWIDTH-1 downto 0);

    valid_out     : out std_logic;
    Q_out         : out std_logic_vector(G_DWIDTH-1 downto 0)
  );
end entity;

architecture rtl of fast_divide is

  type data_t is array (0 to G_DWIDTH-1) of std_logic_vector(G_DWIDTH-1 downto 0);

  signal core_valid_in      : std_logic_vector(G_DWIDTH-1 downto 0);
  signal core_N_in          : data_t;
  signal core_D_in          : data_t;
  signal core_N_approx_in   : data_t;
  signal core_Q_in          : data_t;

  signal core_valid_out     : std_logic_vector(G_DWIDTH-1 downto 0);
  signal core_N_out         : data_t;
  signal core_D_out         : data_t;
  signal core_N_approx_out  : data_t;
  signal core_Q_out         : data_t;

begin

  core_valid_in(0)     <= valid_in;
  core_N_in(0)         <= N_in;
  core_D_in(0)         <= D_in;
  core_N_approx_in(0)  <= (others => '0');
  core_Q_in(0)         <= (others => '0');

  valid_out       <= core_valid_out(G_DWIDTH-1);
  Q_out           <= core_Q_out(G_DWIDTH-1);

  gen_connection : for i in 0 to G_DWIDTH-2 generate
    core_valid_in(i+1)     <= core_valid_out(i);
    core_N_in(i+1)         <= core_N_out(i);
    core_D_in(i+1)         <= core_D_out(i);
    core_N_approx_in(i+1)  <= core_N_approx_out(i);
    core_Q_in(i+1)         <= core_Q_out(i);
  end generate;

  gen_lineup : for i in 0 to G_DWIDTH-1 generate

    u_fast_divide_unit : entity work.fast_divide_unit
    generic map
    (
      G_I           => G_DWIDTH-1-i,
      G_DWIDTH      => G_DWIDTH
    )
    port map
    (
      clk           => clk,
      reset         => reset,

      valid_in      => core_valid_in(i),
      N_in          => core_N_in(i),
      D_in          => core_D_in(i),
      N_approx_in   => core_N_approx_in(i),
      Q_in          => core_Q_in(i),

      valid_out     => core_valid_out(i),
      N_out         => core_N_out(i),
      D_out         => core_D_out(i),
      N_approx_out  => core_N_approx_out(i),
      Q_out         => core_Q_out(i)
    );

  end generate;

end rtl;



