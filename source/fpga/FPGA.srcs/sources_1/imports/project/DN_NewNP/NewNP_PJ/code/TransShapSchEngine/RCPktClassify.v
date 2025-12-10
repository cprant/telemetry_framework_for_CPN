/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  RCPktClassify.v
Target Device All
Dscription 
    1)根据Metadata中的类型域对输入的报文进行分类
    2)对于RC类型流测速模块处理，否则作为BE普通报文直通，送入缓存FIFO准备输出
    
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


Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module RCPktClassify(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
//分组数据输入接口
(*mark_debug="true"*)    output reg          s_axis_tready,
(*mark_debug="true"*)    input  wire         s_axis_tvalid,
(*mark_debug="true"*)    input  wire [ 15:0] s_axis_tkeep ,
(*mark_debug="true"*)    input  wire [127:0] s_axis_tdata ,
(*mark_debug="true"*)    input  wire         s_axis_tlast ,
(*mark_debug="true"*)    input  wire [  0:0] s_axis_tuser ,
//分组数据输出接口
(*mark_debug="true"*)    input  wire         m_be_axis_tready,
(*mark_debug="true"*)    output wire         m_be_axis_tvalid,
(*mark_debug="true"*)    output wire [ 15:0] m_be_axis_tkeep ,
(*mark_debug="true"*)    output wire [127:0] m_be_axis_tdata ,
(*mark_debug="true"*)    output wire         m_be_axis_tlast ,
(*mark_debug="true"*)    output wire [  0:0] m_be_axis_tuser ,
    
(*mark_debug="true"*)    input  wire         m_rc_axis_tready,
(*mark_debug="true"*)    output wire         m_rc_axis_tvalid,
(*mark_debug="true"*)    output wire [ 15:0] m_rc_axis_tkeep ,
(*mark_debug="true"*)    output wire [127:0] m_rc_axis_tdata ,
(*mark_debug="true"*)    output wire         m_rc_axis_tlast ,
(*mark_debug="true"*)    output wire [  0:0] m_rc_axis_tuser 
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
(*mark_debug="true"*)wire         s_axis_sop;
(*mark_debug="true"*)wire [  7:0] s_axis_line_id;
(*mark_debug="true"*)wire         s_axis_eop;

(*mark_debug="true"*)wire         disp_axis_tready;
(*mark_debug="true"*)reg          disp_axis_tvalid;
(*mark_debug="true"*)reg  [ 15:0] disp_axis_tkeep ;
(*mark_debug="true"*)reg  [127:0] disp_axis_tdata ;
(*mark_debug="true"*)reg          disp_axis_tlast ;
(*mark_debug="true"*)reg  [  0:0] disp_axis_tuser ;
(*mark_debug="true"*)reg  [  1:0] disp_axis_tdest ;

(*mark_debug="true"*)reg  [  1:0] disp_axis_tdest_reg;

(*mark_debug="true"*)reg  [ 63:0] rcv_pkt_cnt,send_rcpkt_cnt,send_bepkt_cnt;

/*-----------------------------------------------------------------------
                    报文分类计数
-----------------------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin

    if(axis_rst_n == 1'b0)begin
        rcv_pkt_cnt         <= 64'd0;
        send_rcpkt_cnt      <= 64'd0;
        send_bepkt_cnt      <= 64'd0;
    end
    else begin
        if(s_axis_tready == 1'b1 && s_axis_tvalid && 1'b1 && s_axis_tlast == 1'b1)begin
            rcv_pkt_cnt         <= rcv_pkt_cnt + 64'd1;
        end
        else begin
            rcv_pkt_cnt         <= rcv_pkt_cnt ;
        end
        
        if(m_be_axis_tready == 1'b1 && m_be_axis_tvalid && 1'b1 && m_be_axis_tlast == 1'b1)begin
            send_bepkt_cnt      <= send_bepkt_cnt + 64'd1;
        end
        else begin
            send_bepkt_cnt      <= send_bepkt_cnt ;
        end
        
        if(m_rc_axis_tready == 1'b1 && m_rc_axis_tvalid && 1'b1 && m_rc_axis_tlast == 1'b1)begin
            send_rcpkt_cnt      <= send_rcpkt_cnt + 64'd1;
        end
        else begin
            send_rcpkt_cnt      <= send_rcpkt_cnt ;
        end
    end


end

/*-----------------------------------------------------------------------
                    测速报文分类
-----------------------------------------------------------------------*/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        disp_axis_tdest_reg   <= 2'b0;
    end
    else begin
        disp_axis_tdest_reg   <= disp_axis_tdest;
    end
end

always @(*) begin
    s_axis_tready   = disp_axis_tready;
    disp_axis_tvalid = s_axis_tvalid;
    disp_axis_tkeep  = s_axis_tkeep;
    disp_axis_tdata  = s_axis_tdata;
    disp_axis_tlast  = s_axis_tlast;
    disp_axis_tuser  = s_axis_tuser;
    if(s_axis_sop == 1'b1)
        if(s_axis_tdata[98] == 1'b1)//SRv6,且FUNC为整形转发
            disp_axis_tdest  = 2'b10;
        else
            disp_axis_tdest  = 2'b01;
    else
        disp_axis_tdest  = disp_axis_tdest_reg;
end
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
PktLineDet #(8) SaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( s_axis_tready & s_axis_tvalid),
    .last                   ( s_axis_tlast      ),
                            
    .sop                    ( s_axis_sop        ),
    .line_id                ( s_axis_line_id    ),
    .eop                    ( s_axis_eop        )
);

AXISDisp#(
    .STREAM_SUM             (2),
    .DATA_BYTE              (16),
    .USER_BIT               (1)
)
AXISDisp_Inst(  
    .s_axis_clk             (axis_clk  ),
    .s_axis_rst_n           (axis_rst_n),
    
    .s_axis_tready          (disp_axis_tready),
    .s_axis_tvalid          (disp_axis_tvalid),
    .s_axis_tkeep           (disp_axis_tkeep ),
    .s_axis_tdata           (disp_axis_tdata ),
    .s_axis_tlast           (disp_axis_tlast ),
    .s_axis_tuser           (disp_axis_tuser ),
    .s_axis_tdst            (disp_axis_tdest ),
    
    .m_axis_tready          ({m_rc_axis_tready,m_be_axis_tready}),
    .m_axis_tvalid          ({m_rc_axis_tvalid,m_be_axis_tvalid}),
    .m_axis_tkeep           ({m_rc_axis_tkeep ,m_be_axis_tkeep }),
    .m_axis_tdata           ({m_rc_axis_tdata ,m_be_axis_tdata }),
    .m_axis_tlast           ({m_rc_axis_tlast ,m_be_axis_tlast }),
    .m_axis_tuser           ({m_rc_axis_tuser ,m_be_axis_tuser })
);
endmodule
/*
RCPktClassify RCPktClassify_Inst(
//时钟复位信号
    .axis_clk        (),
    .axis_rst_n      (),
//分组数据输入接口
    .s_axis_tready   (),
    .s_axis_tvalid   (),
    .s_axis_tkeep    (),
    .s_axis_tdata    (),
    .s_axis_tlast    (),
    .s_axis_tuser    (),
//分组数据输出接口
    .m_be_axis_tready(),
    .m_be_axis_tvalid(),
    .m_be_axis_tkeep (),
    .m_be_axis_tdata (),
    .m_be_axis_tlast (),
    .m_be_axis_tuser (),  
                     
    .m_rc_axis_tready(),
    .m_rc_axis_tvalid(),
    .m_rc_axis_tkeep (),
    .m_rc_axis_tdata (),
    .m_rc_axis_tlast (),
    .m_rc_axis_tuser ()
);
*/