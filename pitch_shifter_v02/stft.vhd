library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stft is
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;

    prog_window_din       : in  std_logic_vector(15 downto 0);
    prog_window_din_valid : in  std_logic;
    prog_window_din_ready : out std_logic;
    prog_window_din_done  : out std_logic;

    s_axis_tdata          : in  std_logic_vector(15 downto 0);
    s_axis_tvalid         : in  std_logic;
    s_axis_tready         : out std_logic;

    m_axis_tdata          : out std_logic_vector(255 downto 0);
    m_axis_tvalid         : out std_logic;
    m_axis_tready         : in  std_logic
  );
end entity;

architecture rtl of stft is

  constant C_FFT_SZ           : integer := 128;
  --constant C_FFT_SZ           : integer := 4096;
  constant C_FFT_SAMP_PER_CLK : integer := 8;
  constant C_DIN_CALC_CYCLES  : integer := C_FFT_SZ/C_FFT_SAMP_PER_CLK;

  function clog2 (x : positive) return natural is
    variable i : natural;
  begin
    i := 0;
    while (2**i < x) and i < 31 loop
      i := i + 1;
    end loop;
    return i;
  end function;

  constant C_FIFO_ADDRWIDTH : integer := clog2(C_DIN_CALC_CYCLES) + 1;

  signal dft_din_valid0   : std_logic;
  signal dft_din_valid0_delay : std_logic;
  signal dft_dout_valid0  : std_logic;
  signal dft_dout_valid   : std_logic;

  type iq_t is record
    RE : std_logic_vector(15 downto 0);
    IM : std_logic_vector(15 downto 0);
  end record;

  type dft_data_array_t is array (0 to C_FFT_SAMP_PER_CLK-1) of iq_t;
  signal dft_din_data   : dft_data_array_t;
  signal dft_dout_data  : dft_data_array_t;

  type dft_din_win_t is array (0 to C_FFT_SAMP_PER_CLK-1) of signed(15 downto 0);
  signal dft_din_win    : dft_din_win_t;

  type dft_din_mult_t is array (0 to C_FFT_SAMP_PER_CLK-1) of std_logic_vector(31 downto 0);
  signal dft_din_mult   : dft_din_mult_t;

  type dft_sr_array_t is array (0 to C_FFT_SZ-1) of std_logic_vector(15 downto 0);
  signal din_sr   : dft_sr_array_t;
  type dft_dout_sr_array_t is array (0 to C_FFT_SZ-1) of iq_t;
  signal dout_sr  : dft_dout_sr_array_t;

  type state_t is
  (
    SM_INIT,
    SM_PROG_WINDOW,
    SM_GET_INPUT,
    SM_FEED_CORE_INPUT,
    SM_WAIT_FOR_OUTPUT,
    SM_SEND_OUTPUT,
    SM_COLLECT_OUTPUT,
    SM_DELAY
  );
  signal state : state_t;

  signal s_axis_tready_int : std_logic;

  signal calc_din_counter   : unsigned(15 downto 0);
  signal calc_dout_counter  : unsigned(15 downto 0);

  signal delay_counter : unsigned(15 downto 0);

  signal win_prog_counter : unsigned(15 downto 0);
  signal win_prog_counter2 : unsigned(15 downto 0);

  type win_reg_t is array (0 to C_FFT_SZ-1) of signed(15 downto 0);
  signal win_reg : win_reg_t;

  signal prog_window_din_ready_int : std_logic;

  signal fifo_used        : std_logic_vector(C_FIFO_ADDRWIDTH downto 0);
  signal fifo_din         : std_logic_vector(C_FFT_SAMP_PER_CLK*32-1 downto 0);
  signal fifo_din_valid   : std_logic;
  signal fifo_din_ready   : std_logic;
  signal fifo_dout        : std_logic_vector(C_FFT_SAMP_PER_CLK*32-1 downto 0);
  signal fifo_dout_valid  : std_logic;
  signal fifo_dout_ready  : std_logic;


