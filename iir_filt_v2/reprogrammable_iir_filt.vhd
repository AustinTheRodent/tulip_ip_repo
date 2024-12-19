--                          ┌────────────┐
--     Taps AXIS───────────►│ Reprogram  │       Monitor tlast
--                          │ State      │◄────────────┐
--            Monitor tlast │ Machine    │             │
--              ┌──────────►│            │             │
--              │           │            │             │
--              │   ┌───────┤            │             │
--              │   │       │            │             │
--              │   │       └─────┬──────┘             │
--              │   │             │ Taps               │
--              │   │             │                    │
--              │   │             ▼                    │
--              │   ▼         ┌────────┐               │
--              │ ┌────┐      │IIR     │               │
-- Data In AXIS─┴►│Gate├─────►│Filter  │───────────────┴─────►Data Out AXIS
--                └────┘      │        │
--                            └────────┘
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reprogrammable_iir_filt is
  generic
  (
    G_PACK_TAPS_MSB_FIRST : boolean := false;
    G_NUM_B_TAPS          : integer range 2 to 255  := 16;
    G_NUM_A_TAPS          : integer range 2 to 255  := 16;
    G_TAP_INTEGER_BITS    : integer := 2;
    G_TAP_DWIDTH          : integer := 64;
    G_DWIDTH              : integer := 64
  );
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;
    bypass                : in  std_logic;

    s_prog_b_tap_tdata    : in  std_logic_vector(G_NUM_B_TAPS*G_TAP_DWIDTH-1 downto 0);
    s_prog_b_tap_tvalid   : in  std_logic;
    s_prog_b_tap_tready   : out std_logic;
    s_prog_b_tap_tlast    : in  std_logic;
    prog_b_tap_done       : out std_logic;

    s_prog_a_tap_tdata    : in  std_logic_vector(G_NUM_A_TAPS*G_TAP_DWIDTH-1 downto 0);
    s_prog_a_tap_tvalid   : in  std_logic;
    s_prog_a_tap_tready   : out std_logic;
    s_prog_a_tap_tlast    : in  std_logic;
    prog_a_tap_done       : out std_logic;

    s_iir_tdata           : in  std_logic_vector(G_DWIDTH-1 downto 0);
    s_iir_tvalid          : in  std_logic;
    s_iir_tready          : out std_logic;
    s_iir_tlast           : in  std_logic;

    m_iir_tdata           : out std_logic_vector(G_DWIDTH-1 downto 0);
    m_iir_tvalid          : out std_logic;
    m_iir_tready          : in  std_logic;
    m_iir_tlast           : out std_logic
  );
end entity;

architecture rtl of reprogrammable_iir_filt is

  type a_taps_t is array (0 to G_NUM_A_TAPS-1) of std_logic_vector(G_DWIDTH-1 downto 0);
  type b_taps_t is array (0 to G_NUM_B_TAPS-1) of std_logic_vector(G_DWIDTH-1 downto 0);

  signal a_taps           : a_taps_t;
  signal b_taps           : b_taps_t;
  signal a_taps_store     : a_taps_t;
  signal b_taps_store     : b_taps_t;

  signal b_taps_done      : std_logic;
  signal a_taps_done      : std_logic;

  signal a_prog_counter  : unsigned(7 downto 0);
  signal b_prog_counter  : unsigned(7 downto 0);

  signal core_prog_b_tap      : std_logic_vector(G_TAP_DWIDTH-1 downto 0);
  signal core_prog_b_tap_addr : std_logic_vector(7 downto 0);
  signal core_prog_b_tap_wr   : std_logic;

  signal core_prog_a_tap      : std_logic_vector(G_TAP_DWIDTH-1 downto 0);
  signal core_prog_a_tap_addr : std_logic_vector(7 downto 0);
  signal core_prog_a_tap_wr   : std_logic;

  signal s_core_tdata         : std_logic_vector(G_DWIDTH-1 downto 0);
  signal s_core_tvalid        : std_logic;
  signal s_core_tready        : std_logic;
  signal s_core_tlast         : std_logic;
  signal m_core_tdata         : std_logic_vector(G_DWIDTH-1 downto 0);
  signal m_core_tvalid        : std_logic;
  signal m_core_tready        : std_logic;
  signal m_core_tlast         : std_logic;

  type state_t is
  (
    SM_INIT,
    SM_GET_TAPS,
    SM_PROG_TAPS,
    SM_RUN_FILTER,
    SM_WAIT_FOR_LAST
  );

  signal state : state_t;

