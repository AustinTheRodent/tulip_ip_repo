library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_floating_point is
  generic
  (
    G_DEGREE    : integer range 3 to 8    := 8
  );
  port
  (
    clk         : in  std_logic;
    reset       : in  std_logic;
    enable      : in  std_logic;
    bypass      : in  std_logic;

    b_tap_val   : in  std_logic_vector(31 downto 0);
    b_tap_wr    : in  std_logic;
    b_tap_done  : out std_logic;

    a_tap_val   : in  std_logic_vector(31 downto 0);
    a_tap_wr    : in  std_logic;
    a_tap_done  : out std_logic;

    din         : in  std_logic_vector(31 downto 0);
    din_valid   : in  std_logic;
    din_ready   : out std_logic;
    din_last    : in  std_logic;

    dout        : out std_logic_vector(31 downto 0);
    dout_valid  : out std_logic;
    dout_ready  : in  std_logic;
    dout_last   : out std_logic
  );
end entity;

architecture rtl of iir_floating_point is

  component floating_point_mult is
    port
    (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;

      din1        : in  std_logic_vector(31 downto 0);
      din2        : in  std_logic_vector(31 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;

      dout        : out std_logic_vector(31 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
    );
  end component;

  component floating_point_add is
    port
    (
      clk         : in  std_logic;
      reset       : in  std_logic;
      enable      : in  std_logic;

      din1        : in  std_logic_vector(31 downto 0);
      din2        : in  std_logic_vector(31 downto 0);
      din_valid   : in  std_logic;
      din_ready   : out std_logic;
      din_last    : in  std_logic;

      dout        : out std_logic_vector(31 downto 0);
      dout_valid  : out std_logic;
      dout_ready  : in  std_logic;
      dout_last   : out std_logic
    );
  end component;

  signal din_accepted   : std_logic;
  signal dout_accepted  : std_logic;

  signal dout_int       : std_logic_vector(31 downto 0);
  signal dout_int_buff  : std_logic_vector(31 downto 0);
  signal dout_valid_int : std_logic;
  signal dout_last_int  : std_logic;
  signal din_ready_int  : std_logic;
  signal din_last_store : std_logic;
  signal b_tap_done_int : std_logic;
  signal a_tap_done_int : std_logic;

  type taps_reg_t is array(0 to G_DEGREE-1) of std_logic_vector(31 downto 0);
  signal taps_reg_b : taps_reg_t;
  signal taps_reg_a : taps_reg_t;

  type mul_wire_t is array(0 to G_DEGREE-1) of std_logic_vector(31 downto 0);
  signal mul_wire_b : mul_wire_t;
  signal mul_wire_a : mul_wire_t;

  type add_wire_t is array(0 to G_DEGREE-2) of std_logic_vector(31 downto 0);
  signal add_wire : add_wire_t;

  --signal zeros : std_logic_vector(31 downto 0);

  type delay_reg_t is array(0 to G_DEGREE-2) of std_logic_vector(31 downto 0);
  signal delay_reg : delay_reg_t;

  type state_t is (program_taps, calc_b_mult, calc_a_mult, add, shift_delay, delay);
  signal main_state : state_t;

  type get_fp_mult_state_t is (init, store_b_taps, store_a_taps);
  signal get_fp_mult_state        : get_fp_mult_state_t;
  type fp_mult_data_t is array(0 to G_DEGREE-1) of std_logic_vector(31 downto 0);
  signal fp_mult_din1             : fp_mult_data_t;
  signal fp_mult_din2             : fp_mult_data_t;
  signal fp_mult_din_valid        : std_logic;
  signal fp_mult_din_ready        : std_logic_vector(0 to G_DEGREE-1);
  signal fp_mult_din_last         : std_logic;
  signal fp_mult_dout             : fp_mult_data_t;
  signal fp_mult_dout_valid       : std_logic_vector(0 to G_DEGREE-1);
  signal fp_mult_dout_ready       : std_logic;
  signal fp_mult_dout_last        : std_logic_vector(0 to G_DEGREE-1);

  type fp_add_data_t is array(0 to G_DEGREE-2) of std_logic_vector(31 downto 0);
  signal fp_add_din1              : fp_add_data_t;
  signal fp_add_din2              : fp_add_data_t;
  signal fp_add_din_valid         : std_logic;
  signal fp_add_din_ready         : std_logic_vector(0 to G_DEGREE-2);
  signal fp_add_din_last          : std_logic;
  signal fp_add_dout              : fp_add_data_t;
  signal fp_add_dout_valid        : std_logic_vector(0 to G_DEGREE-2);
  signal fp_add_dout_ready        : std_logic;
  signal fp_add_dout_last         : std_logic_vector(0 to G_DEGREE-2);

  signal fp_add2_din1             : fp_add_data_t;
  signal fp_add2_din2             : fp_add_data_t;
  signal fp_add2_din_valid        : std_logic;
  signal fp_add2_din_ready        : std_logic_vector(0 to G_DEGREE-2);
  signal fp_add2_din_last         : std_logic;
  signal fp_add2_dout             : fp_add_data_t;
  signal fp_add2_dout_valid       : std_logic_vector(0 to G_DEGREE-2);
  signal fp_add2_dout_ready       : std_logic;
  signal fp_add2_dout_last        : std_logic_vector(0 to G_DEGREE-2);

  signal fp_final_add_din1        : std_logic_vector(31 downto 0);
  signal fp_final_add_din2        : std_logic_vector(31 downto 0);
  signal fp_final_add_din_valid   : std_logic;
  signal fp_final_add_din_ready   : std_logic;
  signal fp_final_add_din_last    : std_logic;
  signal fp_final_add_dout        : std_logic_vector(31 downto 0);
  signal fp_final_add_dout_valid  : std_logic;
  signal fp_final_add_dout_ready  : std_logic;
  signal fp_final_add_dout_last   : std_logic;

begin

  din_accepted  <= din_valid and din_ready_int;
  dout_accepted <= dout_valid_int and dout_ready;

  g_floating_pt_mult : for i in 0 to G_DEGREE-1 generate
    u_floating_point_mult : floating_point_mult
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din1        => fp_mult_din1(i),
        din2        => fp_mult_din2(i),
        din_valid   => fp_mult_din_valid,
        din_ready   => fp_mult_din_ready(i),
        din_last    => fp_mult_din_last,

        dout        => fp_mult_dout(i),
        dout_valid  => fp_mult_dout_valid(i),
        dout_ready  => fp_mult_dout_ready,
        dout_last   => fp_mult_dout_last(i)
      );

    fp_mult_din1(i) <=
      taps_reg_b(i) when main_state = calc_b_mult else
      (others => '0') when unsigned(taps_reg_a(i)) = 0 else
      (not (taps_reg_a(i)(31))) & taps_reg_a(i)(30 downto 0);

    fp_mult_din2(i) <=
      din when main_state = calc_b_mult else
      dout_int;

  end generate;

  fp_mult_din_valid <=
    '1' when main_state = calc_b_mult and din_accepted = '1' else
    '1' when main_state = calc_a_mult else
    '0';

  fp_mult_dout_ready <= '1';

  p_fetch_fp_mult_sm : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-1 loop
          mul_wire_b(i) <= (others => '0');
        end loop;

        for i in 1 to G_DEGREE-1 loop
          mul_wire_a(i) <= (others => '0');
        end loop;

        get_fp_mult_state <= init;
      else
        case get_fp_mult_state is
          when init =>
            for i in 0 to G_DEGREE-1 loop
              mul_wire_b(i) <= (others => '0');
            end loop;

            for i in 1 to G_DEGREE-1 loop
              mul_wire_a(i) <= (others => '0');
            end loop;

            get_fp_mult_state <= store_b_taps;

          when store_b_taps =>
            if fp_mult_dout_valid(0) = '1' and fp_mult_dout_ready = '1' then
              for i in 0 to G_DEGREE-1 loop
                mul_wire_b(i) <= fp_mult_dout(i);
              end loop;

              get_fp_mult_state <= store_a_taps;
            end if;

          when store_a_taps =>
            if fp_mult_dout_valid(0) = '1' and fp_mult_dout_ready = '1' then
              for i in 1 to G_DEGREE-1 loop
                mul_wire_a(i) <= fp_mult_dout(i);
              end loop;

              get_fp_mult_state <= store_b_taps;
            end if;

          when others =>
            get_fp_mult_state <= init;

        end case;
      end if;
    end if;
  end process;

  u_floating_point_add_single : floating_point_add
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,

      din1        => fp_add_din1(G_DEGREE-2),
      din2        => fp_add_din2(G_DEGREE-2),
      din_valid   => fp_add_din_valid,
      din_ready   => fp_add_din_ready(G_DEGREE-2),
      din_last    => fp_add_din_last,

      dout        => fp_add2_dout(G_DEGREE-2),
      dout_valid  => fp_add_dout_valid(G_DEGREE-2),
      dout_ready  => fp_add_dout_ready,
      dout_last   => fp_add_dout_last(G_DEGREE-2)
    );

  fp_add_din1(G_DEGREE-2) <= mul_wire_b(G_DEGREE-1);
  fp_add_din2(G_DEGREE-2) <= mul_wire_a(G_DEGREE-1);

  g_floating_pt_add : for i in G_DEGREE-3 downto 0 generate

    fp_add_din1(i) <= mul_wire_b(i+1);
    fp_add_din2(i) <= mul_wire_a(i+1);

    u_floating_point_add : floating_point_add
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din1        => fp_add_din1(i),
        din2        => fp_add_din2(i),
        din_valid   => fp_add_din_valid,
        din_ready   => fp_add_din_ready(i),
        din_last    => fp_add_din_last,

        dout        => fp_add_dout(i),
        dout_valid  => fp_add_dout_valid(i),
        dout_ready  => fp_add_dout_ready,
        dout_last   => fp_add_dout_last(i)
      );

    u_floating_point_add2 : floating_point_add
      port map
      (
        clk         => clk,
        reset       => reset,
        enable      => enable,

        din1        => fp_add2_din1(i),
        din2        => fp_add2_din2(i),
        din_valid   => fp_add2_din_valid,
        din_ready   => fp_add2_din_ready(i),
        din_last    => fp_add2_din_last,

        dout        => fp_add2_dout(i),
        dout_valid  => fp_add2_dout_valid(i),
        dout_ready  => fp_add2_dout_ready,
        dout_last   => fp_add2_dout_last(i)
      );

  end generate;

  fp_add2_din_valid <= fp_add_dout_valid(0);
  fp_add_dout_ready <= fp_add2_din_ready(0);
  fp_add_din_valid <= '1';
  fp_add2_dout_ready <= '1';

  p_buff_fp_add : process(clk)
  begin
    if rising_edge(clk) then
      for i in G_DEGREE-2 downto 0 loop
        add_wire(i) <= fp_add2_dout(i);
      end loop;

      for i in G_DEGREE-3 downto 0 loop
        fp_add2_din1(i) <= fp_add_dout(i);
        fp_add2_din2(i) <= delay_reg(i+1);
      end loop;

    end if;
  end process;

  p_state_machine : process(clk)
    variable v_next_state     : state_t;
    variable v_delay_counter  : integer range 0 to 255;
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        din_last_store <= '0';

        for i in 0 to G_DEGREE-2 loop
          delay_reg(i) <= (others => '0');
        end loop;

        main_state      <= program_taps;
        v_delay_counter := 0;
        v_next_state    := program_taps;
      else
        case main_state is

          when program_taps =>
            if b_tap_done_int = '1' and a_tap_done_int = '1' then
              main_state <= calc_b_mult;
            end if;

          when calc_b_mult =>
            if din_accepted = '1' then

              if din_last = '1' then
                din_last_store <= '1';
              end if;

              main_state      <= delay;
              v_delay_counter := 3;
              v_next_state    := calc_a_mult;

            end if;

          when calc_a_mult =>
            main_state      <= delay;
            v_delay_counter := 2;
            v_next_state    := add;

          when add =>
            main_state      <= delay;
            v_delay_counter := 3;
            v_next_state    := shift_delay;

          when shift_delay =>
            if dout_accepted = '1' then
              for i in 0 to G_DEGREE-2 loop
                delay_reg(i) <= add_wire(i);
              end loop;

              main_state <= calc_b_mult;
            end if;

          when delay =>
            if v_delay_counter = 1 then
              main_state <= v_next_state;
            end if;
            v_delay_counter := v_delay_counter - 1;

          when others =>
        end case;
      end if;
    end if;
  end process;

  mul_wire_a(0) <= (others => '0');

  p_program_a_taps : process(clk)
    variable v_taps_counter : integer range 0 to G_DEGREE;
  begin
    if rising_edge(clK) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-1 loop
          taps_reg_a(i) <= (others => '0');
        end loop;
        a_tap_done_int <= '0';
        v_taps_counter := 1;
      else
        if a_tap_wr = '1' and a_tap_done_int = '0' then
          taps_reg_a(v_taps_counter) <= a_tap_val;
          if v_taps_counter = G_DEGREE-1 then
            a_tap_done_int <= '1';
          end if;
          v_taps_counter := v_taps_counter + 1;
        end if;
      end if;
    end if;
  end process;

  p_program_b_taps : process(clk)
    variable v_taps_counter : integer range 0 to G_DEGREE;
  begin
    if rising_edge(clK) then
      if reset = '1' or enable = '0' then
        for i in 0 to G_DEGREE-1 loop
          taps_reg_b(i) <= (others => '0');
        end loop;
        b_tap_done_int <= '0';
        v_taps_counter := 0;
      else
        if b_tap_wr = '1' and b_tap_done_int = '0' then
          taps_reg_b(v_taps_counter) <= b_tap_val;
          if v_taps_counter = G_DEGREE-1 then
            b_tap_done_int <= '1';
          end if;
          v_taps_counter := v_taps_counter + 1;
        end if;
      end if;
    end if;
  end process;

  fp_final_add_din1       <= delay_reg(0);
  fp_final_add_din2       <= mul_wire_b(0);

  fp_final_add_din_valid  <= '1';
  fp_final_add_dout_ready <= '1';

  u_final_add : floating_point_add
    port map
    (
      clk         => clk,
      reset       => reset,
      enable      => enable,

      din1        => fp_final_add_din1,
      din2        => fp_final_add_din2,
      din_valid   => fp_final_add_din_valid,
      din_ready   => fp_final_add_din_ready,
      din_last    => fp_final_add_din_last,

      dout        => fp_final_add_dout,
      dout_valid  => fp_final_add_dout_valid,
      dout_ready  => fp_final_add_dout_ready,
      dout_last   => fp_final_add_dout_last
    );

  p_dout_int_buff : process(clk)
  begin
    if rising_edge(clk) then
      dout_int_buff <= fp_final_add_dout;
    end if;
  end process;

  dout_int <=
    din when bypass = '1' else
    dout_int_buff;

  dout_valid_int <=
    din_valid when bypass = '1' else
    '1' when main_state = shift_delay else
    '0';

  dout_last_int <=
    din_last when bypass = '1' else
    din_last_store when main_state = shift_delay and dout_accepted = '1' else
    '0';

  din_ready_int <=
    dout_ready when bypass = '1' else
    '1' when main_state = calc_b_mult else
    '0';

  dout        <= dout_int;
  dout_valid  <= dout_valid_int;
  dout_last   <= dout_last_int;
  din_ready   <= din_ready_int;

  a_tap_done  <= a_tap_done_int;
  b_tap_done  <= b_tap_done_int;

end rtl;
