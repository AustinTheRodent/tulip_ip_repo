library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package button_iface_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type BUTTON_CONTROL_subreg_t is record
    SW_RESETN : std_logic;
  end record;

  type BUTTON_INTERRUPT_ENABLE_subreg_t is record
    BUTTON4_FLAT : std_logic;
    BUTTON4_PULSE : std_logic;
    BUTTON3_FLAT : std_logic;
    BUTTON3_PULSE : std_logic;
    BUTTON2_FLAT : std_logic;
    BUTTON2_PULSE : std_logic;
    BUTTON1_FLAT : std_logic;
    BUTTON1_PULSE : std_logic;
    BUTTON0_FLAT : std_logic;
    BUTTON0_PULSE : std_logic;
    ROTARY_B : std_logic;
    ROTARY_A : std_logic;
  end record;

  type BUTTON_INTERRUPT_subreg_t is record
    BUTTON4_FLAT : std_logic;
    BUTTON4_PULSE : std_logic;
    BUTTON3_FLAT : std_logic;
    BUTTON3_PULSE : std_logic;
    BUTTON2_FLAT : std_logic;
    BUTTON2_PULSE : std_logic;
    BUTTON1_FLAT : std_logic;
    BUTTON1_PULSE : std_logic;
    BUTTON0_FLAT : std_logic;
    BUTTON0_PULSE : std_logic;
    ROTARY_B : std_logic;
    ROTARY_A : std_logic;
  end record;

  type BUTTON_POST_RISING_EDGE_DELAY_subreg_t is record
    VALUE : std_logic_vector(31 downto 0);
  end record;

  type BUTTON_POST_FALLING_EDGE_DELAY_subreg_t is record
    VALUE : std_logic_vector(31 downto 0);
  end record;

  type BUTTON_RISING_EDGE_MIN_COUNT_subreg_t is record
    VALUE : std_logic_vector(31 downto 0);
  end record;

  type BUTTON_FALLING_EDGE_MIN_COUNT_subreg_t is record
    VALUE : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    BUTTON_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_INTERRUPT_ENABLE_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_INTERRUPT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTONS_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_POST_RISING_EDGE_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_POST_FALLING_EDGE_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_RISING_EDGE_MIN_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_FALLING_EDGE_MIN_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_DEBUG_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    BUTTON_CONTROL : BUTTON_CONTROL_subreg_t;
    BUTTON_INTERRUPT_ENABLE : BUTTON_INTERRUPT_ENABLE_subreg_t;
    BUTTON_INTERRUPT : BUTTON_INTERRUPT_subreg_t;
    BUTTON_POST_RISING_EDGE_DELAY : BUTTON_POST_RISING_EDGE_DELAY_subreg_t;
    BUTTON_POST_FALLING_EDGE_DELAY : BUTTON_POST_FALLING_EDGE_DELAY_subreg_t;
    BUTTON_RISING_EDGE_MIN_COUNT : BUTTON_RISING_EDGE_MIN_COUNT_subreg_t;
    BUTTON_FALLING_EDGE_MIN_COUNT : BUTTON_FALLING_EDGE_MIN_COUNT_subreg_t;
    BUTTON_CONTROL_wr_pulse : std_logic;
    BUTTON_INTERRUPT_ENABLE_wr_pulse : std_logic;
    BUTTON_INTERRUPT_wr_pulse : std_logic;
    BUTTONS_STATUS_wr_pulse : std_logic;
    BUTTON_POST_RISING_EDGE_DELAY_wr_pulse : std_logic;
    BUTTON_POST_FALLING_EDGE_DELAY_wr_pulse : std_logic;
    BUTTON_RISING_EDGE_MIN_COUNT_wr_pulse : std_logic;
    BUTTON_FALLING_EDGE_MIN_COUNT_wr_pulse : std_logic;
    BUTTON_DEBUG_wr_pulse : std_logic;
    BUTTON_CONTROL_rd_pulse : std_logic;
    BUTTON_INTERRUPT_ENABLE_rd_pulse : std_logic;
    BUTTON_INTERRUPT_rd_pulse : std_logic;
    BUTTONS_STATUS_rd_pulse : std_logic;
    BUTTON_POST_RISING_EDGE_DELAY_rd_pulse : std_logic;
    BUTTON_POST_FALLING_EDGE_DELAY_rd_pulse : std_logic;
    BUTTON_RISING_EDGE_MIN_COUNT_rd_pulse : std_logic;
    BUTTON_FALLING_EDGE_MIN_COUNT_rd_pulse : std_logic;
    BUTTON_DEBUG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.button_iface_pkg.all;

