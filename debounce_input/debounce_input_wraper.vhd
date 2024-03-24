library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce_input_wrapper is
  generic
  (
    G_POST_RISING_EDGE_DELAY  : positive  := 256;
    G_POST_FALLING_EDGE_DELAY : positive  := 256;
    G_RISING_EDGE_MIN_COUNT   : positive  := 16;
    G_FALLING_EDGE_MIN_COUNT  : positive  := 16
  );
  port
  (
    clk             : in  std_logic;
    aresetn         : in  std_logic;

    din_bounce      : in  std_logic;
    dout_debounced  : out std_logic
  );
end entity;

architecture rtl of debounce_input_wrapper is

begin

  u_debounce : entity work.debounce_input
    generic map
    (
      G_POST_RISING_EDGE_DELAY  => G_POST_RISING_EDGE_DELAY,
      G_POST_FALLING_EDGE_DELAY => G_POST_FALLING_EDGE_DELAY,
      G_RISING_EDGE_MIN_COUNT   => G_RISING_EDGE_MIN_COUNT,
      G_FALLING_EDGE_MIN_COUNT  => G_FALLING_EDGE_MIN_COUNT
    )
    port map
    (
      clk                       => clk,
      aresetn                   => aresetn,

      din_bounce                => din_bounce,
      dout_debounced            => dout_debounced
    );

end rtl;
