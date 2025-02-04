library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mcp3221_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    DEVICE_ADDRESS : std_logic_vector(6 downto 0);
    SW_RESETN : std_logic_vector(0 downto 0);
  end record;

  type SAMPLE_RATE_DIVIDER_subreg_t is record
    SAMPLE_RATE_DIVIDER : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    SAMPLE_RATE_DIVIDER_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DATA_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    SAMPLE_RATE_DIVIDER : SAMPLE_RATE_DIVIDER_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    SAMPLE_RATE_DIVIDER_REG_wr_pulse : std_logic;
    DATA_REG_wr_pulse : std_logic;
    STATUS_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    SAMPLE_RATE_DIVIDER_REG_rd_pulse : std_logic;
    DATA_REG_rd_pulse : std_logic;
    STATUS_REG_rd_pulse : std_logic;
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

    s_STATUS_DOUT_VALID : in std_logic_vector(0 downto 0);
    s_STATUS_DOUT_VALID_v : in std_logic;

    s_STATUS_DIN_READY : in std_logic_vector(0 downto 0);
    s_STATUS_DIN_READY_v : in std_logic;


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

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant SAMPLE_RATE_DIVIDER_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant DATA_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;

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

  registers.CONTROL.DEVICE_ADDRESS <= registers.CONTROL_REG(7 downto 1);
  registers.CONTROL.SW_RESETN <= registers.CONTROL_REG(0 downto 0);
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
        if s_STATUS_DOUT_VALID_v = '1' then 
          registers.STATUS_REG(1 downto 1) <= s_STATUS_DOUT_VALID;
        end if;
        if s_STATUS_DIN_READY_v = '1' then 
          registers.STATUS_REG(0 downto 0) <= s_STATUS_DIN_READY;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.SAMPLE_RATE_DIVIDER_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.SAMPLE_RATE_DIVIDER_REG_wr_pulse <= '0';
        registers.DATA_REG_wr_pulse <= '0';
        registers.STATUS_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_REG_wr_pulse <= '0';
            registers.DATA_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_REG_wr_pulse <= '0';
            registers.DATA_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
              s_axi_awready_int <= '0';
              s_axi_wready_int  <= '1';
              awaddr            <= s_axi_awaddr;
              wr_state          <= wr_data;
            end if;

          when wr_data =>

            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
              case awaddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG <= s_axi_wdata;
                  registers.CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SAMPLE_RATE_DIVIDER_REG <= s_axi_wdata;
                  registers.SAMPLE_RATE_DIVIDER_REG_wr_pulse <= '1';
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
        registers.CONTROL_REG_rd_pulse <= '0';
        registers.SAMPLE_RATE_DIVIDER_REG_rd_pulse <= '0';
        registers.DATA_REG_rd_pulse <= '0';
        registers.STATUS_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_REG_rd_pulse <= '0';
            registers.DATA_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.SAMPLE_RATE_DIVIDER_REG_rd_pulse <= '0';
            registers.DATA_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CONTROL_REG;
              when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.SAMPLE_RATE_DIVIDER_REG;
              when std_logic_vector(to_unsigned(DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DATA_REG;
              when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(SAMPLE_RATE_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SAMPLE_RATE_DIVIDER_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DATA_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_REG_rd_pulse <= '1';
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
