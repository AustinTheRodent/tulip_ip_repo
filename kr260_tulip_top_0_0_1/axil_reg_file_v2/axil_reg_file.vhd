library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axil_reg_file_pkg is

  constant C_REG_FILE_DATA_WIDTH : integer := 32;
  constant C_REG_FILE_ADDR_WIDTH : integer := 12;

  type CONTROL_subreg_t is record
    DSP_ENABLE : std_logic_vector(0 downto 0);
    PS_2_I2S_ENABLE : std_logic_vector(0 downto 0);
    I2S_2_PS_ENABLE : std_logic_vector(0 downto 0);
    I2S_ENABLE : std_logic_vector(0 downto 0);
    SW_RESETN : std_logic_vector(0 downto 0);
  end record;

  type I2C_CONTROL_subreg_t is record
    I2C_IS_READ : std_logic_vector(0 downto 0);
    DEVICE_ADDRESS : std_logic_vector(6 downto 0);
    REGISTER_ADDRESS : std_logic_vector(6 downto 0);
    REGISTER_WR_DATA : std_logic_vector(8 downto 0);
  end record;

  type PS_2_I2S_FIFO_WRITE_L_subreg_t is record
    FIFO_VALUE_L : std_logic_vector(31 downto 0);
  end record;

  type PS_2_I2S_FIFO_WRITE_R_subreg_t is record
    FIFO_VALUE_R : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_CONTROL_subreg_t is record
    SW_RESETN_WAWA : std_logic_vector(0 downto 0);
    BYPASS_WAWA : std_logic_vector(0 downto 0);
    SW_RESETN_CHORUS : std_logic_vector(0 downto 0);
    BYPASS_CHORUS : std_logic_vector(0 downto 0);
    SW_RESETN_VIBRATO : std_logic_vector(0 downto 0);
    BYPASS_VIBRATO : std_logic_vector(0 downto 0);
    SW_RESETN_USR_FIR : std_logic_vector(0 downto 0);
    BYPASS_USR_FIR : std_logic_vector(0 downto 0);
    SW_RESETN_LUT_TF : std_logic_vector(0 downto 0);
    BYPASS_LUT_TF : std_logic_vector(0 downto 0);
    SW_RESETN_REVERB : std_logic_vector(0 downto 0);
    BYPASS_REVERB : std_logic_vector(0 downto 0);
    SYMMETRIC_MODE : std_logic_vector(0 downto 0);
    BYPASS : std_logic_vector(0 downto 0);
  end record;

  type TULIP_DSP_USR_FIR_PROG_subreg_t is record
    FIR_TAP_VALUE : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_LUT_PROG_subreg_t is record
    LUT_PROG_VAL : std_logic_vector(23 downto 0);
  end record;

  type TULIP_DSP_INPUT_GAIN_subreg_t is record
    INTEGER_BITS : std_logic_vector(15 downto 0);
    DECIMAL_BITS : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_OUTPUT_GAIN_subreg_t is record
    INTEGER_BITS : std_logic_vector(15 downto 0);
    DECIMAL_BITS : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_REVERB_PROG_subreg_t is record
    REVERB_TAP_VALUE : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_REVERB_SCALE_subreg_t is record
    FEEDBACK_RIGHT_SHIFT : std_logic_vector(7 downto 0);
    FEEDBACK_GAIN : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_REVERB_FEEDFORWARD_GAIN_subreg_t is record
    FEEDFORWARD_GAIN : std_logic_vector(15 downto 0);
  end record;

  type TULIP_DSP_VIBRATO_GAIN_subreg_t is record
    GAIN : std_logic_vector(23 downto 0);
  end record;

  type TULIP_DSP_VIBRATO_CHIRP_DEPTH_subreg_t is record
    CHIRP_DEPTH : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_VIBRATO_FREQ_DERIV_subreg_t is record
    FREQ_DERIV : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_VIBRATO_FREQ_OFFSET_subreg_t is record
    FREQ_OFFSET : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_CHORUS_GAIN_subreg_t is record
    GAIN : std_logic_vector(23 downto 0);
  end record;

  type TULIP_DSP_CHORUS_AVG_DELAY_subreg_t is record
    AVG_DELAY : std_logic_vector(11 downto 0);
  end record;

  type TULIP_DSP_CHORUS_LFO_DEPTH_subreg_t is record
    LFO_DEPTH : std_logic_vector(11 downto 0);
  end record;

  type TULIP_DSP_CHORUS_LFO_FREQ_subreg_t is record
    LFO_FREQ : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_WAWA_B_TAP_DATA_MSB_subreg_t is record
    DATA : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_WAWA_B_TAP_DATA_LSB_subreg_t is record
    DATA : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_WAWA_A_TAP_DATA_MSB_subreg_t is record
    DATA : std_logic_vector(31 downto 0);
  end record;

  type TULIP_DSP_WAWA_A_TAP_DATA_LSB_subreg_t is record
    DATA : std_logic_vector(31 downto 0);
  end record;


  type reg_t is record
    CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    VERSION_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2C_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2C_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_FIFO_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_READ_L_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    I2S_2_PS_FIFO_READ_R_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_COUNT_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_WRITE_L_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    PS_2_I2S_FIFO_WRITE_R_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_CONTROL_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_STATUS_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_USR_FIR_PROG_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_LUT_PROG_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_INPUT_GAIN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_OUTPUT_GAIN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_REVERB_PROG_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_REVERB_SCALE_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_VIBRATO_GAIN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_VIBRATO_FREQ_DERIV_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_VIBRATO_FREQ_OFFSET_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_CHORUS_GAIN_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_CHORUS_AVG_DELAY_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_CHORUS_LFO_DEPTH_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_CHORUS_LFO_FREQ_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG : std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    CONTROL : CONTROL_subreg_t;
    I2C_CONTROL : I2C_CONTROL_subreg_t;
    PS_2_I2S_FIFO_WRITE_L : PS_2_I2S_FIFO_WRITE_L_subreg_t;
    PS_2_I2S_FIFO_WRITE_R : PS_2_I2S_FIFO_WRITE_R_subreg_t;
    TULIP_DSP_CONTROL : TULIP_DSP_CONTROL_subreg_t;
    TULIP_DSP_USR_FIR_PROG : TULIP_DSP_USR_FIR_PROG_subreg_t;
    TULIP_DSP_LUT_PROG : TULIP_DSP_LUT_PROG_subreg_t;
    TULIP_DSP_INPUT_GAIN : TULIP_DSP_INPUT_GAIN_subreg_t;
    TULIP_DSP_OUTPUT_GAIN : TULIP_DSP_OUTPUT_GAIN_subreg_t;
    TULIP_DSP_REVERB_PROG : TULIP_DSP_REVERB_PROG_subreg_t;
    TULIP_DSP_REVERB_SCALE : TULIP_DSP_REVERB_SCALE_subreg_t;
    TULIP_DSP_REVERB_FEEDFORWARD_GAIN : TULIP_DSP_REVERB_FEEDFORWARD_GAIN_subreg_t;
    TULIP_DSP_VIBRATO_GAIN : TULIP_DSP_VIBRATO_GAIN_subreg_t;
    TULIP_DSP_VIBRATO_CHIRP_DEPTH : TULIP_DSP_VIBRATO_CHIRP_DEPTH_subreg_t;
    TULIP_DSP_VIBRATO_FREQ_DERIV : TULIP_DSP_VIBRATO_FREQ_DERIV_subreg_t;
    TULIP_DSP_VIBRATO_FREQ_OFFSET : TULIP_DSP_VIBRATO_FREQ_OFFSET_subreg_t;
    TULIP_DSP_CHORUS_GAIN : TULIP_DSP_CHORUS_GAIN_subreg_t;
    TULIP_DSP_CHORUS_AVG_DELAY : TULIP_DSP_CHORUS_AVG_DELAY_subreg_t;
    TULIP_DSP_CHORUS_LFO_DEPTH : TULIP_DSP_CHORUS_LFO_DEPTH_subreg_t;
    TULIP_DSP_CHORUS_LFO_FREQ : TULIP_DSP_CHORUS_LFO_FREQ_subreg_t;
    TULIP_DSP_WAWA_B_TAP_DATA_MSB : TULIP_DSP_WAWA_B_TAP_DATA_MSB_subreg_t;
    TULIP_DSP_WAWA_B_TAP_DATA_LSB : TULIP_DSP_WAWA_B_TAP_DATA_LSB_subreg_t;
    TULIP_DSP_WAWA_A_TAP_DATA_MSB : TULIP_DSP_WAWA_A_TAP_DATA_MSB_subreg_t;
    TULIP_DSP_WAWA_A_TAP_DATA_LSB : TULIP_DSP_WAWA_A_TAP_DATA_LSB_subreg_t;
    CONTROL_REG_wr_pulse : std_logic;
    VERSION_REG_wr_pulse : std_logic;
    I2C_CONTROL_REG_wr_pulse : std_logic;
    I2C_STATUS_REG_wr_pulse : std_logic;
    I2S_STATUS_REG_wr_pulse : std_logic;
    I2S_FIFO_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_COUNT_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_READ_L_REG_wr_pulse : std_logic;
    I2S_2_PS_FIFO_READ_R_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_COUNT_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse : std_logic;
    TULIP_DSP_CONTROL_REG_wr_pulse : std_logic;
    TULIP_DSP_STATUS_REG_wr_pulse : std_logic;
    TULIP_DSP_USR_FIR_PROG_REG_wr_pulse : std_logic;
    TULIP_DSP_LUT_PROG_REG_wr_pulse : std_logic;
    TULIP_DSP_INPUT_GAIN_REG_wr_pulse : std_logic;
    TULIP_DSP_OUTPUT_GAIN_REG_wr_pulse : std_logic;
    TULIP_DSP_REVERB_PROG_REG_wr_pulse : std_logic;
    TULIP_DSP_REVERB_SCALE_REG_wr_pulse : std_logic;
    TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_wr_pulse : std_logic;
    TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse : std_logic;
    TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse : std_logic;
    TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse : std_logic;
    TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse : std_logic;
    TULIP_DSP_CHORUS_GAIN_REG_wr_pulse : std_logic;
    TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse : std_logic;
    TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse : std_logic;
    TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse : std_logic;
    TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_wr_pulse : std_logic;
    TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse : std_logic;
    TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_wr_pulse : std_logic;
    TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse : std_logic;
    CONTROL_REG_rd_pulse : std_logic;
    VERSION_REG_rd_pulse : std_logic;
    I2C_CONTROL_REG_rd_pulse : std_logic;
    I2C_STATUS_REG_rd_pulse : std_logic;
    I2S_STATUS_REG_rd_pulse : std_logic;
    I2S_FIFO_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_COUNT_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_READ_L_REG_rd_pulse : std_logic;
    I2S_2_PS_FIFO_READ_R_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_COUNT_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse : std_logic;
    PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse : std_logic;
    TULIP_DSP_CONTROL_REG_rd_pulse : std_logic;
    TULIP_DSP_STATUS_REG_rd_pulse : std_logic;
    TULIP_DSP_USR_FIR_PROG_REG_rd_pulse : std_logic;
    TULIP_DSP_LUT_PROG_REG_rd_pulse : std_logic;
    TULIP_DSP_INPUT_GAIN_REG_rd_pulse : std_logic;
    TULIP_DSP_OUTPUT_GAIN_REG_rd_pulse : std_logic;
    TULIP_DSP_REVERB_PROG_REG_rd_pulse : std_logic;
    TULIP_DSP_REVERB_SCALE_REG_rd_pulse : std_logic;
    TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_rd_pulse : std_logic;
    TULIP_DSP_VIBRATO_GAIN_REG_rd_pulse : std_logic;
    TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_rd_pulse : std_logic;
    TULIP_DSP_VIBRATO_FREQ_DERIV_REG_rd_pulse : std_logic;
    TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_rd_pulse : std_logic;
    TULIP_DSP_CHORUS_GAIN_REG_rd_pulse : std_logic;
    TULIP_DSP_CHORUS_AVG_DELAY_REG_rd_pulse : std_logic;
    TULIP_DSP_CHORUS_LFO_DEPTH_REG_rd_pulse : std_logic;
    TULIP_DSP_CHORUS_LFO_FREQ_REG_rd_pulse : std_logic;
    TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_rd_pulse : std_logic;
    TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_rd_pulse : std_logic;
    TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_rd_pulse : std_logic;
    TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_rd_pulse : std_logic;
  end record;

  type transaction_state_t is (get_addr, load_reg, write_reg, read_reg);

