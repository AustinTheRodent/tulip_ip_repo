--******************************************************************************
--                                                                             *
-- Copyright (C) 2010 Regents of the University of California.                 *
--                                                                             *
-- The information contained herein is the exclusive property of the VCL       *
-- group but may be used and/or modified for non-comercial purposes if the     *
-- author is acknowledged.  For all other uses, permission must be attained    *
-- by the VLSI Computation Lab.                                                *
--                                                                             *
-- This work has been developed by members of the VLSI Computation Lab         *
-- (VCL) in the Department of Electrical and Computer Engineering at           *
-- the University of California at Davis.  Contact: bbaas@ece.ucdavis.edu      *
--******************************************************************************
-- FIFO.v
--
-- 16-bit by 32,  dual-clock circular FIFO for interfacing at clock boundaries
--
-- $Id: FIFO.v,v 1.0 7/19/2010 02:15:36 astill Exp $
-- Written by: Aaron Stillmaker
--
-- Origional AsAP FIFO Written by: Ryan Apperson
-- First In First Out circuitry:
-- Main goal in rewriting was to have the whole FIFO in one file and not be
-- AsAP specific.  I started fresh writing most code from scratch using
-- Ryan's thesis as a guide, some of code was used from his origional
-- code, and some of the new code was modeled after the origional code.
--

-- Define FIFO Address width minus 1 and Data word width minus 1

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity async_fifo is
  generic
  (
    G_ADDR_WIDTH  : integer := 7;
    G_DATA_WIDTH  : integer := 16
  );
  port
  (
    delay_sel     : in  std_logic_vector(1 downto 0);             -- choose one/two delay cell for input data
    data_in       : in  std_logic_vector(G_DATA_WIDTH-1 downto 0); -- data to be written

    reserve       : in  std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- reserve space constant
    wr_sync_cntrl : in  std_logic_vector(2 downto 0);             -- Config input for wr side synchronizer
    rd_sync_cntrl : in  std_logic_vector(2 downto 0);             -- Config input for rd side synchronizer

    clk_wr        : in  std_logic;                                -- clock coming from write side of FIFO -- write signals
    clk_rd        : in  std_logic;                                -- clock coming from read side of FIFO  -- read signals
    reset         : in  std_logic;                                -- synchronous to read clock  --------------------------
    wr_valid      : in  std_logic;                                -- write side data is valid for writing to FIFO
    rd_request    : in  std_logic;                                -- asks the FIFO for data
    nap           : in  std_logic;                                -- no increment read pointer signal

    data_out      : out std_logic_vector(G_DATA_WIDTH-1 downto 0); -- data to be read

    fifo_util     : out std_logic_vector(1 downto 0);             -- FIFO utilization, used for DVFS

    empty         : out std_logic;                                -- FIFO is EMPTY (combinational in from 1st stage of FIFO)
    wr_request    : out std_logic;                                -- low= Full or utilizing reserve space, else NOT FULL
    async_full    : out std_logic;                                -- true if FIFO is in reserve, but referenced to read side
    async_empty   : out std_logic                                 -- true if empty, but referenced to write side
  );
end entity;

