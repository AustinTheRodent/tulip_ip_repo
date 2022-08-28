library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity parallel_to_i2s is
  generic
  (
    G_NUM_POSEDGE : integer range 1 to 1023 := 3;
    G_DWIDTH      : integer range 2 to 32;
    G_LSB_FIRST   : boolean := false
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;
    enable        : in  std_logic;

    error         : out std_logic;

    din_left      : in  std_logic_vector(G_DWIDTH-1 downto 0);
    din_right     : in  std_logic_vector(G_DWIDTH-1 downto 0);
    din_valid     : in  std_logic;
    din_ready     : out std_logic;

    bclk          : in  std_logic;
    lrclk         : in  std_logic;
    serial_dout   : out std_logic
  );
end entity;

architecture rtl of parallel_to_i2s is

  type state_t is (init, error_state, wait_for_low_lrclk, wait_for_high_lrclk, wait_for_low_bclk, output_l, output_r, get_next);
  signal state            : state_t;
  signal next_state       : state_t;

  signal din_left_store   : std_logic_vector(G_DWIDTH-1 downto 0);
  signal din_right_store : std_logic_vector(G_DWIDTH-1 downto 0);

  signal din_ready_int    : std_logic;

  signal symbol_pos_count : integer range 0 to 32;

begin

  --gen_lsb_first : if G_LSB_FIRST = true generate
  --  dout_left   <= dout_left_construct;
  --  dout_right  <= dout_right_construct;
  --end generate;
  --
  --gen_msb_first : if G_LSB_FIRST = false generate
  --  g_flip_bits : for i in 0 to G_DWIDTH-1 generate
  --    dout_left(G_DWIDTH-1-i)   <= dout_left_construct(i);
  --    dout_right(G_DWIDTH-1-i)  <= dout_right_construct(i);
  --  end generate;
  --end generate;

  din_ready <= din_ready_int;

  process(clk)
    variable v_posedge_count : integer range 0 to 1023;
  begin
    if rising_edge(clk) then
      if reset = '1' or enable = '0' then
        din_left_store    <= (others => '0');
        din_right_store   <= (others => '0');
        din_ready_int     <= '0';
        serial_dout       <= '0';
        error             <= '0';
        next_state        <= init;
        state             <= init;
        symbol_pos_count  <= 0;
        v_posedge_count   := 0;
      else

        case state is
          when init =>
            serial_dout         <= '0';
            if din_ready_int = '0' then
              din_ready_int     <= '1';
            elsif din_ready_int = '1' and din_valid = '1' then
              din_left_store    <= din_left;
              din_right_store   <= din_right;
              din_ready_int     <= '0';
              state             <= wait_for_low_lrclk;
              symbol_pos_count  <= 0;
            end if;

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
              serial_dout     <= din_left_store(symbol_pos_count);
              state           <= output_l;
              v_posedge_count := 0;
            else
              if lrclk = '1' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when output_l =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              if symbol_pos_count < G_DWIDTH-1 then
                state               <= wait_for_low_bclk;
                next_state          <= output_l;
                symbol_pos_count    <= symbol_pos_count + 1;
              else
                if lrclk = '0' then
                  error <= '1';
                  state <= error_state;
                else
                  state       <= wait_for_low_bclk;
                  next_state  <= output_r;
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

          when output_r =>
            if v_posedge_count >= G_NUM_POSEDGE-1 then
              if symbol_pos_count < G_DWIDTH-1 then
                state               <= wait_for_low_bclk;
                next_state          <= output_r;
                symbol_pos_count    <= symbol_pos_count + 1;
              else
                if lrclk = '1' then
                  error <= '1';
                  state <= error_state;
                else
                  state <= get_next;
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
              if next_state = output_l then
                serial_dout   <= din_left_store(symbol_pos_count);
              else
                serial_dout   <= din_right_store(symbol_pos_count);
              end if;
              state           <= next_state;
              v_posedge_count := 0;
            else
              if bclk = '0' then
                v_posedge_count := v_posedge_count + 1;
              else
                v_posedge_count := 0;
              end if;
            end if;

          when get_next =>
            if din_ready_int = '0' then
              din_ready_int   <= '1';
            elsif din_ready_int = '1' and din_valid = '1' then
              din_ready_int   <= '0';
              din_left_store  <= din_left;
              din_right_store <= din_right;
              state           <= wait_for_low_bclk;
              next_state      <= output_l;
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
