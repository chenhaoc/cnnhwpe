// ********************************************************
// Copyright(c)  2018
// Project name  :  HWPE
// Author        :  chenhaoc
// File    name  :  pe.v
// Module  name  :  pe
// Created Time  :  2018/5/16 16:34:47
// Last Modified :  2018/5/18 21:51:38
// Abstract:

// ========================================================
// Revision     Date     Author      Comment
// --------  ---------  ---------    ---------
//   1.0    2018/05/16  chenhaoc
//
// ********************************************************

`define DLY 1
`timescale 1ns/10ps

module pe(
    input  wire             clk,
    input  wire             rst,
    input  wire [1:0]       Data_type,

    //fifo
    input  wire             fifo_empty,
    output wire             fifo_ren,
    input  wire [63:0]      fifo_rd,

    //kernel fetcher pingpong buffer
    input  wire [64*16-1:0] rm,

    //config read/write accreg
    input  wire             acc_wen,
    input  wire  [2:0]      acc_w_acc_id,
    input  wire  [3:0]      acc_w_pe_id,
    input  wire  [31:0]     acc_w_wd,
    input  wire             acc_ren,
    input  wire  [2:0]      acc_r_acc_id,
    input  wire  [3:0]      acc_r_pe_id,
    output wire  [31:0]     acc_r_rd,

    //relu
    input  wire             relu_ren,
    input  wire  [2:0]      relu_acc_id,
    output wire  [31:0]     relu_accreg_0,
    output wire  [31:0]     relu_accreg_1,
    output wire  [31:0]     relu_accreg_2,
    output wire  [31:0]     relu_accreg_3,
    output wire             relu_accreg_en,
    input  wire             relu_out_continue,

    output wire             pe_done
);

wire [63:0] lm;
wire        mac_out_en;
wire [2:0]  mac_acc_id;
pe_ctrl u_pe_ctrl(
     .clk	 (clk      	)
    ,.rst	 (rst   	)
    ,.fifo_empty (fifo_empty	)
    ,.fifo_rd	 (fifo_rd	)
    ,.fifo_ren	 (fifo_ren	)
    ,.lm	 (lm	        )
    ,.mac_out_en (mac_out_en	)
    ,.mac_acc_id (mac_acc_id    )
    ,.pe_done    (pe_done       )
);


wire [319:0] mac_out_dat;
accreg u_accreg(
     .clk	        (clk	        )
    ,.rst	        (rst	        )
    ,.wen	        (acc_wen	        )
    ,.w_acc_id	        (acc_w_acc_id	)
    ,.w_pe_id	        (acc_w_pe_id	)
    ,.w_wd	        (acc_w_wd	)
    ,.ren	        (acc_ren        )
    ,.r_acc_id	        (acc_r_acc_id	)
    ,.r_pe_id	        (acc_r_pe_id	)
    ,.r_rd	        (acc_r_rd       )
    ,.mac_out_en	(mac_out_en	)
    ,.mac_acc_id	(mac_acc_id	)
    ,.mac_out_dat	(mac_out_dat	)
    ,.relu_ren	        (relu_ren	)
    ,.relu_acc_id	(relu_acc_id	)
    ,.relu_accreg_0	(relu_accreg_0	)
    ,.relu_accreg_1	(relu_accreg_1	)
    ,.relu_accreg_2	(relu_accreg_2	)
    ,.relu_accreg_3	(relu_accreg_3	)
    ,.relu_accreg_en	(relu_accreg_en	)
    ,.relu_out_continue (relu_out_continue)
    ,.relu_done         (relu_done      )
);



wire [63:0] rm_15;
wire [63:0] rm_14;
wire [63:0] rm_13;
wire [63:0] rm_12;
wire [63:0] rm_11;
wire [63:0] rm_10;
wire [63:0] rm_9 ;
wire [63:0] rm_8 ;
wire [63:0] rm_7 ;
wire [63:0] rm_6 ;
wire [63:0] rm_5 ;
wire [63:0] rm_4 ;
wire [63:0] rm_3 ;
wire [63:0] rm_2 ;
wire [63:0] rm_1 ;
wire [63:0] rm_0 ;

wire [19:0] mac_out_0;
wire [19:0] mac_out_1;
wire [19:0] mac_out_2;
wire [19:0] mac_out_3;
wire [19:0] mac_out_4;
wire [19:0] mac_out_5;
wire [19:0] mac_out_6;
wire [19:0] mac_out_7;
wire [19:0] mac_out_8;
wire [19:0] mac_out_9;
wire [19:0] mac_out_10;
wire [19:0] mac_out_11;
wire [19:0] mac_out_12;
wire [19:0] mac_out_13;
wire [19:0] mac_out_14;
wire [19:0] mac_out_15;

assign {rm_15, rm_14, rm_13, rm_12, rm_11, rm_10, rm_9, rm_8,
        rm_7, rm_6, rm_5, rm_4, rm_3, rm_2, rm_1, rm_0} = rm;
assign mac_out_dat = {mac_out_15, mac_out_14, mac_out_13, mac_out_12,
                      mac_out_11, mac_out_10, mac_out_9,  mac_out_8,
                      mac_out_7,  mac_out_6,  mac_out_5,  mac_out_4,
                      mac_out_3,  mac_out_2,  mac_out_1,  mac_out_0};

mac   u_mac_0(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_0	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_0    )
);
mac   u_mac_1(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_1	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_1    )
);
mac   u_mac_2(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_2	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_2    )
);
mac   u_mac_3(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_3	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_3    )
);
mac   u_mac_4(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_4	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_4    )
);
mac   u_mac_5(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_5	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_5    )
);
mac   u_mac_6(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_6	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_6    )
);
mac   u_mac_7(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_7	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_7    )
);
mac   u_mac_8(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_8	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_8    )
);
mac   u_mac_9(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_9	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_9    )
);
mac   u_mac_10(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_10	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_10   )
);
mac   u_mac_11(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_11	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_11   )
);
mac   u_mac_12(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_12	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_12   )
);
mac   u_mac_13(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_13	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_13   )
);
mac   u_mac_14(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_14	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_14   )
);
mac   u_mac_15(
     .clk	  (clk	)
    ,.rst	  (rst	)
    ,.lm	  (lm	)
    ,.rm	  (rm_15	)
    ,.Data_type	  (Data_type	)
    ,.mac_out     (mac_out_15   )
);

endmodule
