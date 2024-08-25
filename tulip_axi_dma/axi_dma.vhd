library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_dma is
  generic
  (
    G_DMA_DATA_WIDTH  : integer range 8 to 128  := 128; -- do not change (todo: make flexible)
    G_PS_ADDR_WIDTH   : integer range 8 to 64   := 40;
    G_MAX_BURST_LEN   : integer range 1 to 256  := 256 -- beats
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;

    trigger_wr_sm : in  std_logic;
    wr_len        : in  std_logic_vector(31 downto 0); -- Bytes
    wr_base_addr  : in  std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);

    trigger_rd_sm : in  std_logic;
    rd_len        : in  std_logic_vector(31 downto 0); -- Bytes
    rd_base_addr  : in  std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);

    -------------------------------------------------------------------------------

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
    s_axis_tdata    : in  std_logic_vector(127 downto 0);
    s_axis_tvalid   : in  std_logic;
    s_axis_tready   : out std_logic;
    s_axis_tlast    : in  std_logic;

    -------------------------------------------------------------------------------

    m_axis_aclk     : in  std_logic;
    m_axis_aresetn  : in  std_logic;
    m_axis_tdata    : out std_logic_vector(127 downto 0);
    m_axis_tvalid   : out std_logic;
    m_axis_tready   : in  std_logic;
    m_axis_tlast    : out std_logic

  );
end entity;

architecture rtl of axi_dma is

  type wr_sm_t is (init, begin_transaction, execute_transaction);
  signal wr_sm : wr_sm_t;

  signal current_wr_len : unsigned(31 downto 0);
  signal core_wr_burst_len : unsigned(11 downto 0);
  signal core_wr_start_burst : std_logic;
  signal core_wr_addr : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);

  type rd_sm_t is (init, begin_transaction, execute_transaction);
  signal rd_sm : rd_sm_t;

  signal current_rd_len : unsigned(31 downto 0);
  signal core_rd_burst_len : unsigned(11 downto 0);
  signal core_rd_start_burst : std_logic;
  signal core_rd_addr : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);

  signal core_m_axi_bvalid  : std_logic;
  signal core_m_axi_bready  : std_logic;

  signal core_m_axi_rvalid  : std_logic;
  signal core_m_axi_rready  : std_logic;
  signal core_m_axi_rlast   : std_logic;

