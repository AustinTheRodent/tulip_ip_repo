library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axis_sniffer_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    SW_RESETN : std_logic_vector(0 downto 0);
  end record;

  type SCRATCHPAD_subreg_t is record
    SCRATCH : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TRANSACTION_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TRANSACTION_VALUE_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    GLOBAL_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    FIFO_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    SCRATCHPAD_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CTRL_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    SCRATCHPAD : SCRATCHPAD_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    TRANSACTION_COUNT_REG_wr_pulse : std_logic;
    TRANSACTION_VALUE_REG_wr_pulse : std_logic;
    GLOBAL_STATUS_REG_wr_pulse : std_logic;
    FIFO_STATUS_REG_wr_pulse : std_logic;
    SCRATCHPAD_REG_wr_pulse : std_logic;
    CTRL_STATUS_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    TRANSACTION_COUNT_REG_rd_pulse : std_logic;
    TRANSACTION_VALUE_REG_rd_pulse : std_logic;
    GLOBAL_STATUS_REG_rd_pulse : std_logic;
    FIFO_STATUS_REG_rd_pulse : std_logic;
    SCRATCHPAD_REG_rd_pulse : std_logic;
    CTRL_STATUS_REG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axis_sniffer_reg_file_pkg.all;

entity axis_sniffer_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_TRANSACTION_COUNT_COUNT : in std_logic_vector(31 downto 0);
    s_TRANSACTION_COUNT_COUNT_v : in std_logic;

    s_TRANSACTION_VALUE_DATA : in std_logic_vector(31 downto 0);
    s_TRANSACTION_VALUE_DATA_v : in std_logic;

    s_GLOBAL_STATUS_TRANSACTION_OVERFLOW : in std_logic_vector(0 downto 0);
    s_GLOBAL_STATUS_TRANSACTION_OVERFLOW_v : in std_logic;

    s_FIFO_STATUS_FIFO_USED : in std_logic_vector(31 downto 0);
    s_FIFO_STATUS_FIFO_USED_v : in std_logic;

    s_CTRL_STATUS_S_AXIS_TVALID : in std_logic_vector(0 downto 0);
    s_CTRL_STATUS_S_AXIS_TVALID_v : in std_logic;

    s_CTRL_STATUS_M_AXIS_TREADY : in std_logic_vector(0 downto 0);
    s_CTRL_STATUS_M_AXIS_TREADY_v : in std_logic;


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

