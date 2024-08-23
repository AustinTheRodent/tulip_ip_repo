library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tulip_axi_dma is
  generic
  (
    G_DMA_FILE_DATA_WIDTH : integer := 128; -- do not change ?
    G_PS_ADDR_WIDTH       : integer := 40
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;

    trigger_wr_sm : in  std_logic;
    wr_burst_len  : in  std_logic_vector(11 downto 0); -- Bytes+1
    wr_base_addr  : in  std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);

    trigger_rd_sm : in  std_logic;
    rd_burst_len  : in  std_logic_vector(11 downto 0); -- Bytes+1
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

    m_axi_wdata   : out std_logic_vector(G_DMA_FILE_DATA_WIDTH-1 downto 0);
    m_axi_wstrb   : out std_logic_vector(G_DMA_FILE_DATA_WIDTH/8-1 downto 0);
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

    m_axi_rdata   : in  std_logic_vector(G_DMA_FILE_DATA_WIDTH-1 downto 0);
    m_axi_rresp   : in  std_logic_vector(G_DMA_FILE_DATA_WIDTH/8-1 downto 0); -- 0 = okay
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

architecture rtl of tulip_axi_dma is

  signal m_axi_awvalid_int  : std_logic;
  signal m_axi_arvalid_int  : std_logic;
  signal m_axi_wvalid_int   : std_logic;
  signal m_axi_bready_int   : std_logic;
  signal m_axi_rready_int   : std_logic;
  signal m_axis_tvalid_int  : std_logic;

  signal m_awaddr           : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
  signal m_araddr           : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
  signal m_awlen            : std_logic_vector(7 downto 0);
  signal m_arlen            : std_logic_vector(7 downto 0);
  signal m_wr_burst_counter : unsigned(7 downto 0);
  signal m_rd_burst_counter : unsigned(7 downto 0);

  signal s_awaddr           : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
  signal s_araddr           : std_logic_vector(G_PS_ADDR_WIDTH-1 downto 0);
  signal s_axi_awready_int  : std_logic;
  signal s_axi_wready_int   : std_logic;
  signal s_axi_rvalid_int   : std_logic;
  signal s_axi_arready_int  : std_logic;

  signal wstrb : std_logic_vector(G_DMA_FILE_DATA_WIDTH/8-1 downto 0);
  signal rstrb : std_logic_vector(G_DMA_FILE_DATA_WIDTH/8-1 downto 0);


  type m_wr_state_t is (init, set_addr, wr_data, get_bresp);
  signal m_wr_state : m_wr_state_t;
  type m_rd_state_t is (init, set_addr, rd_data);
  signal m_rd_state : m_rd_state_t;

