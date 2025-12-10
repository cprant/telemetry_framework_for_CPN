/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CBSQueueCtrl.v
Target Device All
Dscription 
    1)根据输入的分组输出使能信号进行高低优先级RC队列调度输出

Data_Struct:

Caution: 
    1)
Author : wjj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CBSQueueCtrl#(
    parameter   DATA_BYTE    = 16,
                PORT_SUM     = 32
)(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //状态
(*mark_debug="true"*)    output reg  [              1:0] Q_empty,
(*mark_debug="true"*)    output reg  [              1:0] Q_Txing,
(*mark_debug="true"*)    input  wire [              1:0] Tx_enable,
    //高优先级RC分组数据输入接口
(*mark_debug="true"*)    output reg                      hrc_axis_tready,
(*mark_debug="true"*)    input  wire                     hrc_axis_tvalid,
(*mark_debug="true"*)    input  wire [    DATA_BYTE-1:0] hrc_axis_tkeep ,
(*mark_debug="true"*)    input  wire [  DATA_BYTE*8-1:0] hrc_axis_tdata ,
(*mark_debug="true"*)    input  wire                     hrc_axis_tlast ,
(*mark_debug="true"*)    input  wire [              0:0] hrc_axis_tuser ,
    //高优先级RC分组数据输入接口                   
(*mark_debug="true"*)    output reg                      lrc_axis_tready,
(*mark_debug="true"*)    input  wire                     lrc_axis_tvalid,
(*mark_debug="true"*)    input  wire [    DATA_BYTE-1:0] lrc_axis_tkeep ,
(*mark_debug="true"*)    input  wire [  DATA_BYTE*8-1:0] lrc_axis_tdata ,
(*mark_debug="true"*)    input  wire                     lrc_axis_tlast ,
(*mark_debug="true"*)    input  wire [              0:0] lrc_axis_tuser ,
    //RC分组数据输出接口
(*mark_debug="true"*)    input  wire                     m_axis_tready,
(*mark_debug="true"*)    output reg                      m_axis_tvalid,
(*mark_debug="true"*)    output reg  [    DATA_BYTE-1:0] m_axis_tkeep ,
(*mark_debug="true"*)    output reg  [  DATA_BYTE*8-1:0] m_axis_tdata ,
(*mark_debug="true"*)    output reg                      m_axis_tlast ,
(*mark_debug="true"*)    output reg  [              0:0] m_axis_tuser 
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 

(*mark_debug="true"*)reg  [  1:0] cur_send_state,nxt_send_state;
localparam  IDLE_S  = 2'd0,
            SENDH_S = 2'd1,
            SENDL_S = 2'd2;


/************************************************************************
                                队列状态处理
*************************************************************************/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        Q_empty         <= 2'b11;
    end
    else begin
        Q_empty[1]      <= ~hrc_axis_tvalid;
        Q_empty[0]      <= ~lrc_axis_tvalid;
    end
end

/************************************************************************
                                调度输出处理
*************************************************************************/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        cur_send_state  <= IDLE_S;
    end
    else begin
        cur_send_state  <= nxt_send_state;
    end
end



always @(*) begin
    if(axis_rst_n == 1'b0) begin
        m_axis_tvalid   = 1'b0;
        m_axis_tkeep    = {DATA_BYTE{1'b0}};
        m_axis_tdata    = {DATA_BYTE*8{1'b0}};
        m_axis_tlast    = 1'b0;
        m_axis_tuser    = 1'b0;
        
        hrc_axis_tready = 1'b0;
        lrc_axis_tready = 1'b0;
        
        Q_Txing         = 2'b00;
        
        nxt_send_state  = IDLE_S;
    end
    else begin
        case(cur_send_state)
        IDLE_S:begin
            hrc_axis_tready = 1'b0;
            lrc_axis_tready = 1'b0;
        
            m_axis_tvalid   = 1'b0;
            m_axis_tkeep    = {DATA_BYTE{1'b0}};
            m_axis_tdata    = {DATA_BYTE*8{1'b0}};
            m_axis_tlast    = 1'b0;
            m_axis_tuser    = 1'b0;
            
            Q_Txing         = 2'b00;
        
            if(m_axis_tready == 1'b1)begin
                if((Tx_enable == 2'b11 || Tx_enable == 2'b10) && (hrc_axis_tvalid == 1'b1))begin
                    nxt_send_state      = SENDH_S;
                end
                else if(Tx_enable == 2'b01 && lrc_axis_tvalid == 1'b1)begin
                    nxt_send_state      = SENDL_S;
                end
                else begin
                    nxt_send_state      = IDLE_S;
                end
            end
            else begin
                nxt_send_state      = IDLE_S;
            end
        end
        SENDH_S:begin
            if(m_axis_tready == 1'b1 && hrc_axis_tvalid == 1'b1)begin
                m_axis_tvalid   = hrc_axis_tvalid;
                m_axis_tkeep    = hrc_axis_tkeep ;
                m_axis_tdata    = hrc_axis_tdata ;
                m_axis_tlast    = hrc_axis_tlast ;
                m_axis_tuser    = hrc_axis_tuser ;
                
                hrc_axis_tready = 1'b1;
                lrc_axis_tready = 1'b0;
                
                Q_Txing         = 2'b10;
                
                if(hrc_axis_tlast == 1'b1)
                    nxt_send_state      = IDLE_S;
                else
                    nxt_send_state      = SENDH_S;
            end
            else begin
                m_axis_tvalid   = 1'b0;
                m_axis_tkeep    = {DATA_BYTE{1'b0}};
                m_axis_tdata    = {DATA_BYTE*8{1'b0}};
                m_axis_tlast    = 1'b0;
                m_axis_tuser    = 1'b0;
                
                hrc_axis_tready = 1'b0;
                lrc_axis_tready = 1'b0;
                
                Q_Txing         = 2'b00;
                
                nxt_send_state      = SENDH_S;
            end
        end
        SENDL_S:begin
            if(m_axis_tready == 1'b1 && lrc_axis_tvalid == 1'b1)begin
                m_axis_tvalid   = lrc_axis_tvalid;
                m_axis_tkeep    = lrc_axis_tkeep ;
                m_axis_tdata    = lrc_axis_tdata ;
                m_axis_tlast    = lrc_axis_tlast ;
                m_axis_tuser    = lrc_axis_tuser ;
                
                hrc_axis_tready = 1'b0;
                lrc_axis_tready = 1'b1;
                
                Q_Txing         = 2'b01;
                
                if(lrc_axis_tlast == 1'b1)
                    nxt_send_state      = IDLE_S;
                else
                    nxt_send_state      = SENDL_S;
            end
            else begin
                m_axis_tvalid   = 1'b0;
                m_axis_tkeep    = {DATA_BYTE{1'b0}};
                m_axis_tdata    = {DATA_BYTE*8{1'b0}};
                m_axis_tlast    = 1'b0;
                m_axis_tuser    = 1'b0;
                
                hrc_axis_tready = 1'b0;
                lrc_axis_tready = 1'b0;
                
                Q_Txing         = 2'b00;
                
                nxt_send_state      = SENDL_S;
            end
        end
        default:begin
            m_axis_tvalid   = 1'b0;
            m_axis_tkeep    = {DATA_BYTE{1'b0}};
            m_axis_tdata    = {DATA_BYTE*8{1'b0}};
            m_axis_tlast    = 1'b0;
            m_axis_tuser    = 1'b0;
            
            hrc_axis_tready = 1'b0;
            lrc_axis_tready = 1'b0;
            
            Q_Txing         = 2'b00;
            
            nxt_send_state      = IDLE_S;
        end
        
        endcase
    end
end

/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 


endmodule

/*
CBSQueueCtrl#(
    .DATA_BYTE                  ( DATA_BYTE                 ),
    .PORT_SUM                   ( PORT_SUM                  )
)CBSQueueCtrl_inst(
    .axis_clk                   (),
    .axis_rst_n                 (),

    .Q_empty                    (),
    .Q_Txing                    (),
    .Tx_enable                  (),

    .hrc_axis_tready            (),
    .hrc_axis_tvalid            (),
    .hrc_axis_tkeep             (),
    .hrc_axis_tdata             (),
    .hrc_axis_tlast             (),
    .hrc_axis_tuser             (),

    .lrc_axis_tready            (),
    .lrc_axis_tvalid            (),
    .lrc_axis_tkeep             (),
    .lrc_axis_tdata             (),
    .lrc_axis_tlast             (),
    .lrc_axis_tuser             (),

    .m_axis_tready              (),
    .m_axis_tvalid              (),
    .m_axis_tkeep               (),
    .m_axis_tdata               (),
    .m_axis_tlast               (),
    .m_axis_tuser               ()
);
*/