begin

  gen_a_taps_split : for i in 0 to G_NUM_A_TAPS-1 generate

    gen_a_lsbs_first : if G_PACK_TAPS_MSB_FIRST = false generate
      a_taps(i) <= s_prog_a_tap_tdata(G_TAP_DWIDTH*(i+1)-1 downto G_TAP_DWIDTH*i);
    end generate;

    gen_a_msbs_first : if G_PACK_TAPS_MSB_FIRST = true generate
      a_taps(i) <= s_prog_a_tap_tdata(G_TAP_DWIDTH*(G_NUM_A_TAPS-i)-1 downto G_TAP_DWIDTH*(G_NUM_A_TAPS-i-i));
    end generate;

  end generate;

  gen_b_taps_split : for i in 0 to G_NUM_B_TAPS-1 generate

    gen_b_lsbs_first : if G_PACK_TAPS_MSB_FIRST = false generate
      b_taps(i) <= s_prog_b_tap_tdata(G_TAP_DWIDTH*(i+1)-1 downto G_TAP_DWIDTH*i);
    end generate;

    gen_b_msbs_first : if G_PACK_TAPS_MSB_FIRST = true generate
      b_taps(i) <= s_prog_b_tap_tdata(G_TAP_DWIDTH*(G_NUM_B_TAPS-i)-1 downto G_TAP_DWIDTH*(G_NUM_B_TAPS-i-i));
    end generate;

  end generate;

  s_core_tdata  <= s_iir_tdata;
  s_core_tvalid <= s_iir_tvalid when state = SM_RUN_FILTER else '0';
  s_iir_tready  <= s_core_tready when state = SM_RUN_FILTER else '0';
  s_core_tlast  <= s_iir_tlast when state = SM_RUN_FILTER else '0';

  m_iir_tdata   <= m_core_tdata;
  m_iir_tvalid  <= m_core_tvalid;
  m_core_tready <= m_iir_tready;
  m_iir_tlast   <= m_core_tlast;

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' or bypass = '1' then
        b_taps_done <= '0';
        a_taps_done <= '0';
        state       <= SM_INIT;
      else
        case state is
          when SM_INIT =>
            b_prog_counter    <= (others => '0');
            a_prog_counter    <= (others => '0');
            b_taps_done       <= '0';
            a_taps_done       <= '0';
            state             <= SM_GET_TAPS;

          when SM_GET_TAPS =>
            if s_prog_b_tap_tvalid = '1' and b_taps_done = '0' then
              for i in 0 to G_NUM_B_TAPS-1 loop
                b_taps_store(i) <= b_taps(i);
              end loop;
              b_taps_done <= '1';
            end if;

            if s_prog_a_tap_tvalid = '1' and a_taps_done = '0' then
              for i in 0 to G_NUM_A_TAPS-1 loop
                a_taps_store(i) <= a_taps(i);
              end loop;
              a_taps_done <= '1';
            end if;

            if a_taps_done = '1' and b_taps_done = '1' then
              core_prog_a_tap_wr  <= '1';
              core_prog_b_tap_wr  <= '1';
              state     <= SM_PROG_TAPS;
            end if;

          when SM_PROG_TAPS =>

            if a_prog_counter = G_NUM_A_TAPS-1 then
              core_prog_a_tap_wr        <= '0';
            else
              a_prog_counter  <= a_prog_counter + 1;
            end if;

            if b_prog_counter = G_NUM_B_TAPS-1 then
              core_prog_b_tap_wr        <= '0';
            else
              b_prog_counter  <= b_prog_counter + 1;
            end if;

            if core_prog_a_tap_wr = '0' and core_prog_b_tap_wr = '0' then
              state <= SM_RUN_FILTER;
            end if;

          when SM_RUN_FILTER =>
            if s_core_tvalid = '1' and s_core_tready = '1' and s_core_tlast = '1' then
              state <= SM_WAIT_FOR_LAST;
            end if;

          when SM_WAIT_FOR_LAST =>
            if m_core_tvalid = '1' and m_core_tready = '1' and m_core_tlast = '1' then
              b_prog_counter    <= (others => '0');
              a_prog_counter    <= (others => '0');
              b_taps_done       <= '0';
              a_taps_done       <= '0';
              state             <= SM_GET_TAPS;
            end if;

          when others =>
            null;

        end case;
      end if;
    end if;
  end process;

  core_prog_b_tap <= b_taps_store(to_integer(b_prog_counter));
  core_prog_a_tap <= b_taps_store(to_integer(a_prog_counter));

  core_prog_b_tap_addr  <= std_logic_vector(b_prog_counter);
  core_prog_a_tap_addr  <= std_logic_vector(a_prog_counter);

  u_core_iir : entity work.iir_filt
    generic map
    (
      G_NUM_B_TAPS        => G_NUM_B_TAPS,
      G_NUM_A_TAPS        => G_NUM_A_TAPS,
      G_TAP_INTEGER_BITS  => G_TAP_INTEGER_BITS,
      G_TAP_DWIDTH        => G_TAP_DWIDTH,
      G_DWIDTH            => G_DWIDTH
    )
    port map
    (
      clk                 => clk,
      reset               => reset,
      bypass              => bypass,

      b_tap_val           => core_prog_b_tap,
      b_tap_addr          => core_prog_b_tap_addr,
      b_tap_wr            => core_prog_b_tap_wr,

      a_tap_val           => core_prog_a_tap,
      a_tap_addr          => core_prog_a_tap_addr,
      a_tap_wr            => core_prog_a_tap_wr,

      s_iir_tdata         => s_core_tdata,
      s_iir_tvalid        => s_core_tvalid,
      s_iir_tready        => s_core_tready,
      s_iir_tlast         => s_core_tlast,

      m_iir_tdata         => m_core_tdata,
      m_iir_tdata_full    => open,
      m_iir_tvalid        => m_core_tvalid,
      m_iir_tready        => m_core_tready,
      m_iir_tlast         => m_core_tlast
    );

end rtl;
