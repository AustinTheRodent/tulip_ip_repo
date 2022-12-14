----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/11/2022 12:25:51 PM
-- Design Name: 
-- Module Name: xcorr - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity xcorr is
  Port (clk,signalvalid,chirpvalid: in STD_LOGIC;
  inputchirp: in std_logic_vector(0 to 1023);
  inputchirpimag: in std_logic_vector(0 to 1023);
  inputsignal: in std_logic_vector(0 to 1023);
  inputsignalimag: in std_logic_vector(0 to 1023);
  outvalid: out STD_LOGIC;
  output: out std_logic_vector(0 to 95));
end xcorr;

architecture Behavioral of xcorr is

type arraysignal is array(0 to 9999) of signed(15 downto 0);
type signalbuffer is array(0 to 63) of signed(15 downto 0);
type outputbuffer is array(0 to 63) of signed(47 downto 0);

signal partialsum: outputbuffer := (others=>(others=>'0'));
signal partialsumimag: outputbuffer := (others=>(others=>'0'));

signal state: unsigned(7 downto 0):= to_unsigned(0,8);
signal finaladditionstate: unsigned(3 downto 0):=to_unsigned(0,4);
signal siginstate: unsigned(7 downto 0):= to_unsigned(0,8);
signal done: std_logic:='0';

signal address_in: std_logic_vector(7 downto 0);
signal data_in: std_logic_vector(0 to 2047);
signal address_out: std_logic_vector(7 downto 0);
signal data_out: std_logic_vector(0 to 2047);
signal write: std_logic;
    
--component blk_mem_gen_0 is
--  port (
--    clka : IN STD_LOGIC;
--    ena : IN STD_LOGIC;
--    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
--    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    dina : IN STD_LOGIC_VECTOR(2047 DOWNTO 0);
--    clkb : IN STD_LOGIC;
--    enb : IN STD_LOGIC;
--    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--    doutb : OUT STD_LOGIC_VECTOR(2047 DOWNTO 0)
--  );
--end component;
    
begin

  --signalram : blk_mem_gen_0 port map(
  --  clka=>clk,
  --  ena=>write,
  --  wea=>"1",
  --  addra=>address_in,
  --  dina=> data_in,
  --  clkb=>clk,
  --  enb=>'1',
  --  addrb=>address_out,
  --  doutb=>data_out);

  signalram : entity work.xcorr_bram
    generic map
    (
      G_DATA_WIDTH  => 2048,
      G_ADDR_WIDTH  => 8
    )
    port map
    (
      clk           => clk,

      we            => write,
      address_in    => address_in,
      data_in       => data_in,

      address_out   => address_out,
      data_out      => data_out
    );
  
  process(clk) 
  begin 
    
    if rising_edge(clk) then
      outvalid<=done;
      -- store signal
      write<=signalvalid;
      if signalvalid='1' then
        if siginstate/=157 then
          address_in<=std_logic_vector(siginstate);
          data_in<=std_logic_vector(inputsignal)&std_logic_vector(inputsignalimag);
        end if;
        if siginstate=157 then
          siginstate<=to_unsigned(0,8);
          address_out<="00000000";
        else
          siginstate <= siginstate+1;
        end if;
      end if;
    
      -- add chirplet from axi port to partial convolution buffer
      if chirpvalid='1' then
        if state/=157 then
          address_out<=std_logic_vector(state+1);
          for j in 0 to 63 loop 
            partialsum(j) <= partialsum(j) + signed(data_out(16*j to 16*j+15)) * signed(inputchirp(16*j to 16*j+15)) + signed(data_out(16*j+1024 to 16*j+15+1024)) * signed(inputchirpimag(16*j to 16*j+15));
            partialsumimag(j) <= partialsumimag(j) + signed(data_out(16*j+1024 to 16*j+15+1024)) * signed(inputchirp(16*j to 16*j+15)) - signed(data_out(16*j to 16*j+15)) * signed(inputchirpimag(16*j to 16*j+15));
          end loop;
          state <=state+1;
        end if;
      
      -- final addition and output
      else
        if state=157 and finaladditionstate/=6 then
          for j in 0 to 31 loop
            partialsum(j) <=partialsum(2*j)+partialsum(2*j+1);
            partialsumimag(j) <=partialsumimag(2*j)+partialsumimag(2*j+1);
          end loop;
          finaladditionstate<=finaladditionstate+1;
        elsif state=157 then
          if done='1' then
            done<='0';
            state<=to_unsigned(0,8);
            finaladditionstate<=to_unsigned(0,4);
            for j in 0 to 63 loop
              partialsum(j) <=to_signed(0,48);
              partialsumimag(j) <=to_signed(0,48);
            end loop;
          else
            done<='1';
            output(0 to 47)<=std_logic_vector(partialsum(0));
            output(48 to 95)<=std_logic_vector(partialsumimag(0));
            address_out<="00000000";
          end if;
        end if;
      end if;
    end if;
  end process;
  
end Behavioral;
