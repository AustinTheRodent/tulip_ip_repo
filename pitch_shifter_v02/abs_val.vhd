library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity abs_val is
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;

    s_axis_tdata          : in  std_logic_vector(255 downto 0); -- 8 32 bit IQ samples
    s_axis_tvalid         : in  std_logic;
    s_axis_tready         : out std_logic;

    m_axis_tdata          : out std_logic_vector(255 downto 0);
    m_axis_tvalid         : out std_logic;
    m_axis_tready         : in  std_logic
  );
end entity;

architecture rtl of abs_val is

  constant C_FIFO_ADDRWIDTH : integer := 4;
  constant C_SAMP_PER_CLK   : integer := 8;
  constant C_BATCHES        : integer := 8;
  constant C_ABS_DWIDTH     : integer := 32;

  type iq_t is record
    RE : std_logic_vector(15 downto 0);
    IM : std_logic_vector(15 downto 0);
  end record;

  type iq_energy_t is record
    RE : std_logic_vector(31 downto 0);
    IM : std_logic_vector(31 downto 0);
  end record;

  type iq_in_t is array (0 to C_SAMP_PER_CLK-1) of iq_t;
  signal iq_in : iq_in_t;


  type bin_energy_t is array (0 to C_SAMP_PER_CLK-1) of std_logic_vector(31 downto 0);
  signal bin_energy             : bin_energy_t;
  signal fifo_bin_energy        : bin_energy_t;
  type bin_abs_t is array (0 to C_BATCHES*C_SAMP_PER_CLK-1) of std_logic_vector(31 downto 0);
  signal bin_abs                : bin_abs_t;

  signal abs_din_valid          : std_logic_vector(C_BATCHES-1 downto 0);
  signal abs_din_valid_delay    : std_logic_vector(C_BATCHES-1 downto 0);
  signal abs_din_ready          : std_logic_vector(C_BATCHES*C_SAMP_PER_CLK-1 downto 0);
  signal abs_dout_valid         : std_logic_vector(C_BATCHES*C_SAMP_PER_CLK-1 downto 0);
  signal abs_dout_ready         : std_logic_vector(C_BATCHES-1 downto 0);
  signal abs_din_batch_counter  : unsigned(7 downto 0);
  signal abs_dout_batch_counter : unsigned(7 downto 0);

  signal s_axis_tready_int      : std_logic;
  signal m_axis_tvalid_int      : std_logic;

  signal fifo_din               : std_logic_vector(255 downto 0);
  signal fifo_din_valid0        : std_logic;
  signal fifo_din_valid         : std_logic;
  signal fifo_din_ready         : std_logic;
  signal fifo_used              : std_logic_vector(C_FIFO_ADDRWIDTH downto 0);
  signal fifo_dout              : std_logic_vector(255 downto 0);
  signal fifo_dout_valid        : std_logic;
  signal fifo_dout_ready        : std_logic;

begin

  gen_assign_iq_in : for i in 0 to C_SAMP_PER_CLK-1 generate
    iq_in(i).RE <= s_axis_tdata((i+1)*32-1 downto (i+1)*32-16);
    iq_in(i).IM <= s_axis_tdata((i+1)*32-16-1 downto i*32);
  end generate;

  p_calc_energy : process(clk) -- might need to break up the add stage if can't make timing
  begin
    if rising_edge(clk) then
      for i in 0 to C_SAMP_PER_CLK-1 loop
        bin_energy(i) <= std_logic_vector( signed(iq_in(i).RE)*signed(iq_in(i).RE) + signed(iq_in(i).IM)*signed(iq_in(i).IM) );
      end loop;
    end if;
  end process;

  gen_bin_energy_flat : for i in 0 to C_SAMP_PER_CLK-1 generate
    fifo_din((i+1)*32-1 downto i*32) <= bin_energy(i);
    fifo_bin_energy(i) <= fifo_dout((i+1)*32-1 downto i*32);
  end generate;

  fifo_din_valid0 <= s_axis_tvalid when unsigned(fifo_used) <= (2**C_FIFO_ADDRWIDTH)-4 else '0';
  s_axis_tready   <= '1' when unsigned(fifo_used) <= (2**C_FIFO_ADDRWIDTH)-4 else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      fifo_din_valid <= fifo_din_valid0;
    end if;
  end process;

  u_fifo : entity work.axis_sync_fifo
  generic map
  (
    G_ADDR_WIDTH    => C_FIFO_ADDRWIDTH,
    G_DATA_WIDTH    => 256
    --G_BUFFER_INPUT  : boolean := false;
    --G_BUFFER_OUTPUT : boolean := false
  )
  port map
  (
    clk             => clk,
    reset           => reset,
    enable          => '1',

    din             => fifo_din,
    din_valid       => fifo_din_valid,
    din_ready       => fifo_din_ready,
    din_last        => '0',

    used            => fifo_used,

    dout            => fifo_dout,
    dout_valid      => fifo_dout_valid,
    dout_ready      => fifo_dout_ready,
    dout_last       => open
  );








  fifo_dout_ready <= abs_din_ready(to_integer(abs_din_batch_counter*C_BATCHES));
