library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity axis_async_fifo is
  generic
  (
    G_DATA_WIDTH :integer := 8;
    G_ADDR_WIDTH :integer := 4
  );
  port
  (

    async_reset : in  std_logic;

    din_clk     : in  std_logic;
    din         : in  std_logic_vector(G_DATA_WIDTH-1 downto 0);
    din_valid   : in  std_logic;
    din_ready   : out std_logic;

    dout_clk    : in  std_logic;
    dout        : out std_logic_vector(G_DATA_WIDTH-1 downto 0);
    dout_valid  : out std_logic;
    dout_ready  : in  std_logic

  );
end entity;

architecture rtl of axis_async_fifo is

  signal din_ready_int    : std_logic;

  signal din_accepted     : std_logic;

  type state_t is (init, use_buffer, use_core);
  signal state            : state_t;

  signal core_full        : std_logic;
  signal core_dout        : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal core_dout_buffer : std_logic_vector(G_DATA_WIDTH-1 downto 0);

begin;

  din_ready     <= din_ready_int;

  din_ready_int <= not core_full;
  din_accepted  <= din_valid and din_ready_int;

  u_fifo_core : entity work.async_fifo
    generic map
    (
      DATA_WIDTH => G_DATA_WIDTH,
      ADDR_WIDTH => G_ADDR_WIDTH
    )
    port map
    (
        -- Reading port.
        Data_out    => core_dout,
        Empty_out   => out std_logic;
        ReadEn_in   => in  std_logic;
        RClk        => in  std_logic;
        -- Writing port.
        Data_in     => din,
        Full_out    => core_full,
        WriteEn_in  => din_accepted,
        WClk        => din_clk,
	 
        Clear_in    => async_reset
    );

  p_bram2axis : process(dout_clk)
  begin
    if async_reset = '1' then
      core_dout_buffer  <= (others => '0');
      state             <= init;
    elsif rising_edge(dout_clk) then
      case state is =>
        when init =>
          state <= init;
        when others =>
          state <= init;
      end case;
    end if;
  end process;


end rtl;





















