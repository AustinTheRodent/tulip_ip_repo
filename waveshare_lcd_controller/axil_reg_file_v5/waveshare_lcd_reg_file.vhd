library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package waveshare_lcd_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type WAVESHARE_LCD_CONTROL_subreg_t is record
    CLK_POL : std_logic;
    DATA_PHASE : std_logic;
    MSB_FIRST : std_logic;
    MANUAL_CS_USR_MODE : std_logic;
    AXI_LITE_MODE : std_logic;
    SW_RESETN : std_logic;
  end record;

  type PWM_CONTROLLER_subreg_t is record
    CLOCK_DIVIDER : std_logic_vector(7 downto 0);
    ANALOG_VALUE : std_logic_vector(16 downto 0);
  end record;

  type WAVESHARE_LCD_INTERRUPT_ENABLE_subreg_t is record
    SPI_S_LAST : std_logic;
    SPI_M_VALID : std_logic;
    SPI_M_LAST : std_logic;
  end record;

  type WAVESHARE_LCD_INTERRUPT_subreg_t is record
    SPI_S_LAST : std_logic;
    SPI_M_VALID : std_logic;
    SPI_M_LAST : std_logic;
  end record;

  type WAVESHARE_LCD_SPI_DATA_subreg_t is record
    DATA : std_logic_vector(17 downto 0);
  end record;

  type WAVESHARE_SPI_CS_USR_subreg_t is record
    USR : std_logic;
    CS : std_logic;
  end record;

  type WAVESHARE_SPI_TX_DELAY_subreg_t is record
    DELAY : std_logic_vector(31 downto 0);
  end record;

  type WAVESHARE_SPI_CLK_DIVIDER_subreg_t is record
    DELAY : std_logic_vector(31 downto 0);
  end record;

  type WAVESHARE_SPI_CS_FRONT_DELAY_subreg_t is record
    DELAY : std_logic_vector(31 downto 0);
  end record;

  type WAVESHARE_SPI_CS_BACK_DELAY_subreg_t is record
    DELAY : std_logic_vector(31 downto 0);
  end record;

  type WAVESHARE_SPI_TX_LEN_subreg_t is record
    LEN : std_logic_vector(7 downto 0);
  end record;


  type reg_t is record
    WAVESHARE_LCD_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PWM_CONTROLLER_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_LCD_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_LCD_INTERRUPT_ENABLE_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_LCD_INTERRUPT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_LCD_SPI_DATA_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_CS_USR_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_TX_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_CLK_DIVIDER_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_CS_FRONT_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_CS_BACK_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_SPI_TX_LEN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    WAVESHARE_LCD_CONTROL : WAVESHARE_LCD_CONTROL_subreg_t;
    PWM_CONTROLLER : PWM_CONTROLLER_subreg_t;
    WAVESHARE_LCD_INTERRUPT_ENABLE : WAVESHARE_LCD_INTERRUPT_ENABLE_subreg_t;
    WAVESHARE_LCD_INTERRUPT : WAVESHARE_LCD_INTERRUPT_subreg_t;
    WAVESHARE_LCD_SPI_DATA : WAVESHARE_LCD_SPI_DATA_subreg_t;
    WAVESHARE_SPI_CS_USR : WAVESHARE_SPI_CS_USR_subreg_t;
    WAVESHARE_SPI_TX_DELAY : WAVESHARE_SPI_TX_DELAY_subreg_t;
    WAVESHARE_SPI_CLK_DIVIDER : WAVESHARE_SPI_CLK_DIVIDER_subreg_t;
    WAVESHARE_SPI_CS_FRONT_DELAY : WAVESHARE_SPI_CS_FRONT_DELAY_subreg_t;
    WAVESHARE_SPI_CS_BACK_DELAY : WAVESHARE_SPI_CS_BACK_DELAY_subreg_t;
    WAVESHARE_SPI_TX_LEN : WAVESHARE_SPI_TX_LEN_subreg_t;
    WAVESHARE_LCD_CONTROL_wr_pulse : std_logic;
    PWM_CONTROLLER_wr_pulse : std_logic;
    WAVESHARE_LCD_STATUS_wr_pulse : std_logic;
    WAVESHARE_LCD_INTERRUPT_ENABLE_wr_pulse : std_logic;
    WAVESHARE_LCD_INTERRUPT_wr_pulse : std_logic;
    WAVESHARE_LCD_SPI_DATA_wr_pulse : std_logic;
    WAVESHARE_SPI_CS_USR_wr_pulse : std_logic;
    WAVESHARE_SPI_TX_DELAY_wr_pulse : std_logic;
    WAVESHARE_SPI_CLK_DIVIDER_wr_pulse : std_logic;
    WAVESHARE_SPI_CS_FRONT_DELAY_wr_pulse : std_logic;
    WAVESHARE_SPI_CS_BACK_DELAY_wr_pulse : std_logic;
    WAVESHARE_SPI_TX_LEN_wr_pulse : std_logic;
    WAVESHARE_LCD_CONTROL_rd_pulse : std_logic;
    PWM_CONTROLLER_rd_pulse : std_logic;
    WAVESHARE_LCD_STATUS_rd_pulse : std_logic;
    WAVESHARE_LCD_INTERRUPT_ENABLE_rd_pulse : std_logic;
    WAVESHARE_LCD_INTERRUPT_rd_pulse : std_logic;
    WAVESHARE_LCD_SPI_DATA_rd_pulse : std_logic;
    WAVESHARE_SPI_CS_USR_rd_pulse : std_logic;
    WAVESHARE_SPI_TX_DELAY_rd_pulse : std_logic;
    WAVESHARE_SPI_CLK_DIVIDER_rd_pulse : std_logic;
    WAVESHARE_SPI_CS_FRONT_DELAY_rd_pulse : std_logic;
    WAVESHARE_SPI_CS_BACK_DELAY_rd_pulse : std_logic;
    WAVESHARE_SPI_TX_LEN_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.waveshare_lcd_reg_file_pkg.all;

