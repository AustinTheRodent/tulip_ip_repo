// Libraries
#include <stdint.h>
#include <neo430.h>
#include <math.h>
#include <stdbool.h>

#include "hal_printf.h"
#include "tulip.h"

// Configuration
#define BAUD_RATE 19200
#define PI 3.14159265359

#define DEBUG 1

void sdram_reset(void)
{
  rw_registers(WRITE, SDRAM_CLK_EN, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CS_N, 1);
  rw_registers(WRITE, SDRAM_ROW_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_COL_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_WR_EN_N, 1);
  rw_registers(WRITE, SDRAM_ADDR, 0);
  rw_registers(WRITE, SDRAM_BANK_ADDR, 0);
  rw_registers(WRITE, SDRAM_WR_DATA, 0);
  rw_registers(WRITE, SDRAM_DATA_MASK, 0b11);

  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  //rw_registers(WRITE, SDRAM_CLK, 0);
  //rw_registers(WRITE, SDRAM_CLK_EN, 0);

}

void sdram_precharge(void)
{
  rw_registers(WRITE, SDRAM_CLK_EN, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CS_N, 1);
  rw_registers(WRITE, SDRAM_ROW_ADDR_STROBE_N, 0);
  rw_registers(WRITE, SDRAM_COL_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_WR_EN_N, 0);
  rw_registers(WRITE, SDRAM_ADDR, 1 << 10);
  rw_registers(WRITE, SDRAM_BANK_ADDR, 0b11);

  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  //rw_registers(WRITE, SDRAM_CLK, 0);
  //rw_registers(WRITE, SDRAM_CLK_EN, 0);

}

void sdram_activate_row_bank(uint16_t row_addr, uint8_t bank_addr)
{
  if(row_addr > 0x1FFF)
  {
    hal_printf("row_addr must be smaller than or equal to 0x1FFF\n");
    return;
  }
  if(bank_addr > 3)
  {
    hal_printf("bank_addr must be smaller than or equal to 3\n");
    return;
  }

  rw_registers(WRITE, SDRAM_CLK_EN, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CS_N, 0);
  rw_registers(WRITE, SDRAM_ROW_ADDR_STROBE_N, 0);
  rw_registers(WRITE, SDRAM_COL_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_WR_EN_N, 1);
  rw_registers(WRITE, SDRAM_ADDR, row_addr);
  rw_registers(WRITE, SDRAM_BANK_ADDR, bank_addr);

  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);

  sdram_reset();

}

void sdram_write_single(uint16_t data, uint16_t column_addr, uint8_t bank_addr)
{

  uint16_t addr = 0;

  if(column_addr > 0x7FF)
  {
    hal_printf("column_addr must be smaller than or equal to 0x7FF\n");
    return;
  }
  if(bank_addr > 3)
  {
    hal_printf("bank_addr must be smaller than or equal to 3\n");
    return;
  }

  addr |= ((column_addr & 0x400) << 1) | (0 << 10) | (column_addr & 0x3FF);
  hal_printf("write addr: %X\r\n", addr);

  rw_registers(WRITE, SDRAM_CLK_EN, 1);
  rw_registers(WRITE, SDRAM_DATA_MASK, 0);
  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CS_N, 0);
  rw_registers(WRITE, SDRAM_ROW_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_COL_ADDR_STROBE_N, 0);
  rw_registers(WRITE, SDRAM_WR_EN_N, 0);
  rw_registers(WRITE, SDRAM_ADDR, addr);
  rw_registers(WRITE, SDRAM_BANK_ADDR, bank_addr);
  rw_registers(WRITE, SDRAM_WR_DATA, data);

  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  //rw_registers(WRITE, SDRAM_CLK, 1);
  //rw_registers(WRITE, SDRAM_CLK, 0);

  sdram_precharge();
  sdram_reset();

}