entity button_iface is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_BUTTONS_STATUS_A_PULSE : in std_logic;
    s_BUTTONS_STATUS_A_PULSE_v : in std_logic;

    s_BUTTONS_STATUS_B_PULSE : in std_logic;
    s_BUTTONS_STATUS_B_PULSE_v : in std_logic;

    s_BUTTONS_STATUS_BUTTON4 : in std_logic;
    s_BUTTONS_STATUS_BUTTON4_v : in std_logic;

    s_BUTTONS_STATUS_BUTTON3 : in std_logic;
    s_BUTTONS_STATUS_BUTTON3_v : in std_logic;

    s_BUTTONS_STATUS_BUTTON2 : in std_logic;
    s_BUTTONS_STATUS_BUTTON2_v : in std_logic;

    s_BUTTONS_STATUS_BUTTON1 : in std_logic;
    s_BUTTONS_STATUS_BUTTON1_v : in std_logic;

    s_BUTTONS_STATUS_BUTTON0 : in std_logic;
    s_BUTTONS_STATUS_BUTTON0_v : in std_logic;

    s_BUTTONS_STATUS_ROTARY_B : in std_logic;
    s_BUTTONS_STATUS_ROTARY_B_v : in std_logic;

    s_BUTTONS_STATUS_ROTARY_A : in std_logic;
    s_BUTTONS_STATUS_ROTARY_A_v : in std_logic;

    s_BUTTON_DEBUG_STATE : in std_logic_vector(7 downto 0);
    s_BUTTON_DEBUG_STATE_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON4_FLAT : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON4_FLAT_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON4_PULSE : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON4_PULSE_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON3_FLAT : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON3_FLAT_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON3_PULSE : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON3_PULSE_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON2_FLAT : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON2_FLAT_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON2_PULSE : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON2_PULSE_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON1_FLAT : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON1_FLAT_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON1_PULSE : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON1_PULSE_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON0_FLAT : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON0_FLAT_v : in std_logic;

    s_BUTTON_INTERRUPT_BUTTON0_PULSE : in std_logic;
    s_BUTTON_INTERRUPT_BUTTON0_PULSE_v : in std_logic;

    s_BUTTON_INTERRUPT_ROTARY_B : in std_logic;
    s_BUTTON_INTERRUPT_ROTARY_B_v : in std_logic;

    s_BUTTON_INTERRUPT_ROTARY_A : in std_logic;
    s_BUTTON_INTERRUPT_ROTARY_A_v : in std_logic;


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

