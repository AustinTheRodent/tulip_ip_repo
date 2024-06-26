#ifndef KR260_TULIP_REGISTERS_H
#define KR260_TULIP_REGISTERS_H

#define CONTROL 0x0
#define VERSION 0x4
#define I2C_CONTROL 0x8
#define I2C_STATUS 0xC
#define I2S_STATUS 0x10
#define I2S_FIFO 0x14
#define I2S_2_PS_FIFO_COUNT 0x18
#define I2S_2_PS_FIFO_READ_L 0x1C
#define I2S_2_PS_FIFO_READ_R 0x20
#define PS_2_I2S_FIFO_COUNT 0x24
#define PS_2_I2S_FIFO_WRITE_L 0x28
#define PS_2_I2S_FIFO_WRITE_R 0x2C
#define TULIP_DSP_CONTROL 0x30
#define TULIP_DSP_STATUS 0x34
#define TULIP_DSP_USR_FIR_PROG 0x38
#define TULIP_DSP_LUT_PROG 0x3C
#define TULIP_DSP_INPUT_GAIN 0x40
#define TULIP_DSP_OUTPUT_GAIN 0x44
#define TULIP_DSP_REVERB_PROG 0x48
#define TULIP_DSP_REVERB_SCALE 0x4C
#define TULIP_DSP_REVERB_FEEDFORWARD_GAIN 0x50

#define CONTROL_DSP_ENABLE_MASK 0x1
#define CONTROL_DSP_ENABLE_SHIFT 4
#define CONTROL_DSP_ENABLE (0x10)
#define CONTROL_PS_2_I2S_ENABLE_MASK 0x1
#define CONTROL_PS_2_I2S_ENABLE_SHIFT 3
#define CONTROL_PS_2_I2S_ENABLE (0x8)
#define CONTROL_I2S_2_PS_ENABLE_MASK 0x1
#define CONTROL_I2S_2_PS_ENABLE_SHIFT 2
#define CONTROL_I2S_2_PS_ENABLE (0x4)
#define CONTROL_I2S_ENABLE_MASK 0x1
#define CONTROL_I2S_ENABLE_SHIFT 1
#define CONTROL_I2S_ENABLE (0x2)
#define CONTROL_SW_RESETN_MASK 0x1
#define CONTROL_SW_RESETN_SHIFT 0
#define CONTROL_SW_RESETN (0x1)

#define VERSION_VERSION_MASK 0xFFFFFFFF
#define VERSION_VERSION_SHIFT 0

#define I2C_CONTROL_I2C_IS_READ_MASK 0x1
#define I2C_CONTROL_I2C_IS_READ_SHIFT 23
#define I2C_CONTROL_I2C_IS_READ (0x800000)
#define I2C_CONTROL_DEVICE_ADDRESS_MASK 0x7F
#define I2C_CONTROL_DEVICE_ADDRESS_SHIFT 16
#define I2C_CONTROL_REGISTER_ADDRESS_MASK 0x7F
#define I2C_CONTROL_REGISTER_ADDRESS_SHIFT 9
#define I2C_CONTROL_REGISTER_WR_DATA_MASK 0x1FF
#define I2C_CONTROL_REGISTER_WR_DATA_SHIFT 0

#define I2C_STATUS_DIN_READY_MASK 0x1
#define I2C_STATUS_DIN_READY_SHIFT 13
#define I2C_STATUS_DIN_READY (0x2000)
#define I2C_STATUS_DOUT_VALID_MASK 0x1
#define I2C_STATUS_DOUT_VALID_SHIFT 12
#define I2C_STATUS_DOUT_VALID (0x1000)
#define I2C_STATUS_ACK_2_MASK 0x1
#define I2C_STATUS_ACK_2_SHIFT 11
#define I2C_STATUS_ACK_2 (0x800)
#define I2C_STATUS_ACK_1_MASK 0x1
#define I2C_STATUS_ACK_1_SHIFT 10
#define I2C_STATUS_ACK_1 (0x400)
#define I2C_STATUS_ACK_0_MASK 0x1
#define I2C_STATUS_ACK_0_SHIFT 9
#define I2C_STATUS_ACK_0 (0x200)
#define I2C_STATUS_REGISTER_RD_DATA_MASK 0x1FF
#define I2C_STATUS_REGISTER_RD_DATA_SHIFT 0

