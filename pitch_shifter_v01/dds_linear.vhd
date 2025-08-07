library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dds_linear is
  generic
  (
    G_DWIDTH : integer range 4 to 128 := 32
  );
  port
  (
    clk   : in  std_logic;
    reset : in  std_logic;

    din       : in  std_logic_vector(G_DWIDTH-1 downto 0);
    din_valid : in  std_logic;
    din_ready  : out std_logic;

    dout       : out std_logic_vector(G_DWIDTH-1 downto 0);
    dout_valid : out std_logic;
    dout_ready : in  std_logic
  );
end entity;

architecture rtl of dds_linear is
  type state_t is (SM_INIT, SM_GET, SM_OUTPUT);
  signal state : state_t;

  signal counter : unsigned(G_DWIDTH-1 downto 0);

begin

  p_state_machine : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        din_ready <= '0';
        dout_valid <= '0';
        state <= SM_INIT;
      else
        case state is
          when SM_INIT =>
            counter <= (others => '0');
            din_ready <= '1';
            dout_valid <= '0';
            state <= SM_GET;

          when SM_GET =>
            if din_valid = '1' then
              din_ready <= '0';
              dout_valid <= '1';
              counter  <= counter + unsigned(din);
              dout <= std_logic_vector(counter + unsigned(din));
              state <= SM_OUTPUT;
            end if;

          when SM_OUTPUT =>
            if dout_ready = '1' then
              din_ready <= '1';
              dout_valid <= '0';
              state <= SM_GET;
            end if;

          when others =>
            NULL;
        end case;
      end if;
    end if;
  end process;

end rtl;
