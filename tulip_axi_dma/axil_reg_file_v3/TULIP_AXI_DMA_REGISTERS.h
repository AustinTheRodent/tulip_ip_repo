#ifndef TULIP_AXI_DMA_REGISTERS_H
#define TULIP_AXI_DMA_REGISTERS_H

#define CONTROL 0x0
#define DMA_TX_STATUS 0x4
#define DMA_TX_STATUS_RESET 0x8
#define DMA_TX_ADDR_MSBS 0xC
#define DMA_TX_ADDR 0x10
#define DMA_TX_TRANSACT_LEN_BYTES 0x14
#define DMA_RX_STATUS 0x104
#define DMA_RX_STATUS_RESET 0x108
#define DMA_RX_ADDR_MSBS 0x10C
#define DMA_RX_ADDR 0x110
#define DMA_RX_TRANSACT_LEN_BYTES 0x114
#define DMA_FLUSH_BUS 0x200
#define DMA_FLUSH_STATUS_CLEAR 0x204
#define DMA_FLUSH_STATUS 0x208

#define CONTROL_SW_RESETN_MASK 0x1
#define CONTROL_SW_RESETN_SHIFT 0
#define CONTROL_SW_RESETN (0x1)

#define DMA_TX_STATUS_TX_STARTED_MASK 0x1
#define DMA_TX_STATUS_TX_STARTED_SHIFT 1
#define DMA_TX_STATUS_TX_STARTED (0x2)
#define DMA_TX_STATUS_TX_DONE_MASK 0x1
#define DMA_TX_STATUS_TX_DONE_SHIFT 0
#define DMA_TX_STATUS_TX_DONE (0x1)

#define DMA_TX_STATUS_RESET_TX_STARTED_MASK 0x1
#define DMA_TX_STATUS_RESET_TX_STARTED_SHIFT 1
#define DMA_TX_STATUS_RESET_TX_STARTED (0x2)
#define DMA_TX_STATUS_RESET_TX_DONE_MASK 0x1
#define DMA_TX_STATUS_RESET_TX_DONE_SHIFT 0
#define DMA_TX_STATUS_RESET_TX_DONE (0x1)

#define DMA_TX_ADDR_MSBS_TX_ADDR_MSBS_MASK 0xFFFFFFFF
#define DMA_TX_ADDR_MSBS_TX_ADDR_MSBS_SHIFT 0

#define DMA_TX_ADDR_TX_ADDR_LSBS_MASK 0xFFFFFFFF
#define DMA_TX_ADDR_TX_ADDR_LSBS_SHIFT 0

#define DMA_TX_TRANSACT_LEN_BYTES_TX_TRANSACT_LEN_BYTES_MASK 0xFFFFFFFF
#define DMA_TX_TRANSACT_LEN_BYTES_TX_TRANSACT_LEN_BYTES_SHIFT 0

#define DMA_RX_STATUS_RX_STARTED_MASK 0x1
#define DMA_RX_STATUS_RX_STARTED_SHIFT 1
#define DMA_RX_STATUS_RX_STARTED (0x2)
#define DMA_RX_STATUS_RX_DONE_MASK 0x1
#define DMA_RX_STATUS_RX_DONE_SHIFT 0
#define DMA_RX_STATUS_RX_DONE (0x1)

#define DMA_RX_STATUS_RESET_RX_STARTED_MASK 0x1
#define DMA_RX_STATUS_RESET_RX_STARTED_SHIFT 1
#define DMA_RX_STATUS_RESET_RX_STARTED (0x2)
#define DMA_RX_STATUS_RESET_RX_DONE_MASK 0x1
#define DMA_RX_STATUS_RESET_RX_DONE_SHIFT 0
#define DMA_RX_STATUS_RESET_RX_DONE (0x1)

#define DMA_RX_ADDR_MSBS_RX_ADDR_MSBS_MASK 0xFFFFFFFF
#define DMA_RX_ADDR_MSBS_RX_ADDR_MSBS_SHIFT 0

#define DMA_RX_ADDR_RX_ADDR_LSBS_MASK 0xFFFFFFFF
#define DMA_RX_ADDR_RX_ADDR_LSBS_SHIFT 0

#define DMA_RX_TRANSACT_LEN_BYTES_RX_TRANSACT_LEN_BYTES_MASK 0xFFFFFFFF
#define DMA_RX_TRANSACT_LEN_BYTES_RX_TRANSACT_LEN_BYTES_SHIFT 0

#define DMA_FLUSH_BUS_TRIGGER_FLUSH_MASK 0x1
#define DMA_FLUSH_BUS_TRIGGER_FLUSH_SHIFT 0
#define DMA_FLUSH_BUS_TRIGGER_FLUSH (0x1)

#define DMA_FLUSH_STATUS_CLEAR_FLUSH_FINISHED_MASK 0x1
#define DMA_FLUSH_STATUS_CLEAR_FLUSH_FINISHED_SHIFT 0
#define DMA_FLUSH_STATUS_CLEAR_FLUSH_FINISHED (0x1)

#define DMA_FLUSH_STATUS_FLUSH_FINISHED_MASK 0x1
#define DMA_FLUSH_STATUS_FLUSH_FINISHED_SHIFT 0
#define DMA_FLUSH_STATUS_FLUSH_FINISHED (0x1)

#endif
