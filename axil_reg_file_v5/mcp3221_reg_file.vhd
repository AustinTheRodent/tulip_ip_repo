library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mcp3221_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type MCP3221_CONTROL_subreg_t is record
    DEVICE_ADDRESS : std_logic_vector(6 downto 0);
    SW_RESETN : std_logic;
  end record;

  type SAMPLE_RATE_DIVIDER_subreg_t is record
    SAMPLE_RATE_DIVIDER : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    MCP3221_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    SAMPLE_RATE_DIVIDER_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DATA_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    AWC_TEST_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    MCP3221_CONTROL : MCP3221_CONTROL_subreg_t;
    SAMPLE_RATE_DIVIDER : SAMPLE_RATE_DIVIDER_subreg_t;
    MCP3221_CONTROL_wr_pulse : std_logic;
    SAMPLE_RATE_DIVIDER_wr_pulse : std_logic;
    DATA_wr_pulse : std_logic;
    STATUS_wr_pulse : std_logic;
    AWC_TEST_wr_pulse : std_logic;
    MCP3221_CONTROL_rd_pulse : std_logic;
    SAMPLE_RATE_DIVIDER_rd_pulse : std_logic;
    DATA_rd_pulse : std_logic;
    STATUS_rd_pulse : std_logic;
    AWC_TEST_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.mcp3221_reg_file_pkg.all;

entity mcp3221_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_DATA_DATA : in std_logic_vector(15 downto 0);
    s_DATA_DATA_v : in std_logic;

    s_STATUS_ACKS : in std_logic_vector(2 downto 0);
    s_STATUS_ACKS_v : in std_logic;

    s_STATUS_DOUT_VALID : in std_logic;
    s_STATUS_DOUT_VALID_v : in std_logic;

    s_STATUS_DIN_READY : in std_logic;
    s_STATUS_DIN_READY_v : in std_logic;

    s_AWC_TEST_ACKS : in std_logic_vector(2 downto 0);
    s_AWC_TEST_ACKS_v : in std_logic;

    s_AWC_TEST_DOUT_VALID : in std_logic;
    s_AWC_TEST_DOUT_VALID_v : in std_logic;

    s_AWC_TEST_DIN_READY : in std_logic;
    s_AWC_TEST_DIN_READY_v : in std_logic;


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

    registers_out : out reg_t
  );
end entity;

architecture rtl of mcp3221_reg_file is

  constant MCP3221_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant SAMPLE_RATE_DIVIDER_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant DATA_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant AWC_TEST_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;

  signal registers          : reg_t;

  signal awaddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal araddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal s_axi_awready_int  : std_logic;
  signal s_axi_wready_int   : std_logic;
  signal s_axi_rvalid_int   : std_logic;
  signal s_axi_arready_int  : std_logic;

  type wr_state_t is (init, get_addr, wr_data);
  signal wr_state : wr_state_t;
  type rd_state_t is (init, get_addr, rd_data);
  signal rd_state : rd_state_t;

