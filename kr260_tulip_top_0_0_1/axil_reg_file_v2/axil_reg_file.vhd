library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    PS_2_I2S_ENABLE : std_logic_vector(0 downto 0);
    I2S_2_PS_ENABLE : std_logic_vector(0 downto 0);
    I2S_ENABLE : std_logic_vector(0 downto 0);
    SW_RESETN : std_logic_vector(0 downto 0);
  end record;

  type I2C_CONTROL_subreg_t is record
    I2C_IS_READ : std_logic_vector(0 downto 0);
    DEVICE_ADDRESS : std_logic_vector(6 downto 0);
    REGISTER_ADDRESS : std_logic_vector(6 downto 0);
    REGISTER_WR_DATA : std_logic_vector(8 downto 0);
  end record;

  type PS_2_I2S_FIFO_WRITE_L_subreg_t is record
    FIFO_VALUE_L : std_logic_vector(31 downto 0);
  end record;

  type PS_2_I2S_FIFO_WRITE_R_subreg_t is record
    FIFO_VALUE_R : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    VERSION_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2C_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2C_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_FIFO_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_READ_L_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_READ_R_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_WRITE_L_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_WRITE_R_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    I2C_CONTROL : I2C_CONTROL_subreg_t;
    PS_2_I2S_FIFO_WRITE_L : PS_2_I2S_FIFO_WRITE_L_subreg_t;
    PS_2_I2S_FIFO_WRITE_R : PS_2_I2S_FIFO_WRITE_R_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    VERSION_REG_wr_pulse : std_logic;
    I2C_CONTROL_REG_wr_pulse : std_logic;
    I2C_STATUS_REG_wr_pulse : std_logic;
    I2S_STATUS_REG_wr_pulse : std_logic;
    I2S_FIFO_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_COUNT_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_READ_L_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_READ_R_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_COUNT_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    VERSION_REG_rd_pulse : std_logic;
    I2C_CONTROL_REG_rd_pulse : std_logic;
    I2C_STATUS_REG_rd_pulse : std_logic;
    I2S_STATUS_REG_rd_pulse : std_logic;
    I2S_FIFO_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_COUNT_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_READ_L_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_READ_R_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_COUNT_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse : std_logic;
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

    s_VERSION_VERSION : in std_logic_vector(31 downto 0);
    s_VERSION_VERSION_v : in std_logic;

    s_I2C_STATUS_DIN_READY : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_DIN_READY_v : in std_logic;

    s_I2C_STATUS_DOUT_VALID : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_DOUT_VALID_v : in std_logic;

    s_I2C_STATUS_ACK_2 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_2_v : in std_logic;

    s_I2C_STATUS_ACK_1 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_1_v : in std_logic;

    s_I2C_STATUS_ACK_0 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_0_v : in std_logic;

    s_I2C_STATUS_REGISTER_RD_DATA : in std_logic_vector(8 downto 0);
    s_I2C_STATUS_REGISTER_RD_DATA_v : in std_logic;

    s_I2S_STATUS_ADC_ERROR : in std_logic_vector(0 downto 0);
    s_I2S_STATUS_ADC_ERROR_v : in std_logic;

    s_I2S_STATUS_DAC_ERROR : in std_logic_vector(0 downto 0);
    s_I2S_STATUS_DAC_ERROR_v : in std_logic;

    s_I2S_FIFO_FIFO_USED : in std_logic_vector(15 downto 0);
    s_I2S_FIFO_FIFO_USED_v : in std_logic;

    s_I2S_2_PS_FIFO_COUNT_FIFO_USED : in std_logic_vector(15 downto 0);
    s_I2S_2_PS_FIFO_COUNT_FIFO_USED_v : in std_logic;

    s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L : in std_logic_vector(31 downto 0);
    s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_v : in std_logic;

    s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R : in std_logic_vector(31 downto 0);
    s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_v : in std_logic;

    s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE : in std_logic_vector(15 downto 0);
    s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_v : in std_logic;


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
  constant VERSION_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant I2C_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant I2C_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant I2S_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant I2S_FIFO_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant I2S_2_PS_FIFO_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;
  constant I2S_2_PS_FIFO_READ_L_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 28;
  constant I2S_2_PS_FIFO_READ_R_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 32;
  constant PS_2_I2S_FIFO_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 36;
  constant PS_2_I2S_FIFO_WRITE_L_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 40;
  constant PS_2_I2S_FIFO_WRITE_R_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 44;

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

  registers.CONTROL.PS_2_I2S_ENABLE <= registers.CONTROL_REG(3 downto 3);
  registers.CONTROL.I2S_2_PS_ENABLE <= registers.CONTROL_REG(2 downto 2);
  registers.CONTROL.I2S_ENABLE <= registers.CONTROL_REG(1 downto 1);
  registers.CONTROL.SW_RESETN <= registers.CONTROL_REG(0 downto 0);
  registers.I2C_CONTROL.I2C_IS_READ <= registers.I2C_CONTROL_REG(23 downto 23);
  registers.I2C_CONTROL.DEVICE_ADDRESS <= registers.I2C_CONTROL_REG(22 downto 16);
  registers.I2C_CONTROL.REGISTER_ADDRESS <= registers.I2C_CONTROL_REG(15 downto 9);
  registers.I2C_CONTROL.REGISTER_WR_DATA <= registers.I2C_CONTROL_REG(8 downto 0);
  registers.PS_2_I2S_FIFO_WRITE_L.FIFO_VALUE_L <= registers.PS_2_I2S_FIFO_WRITE_L_REG(31 downto 0);
  registers.PS_2_I2S_FIFO_WRITE_R.FIFO_VALUE_R <= registers.PS_2_I2S_FIFO_WRITE_R_REG(31 downto 0);

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
        registers.VERSION_REG <= x"00000013";
        registers.I2C_STATUS_REG <= x"00000000";
        registers.I2S_STATUS_REG <= x"00000000";
        registers.I2S_FIFO_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_COUNT_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_READ_L_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_READ_R_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_COUNT_REG <= x"00000000";
      else
        if s_VERSION_VERSION_v = '1' then 
          registers.VERSION_REG(31 downto 0) <= s_VERSION_VERSION;
        end if;
        if s_I2C_STATUS_DIN_READY_v = '1' then 
          registers.I2C_STATUS_REG(13 downto 13) <= s_I2C_STATUS_DIN_READY;
        end if;
        if s_I2C_STATUS_DOUT_VALID_v = '1' then 
          registers.I2C_STATUS_REG(12 downto 12) <= s_I2C_STATUS_DOUT_VALID;
        end if;
        if s_I2C_STATUS_ACK_2_v = '1' then 
          registers.I2C_STATUS_REG(11 downto 11) <= s_I2C_STATUS_ACK_2;
        end if;
        if s_I2C_STATUS_ACK_1_v = '1' then 
          registers.I2C_STATUS_REG(10 downto 10) <= s_I2C_STATUS_ACK_1;
        end if;
        if s_I2C_STATUS_ACK_0_v = '1' then 
          registers.I2C_STATUS_REG(9 downto 9) <= s_I2C_STATUS_ACK_0;
        end if;
        if s_I2C_STATUS_REGISTER_RD_DATA_v = '1' then 
          registers.I2C_STATUS_REG(8 downto 0) <= s_I2C_STATUS_REGISTER_RD_DATA;
        end if;
        if s_I2S_STATUS_ADC_ERROR_v = '1' then 
          registers.I2S_STATUS_REG(0 downto 0) <= s_I2S_STATUS_ADC_ERROR;
        end if;
        if s_I2S_STATUS_DAC_ERROR_v = '1' then 
          registers.I2S_STATUS_REG(1 downto 1) <= s_I2S_STATUS_DAC_ERROR;
        end if;
        if s_I2S_FIFO_FIFO_USED_v = '1' then 
          registers.I2S_FIFO_REG(15 downto 0) <= s_I2S_FIFO_FIFO_USED;
        end if;
        if s_I2S_2_PS_FIFO_COUNT_FIFO_USED_v = '1' then 
          registers.I2S_2_PS_FIFO_COUNT_REG(15 downto 0) <= s_I2S_2_PS_FIFO_COUNT_FIFO_USED;
        end if;
        if s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_v = '1' then 
          registers.I2S_2_PS_FIFO_READ_L_REG(31 downto 0) <= s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L;
        end if;
        if s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_v = '1' then 
          registers.I2S_2_PS_FIFO_READ_R_REG(31 downto 0) <= s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R;
        end if;
        if s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_v = '1' then 
          registers.PS_2_I2S_FIFO_COUNT_REG(15 downto 0) <= s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.I2C_CONTROL_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_WRITE_L_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_WRITE_R_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.VERSION_REG_wr_pulse <= '0';
        registers.I2C_CONTROL_REG_wr_pulse <= '0';
        registers.I2C_STATUS_REG_wr_pulse <= '0';
        registers.I2S_STATUS_REG_wr_pulse <= '0';
        registers.I2S_FIFO_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.VERSION_REG_wr_pulse <= '0';
            registers.I2C_CONTROL_REG_wr_pulse <= '0';
            registers.I2C_STATUS_REG_wr_pulse <= '0';
            registers.I2S_STATUS_REG_wr_pulse <= '0';
            registers.I2S_FIFO_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.VERSION_REG_wr_pulse <= '0';
            registers.I2C_CONTROL_REG_wr_pulse <= '0';
            registers.I2C_STATUS_REG_wr_pulse <= '0';
            registers.I2S_STATUS_REG_wr_pulse <= '0';
            registers.I2S_FIFO_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
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
                when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_CONTROL_REG <= s_axi_wdata;
                  registers.I2C_CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_L_REG <= s_axi_wdata;
                  registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_R_REG <= s_axi_wdata;
                  registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '1';
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
        registers.VERSION_REG_rd_pulse <= '0';
        registers.I2C_CONTROL_REG_rd_pulse <= '0';
        registers.I2C_STATUS_REG_rd_pulse <= '0';
        registers.I2S_STATUS_REG_rd_pulse <= '0';
        registers.I2S_FIFO_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.VERSION_REG_rd_pulse <= '0';
            registers.I2C_CONTROL_REG_rd_pulse <= '0';
            registers.I2C_STATUS_REG_rd_pulse <= '0';
            registers.I2S_STATUS_REG_rd_pulse <= '0';
            registers.I2S_FIFO_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.VERSION_REG_rd_pulse <= '0';
            registers.I2C_CONTROL_REG_rd_pulse <= '0';
            registers.I2C_STATUS_REG_rd_pulse <= '0';
            registers.I2S_STATUS_REG_rd_pulse <= '0';
            registers.I2S_FIFO_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
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
              when std_logic_vector(to_unsigned(VERSION_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.VERSION_REG;
              when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2C_CONTROL_REG;
              when std_logic_vector(to_unsigned(I2C_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2C_STATUS_REG;
              when std_logic_vector(to_unsigned(I2S_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_STATUS_REG;
              when std_logic_vector(to_unsigned(I2S_FIFO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_FIFO_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_COUNT_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_READ_L_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_READ_R_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_COUNT_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_WRITE_L_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_WRITE_R_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(VERSION_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.VERSION_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2C_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_FIFO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_FIFO_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '1';
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