begin

  core_m_axi_bvalid <= m_axi_bvalid;
  m_axi_bready      <= core_m_axi_bready;

  core_m_axi_rvalid <= m_axi_rvalid;
  m_axi_rready      <= core_m_axi_rready;
  core_m_axi_rlast  <=  m_axi_rlast;

  p_wr_state_machine : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' or reset = '1' then
        core_wr_start_burst <= '0';
        wr_sm               <= init;
      else
        case wr_sm is
          when init =>
            if trigger_wr_sm = '1' then
              current_wr_len    <= unsigned(wr_len);
              wr_sm             <= begin_transaction;
              core_wr_addr      <= wr_base_addr;
            end if;

          when begin_transaction =>
            if current_wr_len   <= (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8) then
              current_wr_len    <= (others => '0');
              core_wr_burst_len <= resize(current_wr_len-1, core_wr_burst_len'length);
            else
              current_wr_len    <= current_wr_len - (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8);
              core_wr_burst_len <= to_unsigned((G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8 - 1), core_wr_burst_len'length);
            end if;

            core_wr_start_burst <= '1';
            wr_sm               <= execute_transaction;

          when execute_transaction =>
            if core_m_axi_bvalid = '1' and core_m_axi_bready = '1' then
              if current_wr_len = 0 then
                wr_sm         <= init;
              else

                if current_wr_len   <= (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8) then
                  current_wr_len    <= (others => '0');
                  core_wr_burst_len <= resize(current_wr_len-1, core_wr_burst_len'length);
                else
                  current_wr_len    <= current_wr_len - (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8);
                  core_wr_burst_len <= to_unsigned((G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8 - 1), core_wr_burst_len'length);
                end if;

                core_wr_start_burst <= '1';
                core_wr_addr        <= std_logic_vector(unsigned(core_wr_addr) + core_wr_burst_len + 1);
              end if;
            else
              core_wr_start_burst <= '0';
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;


  p_rd_state_machine : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' or reset = '1' then
        core_rd_start_burst <= '0';
        rd_sm               <= init;
      else
        case rd_sm is
          when init =>
            if trigger_rd_sm = '1' then
              current_rd_len    <= unsigned(rd_len);
              rd_sm             <= begin_transaction;
              core_rd_addr      <= rd_base_addr;
            end if;

          when begin_transaction =>
            if current_rd_len   <= (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8) then
              current_rd_len    <= (others => '0');
              core_rd_burst_len <= resize(current_rd_len-1, core_rd_burst_len'length);
            else
              current_rd_len    <= current_rd_len - (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8);
              core_rd_burst_len <= to_unsigned((G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8 - 1), core_rd_burst_len'length);
            end if;

            core_rd_start_burst <= '1';
            rd_sm               <= execute_transaction;

          when execute_transaction =>
            if core_m_axi_rvalid = '1' and core_m_axi_rready = '1' and core_m_axi_rlast = '1' then
              if current_rd_len = 0 then
                rd_sm         <= init;
              else

                if current_rd_len   <= (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8) then
                  current_rd_len    <= (others => '0');
                  core_rd_burst_len <= resize(current_rd_len-1, core_rd_burst_len'length);
                else
                  current_rd_len    <= current_rd_len - (G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8);
                  core_rd_burst_len <= to_unsigned((G_MAX_BURST_LEN*G_DMA_DATA_WIDTH/8 - 1), core_rd_burst_len'length);
                end if;

                core_rd_start_burst <= '1';
                core_rd_addr  <= std_logic_vector(unsigned(core_rd_addr) + core_rd_burst_len + 1);
              end if;
            else
              core_rd_start_burst <= '0';
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

  u_single_burst : entity work.axi_dma_single_burst
    generic map
    (
      G_DMA_DATA_WIDTH => G_DMA_DATA_WIDTH,
      G_PS_ADDR_WIDTH       => G_PS_ADDR_WIDTH
    )
    port map
    (
      clk           => clk,
      reset         => reset,

      trigger_wr_sm => core_wr_start_burst,
      wr_burst_len  => std_logic_vector(core_wr_burst_len),
      wr_base_addr  => core_wr_addr,

      trigger_rd_sm => core_rd_start_burst,
      rd_burst_len  => std_logic_vector(core_rd_burst_len),
      rd_base_addr  => core_rd_addr,

      -------------------------------------------------------------------------------

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
      m_axi_bvalid  => core_m_axi_bvalid,
      m_axi_bready  => core_m_axi_bready,

      m_axi_araddr  => m_axi_araddr,
      m_axi_arsize  => m_axi_arsize,
      m_axi_arlen   => m_axi_arlen,
      m_axi_arburst => m_axi_arburst,
      m_axi_arvalid => m_axi_arvalid,
      m_axi_arready => m_axi_arready,

      m_axi_rdata   => m_axi_rdata,
      m_axi_rresp   => m_axi_rresp,
      m_axi_rvalid  => core_m_axi_rvalid,
      m_axi_rready  => core_m_axi_rready,
      m_axi_rlast   => core_m_axi_rlast,

      -------------------------------------------------------------------------------

      s_axis_aclk     => s_axis_aclk,
      s_axis_aresetn  => s_axis_aresetn,
      s_axis_tdata    => s_axis_tdata,
      s_axis_tvalid   => s_axis_tvalid,
      s_axis_tready   => s_axis_tready,
      s_axis_tlast    => s_axis_tlast,

      -------------------------------------------------------------------------------

      m_axis_aclk     => m_axis_aclk,
      m_axis_aresetn  => m_axis_aresetn,
      m_axis_tdata    => m_axis_tdata,
      m_axis_tvalid   => m_axis_tvalid,
      m_axis_tready   => m_axis_tready,
      m_axis_tlast    => m_axis_tlast

    );



end rtl;
