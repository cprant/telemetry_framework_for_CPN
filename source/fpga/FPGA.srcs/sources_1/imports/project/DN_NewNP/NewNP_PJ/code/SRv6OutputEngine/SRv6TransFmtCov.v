////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  TransFmtCov.v
Target Device All
Dscription 
    1)接收待发送的128bit分组数据，并删除分组头部16字节Metadata
    2)从FIFO读出缓存数据，将分组数据的MD丢弃，并根据MD中的分组类型信息判断并提取遥测信息输出
Data_Struct:
    1)Metadata    
        [127:120] 输入端口号 8	输入端口号
        [119:112] 输出端口号 8	输出端口号
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [ 98: 88] 保留      11	保留位
        [ 87: 84] 帧类型	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6帧
            1:IPv6-其他帧
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4-7:保留
            8:TSMP帧
            9-14:保留
            15:丢弃报文
        [ 83: 64] 流ID	20	FlowID
            TSMP报文提取自DMAC的MID
            IPv6报文提取自FlowLabel
        [ 63: 48] 流编号 16	
            SRv6报文时提取自SRH头部的Tag
            其他报文暂无意义
        [ 47:  0] 时间戳
        
    2)遥测信息
        [115:100] pkt_len
        [ 99: 36] timestamp
        [ 35: 16] flow label
        [ 15:  0] 帧的序列号seqnum
Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6TransFmtCov(
//时钟复位信号
    input  wire         s_axis_clk,
    input  wire         s_axis_rst_n,
    
    input  wire         m_axis_clk,
    input  wire         m_axis_rst_n,
//本地同步时钟        
    input  wire [ 63:0] iv_local_cnt,
//报文分组数据接收接口
    output wire         s_axis_tready,
    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep,
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tlast,
    input  wire         s_axis_tuser,
//分组数据输出接口
(*mark_debug="true"*)    input  wire         m_axis_tready,
(*mark_debug="true"*)    output reg          m_axis_tvalid,
(*mark_debug="true"*)    output reg  [ 15:0] m_axis_tkeep,
(*mark_debug="true"*)    output reg  [127:0] m_axis_tdata,
(*mark_debug="true"*)    output reg          m_axis_tlast,
(*mark_debug="true"*)    output reg          m_axis_tuser,
//遥测数据输出接口
(*mark_debug="true"*)    input  wire         m_tm_axis_tready,
(*mark_debug="true"*)    output reg          m_tm_axis_tvalid,
(*mark_debug="true"*)    output reg  [115:0] m_tm_axis_tdata ,
//统计信息
(*mark_debug="true"*)    output reg  [ 63:0] ov_send_pkt_cnt,
(*mark_debug="true"*)    output reg  [ 63:0] ov_send_tm_cnt
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
(*mark_debug="true"*)reg          acf_axis_tready;
(*mark_debug="true"*)wire         acf_axis_tvalid;
wire [ 15:0] acf_axis_tkeep ;
wire [127:0] acf_axis_tdata ;
(*mark_debug="true"*)wire         acf_axis_tlast ;
(*mark_debug="true"*)wire [  0:0] acf_axis_tuser ;

wire [ 31:0] acf_free_space ;
(*mark_debug="true"*)wire [ 31:0] acf_used_space ;

(*mark_debug="true"*)wire         acf_axis_sop;
(*mark_debug="true"*)wire [ 7:0]  acf_axis_line_id;
(*mark_debug="true"*)wire         acf_axis_eop;

reg          tm_vreg;
reg  [115:0] tm_dreg;

/*----------------------------------------------------------------------
                                统计信息
----------------------------------------------------------------------*/
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        ov_send_pkt_cnt <= 64'b0;
        ov_send_tm_cnt  <= 64'b0;
    end
    else begin
        ov_send_pkt_cnt <= ov_send_pkt_cnt + (m_axis_tready && m_axis_tvalid && m_axis_tlast);
        ov_send_tm_cnt  <= ov_send_tm_cnt  + (m_tm_axis_tready && m_tm_axis_tvalid);
    end
end
 /*----------------------------------------------------------------------
                                发送格式处理
----------------------------------------------------------------------*/
always @(*) begin
    acf_axis_tready = m_axis_tready;
    
    m_axis_tuser  = acf_axis_tuser;
    if(acf_axis_sop == 1'b1) begin
        m_axis_tvalid = 1'b0;
        m_axis_tkeep  = 16'b0;
        m_axis_tdata  = 128'b0;
        m_axis_tlast  = 1'b0;
    end
    else begin
        m_axis_tvalid = acf_axis_tvalid;
        m_axis_tkeep  = acf_axis_tkeep;
        m_axis_tdata  = acf_axis_tdata;
        m_axis_tlast  = acf_axis_tlast;
    end
end
/*----------------------------------------------------------------------
                                遥测信息输出
----------------------------------------------------------------------*/
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        tm_vreg <= 1'b0;
        tm_dreg <= 116'b0;
    end
    else begin
        tm_vreg <= m_tm_axis_tvalid;
        tm_dreg <= m_tm_axis_tdata;
    end
end

always @(*) begin
    if((acf_axis_sop == 1'b1) && (acf_axis_tdata[100] == 1'b1))begin//输出遥测标记有效
        m_tm_axis_tvalid = 1'b1;
        m_tm_axis_tdata  = {5'b0,acf_axis_tdata[111:101],iv_local_cnt,acf_axis_tdata[83:48]};//pkt_len+timestamp+flowlabel+tagid
    end
    else if(m_tm_axis_tready == 1'b1)begin
        m_tm_axis_tvalid = 1'b0;
        m_tm_axis_tdata  = tm_dreg;
    end
    else begin
        m_tm_axis_tvalid = tm_vreg;
        m_tm_axis_tdata  = tm_dreg;
    end
end
/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
PktLineDet #(
    .WIDTH              (8)
)saxis_inst(
    .user_clk           (m_axis_clk               ),
    .user_rst_n         (m_axis_rst_n             ),
    
    .valid              (acf_axis_tvalid & acf_axis_tready),
    .last               (acf_axis_tlast           ),
    .sop                (acf_axis_sop             ),
    .line_id            (acf_axis_line_id         ),
    .eop                (acf_axis_eop             )
);

AXISFifoBuf #(
    .ASYNC_EN               ( 1                 ),
    .DEEP_WIDTH             ( 6                 ),
    .PKT_MODE               ( 1                 ),
    .DATA_BYTE              ( 16                ),
    .USER_BIT               ( 1                 )
)TxFifoBuf(  
    //ports 
    .s_axis_clk             ( s_axis_clk        ),
    .s_axis_rst_n           ( s_axis_rst_n      ),
        
    .m_axis_clk             ( m_axis_clk        ),
    .m_axis_rst_n           ( m_axis_rst_n      ),
        
    .s_axis_tready          ( s_axis_tready     ),
    .s_axis_tvalid          ( s_axis_tvalid     ),
    .s_axis_tkeep           ( s_axis_tkeep      ),
    .s_axis_tdata           ( s_axis_tdata      ),
    .s_axis_tlast           ( s_axis_tlast      ),
    .s_axis_tuser           ( s_axis_tuser      ),
        
    .m_axis_tready          ( acf_axis_tready   ),
    .m_axis_tvalid          ( acf_axis_tvalid   ),
    .m_axis_tkeep           ( acf_axis_tkeep    ),
    .m_axis_tdata           ( acf_axis_tdata    ),
    .m_axis_tlast           ( acf_axis_tlast    ),
    .m_axis_tuser           ( acf_axis_tuser    ),
        
    .free_space             ( acf_free_space    ),
    .used_space             ( acf_used_space    )
);  
endmodule

/*
SRv6TransFmtCov SRv6TransFmtCov_Inst(
//时钟复位信号
    .s_axis_clk    (),
    .s_axis_rst_n  (),
    .m_axis_clk    (),
    .m_axis_rst_n  (),
    //本地同步时钟        
    .iv_local_cnt  (),
//报文分组数据接收接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//分组数据输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
//遥测数据输出接口
    .m_tm_axis_tready(),
    .m_tm_axis_tvalid(),
    .m_tm_axis_tdata (),
//统计信息
    .ov_send_pkt_cnt(),
    .ov_send_tm_cnt ()
);
*/