
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity fir_filt is
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

architecture rtl of fir_filt is

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

    type mult_register_t is array (0 to G_NUM_TAPS-1) of integer;
    signal mult_register : mult_register_t;

    signal tap_wr_done_int : std_logic;

    type reg_sum_array_t is array (0 to G_NUM_TAPS-1) of signed(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);
    signal reg_sum_array : reg_sum_array_t;
    signal reg_sum_array_final : std_logic_vector(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);
    signal reg_sum_round : std_logic_vector(G_TAP_RES+G_DWIDTH+G_NUM_TAPS-1 downto 0);

    signal sum_divided : std_logic_vector(G_DWIDTH-1 downto 0);-- todo: magic #

    signal sig_prop_counter : integer range 0 to G_NUM_TAPS;
    signal din_go : std_logic;
    signal dout_go : std_logic;
    signal din_last_empty_fir : std_logic;
    signal dout_done : std_logic;

begin

    din_int <= (others => '0') when din_last_empty_fir = '1' else din; 

    din_go <= din_valid and din_ready_int and (not din_last_empty_fir);
    dout_go <= dout_valid_int and dout_ready and (not dout_done);

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

    dout_last_int <= '1' when din_last_empty_fir = '1' and dout_go = '1' and sig_prop_counter = 1 else '0';

    p_shift_registers : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                for i in 0 to G_NUM_TAPS-1 loop
                    shift_register(i) <= (others => '0');
                end loop;
            elsif tap_wr_done_int = '1' then
                if din_go = '1' or dout_go = '1' then
                    shift_register(0) <= din_int;
                    for i in 1 to G_NUM_TAPS-1 loop
                        shift_register(i) <= shift_register(i-1);
                    end loop;
                end if;
            end if;
        end if;
    end process;

    p_multiply_registers : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                for i in 0 to G_NUM_TAPS-1 loop
                    mult_register(i) <= 0;
                end loop;
            else
                if din_go = '1' or dout_go = '1' then
                    for i in 0 to G_NUM_TAPS-1 loop
                        mult_register(i) <= to_integer(signed(shift_register(i)))*to_integer(signed(taps_register(i)));
                    end loop;
                end if;
            end if;
        end if;
    end process;

    g_add_registers : for i in 0 to G_NUM_TAPS-1 generate
        g_first_sum : if i = 0 generate
            reg_sum_array(0) <= to_signed(mult_register(0), reg_sum_array(0)'length);
        end generate;
        g_other_sum : if i /= 0 generate
            reg_sum_array(i) <= reg_sum_array(i-1) + to_signed(mult_register(i), reg_sum_array(0)'length);
        end generate;
    end generate;

    reg_sum_array_final <= std_logic_vector(reg_sum_array(G_NUM_TAPS-1));
    reg_sum_round <= std_logic_vector(signed(reg_sum_array_final) + 2**(G_TAP_RES-2)) when reg_sum_array_final(G_TAP_RES-2) = '1' else 
                     reg_sum_array_final; -- round result

    sum_divided <= C_SUM_DIVIDED_MAX when reg_sum_round(reg_sum_round'length-1) = '0' and reg_sum_round(G_DWIDTH+G_TAP_RES-2) = '1' else
                   C_SUM_DIVIDED_MIN when reg_sum_round(reg_sum_round'length-1) = '1' and reg_sum_round(G_DWIDTH+G_TAP_RES-2) = '0' else
                   reg_sum_round(G_DWIDTH+G_TAP_RES-1-1 downto G_TAP_RES-1);

    dout_int <= sum_divided(G_DWIDTH-1 downto 0) when dout_done = '0' else (others => '0');

    p_signal_propigation_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                sig_prop_counter <= 0;
            else
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
    din_ready <= din_ready_int;

    dout <= dout_int;
    dout_valid_int <= '1' when din_last_empty_fir = '1' and dout_done = '0' else '0' when sig_prop_counter < C_CENTER_TAP_NUM+1 else din_valid;
    dout_valid <= dout_valid_int;
    din_ready_int <= dout_ready and (not din_last_empty_fir);
    dout_last <= dout_last_int;

end rtl;



