////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISRegStdBuf.v
Target Device All
Dscription 
    1)对AXI Stream接口通过寄存器进行缓存
    2)分为标准模式和时序优化模式
        标准模式，资源占用少，但时序性能差
            只使用了1组AXI-Stream寄存器
            因此s_axis_tready是组合逻辑的
        时序优化模式资源占用多，但拥有更好的时序
            相比标准模式多了一组AXI Stream的寄存器
            同时s_axis_tready也用时序逻辑实现，以将两端时序完全隔断，
        
        
Data_Struct:
    1)
Caution: 
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module AXISRegBuf#(
    parameter PROMODE_EN = 0,
              DATA_BYTE = 8,
              USER_BIT  = 1
)(
//时钟复位信号
    input  wire                   axis_clk,
    input  wire                   axis_rst_n,
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
    output wire [   USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 


generate
    if(PROMODE_EN == 0) begin
        AXISRegStdBuf#(
            .DATA_BYTE(DATA_BYTE),
            .USER_BIT (USER_BIT)
        )AXISRegStdBuf_Inst(
        //时钟复位信号
            .axis_clk  (axis_clk  ),
            .axis_rst_n(axis_rst_n),
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
            .m_axis_tuser (m_axis_tuser )
        );
    end
    else begin
        AXISRegProBuf#(
            .DATA_BYTE(DATA_BYTE),
            .USER_BIT (USER_BIT )
        )AXISRegProBuf_Inst(
        //时钟复位信号
            .axis_clk  (axis_clk  ),
            .axis_rst_n(axis_rst_n),
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
            .m_axis_tuser (m_axis_tuser )
        );
    end
endgenerate
endmodule
/*
AXISRegBuf#(
    .PROMODE_EN(),
    .DATA_BYTE (),
    .USER_BIT  ()
)AXISRegBuf_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//AXI Stream输入接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),    
//AXI Stream输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser ()
);
*/