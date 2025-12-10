/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  SRv6KeyParser.v
Target Device All
Dscription 
    1)监听传输的IPv6报文，从中提取SRv6查表所需的五元组信息
    2)拼接为关键字送往通用寄存器并行查表IP进行查表

Data_Struct:
    1)Metadata    
        [127:120] 输入端口号 8	输入端口号
        [119:112] 输出端口号 8	输出端口号
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [     98] 整形标记  1   整形转发标记  1代表整形
        [ 97: 88] 保留      10	保留位
        [ 87: 84] 帧类型	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6帧
            1:IPv6-其他帧
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4:出口节点SRv6报文，上报CPU
            5-7:保留
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
        
    2) 关键字key
        [175:160] IPv6+SRv6 Next_Header
            8 ipv6_nh
            8 srv6_nh
        [159:144] 源端口
        [143:128] 目的端口
        [127: 64] 源ipv6高64位
        [ 63:  0] 目的ipv6高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)

Caution: 
    1)默认输入数据128bit
    2)每个报文提取信息均为一行，默认对端必定可接收该解析信息，无需控制反压
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6KeyParser(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
//报文分组数据接收接口
    output wire         s_axis_tready,
    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep,
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tlast,
    input  wire         s_axis_tuser,
//关键字输出
(*mark_debug="true"*)    input  wire         m_key_axis_tready,
(*mark_debug="true"*)    output reg          m_key_axis_tvalid,
(*mark_debug="true"*)    output reg  [175:0] m_key_axis_tdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire         s_axis_sop;
wire [  7:0] s_axis_line_id;
wire         s_axis_eop;

(*mark_debug="true"*)reg  [  3:0] cur_rcvfrm_md_type ,nxt_rcvfrm_md_type ;
(*mark_debug="true"*)reg  [  7:0] cur_rcvfrm_ipv6_nh ,nxt_rcvfrm_ipv6_nh ;
(*mark_debug="true"*)reg  [ 63:0] cur_rcvfrm_sip     ,nxt_rcvfrm_sip     ;
(*mark_debug="true"*)reg  [ 63:0] cur_rcvfrm_dip     ,nxt_rcvfrm_dip     ;
(*mark_debug="true"*)reg  [  7:0] cur_rcvfrm_srv6_nh ,nxt_rcvfrm_srv6_nh ;
(*mark_debug="true"*)reg  [ 15:0] cur_rcvfrm_srv6_hel,nxt_rcvfrm_srv6_hel;//hdr_ext_len
(*mark_debug="true"*)reg  [ 15:0] cur_rcvfrm_sport   ,nxt_rcvfrm_sport   ;
(*mark_debug="true"*)reg  [ 15:0] cur_rcvfrm_dport   ,nxt_rcvfrm_dport   ;

/*----------------------------------------------------------
                    接收解析
----------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        cur_rcvfrm_md_type    <= 4'd0 ;
        cur_rcvfrm_ipv6_nh    <= 8'd0 ;
        cur_rcvfrm_sip        <= 64'd0;
        cur_rcvfrm_dip        <= 64'd0;
        cur_rcvfrm_srv6_nh    <= 8'd0 ;
        cur_rcvfrm_srv6_hel   <= 16'd0;
        cur_rcvfrm_sport      <= 16'd0;
        cur_rcvfrm_dport      <= 16'd0;
    end
    else begin
        cur_rcvfrm_md_type    <= nxt_rcvfrm_md_type ;
        cur_rcvfrm_ipv6_nh    <= nxt_rcvfrm_ipv6_nh ;
        cur_rcvfrm_sip        <= nxt_rcvfrm_sip     ;
        cur_rcvfrm_dip        <= nxt_rcvfrm_dip     ;
        cur_rcvfrm_srv6_nh    <= nxt_rcvfrm_srv6_nh ;
        cur_rcvfrm_srv6_hel   <= nxt_rcvfrm_srv6_hel;
        cur_rcvfrm_sport      <= nxt_rcvfrm_sport   ;
        cur_rcvfrm_dport      <= nxt_rcvfrm_dport   ;
    end
end

always @(*) begin
    nxt_rcvfrm_md_type    = (s_axis_sop == 1'd1) ? 
                             s_axis_tdata[87:84] : cur_rcvfrm_md_type;
    nxt_rcvfrm_ipv6_nh    = (s_axis_line_id == 8'd2) ? 
                             s_axis_tdata[95:88] : cur_rcvfrm_ipv6_nh;//IPv6 Next_Header
    nxt_rcvfrm_sip        = (s_axis_line_id == 8'd2) ? 
                             s_axis_tdata[79:16] : cur_rcvfrm_sip;//IPv6 源IP高64bit
    nxt_rcvfrm_dip        = (s_axis_line_id == 8'd3) ? 
                             s_axis_tdata[79:16] : cur_rcvfrm_dip;//IPv6 目的IP高64bit

    if((nxt_rcvfrm_md_type == 4'd0) || 
       (nxt_rcvfrm_md_type == 4'd3) || 
       (nxt_rcvfrm_md_type == 4'd4)) begin// SRV6     
        nxt_rcvfrm_srv6_nh    = (s_axis_line_id == 8'd4) ? 
                                 s_axis_tdata[79:72] : cur_rcvfrm_srv6_nh;//SRv6 Next_Header
        nxt_rcvfrm_srv6_hel   = (s_axis_line_id == 8'd4) ? 
                                 s_axis_tdata[71:64] : cur_rcvfrm_srv6_hel;//SRv6 hdr_ext_len
        nxt_rcvfrm_sport = (s_axis_line_id == (4'd4+nxt_rcvfrm_srv6_hel[7:1])) ? 
                            s_axis_tdata[15:0] : cur_rcvfrm_sport;//SRv6+UDP/TCP sport
        nxt_rcvfrm_dport = (s_axis_line_id == (4'd5+nxt_rcvfrm_srv6_hel[7:1])) ? 
                            s_axis_tdata[127:112] : cur_rcvfrm_dport;//SRv6+UDP/TCP dport
    end
    else begin//默认是IPv6
        nxt_rcvfrm_srv6_nh    = 8'b0;//SRv6 Next_Header
        nxt_rcvfrm_srv6_hel   = 8'b0;//SRv6 hdr_ext_len
        nxt_rcvfrm_sport = (s_axis_line_id == 8'd4) ? 
                             s_axis_tdata[79:64] : cur_rcvfrm_sport;//IPv6+UDP/TCP sport
        nxt_rcvfrm_dport = (s_axis_line_id == 8'd4) ? 
                                 s_axis_tdata[63:48] : cur_rcvfrm_dport;//IPv6+UDP/TCP dport
    end
end
/*----------------------------------------------------------
                    关键字生成
----------------------------------------------------------*/
assign s_axis_tready = m_key_axis_tready;

always @(*) begin
    m_key_axis_tdata  = {nxt_rcvfrm_ipv6_nh,
                         nxt_rcvfrm_srv6_nh,
                         nxt_rcvfrm_sport,
                         nxt_rcvfrm_dport,
                         nxt_rcvfrm_sip,
                         nxt_rcvfrm_dip};

    m_key_axis_tvalid = ((s_axis_tready == 1'b1) && 
                         (s_axis_tvalid == 1'b1) &&
                         ( (s_axis_line_id == (4'd5+nxt_rcvfrm_srv6_hel[7:1])) || 
                           ((s_axis_line_id < (4'd5+nxt_rcvfrm_srv6_hel[7:1])) && (s_axis_tlast == 1'b1))
                         )
                        );
end
/*----------------------------------------------------------
                   IP调用区域
----------------------------------------------------------*/
PktLineDet #(8) SaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( s_axis_tready & s_axis_tvalid),
    .last                   ( s_axis_tlast      ),
                            
    .sop                    ( s_axis_sop        ),
    .line_id                ( s_axis_line_id    ),
    .eop                    ( s_axis_eop        )
);

endmodule
/*
SRv6KeyParser SRv6KeyParser_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//报文分组数据接收接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//关键字输出
    .m_key_axis_tready(),
    .m_key_axis_tvalid(),
    .m_key_axis_tdata ()
);
*/