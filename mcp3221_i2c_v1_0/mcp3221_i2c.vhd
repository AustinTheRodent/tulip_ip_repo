library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.mcp3221_reg_file_pkg.all;

entity mcp3221_i2c is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_axi_awaddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    mcp3221_i2c_sda   : inout std_logic;
    mcp3221_i2c_sclk  : out   std_logic;

    m_axis_aclk       : in  std_logic;
    m_axis_aresetn    : in  std_logic;

    m_axis_tdata      : out std_logic_vector(15 downto 0);
    m_axis_tvalid     : out std_logic;
    m_axis_tready     : in  std_logic
  );
end entity;

architecture rtl of mcp3221_i2c is

  signal sample_period_counter    : unsigned(31 downto 0);
  signal sample_period_valid      : std_logic;

  signal core_din_device_address  : std_logic_vector(6 downto 0);
  signal core_din_valid           : std_logic;
  signal core_din_ready           : std_logic;

  signal core_i2c_sda_output      : std_logic;
  signal core_i2c_sda_input       : std_logic;
  signal core_sda_is_output       : std_logic;
  signal core_i2c_sclk            : std_logic;

  signal core_dout_register_data  : std_logic_vector(15 downto 0);
  signal core_dout_acks_received  : std_logic_vector(2 downto 0);
  signal core_dout_valid          : std_logic;
  signal core_dout_ready          : std_logic;

  signal registers                : reg_t;

begin

  p_sample_counter : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' or registers.MCP3221_CONTROL.SW_RESETN(0) = '0' then
        sample_period_counter <= (others => '0');
      else
        if unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER) = 0 then
          sample_period_counter <= (others => '0');
        else
          if sample_period_counter = unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER)-1 then
            sample_period_counter <= (others => '0');
          else
            sample_period_counter <= sample_period_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  sample_period_valid <=
    '0' when unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER) = 0 else
    '1' when sample_period_counter = unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER)-1 else
    '0';

  u_reg_file : entity work.mcp3221_reg_file
    port map
    (
      s_axi_aclk             => s_axi_aclk,
      s_axi_aresetn          => s_axi_aresetn,

      s_DATA_DATA            => core_dout_register_data,
      s_DATA_DATA_v          => core_dout_valid,

      s_STATUS_DOUT_VALID(0) => core_dout_valid,
      s_STATUS_DOUT_VALID_v  => '1',

      s_STATUS_DIN_READY(0)  => core_din_ready,
      s_STATUS_DIN_READY_v   => '1',

      s_STATUS_ACKS         => core_dout_acks_received,
      s_STATUS_ACKS_v       => core_dout_valid,


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
      SLEW        => "SLOW"
    )
    port map
    (
      O           => core_i2c_sda_input,      -- Buffer output
      IO          => mcp3221_i2c_sda,         -- Buffer inout port (connect directly to top-level port)
      I           => core_i2c_sda_output,     -- Buffer input
      T           => (not core_sda_is_output) -- 3-state enable input, high=input, low=output
    );

  core_din_device_address <= registers.MCP3221_CONTROL.DEVICE_ADDRESS;
  mcp3221_i2c_sclk        <= core_i2c_sclk;

  u_mcp3221_i2c_core : entity work.mcp3221_i2c_core
    generic map
    (
      G_CLK_DIVIDER         => 4000
    )
    port map
    (
      clk                   => s_axi_aclk,
      reset                 => (not s_axi_aresetn) or (not registers.MCP3221_CONTROL.SW_RESETN(0)),

      din_device_address    => core_din_device_address,
      din_valid             => core_din_valid,
      din_ready             => core_din_ready,

      i2c_sda_output        => core_i2c_sda_output,
      i2c_sda_input         => core_i2c_sda_input,
      sda_is_output         => core_sda_is_output,
      i2c_sclk              => core_i2c_sclk,

      dout_register_data    => core_dout_register_data,
      dout_acks_received    => core_dout_acks_received,
      dout_valid            => core_dout_valid,
      dout_ready            => core_dout_ready
    );

  m_axis_tvalid <=
    '0' when unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER) = 0 else
    core_dout_valid;

  core_din_valid <=
    registers.DATA_REG_wr_pulse when unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER) = 0 else
    sample_period_valid;

  core_dout_ready <=
    registers.DATA_REG_rd_pulse when unsigned(registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER) = 0 else
    m_axis_tready;

end rtl;