architecture rtl of async_fifo is

  signal async_full_int     : std_logic;
  signal empty_int          : std_logic;

  signal temp_adder_out     : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- temporary address out
  signal rd_ptr_on_wr       : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_ptr_gray        : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- write pointer in gray code

  signal data_out_c         : std_logic_vector(G_DATA_WIDTH-1 downto 0); -- data out from memory

  signal wr_conv_temp1      : std_logic; -- temporary wires used in gray
  signal wr_conv_temp2      : std_logic; --to binary conversions
  signal rd_conv_temp1      : std_logic;
  signal rd_conv_temp2      : std_logic;
  signal rd_en              : std_logic; -- read enable flag
  signal rd_inc             : std_logic; -- read increment flag

  signal wr_ptr             : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- write pointer
  signal rd_ptr             : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- read pointer
  signal rd_ptr_gray        : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- read pointer in gray code
  signal wr_ptr_gray_d1     : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- delayed write ptr in gray code
  signal wr_ptr_gray_d2     : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_ptr_gray_d1     : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- delayed read ptr in gray code
  signal rd_ptr_gray_d2     : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_ptr_gray_on_wr  : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_ptr_gray_on_rd  : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_ptr_on_rd       : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_Reg1            : std_logic_vector(G_ADDR_WIDTH-1 downto 0); -- registered pointers
  signal wr_Reg2            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_Reg3            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_Reg4            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal wr_RegS            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_Reg1            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_Reg2            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_Reg3            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_Reg4            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);
  signal rd_RegS            : std_logic_vector(G_ADDR_WIDTH-1 downto 0);

  signal data_in_d          : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal data_inREG1        : std_logic_vector(G_DATA_WIDTH-1 downto 0); -- registered data in values
  signal data_inREG2        : std_logic_vector(G_DATA_WIDTH-1 downto 0);
  signal data_inREG3        : std_logic_vector(G_DATA_WIDTH-1 downto 0);

  signal wr_hold_r          : std_logic; -- delayed write hold value
  signal wr_valid_d         : std_logic;
  signal validREG1          : std_logic; -- registered valid values
  signal validREG2          : std_logic;
  signal validREG3          : std_logic;

  signal fifo_util_temp     : std_logic_vector(6 downto 0);
  --signal fifo_util          : std_logic_vector(1 downto 0);

  signal reset_wr_clk_meta  : std_logic;
  signal reset_wr_clk       : std_logic;

