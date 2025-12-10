/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  FlowMeter.v
Target Device All
Dscription 
    1)实现令牌桶机制
    2)根据RC流IPv6中的Flow Lable标识作为流ID，支持RC流单流测速

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
        
    2)des_tdata    
        [ 30: 26]   分组输入端口号     1  
        [ 25: 14]   分组长度           12  
        [ 13:  0]   STREAM_ID          14  
Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module FlowMeter(
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
(*mark_debug="true"*)    input  wire         m_axis_tready,
(*mark_debug="true"*)    output reg          m_axis_tvalid,
(*mark_debug="true"*)    output reg  [ 15:0] m_axis_tkeep ,
(*mark_debug="true"*)    output reg  [127:0] m_axis_tdata ,
(*mark_debug="true"*)    output reg          m_axis_tlast ,
(*mark_debug="true"*)    output reg  [  0:0] m_axis_tuser ,
//配置管理接口         
    input  wire         s_lb_cs_n ,
    output wire         s_lb_ack_n,
    input  wire         s_lb_wr_rd,
    input  wire [ 31:0] s_lb_addr ,
    input  wire [ 31:0] s_lb_wdata,
    output wire [ 31:0] s_lb_rdata
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
(*mark_debug="true"*)wire         s_axis_sop;
(*mark_debug="true"*)wire [  7:0] s_axis_line_id;
(*mark_debug="true"*)wire         s_axis_eop;

(*mark_debug="true"*)reg          w_des_tvalid ;
(*mark_debug="true"*)reg  [ 30:0] wv_des_tdata ;
(*mark_debug="true"*)wire [  1:0] wv_pkt_discard;//[1]valid [0]discard

(*mark_debug="true"*)wire         ipkt_axis_tready;
(*mark_debug="true"*)reg          ipkt_axis_tvalid;
(*mark_debug="true"*)reg  [ 15:0] ipkt_axis_tkeep ;
(*mark_debug="true"*)reg  [127:0] ipkt_axis_tdata ;
(*mark_debug="true"*)reg          ipkt_axis_tlast ;
(*mark_debug="true"*)reg  [  0:0] ipkt_axis_tuser ;

(*mark_debug="true"*)reg          opkt_axis_tready;
(*mark_debug="true"*)wire         opkt_axis_tvalid;
(*mark_debug="true"*)wire [ 15:0] opkt_axis_tkeep ;
(*mark_debug="true"*)wire [127:0] opkt_axis_tdata ;
(*mark_debug="true"*)wire         opkt_axis_tlast ;
(*mark_debug="true"*)wire [  0:0] opkt_axis_tuser ;

(*mark_debug="true"*)wire [ 31:0] acf_free_space;

(*mark_debug="true"*)wire         irsl_axis_tready;
(*mark_debug="true"*)reg          irsl_axis_tvalid;
(*mark_debug="true"*)reg  [  0:0] irsl_axis_tkeep ;
(*mark_debug="true"*)reg  [  7:0] irsl_axis_tdata ;
(*mark_debug="true"*)reg          irsl_axis_tlast ;
(*mark_debug="true"*)reg  [  0:0] irsl_axis_tuser ;
       
(*mark_debug="true"*)reg          orsl_axis_tready;
(*mark_debug="true"*)wire         orsl_axis_tvalid;
(*mark_debug="true"*)wire [  0:0] orsl_axis_tkeep ;
(*mark_debug="true"*)wire [  7:0] orsl_axis_tdata ;
(*mark_debug="true"*)wire         orsl_axis_tlast ;
(*mark_debug="true"*)wire [  0:0] orsl_axis_tuser ;

(*mark_debug="true"*)wire [ 31:0] rsl_free_space;

(*mark_debug="true"*)reg  [  1:0] cur_fm_state,nxt_fm_state;
localparam  IDLE_S  = 2'd0,
            TRANS_S = 2'd1,
            DISC_S  = 2'd2;
            


(*mark_debug="true"*)reg  [ 63:0] rcv_pkt_cnt,send_pkt_cnt;

(*mark_debug="true"*)wire [ 31:0] wv_pkt_outputbit;

(*mark_debug="true"*)wire [  7:0] outport_binary;

/*-----------------------------------------------------------------------
                    报文分类计数
-----------------------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin

    if(axis_rst_n == 1'b0)begin
        rcv_pkt_cnt         <= 64'd0;
        send_pkt_cnt      <= 64'd0;
    end
    else begin
        if(s_axis_tready == 1'b1 && s_axis_tvalid && 1'b1 && s_axis_tlast == 1'b1)begin
            rcv_pkt_cnt         <= rcv_pkt_cnt + 64'd1;
        end
        else begin
            rcv_pkt_cnt         <= rcv_pkt_cnt ;
        end
        
        if(m_axis_tready == 1'b1 && m_axis_tvalid && 1'b1 && m_axis_tlast == 1'b1)begin
            send_pkt_cnt      <= send_pkt_cnt + 64'd1;
        end
        else begin
            send_pkt_cnt      <= send_pkt_cnt ;
        end
    end


end


/*-----------------------------------------------------------------------
                    令牌桶查表请求生成
-----------------------------------------------------------------------*/

always @(*) begin
    s_axis_tready    = ipkt_axis_tready & irsl_axis_tready;
    ipkt_axis_tvalid = s_axis_tvalid;
    ipkt_axis_tkeep  = s_axis_tkeep;
    ipkt_axis_tdata  = s_axis_tdata;
    ipkt_axis_tlast  = s_axis_tlast;
    ipkt_axis_tuser  = s_axis_tuser;
    if(s_axis_sop == 1'b1) begin
        w_des_tvalid = 1'b1;
        wv_des_tdata = {s_axis_tdata[124:120],
                        1'b0,s_axis_tdata[111:101],
                        s_axis_tdata[ 77: 64]};
    end
    else begin
        w_des_tvalid = 1'b0;
        wv_des_tdata = 31'b0;
    end
end
/*-----------------------------------------------------------------------
                    令牌桶查表结果处理
-----------------------------------------------------------------------*/
always @(*) begin
    irsl_axis_tvalid = wv_pkt_discard[1];
    irsl_axis_tkeep  = 1'b1;
    irsl_axis_tdata  = outport_binary;
    irsl_axis_tlast  = 1'b1;
    irsl_axis_tuser  = wv_pkt_discard[0];
end
/*-----------------------------------------------------------------------
                    输出报文处理
-----------------------------------------------------------------------*/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'd0) begin
        cur_fm_state <= IDLE_S;
    end              
    else begin       
        cur_fm_state <= nxt_fm_state;
    end
end

always @(*) begin
    m_axis_tkeep  = opkt_axis_tkeep;
    m_axis_tdata  = opkt_axis_tdata;
    m_axis_tlast  = opkt_axis_tlast;
    m_axis_tuser  = opkt_axis_tuser;
    case(cur_fm_state)
        IDLE_S: begin
            if((orsl_axis_tvalid == 1'b1) && 
               (opkt_axis_tvalid == 1'b1) && 
               (m_axis_tready == 1'b1)) begin//有报文查表完成待处理
                orsl_axis_tready = 1'b1;
                opkt_axis_tready = 1'b1;
                if(orsl_axis_tuser == 1'b1) begin//限速丢弃报文
                    m_axis_tvalid = 1'b0;
                    nxt_fm_state  = DISC_S;
                end
                else begin
                    m_axis_tvalid = 1'b1;
                    nxt_fm_state  = TRANS_S;
                end
                
                m_axis_tdata[119:112] = orsl_axis_tdata;
                
            end
            else begin
            
                m_axis_tdata[119:112] = opkt_axis_tdata[119:112];
            
                orsl_axis_tready = 1'b0;
                opkt_axis_tready = 1'b0;
                m_axis_tvalid = 1'b0;
                nxt_fm_state  = IDLE_S;
            end
        end
        
        TRANS_S: begin
            orsl_axis_tready = 1'b0;
            opkt_axis_tready = m_axis_tready;
            m_axis_tvalid = opkt_axis_tvalid;
            if((m_axis_tready == 1'b1)&& 
               (opkt_axis_tvalid == 1'b1) && 
               (opkt_axis_tlast  == 1'b1)) begin
                nxt_fm_state  = IDLE_S;
            end
            else begin
                nxt_fm_state  = TRANS_S;
            end
        end
        
        DISC_S: begin
            orsl_axis_tready = 1'b0;
            opkt_axis_tready = 1'b1;
            m_axis_tvalid = 1'b0;
            if((opkt_axis_tvalid == 1'b1) && 
               (opkt_axis_tlast  == 1'b1)) begin
                nxt_fm_state  = IDLE_S;
            end
            else begin
                nxt_fm_state  = DISC_S;
            end
        end
        
        default: begin
            orsl_axis_tready = 1'b0;
            opkt_axis_tready = 1'b0;
            m_axis_tvalid = 1'b0;
            nxt_fm_state  = IDLE_S;
        end
    endcase
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

AXISFifoBuf#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH (6),//缓存FIFO的容量的指数位宽
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (16),
    .USER_BIT   (1),
    .MIN_PKTLINE(4)
)PktFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk   (axis_clk   ),
    .s_axis_rst_n (axis_rst_n ),
    .m_axis_clk   (axis_clk   ),
    .m_axis_rst_n (axis_rst_n ),
//AXI Stream输入接口
    .s_axis_tready(ipkt_axis_tready),
    .s_axis_tvalid(ipkt_axis_tvalid),
    .s_axis_tkeep (ipkt_axis_tkeep ),
    .s_axis_tdata (ipkt_axis_tdata ),
    .s_axis_tlast (ipkt_axis_tlast ),
    .s_axis_tuser (ipkt_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(opkt_axis_tready),
    .m_axis_tvalid(opkt_axis_tvalid),
    .m_axis_tkeep (opkt_axis_tkeep ),
    .m_axis_tdata (opkt_axis_tdata ),
    .m_axis_tlast (opkt_axis_tlast ),
    .m_axis_tuser (opkt_axis_tuser ),
//状态信号                               
    .free_space   (acf_free_space      ),
    .used_space   (                    )
);

AXISFifoBuf#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH (6),//缓存FIFO的容量的指数位宽
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (1),
    .USER_BIT   (1),
    .MIN_PKTLINE(1)
)RslFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk   (axis_clk   ),
    .s_axis_rst_n (axis_rst_n ),
    .m_axis_clk   (axis_clk   ),
    .m_axis_rst_n (axis_rst_n ),
//AXI Stream输入接口
    .s_axis_tready(irsl_axis_tready),
    .s_axis_tvalid(irsl_axis_tvalid),
    .s_axis_tkeep (irsl_axis_tkeep ),
    .s_axis_tdata (irsl_axis_tdata ),
    .s_axis_tlast (irsl_axis_tlast ),
    .s_axis_tuser (irsl_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(orsl_axis_tready),
    .m_axis_tvalid(orsl_axis_tvalid),
    .m_axis_tkeep (orsl_axis_tkeep ),
    .m_axis_tdata (orsl_axis_tdata ),
    .m_axis_tlast (orsl_axis_tlast ),
    .m_axis_tuser (orsl_axis_tuser ),
//状态信号                               
    .free_space   (rsl_free_space      ),
    .used_space   (                    )
);

RCPktPolic #(
    .RAMADDR_WID            (4),
    .TABLE_WID              (256)
)RCPktPolic_inst(
    .axis_clk               (axis_clk  ),
    .axis_rst_n             (axis_rst_n),

    .iv_des_tdata           (wv_des_tdata),
    .i_des_tvalid           (w_des_tvalid),
    .o_pkt_discard          (wv_pkt_discard),
    .o_pkt_outputbit        (wv_pkt_outputbit),

    .s_lb_cs_n              (s_lb_cs_n ),
    .s_lb_ack_n             (s_lb_ack_n),
    .s_lb_wr_rd             (s_lb_wr_rd),
    .s_lb_addr              (s_lb_addr ),
    .s_lb_wdata             (s_lb_wdata),
    .s_lb_rdata             (s_lb_rdata)
);

onehot2binary #(
    .WIDTH(5)
)bin2onehot_inst(
    .i_onehot(wv_pkt_outputbit),
    .o_bin(outport_binary)
);


endmodule
/*
FlowMeter FlowMeter_Inst(
//时钟复位信号
    .axis_clk     (),
    .axis_rst_n   (),
//分组数据输入接口
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
//配置管理接口         
    .s_lb_cs_n    (),
    .s_lb_ack_n   (),
    .s_lb_wr_rd   (),
    .s_lb_addr    (),
    .s_lb_wdata   (),
    .s_lb_rdata   ()
);
*/