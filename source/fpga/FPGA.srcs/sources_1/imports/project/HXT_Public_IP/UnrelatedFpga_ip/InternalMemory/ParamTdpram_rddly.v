////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  ParamTdpram.v
Target Device All
Dscription 
    1)基于参数化的通用真双端口RAM，采用Verilog存储器，即数组的方式实现
    2)支持在不同FPGA平台进行RAM推断，即可在不同平台通用该模块
    
Data_Struct:

Caution:
    1)
Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module ParamTdpram_rddly #(
    parameter   ADDR_WIDTH = 10,
                DATA_WIDTH = 32
)(
    input  wire                  clk,
    //A端口
    input  wire                  we_a,
    input  wire [DATA_WIDTH-1:0] wdata_a,
    input  wire [ADDR_WIDTH-1:0] addr_a,
    output reg  [DATA_WIDTH-1:0] rdata_a,
    //B端口
    input  wire                  we_b,
    input  wire [DATA_WIDTH-1:0] wdata_b,
    input  wire [ADDR_WIDTH-1:0] addr_b,
    output reg  [DATA_WIDTH-1:0] rdata_b
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
wire [DATA_WIDTH-1:0] rdata_a_dly;
reg  [DATA_WIDTH-1:0] rdata_a_dly_1;

wire [DATA_WIDTH-1:0] rdata_b_dly;
/************************************************************************
                                读出的数据延迟一拍
*************************************************************************/
always @(posedge clk) begin
    rdata_b         <= rdata_b_dly;
    
    rdata_a_dly_1   <= rdata_a_dly;
    rdata_a         <= rdata_a_dly_1;
end

/*----------------------------------------------------------
                   IP调用区域
----------------------------------------------------------*/
ParamTdpram #(
    .ADDR_WIDTH                 ( ADDR_WIDTH            ),
    .DATA_WIDTH                 ( DATA_WIDTH            )
)ParamTdpram_inst(      
    .clk                        ( clk                   ),
        
    .we_a                       ( we_a                  ),
    .wdata_a                    ( wdata_a               ),
    .addr_a                     ( addr_a                ),
    .rdata_a                    ( rdata_a_dly           ),
                                                    
    .we_b                       ( we_b                  ),
    .wdata_b                    ( wdata_b               ),
    .addr_b                     ( addr_b                ),
    .rdata_b                    ( rdata_b_dly           )
);

endmodule
/*
ParamTdpram_rddly #(
    .ADDR_WIDTH                 ( ADDR_WIDTH            ),
    .DATA_WIDTH                 ( DATA_WIDTH            )
)ParamTdpram_rddly_inst(      
    .clk                        ( ),
        
    .we_a                       ( ),
    .wdata_a                    ( ),
    .addr_a                     ( ),
    .rdata_a                    ( ),
                                  
    .we_b                       ( ),
    .wdata_b                    ( ),
    .addr_b                     ( ),
    .rdata_b                    ( )
);
*/