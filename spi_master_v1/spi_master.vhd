library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
  generic
  (
    G_MAX_DWIDTH      : natural range 1 to 32 := 8;
    G_USER_WIDTH      : natural range 1 to 16 := 4;
    G_CHIP_SEL_WIDTH  : natural range 1 to 16 := 4
  );
  port
  (
    chip_select       : out std_logic_vector(G_CHIP_SEL_WIDTH-1 downto 0);
    dout_user         : out std_logic_vector(G_USER_WIDTH-1 downto 0);
    spi_clk           : out std_logic;
    spi_data_out      : out std_logic;
    spi_data_in       : in  std_logic;

    msb_first         : in  std_logic;
    data_phase        : in  std_logic;
    clk_polarity      : in  std_logic;
    cs_front_delay    : in  std_logic_vector(31 downto 0);
    cs_back_delay     : in  std_logic_vector(31 downto 0);
    spi_divider       : in  std_logic_vector(31 downto 0);
    transmission_len  : in  std_logic_vector(7 downto 0); -- in bits

    s_axis_aclk       : in  std_logic;
    s_axis_aresetn    : in  std_logic;
    s_axis_tdata      : in  std_logic_vector(G_USER_WIDTH+G_CHIP_SEL_WIDTH+G_MAX_DWIDTH-1 downto 0); -- s_axis_tdata <= USER & CHIP_SELECT & DATA
    s_axis_tvalid     : in  std_logic;
    s_axis_tready     : out std_logic;
    s_axis_tlast      : in  std_logic;

    m_axis_aclk       : in  std_logic;
    m_axis_aresetn    : in  std_logic;
    m_axis_tdata      : out std_logic_vector(G_MAX_DWIDTH-1 downto 0);
    m_axis_tvalid     : out std_logic;
    m_axis_tready     : in  std_logic;
    m_axis_tlast      : out std_logic
  );
end entity;

architecture rtl of spi_master is

  type spi_state_t is
  (
    SM_IDLE,
    SM_DELAY_CS_FRONT,
    SM_DELAY_CS_BACK,
    SM_TX_RX,
    SM_FINISH
  );
  signal spi_state : spi_state_t;

  signal msb_first_store        : std_logic;

  signal spi_divider_store      : unsigned(31 downto 0);
  signal spi_divider_half       : unsigned(31 downto 0);

  signal cs_front_delay_store   : unsigned(31 downto 0);
  signal cs_front_delay_counter : unsigned(31 downto 0);
  signal cs_back_delay_store    : unsigned(31 downto 0);
  signal cs_back_delay_counter  : unsigned(31 downto 0);

  signal s_axis_tuser           : std_logic_vector(G_USER_WIDTH-1 downto 0);
  signal s_axis_tcs             : std_logic_vector(G_CHIP_SEL_WIDTH-1 downto 0);
  signal s_axis_tdata_data      : std_logic_vector(G_MAX_DWIDTH-1 downto 0);

  signal din_reg                : std_logic_vector(G_MAX_DWIDTH-1 downto 0);
  signal len_reg                : std_logic_vector(7 downto 0);
  signal spi_counter            : natural range 0 to 100000;
  signal data_count             : natural range 0 to 32;
  signal data_count_pha         : natural range 0 to 32;
  signal data_count_pol         : natural range 0 to 32;
  signal rx_reg                 : std_logic_vector(G_MAX_DWIDTH-1 downto 0);
  signal spi_data_in_cross_0    : std_logic;
  signal spi_data_in_cross_1    : std_logic;

  signal din_last_hold          : std_logic;

  signal din_ready_int          : std_logic;
  signal dout_valid_int         : std_logic;