begin

  prog_window_din_ready <= prog_window_din_ready_int;
  s_axis_tready <= s_axis_tready_int;

  gen_dft_din_win : for i in 0 to C_FFT_SAMP_PER_CLK-1 generate
    dft_din_win(i) <= win_reg(to_integer(calc_din_counter)*C_FFT_SAMP_PER_CLK + i);
  end generate;

  p_dft_din_mult : process(clk)
  begin
    if rising_edge(clk) then

      dft_din_valid0_delay <= dft_din_valid0;

      for i in 0 to C_FFT_SAMP_PER_CLK-1 loop
        dft_din_mult(i) <= std_logic_vector(signed(dft_din_win(i)) * signed(dft_din_data(i).RE));
      end loop;

    end if;
  end process;

  p_wr_win_reg : process(clk)
  begin
    if rising_edge(clk) then
      if prog_window_din_valid = '1' and prog_window_din_ready_int = '1' then
        win_reg(to_integer(win_prog_counter)) <= signed(prog_window_din);
      end if;
    end if;
  end process;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state <= SM_INIT;
        s_axis_tready_int <= '0';
        dft_din_valid0 <= '0';
        --m_axis_tvalid <= '0';
        dft_dout_valid <= '0';
        win_prog_counter  <= (others => '0');
        win_prog_counter2 <= (others => '0');
        prog_window_din_ready_int <= '0';
        prog_window_din_done <= '0';
      else

        case state is
          when SM_INIT =>
            state <= SM_PROG_WINDOW;
            prog_window_din_ready_int <= '1';

          when SM_PROG_WINDOW =>
            if prog_window_din_valid = '1' then

              if win_prog_counter2 = C_FFT_SAMP_PER_CLK-1 then
                win_prog_counter2 <= (others => '0');
              else
                win_prog_counter2 <= win_prog_counter2 + 1;
              end if;

              if win_prog_counter = C_FFT_SZ-1 then
                state <= SM_GET_INPUT;
                prog_window_din_ready_int <= '0';
                prog_window_din_done <= '1';
                s_axis_tready_int <= '1';
              else
                win_prog_counter <= win_prog_counter + 1;
              end if;
            end if;


          when SM_GET_INPUT =>
            if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
              state <= SM_FEED_CORE_INPUT;
              s_axis_tready_int <= '0';
              dft_din_valid0     <= '1';
              calc_din_counter  <= (others => '0');
            end if;

          when SM_FEED_CORE_INPUT =>
            if dft_din_valid0 = '0' then
              if calc_din_counter = C_DIN_CALC_CYCLES-1 then
                state  <= SM_WAIT_FOR_OUTPUT;
              else
                calc_din_counter  <= calc_din_counter + 1;
              end if;
            end if;
            dft_din_valid0 <= '0';

          when SM_WAIT_FOR_OUTPUT =>
            if dft_dout_valid0 = '1' then
              state <= SM_COLLECT_OUTPUT;
              calc_dout_counter <= (others => '0');
              dft_dout_valid <= '1';
            end if;

          when SM_COLLECT_OUTPUT =>
            if calc_dout_counter = C_DIN_CALC_CYCLES-1 then
              state  <= SM_SEND_OUTPUT;
              --m_axis_tvalid <= '1';
              dft_dout_valid <= '0';
            else
              calc_dout_counter  <= calc_dout_counter + 1;
            end if;

          when SM_SEND_OUTPUT =>
            --if m_axis_tready = '1' then
            if unsigned(fifo_used) < C_DIN_CALC_CYCLES then
              state <= SM_GET_INPUT;
              s_axis_tready_int <= '1';
              dft_din_valid0 <= '0';
              --m_axis_tvalid <= '0';
              delay_counter <= (others => '0');
            end if;

          when SM_DELAY =>
            if delay_counter = 1023 then
              state <= SM_INIT;
            else
              delay_counter <= delay_counter + 1;
            end if;

          when others =>
            state <= SM_INIT;

        end case;

      end if;
    end if;
  end process;

  gen_im_data : for i in 0 to C_FFT_SAMP_PER_CLK-1 generate
    dft_din_data(i).IM <= (others => '0');
  end generate;

  p_din_sr : process(clk)
  begin
    if rising_edge(clk) then
      --if reset = '1' then
      --  for i in 0 to C_FFT_SZ-1 loop
      --    din_sr(i) <= (others => '0');
      --  end loop;
      if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
        din_sr(0) <= s_axis_tdata;
        for i in 1 to C_FFT_SZ-1 loop
          din_sr(i) <= din_sr(i-1);
        end loop;
      end if;
    end if;
  end process;

  gen_feed_input : for i in 0 to C_FFT_SAMP_PER_CLK-1 generate
    dft_din_data(i).RE <= din_sr(i + C_FFT_SAMP_PER_CLK*to_integer(calc_din_counter));
  end generate;

  u_dft_top : entity work.dft_128_8_top
  --u_dft_top : entity work.dft_4096_8_top
    port map
      (
      clk         => clk,
      reset       => reset,
      next_top_in => dft_din_valid0_delay,
      next_out    => dft_dout_valid0,

      X0        => dft_din_mult(0)(31 downto 16),
      X1        => dft_din_data(0).IM,
      X2        => dft_din_mult(1)(31 downto 16),
      X3        => dft_din_data(1).IM,
      X4        => dft_din_mult(2)(31 downto 16),
      X5        => dft_din_data(2).IM,
      X6        => dft_din_mult(3)(31 downto 16),
      X7        => dft_din_data(3).IM,
      X8        => dft_din_mult(4)(31 downto 16),
      X9        => dft_din_data(4).IM,
      X10       => dft_din_mult(5)(31 downto 16),
      X11       => dft_din_data(5).IM,
      X12       => dft_din_mult(6)(31 downto 16),
      X13       => dft_din_data(6).IM,
      X14       => dft_din_mult(7)(31 downto 16),
      X15       => dft_din_data(7).IM,

      Y0        => dft_dout_data(0).RE,
      Y1        => dft_dout_data(0).IM,
      Y2        => dft_dout_data(1).RE,
      Y3        => dft_dout_data(1).IM,
      Y4        => dft_dout_data(2).RE,
      Y5        => dft_dout_data(2).IM,
      Y6        => dft_dout_data(3).RE,
      Y7        => dft_dout_data(3).IM,
      Y8        => dft_dout_data(4).RE,
      Y9        => dft_dout_data(4).IM,
      Y10       => dft_dout_data(5).RE,
      Y11       => dft_dout_data(5).IM,
      Y12       => dft_dout_data(6).RE,
      Y13       => dft_dout_data(6).IM,
      Y14       => dft_dout_data(7).RE,
      Y15       => dft_dout_data(7).IM
    );

  gen_fifo_din : for i in 0 to C_FFT_SAMP_PER_CLK-1 generate
    fifo_din((i+1)*32 -1 downto (i+1)*32 - 16)  <= dft_dout_data(i).RE;
    fifo_din((i+1)*32 - 16 - 1 downto i*32)     <= dft_dout_data(i).IM;
  end generate;

  fifo_din_valid  <= dft_dout_valid;

  u_fifo : entity work.axis_sync_fifo
  generic map
  (
    G_ADDR_WIDTH    => C_FIFO_ADDRWIDTH,
    G_DATA_WIDTH    => C_FFT_SAMP_PER_CLK * 32
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

  m_axis_tdata    <= fifo_dout;
  m_axis_tvalid   <= fifo_dout_valid;
  fifo_dout_ready <= m_axis_tready;

end rtl;
