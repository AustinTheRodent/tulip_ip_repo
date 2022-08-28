library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_dual is
  generic
  (
    G_DWIDTH  : integer range 1 to 256;
    G_AWIDTH  : integer range 1 to 64
  );
	port 
	(
    wclk	    : in  std_logic;
    we		    : in  std_logic;
    waddr	    : in  std_logic_vector(G_AWIDTH-1 downto 0);
		wr_data   : in  std_logic_vector(G_DWIDTH-1 downto 0);

    rclk	    : in  std_logic;
    re        : in  std_logic;
		raddr	    : in  std_logic_vector(G_AWIDTH-1 downto 0);
		rd_data   : out std_logic_vector(G_DWIDTH-1 downto 0)
	);
	
end ram_dual;

architecture rtl of ram_dual is

	-- Build a 2-D array type for the RAM
	--subtype word_t is std_logic_vector(7 downto 0);
	--type memory_t is array(63 downto 0) of word_t;
	
	-- Declare the RAM signal.
	--signal ram : memory_t;


  constant C_RAM_DEPTH : integer := 2**G_AWIDTH;
  type ram_t is array (integer range <>)of std_logic_vector (G_DWIDTH-1 downto 0);
  signal ram : ram_t (0 to C_RAM_DEPTH-1);


begin

	process(wclk)
	begin
		if rising_edge(wclk) then 
			if we = '1' then
				ram(to_integer(unsigned(waddr))) <= wr_data;
			end if;
		end if;
	end process;
	
	process(rclk)
	begin
		if rising_edge(rclk) then
      if re = '1' then
        rd_data <= ram(to_integer(unsigned(raddr)));
      end if;
		end if;
	end process;

end rtl;
