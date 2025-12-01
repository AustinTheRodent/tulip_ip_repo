library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- todo:
  -- replace a majority of the top part of this module with the STFT module

entity pitch_shift_osc is
  port
  (
    clk                   : in  std_logic;
    reset                 : in  std_logic;

    prog_window_din       : in  std_logic_vector(15 downto 0);
    prog_window_din_valid : in  std_logic;
    prog_window_din_ready : out std_logic;
    prog_window_din_done  : out std_logic;

    s_axis_tdata          : in  std_logic_vector(15 downto 0);
    s_axis_tvalid         : in  std_logic;
    s_axis_tready         : out std_logic;

    m_axis_tdata          : out std_logic_vector(255 downto 0);
    m_axis_tvalid         : out std_logic;
    m_axis_tready         : in  std_logic
  );
end entity;

architecture rtl of pitch_shift_osc is

  signal stft_din         : std_logic_vector(15 downto 0);
  signal stft_din_valid   : std_logic;
  signal stft_din_ready   : std_logic;
  signal stft_dout        : std_logic_vector(255 downto 0);
  signal stft_dout_valid  : std_logic;
  signal stft_dout_ready  : std_logic;

  signal abs_din          : std_logic_vector(255 downto 0);
  signal abs_din_valid    : std_logic;
  signal abs_din_ready    : std_logic;
  signal abs_dout         : std_logic_vector(255 downto 0);
  signal abs_dout_valid   : std_logic;
  signal abs_dout_ready   : std_logic;

begin

  stft_din        <= s_axis_tdata;
  stft_din_valid  <= s_axis_tvalid;
  s_axis_tready   <= stft_din_ready;

  u_stft : entity work.stft
    port map
    (
      clk                   => clk,
      reset                 => reset,

      prog_window_din       => prog_window_din,
      prog_window_din_valid => prog_window_din_valid,
      prog_window_din_ready => prog_window_din_ready,
      prog_window_din_done  => prog_window_din_done,

      s_axis_tdata          => stft_din,
      s_axis_tvalid         => stft_din_valid,
      s_axis_tready         => stft_din_ready,

      m_axis_tdata          => stft_dout,
      m_axis_tvalid         => stft_dout_valid,
      m_axis_tready         => stft_dout_ready
    );

  abs_din         <= stft_dout;
  abs_din_valid   <= stft_dout_valid;
  stft_dout_ready <= abs_din_ready;


--  m_axis_tdata    <= stft_dout;
--  m_axis_tvalid   <= stft_dout_valid;
--  stft_dout_ready <= m_axis_tready;


  u_abs_val : entity work.abs_val
    port map
    (
      clk                   => clk,
      reset                 => reset,

      s_axis_tdata          => abs_din,
      s_axis_tvalid         => abs_din_valid,
      s_axis_tready         => abs_din_ready,

      m_axis_tdata          => abs_dout,
      m_axis_tvalid         => abs_dout_valid,
      m_axis_tready         => abs_dout_ready
    );

  m_axis_tdata    <= abs_dout;
  m_axis_tvalid   <= abs_dout_valid;
  abs_dout_ready  <= m_axis_tready;

end rtl;