#define I2S_STATUS_ADC_ERROR_MASK 0x1
#define I2S_STATUS_ADC_ERROR_SHIFT 0
#define I2S_STATUS_ADC_ERROR (0x1)
#define I2S_STATUS_DAC_ERROR_MASK 0x1
#define I2S_STATUS_DAC_ERROR_SHIFT 1
#define I2S_STATUS_DAC_ERROR (0x2)

#define I2S_FIFO_FIFO_USED_MASK 0xFFFF
#define I2S_FIFO_FIFO_USED_SHIFT 0

#define I2S_2_PS_FIFO_COUNT_FIFO_USED_MASK 0xFFFF
#define I2S_2_PS_FIFO_COUNT_FIFO_USED_SHIFT 0

#define I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_MASK 0xFFFFFFFF
#define I2S_2_PS_FIFO_READ_L_FIFO_VALUE_L_SHIFT 0

#define I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_MASK 0xFFFFFFFF
#define I2S_2_PS_FIFO_READ_R_FIFO_VALUE_R_SHIFT 0

#define PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_MASK 0xFFFF
#define PS_2_I2S_FIFO_COUNT_FIFO_AVAILABLE_SHIFT 0

#define PS_2_I2S_FIFO_WRITE_L_FIFO_VALUE_L_MASK 0xFFFFFFFF
#define PS_2_I2S_FIFO_WRITE_L_FIFO_VALUE_L_SHIFT 0

#define PS_2_I2S_FIFO_WRITE_R_FIFO_VALUE_R_MASK 0xFFFFFFFF
#define PS_2_I2S_FIFO_WRITE_R_FIFO_VALUE_R_SHIFT 0

#define TULIP_DSP_CONTROL_SW_RESETN_USR_FIR_MASK 0x1
#define TULIP_DSP_CONTROL_SW_RESETN_USR_FIR_SHIFT 7
#define TULIP_DSP_CONTROL_SW_RESETN_USR_FIR (0x80)
#define TULIP_DSP_CONTROL_SW_RESETN_LUT_TF_MASK 0x1
#define TULIP_DSP_CONTROL_SW_RESETN_LUT_TF_SHIFT 6
#define TULIP_DSP_CONTROL_SW_RESETN_LUT_TF (0x40)
#define TULIP_DSP_CONTROL_SW_RESETN_REVERB_MASK 0x1
#define TULIP_DSP_CONTROL_SW_RESETN_REVERB_SHIFT 5
#define TULIP_DSP_CONTROL_SW_RESETN_REVERB (0x20)
#define TULIP_DSP_CONTROL_BYPASS_USR_FIR_MASK 0x1
#define TULIP_DSP_CONTROL_BYPASS_USR_FIR_SHIFT 4
#define TULIP_DSP_CONTROL_BYPASS_USR_FIR (0x10)
#define TULIP_DSP_CONTROL_BYPASS_LUT_TF_MASK 0x1
#define TULIP_DSP_CONTROL_BYPASS_LUT_TF_SHIFT 3
#define TULIP_DSP_CONTROL_BYPASS_LUT_TF (0x8)
#define TULIP_DSP_CONTROL_BYPASS_REVERB_MASK 0x1
#define TULIP_DSP_CONTROL_BYPASS_REVERB_SHIFT 2
#define TULIP_DSP_CONTROL_BYPASS_REVERB (0x4)
#define TULIP_DSP_CONTROL_SYMMETRIC_MODE_MASK 0x1
#define TULIP_DSP_CONTROL_SYMMETRIC_MODE_SHIFT 1
#define TULIP_DSP_CONTROL_SYMMETRIC_MODE (0x2)
#define TULIP_DSP_CONTROL_BYPASS_MASK 0x1
#define TULIP_DSP_CONTROL_BYPASS_SHIFT 0
#define TULIP_DSP_CONTROL_BYPASS (0x1)