architecture rtl of axis_sniffer_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant TRANSACTION_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant TRANSACTION_VALUE_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant GLOBAL_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant FIFO_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant SCRATCHPAD_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant CTRL_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;

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

  registers.CONTROL.SW_RESETN <= registers.CONTROL_REG(0 downto 0);
  registers.SCRATCHPAD.SCRATCH <= registers.SCRATCHPAD_REG(31 downto 0);

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
        registers.TRANSACTION_COUNT_REG <= x"00000000";
        registers.TRANSACTION_VALUE_REG <= x"00000000";
        registers.GLOBAL_STATUS_REG <= x"00000000";
        registers.FIFO_STATUS_REG <= x"00000000";
        registers.CTRL_STATUS_REG <= x"00000000";
      else
        if s_TRANSACTION_COUNT_COUNT_v = '1' then 
          registers.TRANSACTION_COUNT_REG(31 downto 0) <= s_TRANSACTION_COUNT_COUNT;
        end if;
        if s_TRANSACTION_VALUE_DATA_v = '1' then 
          registers.TRANSACTION_VALUE_REG(31 downto 0) <= s_TRANSACTION_VALUE_DATA;
        end if;
        if s_GLOBAL_STATUS_TRANSACTION_OVERFLOW_v = '1' then 
          registers.GLOBAL_STATUS_REG(0 downto 0) <= s_GLOBAL_STATUS_TRANSACTION_OVERFLOW;
        end if;
        if s_FIFO_STATUS_FIFO_USED_v = '1' then 
          registers.FIFO_STATUS_REG(31 downto 0) <= s_FIFO_STATUS_FIFO_USED;
        end if;
        if s_CTRL_STATUS_S_AXIS_TVALID_v = '1' then 
          registers.CTRL_STATUS_REG(0 downto 0) <= s_CTRL_STATUS_S_AXIS_TVALID;
        end if;
        if s_CTRL_STATUS_M_AXIS_TREADY_v = '1' then 
          registers.CTRL_STATUS_REG(1 downto 1) <= s_CTRL_STATUS_M_AXIS_TREADY;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.SCRATCHPAD_REG <= x"CAFEBABE";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.TRANSACTION_COUNT_REG_wr_pulse <= '0';
        registers.TRANSACTION_VALUE_REG_wr_pulse <= '0';
        registers.GLOBAL_STATUS_REG_wr_pulse <= '0';
        registers.FIFO_STATUS_REG_wr_pulse <= '0';
        registers.SCRATCHPAD_REG_wr_pulse <= '0';
        registers.CTRL_STATUS_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.TRANSACTION_COUNT_REG_wr_pulse <= '0';
            registers.TRANSACTION_VALUE_REG_wr_pulse <= '0';
            registers.GLOBAL_STATUS_REG_wr_pulse <= '0';
            registers.FIFO_STATUS_REG_wr_pulse <= '0';
            registers.SCRATCHPAD_REG_wr_pulse <= '0';
            registers.CTRL_STATUS_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.TRANSACTION_COUNT_REG_wr_pulse <= '0';
            registers.TRANSACTION_VALUE_REG_wr_pulse <= '0';
            registers.GLOBAL_STATUS_REG_wr_pulse <= '0';
            registers.FIFO_STATUS_REG_wr_pulse <= '0';
            registers.SCRATCHPAD_REG_wr_pulse <= '0';
            registers.CTRL_STATUS_REG_wr_pulse <= '0';
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
                when std_logic_vector(to_unsigned(SCRATCHPAD_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SCRATCHPAD_REG <= s_axi_wdata;
                  registers.SCRATCHPAD_REG_wr_pulse <= '1';
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
        registers.TRANSACTION_COUNT_REG_rd_pulse <= '0';
        registers.TRANSACTION_VALUE_REG_rd_pulse <= '0';
        registers.GLOBAL_STATUS_REG_rd_pulse <= '0';
        registers.FIFO_STATUS_REG_rd_pulse <= '0';
        registers.SCRATCHPAD_REG_rd_pulse <= '0';
        registers.CTRL_STATUS_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.TRANSACTION_COUNT_REG_rd_pulse <= '0';
            registers.TRANSACTION_VALUE_REG_rd_pulse <= '0';
            registers.GLOBAL_STATUS_REG_rd_pulse <= '0';
            registers.FIFO_STATUS_REG_rd_pulse <= '0';
            registers.SCRATCHPAD_REG_rd_pulse <= '0';
            registers.CTRL_STATUS_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.TRANSACTION_COUNT_REG_rd_pulse <= '0';
            registers.TRANSACTION_VALUE_REG_rd_pulse <= '0';
            registers.GLOBAL_STATUS_REG_rd_pulse <= '0';
            registers.FIFO_STATUS_REG_rd_pulse <= '0';
            registers.SCRATCHPAD_REG_rd_pulse <= '0';
            registers.CTRL_STATUS_REG_rd_pulse <= '0';
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
              when std_logic_vector(to_unsigned(TRANSACTION_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TRANSACTION_COUNT_REG;
              when std_logic_vector(to_unsigned(TRANSACTION_VALUE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TRANSACTION_VALUE_REG;
              when std_logic_vector(to_unsigned(GLOBAL_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.GLOBAL_STATUS_REG;
              when std_logic_vector(to_unsigned(FIFO_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.FIFO_STATUS_REG;
              when std_logic_vector(to_unsigned(SCRATCHPAD_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.SCRATCHPAD_REG;
              when std_logic_vector(to_unsigned(CTRL_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CTRL_STATUS_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TRANSACTION_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TRANSACTION_COUNT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TRANSACTION_VALUE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TRANSACTION_VALUE_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(GLOBAL_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.GLOBAL_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(FIFO_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.FIFO_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(SCRATCHPAD_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SCRATCHPAD_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(CTRL_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CTRL_STATUS_REG_rd_pulse <= '1';
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
