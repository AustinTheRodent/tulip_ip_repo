library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sw_dsp_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    ENGAUGE_LOOPBACK : std_logic_vector(0 downto 0);
  end record;

  type STATUS_RESET_subreg_t is record
    M_AXIS_OVERFLOW : std_logic_vector(0 downto 0);
    S_AXIS_UNDERFLOW : std_logic_vector(0 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS_RESET_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DIN_FIFO_USED_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DOUT_FIFO_USED_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    STATUS_RESET : STATUS_RESET_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    STATUS_RESET_REG_wr_pulse : std_logic;
    STATUS_REG_wr_pulse : std_logic;
    DIN_FIFO_USED_REG_wr_pulse : std_logic;
    DOUT_FIFO_USED_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    STATUS_RESET_REG_rd_pulse : std_logic;
    STATUS_REG_rd_pulse : std_logic;
    DIN_FIFO_USED_REG_rd_pulse : std_logic;
    DOUT_FIFO_USED_REG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.sw_dsp_reg_file_pkg.all;

entity sw_dsp_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_STATUS_M_AXIS_OVERFLOW : in std_logic_vector(0 downto 0);
    s_STATUS_M_AXIS_OVERFLOW_v : in std_logic;

    s_STATUS_S_AXIS_UNDERFLOW : in std_logic_vector(0 downto 0);
    s_STATUS_S_AXIS_UNDERFLOW_v : in std_logic;

    s_DIN_FIFO_USED_FIFO_USED : in std_logic_vector(31 downto 0);
    s_DIN_FIFO_USED_FIFO_USED_v : in std_logic;

    s_DOUT_FIFO_USED_FIFO_USED : in std_logic_vector(31 downto 0);
    s_DOUT_FIFO_USED_FIFO_USED_v : in std_logic;


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

architecture rtl of sw_dsp_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant STATUS_RESET_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant DIN_FIFO_USED_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant DOUT_FIFO_USED_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;

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

  registers.CONTROL.ENGAUGE_LOOPBACK <= registers.CONTROL_REG(0 downto 0);
  registers.STATUS_RESET.M_AXIS_OVERFLOW <= registers.STATUS_RESET_REG(1 downto 1);
  registers.STATUS_RESET.S_AXIS_UNDERFLOW <= registers.STATUS_RESET_REG(0 downto 0);

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
        registers.STATUS_REG <= x"00000000";
        registers.DIN_FIFO_USED_REG <= x"00000000";
        registers.DOUT_FIFO_USED_REG <= x"00000000";
      else
        if s_STATUS_M_AXIS_OVERFLOW_v = '1' then 
          registers.STATUS_REG(1 downto 1) <= s_STATUS_M_AXIS_OVERFLOW;
        end if;
        if s_STATUS_S_AXIS_UNDERFLOW_v = '1' then 
          registers.STATUS_REG(0 downto 0) <= s_STATUS_S_AXIS_UNDERFLOW;
        end if;
        if s_DIN_FIFO_USED_FIFO_USED_v = '1' then 
          registers.DIN_FIFO_USED_REG(31 downto 0) <= s_DIN_FIFO_USED_FIFO_USED;
        end if;
        if s_DOUT_FIFO_USED_FIFO_USED_v = '1' then 
          registers.DOUT_FIFO_USED_REG(31 downto 0) <= s_DOUT_FIFO_USED_FIFO_USED;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.STATUS_RESET_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.STATUS_RESET_REG_wr_pulse <= '0';
        registers.STATUS_REG_wr_pulse <= '0';
        registers.DIN_FIFO_USED_REG_wr_pulse <= '0';
        registers.DOUT_FIFO_USED_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.STATUS_RESET_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            registers.DIN_FIFO_USED_REG_wr_pulse <= '0';
            registers.DOUT_FIFO_USED_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.STATUS_RESET_REG_wr_pulse <= '0';
            registers.STATUS_REG_wr_pulse <= '0';
            registers.DIN_FIFO_USED_REG_wr_pulse <= '0';
            registers.DOUT_FIFO_USED_REG_wr_pulse <= '0';
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
                when std_logic_vector(to_unsigned(STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_RESET_REG <= s_axi_wdata;
                  registers.STATUS_RESET_REG_wr_pulse <= '1';
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
        registers.STATUS_RESET_REG_rd_pulse <= '0';
        registers.STATUS_REG_rd_pulse <= '0';
        registers.DIN_FIFO_USED_REG_rd_pulse <= '0';
        registers.DOUT_FIFO_USED_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.STATUS_RESET_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            registers.DIN_FIFO_USED_REG_rd_pulse <= '0';
            registers.DOUT_FIFO_USED_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.STATUS_RESET_REG_rd_pulse <= '0';
            registers.STATUS_REG_rd_pulse <= '0';
            registers.DIN_FIFO_USED_REG_rd_pulse <= '0';
            registers.DOUT_FIFO_USED_REG_rd_pulse <= '0';
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
              when std_logic_vector(to_unsigned(STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS_RESET_REG;
              when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.STATUS_REG;
              when std_logic_vector(to_unsigned(DIN_FIFO_USED_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DIN_FIFO_USED_REG;
              when std_logic_vector(to_unsigned(DOUT_FIFO_USED_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DOUT_FIFO_USED_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_RESET_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DIN_FIFO_USED_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DIN_FIFO_USED_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DOUT_FIFO_USED_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DOUT_FIFO_USED_REG_rd_pulse <= '1';
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