end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.axil_reg_file_pkg.all;

entity axil_reg_file is
  port
  (
    s_axi_aclk    : in  std_logic;
    a_axi_aresetn : in  std_logic;

    s_VERSION_VERSION : in std_logic_vector(31 downto 0);
    s_VERSION_VERSION_v : in std_logic;

    s_I2C_STATUS_DIN_READY : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_DIN_READY_v : in std_logic;

    s_I2C_STATUS_DOUT_VALID : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_DOUT_VALID_v : in std_logic;

    s_I2C_STATUS_ACK_2 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_2_v : in std_logic;

    s_I2C_STATUS_ACK_1 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_1_v : in std_logic;

    s_I2C_STATUS_ACK_0 : in std_logic_vector(0 downto 0);
    s_I2C_STATUS_ACK_0_v : in std_logic;

    s_I2C_STATUS_REGISTER_RD_DATA : in std_logic_vector(8 downto 0);
    s_I2C_STATUS_REGISTER_RD_DATA_v : in std_logic;

    s_I2S_STATUS_ADC_ERROR : in std_logic_vector(0 downto 0);
    s_I2S_STATUS_ADC_ERROR_v : in std_logic;

    s_I2S_STATUS_DAC_ERROR : in std_logic_vector(0 downto 0);
    s_I2S_STATUS_DAC_ERROR_v : in std_logic;

    s_I2S_FIFO_FIFO_USED : in std_logic_vector(15 downto 0);
    s_I2S_FIFO_FIFO_USED_v : in std_logic;

    s_I2S_2_PS_FIFO_COUNT_FIFO_USED : in std_logic_vector(15 downto 0);
    s_I2S_2_PS_FIFO_COUNT_FIFO_USED_v : in std_logic;

    s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L : in std_logic_vector(31 downto 0);
    s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_v : in std_logic;

    s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R : in std_logic_vector(31 downto 0);
    s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_v : in std_logic;

    s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE : in std_logic_vector(15 downto 0);
    s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_v : in std_logic;

    s_TULIP_DSP_STATUS_WAWA_PROG_A_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_WAWA_PROG_A_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_WAWA_PROG_B_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_WAWA_PROG_B_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_REVERB_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_REVERB_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_REVERB_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_REVERB_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_LUT_PROG_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_LUT_PROG_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_LUT_PROG_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_LUT_PROG_READY_v : in std_logic;

    s_TULIP_DSP_STATUS_FIR_TAP_DONE : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_FIR_TAP_DONE_v : in std_logic;

    s_TULIP_DSP_STATUS_FIR_TAP_READY : in std_logic_vector(0 downto 0);
    s_TULIP_DSP_STATUS_FIR_TAP_READY_v : in std_logic;


    s_axi_awaddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_awvalid : in  std_logic;
    s_axi_awready : out std_logic;

    s_axi_wdata   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_wstrb   : in  std_logic_vector(C_REG_FILE_DATA_WIDTH/8-1 downto 0);
    s_axi_wvalid  : in  std_logic;
    s_axi_wready  : out std_logic;

    s_axi_bresp   : out std_logic_vector(1 downto 0);
    s_axi_bvalid  : out std_logic;
    s_axi_bready  : in  std_logic;

    s_axi_araddr  : in  std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
    s_axi_arvalid : in  std_logic;
    s_axi_arready : out std_logic;

    s_axi_rdata   : out std_logic_vector(C_REG_FILE_DATA_WIDTH-1 downto 0);
    s_axi_rresp   : out std_logic_vector(1 downto 0);
    s_axi_rvalid  : out std_logic;
    s_axi_rready  : in  std_logic;

    registers_out : out reg_t
  );
