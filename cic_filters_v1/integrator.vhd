library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrator is
  generic
  (
    G_INTEGRATOR_DWIDTH : integer := 24;
    G_DIN_DWIDTH        : integer := 24;
    G_DOUT_DWIDTH       : integer := 24
  );
  port
  (
    clk                 : in  std_logic;
    reset               : in  std_logic;
    bypass              : in  std_logic;

    s_integrator_tdata  : in  std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    s_integrator_tvalid : in  std_logic;
    s_integrator_tready : out std_logic;

    m_integrator_tdata  : out std_logic_vector(G_DOUT_DWIDTH-1 downto 0);
    m_integrator_tvalid : out std_logic;
    m_integrator_tready : in  std_logic

  );
end entity;

architecture rtl of integrator is

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  signal m_integrator_tdata_int   : std_logic_vector(G_INTEGRATOR_DWIDTH-1 downto 0);
  signal m_integrator_tvalid_int  : std_logic;
  signal dout_delay               : std_logic_vector(G_INTEGRATOR_DWIDTH-1 downto 0);

begin

  m_integrator_tdata_int  <= std_logic_vector(resize(signed(s_integrator_tdata), G_INTEGRATOR_DWIDTH) + signed(dout_delay));
  m_integrator_tdata      <= std_logic_vector(resize(signed(m_integrator_tdata_int), G_DOUT_DWIDTH));

  m_integrator_tvalid <= m_integrator_tvalid_int;

  m_integrator_tvalid_int <= s_integrator_tvalid and (not reset);
  s_integrator_tready     <= m_integrator_tready and (not reset);

  p_delay_element : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        dout_delay  <= (others => '0');
      else
        if m_integrator_tvalid_int = '1' and m_integrator_tready = '1' then
          dout_delay <= m_integrator_tdata_int;
        end if;
      end if;
    end if;
  end process;


end rtl;