library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity kr260_tulip_top_0_0_1 is
  port
  (
    s_axi_aclk    : in  std_logic;
    a_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(11 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(31 downto 0);
    s_axi_wstrb   : in  std_logic_vector(3 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(11 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(31 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    wm8960_i2c_sda  : inout std_logic;
    wm8960_i2c_sclk : out   std_logic

  );
end entity;

architecture rtl of kr260_tulip_top_0_0_1 is

  signal registers : reg_t;

begin

  u_reg_file : entity work.axil_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      a_axi_aresetn => a_axi_aresetn,


      s_axi_awaddr  => s_axi_awaddr,
      s_axi_awvalid => s_axi_awvalid,
      s_axi_awready => s_axi_awready,

      s_axi_wdata   => s_axi_wdata,
      s_axi_wstrb   => s_axi_wstrb,
      s_axi_wvalid  => s_axi_wvalid,
      s_axi_wready  => s_axi_wready,

      s_axi_bresp   => s_axi_bresp,
      s_axi_bvalid  => s_axi_bvalid,
      s_axi_bready  => s_axi_bready,

      s_axi_araddr  => s_axi_araddr,
      s_axi_arvalid => s_axi_arvalid,
      s_axi_arready => s_axi_arready,

      s_axi_rdata   => s_axi_rdata,
      s_axi_rresp   => s_axi_rresp,
      s_axi_rvalid  => s_axi_rvalid,
      s_axi_rready  => s_axi_rready,

      registers_out => open
    );

  u_wm8960_i2c : entity work.wm8960_i2c
    generic map
    (
      G_CLK_DIVIDER         => 1000
    )
    port map
    (
      clk                   => clk,
      reset                 => (not a_axi_aresetn),
      enable                => std_logic(registers.CONTROL.ENABLE(0)),

      din_device_address    => registers.I2C_CONTROL.DEVICE_ADDRESS,
      din_rd_wr             => std_logic(registers.I2C_CONTROL.I2C_IS_READ(0)),
      din_register_address  => registers.I2C_CONTROL.REGISTER_ADDRESS,
      din_register_data     => registers.I2C_CONTROL.REGISTER_WR_DATA,
      din_valid             => registers.I2C_CONTROL_wr_pulse,
      din_ready             => open,

      i2c_sda               => wm8960_i2c_sda,
      i2c_sclk              => wm8960_i2c_sclk,

      dout_register_data    => open,
      dout_acks_received    => open,
      dout_valid            => open,
      dout_ready            => '1'
    );

end rtl;

