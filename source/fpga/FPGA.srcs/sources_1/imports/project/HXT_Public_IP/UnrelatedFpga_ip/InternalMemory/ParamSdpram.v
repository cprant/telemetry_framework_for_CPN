////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  ParamSdpram.v
Target Device All
Dscription 
    1)基于参数化的通用简单双端口RAM，采用Verilog存储器，即数组的方式实现
    2)支持在不同FPGA平台进行RAM推断，即可在不同平台通用该模块
    
Data_Struct:

Caution:
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module ParamSdpram #(
    parameter   ADDR_WIDTH = 10,
                DATA_WIDTH = 32
)(
    input  wire                  wrclk,
    input  wire                  rdclk,     
    input  wire                  aclr  ,//高有效
    //写端口
    input  wire                  wren,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] wdata,
    //读端口
    input  wire                  rden,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output reg  [DATA_WIDTH-1:0] rdata
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam  RAM_DEEP = 2**ADDR_WIDTH;

reg [DATA_WIDTH-1:0] ram_mem [RAM_DEEP-1:0];

/************************************************************************
                                RAM存储通用实现
*************************************************************************/
//RAM写
always @(posedge wrclk) begin
	if(wren == 1'b1) ram_mem[waddr] <= wdata;
end

//RAM读
always @(posedge rdclk) begin
	rdata <= ram_mem[raddr];
end

endmodule
/*
ParamSdpram #(
    .ADDR_WIDTH(),
    .DATA_WIDTH()
)ParamSdpram_inst(
    .wrclk(),
    .rdclk(),     
    .aclr (),
    //写端口
    .wren  (),
    .waddr (),
    .wdata (),
    //读端口
    .rden  (),
    .raddr (),
    .rdata ()
);
*/