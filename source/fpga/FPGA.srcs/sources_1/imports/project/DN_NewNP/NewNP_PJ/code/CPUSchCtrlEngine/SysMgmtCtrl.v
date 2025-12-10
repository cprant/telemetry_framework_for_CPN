////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  SysMgmtCtrl.v
Target Device All
Dscription 
    1)维护系统全局配置寄存器

Data_Struct:
    1)
Caution: 
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SysMgmtCtrl #(
    parameter THREAD_SUM = 4,
              VERSION = 32'h2022_1015
)(
//时钟复位信号
    input  wire                  clk,
    input  wire                  rst_n,
//输入状态信号
    input  wire [THREAD_SUM*32-1:0] iv_cpu_backlog,
    output reg  [ THREAD_SUM*8-1:0] ov_cpu_percentage,
    output reg  [             31:0] ov_cpu_backlimit,
//配置参数信号
    output reg  [          47:0] ov_local_mac,
    output reg  [          47:0] ov_cpuid_mac,
    output reg  [          47:0] ov_perip_mac,
    output reg  [          47:0] ov_meter_mac,
    output reg  [         127:0] ov_local_ip,
    output reg  [         127:0] ov_meter_ip,
    output reg  [          31:0] ov_local_srv6_opbit,
    output reg                   o_soft_rst_n,
//配置管理接口             
    input  wire                  s_lb_cs_n,
    output reg                   s_lb_ack_n,
    input  wire                  s_lb_wr_rd,
    input  wire [          31:0] s_lb_addr,
    input  wire [          31:0] s_lb_wdata,
    output reg  [          31:0] s_lb_rdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire       sync_localcs;//同步后的片选信号，高有效
reg  [2:0] ctrl_state;
localparam  THREAD_SUM_WIDTH = (THREAD_SUM > 1) ?  clogb2(THREAD_SUM) : 1;

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
        ov_local_mac  <= 48'hABCD_1234_0000;
        ov_cpuid_mac  <= 48'hCDEF_3456_0000;
        ov_perip_mac  <= 48'hEF01_5678_0000;
        ov_meter_mac  <= 48'h0123_789A_0000;
        ov_local_ip   <= {64'hFE80_74FF_5C98_F566,64'b0};
        ov_meter_ip   <= {64'hAC98_8899_6677_EEFF,64'b0};
        ov_local_srv6_opbit <= 32'h20;
        o_soft_rst_n <= 1'b1;
        ov_cpu_percentage <= {THREAD_SUM{8'b0}};
        ov_cpu_backlimit  <= {32{1'b1}};
        s_lb_ack_n <= 1'b1;
        ctrl_state <= INIT_S;
    end
    else begin
        case(ctrl_state)
            INIT_S: begin
                ov_local_mac  <= 48'hABCD_1234_0000;
                ov_cpuid_mac  <= 48'hCDEF_3456_0000;
                ov_perip_mac  <= 48'hEF01_5678_0000;
                ov_meter_mac  <= 48'h0123_789A_0000;
                ov_local_ip   <= {64'hFE80_74FF_5C98_F566,64'b0};
                ov_meter_ip   <= {64'hAC98_8899_6677_EEFF,64'b0};
                ov_local_srv6_opbit <= 32'h20;
                o_soft_rst_n  <= 1'b1;
                ov_cpu_percentage <= {THREAD_SUM{8'b0}};
                ov_cpu_backlimit  <= {32{1'b1}};
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
            
            WRITE_S: begin
                s_lb_ack_n <= 1'b0;//发起响应
                if(s_lb_addr[23:20] == 4'd0) begin
                    case(s_lb_addr[7:0])
                        8'h00: ov_local_mac[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h01: ov_local_mac[ 47:32] <= s_lb_wdata[ 15:0];
                        8'h02: ov_cpuid_mac[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h03: ov_cpuid_mac[ 47:32] <= s_lb_wdata[ 15:0];
                        8'h04: ov_perip_mac[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h05: ov_perip_mac[ 47:32] <= s_lb_wdata[ 15:0];
                        8'h06: ov_meter_mac[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h07: ov_meter_mac[ 47:32] <= s_lb_wdata[ 15:0];
                                             
                        8'h10: ov_local_ip[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h11: ov_local_ip[ 63:32] <= s_lb_wdata[ 31:0];
                        8'h12: ov_local_ip[ 95:64] <= s_lb_wdata[ 31:0];
                        8'h13: ov_local_ip[127:96] <= s_lb_wdata[ 31:0];
                        8'h14: ov_meter_ip[ 31: 0] <= s_lb_wdata[ 31:0];
                        8'h15: ov_meter_ip[ 63:32] <= s_lb_wdata[ 31:0];
                        8'h16: ov_meter_ip[ 95:64] <= s_lb_wdata[ 31:0];
                        8'h17: ov_meter_ip[127:96] <= s_lb_wdata[ 31:0];
                        
                        8'h40: ov_local_srv6_opbit <= s_lb_wdata[ 31:0];
                        
                        8'hFF: o_soft_rst_n        <= s_lb_wdata[0];
                        default:;              
                    endcase
                end
                else if(s_lb_addr[23:20] == 4'd1) begin
                    if(s_lb_addr[15:4] == 12'd0)
                        ov_cpu_percentage[s_lb_addr[THREAD_SUM_WIDTH-1:0]*8 +: 8] <= s_lb_wdata[ 7:0];
                    else if(s_lb_addr[15:4] == 12'd1)
                        ;
                    else if(s_lb_addr[15:4] == 12'h10)
                        case(s_lb_addr[3:0])
                            4'd0: ov_cpu_backlimit <= s_lb_wdata[ 31:0];
                            default: ;
                        endcase
                    else 
                        ;
                end
                ctrl_state <= ACK_S;
            end
            
            READ_S: begin
                s_lb_ack_n <= 1'b0;//发起响应
                if(s_lb_addr[23:20] == 4'd0) begin
                    case(s_lb_addr[7:0])
                        8'h00: s_lb_rdata[31: 0] <= ov_local_mac[31: 0];
                        8'h01: s_lb_rdata[15: 0] <= ov_local_mac[47:32];
                        8'h02: s_lb_rdata[31: 0] <= ov_cpuid_mac[31: 0];
                        8'h03: s_lb_rdata[15: 0] <= ov_cpuid_mac[47:32];
                        8'h04: s_lb_rdata[31: 0] <= ov_perip_mac[31: 0];
                        8'h05: s_lb_rdata[15: 0] <= ov_perip_mac[47:32];
                        8'h06: s_lb_rdata[31: 0] <= ov_meter_mac[31: 0];
                        8'h07: s_lb_rdata[15: 0] <= ov_meter_mac[47:32];
                        
                        8'h10: s_lb_rdata[31: 0] <= ov_local_ip[ 31: 0];
                        8'h11: s_lb_rdata[31: 0] <= ov_local_ip[ 63:32];
                        8'h12: s_lb_rdata[31: 0] <= ov_local_ip[ 95:64];
                        8'h13: s_lb_rdata[31: 0] <= ov_local_ip[127:96];
                        8'h14: s_lb_rdata[31: 0] <= ov_meter_ip[ 31: 0];
                        8'h15: s_lb_rdata[31: 0] <= ov_meter_ip[ 63:32];
                        8'h16: s_lb_rdata[31: 0] <= ov_meter_ip[ 95:64];
                        8'h17: s_lb_rdata[31: 0] <= ov_meter_ip[127:96];
                        
                        8'h40: s_lb_rdata[31: 0] <= ov_local_srv6_opbit;
                        
                        8'hFF: s_lb_rdata[0]     <= o_soft_rst_n;
                        
                        default: ;
                    endcase
                end
                else if(s_lb_addr[23:20] == 4'd1) begin
                    if(s_lb_addr[15:4] == 12'h0)
                        s_lb_rdata[31: 0] <= {24'b0,ov_cpu_percentage[s_lb_addr[THREAD_SUM_WIDTH-1:0]*8 +: 8]};
                    else if(s_lb_addr[15:4] == 12'h1)
                        s_lb_rdata[31: 0] <= iv_cpu_backlog[s_lb_addr[THREAD_SUM_WIDTH-1:0]*32 +: 32];
                    else if(s_lb_addr[15:4] == 12'h10)
                        case(s_lb_addr[3:0])
                            4'h0: s_lb_rdata[31: 0] <= ov_cpu_backlimit;
                            default: ;
                        endcase
                    else 
                        ;
                end
                else begin
                    s_lb_rdata[31: 0] <= VERSION;
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
                ov_local_mac  <= 48'hABCD_1234_0000;
                ov_cpuid_mac  <= 48'hCDEF_3456_0000;
                ov_perip_mac  <= 48'hEF01_5678_0000;
                ov_meter_mac  <= 48'h0123_789A_0000;
                ov_local_ip   <= {64'hFE80_74FF_5C98_F566,64'b0};
                ov_meter_ip   <= {64'hAC98_8899_6677_EEFF,64'b0};
                ov_local_srv6_opbit <= 32'h20;
                o_soft_rst_n  <= 1'b1;
                ov_cpu_percentage <= {THREAD_SUM{8'b0}};
                ov_cpu_backlimit  <= {32{1'b1}};
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
SysMgmtCtrl #(
    .THREAD_SUM (),
    .VERSION    (32'h2022_0415)
)SysMgmtCtrl_Inst(
//时钟复位信号
    .clk                (),
    .rst_n              (),
//输入状态信号          
    .iv_cpu_backlog     (),
    .ov_cpu_percentage  (),
    .ov_cpu_backlimit   (),
//配置参数信号          
    .ov_local_mac       (),
    .ov_cpuid_mac       (),
    .ov_perip_mac       (),
    .ov_meter_mac       (),
    .ov_local_ip        (),
    .ov_meter_ip        (),
    .ov_local_srv6_opbit(),
    .o_soft_rst_n       (),
//配置管理接口
    .s_lb_cs_n       (),
    .s_lb_ack_n      (),
    .s_lb_wr_rd      (),
    .s_lb_addr       (),
    .s_lb_wdata      (),
    .s_lb_rdata      ()
);
*/