library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity osc_bank is
  generic
  (
    G_NUM_OSC : integer := 128
  )
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;

    s_axis_tdata          : in  std_logic_vector(255 downto 0);
    s_axis_tvalid         : in  std_logic;
    s_axis_tready         : out std_logic;

    m_axis_tdata          : out std_logic_vector(23 downto 0);
    m_axis_tvalid         : out std_logic;
    m_axis_tready         : in  std_logic
  );
end entity;

architecture rtl of osc_bank is

  constant ROM_DEPTH :integer := 2**G_ADDR_WIDTH;

  type ROM is array (integer range <>) of std_logic_vector (G_DATA_WIDTH-1 downto 0);

  function initialize_ROM
  (
    address_width : in integer
  ) return ROM is
    variable a        : real;
    variable b        : real;
    variable ret_rom  : ROM(0 to 2**address_width-1);
  begin

    for i in 0 to integer(2.0**address_width)-1 loop

      a           := sin((MATH_PI/2.0) * (real(i)/(2.0**address_width)));
      b           := a * 2**(G_DATA_WIDTH-1);

      if b >= 2**(G_DATA_WIDTH-1) then
        b := 2**(G_DATA_WIDTH-1)-1;
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

  signal mem : ROM(0 to ROM_DEPTH-1) := initialize_ROM(G_ADDR_WIDTH);

  type counter_bank_t is array (0 to G_NUM_OSC-1) of unsigned(8+clog2(G_NUM_OSC)-1 downto 0);
  signal osc_counter_bank : counter_bank_t;

  signal s_axis_tready_int : std_logic;

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        for i in 0 to G_NUM_OSC-1 loop
          osc_counter_bank(i) <= (others => '0');
        end if;
      else
        if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
          for i in 0 to G_NUM_OSC-1 loop
            osc_counter_bank(i) <= osc_counter_bank(i) + i;
          end if;
        end if;
      end if;
    end if;
  end process;


end rtl;
