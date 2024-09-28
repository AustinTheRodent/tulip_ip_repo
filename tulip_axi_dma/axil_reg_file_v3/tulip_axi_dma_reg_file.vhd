library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package tulip_axi_dma_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    SW_RESETN : std_logic_vector(0 downto 0);
  end record;

  type DMA_TX_STATUS_RESET_subreg_t is record
    TX_STARTED : std_logic_vector(0 downto 0);
    TX_DONE : std_logic_vector(0 downto 0);
  end record;

  type DMA_TX_ADDR_MSBS_subreg_t is record
    TX_ADDR_MSBS : std_logic_vector(31 downto 0);
  end record;

  type DMA_TX_ADDR_subreg_t is record
    TX_ADDR_LSBS : std_logic_vector(31 downto 0);
  end record;

  type DMA_TX_TRANSACT_LEN_BYTES_subreg_t is record
    TX_TRANSACT_LEN_BYTES : std_logic_vector(31 downto 0);
  end record;

  type DMA_RX_STATUS_RESET_subreg_t is record
    RX_STARTED : std_logic_vector(0 downto 0);
    RX_DONE : std_logic_vector(0 downto 0);
  end record;

  type DMA_RX_ADDR_MSBS_subreg_t is record
    RX_ADDR_MSBS : std_logic_vector(31 downto 0);
  end record;

  type DMA_RX_ADDR_subreg_t is record
    RX_ADDR_LSBS : std_logic_vector(31 downto 0);
  end record;

  type DMA_RX_TRANSACT_LEN_BYTES_subreg_t is record
    RX_TRANSACT_LEN_BYTES : std_logic_vector(31 downto 0);
  end record;

  type DMA_FLUSH_BUS_subreg_t is record
    TRIGGER_FLUSH : std_logic_vector(0 downto 0);
  end record;

  type DMA_FLUSH_STATUS_CLEAR_subreg_t is record
    FLUSH_FINISHED : std_logic_vector(0 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_TX_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_TX_STATUS_RESET_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_TX_ADDR_MSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_TX_ADDR_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_TX_TRANSACT_LEN_BYTES_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_RX_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_RX_STATUS_RESET_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_RX_ADDR_MSBS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_RX_ADDR_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_RX_TRANSACT_LEN_BYTES_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_FLUSH_BUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_FLUSH_STATUS_CLEAR_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    DMA_FLUSH_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    DMA_TX_STATUS_RESET : DMA_TX_STATUS_RESET_subreg_t;
    DMA_TX_ADDR_MSBS : DMA_TX_ADDR_MSBS_subreg_t;
    DMA_TX_ADDR : DMA_TX_ADDR_subreg_t;
    DMA_TX_TRANSACT_LEN_BYTES : DMA_TX_TRANSACT_LEN_BYTES_subreg_t;
    DMA_RX_STATUS_RESET : DMA_RX_STATUS_RESET_subreg_t;
    DMA_RX_ADDR_MSBS : DMA_RX_ADDR_MSBS_subreg_t;
    DMA_RX_ADDR : DMA_RX_ADDR_subreg_t;
    DMA_RX_TRANSACT_LEN_BYTES : DMA_RX_TRANSACT_LEN_BYTES_subreg_t;
    DMA_FLUSH_BUS : DMA_FLUSH_BUS_subreg_t;
    DMA_FLUSH_STATUS_CLEAR : DMA_FLUSH_STATUS_CLEAR_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    DMA_TX_STATUS_REG_wr_pulse : std_logic;
    DMA_TX_STATUS_RESET_REG_wr_pulse : std_logic;
    DMA_TX_ADDR_MSBS_REG_wr_pulse : std_logic;
    DMA_TX_ADDR_REG_wr_pulse : std_logic;
    DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse : std_logic;
    DMA_RX_STATUS_REG_wr_pulse : std_logic;
    DMA_RX_STATUS_RESET_REG_wr_pulse : std_logic;
    DMA_RX_ADDR_MSBS_REG_wr_pulse : std_logic;
    DMA_RX_ADDR_REG_wr_pulse : std_logic;
    DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse : std_logic;
    DMA_FLUSH_BUS_REG_wr_pulse : std_logic;
    DMA_FLUSH_STATUS_CLEAR_REG_wr_pulse : std_logic;
    DMA_FLUSH_STATUS_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    DMA_TX_STATUS_REG_rd_pulse : std_logic;
    DMA_TX_STATUS_RESET_REG_rd_pulse : std_logic;
    DMA_TX_ADDR_MSBS_REG_rd_pulse : std_logic;
    DMA_TX_ADDR_REG_rd_pulse : std_logic;
    DMA_TX_TRANSACT_LEN_BYTES_REG_rd_pulse : std_logic;
    DMA_RX_STATUS_REG_rd_pulse : std_logic;
    DMA_RX_STATUS_RESET_REG_rd_pulse : std_logic;
    DMA_RX_ADDR_MSBS_REG_rd_pulse : std_logic;
    DMA_RX_ADDR_REG_rd_pulse : std_logic;
    DMA_RX_TRANSACT_LEN_BYTES_REG_rd_pulse : std_logic;
    DMA_FLUSH_BUS_REG_rd_pulse : std_logic;
    DMA_FLUSH_STATUS_CLEAR_REG_rd_pulse : std_logic;
    DMA_FLUSH_STATUS_REG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.tulip_axi_dma_reg_file_pkg.all;

entity tulip_axi_dma_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    s_axi_aresetn : in  std_logic;

    s_DMA_TX_STATUS_TX_STARTED : in std_logic_vector(0 downto 0);
    s_DMA_TX_STATUS_TX_STARTED_v : in std_logic;

    s_DMA_TX_STATUS_TX_DONE : in std_logic_vector(0 downto 0);
    s_DMA_TX_STATUS_TX_DONE_v : in std_logic;

    s_DMA_RX_STATUS_RX_STARTED : in std_logic_vector(0 downto 0);
    s_DMA_RX_STATUS_RX_STARTED_v : in std_logic;

    s_DMA_RX_STATUS_RX_DONE : in std_logic_vector(0 downto 0);
    s_DMA_RX_STATUS_RX_DONE_v : in std_logic;

    s_DMA_FLUSH_STATUS_FLUSH_FINISHED : in std_logic_vector(0 downto 0);
    s_DMA_FLUSH_STATUS_FLUSH_FINISHED_v : in std_logic;


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

architecture rtl of tulip_axi_dma_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant DMA_TX_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant DMA_TX_STATUS_RESET_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant DMA_TX_ADDR_MSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant DMA_TX_ADDR_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant DMA_TX_TRANSACT_LEN_BYTES_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant DMA_RX_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 260;
  constant DMA_RX_STATUS_RESET_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 264;
  constant DMA_RX_ADDR_MSBS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 268;
  constant DMA_RX_ADDR_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 272;
  constant DMA_RX_TRANSACT_LEN_BYTES_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 276;
  constant DMA_FLUSH_BUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 512;
  constant DMA_FLUSH_STATUS_CLEAR_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 516;
  constant DMA_FLUSH_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 520;

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
  registers.DMA_TX_STATUS_RESET.TX_STARTED <= registers.DMA_TX_STATUS_RESET_REG(1 downto 1);
  registers.DMA_TX_STATUS_RESET.TX_DONE <= registers.DMA_TX_STATUS_RESET_REG(0 downto 0);
  registers.DMA_TX_ADDR_MSBS.TX_ADDR_MSBS <= registers.DMA_TX_ADDR_MSBS_REG(31 downto 0);
  registers.DMA_TX_ADDR.TX_ADDR_LSBS <= registers.DMA_TX_ADDR_REG(31 downto 0);
  registers.DMA_TX_TRANSACT_LEN_BYTES.TX_TRANSACT_LEN_BYTES <= registers.DMA_TX_TRANSACT_LEN_BYTES_REG(31 downto 0);
  registers.DMA_RX_STATUS_RESET.RX_STARTED <= registers.DMA_RX_STATUS_RESET_REG(1 downto 1);
  registers.DMA_RX_STATUS_RESET.RX_DONE <= registers.DMA_RX_STATUS_RESET_REG(0 downto 0);
  registers.DMA_RX_ADDR_MSBS.RX_ADDR_MSBS <= registers.DMA_RX_ADDR_MSBS_REG(31 downto 0);
  registers.DMA_RX_ADDR.RX_ADDR_LSBS <= registers.DMA_RX_ADDR_REG(31 downto 0);
  registers.DMA_RX_TRANSACT_LEN_BYTES.RX_TRANSACT_LEN_BYTES <= registers.DMA_RX_TRANSACT_LEN_BYTES_REG(31 downto 0);
  registers.DMA_FLUSH_BUS.TRIGGER_FLUSH <= registers.DMA_FLUSH_BUS_REG(0 downto 0);
  registers.DMA_FLUSH_STATUS_CLEAR.FLUSH_FINISHED <= registers.DMA_FLUSH_STATUS_CLEAR_REG(0 downto 0);

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
        registers.DMA_TX_STATUS_REG <= x"00000000";
        registers.DMA_RX_STATUS_REG <= x"00000000";
        registers.DMA_FLUSH_STATUS_REG <= x"00000000";
      else
        if s_DMA_TX_STATUS_TX_STARTED_v = '1' then 
          registers.DMA_TX_STATUS_REG(1 downto 1) <= s_DMA_TX_STATUS_TX_STARTED;
        end if;
        if s_DMA_TX_STATUS_TX_DONE_v = '1' then 
          registers.DMA_TX_STATUS_REG(0 downto 0) <= s_DMA_TX_STATUS_TX_DONE;
        end if;
        if s_DMA_RX_STATUS_RX_STARTED_v = '1' then 
          registers.DMA_RX_STATUS_REG(1 downto 1) <= s_DMA_RX_STATUS_RX_STARTED;
        end if;
        if s_DMA_RX_STATUS_RX_DONE_v = '1' then 
          registers.DMA_RX_STATUS_REG(0 downto 0) <= s_DMA_RX_STATUS_RX_DONE;
        end if;
        if s_DMA_FLUSH_STATUS_FLUSH_FINISHED_v = '1' then 
          registers.DMA_FLUSH_STATUS_REG(0 downto 0) <= s_DMA_FLUSH_STATUS_FLUSH_FINISHED;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if s_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.DMA_TX_STATUS_RESET_REG <= x"00000000";
        registers.DMA_TX_ADDR_MSBS_REG <= x"00000000";
        registers.DMA_TX_ADDR_REG <= x"00000000";
        registers.DMA_TX_TRANSACT_LEN_BYTES_REG <= x"00000000";
        registers.DMA_RX_STATUS_RESET_REG <= x"00000000";
        registers.DMA_RX_ADDR_MSBS_REG <= x"00000000";
        registers.DMA_RX_ADDR_REG <= x"00000000";
        registers.DMA_RX_TRANSACT_LEN_BYTES_REG <= x"00000000";
        registers.DMA_FLUSH_BUS_REG <= x"00000000";
        registers.DMA_FLUSH_STATUS_CLEAR_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.DMA_TX_STATUS_REG_wr_pulse <= '0';
        registers.DMA_TX_STATUS_RESET_REG_wr_pulse <= '0';
        registers.DMA_TX_ADDR_MSBS_REG_wr_pulse <= '0';
        registers.DMA_TX_ADDR_REG_wr_pulse <= '0';
        registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
        registers.DMA_RX_STATUS_REG_wr_pulse <= '0';
        registers.DMA_RX_STATUS_RESET_REG_wr_pulse <= '0';
        registers.DMA_RX_ADDR_MSBS_REG_wr_pulse <= '0';
        registers.DMA_RX_ADDR_REG_wr_pulse <= '0';
        registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
        registers.DMA_FLUSH_BUS_REG_wr_pulse <= '0';
        registers.DMA_FLUSH_STATUS_CLEAR_REG_wr_pulse <= '0';
        registers.DMA_FLUSH_STATUS_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.DMA_TX_STATUS_REG_wr_pulse <= '0';
            registers.DMA_TX_STATUS_RESET_REG_wr_pulse <= '0';
            registers.DMA_TX_ADDR_MSBS_REG_wr_pulse <= '0';
            registers.DMA_TX_ADDR_REG_wr_pulse <= '0';
            registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
            registers.DMA_RX_STATUS_REG_wr_pulse <= '0';
            registers.DMA_RX_STATUS_RESET_REG_wr_pulse <= '0';
            registers.DMA_RX_ADDR_MSBS_REG_wr_pulse <= '0';
            registers.DMA_RX_ADDR_REG_wr_pulse <= '0';
            registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_BUS_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_STATUS_CLEAR_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_STATUS_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.DMA_TX_STATUS_REG_wr_pulse <= '0';
            registers.DMA_TX_STATUS_RESET_REG_wr_pulse <= '0';
            registers.DMA_TX_ADDR_MSBS_REG_wr_pulse <= '0';
            registers.DMA_TX_ADDR_REG_wr_pulse <= '0';
            registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
            registers.DMA_RX_STATUS_REG_wr_pulse <= '0';
            registers.DMA_RX_STATUS_RESET_REG_wr_pulse <= '0';
            registers.DMA_RX_ADDR_MSBS_REG_wr_pulse <= '0';
            registers.DMA_RX_ADDR_REG_wr_pulse <= '0';
            registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_BUS_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_STATUS_CLEAR_REG_wr_pulse <= '0';
            registers.DMA_FLUSH_STATUS_REG_wr_pulse <= '0';
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
                when std_logic_vector(to_unsigned(DMA_TX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_STATUS_RESET_REG <= s_axi_wdata;
                  registers.DMA_TX_STATUS_RESET_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_ADDR_MSBS_REG <= s_axi_wdata;
                  registers.DMA_TX_ADDR_MSBS_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_ADDR_REG <= s_axi_wdata;
                  registers.DMA_TX_ADDR_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_TRANSACT_LEN_BYTES_REG <= s_axi_wdata;
                  registers.DMA_TX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_STATUS_RESET_REG <= s_axi_wdata;
                  registers.DMA_RX_STATUS_RESET_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_ADDR_MSBS_REG <= s_axi_wdata;
                  registers.DMA_RX_ADDR_MSBS_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_ADDR_REG <= s_axi_wdata;
                  registers.DMA_RX_ADDR_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_TRANSACT_LEN_BYTES_REG <= s_axi_wdata;
                  registers.DMA_RX_TRANSACT_LEN_BYTES_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_FLUSH_BUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_FLUSH_BUS_REG <= s_axi_wdata;
                  registers.DMA_FLUSH_BUS_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_FLUSH_STATUS_CLEAR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_FLUSH_STATUS_CLEAR_REG <= s_axi_wdata;
                  registers.DMA_FLUSH_STATUS_CLEAR_REG_wr_pulse <= '1';
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
        registers.DMA_TX_STATUS_REG_rd_pulse <= '0';
        registers.DMA_TX_STATUS_RESET_REG_rd_pulse <= '0';
        registers.DMA_TX_ADDR_MSBS_REG_rd_pulse <= '0';
        registers.DMA_TX_ADDR_REG_rd_pulse <= '0';
        registers.DMA_TX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
        registers.DMA_RX_STATUS_REG_rd_pulse <= '0';
        registers.DMA_RX_STATUS_RESET_REG_rd_pulse <= '0';
        registers.DMA_RX_ADDR_MSBS_REG_rd_pulse <= '0';
        registers.DMA_RX_ADDR_REG_rd_pulse <= '0';
        registers.DMA_RX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
        registers.DMA_FLUSH_BUS_REG_rd_pulse <= '0';
        registers.DMA_FLUSH_STATUS_CLEAR_REG_rd_pulse <= '0';
        registers.DMA_FLUSH_STATUS_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.DMA_TX_STATUS_REG_rd_pulse <= '0';
            registers.DMA_TX_STATUS_RESET_REG_rd_pulse <= '0';
            registers.DMA_TX_ADDR_MSBS_REG_rd_pulse <= '0';
            registers.DMA_TX_ADDR_REG_rd_pulse <= '0';
            registers.DMA_TX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
            registers.DMA_RX_STATUS_REG_rd_pulse <= '0';
            registers.DMA_RX_STATUS_RESET_REG_rd_pulse <= '0';
            registers.DMA_RX_ADDR_MSBS_REG_rd_pulse <= '0';
            registers.DMA_RX_ADDR_REG_rd_pulse <= '0';
            registers.DMA_RX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_BUS_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_STATUS_CLEAR_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_STATUS_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.DMA_TX_STATUS_REG_rd_pulse <= '0';
            registers.DMA_TX_STATUS_RESET_REG_rd_pulse <= '0';
            registers.DMA_TX_ADDR_MSBS_REG_rd_pulse <= '0';
            registers.DMA_TX_ADDR_REG_rd_pulse <= '0';
            registers.DMA_TX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
            registers.DMA_RX_STATUS_REG_rd_pulse <= '0';
            registers.DMA_RX_STATUS_RESET_REG_rd_pulse <= '0';
            registers.DMA_RX_ADDR_MSBS_REG_rd_pulse <= '0';
            registers.DMA_RX_ADDR_REG_rd_pulse <= '0';
            registers.DMA_RX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_BUS_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_STATUS_CLEAR_REG_rd_pulse <= '0';
            registers.DMA_FLUSH_STATUS_REG_rd_pulse <= '0';
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
              when std_logic_vector(to_unsigned(DMA_TX_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_TX_STATUS_REG;
              when std_logic_vector(to_unsigned(DMA_TX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_TX_STATUS_RESET_REG;
              when std_logic_vector(to_unsigned(DMA_TX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_TX_ADDR_MSBS_REG;
              when std_logic_vector(to_unsigned(DMA_TX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_TX_ADDR_REG;
              when std_logic_vector(to_unsigned(DMA_TX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_TX_TRANSACT_LEN_BYTES_REG;
              when std_logic_vector(to_unsigned(DMA_RX_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_RX_STATUS_REG;
              when std_logic_vector(to_unsigned(DMA_RX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_RX_STATUS_RESET_REG;
              when std_logic_vector(to_unsigned(DMA_RX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_RX_ADDR_MSBS_REG;
              when std_logic_vector(to_unsigned(DMA_RX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_RX_ADDR_REG;
              when std_logic_vector(to_unsigned(DMA_RX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_RX_TRANSACT_LEN_BYTES_REG;
              when std_logic_vector(to_unsigned(DMA_FLUSH_BUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_FLUSH_BUS_REG;
              when std_logic_vector(to_unsigned(DMA_FLUSH_STATUS_CLEAR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_FLUSH_STATUS_CLEAR_REG;
              when std_logic_vector(to_unsigned(DMA_FLUSH_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.DMA_FLUSH_STATUS_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_STATUS_RESET_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_ADDR_MSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_ADDR_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_TX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_TX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_STATUS_RESET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_STATUS_RESET_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_ADDR_MSBS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_ADDR_MSBS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_ADDR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_ADDR_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_RX_TRANSACT_LEN_BYTES_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_RX_TRANSACT_LEN_BYTES_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_FLUSH_BUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_FLUSH_BUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_FLUSH_STATUS_CLEAR_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_FLUSH_STATUS_CLEAR_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(DMA_FLUSH_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.DMA_FLUSH_STATUS_REG_rd_pulse <= '1';
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
