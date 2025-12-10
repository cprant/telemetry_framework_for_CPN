////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  PktLineDet.v
Target Device All
Dscription 
    1)检测输入信号的起始/结束位，以及中间传输数据编号
Data_Struct:
   
Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
`timescale 1ns/100ps
module PktLineDet #(
    parameter  WIDTH = 8
)(
    input  wire             user_clk,
    input  wire             user_rst_n,
                            
    input  wire             valid,
    input  wire             last,
    
    output wire             sop,
    output wire [WIDTH-1:0] line_id,
    output wire             eop
);
/************************************************************************
                    中间变量声明区域
************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
reg [WIDTH-1:0] line_cnt;

always @(posedge user_clk or negedge user_rst_n) begin
    if(user_rst_n == 1'b0) begin
        line_cnt <= {WIDTH{1'b0}};
    end
    else begin
        if(valid == 1'b1)
            if(last  == 1'b1)//当前传输的是报文尾
                line_cnt <= {WIDTH{1'b0}};
            else
                line_cnt <= ((&line_cnt) == 1'b1) ? line_cnt : line_cnt + 1'b1;
        else
            line_cnt <= line_cnt;    
    end
end

//生成分组ID信号
assign sop     = valid & ((|line_cnt) == 1'b0);
assign eop     = valid & last;
assign line_id = line_cnt;

endmodule
/*
PktLineDet PktLineDet_Inst(
    .user_clk(),
    .user_rst_n(),
        
    .valid(),
    .last(),
        
    .sop(),
    .line_id(),
    .eop()
);
*/