begin

  spi_divider_half  <= shift_right(spi_divider_store, 1);

  s_axis_tuser      <= s_axis_tdata(G_USER_WIDTH+G_CHIP_SEL_WIDTH+G_MAX_DWIDTH-1 downto G_CHIP_SEL_WIDTH+G_MAX_DWIDTH);
  s_axis_tcs        <= s_axis_tdata(G_CHIP_SEL_WIDTH+G_MAX_DWIDTH-1 downto G_MAX_DWIDTH);
  s_axis_tdata_data <= s_axis_tdata(G_MAX_DWIDTH-1 downto 0);

  s_axis_tready   <= din_ready_int;
  m_axis_tvalid  <= dout_valid_int;

  p_din_cross : process (s_axis_aclk)
  begin
    if rising_edge(s_axis_aclk) then
      if s_axis_aresetn = '0' then
        spi_data_in_cross_1 <= '0';
        spi_data_in_cross_0 <= '0';
      else
        spi_data_in_cross_0 <= spi_data_in;
        spi_data_in_cross_1 <= spi_data_in_cross_0;
      end if;
    end if;
  end process;

  data_count_pol <=
    data_count when data_phase = '0' else
    0 when data_count_pha = 0 else
    data_count_pha - 1;

  p_state_machine : process (s_axis_aclk)
  begin
    if rising_edge(s_axis_aclk) then
      if s_axis_aresetn = '0' then
        spi_state       <= SM_IDLE;
        data_count      <= 0;
        data_count_pha  <= 0;
        --data_count_pol  <= 0;
        chip_select     <= (others => '1');
        dout_user       <= (others => '0');
        spi_clk         <= clk_polarity;
        spi_data_out    <= '0';
        din_ready_int   <= '0';
        dout_valid_int  <= '0';
        spi_counter     <= 0;
        din_last_hold   <= '0';
        din_reg         <= (others => '0');
        len_reg         <= (others => '0');
        rx_reg          <= (others => '0');
        m_axis_tdata            <= (others => '0');
      else
        case spi_state is
          when SM_IDLE =>
            if dout_valid_int = '1' and m_axis_tready = '1' then
              dout_valid_int <= '0';
            end if;

            if din_ready_int = '1' and s_axis_tvalid = '1' then
              din_ready_int     <= '0';
              msb_first_store   <= msb_first;
              din_reg           <= s_axis_tdata_data;
              len_reg           <= transmission_len;
              spi_divider_store <= unsigned(spi_divider);
              chip_select       <= not s_axis_tcs;
              dout_user         <= s_axis_tuser;

              if unsigned(cs_front_delay) = 0 then
                spi_state   <= SM_TX_RX;
              else
                spi_state               <= SM_DELAY_CS_FRONT;
                cs_front_delay_store    <= unsigned(cs_front_delay);
                cs_front_delay_counter  <= (others => '0');
              end if;

              cs_back_delay_store   <= unsigned(cs_back_delay);
              cs_back_delay_counter <= (others => '0');

              if s_axis_tlast = '1' then
                din_last_hold <= '1';
              end if;
            else
              din_ready_int <= '1';
              chip_select   <= (others => '1');
            end if;

          when SM_DELAY_CS_FRONT =>
            cs_front_delay_counter <= cs_front_delay_counter + 1;
            if cs_front_delay_counter = cs_front_delay_store-1 then
              spi_state   <= SM_TX_RX;
            end if;

          when SM_TX_RX =>
            if msb_first_store = '1' then
              spi_data_out <= din_reg(G_MAX_DWIDTH-data_count_pol-1);
            else
              spi_data_out <= din_reg(data_count_pol);
            end if;

            if spi_counter = unsigned(spi_divider_store) then
              data_count <= data_count + 1;
              if data_count = unsigned(len_reg) - 1 then
                if cs_back_delay_store = 0 then
                  spi_state <= SM_FINISH;
                else
                  spi_state <= SM_DELAY_CS_BACK;
                end if;
                m_axis_tdata <= rx_reg;
              end if;
              spi_counter <= 0;
              if clk_polarity = '0' then
                spi_clk <= '0';
              else
                spi_clk <= '1';
              end if;
            elsif spi_counter = spi_divider_half then
              data_count_pha  <= data_count_pha + 1;
              if msb_first_store = '1' then
                rx_reg(G_MAX_DWIDTH-data_count-1) <= spi_data_in_cross_1;
              else
                rx_reg(data_count) <= spi_data_in_cross_1;
              end if;
              spi_counter <= spi_counter + 1;
              if clk_polarity = '0' then
                spi_clk <= '1';
              else
                spi_clk <= '0';
              end if;
            else
              spi_counter <= spi_counter + 1;
            end if;

          when SM_DELAY_CS_BACK =>
            cs_back_delay_counter <= cs_back_delay_counter + 1;
            if cs_back_delay_counter = cs_back_delay_store-1 then
              spi_state <= SM_FINISH;
            end if;

          when SM_FINISH =>
            data_count      <= 0;
            data_count_pha  <= 0;
            spi_counter     <= 0;
            din_reg         <= (others => '0');
            chip_select     <= (others => '1');

            dout_valid_int  <= '1';
            din_ready_int   <= '1';

            spi_state       <= SM_IDLE;

          when others =>
              null;

        end case;
      end if;
    end if;
  end process;

  m_axis_tlast <= '1' when din_last_hold = '1' and dout_valid_int = '1' else '0';

end rtl;
















