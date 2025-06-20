#ifndef BUTTON_IFACE_H
#define BUTTON_IFACE_H

#define BUTTON_CONTROL 0x0
#define BUTTON_INTERRUPT_ENABLE 0x4
#define BUTTON_INTERRUPT 0x8
#define BUTTONS_STATUS 0x100
#define BUTTON_POST_RISING_EDGE_DELAY 0xC
#define BUTTON_POST_FALLING_EDGE_DELAY 0x10
#define BUTTON_RISING_EDGE_MIN_COUNT 0x14
#define BUTTON_FALLING_EDGE_MIN_COUNT 0x18
#define BUTTON_DEBUG 0x1C

#define BUTTON_CONTROL_SW_RESETN_MASK 0x1
#define BUTTON_CONTROL_SW_RESETN_SHIFT 0
#define BUTTON_CONTROL_SW_RESETN (0x1)

#define BUTTON_INTERRUPT_ENABLE_BUTTON4_FE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON4_FE_SHIFT 11
#define BUTTON_INTERRUPT_ENABLE_BUTTON4_FE (0x800)
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_FE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_FE_SHIFT 10
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_FE (0x400)
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_FE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_FE_SHIFT 9
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_FE (0x200)
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_FE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_FE_SHIFT 8
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_FE (0x100)
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_FE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_FE_SHIFT 7
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_FE (0x80)
#define BUTTON_INTERRUPT_ENABLE_BUTTON4_RE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON4_RE_SHIFT 6
#define BUTTON_INTERRUPT_ENABLE_BUTTON4_RE (0x40)
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_RE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_RE_SHIFT 5
#define BUTTON_INTERRUPT_ENABLE_BUTTON3_RE (0x20)
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_RE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_RE_SHIFT 4
#define BUTTON_INTERRUPT_ENABLE_BUTTON2_RE (0x10)
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_RE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_RE_SHIFT 3
#define BUTTON_INTERRUPT_ENABLE_BUTTON1_RE (0x8)
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_RE_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_RE_SHIFT 2
#define BUTTON_INTERRUPT_ENABLE_BUTTON0_RE (0x4)
#define BUTTON_INTERRUPT_ENABLE_ROTARY_B_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_ROTARY_B_SHIFT 1
#define BUTTON_INTERRUPT_ENABLE_ROTARY_B (0x2)
#define BUTTON_INTERRUPT_ENABLE_ROTARY_A_MASK 0x1
#define BUTTON_INTERRUPT_ENABLE_ROTARY_A_SHIFT 0
#define BUTTON_INTERRUPT_ENABLE_ROTARY_A (0x1)

#define BUTTON_INTERRUPT_BUTTON4_FE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON4_FE_SHIFT 11
#define BUTTON_INTERRUPT_BUTTON4_FE (0x800)
#define BUTTON_INTERRUPT_BUTTON3_FE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON3_FE_SHIFT 10
#define BUTTON_INTERRUPT_BUTTON3_FE (0x400)
#define BUTTON_INTERRUPT_BUTTON2_FE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON2_FE_SHIFT 9
#define BUTTON_INTERRUPT_BUTTON2_FE (0x200)
#define BUTTON_INTERRUPT_BUTTON1_FE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON1_FE_SHIFT 8
#define BUTTON_INTERRUPT_BUTTON1_FE (0x100)
#define BUTTON_INTERRUPT_BUTTON0_FE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON0_FE_SHIFT 7
#define BUTTON_INTERRUPT_BUTTON0_FE (0x80)
#define BUTTON_INTERRUPT_BUTTON4_RE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON4_RE_SHIFT 6
#define BUTTON_INTERRUPT_BUTTON4_RE (0x40)
#define BUTTON_INTERRUPT_BUTTON3_RE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON3_RE_SHIFT 5
#define BUTTON_INTERRUPT_BUTTON3_RE (0x20)
#define BUTTON_INTERRUPT_BUTTON2_RE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON2_RE_SHIFT 4
#define BUTTON_INTERRUPT_BUTTON2_RE (0x10)
#define BUTTON_INTERRUPT_BUTTON1_RE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON1_RE_SHIFT 3
#define BUTTON_INTERRUPT_BUTTON1_RE (0x8)
#define BUTTON_INTERRUPT_BUTTON0_RE_MASK 0x1
#define BUTTON_INTERRUPT_BUTTON0_RE_SHIFT 2
#define BUTTON_INTERRUPT_BUTTON0_RE (0x4)
#define BUTTON_INTERRUPT_ROTARY_B_MASK 0x1
#define BUTTON_INTERRUPT_ROTARY_B_SHIFT 1
#define BUTTON_INTERRUPT_ROTARY_B (0x2)
#define BUTTON_INTERRUPT_ROTARY_A_MASK 0x1
#define BUTTON_INTERRUPT_ROTARY_A_SHIFT 0
#define BUTTON_INTERRUPT_ROTARY_A (0x1)

#define BUTTONS_STATUS_BUTTON4_MASK 0x1
#define BUTTONS_STATUS_BUTTON4_SHIFT 6
#define BUTTONS_STATUS_BUTTON4 (0x40)
#define BUTTONS_STATUS_BUTTON3_MASK 0x1
#define BUTTONS_STATUS_BUTTON3_SHIFT 5
#define BUTTONS_STATUS_BUTTON3 (0x20)
#define BUTTONS_STATUS_BUTTON2_MASK 0x1
#define BUTTONS_STATUS_BUTTON2_SHIFT 4
#define BUTTONS_STATUS_BUTTON2 (0x10)
#define BUTTONS_STATUS_BUTTON1_MASK 0x1
#define BUTTONS_STATUS_BUTTON1_SHIFT 3
#define BUTTONS_STATUS_BUTTON1 (0x8)
#define BUTTONS_STATUS_BUTTON0_MASK 0x1
#define BUTTONS_STATUS_BUTTON0_SHIFT 2
#define BUTTONS_STATUS_BUTTON0 (0x4)
#define BUTTONS_STATUS_ROTARY_B_MASK 0x1
#define BUTTONS_STATUS_ROTARY_B_SHIFT 1
#define BUTTONS_STATUS_ROTARY_B (0x2)
#define BUTTONS_STATUS_ROTARY_A_MASK 0x1
#define BUTTONS_STATUS_ROTARY_A_SHIFT 0
#define BUTTONS_STATUS_ROTARY_A (0x1)

#define BUTTON_POST_RISING_EDGE_DELAY_VALUE_MASK 0xFFFFFFFF
#define BUTTON_POST_RISING_EDGE_DELAY_VALUE_SHIFT 0

#define BUTTON_POST_FALLING_EDGE_DELAY_VALUE_MASK 0xFFFFFFFF
#define BUTTON_POST_FALLING_EDGE_DELAY_VALUE_SHIFT 0

#define BUTTON_RISING_EDGE_MIN_COUNT_VALUE_MASK 0xFFFFFFFF
#define BUTTON_RISING_EDGE_MIN_COUNT_VALUE_SHIFT 0

#define BUTTON_FALLING_EDGE_MIN_COUNT_VALUE_MASK 0xFFFFFFFF
#define BUTTON_FALLING_EDGE_MIN_COUNT_VALUE_SHIFT 0

#define BUTTON_DEBUG_STATE_MASK 0xFF
#define BUTTON_DEBUG_STATE_SHIFT 0

#endif