#define TULIP_DSP_STATUS_REVERB_PROG_DONE_MASK 0x1
#define TULIP_DSP_STATUS_REVERB_PROG_DONE_SHIFT 5
#define TULIP_DSP_STATUS_REVERB_PROG_DONE (0x20)
#define TULIP_DSP_STATUS_REVERB_PROG_READY_MASK 0x1
#define TULIP_DSP_STATUS_REVERB_PROG_READY_SHIFT 4
#define TULIP_DSP_STATUS_REVERB_PROG_READY (0x10)
#define TULIP_DSP_STATUS_LUT_PROG_DONE_MASK 0x1
#define TULIP_DSP_STATUS_LUT_PROG_DONE_SHIFT 3
#define TULIP_DSP_STATUS_LUT_PROG_DONE (0x8)
#define TULIP_DSP_STATUS_LUT_PROG_READY_MASK 0x1
#define TULIP_DSP_STATUS_LUT_PROG_READY_SHIFT 2
#define TULIP_DSP_STATUS_LUT_PROG_READY (0x4)
#define TULIP_DSP_STATUS_FIR_TAP_DONE_MASK 0x1
#define TULIP_DSP_STATUS_FIR_TAP_DONE_SHIFT 1
#define TULIP_DSP_STATUS_FIR_TAP_DONE (0x2)
#define TULIP_DSP_STATUS_FIR_TAP_READY_MASK 0x1
#define TULIP_DSP_STATUS_FIR_TAP_READY_SHIFT 0
#define TULIP_DSP_STATUS_FIR_TAP_READY (0x1)

#define TULIP_DSP_USR_FIR_PROG_FIR_TAP_VALUE_MASK 0xFFFF
#define TULIP_DSP_USR_FIR_PROG_FIR_TAP_VALUE_SHIFT 0

#define TULIP_DSP_LUT_PROG_LUT_PROG_VAL_MASK 0xFFFFFF
#define TULIP_DSP_LUT_PROG_LUT_PROG_VAL_SHIFT 0

#define TULIP_DSP_INPUT_GAIN_INTEGER_BITS_MASK 0xFFFF
#define TULIP_DSP_INPUT_GAIN_INTEGER_BITS_SHIFT 16
#define TULIP_DSP_INPUT_GAIN_DECIMAL_BITS_MASK 0xFFFF
#define TULIP_DSP_INPUT_GAIN_DECIMAL_BITS_SHIFT 0

#define TULIP_DSP_OUTPUT_GAIN_INTEGER_BITS_MASK 0xFFFF
#define TULIP_DSP_OUTPUT_GAIN_INTEGER_BITS_SHIFT 16
#define TULIP_DSP_OUTPUT_GAIN_DECIMAL_BITS_MASK 0xFFFF
#define TULIP_DSP_OUTPUT_GAIN_DECIMAL_BITS_SHIFT 0

#define TULIP_DSP_REVERB_PROG_REVERB_TAP_VALUE_MASK 0xFFFF
#define TULIP_DSP_REVERB_PROG_REVERB_TAP_VALUE_SHIFT 0

#define TULIP_DSP_REVERB_SCALE_FEEDBACK_RIGHT_SHIFT_MASK 0xFF
#define TULIP_DSP_REVERB_SCALE_FEEDBACK_RIGHT_SHIFT_SHIFT 16
#define TULIP_DSP_REVERB_SCALE_FEEDBACK_GAIN_MASK 0xFFFF
#define TULIP_DSP_REVERB_SCALE_FEEDBACK_GAIN_SHIFT 0

#define TULIP_DSP_REVERB_FEEDFORWARD_GAIN_FEEDFORWARD_GAIN_MASK 0xFFFF
#define TULIP_DSP_REVERB_FEEDFORWARD_GAIN_FEEDFORWARD_GAIN_SHIFT 0

#endif