--  s_axis_tready     <= s_axis_tready_int;

  gen_abs_din_valid : for i in 0 to C_BATCHES-1 generate
    abs_din_valid(i) <= fifo_dout_valid and fifo_dout_ready when abs_din_batch_counter = i else '0';
  end generate;

--  process(clk) -- I can only do this because I know s_axis_tready_int won't deassert until it gets a good transaction
--  begin
--    if rising_edge(clk) then
--      abs_din_valid_delay <= abs_din_valid;
--    end if;
--  end process;

  p_abs_counter : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        abs_din_batch_counter <= (others => '0');
        abs_dout_batch_counter <= (others => '0');
      else
        if fifo_dout_valid = '1' and fifo_dout_ready = '1' then
          if abs_din_batch_counter = C_BATCHES-1 then
            abs_din_batch_counter <= (others => '0');
          else
            abs_din_batch_counter <= abs_din_batch_counter + 1;
          end if;
        end if;

        if m_axis_tvalid_int = '1' and m_axis_tready = '1' then
          if abs_dout_batch_counter = C_BATCHES-1 then
            abs_dout_batch_counter <= (others => '0');
          else
            abs_dout_batch_counter <= abs_dout_batch_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;





  gen_batch : for i in 0 to C_BATCHES-1 generate
    gen_spc : for j in 0 to C_SAMP_PER_CLK-1 generate

      --bin_abs((i*C_BATCHES+j)) <= bin_energy(j);
      --abs_dout_valid(i*C_BATCHES+j) <= abs_din_valid_delay(i);
      --abs_din_ready(i*C_BATCHES+j) <= m_axis_tready;


      u_sqrt : entity work.faster_sqrt
      generic map
      (
        G_DINWIDTH      => 32,
        G_DOUT_SIGFIGS  => 30
      )
      port map
      (
        clk           => clk,
        reset         => reset,

        s_axis_tdata  => fifo_bin_energy(j),
        s_axis_tvalid => abs_din_valid(i),
        s_axis_tready => abs_din_ready(i*C_BATCHES+j),

        m_axis_tdata  => bin_abs((i*C_BATCHES+j)),
        m_axis_tvalid => abs_dout_valid(i*C_BATCHES+j),
        m_axis_tready => abs_dout_ready(i)
      );

    end generate;
  end generate;

  gen_abs_dout_ready : for i in 0 to C_BATCHES-1 generate
    abs_dout_ready(i) <= m_axis_tready when abs_dout_batch_counter = i else '0';
  end generate;

  m_axis_tvalid_int <= '1' when unsigned(abs_dout_valid) > 0 else '0';
  m_axis_tvalid     <= m_axis_tvalid_int;

  gen_output : for i in 0 to C_SAMP_PER_CLK-1 generate
    m_axis_tdata((i+1)*C_ABS_DWIDTH-1 downto i*C_ABS_DWIDTH) <= bin_abs(i+to_integer(abs_dout_batch_counter)*C_SAMP_PER_CLK);
  end generate;


end rtl;
