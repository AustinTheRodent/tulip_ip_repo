library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb is
  generic
  (
    G_COMB_DEPTH  : integer range 3 to 8192 := 4;
    G_COMB_DWIDTH : integer := 24;
    G_DIN_DWIDTH  : integer := 24;
    G_DOUT_DWIDTH : integer := 24
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;
    bypass        : in  std_logic;

    s_comb_tdata  : in  std_logic_vector(G_DIN_DWIDTH-1 downto 0);
    s_comb_tvalid : in  std_logic;
    s_comb_tready : out std_logic;

    m_comb_tdata  : out std_logic_vector(G_DOUT_DWIDTH-1 downto 0);
    m_comb_tvalid : out std_logic;
    m_comb_tready : in  std_logic

  );
end entity;

architecture rtl of comb is

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  type state_t is (SM_INIT, SM_RUN);
  signal state : state_t;

  type comb_sr_t is array (0 to G_COMB_DEPTH-1-1) of std_logic_vector(G_COMB_DWIDTH-1 downto 0);
  signal comb_sr        : comb_sr_t;

  signal comb_shift_en  : std_logic;
  signal comb_0_din     : std_logic_vector(G_COMB_DWIDTH-1 downto 0);
  signal comb_nm1_dout  : std_logic_vector(G_COMB_DWIDTH-1 downto 0);

  signal comb_dout      : std_logic_vector(G_COMB_DWIDTH-1 downto 0);

begin

  comb_dout     <= std_logic_vector(resize(signed(s_comb_tdata), G_COMB_DWIDTH) - signed(comb_nm1_dout));
  m_comb_tdata  <= std_logic_vector(resize(signed(comb_dout), G_DOUT_DWIDTH));

  p_comb_sr : process(clk)
  begin
    if rising_edge(clk) then

      if comb_shift_en = '1' then

        for i in 1 to G_COMB_DEPTH-1-1 loop
          comb_sr(i)  <= comb_sr(i-1);
        end loop;

        comb_sr(0)    <= comb_0_din;
        comb_nm1_dout <= comb_sr(G_COMB_DEPTH-1-1);

      end if;

    end if;
  end process;

  comb_0_din <=
    std_logic_vector(resize(signed(s_comb_tdata), G_COMB_DWIDTH)) when state = SM_RUN else
    (others => '0');

  comb_shift_en <=
    '1' when state = SM_INIT else
    s_comb_tvalid and m_comb_tready;

  s_comb_tready <=
    m_comb_tready when state = SM_RUN else
    '0';

  m_comb_tvalid <=
    s_comb_tvalid when state = SM_RUN else
    '0';

  p_state : process(clk)
    variable v_delay : unsigned(clog2(G_COMB_DEPTH)-1 downto 0);
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state         <= SM_INIT;
        v_delay       := (others => '0');
      else
        case (state) is
          when SM_INIT =>
            if v_delay < G_COMB_DEPTH-1 then
              v_delay := v_delay + 1;
            else
              state   <= SM_RUN;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

end rtl;