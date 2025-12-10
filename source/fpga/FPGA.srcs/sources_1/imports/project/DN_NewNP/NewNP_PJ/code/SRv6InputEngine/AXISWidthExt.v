////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISWidthExt.v
Target Device All
Dscription 
  1)分组位宽扩展(PktWidthExt)模块采用标准IP实现方式,方便后续复用。
  2)该模块接收MAC IP核RX端数据,将数据位宽扩展指定倍数,以增加处理带宽
  3)使得用户核心逻辑可将多个端口数据汇聚后统一处理


Data_Struct:

Caution:

Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/

module AXISWidthExt #(
    parameter   BYTE_DIR = 1,//扩展数据方向标记,即数据扩展方向,0从低到高  1从高到低
                IN_BYTE  = 1,//输入接口数据位宽,单位为字节,最高支持1024字节
                EXT_NUM  = 16,//输出扩展倍数,即将输入数据位宽扩展的倍数,支持倍数范围2~1024倍
                USER_BIT = 1//tuser信号的位宽
)(
//时钟复位信号
    input  wire                         axis_clk,
    input  wire                         axis_rst_n,	
//报文分组输入接口信号         
    output reg                          s_axis_tready,    
    input  wire                         s_axis_tvalid,    
    input  wire [          IN_BYTE-1:0] s_axis_tkeep,
    input  wire [        IN_BYTE*8-1:0] s_axis_tdata,
    input  wire                         s_axis_tlast,
    input  wire [         USER_BIT-1:0] s_axis_tuser,    
//报文分组输出接口信号
    input   wire                        m_axis_tready,
    output  reg                         m_axis_tvalid,
    output  reg [  IN_BYTE*EXT_NUM-1:0] m_axis_tkeep,
    output  reg [IN_BYTE*EXT_NUM*8-1:0] m_axis_tdata,
    output  reg                         m_axis_tlast,
    output  reg [         USER_BIT-1:0] m_axis_tuser
);

/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam  IN_BIT   = IN_BYTE*8,
            OUT_BYTE = IN_BYTE*EXT_NUM,
            OUT_BIT  = OUT_BYTE*8;
            
reg  [9:0] ext_byte_cnt;//接收位宽扩展数据标号
wire [9:0] sel_ext_byte_cnt;//实际数据标高


/*/////////////////////////////////////
            接收端处理
*////////////////////////////////////// 
//为每个输出端的寄存器将输入的数据排序写入提供编号 
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        ext_byte_cnt <= 10'b0;
    end
    else begin
        if((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1)) begin//输入数据被接收
            if((ext_byte_cnt == (EXT_NUM-1)) || (s_axis_tlast == 1'b1)) begin//输出端口存满输入数据,或 接收到报文尾部
                ext_byte_cnt <= 10'b0;
            end
            else begin
                ext_byte_cnt <= ext_byte_cnt+1'b1;
            end
        end
        else begin
            ext_byte_cnt <= ext_byte_cnt;
        end
    end
        
end   

//根据扩展数据方向标记选择对应的标号
assign sel_ext_byte_cnt = (BYTE_DIR == 1) ? (EXT_NUM-ext_byte_cnt-1):ext_byte_cnt;

//s_axis_tready处理
always @* begin
    if((m_axis_tvalid == 1'b1)&&( m_axis_tready == 1'b0))//即输出端口正在输出中,但对端不接受该输出数据
        s_axis_tready = 1'b0;
    else 
        s_axis_tready = 1'b1;
end

/*/////////////////////////////////////
            输出端处理
*////////////////////////////////////// 
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        m_axis_tvalid <= 1'b0;
        m_axis_tlast  <= 1'b0;
        m_axis_tuser  <= {USER_BIT{1'b0}};
        
        m_axis_tdata <= {OUT_BYTE{8'b0}};
        m_axis_tkeep <= {OUT_BYTE{1'b0}};
    end
    else begin
        if((s_axis_tvalid == 1'b1) && (s_axis_tready == 1'b1)) begin//有数据输入
            m_axis_tdata[(sel_ext_byte_cnt*IN_BIT)+:IN_BIT] <= s_axis_tdata;
            
            //每行的首字节将tkeep清零,但同时还是要将该赋值的位置复位
            //此处利用了过程块赋值的特性进行了偷懒,即相同寄存器的赋值,后续赋值动作覆盖前面的
            m_axis_tkeep <= (ext_byte_cnt == 10'b0) ? {OUT_BYTE{1'b0}} : m_axis_tkeep;
            m_axis_tkeep[(sel_ext_byte_cnt*IN_BYTE)+:IN_BYTE] <= s_axis_tkeep;
            
            if((ext_byte_cnt == (EXT_NUM-1)) || (s_axis_tlast == 1'b1)) begin
            //输出端口存满输入数据,或 接收到报文尾部,可输出当拍缓存输出
                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= s_axis_tlast;
                m_axis_tuser  <= s_axis_tuser;
            end
            else begin
                m_axis_tvalid <= 1'b0;
                m_axis_tlast  <= m_axis_tlast;
                m_axis_tuser  <= m_axis_tuser;
            end
        end                  
        else begin
            m_axis_tvalid <= (m_axis_tready == 1'b1) ? 1'b0 : m_axis_tvalid;
            //m_axis_tready为1,则即使有数据也被接收了,新数据也没来,可以置0,否则保持原值(有可能正在传输)
            m_axis_tlast  <= m_axis_tlast;
            m_axis_tuser  <= m_axis_tuser;
            
            m_axis_tdata <= m_axis_tdata;
            m_axis_tkeep <= m_axis_tkeep;
        end
    end
end

endmodule
/*
AXISWidthExt #(
    .BYTE_DIR(),//扩展数据方向标记,即数据扩展方向,0从低到高  1从高到低
    .IN_BYTE (),//输入接口数据位宽,单位为字节,最高支持1024字节
    .EXT_NUM (),//输出扩展倍数,即将输入数据位宽扩展的倍数,支持倍数范围2~1024倍
    .USER_BIT()//tuser信号的位宽
)PktWidthExt_inst(
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