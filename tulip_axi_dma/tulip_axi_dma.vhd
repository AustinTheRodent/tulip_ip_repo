library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tulip_axi_dma_reg_file_pkg.all;

entity tulip_axi_dma is
  generic
  (
    G_DMA_DATA_WIDTH  : integer range 8 to 128  := 128; -- do not change (todo: make flexible)
    G_PS_ADDR_WIDTH   : integer range 8 to 64   := 40;
    G_MAX_BURST_LEN   : integer range 1 to 256  := 256; -- beats

    G_S_AXIS_DWIDTH   : integer range 8 to 128  := 128;
    G_M_AXIS_DWIDTH   : integer range 8 to 128  := 128
  );
  port
  (
    m_axi_aclk    : in  std_logic;
    m_axi_aresetn : in  std_logic;

    m_axi_awaddr  : out std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
    m_axi_awsize  : out std_logic_vector(2 downto 0);
    -- m_axi_awsize represents bytes in beat:
    -- b000 = 1
    -- b001 = 2
    -- b010 = 4
    -- b011 = 8
    -- b100 = 16
    -- b101 = 32
    -- b110 = 64
    -- b111 = 128
    m_axi_awlen   : out std_logic_vector(7 downto 0); -- Number of beats+1 in burst (max 256 for AXI4)
    m_axi_awburst : out std_logic_vector(1 downto 0);
    -- m_axi_awburst represents burst type:
    -- b00 = FIXED , fixed address burst
    -- b01 = INCR , incrementing address burst
    -- b10 = WRAP , incrementing address that wraps at boundary
    -- b11 = reserved
    m_axi_awvalid : out std_logic;
    m_axi_awready : in  std_logic;

    m_axi_wdata   : out std_logic_vector(G_DMA_DATA_WIDTH-1 downto 0);
    m_axi_wstrb   : out std_logic_vector(G_DMA_DATA_WIDTH/8-1 downto 0);
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in  std_logic;
    m_axi_wlast   : out std_logic;

    m_axi_bresp   : in  std_logic_vector(1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;

    -------------------------------------------------------------------------------

    m_axi_araddr  : out std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
    m_axi_arsize  : out std_logic_vector(2 downto 0);
    -- m_axi_arsize represents bytes in beat:
    -- b000 = 1
    -- b001 = 2
    -- b010 = 4
    -- b011 = 8
    -- b100 = 16
    -- b101 = 32
    -- b110 = 64
    -- b111 = 128
    m_axi_arlen   : out std_logic_vector(7 downto 0); -- Number of beats+1 in burst (max 256 for AXI4)
    m_axi_arburst : out std_logic_vector(1 downto 0);
    -- m_axi_awburst represents burst type:
    -- b00 = FIXED , fixed address burst
    -- b01 = INCR , incrementing address burst
    -- b10 = WRAP , incrementing address that wraps at boundary
    -- b11 = reserved
    m_axi_arvalid : out std_logic;
    m_axi_arready : in  std_logic;

    m_axi_rdata   : in  std_logic_vector(G_DMA_DATA_WIDTH-1 downto 0);
    m_axi_rresp   : in  std_logic_vector(G_DMA_DATA_WIDTH/8-1 downto 0); -- 0 = okay
    m_axi_rvalid  : in  std_logic;
    m_axi_rready  : out std_logic;
    m_axi_rlast   : in  std_logic;

    -------------------------------------------------------------------------------

    s_axis_aclk     : in  std_logic;
    s_axis_aresetn  : in  std_logic;
    s_axis_tdata    : in  std_logic_vector(G_S_AXIS_DWIDTH-1 downto 0);
    s_axis_tvalid   : in  std_logic;
    s_axis_tready   : out std_logic;
    s_axis_tlast    : in  std_logic;

    -------------------------------------------------------------------------------

    m_axis_aclk     : in  std_logic;
    m_axis_aresetn  : in  std_logic;
    m_axis_tdata    : out std_logic_vector(G_M_AXIS_DWIDTH-1 downto 0);
    m_axis_tvalid   : out std_logic;
    m_axis_tready   : in  std_logic;
    m_axis_tlast    : out std_logic;

    -------------------------------------------------------------------------------

    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

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
    s_axi_rready  : in  std_logic

  );
end entity;

architecture rtl of tulip_axi_dma is

  signal registers : reg_t;

  signal wr_done_pulse : std_logic;
  signal rd_done_pulse : std_logic;

  signal tx_done_status : std_logic;
  signal tx_started_status : std_logic;
  signal rx_done_status : std_logic;
  signal rx_started_status : std_logic;

  signal s_axis_core_tdata  : std_logic_vector(127 downto 0);
  signal s_axis_core_tvalid : std_logic;
  signal s_axis_core_tready : std_logic;
  signal s_axis_core_tlast  : std_logic;

  signal m_axis_core_tdata  : std_logic_vector(127 downto 0);
  signal m_axis_core_tvalid : std_logic;
  signal m_axis_core_tready : std_logic;
  signal m_axis_core_tlast  : std_logic;

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  constant C_DMA_DWIDTH_BYTES   : integer := (G_DMA_DATA_WIDTH/8);
  constant C_SAXIS_DWIDTH_BYTES : integer := (G_S_AXIS_DWIDTH/8);
  constant C_MAXIS_DWIDTH_BYTES : integer := (G_M_AXIS_DWIDTH/8);
  constant C_MAX_TRANSACT       : integer := C_DMA_DWIDTH_BYTES/C_MAXIS_DWIDTH_BYTES;

  signal keep_val0 : unsigned(4 downto 0);
  signal keep_val1 : unsigned(4 downto 0);
  signal keep_val  : std_logic_vector(7 downto 0);

  signal tx_counter : unsigned(31 downto 0);
  signal rx_counter : unsigned(31 downto 0);

  signal s_axis_tvalid_gate : std_logic;
  signal s_axis_tready_gate : std_logic;
  signal s_axis_tlast_gate  : std_logic;

begin

  s_axis_tready <= s_axis_tready_gate when rx_started_status = '1' and rx_counter < unsigned(registers.DMA_RX_TRANSACT_LEN_BYTES_REG) else '0';
  s_axis_tvalid_gate  <= s_axis_tvalid when rx_started_status = '1' and rx_counter < unsigned(registers.DMA_RX_TRANSACT_LEN_BYTES_REG) else '0';

  s_axis_tlast_gate <= s_axis_tvalid_gate when rx_counter + C_SAXIS_DWIDTH_BYTES >= unsigned(registers.DMA_RX_TRANSACT_LEN_BYTES_REG) else '0';

  p_rx_counter : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' or registers.CONTROL.SW_RESETN(0) = '0' or registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse = '1' then
        rx_counter  <= (others => '0');
      else
        if s_axis_tvalid_gate = '1' and s_axis_tready_gate = '1' then
          if rx_counter < unsigned(registers.DMA_RX_TRANSACT_LEN_BYTES_REG) then
            rx_counter <= rx_counter + C_SAXIS_DWIDTH_BYTES;
          end if;
        end if;
      end if;
    end if;
  end process;

  u_din_converter : entity work.symbol_expander
    generic map
    (
      G_DIN_WIDTH           => G_S_AXIS_DWIDTH,
      G_DOUT_OVER_DIN_WIDTH => G_DMA_DATA_WIDTH/G_S_AXIS_DWIDTH,
      G_FILL_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => m_axi_aclk,
      reset                 => not m_axi_aresetn,
      enable                => registers.CONTROL.SW_RESETN(0),

      din                   => s_axis_tdata,
      din_valid             => s_axis_tvalid_gate,
      din_ready             => s_axis_tready_gate,
      din_last              => s_axis_tlast_gate,

      dout                  => s_axis_core_tdata,
      dout_valid            => s_axis_core_tvalid,
      dout_ready            => s_axis_core_tready,
      dout_last             => s_axis_core_tlast
    );

  keep_val0 <= resize(unsigned(registers.DMA_TX_TRANSACT_LEN_BYTES_REG(clog2(C_DMA_DWIDTH_BYTES)-1 downto 0)), keep_val0'length);
  keep_val1 <= shift_right(keep_val0, clog2(C_MAXIS_DWIDTH_BYTES));

  keep_val <=
    x"01" when C_DMA_DWIDTH_BYTES = C_MAXIS_DWIDTH_BYTES else
    std_logic_vector(resize(to_unsigned(C_MAX_TRANSACT, keep_val'length), keep_val'length)) when keep_val1 = 0 else
    std_logic_vector(resize(keep_val1, keep_val'length));

  u_dout_converter : entity work.symbol_decomp
    generic map
    (
      G_DIN_WIDTH           => G_DMA_DATA_WIDTH,
      G_DIN_OVER_DOUT_WIDTH => G_DMA_DATA_WIDTH/G_M_AXIS_DWIDTH,
      G_READ_LSBS_FIRST     => true
    )
    port map
    (
      clk                   => m_axi_aclk,
      reset                 => not m_axi_aresetn,
      enable                => registers.CONTROL.SW_RESETN(0),

      din                   => m_axis_core_tdata,
      din_valid             => m_axis_core_tvalid,
      din_ready             => m_axis_core_tready,
      din_last_keep         => keep_val,
      din_last              => m_axis_core_tlast,

      dout                  => m_axis_tdata,
      dout_valid            => m_axis_tvalid,
      dout_ready            => m_axis_tready,
      dout_last             => m_axis_tlast
    );

  p_tx_status : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' or registers.CONTROL.SW_RESETN(0) = '0' then
        tx_done_status <= '0';
        tx_started_status <= '0';
      else
        if rd_done_pulse = '1' then
          tx_done_status <= '1';
        elsif registers.DMA_TX_STATUS_RESET_REG_wr_pulse = '1' then
          if registers.DMA_TX_STATUS_RESET.TX_DONE(0) = '1' then
            tx_done_status <= '0';
          end if;
        end if;

        if registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse = '1' then
          tx_started_status <= '1';
        elsif registers.DMA_TX_STATUS_RESET_REG_wr_pulse = '1' then
          if registers.DMA_TX_STATUS_RESET.TX_STARTED(0) = '1' then
            tx_started_status <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  p_rx_status : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' or registers.CONTROL.SW_RESETN(0) = '0' then
        rx_done_status <= '0';
        rx_started_status <= '0';
      else
        if wr_done_pulse = '1' then
          rx_done_status <= '1';
        elsif registers.DMA_RX_STATUS_RESET_REG_wr_pulse = '1' then
          if registers.DMA_RX_STATUS_RESET.RX_DONE(0) = '1' then
            rx_done_status <= '0';
          end if;
        end if;

        if registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse = '1' then
          rx_started_status <= '1';
        elsif registers.DMA_RX_STATUS_RESET_REG_wr_pulse = '1' then
          if registers.DMA_RX_STATUS_RESET.RX_STARTED(0) = '1' then
            rx_started_status <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  u_axi_dma : entity work.axi_dma
    generic map
    (
      G_DMA_DATA_WIDTH  => G_DMA_DATA_WIDTH, -- do not change (todo: make flexible)
      G_PS_ADDR_WIDTH   => G_PS_ADDR_WIDTH,
      G_MAX_BURST_LEN   => G_MAX_BURST_LEN -- beats
    )
    port map
    (
      clk           => m_axi_aclk,
      reset         => not registers.CONTROL.SW_RESETN(0),

      trigger_wr_sm => registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse,
      wr_len        => registers.DMA_RX_TRANSACT_LEN_BYTES_REG,
      wr_base_addr  => std_logic_vector(resize(unsigned(registers.DMA_RX_ADDR_MSBS_REG & registers.DMA_RX_ADDR_REG), G_PS_ADDR_WIDTH)),
      wr_done_pulse => wr_done_pulse,

      trigger_rd_sm => registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse,
      rd_len        => registers.DMA_TX_TRANSACT_LEN_BYTES_REG,
      rd_base_addr  => std_logic_vector(resize(unsigned(registers.DMA_TX_ADDR_MSBS_REG & registers.DMA_TX_ADDR_REG), G_PS_ADDR_WIDTH)),
      rd_done_pulse => rd_done_pulse,

      m_axi_aclk    => m_axi_aclk,
      m_axi_aresetn => m_axi_aresetn,

      m_axi_awaddr  => m_axi_awaddr,
      m_axi_awsize  => m_axi_awsize,
      m_axi_awlen   => m_axi_awlen,
      m_axi_awburst => m_axi_awburst,
      m_axi_awvalid => m_axi_awvalid,
      m_axi_awready => m_axi_awready,

      m_axi_wdata   => m_axi_wdata,
      m_axi_wstrb   => m_axi_wstrb,
      m_axi_wvalid  => m_axi_wvalid,
      m_axi_wready  => m_axi_wready,
      m_axi_wlast   => m_axi_wlast,

      m_axi_bresp   => m_axi_bresp,
      m_axi_bvalid  => m_axi_bvalid,
      m_axi_bready  => m_axi_bready,

      m_axi_araddr  => m_axi_araddr,
      m_axi_arsize  => m_axi_arsize,
      m_axi_arlen   => m_axi_arlen,
      m_axi_arburst => m_axi_arburst,
      m_axi_arvalid => m_axi_arvalid,
      m_axi_arready => m_axi_arready,

      m_axi_rdata   => m_axi_rdata,
      m_axi_rresp   => m_axi_rresp,
      m_axi_rvalid  => m_axi_rvalid,
      m_axi_rready  => m_axi_rready,
      m_axi_rlast   => m_axi_rlast,

      -------------------------------------------------------------------------------

      s_axis_aclk     => m_axi_aclk,
      s_axis_aresetn  => m_axi_aresetn,
      s_axis_tdata    => s_axis_core_tdata,
      s_axis_tvalid   => s_axis_core_tvalid,
      s_axis_tready   => s_axis_core_tready,
      s_axis_tlast    => s_axis_core_tlast,

      -------------------------------------------------------------------------------

      m_axis_aclk     => m_axi_aclk,
      m_axis_aresetn  => m_axi_aresetn,
      m_axis_tdata    => m_axis_core_tdata,
      m_axis_tvalid   => m_axis_core_tvalid,
      m_axis_tready   => m_axis_core_tready,
      m_axis_tlast    => m_axis_core_tlast
    );

  u_reg_file : entity work.tulip_axi_dma_reg_file
    port map
    (
      s_axi_aclk    => m_axi_aclk,
      s_axi_aresetn => m_axi_aresetn,

      s_DMA_TX_STATUS_TX_STARTED(0) => tx_started_status,
      s_DMA_TX_STATUS_TX_STARTED_v  => '1',

      s_DMA_TX_STATUS_TX_DONE(0)  => tx_done_status,
      s_DMA_TX_STATUS_TX_DONE_v   => '1',

      s_DMA_RX_STATUS_RX_STARTED(0) => rx_started_status,
      s_DMA_RX_STATUS_RX_STARTED_v  => '1',

      s_DMA_RX_STATUS_RX_DONE(0)  => rx_done_status,
      s_DMA_RX_STATUS_RX_DONE_v   => '1',


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

end rtl;
