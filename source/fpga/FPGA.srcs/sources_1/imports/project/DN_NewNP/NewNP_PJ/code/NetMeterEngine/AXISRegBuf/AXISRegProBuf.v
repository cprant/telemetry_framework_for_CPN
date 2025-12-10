////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISRegProBuf.v
Target Device All
Dscription 
    1)对AXI Stream接口通过寄存器进行缓存
    2)相比AXISRegStdBuf拥有更好的时序
        多了一组AXI Stream的寄存器
        同时s_axis_tready也用时序逻辑实现，以将两端时序完全隔断
Data_Struct:
    1)
Caution: 
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module AXISRegProBuf#(
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
reg                    int_axis_tvalid;
reg  [  DATA_BYTE-1:0] int_axis_tkeep ;
reg  [DATA_BYTE*8-1:0] int_axis_tdata ;
reg                    int_axis_tlast ;
reg  [   USER_BIT-1:0] int_axis_tuser ;

wire                   m_axis_empty;
wire                   int_axis_empty;
wire [            1:0] free_buff_sum;
/*/////////////////////////////////////
    缓存并输出s_axis接口数据
*//////////////////////////////////////
assign m_axis_empty   = ({m_axis_tready,m_axis_tvalid} != 2'b01);
assign int_axis_empty = ~int_axis_tvalid;

assign free_buff_sum = m_axis_empty + int_axis_empty - (s_axis_tvalid & s_axis_tready);

always @(posedge axis_clk)begin
    if((free_buff_sum == 2'd1) || (free_buff_sum == 2'd2))//有数据发出但没有被对端接收
    //没有寄存器可以缓存输入的数据,将ready置低(等于3时只有可能是2个empty都是0，且s_axis_tvalid是1，减溢出)
        s_axis_tready <= 1'b1;
    else
        s_axis_tready <= 1'b0;
end

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        m_axis_tvalid <= 1'b0;
        m_axis_tlast  <= 1'b0;
        m_axis_tuser  <= {USER_BIT{1'b0}};
        m_axis_tkeep  <= {DATA_BYTE{1'b0}};
        m_axis_tdata  <= {DATA_BYTE{8'b0}};
        
        int_axis_tvalid <= 1'b0;
        int_axis_tlast  <= 1'b0;
        int_axis_tuser  <= {USER_BIT{1'b0}};
        int_axis_tkeep  <= {DATA_BYTE{1'b0}};
        int_axis_tdata  <= {DATA_BYTE{8'b0}};
    end
    else begin
        case({int_axis_tvalid,m_axis_tready,m_axis_tvalid})
            3'b000,3'b010,3'b011: begin//int_axis没有数据缓存，而m_axis可发送，则m_axis直接发送s_axis
                m_axis_tvalid <= s_axis_tvalid & s_axis_tready;
                m_axis_tlast  <= s_axis_tlast;
                m_axis_tuser  <= s_axis_tuser;
                m_axis_tkeep  <= s_axis_tkeep;
                m_axis_tdata  <= s_axis_tdata;
                
                int_axis_tvalid <= int_axis_tvalid;
                int_axis_tlast  <= int_axis_tlast;
                int_axis_tuser  <= int_axis_tuser;
                int_axis_tkeep  <= int_axis_tkeep;
                int_axis_tdata  <= int_axis_tdata;
            end

            3'b100,3'b110,3'b111: begin//int_axis有数据缓存，而m_axis可发送，则m_axis发送int_axis，而int_axis缓存s_axis
                m_axis_tvalid <= int_axis_tvalid;
                m_axis_tlast  <= int_axis_tlast;
                m_axis_tuser  <= int_axis_tuser;
                m_axis_tkeep  <= int_axis_tkeep;
                m_axis_tdata  <= int_axis_tdata;
                
                int_axis_tvalid <= s_axis_tvalid & s_axis_tready;
                int_axis_tlast  <= s_axis_tlast;
                int_axis_tuser  <= s_axis_tuser;
                int_axis_tkeep  <= s_axis_tkeep;
                int_axis_tdata  <= s_axis_tdata;
            end
            
            3'b001: begin//m_axis有数据不能发，int_axis没有数据可接收s_axis
                m_axis_tvalid <= m_axis_tvalid;
                m_axis_tlast  <= m_axis_tlast;
                m_axis_tuser  <= m_axis_tuser;
                m_axis_tkeep  <= m_axis_tkeep;
                m_axis_tdata  <= m_axis_tdata;
                
                int_axis_tvalid <= s_axis_tvalid & s_axis_tready;
                int_axis_tlast  <= s_axis_tlast;
                int_axis_tuser  <= s_axis_tuser;
                int_axis_tkeep  <= s_axis_tkeep;
                int_axis_tdata  <= s_axis_tdata;
            end

            3'b101: begin//m_axis有数据不能发，int_axis有数据也只能保持
                m_axis_tvalid <= m_axis_tvalid;
                m_axis_tlast  <= m_axis_tlast;
                m_axis_tuser  <= m_axis_tuser;
                m_axis_tkeep  <= m_axis_tkeep;
                m_axis_tdata  <= m_axis_tdata;
                
                int_axis_tvalid <= int_axis_tvalid;
                int_axis_tlast  <= int_axis_tlast;
                int_axis_tuser  <= int_axis_tuser;
                int_axis_tkeep  <= int_axis_tkeep;
                int_axis_tdata  <= int_axis_tdata;
            end

            default: begin//其他状态为没有数据缓存且传输的状态，保持原值即可
                m_axis_tvalid <= m_axis_tvalid;
                m_axis_tlast  <= m_axis_tlast;
                m_axis_tuser  <= m_axis_tuser;
                m_axis_tkeep  <= m_axis_tkeep;
                m_axis_tdata  <= m_axis_tdata;
                
                int_axis_tvalid <= int_axis_tvalid;
                int_axis_tlast  <= int_axis_tlast;
                int_axis_tuser  <= int_axis_tuser;
                int_axis_tkeep  <= int_axis_tkeep;
                int_axis_tdata  <= int_axis_tdata;
            end
        endcase
    end
end
endmodule
/*
AXISRegProBuf#(
    .DATA_BYTE(),
    .USER_BIT ()
)AXISRegProBuf_Inst(
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