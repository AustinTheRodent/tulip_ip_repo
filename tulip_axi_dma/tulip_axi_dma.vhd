
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axis_sniffer_reg_file_pkg.all;

entity axi_dma is
  generic
  (
    G_REG_FILE_DATA_WIDTH : integer := 32;
    G_REG_FILE_ADDR_WIDTH : integer := 16
  );
  port
  (
    m_axi_aclk    : in  std_logic;
    m_axi_aresetn : in  std_logic;

    m_axi_awaddr  : out std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
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

    m_axi_wdata   : out std_logic_vector(G_REG_FILE_DATA_WIDTH-1 downto 0);
    m_axi_wstrb   : out std_logic_vector(G_REG_FILE_DATA_WIDTH/8-1 downto 0);
    m_axi_wvalid  : out std_logic;
    m_axi_wready  : in  std_logic;
    m_axi_wlast   : out std_logic;

    m_axi_bresp   : in  std_logic_vector(1 downto 0);
    m_axi_bvalid  : in  std_logic;
    m_axi_bready  : out std_logic;

    -------------------------------------------------------------------------------

    m_axi_araddr  : out std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
    m_axi_arsize  : out std_logic_vector(2 downto 0);
    -- m_axi_awsize represents bytes in beat:
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

    m_axi_rdata   : in  std_logic_vector(G_REG_FILE_DATA_WIDTH-1 downto 0);
    m_axi_rresp   : in  std_logic_vector(G_REG_FILE_DATA_WIDTH/8-1 downto 0); -- 0 = okay
    m_axi_rvalid  : in  std_logic;
    m_axi_rready  : out std_logic;
    m_axi_rlast   : in  std_logic;

    -------------------------------------------------------------------------------

    s_axis_aclk
    s_axis_aresetn
    s_axis_tdata
    s_axis_tvalid
    s_axis_tready



  );
end entity;