end entity;

architecture rtl of axil_reg_file is

  constant CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 0;
  constant VERSION_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 4;
  constant I2C_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 8;
  constant I2C_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 12;
  constant I2S_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 16;
  constant I2S_FIFO_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 20;
  constant I2S_2_PS_FIFO_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 24;
  constant I2S_2_PS_FIFO_READ_L_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 28;
  constant I2S_2_PS_FIFO_READ_R_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 32;
  constant PS_2_I2S_FIFO_COUNT_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 36;
  constant PS_2_I2S_FIFO_WRITE_L_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 40;
  constant PS_2_I2S_FIFO_WRITE_R_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 44;
  constant TULIP_DSP_CONTROL_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 48;
  constant TULIP_DSP_STATUS_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 52;
  constant TULIP_DSP_USR_FIR_PROG_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 56;
  constant TULIP_DSP_LUT_PROG_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 60;
  constant TULIP_DSP_INPUT_GAIN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 64;
  constant TULIP_DSP_OUTPUT_GAIN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 68;
  constant TULIP_DSP_REVERB_PROG_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 72;
  constant TULIP_DSP_REVERB_SCALE_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 76;
  constant TULIP_DSP_REVERB_FEEDFORWARD_GAIN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 80;
  constant TULIP_DSP_VIBRATO_GAIN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 84;
  constant TULIP_DSP_VIBRATO_CHIRP_DEPTH_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 88;
  constant TULIP_DSP_VIBRATO_FREQ_DERIV_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 92;
  constant TULIP_DSP_VIBRATO_FREQ_OFFSET_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 96;
  constant TULIP_DSP_CHORUS_GAIN_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 100;
  constant TULIP_DSP_CHORUS_AVG_DELAY_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 104;
  constant TULIP_DSP_CHORUS_LFO_DEPTH_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 108;
  constant TULIP_DSP_CHORUS_LFO_FREQ_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 112;
  constant TULIP_DSP_WAWA_B_TAP_DATA_MSB_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 116;
  constant TULIP_DSP_WAWA_B_TAP_DATA_LSB_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 120;
  constant TULIP_DSP_WAWA_A_TAP_DATA_MSB_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 124;
  constant TULIP_DSP_WAWA_A_TAP_DATA_LSB_addr : integer range 0 to 2**C_REG_FILE_ADDR_WIDTH-1 := 128;

  signal registers          : reg_t;

  signal awaddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal araddr             : std_logic_vector(C_REG_FILE_ADDR_WIDTH-1 downto 0);
  signal s_axi_awready_int  : std_logic;
  signal s_axi_wready_int   : std_logic;
  signal s_axi_rvalid_int   : std_logic;
  signal s_axi_arready_int  : std_logic;

  type wr_state_t is (init, get_addr, wr_data);
  signal wr_state : wr_state_t;
  type rd_state_t is (init, get_addr, rd_data);
  signal rd_state : rd_state_t;

