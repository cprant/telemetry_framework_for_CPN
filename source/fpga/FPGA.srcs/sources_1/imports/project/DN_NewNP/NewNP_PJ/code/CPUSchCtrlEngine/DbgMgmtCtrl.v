////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  DbgMgmtCtrl.v
Target Device All
Dscription 
    1)维护统计调试寄存器

Data_Struct:
    1)
Caution: 
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module DbgMgmtCtrl #(
    parameter PORT_SUM   = 4,
              THREAD_SUM = 4
)(
//时钟复位信号
    input  wire                    clk,
    input  wire                    rst_n,
//输入状态信号    
    input wire [  PORT_SUM*64-1:0] iv_port_rcv_allpkt_cnt ,
    input wire [  PORT_SUM*64-1:0] iv_port_rcv_filtpkt_cnt,
    input wire [  PORT_SUM*64-1:0] iv_port_rcv_discpkt_cnt,
    input wire [  PORT_SUM*64-1:0] iv_port_rcv_tm_cnt     , 
    input wire [  PORT_SUM*64-1:0] iv_port_send_pkt_cnt   ,
    input wire [  PORT_SUM*64-1:0] iv_port_send_tm_cnt    ,
                                                 
    input wire [         1*64-1:0] iv_cpu_rcv_allpkt_cnt  ,
    input wire [         1*64-1:0] iv_cpu_rcv_filtpkt_cnt ,
    input wire [         1*64-1:0] iv_cpu_rcv_discpkt_cnt ,
    input wire [         1*64-1:0] iv_cpu_rcv_tm_cnt      , 
    input wire [         1*64-1:0] iv_cpu_send_pkt_cnt    ,
    input wire [         1*64-1:0] iv_cpu_send_tm_cnt     ,
    
    input wire [THREAD_SUM*64-1:0] iv_thread_rcv_pkt_cnt ,
    input wire [THREAD_SUM*64-1:0] iv_thread_send_pkt_cnt,
//配置管理接口             
    input  wire                    s_lb_cs_n,
    output reg                     s_lb_ack_n,
    input  wire                    s_lb_wr_rd,
    input  wire [            31:0] s_lb_addr,
    input  wire [            31:0] s_lb_wdata,
    output reg  [            31:0] s_lb_rdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire       sync_localcs;//同步后的片选信号，高有效
reg  [2:0] ctrl_state;
localparam  THREAD_SUM_WIDTH = (THREAD_SUM > 1) ?  clogb2(THREAD_SUM) : 1,
            PORT_SUM_WIDTH   = (PORT_SUM > 1) ?  clogb2(PORT_SUM) : 1;

localparam  INIT_S  = 3'd0,
            IDLE_S  = 3'd1,
            WRITE_S = 3'd2,
            READ_S  = 3'd3,
            ACK_S   = 3'd4;
/*----------------------------------------------------------
                    调度处理
----------------------------------------------------------*/

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        s_lb_ack_n <= 1'b1;
        ctrl_state <= INIT_S;
    end
    else begin
        case(ctrl_state)
            INIT_S: begin
                s_lb_ack_n <= 1'b1;
                ctrl_state <= IDLE_S;
            end
            
            IDLE_S: begin
                s_lb_ack_n          <= 1'b1;
                s_lb_rdata          <= 32'b0;
                if(sync_localcs == 1'b1)
                    if(s_lb_wr_rd == 1'b0)//写请求
                        ctrl_state <= WRITE_S;
                    else//读请求
                        ctrl_state <= READ_S;
                else
                    ctrl_state <= IDLE_S;
            end
            
            WRITE_S: begin//暂无需要调试写的寄存器
                s_lb_ack_n <= 1'b0;//发起响应
                ctrl_state <= ACK_S;
            end
            
            READ_S: begin
                s_lb_ack_n <= 1'b0;//发起响应
                
                if(s_lb_addr[23:16] == 8'd0) begin//端口调试
                    case(s_lb_addr[15:8])
                        8'h00: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_rcv_allpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_rcv_allpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h01: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_rcv_filtpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_rcv_filtpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h02: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_rcv_discpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_rcv_discpkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h03: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_rcv_tm_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_rcv_tm_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h04: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_send_pkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_send_pkt_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h05: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_port_send_tm_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_port_send_tm_cnt[s_lb_addr[PORT_SUM_WIDTH:1]*32+32 +: 32] ;
                        default: s_lb_rdata[31: 0] <= 32'b0;
                    endcase
                end
                else if(s_lb_addr[23:16] == 8'd1) begin//主机调试信号
                    case(s_lb_addr[15:8])
                        8'h00: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_thread_rcv_pkt_cnt[s_lb_addr[THREAD_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_thread_rcv_pkt_cnt[s_lb_addr[THREAD_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h01: s_lb_rdata[31: 0] <= (s_lb_addr[0] == 1'b0) ? 
                                                   iv_thread_send_pkt_cnt[s_lb_addr[THREAD_SUM_WIDTH:1]*32    +: 32] : 
                                                   iv_thread_send_pkt_cnt[s_lb_addr[THREAD_SUM_WIDTH:1]*32+32 +: 32] ;
                        8'h02: begin
                            case(s_lb_addr[7:0])
                                8'h00 : s_lb_rdata[31: 0] <= iv_cpu_rcv_allpkt_cnt [31: 0];
                                8'h01 : s_lb_rdata[31: 0] <= iv_cpu_rcv_allpkt_cnt [63:32];
                                8'h02 : s_lb_rdata[31: 0] <= iv_cpu_rcv_filtpkt_cnt[31: 0];
                                8'h03 : s_lb_rdata[31: 0] <= iv_cpu_rcv_filtpkt_cnt[63:32];
                                8'h04 : s_lb_rdata[31: 0] <= iv_cpu_rcv_discpkt_cnt[31: 0];
                                8'h05 : s_lb_rdata[31: 0] <= iv_cpu_rcv_discpkt_cnt[63:32];
                                8'h06 : s_lb_rdata[31: 0] <= iv_cpu_rcv_tm_cnt     [31: 0];
                                8'h07 : s_lb_rdata[31: 0] <= iv_cpu_rcv_tm_cnt     [63:32];
                                8'h08 : s_lb_rdata[31: 0] <= iv_cpu_send_pkt_cnt   [31: 0];
                                8'h09 : s_lb_rdata[31: 0] <= iv_cpu_send_pkt_cnt   [63:32];
                                8'h0A: s_lb_rdata[31: 0] <= iv_cpu_send_tm_cnt    [31: 0];
                                8'h0B: s_lb_rdata[31: 0] <= iv_cpu_send_tm_cnt    [63:32];
                                default: s_lb_rdata[31: 0] <= 32'b0;
                            endcase
                        end
                        default: s_lb_rdata[31: 0] <= 32'b0;
                    endcase
                end
                else begin
                    s_lb_rdata[31: 0] <= 32'b0;
                end
                ctrl_state <= ACK_S;
            end
            
            ACK_S: begin
                if(sync_localcs == 1'b0) begin//Master端收到响应并释放总线
                    s_lb_ack_n <= 1'b1;   
                    ctrl_state <= IDLE_S;
                end
                else begin
                    s_lb_ack_n <= 1'b0;   
                    ctrl_state <= ACK_S;
                end
            end
            
            default: begin
                s_lb_ack_n <= 1'b1;
                ctrl_state <= INIT_S;
            end
        endcase
    end
end
/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
function [31:0] clogb2;
    input [31:0] depth;
    reg [31:0] i,result;
begin
    for(i=0;2**i<depth;i=i+1)
        result=i+1;
    clogb2=i;//返回的结果是i，即求幂的逆计算
end
endfunction
    
SyncSig localcsn_sync_inst(
    .clk  (clk        ),
    .rst_n(rst_n    ),
    
    .in_sig(~s_lb_cs_n   ),
    .out_sig(sync_localcs)
);
endmodule
/*
DbgMgmtCtrl #(
    .PORT_SUM   (),
    .THREAD_SUM ()
)DbgMgmtCtrl_Inst(
//时钟复位信号
    .clk                    (),
    .rst_n                  (),
//输入状态信号          
    .iv_port_rcv_allpkt_cnt (),
    .iv_port_rcv_filtpkt_cnt(),
    .iv_port_rcv_discpkt_cnt(),
    .iv_port_rcv_tm_cnt     (), 
    .iv_port_send_pkt_cnt   (),
    .iv_port_send_tm_cnt    (),

    .iv_cpu_rcv_allpkt_cnt  (),
    .iv_cpu_rcv_filtpkt_cnt (),
    .iv_cpu_rcv_discpkt_cnt (),
    .iv_cpu_rcv_tm_cnt      (), 
    .iv_cpu_send_pkt_cnt    (),
    .iv_cpu_send_tm_cnt     (),

    .iv_thread_rcv_pkt_cnt  (),
    .iv_thread_send_pkt_cnt (),
//配置管理接口
    .s_lb_cs_n       (),
    .s_lb_ack_n      (),
    .s_lb_wr_rd      (),
    .s_lb_addr       (),
    .s_lb_wdata      (),
    .s_lb_rdata      ()
);
*/