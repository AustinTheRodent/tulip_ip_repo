#ifndef WAVESHARE_LCD_REGISTERS_H
#define WAVESHARE_LCD_REGISTERS_H

#define WAVESHARE_LCD_CONTROL 0x0
#define PWM_CONTROLLER 0x4
#define WAVESHARE_LCD_STATUS 0x8
#define WAVESHARE_LCD_INTERRUPT_ENABLE 0xC
#define WAVESHARE_LCD_INTERRUPT 0x10
#define WAVESHARE_LCD_SPI_DATA 0x14
#define WAVESHARE_SPI_CS_USR 0x18
#define WAVESHARE_SPI_TX_DELAY 0x1C
#define WAVESHARE_SPI_CLK_DIVIDER 0x20
#define WAVESHARE_SPI_CS_FRONT_DELAY 0x24
#define WAVESHARE_SPI_CS_BACK_DELAY 0x28
#define WAVESHARE_SPI_TX_LEN 0x2C

#define WAVESHARE_LCD_CONTROL_CLK_POL_MASK 0x1
#define WAVESHARE_LCD_CONTROL_CLK_POL_SHIFT 5
#define WAVESHARE_LCD_CONTROL_CLK_POL (0x20)
#define WAVESHARE_LCD_CONTROL_DATA_PHASE_MASK 0x1
#define WAVESHARE_LCD_CONTROL_DATA_PHASE_SHIFT 4
#define WAVESHARE_LCD_CONTROL_DATA_PHASE (0x10)
#define WAVESHARE_LCD_CONTROL_MSB_FIRST_MASK 0x1
#define WAVESHARE_LCD_CONTROL_MSB_FIRST_SHIFT 3
#define WAVESHARE_LCD_CONTROL_MSB_FIRST (0x8)
#define WAVESHARE_LCD_CONTROL_MANUAL_CS_USR_MODE_MASK 0x1
#define WAVESHARE_LCD_CONTROL_MANUAL_CS_USR_MODE_SHIFT 2
#define WAVESHARE_LCD_CONTROL_MANUAL_CS_USR_MODE (0x4)
#define WAVESHARE_LCD_CONTROL_AXI_LITE_MODE_MASK 0x1
#define WAVESHARE_LCD_CONTROL_AXI_LITE_MODE_SHIFT 1
#define WAVESHARE_LCD_CONTROL_AXI_LITE_MODE (0x2)
#define WAVESHARE_LCD_CONTROL_SW_RESETN_MASK 0x1
#define WAVESHARE_LCD_CONTROL_SW_RESETN_SHIFT 0
#define WAVESHARE_LCD_CONTROL_SW_RESETN (0x1)

#define PWM_CONTROLLER_CLOCK_DIVIDER_MASK 0xFF
#define PWM_CONTROLLER_CLOCK_DIVIDER_SHIFT 24
#define PWM_CONTROLLER_ANALOG_VALUE_MASK 0x1FFFF
#define PWM_CONTROLLER_ANALOG_VALUE_SHIFT 0

#define WAVESHARE_LCD_STATUS_SPI_S_VALID_MASK 0x1
#define WAVESHARE_LCD_STATUS_SPI_S_VALID_SHIFT 2
#define WAVESHARE_LCD_STATUS_SPI_S_VALID (0x4)
#define WAVESHARE_LCD_STATUS_SPI_S_READY_MASK 0x1
#define WAVESHARE_LCD_STATUS_SPI_S_READY_SHIFT 1
#define WAVESHARE_LCD_STATUS_SPI_S_READY (0x2)
#define WAVESHARE_LCD_STATUS_SPI_M_VALID_MASK 0x1
#define WAVESHARE_LCD_STATUS_SPI_M_VALID_SHIFT 0
#define WAVESHARE_LCD_STATUS_SPI_M_VALID (0x1)

#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_S_LAST_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_S_LAST_SHIFT 2
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_S_LAST (0x4)
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_VALID_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_VALID_SHIFT 1
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_VALID (0x2)
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_LAST_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_LAST_SHIFT 0
#define WAVESHARE_LCD_INTERRUPT_ENABLE_SPI_M_LAST (0x1)

#define WAVESHARE_LCD_INTERRUPT_SPI_S_LAST_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_SPI_S_LAST_SHIFT 2
#define WAVESHARE_LCD_INTERRUPT_SPI_S_LAST (0x4)
#define WAVESHARE_LCD_INTERRUPT_SPI_M_VALID_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_SPI_M_VALID_SHIFT 1
#define WAVESHARE_LCD_INTERRUPT_SPI_M_VALID (0x2)
#define WAVESHARE_LCD_INTERRUPT_SPI_M_LAST_MASK 0x1
#define WAVESHARE_LCD_INTERRUPT_SPI_M_LAST_SHIFT 0
#define WAVESHARE_LCD_INTERRUPT_SPI_M_LAST (0x1)

#define WAVESHARE_LCD_SPI_DATA_DATA_MASK 0x3FFFF
#define WAVESHARE_LCD_SPI_DATA_DATA_SHIFT 0

#define WAVESHARE_SPI_CS_USR_USR_MASK 0x1
#define WAVESHARE_SPI_CS_USR_USR_SHIFT 1
#define WAVESHARE_SPI_CS_USR_USR (0x2)
#define WAVESHARE_SPI_CS_USR_CS_MASK 0x1
#define WAVESHARE_SPI_CS_USR_CS_SHIFT 0
#define WAVESHARE_SPI_CS_USR_CS (0x1)

#define WAVESHARE_SPI_TX_DELAY_DELAY_MASK 0xFFFFFFFF
#define WAVESHARE_SPI_TX_DELAY_DELAY_SHIFT 0

#define WAVESHARE_SPI_CLK_DIVIDER_DELAY_MASK 0xFFFFFFFF
#define WAVESHARE_SPI_CLK_DIVIDER_DELAY_SHIFT 0

#define WAVESHARE_SPI_CS_FRONT_DELAY_DELAY_MASK 0xFFFFFFFF
#define WAVESHARE_SPI_CS_FRONT_DELAY_DELAY_SHIFT 0

#define WAVESHARE_SPI_CS_BACK_DELAY_DELAY_MASK 0xFFFFFFFF
#define WAVESHARE_SPI_CS_BACK_DELAY_DELAY_SHIFT 0

#define WAVESHARE_SPI_TX_LEN_LEN_MASK 0xFF
#define WAVESHARE_SPI_TX_LEN_LEN_SHIFT 0

#endif
