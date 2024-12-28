library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wawa_bram is
  generic
  (
    G_ADDR_WIDTH  : integer := 10;
    G_DATA_WIDTH  : integer := 64
    --G_WORD_WIDTH  : integer := 32
  );
  port
  (
    clk                   : in  std_logic;

    wr_data               : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    wr_address            : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    wr_valid              : in  std_logic;

    rd_data               : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    rd_address            : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0);
    rd_din_valid          : in  std_logic;
    rd_dout_valid         : out std_logic

  );
end entity;

architecture rtl of wawa_bram is

  type ram_t is array (0 to 2**G_ADDR_WIDTH-1) of std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal ram : ram_t;

begin

  p_wr : process(clk)
  begin
    if rising_edge(clk) then
      if wr_valid = '1' then
        ram(to_integer(unsigned(wr_address))) <= wr_data;
      end if;
    end if;
  end process;

  p_rd : process(clk)
  begin
    if rising_edge(clk) then
      rd_data <= ram(to_integer(unsigned(rd_address)));
      rd_dout_valid <= rd_din_valid;
    end if;
  end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wawa_iir is
  generic
  (
    G_BRAM_ADDRWIDTH      : integer range 4 to 12   := 8;
    G_NUM_B_TAPS          : integer range 2 to 255  := 16;
    G_NUM_A_TAPS          : integer range 2 to 255  := 16;
    G_TAP_INTEGER_BITS    : integer := 2;
    G_TAP_DWIDTH          : integer := 64; -- keep these large
    G_DWIDTH              : integer := 64; -- keep these large
    G_REFRESH_RATE        : integer := 4800 -- samples
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    bypass                : in  std_logic;

    s_prog_b_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_b_tap_tvalid   : in  std_logic;
    s_prog_b_tap_tready   : out std_logic;
    prog_b_done           : out std_logic;

    s_prog_a_tap_tdata    : in  std_logic_vector(G_TAP_DWIDTH-1 downto 0);
    s_prog_a_tap_tvalid   : in  std_logic;
    s_prog_a_tap_tready   : out std_logic;
    prog_a_done           : out std_logic;

    pedal_input           : in  std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);

    s_wawa_tdata          : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_wawa_tvalid         : in  std_logic;
    s_wawa_tready         : out std_logic;

    m_wawa_tdata          : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_wawa_tvalid         : out std_logic;
    m_wawa_tready         : in  std_logic
  );
end entity;

