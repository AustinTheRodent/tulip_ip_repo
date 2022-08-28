#include <stdint.h>
#include <neo430.h>
#include "tulip.h"
#include "hal_printf.h"

uint16_t rw_registers(uint8_t read_write, uint16_t address_in, uint16_t data_in) // 0 = read, 1 = write
{
    uint16_t timeout = 0;
    uint16_t reg_return;
    if(read_write == WRITE)
    {
        neo430_gpio_pin_set(REG_RW);
    }
    else
    {
        neo430_gpio_pin_clr(REG_RW);
    }
    neo430_gpio_pin_set(REG_TRANSACTION_ENABLE); // transaction enable raise
    neo430_spi_cs_en(REG_SPI);

    neo430_spi_trans(address_in);

    neo430_spi_cs_dis();
    while(neo430_gpio_pin_get(REG_RW_READY) == 0)
    {
        timeout++;
        if(timeout > 50000)
        {
            neo430_uart_br_print("error: rw_register timeout\n");
            break;
        }
    }; // wait for feedback

    neo430_spi_cs_en(REG_SPI);

    reg_return = neo430_spi_trans(data_in);

    neo430_spi_cs_dis();
    neo430_gpio_pin_clr(REG_TRANSACTION_ENABLE);

    return reg_return;
}

int write_dec_to_hex_segments(uint8_t is_pos, uint16_t value)
{
    uint16_t decimal_digit[4];
    if(value < 10)
    {
        rw_registers(WRITE, HEX0_REG, value);
        rw_registers(WRITE, HEX2_REG, 0xFFFF);
        rw_registers(WRITE, HEX3_REG, 0xFFFF);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX1_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX1_REG, 0xFFFF);
        }
    }
    else if(value < 100)
    {
        decimal_digit[0] = value%10;
        decimal_digit[1] = ((value - decimal_digit[0])/10)%10;
        rw_registers(WRITE, HEX0_REG, decimal_digit[0]);
        rw_registers(WRITE, HEX1_REG, decimal_digit[1]);
        rw_registers(WRITE, HEX3_REG, 0xFFFF);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX2_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX2_REG, 0xFFFF);
        }
    }
    else if(value < 1000)
    {
        decimal_digit[0] = value%10;
        decimal_digit[1] = ((value - decimal_digit[0])/10)%10;
        decimal_digit[2] = ((value - decimal_digit[1] - decimal_digit[0])/100)%10;
        rw_registers(WRITE, HEX0_REG, decimal_digit[0]);
        rw_registers(WRITE, HEX1_REG, decimal_digit[1]);
        rw_registers(WRITE, HEX2_REG, decimal_digit[2]);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX3_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX3_REG, 0xFFFF);
        }
    }
    else if(value < 10000)
    {
        decimal_digit[0] = value%10;
        decimal_digit[1] = ((value - decimal_digit[0])/10)%10;
        decimal_digit[2] = ((value - decimal_digit[1] - decimal_digit[0])/100)%10;
        decimal_digit[3] = ((value - decimal_digit[2] - decimal_digit[1] - decimal_digit[0])/1000)%10;
        rw_registers(WRITE, HEX0_REG, decimal_digit[0]);
        rw_registers(WRITE, HEX1_REG, decimal_digit[1]);
        rw_registers(WRITE, HEX2_REG, decimal_digit[2]);
        rw_registers(WRITE, HEX3_REG, decimal_digit[3]);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX4_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX4_REG, 0xFFFF);
        }
    }
    else
    {
        hal_printf("error in function \"write_to_hex_segments\", input value must be < 10000\n\r");
        return 1;
    }
    return 0;
}

int write_hex_to_hex_segments(uint8_t is_pos, uint16_t value)
{
    if(value < 0x10)
    {
        rw_registers(WRITE, HEX0_REG, value & 0x000F);
        rw_registers(WRITE, HEX2_REG, 0xFFFF);
        rw_registers(WRITE, HEX3_REG, 0xFFFF);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX1_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX1_REG, 0xFFFF);
        }
    }
    else if(value < 0x100)
    {
        rw_registers(WRITE, HEX0_REG, value & 0x000F);
        rw_registers(WRITE, HEX1_REG, (value & 0x00F0)>>4);
        rw_registers(WRITE, HEX3_REG, 0xFFFF);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX2_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX2_REG, 0xFFFF);
        }
    }
    else if(value < 0x1000)
    {
        rw_registers(WRITE, HEX0_REG, value & 0x000F);
        rw_registers(WRITE, HEX1_REG, (value & 0x00F0)>>4);
        rw_registers(WRITE, HEX2_REG, (value & 0x0F00)>>8);
        rw_registers(WRITE, HEX4_REG, 0xFFFF);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX3_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX3_REG, 0xFFFF);
        }
    }
    else
    {
        rw_registers(WRITE, HEX0_REG, value & 0x000F);
        rw_registers(WRITE, HEX1_REG, (value & 0x00F0)>>4);
        rw_registers(WRITE, HEX2_REG, (value & 0x0F00)>>8);
        rw_registers(WRITE, HEX3_REG, (value & 0xF000)>>12);
        if(is_pos == 0)
        {
            rw_registers(WRITE, HEX4_REG, 0xFFFE);
        }
        else
        {
            rw_registers(WRITE, HEX4_REG, 0xFFFF);
        }
    }
    return 0;
}
