library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sw_dsp_reg_file_pkg.all;

entity tulip_sw_dsp_loopback is
  generic
  (
    G_DATA_WIDTH            : integer := 64
  );
  port
  (
    s_axis_pl_aclk          : in  std_logic;
    s_axis_pl_aresetn       : in  std_logic;
    s_axis_pl_tdata         : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_axis_pl_tvalid        : in  std_logic;
    s_axis_pl_tready        : out std_logic;
    s_axis_pl_tlast         : in  std_logic;

    s_axis_loopback_aclk    : in  std_logic;
    s_axis_loopback_aresetn : in  std_logic;
    s_axis_loopback_tdata   : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_axis_loopback_tvalid  : in  std_logic;
    s_axis_loopback_tready  : out std_logic;
    s_axis_loopback_tlast   : in  std_logic;

    m_axis_pl_aclk          : in  std_logic;
    m_axis_pl_aresetn       : in  std_logic;
    m_axis_pl_tdata         : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_axis_pl_tvalid        : out std_logic;
    m_axis_pl_tready        : in  std_logic;
    m_axis_pl_tlast         : out std_logic;

    m_axis_loopback_aclk    : in  std_logic;
    m_axis_loopback_aresetn : in  std_logic;
    m_axis_loopback_tdata   : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_axis_loopback_tvalid  : out std_logic;
    m_axis_loopback_tready  : in  std_logic;
    m_axis_loopback_tlast   : out std_logic;

    s_axi_aclk        : in  std_logic;
    s_axi_aresetn     : in  std_logic;
    s_axi_awaddr      : in  std_logic_vector(12-1 downto 0);
    s_axi_awvalid     : in  std_logic;
    s_axi_awready     : out std_logic;
    s_axi_wdata       : in  std_logic_vector(32-1 downto 0);
    s_axi_wstrb       : in  std_logic_vector(32/8-1 downto 0);
    s_axi_wvalid      : in  std_logic;
    s_axi_wready      : out std_logic;
    s_axi_bresp       : out std_logic_vector(1 downto 0);
    s_axi_bvalid      : out std_logic;
    s_axi_bready      : in  std_logic;
    s_axi_araddr      : in  std_logic_vector(12-1 downto 0);
    s_axi_arvalid     : in  std_logic;
    s_axi_arready     : out std_logic;
    s_axi_rdata       : out std_logic_vector(32-1 downto 0);
    s_axi_rresp       : out std_logic_vector(1 downto 0);
    s_axi_rvalid      : out std_logic;
    s_axi_rready      : in  std_logic

  );
end entity;

architecture rtl of tulip_sw_dsp_loopback is

  signal registers        : reg_t;

  signal m_axis_overflow  : std_logic;
  signal s_axis_underflow : std_logic;
  signal din_fifo_used    : std_logic_vector(9 downto 0);
  signal dout_fifo_used   : std_logic_vector(9 downto 0);

  signal s_axis_din_fifo_tdata    : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal s_axis_din_fifo_tvalid   : std_logic;
  signal s_axis_din_fifo_tready   : std_logic;
  signal m_axis_din_fifo_tdata    : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal m_axis_din_fifo_tvalid   : std_logic;
  signal m_axis_din_fifo_tready   : std_logic;

  signal s_axis_dout_fifo_tdata   : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal s_axis_dout_fifo_tvalid  : std_logic;
  signal s_axis_dout_fifo_tready  : std_logic;
  signal m_axis_dout_fifo_tdata   : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal m_axis_dout_fifo_tvalid  : std_logic;
  signal m_axis_dout_fifo_tready  : std_logic;

begin

  m_axis_pl_tdata         <= s_axis_pl_tdata when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else m_axis_dout_fifo_tdata;
  m_axis_pl_tvalid        <= s_axis_pl_tvalid when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else m_axis_dout_fifo_tvalid;

  m_axis_dout_fifo_tready <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else m_axis_pl_tready;
  s_axis_pl_tready        <= m_axis_pl_tready when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else s_axis_din_fifo_tready;

  s_axis_din_fifo_tdata   <= s_axis_pl_tdata;
  s_axis_din_fifo_tvalid  <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else s_axis_pl_tvalid;

  m_axis_loopback_tdata   <= m_axis_din_fifo_tdata;
  m_axis_loopback_tvalid  <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else m_axis_din_fifo_tvalid;
  m_axis_din_fifo_tready  <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else m_axis_loopback_tready;

  s_axis_dout_fifo_tdata  <= s_axis_loopback_tdata;
  s_axis_dout_fifo_tvalid <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else s_axis_loopback_tvalid;
  s_axis_loopback_tready  <= '0' when registers.CONTROL.ENGAUGE_LOOPBACK(0) = '0' else s_axis_dout_fifo_tready;

  u_reg_file : entity work.sw_dsp_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,

      s_STATUS_M_AXIS_OVERFLOW(0)   => m_axis_overflow,
      s_STATUS_M_AXIS_OVERFLOW_v    => '1',

      s_STATUS_S_AXIS_UNDERFLOW(0)  => s_axis_underflow,
      s_STATUS_S_AXIS_UNDERFLOW_v   => '1',

      s_DIN_FIFO_USED_FIFO_USED     => std_logic_vector(resize(unsigned(din_fifo_used), 32)),
      s_DIN_FIFO_USED_FIFO_USED_v   => '1',

      s_DOUT_FIFO_USED_FIFO_USED    => std_logic_vector(resize(unsigned(dout_fifo_used), 32)),
      s_DOUT_FIFO_USED_FIFO_USED_v  => '1',


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

  u_din_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => 9,
      G_DATA_WIDTH    => G_DATA_WIDTH,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => registers.CONTROL.ENGAUGE_LOOPBACK(0),

      din             => s_axis_din_fifo_tdata,
      din_valid       => s_axis_din_fifo_tvalid,
      din_ready       => s_axis_din_fifo_tready,
      din_last        => '0',

      used            => din_fifo_used,

      dout            => m_axis_din_fifo_tdata,
      dout_valid      => m_axis_din_fifo_tvalid,
      dout_ready      => m_axis_din_fifo_tready,
      dout_last       => open
    );

  u_dout_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => 9,
      G_DATA_WIDTH    => G_DATA_WIDTH,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => registers.CONTROL.ENGAUGE_LOOPBACK(0),

      din             => s_axis_dout_fifo_tdata,
      din_valid       => s_axis_dout_fifo_tvalid,
      din_ready       => s_axis_dout_fifo_tready,
      din_last        => '0',

      used            => dout_fifo_used,

      dout            => m_axis_dout_fifo_tdata,
      dout_valid      => m_axis_dout_fifo_tvalid,
      dout_ready      => m_axis_dout_fifo_tready,
      dout_last       => open
    );

end rtl;