entity waveshare_lcd_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_WAVESHARE_LCD_STATUS_SPI_S_VALID : in std_logic;
    s_WAVESHARE_LCD_STATUS_SPI_S_VALID_v : in std_logic;

    s_WAVESHARE_LCD_STATUS_SPI_S_READY : in std_logic;
    s_WAVESHARE_LCD_STATUS_SPI_S_READY_v : in std_logic;

    s_WAVESHARE_LCD_STATUS_SPI_M_VALID : in std_logic;
    s_WAVESHARE_LCD_STATUS_SPI_M_VALID_v : in std_logic;

    s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST : in std_logic;
    s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST_v : in std_logic;

    s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID : in std_logic;
    s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID_v : in std_logic;

    s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST : in std_logic;
    s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST_v : in std_logic;


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

architecture rtl of waveshare_lcd_reg_file is

  constant WAVESHARE_LCD_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant PWM_CONTROLLER_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant WAVESHARE_LCD_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant WAVESHARE_LCD_INTERRUPT_ENABLE_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant WAVESHARE_LCD_INTERRUPT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant WAVESHARE_LCD_SPI_DATA_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant WAVESHARE_SPI_CS_USR_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;
  constant WAVESHARE_SPI_TX_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 28;
  constant WAVESHARE_SPI_CLK_DIVIDER_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 32;
  constant WAVESHARE_SPI_CS_FRONT_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 36;
  constant WAVESHARE_SPI_CS_BACK_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 40;
  constant WAVESHARE_SPI_TX_LEN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 44;

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

  registers.WAVESHARE_LCD_CONTROL.CLK_POL <= registers.WAVESHARE_LCD_CONTROL_REG(5);
  registers.WAVESHARE_LCD_CONTROL.DATA_PHASE <= registers.WAVESHARE_LCD_CONTROL_REG(4);
  registers.WAVESHARE_LCD_CONTROL.MSB_FIRST <= registers.WAVESHARE_LCD_CONTROL_REG(3);
  registers.WAVESHARE_LCD_CONTROL.MANUAL_CS_USR_MODE <= registers.WAVESHARE_LCD_CONTROL_REG(2);
  registers.WAVESHARE_LCD_CONTROL.AXI_LITE_MODE <= registers.WAVESHARE_LCD_CONTROL_REG(1);
  registers.WAVESHARE_LCD_CONTROL.SW_RESETN <= registers.WAVESHARE_LCD_CONTROL_REG(0);
  registers.PWM_CONTROLLER.CLOCK_DIVIDER <= registers.PWM_CONTROLLER_REG(31 downto 24);
  registers.PWM_CONTROLLER.ANALOG_VALUE <= registers.PWM_CONTROLLER_REG(16 downto 0);
  registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_S_LAST <= registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG(2);
  registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_M_VALID <= registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG(1);
  registers.WAVESHARE_LCD_INTERRUPT_ENABLE.SPI_M_LAST <= registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG(0);
  registers.WAVESHARE_LCD_INTERRUPT.SPI_S_LAST <= registers.WAVESHARE_LCD_INTERRUPT_REG(2);
  registers.WAVESHARE_LCD_INTERRUPT.SPI_M_VALID <= registers.WAVESHARE_LCD_INTERRUPT_REG(1);
  registers.WAVESHARE_LCD_INTERRUPT.SPI_M_LAST <= registers.WAVESHARE_LCD_INTERRUPT_REG(0);
  registers.WAVESHARE_LCD_SPI_DATA.DATA <= registers.WAVESHARE_LCD_SPI_DATA_REG(17 downto 0);
  registers.WAVESHARE_SPI_CS_USR.USR <= registers.WAVESHARE_SPI_CS_USR_REG(1);
  registers.WAVESHARE_SPI_CS_USR.CS <= registers.WAVESHARE_SPI_CS_USR_REG(0);
  registers.WAVESHARE_SPI_TX_DELAY.DELAY <= registers.WAVESHARE_SPI_TX_DELAY_REG(31 downto 0);
  registers.WAVESHARE_SPI_CLK_DIVIDER.DELAY <= registers.WAVESHARE_SPI_CLK_DIVIDER_REG(31 downto 0);
  registers.WAVESHARE_SPI_CS_FRONT_DELAY.DELAY <= registers.WAVESHARE_SPI_CS_FRONT_DELAY_REG(31 downto 0);
  registers.WAVESHARE_SPI_CS_BACK_DELAY.DELAY <= registers.WAVESHARE_SPI_CS_BACK_DELAY_REG(31 downto 0);
  registers.WAVESHARE_SPI_TX_LEN.LEN <= registers.WAVESHARE_SPI_TX_LEN_REG(7 downto 0);

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
        registers.WAVESHARE_LCD_STATUS_REG <= x"00000000";
      else
        if s_WAVESHARE_LCD_STATUS_SPI_S_VALID_v = '1' then
          registers.WAVESHARE_LCD_STATUS_REG(2) <= s_WAVESHARE_LCD_STATUS_SPI_S_VALID;
        end if;
        if s_WAVESHARE_LCD_STATUS_SPI_S_READY_v = '1' then
          registers.WAVESHARE_LCD_STATUS_REG(1) <= s_WAVESHARE_LCD_STATUS_SPI_S_READY;
        end if;
        if s_WAVESHARE_LCD_STATUS_SPI_M_VALID_v = '1' then
          registers.WAVESHARE_LCD_STATUS_REG(0) <= s_WAVESHARE_LCD_STATUS_SPI_M_VALID;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.WAVESHARE_LCD_CONTROL_REG <= x"00000000";
        registers.PWM_CONTROLLER_REG <= x"00000000";
        registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG <= x"00000000";
        registers.WAVESHARE_LCD_INTERRUPT_REG <= x"00000000";
        registers.WAVESHARE_LCD_SPI_DATA_REG <= x"00000000";
        registers.WAVESHARE_SPI_CS_USR_REG <= x"00000000";
        registers.WAVESHARE_SPI_TX_DELAY_REG <= x"00000000";
        registers.WAVESHARE_SPI_CLK_DIVIDER_REG <= x"00000000";
        registers.WAVESHARE_SPI_CS_FRONT_DELAY_REG <= x"00000000";
        registers.WAVESHARE_SPI_CS_BACK_DELAY_REG <= x"00000000";
        registers.WAVESHARE_SPI_TX_LEN_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.WAVESHARE_LCD_CONTROL_wr_pulse <= '0';
        registers.PWM_CONTROLLER_wr_pulse <= '0';
        registers.WAVESHARE_LCD_STATUS_wr_pulse <= '0';
        registers.WAVESHARE_LCD_INTERRUPT_ENABLE_wr_pulse <= '0';
        registers.WAVESHARE_LCD_INTERRUPT_wr_pulse <= '0';
        registers.WAVESHARE_LCD_SPI_DATA_wr_pulse <= '0';
        registers.WAVESHARE_SPI_CS_USR_wr_pulse <= '0';
        registers.WAVESHARE_SPI_TX_DELAY_wr_pulse <= '0';
        registers.WAVESHARE_SPI_CLK_DIVIDER_wr_pulse <= '0';
        registers.WAVESHARE_SPI_CS_FRONT_DELAY_wr_pulse <= '0';
        registers.WAVESHARE_SPI_CS_BACK_DELAY_wr_pulse <= '0';
        registers.WAVESHARE_SPI_TX_LEN_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.WAVESHARE_LCD_CONTROL_wr_pulse <= '0';
            registers.PWM_CONTROLLER_wr_pulse <= '0';
            registers.WAVESHARE_LCD_STATUS_wr_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_ENABLE_wr_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_wr_pulse <= '0';
            registers.WAVESHARE_LCD_SPI_DATA_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_USR_wr_pulse <= '0';
            registers.WAVESHARE_SPI_TX_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CLK_DIVIDER_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_FRONT_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_BACK_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_TX_LEN_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.WAVESHARE_LCD_CONTROL_wr_pulse <= '0';
            registers.PWM_CONTROLLER_wr_pulse <= '0';
            registers.WAVESHARE_LCD_STATUS_wr_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_ENABLE_wr_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_wr_pulse <= '0';
            registers.WAVESHARE_LCD_SPI_DATA_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_USR_wr_pulse <= '0';
            registers.WAVESHARE_SPI_TX_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CLK_DIVIDER_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_FRONT_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_CS_BACK_DELAY_wr_pulse <= '0';
            registers.WAVESHARE_SPI_TX_LEN_wr_pulse <= '0';
            if s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST_v = '1' then
              registers.WAVESHARE_LCD_INTERRUPT_REG(2) <= registers.WAVESHARE_LCD_INTERRUPT_REG(2) or s_WAVESHARE_LCD_INTERRUPT_SPI_S_LAST;
            end if;
            if s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID_v = '1' then
              registers.WAVESHARE_LCD_INTERRUPT_REG(1) <= registers.WAVESHARE_LCD_INTERRUPT_REG(1) or s_WAVESHARE_LCD_INTERRUPT_SPI_M_VALID;
            end if;
            if s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST_v = '1' then
              registers.WAVESHARE_LCD_INTERRUPT_REG(0) <= registers.WAVESHARE_LCD_INTERRUPT_REG(0) or s_WAVESHARE_LCD_INTERRUPT_SPI_M_LAST;
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
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_CONTROL_REG <= s_axi_wdata;
                  registers.WAVESHARE_LCD_CONTROL_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(PWM_CONTROLLER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PWM_CONTROLLER_REG <= s_axi_wdata;
                  registers.PWM_CONTROLLER_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_STATUS_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG <= s_axi_wdata;
                  registers.WAVESHARE_LCD_INTERRUPT_ENABLE_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_INTERRUPT_REG <= registers.WAVESHARE_LCD_INTERRUPT_REG and (not s_axi_wdata);
                  registers.WAVESHARE_LCD_INTERRUPT_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_SPI_DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_SPI_DATA_REG <= s_axi_wdata;
                  registers.WAVESHARE_LCD_SPI_DATA_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_USR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_USR_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_CS_USR_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_TX_DELAY_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_TX_DELAY_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CLK_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CLK_DIVIDER_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_CLK_DIVIDER_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_FRONT_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_FRONT_DELAY_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_CS_FRONT_DELAY_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_BACK_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_BACK_DELAY_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_CS_BACK_DELAY_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_LEN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_TX_LEN_REG <= s_axi_wdata;
                  registers.WAVESHARE_SPI_TX_LEN_wr_pulse <= '1';
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
        registers.WAVESHARE_LCD_CONTROL_rd_pulse <= '0';
        registers.PWM_CONTROLLER_rd_pulse <= '0';
        registers.WAVESHARE_LCD_STATUS_rd_pulse <= '0';
        registers.WAVESHARE_LCD_INTERRUPT_ENABLE_rd_pulse <= '0';
        registers.WAVESHARE_LCD_INTERRUPT_rd_pulse <= '0';
        registers.WAVESHARE_LCD_SPI_DATA_rd_pulse <= '0';
        registers.WAVESHARE_SPI_CS_USR_rd_pulse <= '0';
        registers.WAVESHARE_SPI_TX_DELAY_rd_pulse <= '0';
        registers.WAVESHARE_SPI_CLK_DIVIDER_rd_pulse <= '0';
        registers.WAVESHARE_SPI_CS_FRONT_DELAY_rd_pulse <= '0';
        registers.WAVESHARE_SPI_CS_BACK_DELAY_rd_pulse <= '0';
        registers.WAVESHARE_SPI_TX_LEN_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.WAVESHARE_LCD_CONTROL_rd_pulse <= '0';
            registers.PWM_CONTROLLER_rd_pulse <= '0';
            registers.WAVESHARE_LCD_STATUS_rd_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_ENABLE_rd_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_rd_pulse <= '0';
            registers.WAVESHARE_LCD_SPI_DATA_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_USR_rd_pulse <= '0';
            registers.WAVESHARE_SPI_TX_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CLK_DIVIDER_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_FRONT_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_BACK_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_TX_LEN_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.WAVESHARE_LCD_CONTROL_rd_pulse <= '0';
            registers.PWM_CONTROLLER_rd_pulse <= '0';
            registers.WAVESHARE_LCD_STATUS_rd_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_ENABLE_rd_pulse <= '0';
            registers.WAVESHARE_LCD_INTERRUPT_rd_pulse <= '0';
            registers.WAVESHARE_LCD_SPI_DATA_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_USR_rd_pulse <= '0';
            registers.WAVESHARE_SPI_TX_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CLK_DIVIDER_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_FRONT_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_CS_BACK_DELAY_rd_pulse <= '0';
            registers.WAVESHARE_SPI_TX_LEN_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(WAVESHARE_LCD_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_LCD_CONTROL_REG;
              when std_logic_vector(to_unsigned(PWM_CONTROLLER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PWM_CONTROLLER_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_LCD_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_LCD_STATUS_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_LCD_INTERRUPT_ENABLE_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_LCD_INTERRUPT_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_LCD_SPI_DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_LCD_SPI_DATA_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_USR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_CS_USR_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_TX_DELAY_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_CLK_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_CLK_DIVIDER_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_FRONT_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_CS_FRONT_DELAY_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_BACK_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_CS_BACK_DELAY_REG;
              when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_LEN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.WAVESHARE_SPI_TX_LEN_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_CONTROL_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PWM_CONTROLLER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PWM_CONTROLLER_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_STATUS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_INTERRUPT_ENABLE_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_INTERRUPT_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_LCD_SPI_DATA_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_LCD_SPI_DATA_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_USR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_USR_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_TX_DELAY_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CLK_DIVIDER_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CLK_DIVIDER_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_FRONT_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_FRONT_DELAY_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_CS_BACK_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_CS_BACK_DELAY_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(WAVESHARE_SPI_TX_LEN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.WAVESHARE_SPI_TX_LEN_rd_pulse <= '1';
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