begin

  m_axi_arvalid     <= m_axi_arvalid_int;
  m_axi_awvalid     <= m_axi_awvalid_int;
  m_axi_wvalid      <= m_axi_wvalid_int;

  m_axi_awaddr      <= wr_base_addr;

  m_axi_awlen       <= std_logic_vector(resize(shift_right(unsigned(wr_burst_len), 4), m_axi_awlen'length));

  m_axi_wdata       <= s_axis_tdata;
  s_axis_tready     <= m_axi_wready     when m_wr_state = wr_data                   else '0';
  m_axi_wvalid_int  <= s_axis_tvalid    when m_wr_state = wr_data                   else '0';
  m_axi_wlast       <= m_axi_wvalid_int when m_wr_burst_counter = unsigned(m_awlen) else '0';

  p_wstrb : process(wr_burst_len(3 downto 0))
  begin
    case wr_burst_len(3 downto 0) is
      when "0000" =>
        wstrb <= x"0001";
      when "0001" =>
        wstrb <= x"0003";
      when "0010" =>
        wstrb <= x"0007";
      when "0011" =>
        wstrb <= x"000F";
      when "0100" =>
        wstrb <= x"001F";
      when "0101" =>
        wstrb <= x"003F";
      when "0110" =>
        wstrb <= x"007F";
      when "0111" =>
        wstrb <= x"00FF";
      when "1000" =>
        wstrb <= x"01FF";
      when "1001" =>
        wstrb <= x"03FF";
      when "1010" =>
        wstrb <= x"07FF";
      when "1011" =>
        wstrb <= x"0FFF";
      when "1100" =>
        wstrb <= x"1FFF";
      when "1101" =>
        wstrb <= x"3FFF";
      when "1110" =>
        wstrb <= x"7FFF";
      when others =>
        wstrb <= x"FFFF";
    end case;
  end process;

  m_axi_wstrb <=
    (others => '1') when m_wr_burst_counter < unsigned(m_awlen) else
    wstrb;

  m_axi_awburst <= "01";
  m_axi_awsize  <= "111";

  m_axi_bready_int  <= '1' when m_wr_state = get_bresp else '0';
  m_axi_bready      <= m_axi_bready_int;

  m_axi_awvalid_int <= '1' when m_wr_state = set_addr else '0';

  p_m_wr_state_machine : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' then
        m_wr_state <= init;
      else
        case m_wr_state is
          when init =>
            if trigger_wr_sm = '1' then
              m_wr_state <= set_addr;
            end if;

          when set_addr =>
            if m_axi_awvalid_int = '1' and m_axi_awready = '1' then
              m_awaddr            <= wr_base_addr;
              m_awlen             <= std_logic_vector(resize(shift_right(unsigned(wr_burst_len), 4), m_awlen'length));
              m_wr_burst_counter  <= (others => '0');
              m_wr_state          <= wr_data;
            end if;

          when wr_data =>
            if m_axi_wvalid_int = '1' and m_axi_wready = '1' then
              if m_wr_burst_counter = unsigned(m_awlen) then
                m_wr_state      <= get_bresp;
              else
                m_wr_burst_counter <= m_wr_burst_counter + 1;
              end if;
            end if;

          when get_bresp =>
            if m_axi_bvalid = '1' and m_axi_bready_int = '1' then
              m_wr_state <= init;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------------------

  m_axi_rready      <= m_axi_rready_int;
  m_axi_araddr      <= rd_base_addr;

  m_axi_arlen       <= std_logic_vector(resize(shift_right(unsigned(rd_burst_len), 4), m_axi_arlen'length));

  m_axis_tvalid     <= m_axis_tvalid_int;

  m_axis_tdata      <= m_axi_rdata;
  m_axis_tvalid_int <= m_axi_rvalid       when m_rd_state = rd_data                   else '0';
  m_axi_rready_int  <= m_axis_tready      when m_rd_state = rd_data                   else '0';
  m_axis_tlast      <= m_axis_tvalid_int  when m_rd_burst_counter = unsigned(m_arlen) else '0';

  m_axi_arburst     <= "01";
  m_axi_arsize      <= "111";

  m_axi_arvalid_int <= '1' when m_rd_state = set_addr else '0';

  p_m_rd_state_machine : process(m_axi_aclk)
  begin
    if rising_edge(m_axi_aclk) then
      if m_axi_aresetn = '0' then
        m_rd_state <= init;
      else
        case m_rd_state is
          when init =>
            if trigger_rd_sm = '1' then
              m_rd_state <= set_addr;
            end if;

          when set_addr =>
            if m_axi_arvalid_int = '1' and m_axi_arready = '1' then
              m_araddr            <= rd_base_addr;
              m_arlen             <= std_logic_vector(resize(shift_right(unsigned(rd_burst_len), 4), m_arlen'length));
              m_rd_burst_counter  <= (others => '0');
              m_rd_state          <= rd_data;
            end if;

          when rd_data =>
            if m_axi_rvalid = '1' and m_axi_rready_int = '1' then
              if m_rd_burst_counter = unsigned(m_arlen) then
                m_rd_state          <= init;
              else
                m_rd_burst_counter  <= m_rd_burst_counter + 1;
              end if;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

end rtl;
