`define HWPE_ADDR_WIDTH 22
`define FMEM_ADDR_WIDTH 21 //Feature Map SRAM addr
`define KMEM_ADDR_WIDTH 21 //Kernel SRAM addr
`define SRAM_ADDR_WIDTH 20 //SRAM addr
`define FMEM_ADDR2_START 21'h1_00000
`define KMEM_ADDR_START  22'h2_00000
`define OFFSET_IS_0 21'h0_00000

`define CUSTOM0 7'b00_010_11

`define HWPEWriteFmapAddrReg   7'b0000_001
`define HWPEWriteCfgReg        7'b0000_010
`define HWPEMatrixMac          7'b0000_100
`define HWPEWriteAccReg        7'b0001_000
`define HWPEReadAccReg         7'b0010_000
`define HWPEReLUMemWriteAccReg 7'b0100_000
`define HWPEReset              7'b1000_000
