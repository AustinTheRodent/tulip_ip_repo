library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axis_sniffer_reg_file_pkg.all;

entity axi_stream_sniffer is
  generic
  (
    G_DATA_WIDTH      : integer := 32;
    G_FIFO_ADDR_WIDTH : integer := 10
  );
  port
  (
    s_axis_sniff_aclk     : in  std_logic;
    s_axis_sniff_aresetn  : in  std_logic;
    s_axis_sniff_tdata    : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    s_axis_sniff_tvalid   : in  std_logic;
    s_axis_sniff_tready   : out std_logic;
    s_axis_sniff_tlast    : in  std_logic;

    m_axis_sniff_aclk     : in  std_logic;
    m_axis_sniff_aresetn  : in  std_logic;
    m_axis_sniff_tdata    : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    m_axis_sniff_tvalid   : out std_logic;
    m_axis_sniff_tready   : in  std_logic;
    m_axis_sniff_tlast    : out std_logic;

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

architecture rtl of axi_stream_sniffer is

begin

  m_axis_sniff_tdata   <= s_axis_sniff_tdata;
  m_axis_sniff_tvalid  <= s_axis_sniff_tvalid;
  s_axis_sniff_tready  <= m_axis_sniff_tready;
  m_axis_sniff_tlast   <= s_axis_sniff_tlast;

  u_reg_file : entity work.axis_sniffer_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,

      s_TRANSACTION_COUNT_COUNT               => (others => '0'),
      s_TRANSACTION_COUNT_COUNT_v             => '0',

      s_TRANSACTION_VALUE_DATA                => (others => '0'),
      s_TRANSACTION_VALUE_DATA_v              => '0',

      s_GLOBAL_STATUS_TRANSACTION_OVERFLOW    => (others => '0'),
      s_GLOBAL_STATUS_TRANSACTION_OVERFLOW_v  => '0',

      s_FIFO_STATUS_FIFO_AVAILABLE            => (others => '0'),
      s_FIFO_STATUS_FIFO_AVAILABLE_v          => '0',


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

    u_ps_2_i2s_fifo : entity work.axis_sync_fifo
      generic map
      (
        G_ADDR_WIDTH    => C_PS_2_I2S_FIFO_AWIDTH,
        G_DATA_WIDTH    => 2*C_ADC_RESOLUTION,
        G_BUFFER_INPUT  => true,
        G_BUFFER_OUTPUT => true
      )
      port map
      (
        clk             => 
        reset           => 
        enable          => 

        din             => 
        din_valid       => 
        din_ready       => 
        din_last        => '0',

        used            => 

        dout            => 
        dout_valid      => 
        dout_ready      => 
        dout_last       => 
      );

end rtl;
