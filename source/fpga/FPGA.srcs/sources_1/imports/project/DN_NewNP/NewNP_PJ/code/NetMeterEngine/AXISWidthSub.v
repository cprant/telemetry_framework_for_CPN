////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISWidthSub.v
Target Device All
Dscription 
  1)分组位宽缩减(AXISWidthSub)模块采用标准IP实现方式，方便后续复用。
  2)在当前设计中接收输入的数据，根据指定参数将数据按比例缩减并输出，以便输出数据适配端口MAC IP核TX端的接口。

Data_Struct:

Caution:

Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module AXISWidthSub #(
    parameter   BYTE_DIR = 1,//扩展数据方向标记,即数据扩展方向，0从低到高  1从高到低
                OUT_BYTE = 1,//输出接口数据位宽，单位为字节，最高支持1024字节
                SUB_SUM  = 16,//输出相对输入缩减倍数，即将输入数据位宽除以输出数据位宽,支持倍数范围2~1024倍
                USER_BIT = 1//tuser信号的位宽
)(
//时钟复位信号
    input  wire                          axis_clk,
    input  wire                          axis_rst_n,    
//报文分组输入接口信号 
    output reg                           s_axis_tready,
    input  wire                          s_axis_tvalid,
    input  wire [  OUT_BYTE*SUB_SUM-1:0] s_axis_tkeep,
    input  wire [OUT_BYTE*SUB_SUM*8-1:0] s_axis_tdata,
    input  wire                          s_axis_tlast,
    input  wire [          USER_BIT-1:0] s_axis_tuser,
 
//报文分组输出接口信号
    input  wire                          m_axis_tready,    
    output wire                          m_axis_tvalid,    
    output wire [          OUT_BYTE-1:0] m_axis_tkeep,
    output wire [        OUT_BYTE*8-1:0] m_axis_tdata,
    output wire                          m_axis_tlast,
    output wire [          USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam  OUT_BIT = OUT_BYTE*8,
            IN_BYTE = OUT_BYTE*SUB_SUM,
            IN_BIT  = IN_BYTE*8;
            
//缓存接收的数据，并采用移位寄存器的方式逐步输出数据
reg [ IN_BYTE-1:0] keep_reg; 
reg [  IN_BIT-1:0] data_reg;
reg                last_reg;
reg [USER_BIT-1:0] user_reg; 

/*/////////////////////////////////////
            接收端处理
*////////////////////////////////////// 
reg last_flag;
//标记当前输出端口传输的是当前data_reg缓存的最后一拍数据
//注意，只是当前data_reg缓存数据还没有发出去的最后一拍，不一定是报文尾
always @(*) begin
    if(BYTE_DIR == 1) 
        last_flag = ((|m_axis_tkeep)==1'b1) && ((|(keep_reg & {{OUT_BYTE{1'b0}},{(IN_BYTE-OUT_BYTE){1'b1}}})) == 1'b0);
    else 
        last_flag = ((|m_axis_tkeep)==1'b1) && ((|(keep_reg & {{(IN_BYTE-OUT_BYTE){1'b1}},{OUT_BYTE{1'b0}}})) == 1'b0);
end

always @* begin
    if((|keep_reg) == 1'b0) //没有缓存代发的数据
        s_axis_tready = 1'b1;
    else if((last_flag == 1'b1) && (m_axis_tready == 1'b1))//data_reg正在发送最后1拍数据，且已经被对端接收
        s_axis_tready = 1'b1;
    else
        s_axis_tready = 1'b0;
end

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        keep_reg <= {IN_BYTE{1'b0}};
        data_reg <= {IN_BIT{1'b0}};
        last_reg <= 1'b0;
        user_reg <= {USER_BIT{1'b0}};
    end
    else begin
        if((s_axis_tready == 1'b1) && (s_axis_tvalid == 1'b1)) begin//有新数据更新data_reg
        //此条件包含data_reg根本没有数据和data_reg只剩最后一个数据且被接收
            keep_reg <= s_axis_tkeep;
            data_reg <= s_axis_tdata;
            last_reg <= s_axis_tlast;
            user_reg <= s_axis_tuser;
        end
        else if((m_axis_tready == 1'b1) && (m_axis_tvalid == 1'b1)) begin//输出的m_axis_tdata被接收
            keep_reg <= (BYTE_DIR == 1) ? keep_reg << OUT_BYTE : keep_reg >> OUT_BYTE;
            data_reg <= (BYTE_DIR == 1) ? data_reg << OUT_BIT  : data_reg >> OUT_BIT ;
        end
        else begin
            keep_reg <= keep_reg;
            data_reg <= data_reg;
            last_reg <= last_reg;
            user_reg <= user_reg;
        end
    end
end

/*/////////////////////////////////////
            输出端处理
*////////////////////////////////////// 
assign m_axis_tvalid = (|m_axis_tkeep);
assign m_axis_tkeep  = (BYTE_DIR == 1) ? keep_reg[IN_BYTE-1:IN_BYTE-OUT_BYTE] : keep_reg[OUT_BYTE-1:0];
assign m_axis_tdata  = (BYTE_DIR == 1) ? data_reg[ IN_BIT-1: IN_BIT- OUT_BIT] : data_reg[ OUT_BIT-1:0];

//只在最后一个向外发的数据才会将赋值为缓存的tlast，避免接收的尾部数据可以分为多拍输出，没拍数据都将last置高
assign m_axis_tlast = (last_flag == 1'b1) ? last_reg : 1'b0;
//由于需要传输接收时间戳，tuser需要每拍都有效
assign m_axis_tuser = user_reg;

endmodule 
/*
AXISWidthSub #(
    .BYTE_DIR(),
    .OUT_BYTE(),//输出接口数据位宽，单位为字节，最高支持1024字节
    .SUB_SUM(),//输出相对输入缩减倍数，即将输入数据位宽除以输出数据位宽,支持倍数范围2~1024倍
    .USER_BIT()//tuser信号的位宽
)PktWidthSub_inst(
//时钟复位信号
    .axis_clk(),
    .axis_rst_n(),  
//报文分组输入接口信号         
    .s_axis_tready(),    
    .s_axis_tvalid(),    
    .s_axis_tkeep(),
    .s_axis_tdata(),
    .s_axis_tlast(),
    .s_axis_tuser(),    
//报文分组输出接口信号
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep(),
    .m_axis_tdata(),
    .m_axis_tlast(),
    .m_axis_tuser()
);
*/   