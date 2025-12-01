library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity faster_sqrt is
  generic
  (
    G_DINWIDTH      : integer := 24;
    G_DOUT_SIGFIGS  : integer := 24
  );
  port
  (
    clk           : in  std_logic;
    reset         : in  std_logic;

    s_axis_tdata  : in  std_logic_vector(G_DINWIDTH - 1 downto 0);
    s_axis_tvalid : in  std_logic;
    s_axis_tready : out std_logic;

    m_axis_tdata  : out std_logic_vector(G_DINWIDTH - 1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tready : in  std_logic
  );
end entity;

architecture rtl of faster_sqrt is


  type state_t is (SM_INIT, SM_GET_INPUT, SM_CALC0, SM_CALC1, SM_DELAY, SM_SEND_OUTPUT);
  signal state : state_t;

  signal s_axis_tready_int  : std_logic;
  signal m_axis_tvalid_int  : std_logic;

  signal root       : unsigned(G_DINWIDTH-1 downto 0);
  signal root_sqr   : unsigned(G_DINWIDTH*2-1 downto 0);

  signal input_reg  : unsigned(G_DINWIDTH*2-1 downto 0);

  signal counter    : unsigned(15 downto 0);

begin

  p_root_sqr : process(clk)
  begin
    if rising_edge(clk) then
      root_sqr <= root*root;
    end if;
  end process;

  s_axis_tready <= s_axis_tready_int;
  m_axis_tvalid <= m_axis_tvalid_int;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        state   <= SM_INIT;
        s_axis_tready_int <= '0';
        m_axis_tvalid_int <= '0';
        counter <= (others => '0');
      else
        case state is
          when SM_INIT =>
            state             <= SM_GET_INPUT;
            s_axis_tready_int <= '1';

          when SM_GET_INPUT =>
            if s_axis_tvalid = '1' and s_axis_tready_int = '1' then
              state                       <= SM_CALC0;
              s_axis_tready_int           <= '0';
              input_reg                   <= resize(unsigned(s_axis_tdata), input_reg'length);
              root(root'left)             <= '1';
              root(root'left-1 downto 0)  <= (others => '0');
              counter                     <= (others => '0');
            end if;

          when SM_CALC0 =>
            state <= SM_CALC1;

          when SM_CALC1 =>
            if root_sqr > input_reg then
              root(G_DINWIDTH-to_integer(counter)-1) <= '0';
            end if;

            if G_DOUT_SIGFIGS-to_integer(counter)-2 >= 0 then
              root(G_DINWIDTH-to_integer(counter)-2) <= '1';
            end if;

            --if counter = G_DINWIDTH-1 then
            if counter = G_DOUT_SIGFIGS-1 then
              state   <= SM_SEND_OUTPUT;
              counter <= (others => '0');
            else
              state   <= SM_CALC0;
              counter <= counter + 1;
            end if;

          when SM_SEND_OUTPUT =>
            if m_axis_tvalid_int = '1' and m_axis_tready = '1' then
              state             <= SM_GET_INPUT;
              s_axis_tready_int <= '1';
              m_axis_tvalid_int <= '0';
            else
              m_axis_tdata      <= std_logic_vector(root);
              m_axis_tvalid_int <= '1';
            end if;

          when others =>
            NULL;

        end case;
      end if;
    end if;
  end process;

end rtl;
