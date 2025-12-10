////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISFifoBuf.v
Target Device All
Dscription 
    1)对AXI Stream接口通过FIFO进行缓存并输出
    2)支持报文处理模式和流模式
        0：流处理模式，随到随取  
        1：报文处理模式，接收完整报文后再取出发送
    2)支持同步和异步两种模式
Data_Struct:
    1)
Caution: 
    1)如果PKT_MODE为报文模式时，FIFO深度至少为512(2的9次方)
    2)即使PKT_MODE为流模式，深度也不应小于32(2的5次方)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module AXISFifoBuf#(
    parameter ASYNC_EN    = 1,//同步或异步  0：同步  1：异步
              DEEP_WIDTH  = 5,//缓存FIFO的容量的指数位宽
              PKT_MODE    = 0,//处理模式，0：流处理模式  1：报文处理模式
              DATA_BYTE   = 8,
              USER_BIT    = 1,
              MIN_PKTLINE = 4//默认按照最少每8拍是1个完整报文来评估SFIFO深度
)(
//时钟复位信号
    input  wire                   s_axis_clk,
    input  wire                   s_axis_rst_n,
    
    input  wire                   m_axis_clk,
    input  wire                   m_axis_rst_n,
//AXI Stream输入接口
    output wire                   s_axis_tready,
    input  wire                   s_axis_tvalid,
    input  wire [  DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire [   USER_BIT-1:0] s_axis_tuser,    
//AXI Stream输出接口
    input  wire                   m_axis_tready,
    output wire                   m_axis_tvalid,
    output wire [  DATA_BYTE-1:0] m_axis_tkeep,
    output wire [DATA_BYTE*8-1:0] m_axis_tdata,
    output wire                   m_axis_tlast,
    output wire [   USER_BIT-1:0] m_axis_tuser,
    
    output wire [           31:0] free_space,
    output wire [           31:0] used_space
);

generate
    if(PKT_MODE == 1) begin:PktBuf
        AXISFifoPktBuf#(
            .ASYNC_EN   (ASYNC_EN   ),
            .DEEP_WIDTH (DEEP_WIDTH ),
            .DATA_BYTE  (DATA_BYTE  ),
            .USER_BIT   (USER_BIT   ),
            .MIN_PKTLINE(MIN_PKTLINE)
        )AXISFifoPktBuf_Inst(
        //时钟复位信号
            .s_axis_clk  (s_axis_clk  ),
            .s_axis_rst_n(s_axis_rst_n),
            .m_axis_clk  (m_axis_clk  ),
            .m_axis_rst_n(m_axis_rst_n),
        //AXI Stream输入接口
            .s_axis_tready(s_axis_tready),
            .s_axis_tvalid(s_axis_tvalid),
            .s_axis_tkeep (s_axis_tkeep ),
            .s_axis_tdata (s_axis_tdata ),
            .s_axis_tlast (s_axis_tlast ),
            .s_axis_tuser (s_axis_tuser ),    
        //AXI Stream输出接口
            .m_axis_tready(m_axis_tready),
            .m_axis_tvalid(m_axis_tvalid),
            .m_axis_tkeep (m_axis_tkeep ),
            .m_axis_tdata (m_axis_tdata ),
            .m_axis_tlast (m_axis_tlast ),
            .m_axis_tuser (m_axis_tuser ),
        //状态信号
            .free_space(free_space),
            .used_space(used_space)
        );
    end
    else begin:StrBuf
        AXISFifoStrBuf#(
            .ASYNC_EN   (ASYNC_EN   ),
            .DEEP_WIDTH (DEEP_WIDTH ),
            .DATA_BYTE  (DATA_BYTE  ),
            .USER_BIT   (USER_BIT   ),
            .MIN_PKTLINE(MIN_PKTLINE)
        )AXISFifoStrBuf_Inst(
        //时钟复位信号
            .s_axis_clk  (s_axis_clk  ),
            .s_axis_rst_n(s_axis_rst_n),
            .m_axis_clk  (m_axis_clk  ),
            .m_axis_rst_n(m_axis_rst_n),
        //AXI Stream输入接口
            .s_axis_tready(s_axis_tready),
            .s_axis_tvalid(s_axis_tvalid),
            .s_axis_tkeep (s_axis_tkeep ),
            .s_axis_tdata (s_axis_tdata ),
            .s_axis_tlast (s_axis_tlast ),
            .s_axis_tuser (s_axis_tuser ),    
        //AXI Stream输出接口
            .m_axis_tready(m_axis_tready),
            .m_axis_tvalid(m_axis_tvalid),
            .m_axis_tkeep (m_axis_tkeep ),
            .m_axis_tdata (m_axis_tdata ),
            .m_axis_tlast (m_axis_tlast ),
            .m_axis_tuser (m_axis_tuser ),
        //状态信号
            .free_space(free_space),
            .used_space(used_space)
        );
    end
endgenerate

endmodule
/*

AXISFifoBuf#(
    .ASYNC_EN   (ASYNC_EN   ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH (DEEP_WIDTH ),//缓存FIFO的容量的指数位宽
    .PKT_MODE   (PKT_MODE   ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (DATA_BYTE  ),
    .USER_BIT   (USER_BIT   ),
    .MIN_PKTLINE(MIN_PKTLINE)
)AXISFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk  (s_axis_clk  ),
    .s_axis_rst_n(s_axis_rst_n),
    .m_axis_clk  (m_axis_clk  ),
    .m_axis_rst_n(m_axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser ),
//状态信号
    .free_space(free_space),
    .used_space(used_space)
);
*/