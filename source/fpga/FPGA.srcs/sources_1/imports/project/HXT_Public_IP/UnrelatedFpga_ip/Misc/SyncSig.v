////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  SyncSig.v
Target Device All
Dscription 
    1)简单的单bit信号同步器
    2)支持参数化进行级联
    3)注意和相应平台的约束tcl脚本搭配使用
    4)支持简单/严格同步模式
        简单模式就是简单的2级及以上寄存器打拍数
        严格同步模式则是必须保证同步寄存器bit一致才能改变输出
    
Data_Struct:

Caution:
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module SyncSig #(
    parameter SYNC_REGS = 2,
              POLAR     = 0,
              STRICT    = 0
)(
	input  wire clk    ,
	input  wire rst_n  ,
	input  wire in_sig ,
	output reg  out_sig
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
reg [SYNC_REGS-1:0] sig_shift;

localparam  INIT_VAL = (POLAR > 0) ? 1'b1 : 1'b0;
/************************************************************************
                                同步级联
*************************************************************************/
always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0) begin
		sig_shift <= {SYNC_REGS{INIT_VAL}};
	end
	else begin//Sync signal
		sig_shift <= {sig_shift[SYNC_REGS-2:0],in_sig};
  end
end

generate 
    if(STRICT == 0)
        always @(*) out_sig = sig_shift[SYNC_REGS-1];
    else
        always @(posedge clk or negedge rst_n) begin
            if(rst_n == 1'b0)begin
                out_sig <= INIT_VAL;
            end
            else begin
                if     ((|sig_shift) == 1'b0) out_sig <= 1'b0;
                else if((&sig_shift) == 1'b1) out_sig <= 1'b1;
                else                          out_sig <= out_sig;
            end
        end
endgenerate

endmodule
/*
SyncSig #(
    .SYNC_REGS(SYNC_REGS),
    .POLAR    (POLAR),
    .STRICT   (STRICT)
)SyncSig_Inst(
    .clk    (),
    .rst_n  (),
    .in_sig (),
    .out_sig()
);
*/