uint16_t sdram_read_single(uint16_t column_addr, uint8_t bank_addr)
{

  uint16_t addr = 0;
  uint16_t ret = 0;

  if(column_addr > 0x7FF)
  {
    hal_printf("column_addr must be smaller than or equal to 0x7FF\n");
    return 0;
  }
  if(bank_addr > 3)
  {
    hal_printf("bank_addr must be smaller than or equal to 3\n");
    return 0;
  }

  addr |= ((column_addr & 0x400) << 1) | (0 << 10) | (column_addr & 0x3FF);
  hal_printf("read addr: %X\r\n", addr);

  rw_registers(WRITE, SDRAM_CLK_EN, 1);
  rw_registers(WRITE, SDRAM_DATA_MASK, 0);
  rw_registers(WRITE, SDRAM_CLK, 0);
  rw_registers(WRITE, SDRAM_CS_N, 0);
  rw_registers(WRITE, SDRAM_ROW_ADDR_STROBE_N, 1);
  rw_registers(WRITE, SDRAM_COL_ADDR_STROBE_N, 0);
  rw_registers(WRITE, SDRAM_WR_EN_N, 1);
  rw_registers(WRITE, SDRAM_ADDR, addr);
  rw_registers(WRITE, SDRAM_BANK_ADDR, bank_addr);

  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);

  rw_registers(WRITE, SDRAM_CLK, 1);
  rw_registers(WRITE, SDRAM_CLK, 0);
  ret = rw_registers(READ, SDRAM_RD_DATA, 0);

  sdram_precharge();
  sdram_reset();

  return ret;

}


/* ------------------------------------------------------------
 * INFO Main function
 * ------------------------------------------------------------ */
int main(void) 
{
  //int i;
  int16_t count = 0;
  uint16_t reg_return = 0;
  //uint8_t L_button_pressed = 0;
  //uint8_t R_button_pressed = 0;
  //int16_t adc_dout;
  //int16_t iir_dout;

  // put tulip in reset
  neo430_gpio_port_set(0);
  neo430_gpio_pin_set(TULIP_RESET);

  // setup UART
  neo430_uart_setup(BAUD_RATE);

  // intro text
  if(DEBUG)
    hal_printf("\n\rInitial tulip soft core test\n\r");

  // setup spi
  if(DEBUG)
    hal_printf("\n\rSetup SPI\n\r");

  neo430_spi_enable(2); // lower to 1?
  neo430_spi_cs_dis();
  neo430_gpio_pin_clr(REG_TRANSACTION_ENABLE);

  // enable tulip
  neo430_cpu_delay_ms(150);
  neo430_gpio_pin_clr(TULIP_RESET);

  // enable tulip modules:
  rw_registers(WRITE, ENABLE_REG, 0xFFFF); // enable all
  //rw_registers(WRITE, ENABLE_REG, 0x0); // disable all


  sdram_reset();
  sdram_activate_row_bank(0, 0);
  //reg_return = sdram_read_single(0, 0);
  sdram_write_single(0xBEEF, 0, 0);
  sdram_write_single(0xDEAD, 2, 0);
  rw_registers(WRITE, SDRAM_WR_DATA, 0);
  neo430_cpu_delay_ms(1000);
  sdram_activate_row_bank(0, 0);
  reg_return = sdram_read_single(0, 0);
  rw_registers(WRITE, SDRAM_WR_DATA, 0);
  hal_printf("read reg: %X\r\n", rw_registers(READ, SDRAM_WR_DATA, 0));
  hal_printf("sdram_read_single: %X\r\n", reg_return);

  while(1)
  {
    //sdram_write_single(0xBEEF, 0, 0);
    //rw_registers(WRITE, SDRAM_WR_DATA, 0);
    reg_return = sdram_read_single(2, 0);
    hal_printf("sdram_read_single: %X\r\n", reg_return);

    write_dec_to_hex_segments(1, (uint16_t)count%10000);
    neo430_cpu_delay_ms(2000);
    count += 2;
  }

  return 0;
}


