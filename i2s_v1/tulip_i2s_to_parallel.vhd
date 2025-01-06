library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tulip_i2s_to_parallel is
  generic
  (
    G_NUM_POSEDGE : integer range 1 to 1023 := 3;
    G_DWIDTH      : integer range 2 to 32   := 32;
    G_LSB_FIRST   : boolean                 := false
  );
  port
  (
    clk           : in  std_logic;
    resetn        : in  std_logic;
    enable        : in  std_logic;

    error         : out std_logic;

    bclk          : in  std_logic;
    lrclk         : in  std_logic;
    serial_din    : in  std_logic;

    m_axis_tdata  : out std_logic_vector(2*G_DWIDTH-1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic

    --dout_left     : out std_logic_vector(G_DWIDTH-1 downto 0);
    --dout_right    : out std_logic_vector(G_DWIDTH-1 downto 0);
    --dout_valid    : out std_logic;
    --dout_ready    : in  std_logic
  );
end entity;

architecture rtl of tulip_i2s_to_parallel is

  signal dout_left  : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_right : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_ls_left  : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_ls_right : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_32_left  : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_32_right : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_valid : std_logic;
  signal dout_ready : std_logic;

  type state_t is (init, error_state, wait_for_low_lrclk, wait_for_high_lrclk, wait_for_low_bclk, construct_l, construct_r, output);
  signal state                : state_t;
  signal next_state           : state_t;

  signal dout_left_construct  : std_logic_vector(G_DWIDTH-1 downto 0);
  signal dout_right_construct : std_logic_vector(G_DWIDTH-1 downto 0);

  signal dout_valid_int       : std_logic;

  signal symbol_pos_count     : integer range 0 to 32;

begin

  dout_ls_left  <= std_logic_vector(shift_left(unsigned(dout_left), 1));
  dout_ls_right <= std_logic_vector(shift_left(unsigned(dout_right), 1));

  dout_32_left  <= std_logic_vector(shift_right(signed(dout_ls_left), 8));
  dout_32_right <= std_logic_vector(shift_right(signed(dout_ls_right), 8));

  m_axis_tdata  <= dout_32_left & dout_32_right;
  m_axis_tvalid <= dout_valid;
  dout_ready    <= '1';

  gen_lsb_first : if G_LSB_FIRST = true generate
    dout_left   <= dout_left_construct;
    dout_right  <= dout_right_construct;
  end generate;

  gen_msb_first : if G_LSB_FIRST = false generate
    g_flip_bits : for i in 0 to G_DWIDTH-1 generate
      dout_left(G_DWIDTH-1-i)   <= dout_left_construct(i);
      dout_right(G_DWIDTH-1-i)  <= dout_right_construct(i);
    end generate;
  end generate;

  dout_valid <= dout_valid_int;

  process(clk)
    variable v_posedge_count : integer range 0 to 1023;
  begin
    if rising_edge(clk) then
      if resetn = '0' or enable = '0' then
        dout_valid_int        <= '0';
        error                 <= '0';
        dout_left_construct   <= (others => '0');
        dout_right_construct  <= (others => '0');
        next_state            <= init;
        state                 <= init;
        symbol_pos_count      <= 0;
        v_posedge_count       := 0;
      else

        case state is
          when init =>
            dout_valid_int        <= '0';
            dout_left_construct   <= (others => '0');
            dout_right_construct  <= (others => '0');
            state                 <= wait_for_low_lrclk;
            symbol_pos_count      <= 0;

          when wait_for_low_lrclk =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              state           <= wait_for_high_lrclk;
              v_posedge_count := 0;
            else
              if lrclk = '0' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when wait_for_high_lrclk =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              state            <= wait_for_low_bclk;
              next_state       <= construct_l;
              v_posedge_count  := 0;
            else
              if lrclk = '1' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when construct_l =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              dout_left_construct(symbol_pos_count) <= serial_din;
              if symbol_pos_count < G_DWIDTH-1 then
                state               <= wait_for_low_bclk;
                next_state          <= construct_l;
                symbol_pos_count    <= symbol_pos_count + 1;
              else
                if lrclk = '0' then
                  error <= '1';
                  state <= error_state;
                else
                  state       <= wait_for_low_bclk;
                  next_state  <= construct_r;
                end if;
                symbol_pos_count <= 0;
              end if;
              v_posedge_count := 0;
            else
              if bclk = '1' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when construct_r =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              dout_right_construct(symbol_pos_count) <= serial_din;
              if symbol_pos_count < G_DWIDTH-1 then
                state               <= wait_for_low_bclk;
                next_state          <= construct_r;
                symbol_pos_count    <= symbol_pos_count + 1;
              else
                if lrclk = '1' then
                  error <= '1';
                  state <= error_state;
                else
                  state <= output;
                end if;
                symbol_pos_count <= 0;
              end if;
              v_posedge_count := 0;
            else
              if bclk = '1' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when wait_for_low_bclk =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              state           <= next_state;
              v_posedge_count := 0;
            else
              if bclk = '0' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when output =>
            if dout_valid_int = '0' then
              dout_valid_int  <= '1';
            elsif dout_valid_int = '1' and dout_ready = '1' then
              dout_valid_int  <= '0';
              state           <= wait_for_low_bclk;
              next_state      <= construct_l;
            end if;

          when error_state =>
            null;

          when others =>
            state <= init;

        end case;
      end if;
    end if;
  end process;

end rtl;
