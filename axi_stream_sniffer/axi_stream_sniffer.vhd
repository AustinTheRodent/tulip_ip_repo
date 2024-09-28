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

  signal registers          : reg_t;

  signal fifo_din           : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal fifo_din_valid     : std_logic;
  signal fifo_din_ready     : std_logic;
  signal fifo_dout          : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal fifo_dout_valid    : std_logic;
  signal fifo_dout_ready    : std_logic;
  signal fifo_used          : std_logic_vector(G_FIFO_ADDR_WIDTH downto 0);
  signal fifo_overflow      : std_logic;

  signal transaction_count  : unsigned(31 downto 0);

begin

  p_transaction_count : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' or registers.CONTROL.SW_RESETN(0) = '0' then
        transaction_count <= (others => '0');
      else
        if s_axis_sniff_tvalid = '1' and m_axis_sniff_tready = '1' then
          transaction_count <= transaction_count + 1;
        end if;
      end if;
    end if;
  end process;

  m_axis_sniff_tdata   <= s_axis_sniff_tdata;
  m_axis_sniff_tvalid  <= s_axis_sniff_tvalid;
  s_axis_sniff_tready  <= m_axis_sniff_tready;
  m_axis_sniff_tlast   <= s_axis_sniff_tlast;

  u_reg_file : entity work.axis_sniffer_reg_file
    port map
    (
      s_axi_aclk    => s_axi_aclk,
      s_axi_aresetn => s_axi_aresetn,

      s_GLOBAL_STATUS_FIFO_DOUT_VALID(0)      => fifo_dout_valid,
      s_GLOBAL_STATUS_FIFO_DOUT_VALID_v       => '1',

      s_TRANSACTION_COUNT_COUNT               => std_logic_vector(transaction_count),
      s_TRANSACTION_COUNT_COUNT_v             => '1',

      s_TRANSACTION_VALUE_DATA                => fifo_dout,
      s_TRANSACTION_VALUE_DATA_v              => fifo_dout_valid,

      s_GLOBAL_STATUS_TRANSACTION_OVERFLOW    => (others => '0'),
      s_GLOBAL_STATUS_TRANSACTION_OVERFLOW_v  => '0',

      s_FIFO_STATUS_FIFO_USED                 => std_logic_vector(resize(unsigned(fifo_used), 32)),
      s_FIFO_STATUS_FIFO_USED_v               => '1',

      s_CTRL_STATUS_S_AXIS_TVALID(0)          => s_axis_sniff_tvalid,
      s_CTRL_STATUS_S_AXIS_TVALID_v           => '1',

      s_CTRL_STATUS_M_AXIS_TREADY(0)          => m_axis_sniff_tready,
      s_CTRL_STATUS_M_AXIS_TREADY_v           => '1',


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

  fifo_din        <= s_axis_sniff_tdata;
  fifo_din_valid  <= s_axis_sniff_tvalid and m_axis_sniff_tready;

  p_fifo_overflow : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' or registers.CONTROL.SW_RESETN(0) = '0' then
        fifo_overflow <= '0';
      else
        if fifo_din_valid = '1' and fifo_din_ready = '0' then
          fifo_overflow <= '1';
        end if;
      end if;
    end if;
  end process;

  u_ps_2_i2s_fifo : entity work.axis_sync_fifo
    generic map
    (
      G_ADDR_WIDTH    => G_FIFO_ADDR_WIDTH,
      G_DATA_WIDTH    => G_DATA_WIDTH,
      G_BUFFER_INPUT  => true,
      G_BUFFER_OUTPUT => true
    )
    port map
    (
      clk             => s_axi_aclk,
      reset           => (not s_axi_aresetn),
      enable          => registers.CONTROL.SW_RESETN(0),

      din             => fifo_din,
      din_valid       => fifo_din_valid,
      din_ready       => fifo_din_ready,
      din_last        => '0',

      used            => fifo_used,

      dout            => fifo_dout,
      dout_valid      => fifo_dout_valid,
      dout_ready      => fifo_dout_ready,
      dout_last       => open
    );

    fifo_dout_ready <= registers.TRANSACTION_VALUE_REG_rd_pulse;

end rtl;
