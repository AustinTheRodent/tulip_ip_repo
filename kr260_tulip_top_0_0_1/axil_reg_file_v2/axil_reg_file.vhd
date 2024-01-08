library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    ENABLE : std_logic_vector(0 downto 0);
    FEEDBACK_MODE : std_logic_vector(0 downto 0);
  end record;

  type SCRATCH_subreg_t is record
    SCRATCH : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    SCRATCH_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    SCRATCH : SCRATCH_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    SCRATCH_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    SCRATCH_REG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity axil_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    a_axi_aresetn : in  std_logic;


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

architecture rtl of axil_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant SCRATCH_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;

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

  registers.CONTROL.ENABLE <= registers.CONTROL_REG(0 downto 0);
  registers.CONTROL.FEEDBACK_MODE <= registers.CONTROL_REG(1 downto 1);
  registers.SCRATCH.SCRATCH <= registers.SCRATCH_REG(31 downto 0);

  registers_out <= registers;

  s_axi_rresp   <= (others => '0');
  s_axi_bresp   <= (others => '0');
  s_axi_bvalid  <= '1';

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_read_only_regs : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
      else
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.SCRATCH_REG <= x"DEADBEEF";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.SCRATCH_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.SCRATCH_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.SCRATCH_REG_wr_pulse <= '0';
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
                when std_logic_vector(to_unsigned(SCRATCH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SCRATCH_REG <= s_axi_wdata;
                  registers.SCRATCH_REG_wr_pulse <= '1';
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
      if a_axi_aresetn = '0' then
        araddr            <= (others => '0');
        s_axi_rdata       <= (others => '0');
        registers.CONTROL_REG_rd_pulse <= '0';
        registers.SCRATCH_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.SCRATCH_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.SCRATCH_REG_rd_pulse <= '0';
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
              when std_logic_vector(to_unsigned(SCRATCH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.SCRATCH_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(SCRATCH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.SCRATCH_REG_rd_pulse <= '1';
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