architecture rtl of axi_dma is

  signal trigger_wr_sm  : std_logic;
  signal trigger_rd_sm  : std_logic;

  signal m_axi_awvalid_int  : std_logic;
  signal m_axi_arvalid_int  : std_logic;
  signal m_axi_awaddr_int   : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal m_axi_awlen_int    : std_logic_vector(7 downto 0);
  signal m_axi_wvalid_int   : std_logic;
  signal m_axi_bready_int   : std_logic;
  signal m_axi_rready_int   : std_logic;

  signal m_awaddr           : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal m_araddr           : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal m_awlen            : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal m_arlen            : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal m_wr_burst_counter : unsigned(7 downto 0);
  signal m_rd_burst_counter : unsigned(7 downto 0);

  signal s_awaddr           : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal s_araddr           : std_logic_vector(G_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal s_axi_awready_int  : std_logic;
  signal s_axi_wready_int   : std_logic;
  signal s_axi_rvalid_int   : std_logic;
  signal s_axi_arready_int  : std_logic;




  type ms_wr_state_t is (init, set_addr, wr_data, get_bresp);
  signal m_wr_state : s_wr_state_t;
  type m_rd_state_t is (init, set_addr, rd_data);
  signal m_rd_state : s_rd_state_t;

begin

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
              m_awaddr            <= m_axi_awaddr_int;
              m_awlen             <= m_axi_awlen_int;
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
            if m_ax_bvalid = '1' and m_axi_bready_int = '1' theni
              m_wr_state <= init;
            end if;

          when others =>
            null;

        end case;
      end if;
    end process;
  end process;

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
              m_araddr            <= m_axi_awaddr_int;
              m_arlen             <= m_axi_awlen_int;
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
    end process;
  end process;




















--  ----------------------------------------------------------------------------
--
--  registers.SCRATCHPAD.SCRATCH  <= registers.SCRATCHPAD_REG(31 downto 0);
--
--  registers_out <= registers;
--
--  s_axi_rresp   <= (others => '0');
--  s_axi_bresp   <= (others => '0');
--  s_axi_bvalid  <= '1';
--
--  s_axi_awready <= s_axi_awready_int;
--  s_axi_wready  <= s_axi_wready_int;
--
--  p_s_wr_state_machine : process(s_axi_aclk)
--  begin
--    if rising_edge(s_axi_aclk) then
--      if s_axi_aresetn = '0' then
--        registers.SCRATCHPAD_REG          <= x"CAFEBABE";
--        s_awaddr                          <= (others => '0');
--        registers.SCRATCHPAD_REG_wr_pulse <= '0';
--        s_axi_awready_int                 <= '0';
--        s_axi_wready_int                  <= '0';
--        s_wr_state                          <= init;
--      else
--        case s_wr_state is
--          when init =>
--            registers.SCRATCHPAD_REG_wr_pulse <= '0';
--            s_axi_awready_int                 <= '1';
--            s_axi_wready_int                  <= '0';
--            s_awaddr                          <= (others => '0');
--            s_wr_state                        <= get_addr;
--
--          when get_addr =>
--            registers.SCRATCHPAD_REG_wr_pulse <= '0';
--            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
--              s_axi_awready_int <= '0';
--              s_axi_wready_int  <= '1';
--              s_awaddr          <= s_axi_awaddr;
--              s_wr_state        <= wr_data;
--            end if;
--
--          when wr_data =>
--            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
--              case s_awaddr is
--                when std_logic_vector(to_unsigned(SCRATCHPAD_addr, G_REG_FILE_ADDR_WIDTH)) =>
--                  registers.SCRATCHPAD_REG          <= s_axi_wdata;
--                  registers.SCRATCHPAD_REG_wr_pulse <= '1';
--                when others =>
--                  null;
--              end case;
--
--              s_axi_awready_int <= '1';
--              s_axi_wready_int  <= '0';
--              s_wr_state          <= get_addr;
--            end if;
--
--          when others =>
--            s_wr_state <= init;
--
--        end case;
--      end if;
--    end if;
--  end process;
--
--  ----------------------------------------------------------------------------
--
--  s_axi_arready     <= s_axi_arready_int;
--  s_axi_rvalid      <= s_axi_rvalid_int;
--
--  p_s_rd_state_machine : process(s_axi_aclk)
--  begin
--    if rising_edge(s_axi_aclk) then
--      if s_axi_aresetn = '0' then
--        s_araddr                          <= (others => '0');
--        s_axi_rdata                       <= (others => '0');
--        registers.SCRATCHPAD_REG_rd_pulse <= '0';
--        s_axi_arready_int                 <= '0';
--        s_axi_rvalid_int                  <= '0';
--        s_rd_state                        <= init;
--      else
--        case s_rd_state is
--          when init =>
--            registers.SCRATCHPAD_REG_rd_pulse <= '0';
--            s_axi_arready_int                 <= '1';
--            s_axi_rvalid_int                  <= '0';
--            s_araddr                          <= (others => '0');
--            s_rd_state                        <= get_addr;
--
--          when get_addr =>
--            registers.SCRATCHPAD_REG_rd_pulse <= '0';
--            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
--              s_axi_arready_int               <= '0';
--              s_axi_rvalid_int                <= '0';
--              s_araddr                        <= s_axi_araddr;
--              s_rd_state                      <= rd_data;
--            end if;
--
--          when rd_data =>
--            case s_araddr is
--              when std_logic_vector(to_unsigned(SCRATCHPAD_addr, G_REG_FILE_ADDR_WIDTH)) =>
--                s_axi_rdata <= registers.SCRATCHPAD_REG;
--              when others =>
--                null;
--            end case;
--
--            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
--              case s_araddr is
--                when std_logic_vector(to_unsigned(SCRATCHPAD_addr, G_REG_FILE_ADDR_WIDTH)) =>
--                  registers.SCRATCHPAD_REG_rd_pulse <= '1';
--                when others =>
--                  null;
--              end case;
--              s_axi_arready_int <= '1';
--              s_axi_rvalid_int  <= '0';
--              s_rd_state          <= get_addr;
--            else
--              s_axi_rvalid_int  <= '1';
--            end if;
--
--          when others =>
--            s_rd_state <= init;
--
--        end case;
--      end if;
--    end if;
--  end process;

end rtl;
