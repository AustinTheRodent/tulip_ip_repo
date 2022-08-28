library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity decimator is
    generic
    (
        G_DWIDTH            : integer range 1 to 64 := 16
    );
    port
    (
        clk                 : in  std_logic;
        reset               : in  std_logic;
        enable              : in  std_logic;
        bypass              : in  std_logic;

        decimation_factor   : in  std_logic_vector(15 downto 0);

        din                 : in  std_logic_vector(G_DWIDTH-1 downto 0);
        din_valid           : in  std_logic;
        din_ready           : out std_logic;
        din_last            : in  std_logic;

        dout                : out std_logic_vector(G_DWIDTH-1 downto 0);
        dout_valid          : out std_logic;
        dout_ready          : in  std_logic;
        dout_last           : out std_logic
    );
end entity;

architecture rtl of decimator is

    signal din_ready_int    : std_logic;
    signal dout_int         : std_logic_vector(G_DWIDTH-1 downto 0);
    signal dout_valid_int   : std_logic;
    signal dout_last_int    : std_logic;

    signal din_go           : std_logic;
    signal dout_go          : std_logic;


    signal input_counter    : unsigned(15 downto 0);

    type sm_state_t is (SM_INIT, SM_PASS, SM_DECIMATE, SM_DONE);
    signal sm_state : sm_state_t;


begin

    din_ready       <= din_ready_int;
    dout            <= dout_int;
    dout_valid      <= dout_valid_int;
    dout_last       <= dout_last_int;

    din_go          <= din_valid and din_ready_int;
    dout_go         <= dout_valid_int and dout_ready;

    din_ready_int   <= dout_ready   when bypass = '1'                       else
                       '0'          when sm_state = SM_DONE                 else
                       '0'          when sm_state = SM_INIT                 else
                       dout_ready;

    dout_int        <= din;

    dout_valid_int  <= din_valid    when bypass = '1'                       else
                       din_valid    when sm_state = SM_PASS                 else
                       '1'          when din_last = '1' and din_valid = '1' else
                       '0';

    dout_last_int   <= din_last;

    p_input_counter : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                sm_state <= SM_INIT;
                input_counter <= (others => '0');
            else
                case (sm_state) is
                    when SM_INIT =>
                        input_counter <= (others => '0');
                        sm_state <= SM_PASS;

                    when SM_PASS =>
                        if din_go = '1' and dout_go = '1' then
                            if din_last = '1' then
                                input_counter <= (others => '0');
                                sm_state <= SM_DONE;
                            else
                                input_counter <= input_counter + 1;
                                sm_state <= SM_DECIMATE;
                            end if;
                        end if;

                    when SM_DECIMATE =>
                        if din_go = '1' then
                            if din_last = '1' then
                                input_counter <= (others => '0');
                                sm_state <= SM_DONE;
                            else
                                if input_counter = unsigned(decimation_factor)-1 then
                                    input_counter <= (others => '0');
                                    sm_state <= SM_PASS;
                                else
                                    input_counter <= input_counter + 1;
                                end if;
                            end if;
                        end if;

                    when SM_DONE =>
                        sm_state <= SM_DONE;

                    when others =>
                        input_counter <= (others => '0');
                        sm_state <= SM_INIT;

                end case;
            end if;
        end if;
    end process;

end rtl;