begin

  p_reset_wr_side : process(clk_wr)
  begin
    if rising_edge(clk_wr) then
      reset_wr_clk_meta <= reset;
      reset_wr_clk      <= reset_wr_clk_meta;
    end if;
  end process;

  async_full    <= async_full_int;
  empty         <= empty_int;

  -- Temporary wires used in the Gray Code to Binary Converter
  wr_conv_temp1 <= rd_ptr_gray_on_wr(1) xor rd_ptr_gray_on_wr(2);
  wr_conv_temp2 <= rd_ptr_gray_on_wr(1) xor (not rd_ptr_gray_on_wr(2));


   -- Reserve Logic Calculation, if the MSB is 1, hold.
   --Accordingly assign the wr request output and async full

  temp_adder_out  <= std_logic_vector(unsigned(wr_ptr_on_rd) - unsigned(rd_ptr) + unsigned(reserve));
  async_full_int  <= temp_adder_out(G_ADDR_WIDTH-1);
  wr_request      <= not wr_hold_r;

   -- Asynchronous Communication of RD address pointer from RD side to WR side

  wr_RegS <=
    rd_ptr_gray_d2  when wr_sync_cntrl = "000" else
    wr_Reg1         when wr_sync_cntrl = "100" else
    wr_Reg2         when wr_sync_cntrl = "101" else
    wr_Reg3         when wr_sync_cntrl = "110" else
    wr_Reg4         when wr_sync_cntrl = "111" else
    (others => '0');

  process(clk_wr)
  begin
    if rising_edge(clk_wr) then
      -- Binary Incrementer %%

      -- Asynchronous Communication of RD address pointer from RD side to
      --WR side %%

      if reset_wr_clk = '1' then  --reset address FFs
        wr_ptr            <= (others => '0');
        wr_ptr_gray_d1    <= (others => '0');
        wr_ptr_gray_d2    <= (others => '0');
        wr_hold_r	        <= '0';

        wr_Reg1           <= (others => '0');
        wr_Reg2           <= (others => '0');
        wr_Reg3           <= (others => '0');
        wr_Reg4           <= (others => '0');
        rd_ptr_gray_on_wr <= (others => '0');

         -- Insert delay to avoid the holdtime violation

        case delay_sel is
          when "00" =>
            wr_valid_d  <= wr_valid;
            data_in_d   <= data_in;
          when "01" =>
            wr_valid_d  <= validREG1;
            data_in_d   <= data_inREG1;
          when "10" =>
            wr_valid_d  <= validREG2;
            data_in_d   <= data_inREG2;
          when "11" =>
            wr_valid_d  <= validREG3;
            data_in_d   <= data_inREG3;
          when others =>
            wr_valid_d  <= wr_valid;
            data_in_d   <=	data_in;
        end case;

      else

        if wr_valid_d = '1' then
          wr_ptr          <=  std_logic_vector(unsigned(wr_ptr) + 1);
        end if;
        wr_ptr_gray_d1    <=  wr_ptr_gray;
        wr_ptr_gray_d2    <=  wr_ptr_gray_d1;
        wr_hold_r         <=  async_full_int;

        wr_Reg1           <=  rd_ptr_gray_d2;
        wr_Reg2           <=  wr_Reg1;
        wr_Reg3           <=  wr_Reg2;
        wr_Reg4           <=  wr_Reg3;

        validREG1         <=  wr_valid;
        validREG2         <=  validREG1;
        validREG3         <=  validREG2;

        data_inREG1       <=  data_in;
        data_inREG2       <=  data_inREG1;
        data_inREG3       <=  data_inREG2;

        rd_ptr_gray_on_wr <= wr_RegS;

         -- Insert delay to avoid the holdtime violation

        case	delay_sel is
          when "00" =>
            wr_valid_d  <= wr_valid;
            data_in_d   <= data_in;
          when "01" =>
            wr_valid_d  <= validREG1;
            data_in_d   <= data_inREG1;
          when "10" =>
            wr_valid_d  <= validREG2;
            data_in_d   <= data_inREG2;
          when "11" =>
            wr_valid_d  <= validREG3;
            data_in_d   <= data_inREG3;
          when others =>
            wr_valid_d  <= wr_valid;
            data_in_d   <=	data_in;

        end case;

      end if;
    end if;
  end process;

   -- Binary to Gray Code Converter %%

  wr_ptr_gray(0) <= wr_ptr(0) xor wr_ptr(1);
  wr_ptr_gray(1) <= wr_ptr(1) xor wr_ptr(2);
  wr_ptr_gray(2) <= wr_ptr(2) xor wr_ptr(3);
  wr_ptr_gray(3) <= wr_ptr(3) xor wr_ptr(4);
  wr_ptr_gray(4) <= wr_ptr(4) xor wr_ptr(5);
  wr_ptr_gray(5) <= wr_ptr(5) xor wr_ptr(6);
  wr_ptr_gray(6) <= wr_ptr(6);


   -- Gray Code to Binary Converter %%

  rd_ptr_on_wr(6) <= rd_ptr_gray_on_wr(6);
  rd_ptr_on_wr(5) <= rd_ptr_gray_on_wr(5) xor rd_ptr_gray_on_wr(6);
  rd_ptr_on_wr(4) <= rd_ptr_gray_on_wr(4) xor rd_ptr_on_wr(5);
  rd_ptr_on_wr(3) <= rd_ptr_gray_on_wr(3) xor rd_ptr_on_wr(4);

  rd_ptr_on_wr(2) <=
    not rd_ptr_gray_on_wr(2) when rd_ptr_on_wr(3) = '1' else
    rd_ptr_gray_on_wr(2);

  rd_ptr_on_wr(1) <=
    wr_conv_temp2 when rd_ptr_on_wr(3) = '1' else
    wr_conv_temp1;

  rd_ptr_on_wr(0) <=
    wr_conv_temp2 xor rd_ptr_gray_on_wr(0) when rd_ptr_on_wr(3) = '1' else
    wr_conv_temp1 xor rd_ptr_gray_on_wr(0);


   -- Read Logic %%%


   -- Temporary wires used in the Gray Code to Binary Converter

  rd_conv_temp1 <= wr_ptr_gray_on_rd(1) xor wr_ptr_gray_on_rd(2);
  rd_conv_temp2 <= wr_ptr_gray_on_rd(1) xor (not wr_ptr_gray_on_rd(2));


   -- Read Enable Logic

  rd_en <= (not empty_int) and rd_request;


   -- Increment Enable Logic

  rd_inc <= rd_en and (not nap);


   -- Empty Logic, see if the next value for the read pointer would be empty

  empty_int <=
    not nap when unsigned(rd_ptr) + 1 = unsigned(wr_ptr_on_rd) else
    '0';

   -- Asynchronous Communication of WR address pointer from WR side to RD side

  rd_RegS <=
    wr_ptr_gray_d2  when rd_sync_cntrl = "000" else
    rd_Reg1         when rd_sync_cntrl = "100" else
    rd_Reg2         when rd_sync_cntrl = "101" else
    rd_Reg3         when rd_sync_cntrl = "110" else
    rd_Reg4         when rd_sync_cntrl = "111" else
    (others => '0');

  process(clk_rd)
  begin
    if rising_edge(clk_rd) then
      -- Binary Incrementers %%

      if reset = '1' then
        rd_ptr          <= (others => '1');
        wr_ptr_on_rd    <= (others => '0');
        rd_ptr_gray     <= (others => '0');
        rd_ptr_gray_d1  <= (others => '0');
        rd_ptr_gray_d2  <= (others => '0');
      else
        if rd_inc = '1' then
          rd_ptr        <= std_logic_vector(unsigned(rd_ptr) + 1);
        end if;
        rd_ptr_gray_d1  <= rd_ptr_gray;
        rd_ptr_gray_d2  <= rd_ptr_gray_d1;
      end if;

      -- Binary to Gray Code Converter %%

      rd_ptr_gray(0)  <= rd_ptr(0)  xor rd_ptr(1);
      rd_ptr_gray(1)  <= rd_ptr(1)  xor rd_ptr(2);
      rd_ptr_gray(2)  <= rd_ptr(2)  xor rd_ptr(3);
      rd_ptr_gray(3)  <= rd_ptr(3)  xor rd_ptr(4);
      rd_ptr_gray(4)  <= rd_ptr(4)  xor rd_ptr(5);
      rd_ptr_gray(5)  <= rd_ptr(5)  xor rd_ptr(6);
      rd_ptr_gray(6)  <= rd_ptr(6) ;

      -- Asynchronous Communication of WR address ptr from WR side to RD side %%

      if reset = '1' then
        rd_Reg1           <= (others => '0');
        rd_Reg2           <= (others => '0');
        rd_Reg3           <= (others => '0');
        rd_Reg4           <= (others => '0');
        wr_ptr_gray_on_rd <= (others => '0');
      else
        rd_Reg1           <= wr_ptr_gray_d2;
        rd_Reg2           <= rd_Reg1;
        rd_Reg3           <= rd_Reg2;
        rd_Reg4           <= rd_Reg3;
        wr_ptr_gray_on_rd <= rd_RegS;
      end if;

      -- Gray Code to Binary Converter %%

      wr_ptr_on_rd(6) <= wr_ptr_gray_on_rd(6);
      wr_ptr_on_rd(5) <= wr_ptr_gray_on_rd(5) xor wr_ptr_gray_on_rd(6);
      wr_ptr_on_rd(4) <= wr_ptr_gray_on_rd(4) xor wr_ptr_on_rd(5);
      wr_ptr_on_rd(3) <= wr_ptr_gray_on_rd(3) xor wr_ptr_on_rd(4);


      if wr_ptr_on_rd(3) = '1' then
        wr_ptr_on_rd(2) <= not wr_ptr_gray_on_rd(2);
        wr_ptr_on_rd(1) <= rd_conv_temp2;
        wr_ptr_on_rd(0) <= rd_conv_temp2 xor wr_ptr_gray_on_rd(0);
      else
        wr_ptr_on_rd(2) <= wr_ptr_gray_on_rd(2);
        wr_ptr_on_rd(1) <= rd_conv_temp1;
        wr_ptr_on_rd(0) <= rd_conv_temp1 xor wr_ptr_gray_on_rd(0);
      end if;

      -- Register the SRAM output

      data_out <= data_out_c;

    end if;
   end process;


   -- Asychronous Empty Logic, used for asynchrnous wake

  async_empty <=
    '1' when wr_ptr = rd_ptr_on_wr else
    '0';

   -- FIFO utilization used by Dynamic Voltage and Frequency Scaling logic %%%
  fifo_util_temp <= std_logic_vector(unsigned(wr_ptr) - unsigned(rd_ptr) - 1);

  process(fifo_util_temp)
  begin
    if fifo_util_temp(6) = '1' then	-- util = 64
      fifo_util <= "11";
    else
     fifo_util  <= fifo_util_temp(5 downto 4);	-- util = 0 to 63
    end if;
  end process;

  u_ram : entity work.ram_dual
    generic map
    (
      G_DWIDTH  => G_DATA_WIDTH,
      G_AWIDTH  => G_ADDR_WIDTH
    )
    port map
    (
      wclk	    => clk_wr,
      we		    => wr_valid_d,
      waddr	    => wr_ptr,
      wr_data   => data_in_d,

      rclk	    => clk_rd,
      re        => rd_en,
      raddr	    => rd_ptr,
      rd_data   => data_out_c
    );

end rtl;
