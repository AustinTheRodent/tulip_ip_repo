library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

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

    wm8960_i2c_sda      : inout std_logic;
    wm8960_i2c_sda_output : out std_logic;
    wm8960_i2c_sclk     : out   std_logic;

    debug_inout_test    : inout std_logic

  );
end entity;

architecture rtl of kr260_tulip_top_0_0_1 is

  signal registers : reg_t;

  signal wm8960_i2c_din_ready           : std_logic_vector(0 downto 0);
  signal wm8960_i2c_dout_valid          : std_logic_vector(0 downto 0);
  signal wm8960_i2c_register_read_data  : std_logic_vector(8 downto 0);
  signal wm8960_i2c_acks                : std_logic_vector(2 downto 0);

  signal i2c_sda_output : std_logic;
  signal i2c_sda_input  : std_logic;
  signal sda_is_output  : std_logic;

begin

  IOBUF_inst : IOBUF
    generic map
    (
      DRIVE       => 12,
      IOSTANDARD  => "DEFAULT",
      SLEW        => "SLOW")
    port map
    (
      O           => open,     -- Buffer output
      IO          => debug_inout_test,   -- Buffer inout port (connect directly to top-level port)
      I           => registers.INOUT_TEST.WR_OUTPUT_LEVEL(0),     -- Buffer input
      T           => (not registers.INOUT_TEST.OUTPUT_ENABLE(0))      -- 3-state enable input, high=input, low=output
    );

  u_reg_file : entity work.axil_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      a_axi_aresetn => a_axi_aresetn,

      s_VERSION_VERSION               => (others => '0'),
      s_VERSION_VERSION_v             => '0',

      s_I2C_STATUS_DIN_READY          => wm8960_i2c_din_ready,
      s_I2C_STATUS_DIN_READY_v        => '1',

      s_I2C_STATUS_DOUT_VALID         => wm8960_i2c_dout_valid,
      s_I2C_STATUS_DOUT_VALID_v       => '1',

      s_I2C_STATUS_ACK_2              => wm8960_i2c_acks(2 downto 2),
      s_I2C_STATUS_ACK_2_v            => wm8960_i2c_dout_valid(0),

      s_I2C_STATUS_ACK_1              => wm8960_i2c_acks(1 downto 1),
      s_I2C_STATUS_ACK_1_v            => wm8960_i2c_dout_valid(0),

      s_I2C_STATUS_ACK_0              => wm8960_i2c_acks(0 downto 0),
      s_I2C_STATUS_ACK_0_v            => wm8960_i2c_dout_valid(0),
  
      s_I2C_STATUS_REGISTER_RD_DATA   => wm8960_i2c_register_read_data,
      s_I2C_STATUS_REGISTER_RD_DATA_v => wm8960_i2c_dout_valid(0),


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

      registers_out => registers
    );

  IOBUF_i2c : IOBUF
    generic map
    (
      DRIVE       => 12,
      IOSTANDARD  => "DEFAULT",
      SLEW        => "SLOW")
    port map
    (
      O           => i2c_sda_input,       -- Buffer output
      IO          => wm8960_i2c_sda,      -- Buffer inout port (connect directly to top-level port)
      I           => i2c_sda_output,      -- Buffer input
      T           => (not sda_is_output)  -- 3-state enable input, high=input, low=output
    );

  wm8960_i2c_sda_output <= i2c_sda_output;

  u_wm8960_i2c : entity work.wm8960_i2c
    generic map
    (
      G_CLK_DIVIDER         => 1000
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => (not a_axi_aresetn),
      enable                => std_logic(registers.CONTROL.ENABLE(0)),
  
      din_device_address    => registers.I2C_CONTROL.DEVICE_ADDRESS,
      din_rd_wr             => std_logic(registers.I2C_CONTROL.I2C_IS_READ(0)),
      din_register_address  => registers.I2C_CONTROL.REGISTER_ADDRESS,
      din_register_data     => registers.I2C_CONTROL.REGISTER_WR_DATA,
      din_valid             => registers.I2C_CONTROL_REG_wr_pulse,
      din_ready             => wm8960_i2c_din_ready(0),

      i2c_sda_output        => i2c_sda_output, 
      i2c_sda_input         => i2c_sda_input, 
      sda_is_output         => sda_is_output, 
      i2c_sclk              => wm8960_i2c_sclk,
  
      dout_register_data    => wm8960_i2c_register_read_data,
      dout_acks_received    => wm8960_i2c_acks,
      dout_valid            => wm8960_i2c_dout_valid(0),
      dout_ready            => '1'
    );

end rtl;