architecture rtl of wawa_iir is

  signal s_prog_b_tap_address       : unsigned(G_BRAM_ADDRWIDTH-1 downto 0); -- the address is used to create the wawa array of filters
  signal s_prog_b_tap_index         : unsigned(7 downto 0); -- the index is used to program a single IIR component
  signal s_prog_a_tap_address       : unsigned(G_BRAM_ADDRWIDTH-1 downto 0); -- the address is used to create the wawa array of filters
  signal s_prog_a_tap_index         : unsigned(7 downto 0); -- the index is used to program a single IIR component

  signal s_prog_b_tap_address_register  : std_logic_vector(s_prog_b_tap_address'range);
  signal s_prog_a_tap_address_register  : std_logic_vector(s_prog_a_tap_address'range);

  signal b_tap_bram_register        : std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal b_tap_bram_register_valid  : std_logic;
  signal a_tap_bram_register        : std_logic_vector(G_NUM_A_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal a_tap_bram_register_valid  : std_logic;

  signal rd_b_bram_data             : std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal rd_b_bram_address          : std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);
  signal rd_b_bram_din_valid        : std_logic;
  signal rd_b_bram_dout_valid       : std_logic;
  signal rd_a_bram_data             : std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal rd_a_bram_address          : std_logic_vector(G_BRAM_ADDRWIDTH-1 downto 0);
  signal rd_a_bram_din_valid        : std_logic;
  signal rd_a_bram_dout_valid       : std_logic;

  signal b_tap_index_int            : integer range 0 to 255;
  signal a_tap_index_int            : integer range 0 to 255;

  type state_t is (SM_INIT, SM_PROGRAM_BRAM, SM_REFRESH_IIR, SM_RUN_IIR, SM_WAIT_TO_PROGRAM);
  signal state                      : state_t;

  signal a_bram_done                : std_logic;
  signal b_bram_done                : std_logic;

  signal s_prog_core_b_tap_tdata         : std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal s_prog_core_b_tap_tvalid        : std_logic;
  signal s_prog_core_b_tap_tready        : std_logic;
  signal s_prog_core_b_tap_tlast         : std_logic;
  signal prog_core_b_tap_done            : std_logic;

  signal s_prog_core_a_tap_tdata         : std_logic_vector(G_NUM_A_TAPS*G_TAP_DWIDTH-1 downto 0);
  signal s_prog_core_a_tap_tvalid        : std_logic;
  signal s_prog_core_a_tap_tready        : std_logic;
  signal s_prog_core_a_tap_tlast         : std_logic;
  signal prog_core_a_tap_done            : std_logic;

  signal s_iir_tdata                : std_logic_vector(G_DWIDTH-1 downto 0);
  signal s_iir_tvalid               : std_logic;
  signal s_iir_tready               : std_logic;
  signal s_iir_tlast                : std_logic;

  signal m_iir_tdata                : std_logic_vector(G_DWIDTH-1 downto 0);
  signal m_iir_tvalid               : std_logic;
  signal m_iir_tready               : std_logic;
  signal m_iir_tlast                : std_logic;

  signal sample_counter             : unsigned(31 downto 0);

begin

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then

        s_prog_b_tap_address  <= (others => '0');
        s_prog_b_tap_index    <= (others => '0');
        s_prog_a_tap_address  <= (others => '0');
        s_prog_a_tap_index    <= (others => '0');

        b_bram_done         <= '0';
        a_bram_done         <= '0';
        prog_b_done         <= '0';
        prog_a_done         <= '0';
        rd_b_bram_din_valid <= '0';
        rd_a_bram_din_valid <= '0';
        s_prog_b_tap_tready <= '0';
        s_prog_a_tap_tready <= '0';
        state               <= SM_INIT;
      else
        case state is
          when SM_INIT =>
            a_bram_done   <= '0';
            b_bram_done   <= '0';
            prog_b_done   <= '0';
            prog_a_done   <= '0';
            s_prog_b_tap_tready  <= '1';
            s_prog_a_tap_tready  <= '1';
            state         <= SM_PROGRAM_BRAM;

          when SM_PROGRAM_BRAM =>

            if s_prog_b_tap_tvalid = '1' then
              if s_prog_b_tap_index = G_NUM_B_TAPS-1 and s_prog_b_tap_address = (2**G_BRAM_ADDRWIDTH)-1 then
                b_bram_done         <= '1';
                prog_b_done         <= '1';
                s_prog_b_tap_tready <= '0';
              else
                if s_prog_b_tap_index = G_NUM_B_TAPS-1 then
                  s_prog_b_tap_index    <= (others => '0');
                  s_prog_b_tap_address  <= s_prog_b_tap_address + 1;
                else
                  s_prog_b_tap_index    <= s_prog_b_tap_index + 1;
                end if;
              end if;
            end if;

            if s_prog_a_tap_tvalid = '1' then
              if s_prog_a_tap_index = G_NUM_B_TAPS-1 and s_prog_a_tap_address = (2**G_BRAM_ADDRWIDTH)-1 then
                a_bram_done         <= '1';
                prog_a_done         <= '1';
                s_prog_a_tap_tready <= '0';
              else
                if s_prog_a_tap_index = G_NUM_A_TAPS-1 then
                  s_prog_a_tap_index    <= (others => '0');
                  s_prog_a_tap_address  <= s_prog_a_tap_address + 1;
                else
                  s_prog_a_tap_index    <= s_prog_a_tap_index + 1;
                end if;
              end if;
            end if;

            if b_bram_done = '1' and a_bram_done = '1' then
              rd_b_bram_address   <= pedal_input;
              rd_a_bram_address   <= pedal_input;
              state               <= SM_REFRESH_IIR;
            end if;

          when SM_REFRESH_IIR =>
            if s_prog_core_b_tap_tready = '1' and s_prog_core_a_tap_tready = '1' then
              rd_b_bram_din_valid <= '1';
              rd_a_bram_din_valid <= '1';
            elsif prog_core_b_tap_done = '1' and prog_core_a_tap_done = '1' then
              rd_b_bram_din_valid <= '0';
              rd_a_bram_din_valid <= '0';
              sample_counter      <= (others => '0');
              state               <= SM_RUN_IIR;
            end if;

          when SM_RUN_IIR =>
            if s_iir_tvalid = '1' and s_iir_tready = '1' then
              if sample_counter = G_REFRESH_RATE-1 then
                state           <= SM_WAIT_TO_PROGRAM;
              else
                sample_counter  <= sample_counter + 1;
              end if;
            end if;

          when SM_WAIT_TO_PROGRAM =>
            if prog_core_b_tap_done = '0' and prog_core_a_tap_done = '0' then
              rd_b_bram_address   <= pedal_input;
              rd_a_bram_address   <= pedal_input;
              state <= SM_REFRESH_IIR;
            end if;

          when others =>
            state <= SM_INIT;

        end case;
      end if;
    end if;
  end process;

  b_tap_index_int <= to_integer(unsigned(s_prog_b_tap_index));
  a_tap_index_int <= to_integer(unsigned(s_prog_a_tap_index));

  p_b_tap_register : process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(s_prog_b_tap_index) < G_NUM_B_TAPS and s_prog_b_tap_tvalid = '1' then
        b_tap_bram_register(G_TAP_DWIDTH*(b_tap_index_int+1)-1 downto G_TAP_DWIDTH*b_tap_index_int) <= s_prog_b_tap_tdata;
      end if;
      s_prog_b_tap_address_register <= std_logic_vector(s_prog_b_tap_address);
      b_tap_bram_register_valid <= s_prog_b_tap_tvalid;
    end if;
  end process;

  p_a_tap_register : process(clk)
  begin
    if rising_edge(clk) then
      if unsigned(s_prog_a_tap_index) < G_NUM_A_TAPS and s_prog_a_tap_tvalid = '1' then
        a_tap_bram_register(G_TAP_DWIDTH*(a_tap_index_int+1)-1 downto G_TAP_DWIDTH*a_tap_index_int) <= s_prog_a_tap_tdata;
      end if;
      s_prog_a_tap_address_register <= std_logic_vector(s_prog_a_tap_address);
      a_tap_bram_register_valid <= s_prog_a_tap_tvalid;
    end if;
  end process;

  u_b_tap_bram : entity work.wawa_bram
  generic map
  (
    G_ADDR_WIDTH  => G_BRAM_ADDRWIDTH,
    G_DATA_WIDTH  => G_NUM_B_TAPS*G_TAP_DWIDTH
  )
  port map
  (
    clk           => clk,

    wr_data       => b_tap_bram_register,
    wr_address    => s_prog_b_tap_address_register,
    wr_valid      => b_tap_bram_register_valid,

    rd_data       => rd_b_bram_data,
    rd_address    => rd_b_bram_address,
    rd_din_valid  => rd_b_bram_din_valid,
    rd_dout_valid => rd_b_bram_dout_valid
  );

  u_a_tap_bram : entity work.wawa_bram
  generic map
  (
    G_ADDR_WIDTH  => G_BRAM_ADDRWIDTH,
    G_DATA_WIDTH  => G_NUM_A_TAPS*G_TAP_DWIDTH
  )
  port map
  (
    clk           => clk,

    wr_data       => a_tap_bram_register,
    wr_address    => s_prog_a_tap_address_register,
    wr_valid      => a_tap_bram_register_valid,

    rd_data       => rd_a_bram_data,
    rd_address    => rd_a_bram_address,
    rd_din_valid  => rd_a_bram_din_valid,
    rd_dout_valid => rd_a_bram_dout_valid
  );

  s_prog_core_b_tap_tdata  <= rd_b_bram_data;
  s_prog_core_b_tap_tvalid <= rd_b_bram_dout_valid;

  s_prog_core_a_tap_tdata  <= rd_a_bram_data;
  s_prog_core_a_tap_tvalid <= rd_a_bram_dout_valid;

  s_iir_tdata   <= s_wawa_tdata;
  s_iir_tvalid  <= s_wawa_tvalid when state = SM_RUN_IIR else '0';
  s_wawa_tready <= m_wawa_tready when bypass = '1' else s_iir_tready when state = SM_RUN_IIR else '0';
  s_iir_tlast   <= s_iir_tvalid when sample_counter = G_REFRESH_RATE-1 else '0';

  m_wawa_tdata  <= s_wawa_tdata when bypass = '1' else m_iir_tdata;
  m_wawa_tvalid <= s_wawa_tvalid when bypass = '1' else m_iir_tvalid;
  m_iir_tready  <= m_wawa_tready;

  u_reprogrammable_iir_filt : entity work.reprogrammable_iir_filt
  generic map
  (
    G_PACK_TAPS_MSB_FIRST => false,
    G_NUM_B_TAPS          => G_NUM_B_TAPS,
    G_NUM_A_TAPS          => G_NUM_A_TAPS,
    G_TAP_INTEGER_BITS    => G_TAP_INTEGER_BITS,
    G_TAP_DWIDTH          => G_TAP_DWIDTH,
    G_DWIDTH              => G_DWIDTH
  )
  port map
  (
    clk                   => clk,
    reset                 => reset,
    bypass                => '0',

    s_prog_b_tap_tdata    => s_prog_core_b_tap_tdata,
    s_prog_b_tap_tvalid   => s_prog_core_b_tap_tvalid,
    s_prog_b_tap_tready   => s_prog_core_b_tap_tready,
    prog_b_tap_done       => prog_core_b_tap_done,

    s_prog_a_tap_tdata    => s_prog_core_a_tap_tdata,
    s_prog_a_tap_tvalid   => s_prog_core_a_tap_tvalid,
    s_prog_a_tap_tready   => s_prog_core_a_tap_tready,
    prog_a_tap_done       => prog_core_a_tap_done,

    s_iir_tdata           => s_iir_tdata,
    s_iir_tvalid          => s_iir_tvalid,
    s_iir_tready          => s_iir_tready,
    s_iir_tlast           => s_iir_tlast,

    m_iir_tdata           => m_iir_tdata,
    m_iir_tvalid          => m_iir_tvalid,
    m_iir_tready          => m_iir_tready,
    m_iir_tlast           => m_iir_tlast
  );


end rtl;