architecture rtl of button_iface is

  constant BUTTON_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant BUTTON_INTERRUPT_ENABLE_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant BUTTON_INTERRUPT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant BUTTONS_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 256;
  constant BUTTON_POST_RISING_EDGE_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant BUTTON_POST_FALLING_EDGE_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant BUTTON_RISING_EDGE_MIN_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant BUTTON_FALLING_EDGE_MIN_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;
  constant BUTTON_DEBUG_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 28;

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

  registers.BUTTON_CONTROL.SW_RESETN <= registers.BUTTON_CONTROL_REG(0);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON4_FLAT <= registers.BUTTON_INTERRUPT_ENABLE_REG(11);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON4_PULSE <= registers.BUTTON_INTERRUPT_ENABLE_REG(10);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON3_FLAT <= registers.BUTTON_INTERRUPT_ENABLE_REG(9);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON3_PULSE <= registers.BUTTON_INTERRUPT_ENABLE_REG(8);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON2_FLAT <= registers.BUTTON_INTERRUPT_ENABLE_REG(7);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON2_PULSE <= registers.BUTTON_INTERRUPT_ENABLE_REG(6);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON1_FLAT <= registers.BUTTON_INTERRUPT_ENABLE_REG(5);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON1_PULSE <= registers.BUTTON_INTERRUPT_ENABLE_REG(4);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON0_FLAT <= registers.BUTTON_INTERRUPT_ENABLE_REG(3);
  registers.BUTTON_INTERRUPT_ENABLE.BUTTON0_PULSE <= registers.BUTTON_INTERRUPT_ENABLE_REG(2);
  registers.BUTTON_INTERRUPT_ENABLE.ROTARY_B <= registers.BUTTON_INTERRUPT_ENABLE_REG(1);
  registers.BUTTON_INTERRUPT_ENABLE.ROTARY_A <= registers.BUTTON_INTERRUPT_ENABLE_REG(0);
  registers.BUTTON_INTERRUPT.BUTTON4_FLAT <= registers.BUTTON_INTERRUPT_REG(11);
  registers.BUTTON_INTERRUPT.BUTTON4_PULSE <= registers.BUTTON_INTERRUPT_REG(10);
  registers.BUTTON_INTERRUPT.BUTTON3_FLAT <= registers.BUTTON_INTERRUPT_REG(9);
  registers.BUTTON_INTERRUPT.BUTTON3_PULSE <= registers.BUTTON_INTERRUPT_REG(8);
  registers.BUTTON_INTERRUPT.BUTTON2_FLAT <= registers.BUTTON_INTERRUPT_REG(7);
  registers.BUTTON_INTERRUPT.BUTTON2_PULSE <= registers.BUTTON_INTERRUPT_REG(6);
  registers.BUTTON_INTERRUPT.BUTTON1_FLAT <= registers.BUTTON_INTERRUPT_REG(5);
  registers.BUTTON_INTERRUPT.BUTTON1_PULSE <= registers.BUTTON_INTERRUPT_REG(4);
  registers.BUTTON_INTERRUPT.BUTTON0_FLAT <= registers.BUTTON_INTERRUPT_REG(3);
  registers.BUTTON_INTERRUPT.BUTTON0_PULSE <= registers.BUTTON_INTERRUPT_REG(2);
  registers.BUTTON_INTERRUPT.ROTARY_B <= registers.BUTTON_INTERRUPT_REG(1);
  registers.BUTTON_INTERRUPT.ROTARY_A <= registers.BUTTON_INTERRUPT_REG(0);
  registers.BUTTON_POST_RISING_EDGE_DELAY.VALUE <= registers.BUTTON_POST_RISING_EDGE_DELAY_REG(31 downto 0);
  registers.BUTTON_POST_FALLING_EDGE_DELAY.VALUE <= registers.BUTTON_POST_FALLING_EDGE_DELAY_REG(31 downto 0);
  registers.BUTTON_RISING_EDGE_MIN_COUNT.VALUE <= registers.BUTTON_RISING_EDGE_MIN_COUNT_REG(31 downto 0);
  registers.BUTTON_FALLING_EDGE_MIN_COUNT.VALUE <= registers.BUTTON_FALLING_EDGE_MIN_COUNT_REG(31 downto 0);

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
        registers.BUTTONS_STATUS_REG <= x"00000000";
        registers.BUTTON_DEBUG_REG <= x"00000000";
      else
        if s_BUTTONS_STATUS_A_PULSE_v = '1' then
          registers.BUTTONS_STATUS_REG(8) <= s_BUTTONS_STATUS_A_PULSE;
        end if;
        if s_BUTTONS_STATUS_B_PULSE_v = '1' then
          registers.BUTTONS_STATUS_REG(7) <= s_BUTTONS_STATUS_B_PULSE;
        end if;
        if s_BUTTONS_STATUS_BUTTON4_v = '1' then
          registers.BUTTONS_STATUS_REG(6) <= s_BUTTONS_STATUS_BUTTON4;
        end if;
        if s_BUTTONS_STATUS_BUTTON3_v = '1' then
          registers.BUTTONS_STATUS_REG(5) <= s_BUTTONS_STATUS_BUTTON3;
        end if;
        if s_BUTTONS_STATUS_BUTTON2_v = '1' then
          registers.BUTTONS_STATUS_REG(4) <= s_BUTTONS_STATUS_BUTTON2;
        end if;
        if s_BUTTONS_STATUS_BUTTON1_v = '1' then
          registers.BUTTONS_STATUS_REG(3) <= s_BUTTONS_STATUS_BUTTON1;
        end if;
        if s_BUTTONS_STATUS_BUTTON0_v = '1' then
          registers.BUTTONS_STATUS_REG(2) <= s_BUTTONS_STATUS_BUTTON0;
        end if;
        if s_BUTTONS_STATUS_ROTARY_B_v = '1' then
          registers.BUTTONS_STATUS_REG(1) <= s_BUTTONS_STATUS_ROTARY_B;
        end if;
        if s_BUTTONS_STATUS_ROTARY_A_v = '1' then
          registers.BUTTONS_STATUS_REG(0) <= s_BUTTONS_STATUS_ROTARY_A;
        end if;
        if s_BUTTON_DEBUG_STATE_v = '1' then
          registers.BUTTON_DEBUG_REG(7 downto 0) <= s_BUTTON_DEBUG_STATE;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.BUTTON_CONTROL_REG <= x"00000000";
        registers.BUTTON_INTERRUPT_ENABLE_REG <= x"00000000";
        registers.BUTTON_INTERRUPT_REG <= x"00000000";
        registers.BUTTON_POST_RISING_EDGE_DELAY_REG <= x"00000000";
        registers.BUTTON_POST_FALLING_EDGE_DELAY_REG <= x"00000000";
        registers.BUTTON_RISING_EDGE_MIN_COUNT_REG <= x"00000000";
        registers.BUTTON_FALLING_EDGE_MIN_COUNT_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.BUTTON_CONTROL_wr_pulse <= '0';
        registers.BUTTON_INTERRUPT_ENABLE_wr_pulse <= '0';
        registers.BUTTON_INTERRUPT_wr_pulse <= '0';
        registers.BUTTONS_STATUS_wr_pulse <= '0';
        registers.BUTTON_POST_RISING_EDGE_DELAY_wr_pulse <= '0';
        registers.BUTTON_POST_FALLING_EDGE_DELAY_wr_pulse <= '0';
        registers.BUTTON_RISING_EDGE_MIN_COUNT_wr_pulse <= '0';
        registers.BUTTON_FALLING_EDGE_MIN_COUNT_wr_pulse <= '0';
        registers.BUTTON_DEBUG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.BUTTON_CONTROL_wr_pulse <= '0';
            registers.BUTTON_INTERRUPT_ENABLE_wr_pulse <= '0';
            registers.BUTTON_INTERRUPT_wr_pulse <= '0';
            registers.BUTTONS_STATUS_wr_pulse <= '0';
            registers.BUTTON_POST_RISING_EDGE_DELAY_wr_pulse <= '0';
            registers.BUTTON_POST_FALLING_EDGE_DELAY_wr_pulse <= '0';
            registers.BUTTON_RISING_EDGE_MIN_COUNT_wr_pulse <= '0';
            registers.BUTTON_FALLING_EDGE_MIN_COUNT_wr_pulse <= '0';
            registers.BUTTON_DEBUG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.BUTTON_CONTROL_wr_pulse <= '0';
            registers.BUTTON_INTERRUPT_ENABLE_wr_pulse <= '0';
            registers.BUTTON_INTERRUPT_wr_pulse <= '0';
            registers.BUTTONS_STATUS_wr_pulse <= '0';
            registers.BUTTON_POST_RISING_EDGE_DELAY_wr_pulse <= '0';
            registers.BUTTON_POST_FALLING_EDGE_DELAY_wr_pulse <= '0';
            registers.BUTTON_RISING_EDGE_MIN_COUNT_wr_pulse <= '0';
            registers.BUTTON_FALLING_EDGE_MIN_COUNT_wr_pulse <= '0';
            registers.BUTTON_DEBUG_wr_pulse <= '0';
            if s_BUTTON_INTERRUPT_BUTTON4_FLAT_v = '1' then
              registers.BUTTON_INTERRUPT_REG(11) <= registers.BUTTON_INTERRUPT_REG(11) or s_BUTTON_INTERRUPT_BUTTON4_FLAT;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON4_PULSE_v = '1' then
              registers.BUTTON_INTERRUPT_REG(10) <= registers.BUTTON_INTERRUPT_REG(10) or s_BUTTON_INTERRUPT_BUTTON4_PULSE;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON3_FLAT_v = '1' then
              registers.BUTTON_INTERRUPT_REG(9) <= registers.BUTTON_INTERRUPT_REG(9) or s_BUTTON_INTERRUPT_BUTTON3_FLAT;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON3_PULSE_v = '1' then
              registers.BUTTON_INTERRUPT_REG(8) <= registers.BUTTON_INTERRUPT_REG(8) or s_BUTTON_INTERRUPT_BUTTON3_PULSE;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON2_FLAT_v = '1' then
              registers.BUTTON_INTERRUPT_REG(7) <= registers.BUTTON_INTERRUPT_REG(7) or s_BUTTON_INTERRUPT_BUTTON2_FLAT;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON2_PULSE_v = '1' then
              registers.BUTTON_INTERRUPT_REG(6) <= registers.BUTTON_INTERRUPT_REG(6) or s_BUTTON_INTERRUPT_BUTTON2_PULSE;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON1_FLAT_v = '1' then
              registers.BUTTON_INTERRUPT_REG(5) <= registers.BUTTON_INTERRUPT_REG(5) or s_BUTTON_INTERRUPT_BUTTON1_FLAT;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON1_PULSE_v = '1' then
              registers.BUTTON_INTERRUPT_REG(4) <= registers.BUTTON_INTERRUPT_REG(4) or s_BUTTON_INTERRUPT_BUTTON1_PULSE;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON0_FLAT_v = '1' then
              registers.BUTTON_INTERRUPT_REG(3) <= registers.BUTTON_INTERRUPT_REG(3) or s_BUTTON_INTERRUPT_BUTTON0_FLAT;
            end if;
            if s_BUTTON_INTERRUPT_BUTTON0_PULSE_v = '1' then
              registers.BUTTON_INTERRUPT_REG(2) <= registers.BUTTON_INTERRUPT_REG(2) or s_BUTTON_INTERRUPT_BUTTON0_PULSE;
            end if;
            if s_BUTTON_INTERRUPT_ROTARY_B_v = '1' then
              registers.BUTTON_INTERRUPT_REG(1) <= registers.BUTTON_INTERRUPT_REG(1) or s_BUTTON_INTERRUPT_ROTARY_B;
            end if;
            if s_BUTTON_INTERRUPT_ROTARY_A_v = '1' then
              registers.BUTTON_INTERRUPT_REG(0) <= registers.BUTTON_INTERRUPT_REG(0) or s_BUTTON_INTERRUPT_ROTARY_A;
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
                when std_logic_vector(to_unsigned(BUTTON_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_CONTROL_REG <= s_axi_wdata;
                  registers.BUTTON_CONTROL_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_INTERRUPT_ENABLE_REG <= s_axi_wdata;
                  registers.BUTTON_INTERRUPT_ENABLE_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_INTERRUPT_REG <= registers.BUTTON_INTERRUPT_REG and (not s_axi_wdata);
                  registers.BUTTON_INTERRUPT_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTONS_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTONS_STATUS_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_POST_RISING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_POST_RISING_EDGE_DELAY_REG <= s_axi_wdata;
                  registers.BUTTON_POST_RISING_EDGE_DELAY_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_POST_FALLING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_POST_FALLING_EDGE_DELAY_REG <= s_axi_wdata;
                  registers.BUTTON_POST_FALLING_EDGE_DELAY_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_RISING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_RISING_EDGE_MIN_COUNT_REG <= s_axi_wdata;
                  registers.BUTTON_RISING_EDGE_MIN_COUNT_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_FALLING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_FALLING_EDGE_MIN_COUNT_REG <= s_axi_wdata;
                  registers.BUTTON_FALLING_EDGE_MIN_COUNT_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_DEBUG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_DEBUG_wr_pulse <= '1';
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
        registers.BUTTON_CONTROL_rd_pulse <= '0';
        registers.BUTTON_INTERRUPT_ENABLE_rd_pulse <= '0';
        registers.BUTTON_INTERRUPT_rd_pulse <= '0';
        registers.BUTTONS_STATUS_rd_pulse <= '0';
        registers.BUTTON_POST_RISING_EDGE_DELAY_rd_pulse <= '0';
        registers.BUTTON_POST_FALLING_EDGE_DELAY_rd_pulse <= '0';
        registers.BUTTON_RISING_EDGE_MIN_COUNT_rd_pulse <= '0';
        registers.BUTTON_FALLING_EDGE_MIN_COUNT_rd_pulse <= '0';
        registers.BUTTON_DEBUG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.BUTTON_CONTROL_rd_pulse <= '0';
            registers.BUTTON_INTERRUPT_ENABLE_rd_pulse <= '0';
            registers.BUTTON_INTERRUPT_rd_pulse <= '0';
            registers.BUTTONS_STATUS_rd_pulse <= '0';
            registers.BUTTON_POST_RISING_EDGE_DELAY_rd_pulse <= '0';
            registers.BUTTON_POST_FALLING_EDGE_DELAY_rd_pulse <= '0';
            registers.BUTTON_RISING_EDGE_MIN_COUNT_rd_pulse <= '0';
            registers.BUTTON_FALLING_EDGE_MIN_COUNT_rd_pulse <= '0';
            registers.BUTTON_DEBUG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.BUTTON_CONTROL_rd_pulse <= '0';
            registers.BUTTON_INTERRUPT_ENABLE_rd_pulse <= '0';
            registers.BUTTON_INTERRUPT_rd_pulse <= '0';
            registers.BUTTONS_STATUS_rd_pulse <= '0';
            registers.BUTTON_POST_RISING_EDGE_DELAY_rd_pulse <= '0';
            registers.BUTTON_POST_FALLING_EDGE_DELAY_rd_pulse <= '0';
            registers.BUTTON_RISING_EDGE_MIN_COUNT_rd_pulse <= '0';
            registers.BUTTON_FALLING_EDGE_MIN_COUNT_rd_pulse <= '0';
            registers.BUTTON_DEBUG_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(BUTTON_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_CONTROL_REG;
              when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_INTERRUPT_ENABLE_REG;
              when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_INTERRUPT_REG;
              when std_logic_vector(to_unsigned(BUTTONS_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTONS_STATUS_REG;
              when std_logic_vector(to_unsigned(BUTTON_POST_RISING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_POST_RISING_EDGE_DELAY_REG;
              when std_logic_vector(to_unsigned(BUTTON_POST_FALLING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_POST_FALLING_EDGE_DELAY_REG;
              when std_logic_vector(to_unsigned(BUTTON_RISING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_RISING_EDGE_MIN_COUNT_REG;
              when std_logic_vector(to_unsigned(BUTTON_FALLING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_FALLING_EDGE_MIN_COUNT_REG;
              when std_logic_vector(to_unsigned(BUTTON_DEBUG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.BUTTON_DEBUG_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(BUTTON_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_CONTROL_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_ENABLE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_INTERRUPT_ENABLE_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_INTERRUPT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_INTERRUPT_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTONS_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTONS_STATUS_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_POST_RISING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_POST_RISING_EDGE_DELAY_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_POST_FALLING_EDGE_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_POST_FALLING_EDGE_DELAY_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_RISING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_RISING_EDGE_MIN_COUNT_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_FALLING_EDGE_MIN_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_FALLING_EDGE_MIN_COUNT_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(BUTTON_DEBUG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.BUTTON_DEBUG_rd_pulse <= '1';
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
