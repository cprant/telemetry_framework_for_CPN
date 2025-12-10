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
    2)只使用了1组AXI-Stream寄存器，因此s_axis_tready是组合逻辑的
      如果要更好的时序，可以使用AXISregProBuf
Data_Struct:
    1)
Caution: 
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module AXISRegStdBuf#(
    parameter DATA_BYTE = 8,
              USER_BIT  = 1
)(
//时钟复位信号
    input  wire                   axis_clk,
    input  wire                   axis_rst_n,
//AXI Stream输入接口
    output reg                    s_axis_tready,
    input  wire                   s_axis_tvalid,
    input  wire [  DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire [   USER_BIT-1:0] s_axis_tuser,    
//AXI Stream输出接口
    input  wire                   m_axis_tready,
    output reg                    m_axis_tvalid,
    output reg  [  DATA_BYTE-1:0] m_axis_tkeep,
    output reg  [DATA_BYTE*8-1:0] m_axis_tdata,
    output reg                    m_axis_tlast,
    output reg  [   USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 


/*/////////////////////////////////////
    缓存并输出s_axis接口数据
*//////////////////////////////////////
always @* begin
    if((m_axis_tready == 1'b0) && (m_axis_tvalid == 1'b1))//有数据发出但没有被对端接收
    //没有寄存器可以缓存输入的数据,将ready置低
        s_axis_tready = 1'b0;
    else
        s_axis_tready = 1'b1;
end

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        m_axis_tvalid <= 1'b0;
        m_axis_tlast  <= 1'b0;
        m_axis_tuser  <= {USER_BIT{1'b0}};
        m_axis_tkeep  <= {DATA_BYTE{1'b0}};
        m_axis_tdata  <= {DATA_BYTE{8'b0}};
    end
    else begin
        case({s_axis_tvalid,m_axis_tready,m_axis_tvalid})
            3'b001,3'b101: begin
                m_axis_tvalid <= m_axis_tvalid;
                m_axis_tlast  <= m_axis_tlast;
                m_axis_tuser  <= m_axis_tuser;
                m_axis_tkeep  <= m_axis_tkeep;
                m_axis_tdata  <= m_axis_tdata;
            end

            3'b100,3'b110,3'b111: begin
                m_axis_tvalid <= s_axis_tvalid;
                m_axis_tlast  <= s_axis_tlast;
                m_axis_tuser  <= s_axis_tuser;
                m_axis_tkeep  <= s_axis_tkeep;
                m_axis_tdata  <= s_axis_tdata;
            end
            
            default: begin
                m_axis_tvalid <= 1'b0;
            end
        endcase
    end
end
endmodule
/*
AXISRegStdBuf#(
    .DATA_BYTE(),
    .USER_BIT ()
)AXISRegStdBuf_Inst(
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