begin

  registers.CONTROL.DSP_ENABLE <= registers.CONTROL_REG(4 downto 4);
  registers.CONTROL.PS_2_I2S_ENABLE <= registers.CONTROL_REG(3 downto 3);
  registers.CONTROL.I2S_2_PS_ENABLE <= registers.CONTROL_REG(2 downto 2);
  registers.CONTROL.I2S_ENABLE <= registers.CONTROL_REG(1 downto 1);
  registers.CONTROL.SW_RESETN <= registers.CONTROL_REG(0 downto 0);
  registers.I2C_CONTROL.I2C_IS_READ <= registers.I2C_CONTROL_REG(23 downto 23);
  registers.I2C_CONTROL.DEVICE_ADDRESS <= registers.I2C_CONTROL_REG(22 downto 16);
  registers.I2C_CONTROL.REGISTER_ADDRESS <= registers.I2C_CONTROL_REG(15 downto 9);
  registers.I2C_CONTROL.REGISTER_WR_DATA <= registers.I2C_CONTROL_REG(8 downto 0);
  registers.PS_2_I2S_FIFO_WRITE_L.FIFO_VALUE_L <= registers.PS_2_I2S_FIFO_WRITE_L_REG(31 downto 0);
  registers.PS_2_I2S_FIFO_WRITE_R.FIFO_VALUE_R <= registers.PS_2_I2S_FIFO_WRITE_R_REG(31 downto 0);
  registers.TULIP_DSP_CONTROL.SW_RESETN_WAWA <= registers.TULIP_DSP_CONTROL_REG(13 downto 13);
  registers.TULIP_DSP_CONTROL.BYPASS_WAWA <= registers.TULIP_DSP_CONTROL_REG(12 downto 12);
  registers.TULIP_DSP_CONTROL.SW_RESETN_CHORUS <= registers.TULIP_DSP_CONTROL_REG(10 downto 10);
  registers.TULIP_DSP_CONTROL.BYPASS_CHORUS <= registers.TULIP_DSP_CONTROL_REG(11 downto 11);
  registers.TULIP_DSP_CONTROL.SW_RESETN_VIBRATO <= registers.TULIP_DSP_CONTROL_REG(8 downto 8);
  registers.TULIP_DSP_CONTROL.BYPASS_VIBRATO <= registers.TULIP_DSP_CONTROL_REG(9 downto 9);
  registers.TULIP_DSP_CONTROL.SW_RESETN_USR_FIR <= registers.TULIP_DSP_CONTROL_REG(7 downto 7);
  registers.TULIP_DSP_CONTROL.BYPASS_USR_FIR <= registers.TULIP_DSP_CONTROL_REG(4 downto 4);
  registers.TULIP_DSP_CONTROL.SW_RESETN_LUT_TF <= registers.TULIP_DSP_CONTROL_REG(6 downto 6);
  registers.TULIP_DSP_CONTROL.BYPASS_LUT_TF <= registers.TULIP_DSP_CONTROL_REG(3 downto 3);
  registers.TULIP_DSP_CONTROL.SW_RESETN_REVERB <= registers.TULIP_DSP_CONTROL_REG(5 downto 5);
  registers.TULIP_DSP_CONTROL.BYPASS_REVERB <= registers.TULIP_DSP_CONTROL_REG(2 downto 2);
  registers.TULIP_DSP_CONTROL.SYMMETRIC_MODE <= registers.TULIP_DSP_CONTROL_REG(1 downto 1);
  registers.TULIP_DSP_CONTROL.BYPASS <= registers.TULIP_DSP_CONTROL_REG(0 downto 0);
  registers.TULIP_DSP_USR_FIR_PROG.FIR_TAP_VALUE <= registers.TULIP_DSP_USR_FIR_PROG_REG(15 downto 0);
  registers.TULIP_DSP_LUT_PROG.LUT_PROG_VAL <= registers.TULIP_DSP_LUT_PROG_REG(23 downto 0);
  registers.TULIP_DSP_INPUT_GAIN.INTEGER_BITS <= registers.TULIP_DSP_INPUT_GAIN_REG(31 downto 16);
  registers.TULIP_DSP_INPUT_GAIN.DECIMAL_BITS <= registers.TULIP_DSP_INPUT_GAIN_REG(15 downto 0);
  registers.TULIP_DSP_OUTPUT_GAIN.INTEGER_BITS <= registers.TULIP_DSP_OUTPUT_GAIN_REG(31 downto 16);
  registers.TULIP_DSP_OUTPUT_GAIN.DECIMAL_BITS <= registers.TULIP_DSP_OUTPUT_GAIN_REG(15 downto 0);
  registers.TULIP_DSP_REVERB_PROG.REVERB_TAP_VALUE <= registers.TULIP_DSP_REVERB_PROG_REG(15 downto 0);
  registers.TULIP_DSP_REVERB_SCALE.FEEDBACK_RIGHT_SHIFT <= registers.TULIP_DSP_REVERB_SCALE_REG(23 downto 16);
  registers.TULIP_DSP_REVERB_SCALE.FEEDBACK_GAIN <= registers.TULIP_DSP_REVERB_SCALE_REG(15 downto 0);
  registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN.FEEDFORWARD_GAIN <= registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG(15 downto 0);
  registers.TULIP_DSP_VIBRATO_GAIN.GAIN <= registers.TULIP_DSP_VIBRATO_GAIN_REG(23 downto 0);
  registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH.CHIRP_DEPTH <= registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG(31 downto 0);
  registers.TULIP_DSP_VIBRATO_FREQ_DERIV.FREQ_DERIV <= registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG(31 downto 0);
  registers.TULIP_DSP_VIBRATO_FREQ_OFFSET.FREQ_OFFSET <= registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG(31 downto 0);
  registers.TULIP_DSP_CHORUS_GAIN.GAIN <= registers.TULIP_DSP_CHORUS_GAIN_REG(23 downto 0);
  registers.TULIP_DSP_CHORUS_AVG_DELAY.AVG_DELAY <= registers.TULIP_DSP_CHORUS_AVG_DELAY_REG(11 downto 0);
  registers.TULIP_DSP_CHORUS_LFO_DEPTH.LFO_DEPTH <= registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG(11 downto 0);
  registers.TULIP_DSP_CHORUS_LFO_FREQ.LFO_FREQ <= registers.TULIP_DSP_CHORUS_LFO_FREQ_REG(31 downto 0);
  registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB.DATA <= registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG(31 downto 0);
  registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB.DATA <= registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG(31 downto 0);
  registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB.DATA <= registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG(31 downto 0);
  registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB.DATA <= registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG(31 downto 0);

  registers_out <= registers;

  s_axi_rresp   <= (others => '0');
  s_axi_bresp   <= (others => '0');
  s_axi_bvalid  <= '1';

  s_axi_awready <= s_axi_awready_int;
  s_axi_wready  <= s_axi_wready_int;

  p_read_only_regs : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.VERSION_REG <= x"0000004A";
        registers.I2C_STATUS_REG <= x"00000000";
        registers.I2S_STATUS_REG <= x"00000000";
        registers.I2S_FIFO_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_COUNT_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_READ_L_REG <= x"00000000";
        registers.I2S_2_PS_FIFO_READ_R_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_COUNT_REG <= x"00000000";
        registers.TULIP_DSP_STATUS_REG <= x"00000000";
      else
        if s_VERSION_VERSION_v = '1' then 
          registers.VERSION_REG(31 downto 0) <= s_VERSION_VERSION;
        end if;
        if s_I2C_STATUS_DIN_READY_v = '1' then 
          registers.I2C_STATUS_REG(13 downto 13) <= s_I2C_STATUS_DIN_READY;
        end if;
        if s_I2C_STATUS_DOUT_VALID_v = '1' then 
          registers.I2C_STATUS_REG(12 downto 12) <= s_I2C_STATUS_DOUT_VALID;
        end if;
        if s_I2C_STATUS_ACK_2_v = '1' then 
          registers.I2C_STATUS_REG(11 downto 11) <= s_I2C_STATUS_ACK_2;
        end if;
        if s_I2C_STATUS_ACK_1_v = '1' then 
          registers.I2C_STATUS_REG(10 downto 10) <= s_I2C_STATUS_ACK_1;
        end if;
        if s_I2C_STATUS_ACK_0_v = '1' then 
          registers.I2C_STATUS_REG(9 downto 9) <= s_I2C_STATUS_ACK_0;
        end if;
        if s_I2C_STATUS_REGISTER_RD_DATA_v = '1' then 
          registers.I2C_STATUS_REG(8 downto 0) <= s_I2C_STATUS_REGISTER_RD_DATA;
        end if;
        if s_I2S_STATUS_ADC_ERROR_v = '1' then 
          registers.I2S_STATUS_REG(0 downto 0) <= s_I2S_STATUS_ADC_ERROR;
        end if;
        if s_I2S_STATUS_DAC_ERROR_v = '1' then 
          registers.I2S_STATUS_REG(1 downto 1) <= s_I2S_STATUS_DAC_ERROR;
        end if;
        if s_I2S_FIFO_FIFO_USED_v = '1' then 
          registers.I2S_FIFO_REG(15 downto 0) <= s_I2S_FIFO_FIFO_USED;
        end if;
        if s_I2S_2_PS_FIFO_COUNT_FIFO_USED_v = '1' then 
          registers.I2S_2_PS_FIFO_COUNT_REG(15 downto 0) <= s_I2S_2_PS_FIFO_COUNT_FIFO_USED;
        end if;
        if s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_v = '1' then 
          registers.I2S_2_PS_FIFO_READ_L_REG(31 downto 0) <= s_I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L;
        end if;
        if s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_v = '1' then 
          registers.I2S_2_PS_FIFO_READ_R_REG(31 downto 0) <= s_I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R;
        end if;
        if s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_v = '1' then 
          registers.PS_2_I2S_FIFO_COUNT_REG(15 downto 0) <= s_PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE;
        end if;
        if s_TULIP_DSP_STATUS_WAWA_PROG_A_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(25 downto 25) <= s_TULIP_DSP_STATUS_WAWA_PROG_A_READY;
        end if;
        if s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(24 downto 24) <= s_TULIP_DSP_STATUS_WAWA_PROG_A_DONE;
        end if;
        if s_TULIP_DSP_STATUS_WAWA_PROG_B_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(23 downto 23) <= s_TULIP_DSP_STATUS_WAWA_PROG_B_READY;
        end if;
        if s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(22 downto 22) <= s_TULIP_DSP_STATUS_WAWA_PROG_B_DONE;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(21 downto 21) <= s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(20 downto 20) <= s_TULIP_DSP_STATUS_CHORUS_LFO_FREQ_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(19 downto 19) <= s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(18 downto 18) <= s_TULIP_DSP_STATUS_CHORUS_LFO_DEPTH_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(17 downto 17) <= s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(16 downto 16) <= s_TULIP_DSP_STATUS_CHORUS_AVG_DELAY_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(15 downto 15) <= s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(14 downto 14) <= s_TULIP_DSP_STATUS_CHORUS_GAIN_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(13 downto 13) <= s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(12 downto 12) <= s_TULIP_DSP_STATUS_VIBRATO_FREQ_OFFSET_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(11 downto 11) <= s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(10 downto 10) <= s_TULIP_DSP_STATUS_VIBRATO_FREQ_DERIV_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(9 downto 9) <= s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(8 downto 8) <= s_TULIP_DSP_STATUS_VIBRATO_CHIRP_DEPTH_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(7 downto 7) <= s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(6 downto 6) <= s_TULIP_DSP_STATUS_VIBRATO_GAIN_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_REVERB_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(5 downto 5) <= s_TULIP_DSP_STATUS_REVERB_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_REVERB_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(4 downto 4) <= s_TULIP_DSP_STATUS_REVERB_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_LUT_PROG_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(3 downto 3) <= s_TULIP_DSP_STATUS_LUT_PROG_DONE;
        end if;
        if s_TULIP_DSP_STATUS_LUT_PROG_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(2 downto 2) <= s_TULIP_DSP_STATUS_LUT_PROG_READY;
        end if;
        if s_TULIP_DSP_STATUS_FIR_TAP_DONE_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(1 downto 1) <= s_TULIP_DSP_STATUS_FIR_TAP_DONE;
        end if;
        if s_TULIP_DSP_STATUS_FIR_TAP_READY_v = '1' then 
          registers.TULIP_DSP_STATUS_REG(0 downto 0) <= s_TULIP_DSP_STATUS_FIR_TAP_READY;
        end if;
      end if;
    end if;
  end process;

  p_wr_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        registers.CONTROL_REG <= x"00000000";
        registers.I2C_CONTROL_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_WRITE_L_REG <= x"00000000";
        registers.PS_2_I2S_FIFO_WRITE_R_REG <= x"00000000";
        registers.TULIP_DSP_CONTROL_REG <= x"00000000";
        registers.TULIP_DSP_USR_FIR_PROG_REG <= x"00000000";
        registers.TULIP_DSP_LUT_PROG_REG <= x"00000000";
        registers.TULIP_DSP_INPUT_GAIN_REG <= x"00010000";
        registers.TULIP_DSP_OUTPUT_GAIN_REG <= x"00010000";
        registers.TULIP_DSP_REVERB_PROG_REG <= x"00000000";
        registers.TULIP_DSP_REVERB_SCALE_REG <= x"00000000";
        registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG <= x"00000000";
        registers.TULIP_DSP_VIBRATO_GAIN_REG <= x"00000000";
        registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG <= x"00000000";
        registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG <= x"00000000";
        registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG <= x"00000000";
        registers.TULIP_DSP_CHORUS_GAIN_REG <= x"00000000";
        registers.TULIP_DSP_CHORUS_AVG_DELAY_REG <= x"00000000";
        registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG <= x"00000000";
        registers.TULIP_DSP_CHORUS_LFO_FREQ_REG <= x"00000000";
        registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG <= x"00000000";
        registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG <= x"00000000";
        registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG <= x"00000000";
        registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG <= x"00000000";
        awaddr            <= (others => '0');
        registers.CONTROL_REG_wr_pulse <= '0';
        registers.VERSION_REG_wr_pulse <= '0';
        registers.I2C_CONTROL_REG_wr_pulse <= '0';
        registers.I2C_STATUS_REG_wr_pulse <= '0';
        registers.I2S_STATUS_REG_wr_pulse <= '0';
        registers.I2S_FIFO_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
        registers.TULIP_DSP_CONTROL_REG_wr_pulse <= '0';
        registers.TULIP_DSP_STATUS_REG_wr_pulse <= '0';
        registers.TULIP_DSP_USR_FIR_PROG_REG_wr_pulse <= '0';
        registers.TULIP_DSP_LUT_PROG_REG_wr_pulse <= '0';
        registers.TULIP_DSP_INPUT_GAIN_REG_wr_pulse <= '0';
        registers.TULIP_DSP_OUTPUT_GAIN_REG_wr_pulse <= '0';
        registers.TULIP_DSP_REVERB_PROG_REG_wr_pulse <= '0';
        registers.TULIP_DSP_REVERB_SCALE_REG_wr_pulse <= '0';
        registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_wr_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse <= '0';
        registers.TULIP_DSP_CHORUS_GAIN_REG_wr_pulse <= '0';
        registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse <= '0';
        registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse <= '0';
        registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse <= '0';
        registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_wr_pulse <= '0';
        registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse <= '0';
        registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_wr_pulse <= '0';
        registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse <= '0';
        s_axi_awready_int <= '0';
        s_axi_wready_int  <= '0';
        wr_state          <= init;
      else
        case wr_state is
          when init =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.VERSION_REG_wr_pulse <= '0';
            registers.I2C_CONTROL_REG_wr_pulse <= '0';
            registers.I2C_STATUS_REG_wr_pulse <= '0';
            registers.I2S_STATUS_REG_wr_pulse <= '0';
            registers.I2S_FIFO_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CONTROL_REG_wr_pulse <= '0';
            registers.TULIP_DSP_STATUS_REG_wr_pulse <= '0';
            registers.TULIP_DSP_USR_FIR_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_LUT_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_INPUT_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_OUTPUT_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_SCALE_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse <= '0';
            s_axi_awready_int <= '1';
            s_axi_wready_int  <= '0';
            awaddr            <= (others => '0');
            wr_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_wr_pulse <= '0';
            registers.VERSION_REG_wr_pulse <= '0';
            registers.I2C_CONTROL_REG_wr_pulse <= '0';
            registers.I2C_STATUS_REG_wr_pulse <= '0';
            registers.I2S_STATUS_REG_wr_pulse <= '0';
            registers.I2S_FIFO_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_wr_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CONTROL_REG_wr_pulse <= '0';
            registers.TULIP_DSP_STATUS_REG_wr_pulse <= '0';
            registers.TULIP_DSP_USR_FIR_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_LUT_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_INPUT_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_OUTPUT_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_PROG_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_SCALE_REG_wr_pulse <= '0';
            registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_GAIN_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_wr_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse <= '0';
            if s_axi_awvalid = '1' and s_axi_awready_int = '1' then
              s_axi_awready_int <= '0';
              s_axi_wready_int  <= '1';
              awaddr            <= s_axi_awaddr;
              wr_state          <= wr_data;
            end if;

          when wr_data =>

            if s_axi_wvalid = '1' and s_axi_wready_int = '1' then
              case awaddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG <= s_axi_wdata;
                  registers.CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_CONTROL_REG <= s_axi_wdata;
                  registers.I2C_CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_L_REG <= s_axi_wdata;
                  registers.PS_2_I2S_FIFO_WRITE_L_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_R_REG <= s_axi_wdata;
                  registers.PS_2_I2S_FIFO_WRITE_R_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CONTROL_REG <= s_axi_wdata;
                  registers.TULIP_DSP_CONTROL_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_USR_FIR_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_USR_FIR_PROG_REG <= s_axi_wdata;
                  registers.TULIP_DSP_USR_FIR_PROG_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_LUT_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_LUT_PROG_REG <= s_axi_wdata;
                  registers.TULIP_DSP_LUT_PROG_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_INPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_INPUT_GAIN_REG <= s_axi_wdata;
                  registers.TULIP_DSP_INPUT_GAIN_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_OUTPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_OUTPUT_GAIN_REG <= s_axi_wdata;
                  registers.TULIP_DSP_OUTPUT_GAIN_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_PROG_REG <= s_axi_wdata;
                  registers.TULIP_DSP_REVERB_PROG_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_SCALE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_SCALE_REG <= s_axi_wdata;
                  registers.TULIP_DSP_REVERB_SCALE_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_FEEDFORWARD_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG <= s_axi_wdata;
                  registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_GAIN_REG <= s_axi_wdata;
                  registers.TULIP_DSP_VIBRATO_GAIN_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_CHIRP_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG <= s_axi_wdata;
                  registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_DERIV_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG <= s_axi_wdata;
                  registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_OFFSET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG <= s_axi_wdata;
                  registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_GAIN_REG <= s_axi_wdata;
                  registers.TULIP_DSP_CHORUS_GAIN_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_AVG_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_AVG_DELAY_REG <= s_axi_wdata;
                  registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG <= s_axi_wdata;
                  registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_FREQ_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_LFO_FREQ_REG <= s_axi_wdata;
                  registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG <= s_axi_wdata;
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG <= s_axi_wdata;
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG <= s_axi_wdata;
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_wr_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG <= s_axi_wdata;
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_wr_pulse <= '1';
                when others =>
                  null;
              end case;

              s_axi_awready_int <= '1';
              s_axi_wready_int  <= '0';
              wr_state          <= get_addr;
            end if;

          when others =>
            wr_state <= init;

        end case;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------

  s_axi_arready     <= s_axi_arready_int;
  s_axi_rvalid      <= s_axi_rvalid_int;

  p_rd_state_machine : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if a_axi_aresetn = '0' then
        araddr            <= (others => '0');
        s_axi_rdata       <= (others => '0');
        registers.CONTROL_REG_rd_pulse <= '0';
        registers.VERSION_REG_rd_pulse <= '0';
        registers.I2C_CONTROL_REG_rd_pulse <= '0';
        registers.I2C_STATUS_REG_rd_pulse <= '0';
        registers.I2S_STATUS_REG_rd_pulse <= '0';
        registers.I2S_FIFO_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
        registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
        registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
        registers.TULIP_DSP_CONTROL_REG_rd_pulse <= '0';
        registers.TULIP_DSP_STATUS_REG_rd_pulse <= '0';
        registers.TULIP_DSP_USR_FIR_PROG_REG_rd_pulse <= '0';
        registers.TULIP_DSP_LUT_PROG_REG_rd_pulse <= '0';
        registers.TULIP_DSP_INPUT_GAIN_REG_rd_pulse <= '0';
        registers.TULIP_DSP_OUTPUT_GAIN_REG_rd_pulse <= '0';
        registers.TULIP_DSP_REVERB_PROG_REG_rd_pulse <= '0';
        registers.TULIP_DSP_REVERB_SCALE_REG_rd_pulse <= '0';
        registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_rd_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_GAIN_REG_rd_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_rd_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_rd_pulse <= '0';
        registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_rd_pulse <= '0';
        registers.TULIP_DSP_CHORUS_GAIN_REG_rd_pulse <= '0';
        registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_rd_pulse <= '0';
        registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_rd_pulse <= '0';
        registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_rd_pulse <= '0';
        registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_rd_pulse <= '0';
        registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_rd_pulse <= '0';
        registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_rd_pulse <= '0';
        registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_rd_pulse <= '0';
        s_axi_arready_int <= '0';
        s_axi_rvalid_int  <= '0';
        rd_state          <= init;
      else
        case rd_state is
          when init =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.VERSION_REG_rd_pulse <= '0';
            registers.I2C_CONTROL_REG_rd_pulse <= '0';
            registers.I2C_STATUS_REG_rd_pulse <= '0';
            registers.I2S_STATUS_REG_rd_pulse <= '0';
            registers.I2S_FIFO_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CONTROL_REG_rd_pulse <= '0';
            registers.TULIP_DSP_STATUS_REG_rd_pulse <= '0';
            registers.TULIP_DSP_USR_FIR_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_LUT_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_INPUT_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_OUTPUT_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_SCALE_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_rd_pulse <= '0';
            s_axi_arready_int <= '1';
            s_axi_rvalid_int  <= '0';
            araddr            <= (others => '0');
            rd_state          <= get_addr;

          when get_addr =>
            registers.CONTROL_REG_rd_pulse <= '0';
            registers.VERSION_REG_rd_pulse <= '0';
            registers.I2C_CONTROL_REG_rd_pulse <= '0';
            registers.I2C_STATUS_REG_rd_pulse <= '0';
            registers.I2S_STATUS_REG_rd_pulse <= '0';
            registers.I2S_FIFO_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '0';
            registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '0';
            registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CONTROL_REG_rd_pulse <= '0';
            registers.TULIP_DSP_STATUS_REG_rd_pulse <= '0';
            registers.TULIP_DSP_USR_FIR_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_LUT_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_INPUT_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_OUTPUT_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_PROG_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_SCALE_REG_rd_pulse <= '0';
            registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_rd_pulse <= '0';
            registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_GAIN_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_rd_pulse <= '0';
            registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_rd_pulse <= '0';
            registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_rd_pulse <= '0';
            if s_axi_arvalid = '1' and s_axi_arready_int = '1' then
              s_axi_arready_int <= '0';
              s_axi_rvalid_int  <= '0';
              araddr            <= s_axi_araddr;
              rd_state          <= rd_data;
            end if;

          when rd_data =>
            case araddr is
              when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.CONTROL_REG;
              when std_logic_vector(to_unsigned(VERSION_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.VERSION_REG;
              when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2C_CONTROL_REG;
              when std_logic_vector(to_unsigned(I2C_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2C_STATUS_REG;
              when std_logic_vector(to_unsigned(I2S_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_STATUS_REG;
              when std_logic_vector(to_unsigned(I2S_FIFO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_FIFO_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_COUNT_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_READ_L_REG;
              when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.I2S_2_PS_FIFO_READ_R_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_COUNT_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_WRITE_L_REG;
              when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.PS_2_I2S_FIFO_WRITE_R_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_CONTROL_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_STATUS_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_USR_FIR_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_USR_FIR_PROG_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_LUT_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_LUT_PROG_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_INPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_INPUT_GAIN_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_OUTPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_OUTPUT_GAIN_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_REVERB_PROG_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_SCALE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_REVERB_SCALE_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_FEEDFORWARD_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_VIBRATO_GAIN_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_CHIRP_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_DERIV_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_OFFSET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_CHORUS_GAIN_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_AVG_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_CHORUS_AVG_DELAY_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_FREQ_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_CHORUS_LFO_FREQ_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG;
              when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                s_axi_rdata <= registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG;
              when others =>
                null;
            end case;

            if s_axi_rvalid_int = '1' and s_axi_rready = '1' then
              case araddr is
                when std_logic_vector(to_unsigned(CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(VERSION_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.VERSION_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2C_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2C_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2C_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_FIFO_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_FIFO_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_COUNT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_READ_L_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(I2S_2_PS_FIFO_READ_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.I2S_2_PS_FIFO_READ_R_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_COUNT_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_COUNT_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_L_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_L_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(PS_2_I2S_FIFO_WRITE_R_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.PS_2_I2S_FIFO_WRITE_R_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CONTROL_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CONTROL_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_STATUS_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_STATUS_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_USR_FIR_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_USR_FIR_PROG_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_LUT_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_LUT_PROG_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_INPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_INPUT_GAIN_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_OUTPUT_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_OUTPUT_GAIN_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_PROG_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_PROG_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_SCALE_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_SCALE_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_REVERB_FEEDFORWARD_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_REVERB_FEEDFORWARD_GAIN_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_GAIN_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_CHIRP_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_CHIRP_DEPTH_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_DERIV_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_FREQ_DERIV_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_VIBRATO_FREQ_OFFSET_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_VIBRATO_FREQ_OFFSET_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_GAIN_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_GAIN_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_AVG_DELAY_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_AVG_DELAY_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_DEPTH_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_LFO_DEPTH_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_CHORUS_LFO_FREQ_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_CHORUS_LFO_FREQ_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_MSB_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_B_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_B_TAP_DATA_LSB_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_MSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_MSB_REG_rd_pulse <= '1';
                when std_logic_vector(to_unsigned(TULIP_DSP_WAWA_A_TAP_DATA_LSB_addr, C_REG_FILE_ADDR_WIDTH)) =>
                  registers.TULIP_DSP_WAWA_A_TAP_DATA_LSB_REG_rd_pulse <= '1';
                when others =>
                  null;
              end case;
              s_axi_arready_int <= '1';
              s_axi_rvalid_int  <= '0';
              rd_state          <= get_addr;
            else
              s_axi_rvalid_int  <= '1';
            end if;

          when others =>
            rd_state <= init;

        end case;
      end if;
    end if;
  end process;

end rtl;
