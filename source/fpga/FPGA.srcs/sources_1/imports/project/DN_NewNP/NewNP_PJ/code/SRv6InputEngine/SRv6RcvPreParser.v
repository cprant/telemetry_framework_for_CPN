/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  SRv6RcvPreParser.v
Target Device All
Dscription 
    1)预解析主要负责根据分组以太网长度类型域及IPv6字段解析出分组类型
    2)根据提取和确认的分类信息构造Metadata

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

    2)NewNP支持的FUNC编码功能SID[63:48]
        0x1000：SRv6转发
        0x1001：SRv6转发，入口遥测
        0x1010：SRv6转发，出口遥测
        0x1011：SRv6转发，入出遥测
        0x8000：整形转发
        0x8001：整形转发，入口遥测
        0x8010：整形转发，出口遥测
        0x8011：整形转发，入出遥测

Caution: 
    1)默认输入数据128bit
    2)每个报文提取信息均为一行，默认对端必定可接收该解析信息，无需控制反压
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6RcvPreParser #(
    parameter   PORT_ID     = 8'd0
)(
//时钟复位信号
    input  wire               axis_clk,
    input  wire               axis_rst_n,
//本地同步时钟        
    input  wire [       63:0] iv_local_cnt,
//报文分组数据接收接口
(*mark_debug="true"*)    input  wire               s_axis_tready,
(*mark_debug="true"*)    input  wire               s_axis_tvalid,
(*mark_debug="true"*)    input  wire [       15:0] s_axis_tkeep,
(*mark_debug="true"*)    input  wire [      127:0] s_axis_tdata,
(*mark_debug="true"*)    input  wire               s_axis_tlast,
(*mark_debug="true"*)    input  wire               s_axis_tuser,
//Metadata数据输出     接口
(*mark_debug="true"*)    output reg                o_md_tvalid,
(*mark_debug="true"*)    output reg  [      127:0] ov_md_tdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
(*mark_debug="true"*)wire         s_axis_sop;
(*mark_debug="true"*)wire [  3:0] s_axis_line_id;
(*mark_debug="true"*)wire         s_axis_eop;

(*mark_debug="true"*)reg  [ 63:0] rcvfrm_timestamp;
(*mark_debug="true"*)reg  [ 15:0] rcvfrm_ethtype;
(*mark_debug="true"*)reg  [ 19:0] rcvfrm_flowid;
(*mark_debug="true"*)reg  [  7:0] rcvfrm_ipv6_nh;
(*mark_debug="true"*)reg  [ 15:0] rcvfrm_ipv6_func;
(*mark_debug="true"*)reg cur_md_state,nxt_md_state;
localparam  IDLE_S  = 1'd0,
            PARSE_S = 1'd1;
/*----------------------------------------------------------
                    接收解析
----------------------------------------------------------*/
always @(posedge axis_clk) begin
    rcvfrm_timestamp   <= (s_axis_sop == 1'd1) ? 
                           iv_local_cnt : rcvfrm_timestamp;
    rcvfrm_ethtype     <= (s_axis_sop == 1'd1) ? 
                           s_axis_tdata[31:16] : rcvfrm_ethtype;//以太网二层协议号
    rcvfrm_ipv6_nh     <= (s_axis_line_id == 4'd1) ? 
                           s_axis_tdata[95:88] : rcvfrm_ipv6_nh;//IPv6 NextHeader
    rcvfrm_ipv6_func   <= (s_axis_line_id == 4'd2) ? 
                           s_axis_tdata[15:0] : rcvfrm_ipv6_func;//IPv6 DIP[63:48]-FUNC字段
    if(s_axis_sop == 1'd1)
        if(s_axis_tdata[31:16] == 16'hFF01)//TSMP取MID(DMAC[23:12])
            rcvfrm_flowid <= {8'b0,s_axis_tdata[103:92]};
        else//预提取IPv6的FlowLabel[19:16]
            rcvfrm_flowid <= {s_axis_tdata[3:0],16'b0};
    else if((s_axis_line_id == 4'd1) && (rcvfrm_ethtype == 16'h86DD))//IPv6取FlowLabel[15:0]
        rcvfrm_flowid <= {rcvfrm_flowid[19:16],s_axis_tdata[127:112]};
    else
        rcvfrm_flowid <= rcvfrm_flowid;
end


//MD状态机
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)
        cur_md_state <= IDLE_S;
    else
        cur_md_state <= nxt_md_state;
end

always @(*) begin
    case(cur_md_state)
        IDLE_S: begin
            o_md_tvalid = 1'b0;
            ov_md_tdata = 127'b0;
            if(s_axis_sop == 1'd1)
                nxt_md_state = PARSE_S;
            else
                nxt_md_state = IDLE_S;
        end
        
        PARSE_S: begin
            ov_md_tdata[127:120] = PORT_ID;//输入端口
            ov_md_tdata[119:112] = PORT_ID;//输出端口
            ov_md_tdata[111:101] = 11'd0;//报文长度,本模块无法填写,需要将长度填写到tuser,让后续的模块开始添加
            ov_md_tdata[ 97: 88] = 10'd0;//保留位
            ov_md_tdata[ 83: 64] = rcvfrm_flowid;//流ID
            ov_md_tdata[ 47:  0] = rcvfrm_timestamp[47:0];//接收时间戳
            
            if((s_axis_tready == 1'b1) && (s_axis_tvalid == 1'b1) &&
              ((s_axis_line_id == 4'd3) || (s_axis_tlast == 1'b1)))begin//传到第4拍或者报文尾时开始构造MD并输出
                o_md_tvalid = 1'b1;
                if(rcvfrm_ethtype == 16'hFF01) begin//TSMP
                    ov_md_tdata[100:99] = 2'd0;
                    ov_md_tdata[    98] = 1'b0;//整形标记
                    ov_md_tdata[ 87:84] = 4'd8;
                    ov_md_tdata[ 63:48] = 16'b0;
                end
                else if(rcvfrm_ethtype == 16'h86DD) begin//IPv6
                    if(rcvfrm_ipv6_nh == 8'd43) begin//SRv6
                        ov_md_tdata[   100] = ((rcvfrm_ipv6_func == 16'h1010) || 
                                               (rcvfrm_ipv6_func == 16'h1011) || 
                                               (rcvfrm_ipv6_func == 16'h8010) || 
                                               (rcvfrm_ipv6_func == 16'h8011));//输出遥测标记
                        ov_md_tdata[   99]  = ((rcvfrm_ipv6_func == 16'h1001) || 
                                               (rcvfrm_ipv6_func == 16'h1011) || 
                                               (rcvfrm_ipv6_func == 16'h8001) || 
                                               (rcvfrm_ipv6_func == 16'h8011));//输入遥测标记  
                        ov_md_tdata[     98] = rcvfrm_ipv6_func[15];//整形标记                                
                        ov_md_tdata[ 87: 84] = (s_axis_tdata[55:48] == 8'd0) ? 
                                                4'd4 : 4'd0;//出口节点SRv6报文 : 转发处理SRv6
                        ov_md_tdata[ 63: 48] = s_axis_tdata[32:16];//流编号,SRv6-Tag域        
                    end
                    else begin//其他IPv6
                        ov_md_tdata[100:99] = 2'd0;
                        ov_md_tdata[    98] = 1'b0;//整形标记
                        ov_md_tdata[ 87:84] = 4'd1;
                        ov_md_tdata[ 63:48] = 16'b0;
                    end
                end
                else begin//丢弃帧
                    ov_md_tdata[100:99] = 2'd0;
                    ov_md_tdata[    98] = 1'b0;//整形标记
                    ov_md_tdata[ 87:84] = 4'd15;
                    ov_md_tdata[ 63:48] = 16'b0;
                end
                nxt_md_state = IDLE_S;
            end
            else begin
                o_md_tvalid         = 1'b0;
                ov_md_tdata[100:99] = 2'd0;
                ov_md_tdata[    98] = 1'b0;//整形标记
                ov_md_tdata[ 87:84] = 4'd15;
                ov_md_tdata[ 63:48] = 16'b0;
                nxt_md_state = PARSE_S;
            end
        end
        
        default: begin
            o_md_tvalid  = 1'b0;
            ov_md_tdata  = 127'b0;
            nxt_md_state = IDLE_S;
        end
    endcase
end

/*----------------------------------------------------------
                   IP调用区域
----------------------------------------------------------*/
PktLineDet #(4) SaxisLineDet_Inst(  //识别并标记输入分组数据首尾行号等位置标记
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
SRv6RcvPreParser #(
    .PORT_ID                (PORT_ID)
)SRv6RPP_Inst(  
    //时钟复位信号    
    .axis_clk               (),
    .axis_rst_n             (),
    //本地同步时钟        
    .iv_local_cnt           (),
    //报文分组数据接收接口
    .s_axis_tready          (),
    .s_axis_tvalid          (),
    .s_axis_tkeep           (),
    .s_axis_tdata           (),
    .s_axis_tlast           (),
    .s_axis_tuser           (),
    //Metadata数据输出接口
    .o_md_tvalid            (),
    .ov_md_tdata            ()
);
*/