
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tiny_fir is
    generic
    (
        G_DWIDTH : integer := 16; -- [bits]
        G_TAP_RES : integer := 16; -- [bits]
        G_NUM_TAPS : integer := 15
    );
    port
    (
        clk : in std_logic;
        reset : in std_logic;
        enable : in std_logic;
        bypass : in std_logic;

        tap_wr : in std_logic;
        tap_val : in std_logic_vector(G_TAP_RES-1 downto 0);
        tap_wr_done : out std_logic;

        din : in std_logic_vector(G_DWIDTH-1 downto 0);
        din_valid : in std_logic;
        din_ready : out std_logic;
        din_last : in std_logic;

        dout : out std_logic_vector(G_DWIDTH-1 downto 0);
        dout_valid : out std_logic;
        dout_ready : in std_logic;
        dout_last : out std_logic
    );
end entity;

architecture rtl of tiny_fir is

    constant C_CENTER_TAP_NUM : integer := (G_NUM_TAPS+1)/2;
    constant C_SUM_DIVIDED_MAX : std_logic_vector(G_DWIDTH-1 downto 0) := (G_DWIDTH-1 => '0', others => '1');
    constant C_SUM_DIVIDED_MIN : std_logic_vector(G_DWIDTH-1 downto 0) := (G_DWIDTH-1 => '1', others => '0');

    signal din_int : std_logic_vector(G_DWIDTH-1 downto 0);
    signal dout_int : std_logic_vector(G_DWIDTH-1 downto 0);
    signal dout_valid_int : std_logic;
    signal dout_last_int : std_logic;
    signal din_ready_int : std_logic;

    type taps_register_t is array (0 to G_NUM_TAPS-1) of std_logic_vector(G_TAP_RES-1 downto 0);
    signal taps_register : taps_register_t;
    signal register_program_counter : integer range 0 to G_NUM_TAPS;

    type shift_register_t is array (0 to G_NUM_TAPS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
    signal shift_register : shift_register_t;
    type shift_reg_state_t is (init, wait_for_tap_wr_done, get_input, wait_for_mult_ready, done);
    signal shift_reg_state : shift_reg_state_t;
    signal shift_reg_din_valid : std_logic;
    signal shift_reg_din_ready : std_logic;
    signal shift_reg_dout_valid : std_logic;
    signal shift_reg_dout_ready : std_logic;

    type mult_register_t is array (0 to G_NUM_TAPS-1) of integer;
    signal mult_register : mult_register_t;
    type mult_add_state_t is (init, get_input, mult_add, wait_for_dout_ready, done);
    signal shift_reg_store : shift_register_t;
    signal sum_register : signed(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);
    signal mult_counter : integer range 0 to G_NUM_TAPS-1;
    signal mult_add_state : mult_add_state_t;
    signal mult_add_din_valid : std_logic;
    signal mult_add_din_ready : std_logic;
    signal mult_add_dout_valid : std_logic;
    signal mult_add_dout_ready : std_logic;

    signal tap_wr_done_int : std_logic;

    signal reg_sum_array_final : std_logic_vector(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);
    signal reg_sum_round : std_logic_vector(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);

    signal sum_divided : std_logic_vector(G_DWIDTH-1 downto 0);-- todo: magic #

    signal output_counter : integer range 0 to G_NUM_TAPS;
    signal sig_prop_counter : integer range 0 to G_NUM_TAPS;
    signal din_go : std_logic;
    signal dout_go : std_logic;
    signal din_last_empty_fir : std_logic;
    signal dout_done : std_logic;

begin

    din_int <= (others => '0') when din_last_empty_fir = '1' else din;
    din_ready <= din_ready_int;

    din_go <= din_valid and din_ready_int;
    dout_go <= dout_valid_int and dout_ready;

    p_program_registers : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                for i in 0 to G_NUM_TAPS-1 loop
                    taps_register(i) <= (others => '0');
                end loop;
                register_program_counter <= 0;
                tap_wr_done_int <= '0';
            else
                if tap_wr = '1' and tap_wr_done_int /= '1' then
                    taps_register(register_program_counter) <= tap_val;
                    register_program_counter <= register_program_counter + 1;
                    if register_program_counter = G_NUM_TAPS - 1 then
                        tap_wr_done_int <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    p_din_last : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                din_last_empty_fir <= '0';
                dout_done <= '0';
            else
                if din_last = '1' and din_go = '1' then
                    din_last_empty_fir <= '1';
                end if;
                if dout_go = '1' and dout_last_int = '1' then
                    dout_done <= '1';
                end if;
            end if;
        end if;
    end process;

    dout_last_int <= din_last when bypass = '1' else
                     '1' when din_last_empty_fir = '1' and dout_go = '1' and sig_prop_counter = 1 else
                     '0';

    din_ready_int <= dout_ready when bypass = '1' else shift_reg_din_ready;
    shift_reg_din_valid <= '1' when din_last_empty_fir = '1' and dout_done = '0' else din_valid;

    p_shift_registers : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                for i in 0 to G_NUM_TAPS-1 loop
                    shift_register(i) <= (others => '0');
                end loop;
                shift_reg_state <= init;
                shift_reg_din_ready <= '0';
                shift_reg_dout_valid <= '0';
            else
                case(shift_reg_state) is
                    when init =>
                        shift_reg_state <= wait_for_tap_wr_done;
                        shift_reg_din_ready <= '0';
                        shift_reg_dout_valid <= '0';
                    when wait_for_tap_wr_done =>
                        if tap_wr_done_int = '1' then
                            shift_reg_din_ready <= '1';
                            shift_reg_state <= get_input;
                        end if;
                    when get_input =>
                        if shift_reg_din_valid = '1' and shift_reg_din_ready = '1' then
                            shift_register(0) <= din_int;
                            for i in 1 to G_NUM_TAPS-1 loop
                                shift_register(i) <= shift_register(i-1);
                            end loop;
                            shift_reg_din_ready <= '0';
                            shift_reg_dout_valid <= '1';
                            shift_reg_state <= wait_for_mult_ready;
                        end if;
                    when wait_for_mult_ready =>
                        if shift_reg_dout_ready = '1' and shift_reg_dout_valid = '1' then
                            shift_reg_din_ready <= '1';
                            shift_reg_dout_valid <= '0';
                            shift_reg_state <= get_input;
                        end if;
                    when done =>
                        shift_reg_state <= init;
                    when others =>
                        shift_reg_state <= init;
                end case;
            end if;
        end if;
    end process;

    mult_add_din_valid <= shift_reg_dout_valid;
    shift_reg_dout_ready <= mult_add_din_ready;

    p_mult_add_registers : process(clk)
    begin
        if rising_edge(clk) then--(init, get_input, mult_add, wait_for_dout_ready, done)
            if reset = '1' or enable = '0' then
                for i in 0 to G_NUM_TAPS-1 loop
                    shift_reg_store(i) <= (others => '0');
                end loop;
                mult_counter <= 0;
                sum_register <= (others => '0');
                mult_add_din_ready <= '0';
                mult_add_dout_valid <= '0';
                mult_add_state <= init;
            else
                case(mult_add_state) is
                    when init =>
                        mult_counter <= 0;
                        mult_add_din_ready <= '1';
                        mult_add_dout_valid <= '0';
                        mult_add_state <= get_input;
                    when get_input =>
                        if mult_add_din_valid = '1' and mult_add_din_ready = '1' then
                            for i in 0 to G_NUM_TAPS-1 loop
                                shift_reg_store(i) <= shift_register(i);
                            end loop;
                            mult_counter <= 0;
                            sum_register <= (others => '0');
                            mult_add_din_ready <= '0';
                            mult_add_dout_valid <= '0';
                            mult_add_state <= mult_add;
                        end if;
                    when mult_add =>
                        if mult_counter = G_NUM_TAPS-1 then
                            mult_counter <= 0;
                            mult_add_din_ready <= '0';
                            mult_add_dout_valid <= '1';
                            mult_add_state <= wait_for_dout_ready;
                        else
                            mult_counter <= mult_counter + 1;
                        end if;
                        sum_register <= sum_register + 
                                        (signed(shift_reg_store(mult_counter))*signed(taps_register(mult_counter)));
                    when wait_for_dout_ready =>
                        if mult_add_dout_valid = '1' and mult_add_dout_ready = '1' then
                            for i in 0 to G_NUM_TAPS-1 loop
                                shift_reg_store(i) <= (others => '0');
                            end loop;
                            sum_register <= (others => '0');
                            mult_add_din_ready <= '1';
                            mult_add_dout_valid <= '0';
                            mult_add_state <= get_input;
                        end if;
                    when others =>
                        mult_add_state <= init;
                end case;
            end if;
        end if;
    end process;

    --dout_valid_int <= mult_add_dout_valid;

    dout_valid_int <= din_valid when bypass = '1' else
                      mult_add_dout_valid when din_last_empty_fir = '1' and dout_done = '0' else
                      '0' when output_counter < C_CENTER_TAP_NUM-1 else
                      mult_add_dout_valid;

    mult_add_dout_ready <= dout_ready;

    reg_sum_array_final <= std_logic_vector(sum_register);
    reg_sum_round <= std_logic_vector(signed(reg_sum_array_final) + 2**(G_TAP_RES-2)) when reg_sum_array_final(G_TAP_RES-2) = '1' else 
                     reg_sum_array_final; -- round result

    sum_divided <= C_SUM_DIVIDED_MAX when reg_sum_round(reg_sum_round'length-1) = '0' and reg_sum_round(G_DWIDTH+G_TAP_RES-2) = '1' else
                   C_SUM_DIVIDED_MIN when reg_sum_round(reg_sum_round'length-1) = '1' and reg_sum_round(G_DWIDTH+G_TAP_RES-2) = '0' else
                   reg_sum_round(G_DWIDTH+G_TAP_RES-1-1 downto G_TAP_RES-1);

    dout_int <= din when bypass = '1' else sum_divided(G_DWIDTH-1 downto 0) when dout_done = '0' else (others => '0');

    p_signal_propigation_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                sig_prop_counter <= 0;
                output_counter <= 0;
            else
                if mult_add_dout_valid = '1' and mult_add_dout_ready = '1' then
                    if output_counter < G_NUM_TAPS then
                        output_counter <= output_counter + 1;
                    end if;
                end if;


                if din_go = '1' and dout_go = '0' then
                    if sig_prop_counter /= G_NUM_TAPS then
                        sig_prop_counter <= sig_prop_counter + 1;
                    end if;
                elsif din_go = '0' and dout_go = '1' then
                    if sig_prop_counter /= 0 then
                        sig_prop_counter <= sig_prop_counter - 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    tap_wr_done <= tap_wr_done_int;

    dout <= dout_int;


    dout_valid <= dout_valid_int;
    dout_last <= dout_last_int;

end rtl;