begin

  registers.MCP3221_CONTROL.DEVICE_ADDRESS <= registers.MCP3221_CONTROL_REG(7 downto 1);
  registers.MCP3221_CONTROL.SW_RESETN <= registers.MCP3221_CONTROL_REG(0);
  registers.SAMPLE_RATE_DIVIDER.SAMPLE_RATE_DIVIDER <= registers.SAMPLE_RATE_DIVIDER_REG(31 downto 0);

  registers_out <= registers;

  s_axi_rresp   <= (others => '0');
  s_axi_bresp   <= (others => '0');
  s_axi_bvalid  <= '1';

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_read_only_regs : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.DATA_REG <= x"00000000";
        registers.STATUS_REG <= x"00000000";
      else
        if s_DATA_DATA_v = '1' then
          registers.DATA_REG(15 downto 0) <= s_DATA_DATA;
        end if;
        if s_STATUS_ACKS_v = '1' then
          registers.STATUS_REG(4 downto 2) <= s_STATUS_ACKS;
        end if;
        if s_STATUS_DOUT_VALID_v = '1' then
          registers.STATUS_REG(1) <= s_STATUS_DOUT_VALID;
        end if;
        if s_STATUS_DIN_READY_v = '1' then
          registers.STATUS_REG(0) <= s_STATUS_DIN_READY;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.MCP3221_CONTROL_REG <= x"00000000";
        registers.SAMPLE_RATE_DIVIDER_REG <= x"00000000";
        registers.AWC_TEST_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.MCP3221_CONTROL_wr_pulse <= '0';
        registers.SAMPLE_RATE_DIVIDER_wr_pulse <= '0';
        registers.DATA_wr_pulse <= '0';
        registers.STATUS_wr_pulse <= '0';
        registers.AWC_TEST_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.MCP3221_CONTROL_wr_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_wr_pulse <= '0';
            registers.DATA_wr_pulse <= '0';
            registers.STATUS_wr_pulse <= '0';
            registers.AWC_TEST_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.MCP3221_CONTROL_wr_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_wr_pulse <= '0';
            registers.DATA_wr_pulse <= '0';
            registers.STATUS_wr_pulse <= '0';
            registers.AWC_TEST_wr_pulse <= '0';
            if s_AWC_TEST_ACKS_v = '1' then
              registers.AWC_TEST_REG(4 downto 2) <= registers.AWC_TEST_REG(4 downto 2) or s_AWC_TEST_ACKS;
            end if;
            if s_AWC_TEST_DOUT_VALID_v = '1' then
              registers.AWC_TEST_REG(1) <= registers.AWC_TEST_REG(1) or s_AWC_TEST_DOUT_VALID;
            end if;
            if s_AWC_TEST_DIN_READY_v = '1' then
              registers.AWC_TEST_REG(0) <= registers.AWC_TEST_REG(0) or s_AWC_TEST_DIN_READY;
            end if;
            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
              s_axi_awready_int <= '0';
              s_axi_wready_int  <= '1';
              awaddr            <= s_axi_awaddr;
              wr_state          <= wr_data;
            end if;

          when wr_data =>

            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
              case awaddr is
                when std_logic_vector(to_unsigned(MCP3221_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.MCP3221_CONTROL_REG <= s_axi_wdata;
                  registers.MCP3221_CONTROL_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SAMPLE_RATE_DIVIDER_REG <= s_axi_wdata;
                  registers.SAMPLE_RATE_DIVIDER_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DATA_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(AWC_TEST_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.AWC_TEST_REG <= registers.AWC_TEST_REG and (not s_axi_wdata);
                  registers.AWC_TEST_wr_pulse <= '1';
                when others =>
                  null;
              end case;

              s_axi_awready_int <= '1';
              s_axi_wready_int  <= '0';
              wr_state          <= get_addr;
            end if;

          when others =>
            wr_state <= init;

        end case;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------

  s_axi_arready     <= s_axi_arready_int;
  s_axi_rvalid      <= s_axi_rvalid_int;

  p_rd_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        araddr            <= (others => '0');
        s_axi_rdata       <= (others => '0');
        registers.MCP3221_CONTROL_rd_pulse <= '0';
        registers.SAMPLE_RATE_DIVIDER_rd_pulse <= '0';
        registers.DATA_rd_pulse <= '0';
        registers.STATUS_rd_pulse <= '0';
        registers.AWC_TEST_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.MCP3221_CONTROL_rd_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_rd_pulse <= '0';
            registers.DATA_rd_pulse <= '0';
            registers.STATUS_rd_pulse <= '0';
            registers.AWC_TEST_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.MCP3221_CONTROL_rd_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_rd_pulse <= '0';
            registers.DATA_rd_pulse <= '0';
            registers.STATUS_rd_pulse <= '0';
            registers.AWC_TEST_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(MCP3221_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.MCP3221_CONTROL_REG;
              when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.SAMPLE_RATE_DIVIDER_REG;
              when std_logic_vector(to_unsigned(DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DATA_REG;
              when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS_REG;
              when std_logic_vector(to_unsigned(AWC_TEST_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.AWC_TEST_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(MCP3221_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.MCP3221_CONTROL_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SAMPLE_RATE_DIVIDER_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DATA_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(AWC_TEST_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.AWC_TEST_rd_pulse <= '1';
                when others =>
                  null;
              end case;
              s_axi_arready_int <= '1';
              s_axi_rvalid_int  <= '0';
              rd_state          <= get_addr;
            else
              s_axi_rvalid_int  <= '1';
            end if;

          when others =>
            rd_state <= init;

        end case;
      end if;
    end if;
  end process;

end rtl;
