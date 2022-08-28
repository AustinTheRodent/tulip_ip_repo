library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- this module will take an input signal and go through a quarter band filter
-- followed by decimation by 4. This is repeated G_FILT_ITERATIONS times

entity dc_estimator is
    generic
    (
        G_DWIDTH            : integer range 1 to 64 := 18;
        G_FILT_ITERATIONS   : integer range 1 to 32 := 6;
        G_USE_TINY_FIR      : boolean               := true
    );
    port
    (
        clk                 : in std_logic;
        reset               : in std_logic;
        enable              : in std_logic;
        bypass              : in std_logic;

        din                 : in std_logic_vector(G_DWIDTH-1 downto 0);
        din_valid           : in std_logic;
        din_ready           : out std_logic;
        din_last            : in std_logic;

        dout                : out std_logic_vector(G_DWIDTH-1 downto 0);
        dout_valid          : out std_logic;
        dout_ready          : in std_logic;
        dout_last           : out std_logic
    );
end entity;

architecture rtl of dc_estimator is


    component tiny_fir is
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
    end component;

    component decimator is
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
    end component;

    function i2slv
    (
        valu : integer;
        sz : integer
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(valu,sz));
    end function;

    constant C_DECIMATION_FACTOR        : std_logic_vector(15 downto 0) := x"0004";
    constant C_QUARTER_BAND_TAP_WIDTH   : integer := 16;
    constant C_QUARTER_BAND_LEN         : integer := 15;

    type taps_reg_t is array(0 to C_QUARTER_BAND_LEN-1) of std_logic_vector(C_QUARTER_BAND_TAP_WIDTH-1 downto 0);
    constant C_QUARTER_BAND_TAPS : taps_reg_t := 
    (
        i2slv( 622   ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 1070 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 1596 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 2152 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 2679 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 3114 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 3400 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 3500 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 3400 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 3114 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 2679 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 2152 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 1596 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 1070 ,C_QUARTER_BAND_TAP_WIDTH),
        i2slv( 622  ,C_QUARTER_BAND_TAP_WIDTH)
    );

    type decimate_din_t         is array (0 to G_FILT_ITERATIONS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
    type decimate_din_valid_t   is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type decimate_din_ready_t   is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type decimate_din_last_t    is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type decimate_dout_t        is array (0 to G_FILT_ITERATIONS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
    type decimate_dout_valid_t  is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type decimate_dout_ready_t  is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type decimate_dout_last_t   is array (0 to G_FILT_ITERATIONS-1) of std_logic;

    type fir_din_t          is array (0 to G_FILT_ITERATIONS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
    type fir_din_valid_t    is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type fir_din_ready_t    is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type fir_din_last_t     is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type fir_dout_t         is array (0 to G_FILT_ITERATIONS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
    type fir_dout_valid_t   is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type fir_dout_ready_t   is array (0 to G_FILT_ITERATIONS-1) of std_logic;
    type fir_dout_last_t    is array (0 to G_FILT_ITERATIONS-1) of std_logic;

    signal decimate_din          : decimate_din_t;
    signal decimate_din_valid    : decimate_din_valid_t;
    signal decimate_din_ready    : decimate_din_ready_t;
    signal decimate_din_last     : decimate_din_last_t;
    signal decimate_dout         : decimate_dout_t;
    signal decimate_dout_valid   : decimate_dout_valid_t;
    signal decimate_dout_ready   : decimate_dout_ready_t;
    signal decimate_dout_last    : decimate_dout_last_t;

    signal fir_din          : fir_din_t;
    signal fir_din_valid    : fir_din_valid_t;
    signal fir_din_ready    : fir_din_ready_t;
    signal fir_din_last     : fir_din_last_t;
    signal fir_dout         : fir_dout_t;
    signal fir_dout_valid   : fir_dout_valid_t;
    signal fir_dout_ready   : fir_dout_ready_t;
    signal fir_dout_last    : fir_dout_last_t;

    signal fir_prog_count   : integer range 0 to C_QUARTER_BAND_LEN-1;

    signal fir_tap_wr       : std_logic;
    signal fir_tap_val      : std_logic_vector(C_QUARTER_BAND_TAP_WIDTH-1 downto 0);

    signal din_ready_int    : std_logic;
    signal dout_int         : std_logic_vector(G_DWIDTH-1 downto 0);
    signal dout_valid_int   : std_logic;
    signal dout_last_int    : std_logic;

begin


    din_ready           <= din_ready_int;
    dout                <= dout_int;
    dout_valid          <= dout_valid_int;
    dout_last           <= dout_last_int;


    fir_din(0)          <= din;
    fir_din_valid(0)    <= din_valid;
    din_ready_int       <= fir_din_ready(0);
    fir_din_last(0)     <= din_last;

    dout_int            <= decimate_dout(G_FILT_ITERATIONS-1);
    dout_valid_int      <= decimate_dout_valid(G_FILT_ITERATIONS-1);
    dout_last_int       <= decimate_dout_last(G_FILT_ITERATIONS-1);

    decimate_dout_ready(G_FILT_ITERATIONS-1)
                        <= dout_ready;


    dout_int            <= decimate_dout(G_FILT_ITERATIONS-1);
    dout_valid_int      <= decimate_dout_valid(G_FILT_ITERATIONS-1);

    decimate_dout_ready(G_FILT_ITERATIONS-1)
                        <= dout_ready;

    p_program_firs : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' or enable = '0' then
                fir_prog_count <= 0;
                fir_tap_wr <= '0';
                fir_tap_val <= C_QUARTER_BAND_TAPS(0);
            else
                if fir_prog_count = C_QUARTER_BAND_LEN-1 then
                    fir_tap_wr <= '0';
                elsif fir_prog_count < C_QUARTER_BAND_LEN-1 and fir_tap_wr = '1' then
                    fir_prog_count <= fir_prog_count + 1;
                    fir_tap_val <= C_QUARTER_BAND_TAPS(fir_prog_count+1);
                elsif fir_prog_count < C_QUARTER_BAND_LEN-1 and fir_tap_wr = '0' then
                    fir_tap_wr <= '1';
                end if;
            end if;
        end if;
    end process;

    g_not_final : for i  in 0 to G_FILT_ITERATIONS-2 generate
        fir_din(i+1) <= decimate_dout(i);
        fir_din_valid(i+1) <= decimate_dout_valid(i);
        decimate_dout_ready(i) <= fir_din_ready(i+1);
        fir_din_last(i+1) <= decimate_dout_last(i);
    end generate;

    --todo: hook up fir, decimate
    g_firs : for i in 0 to G_FILT_ITERATIONS-1 generate

        decimate_din(i)         <= fir_dout(i);
        decimate_din_valid(i)   <= fir_dout_valid(i);
        fir_dout_ready(i)       <= decimate_din_ready(i);
        decimate_din_last(i)    <= fir_dout_last(i);

        u_decimate_x : decimator
            generic map
            (
                G_DWIDTH            => G_DWIDTH
            )
            port map
            (
                clk                 => clk,
                reset               => reset,
                enable              => enable,
                bypass              => '0',

                decimation_factor   => C_DECIMATION_FACTOR,

                din                 => decimate_din(i),
                din_valid           => decimate_din_valid(i),
                din_ready           => decimate_din_ready(i),
                din_last            => decimate_din_last(i),
                dout                => decimate_dout(i),
                dout_valid          => decimate_dout_valid(i),
                dout_ready          => decimate_dout_ready(i),
                dout_last           => decimate_dout_last(i)
            );

        u_fir_x : tiny_fir
            generic map
            (
                G_DWIDTH    => G_DWIDTH, -- [bits]
                G_TAP_RES   => C_QUARTER_BAND_TAP_WIDTH, -- [bits]
                G_NUM_TAPS  => C_QUARTER_BAND_LEN
            )
            port map
            (
                clk         => clk,
                reset       => reset,
                enable      => enable,
                bypass      => '0',

                tap_wr      => fir_tap_wr,
                tap_val     => fir_tap_val,
                tap_wr_done => open,

                din         => fir_din(i),
                din_valid   => fir_din_valid(i),
                din_ready   => fir_din_ready(i),
                din_last    => fir_din_last(i),
                dout        => fir_dout(i),
                dout_valid  => fir_dout_valid(i),
                dout_ready  => fir_dout_ready(i),
                dout_last   => fir_dout_last(i)
            );
    end generate;

    --u_fir_0 : tiny_fir
    --    generic map
    --    (
    --        G_DWIDTH    => G_DWIDTH, -- [bits]
    --        G_TAP_RES   => C_QUARTER_BAND_TAP_WIDTH, -- [bits]
    --        G_NUM_TAPS  => C_QUARTER_BAND_LEN
    --    )
    --    port map
    --    (
    --        clk         => clk,
    --        reset       => reset,
    --        enable      => enable,
    --        bypass      => '0',
    --
    --        tap_wr      => fir_tap_wr,
    --        tap_val     => fir_tap_val,
    --        tap_wr_done => open,
    --
    --        din         => (others => '0'),
    --        din_valid   => '0',
    --        din_ready   => open,
    --        din_last    => '0',
    --
    --        dout        => open,
    --        dout_valid  => open,
    --        dout_ready  => '0',
    --        dout_last   => open
    --    );

    --din_ready_int <= dout_ready;
    --dout_int <= din;
    --dout_valid_int <= din_valid;
    --
    --din_ready <= din_ready_int;
    --dout <= dout_int;
    --dout_valid <= dout_valid_int;

end rtl;




