library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.axil_reg_file_pkg.all;

entity wm8960_i2c_core is
  port
  (
    clk            : in    std_logic;
    reset          : in    std_logic;
    aresetn    : in    std_logic;

    wm8960_i2c_sda        : inout std_logic;
    wm8960_i2c_sda_output : out   std_logic;
    wm8960_i2c_sclk       : out   std_logic;
  );
end entity;

architecture rtl of kr260_tulip_top_0_0_1 is

begin

  IOBUF_i2c : IOBUF
    generic map
    (
      DRIVE       => 12,
      IOSTANDARD  => "DEFAULT",
      SLEW        => "SLOW"
    )
    port map
    (
      O           => i2c_sda_input,       -- Buffer output
      IO          => wm8960_i2c_sda,      -- Buffer inout port (connect directly to top-level port)
      I           => i2c_sda_output,      -- Buffer input
      T           => (not sda_is_output)  -- 3-state enable input, high=input, low=output
    );

  wm8960_i2c_sda_output <= i2c_sda_output;

  u_wm8960_i2c_core : entity work.wm8960_i2c_core
    generic map
    (
      G_CLK_DIVIDER         => 1000
    )
    port map
    (
      clk                   => clk,
      reset                 => (not aresetn),

      din_device_address    => 
      din_valid             => 
      din_ready             => 

      i2c_sda_output        => 
      i2c_sda_input         => 
      sda_is_output         => 
      i2c_sclk              => 

      dout_register_data    => 
      dout_acks_received    => 
      dout_valid            => 
      dout_ready            => 
    );

end rtl;
