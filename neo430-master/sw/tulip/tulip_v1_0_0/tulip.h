// Libraries
#include <stdint.h>
#include <neo430.h>
#include <math.h>
#include <stdbool.h>

// GPIO in:
#define REG_RW_READY 0 // in_gpio[0] for RW_READY feedback
#define BUTTON_UP 1
#define BUTTON_DN 2
#define BUTTON_L 3
#define BUTTON_LL 4
#define BUTTON_R 5
#define BUTTON_RR 6

// GPIO out:
#define REG_TRANSACTION_ENABLE 0
#define REG_RW 1
#define TULIP_RESET 2

// SPI Setup
#define REG_SPI 0 // tulip reg uses CS 0

#define READ 0
#define WRITE 1

#define ENABLE_REG     0x0000
#define IIR_ENABLE (1 << 0)

#define CONTROL_REG    0x0001
#define IIR_ENABLE_PROGRAM (1 << 0)

#define STATUS_REG     0x0002
#define IIR_TAP_A_DONE (1 << 0)
#define IIR_TAP_B_DONE (1 << 1)

#define IIR_A_TAP_MSB           0x0003
#define IIR_A_TAP               0x0004
#define IIR_B_TAP_MSB           0x0005
#define IIR_B_TAP               0x0006
#define ADC_OUTPUT_REG          0x0007
#define LEDR_REG                0x0008
#define HEX0_REG                0x000A
#define HEX1_REG                0x000B
#define HEX2_REG                0x000C
#define HEX3_REG                0x000D
#define HEX4_REG                0x000E
#define HEX5_REG                0x000F
#define IIR_OUTPUT_REG          0x0010

#define SDRAM_ADDR              0x0011
#define SDRAM_WR_DATA           0x0012
#define SDRAM_RD_DATA           0x0013
#define SDRAM_BANK_ADDR         0x0014
#define SDRAM_DATA_MASK         0x0015
#define SDRAM_ROW_ADDR_STROBE_N 0x0016
#define SDRAM_COL_ADDR_STROBE_N 0x0017
#define SDRAM_CLK_EN            0x0018
#define SDRAM_CLK               0x0019
#define SDRAM_WR_EN_N           0x001A
#define SDRAM_CS_N              0x001B

uint16_t rw_registers(uint8_t read_write, uint16_t address_in, uint16_t data_in); // 0 = read, 1 = write
int write_dec_to_hex_segments(uint8_t is_pos, uint16_t value);
int write_hex_to_hex_segments(uint8_t is_pos, uint16_t value);
