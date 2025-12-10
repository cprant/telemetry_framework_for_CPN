/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  NetTelMeterEngine.v
Target Device All
Dscription 
    1)维护各CPU核的负载状态计数器
    2)接收CPU接收分派和CPU发送控制模块输入的帧状态信息
    3)根据状态信息实时更新对应的负载状态计数器

Data_Struct:
    1)

Author : LXJ
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
Caution:
    1)
*/

module CPULoadStateStatis#(
    parameter   THREAD_SUM        = 4
)(
    input wire                     clk  ,   
    input wire                     rst_n,
                             
//CPU负载信息                
    input wire                     i_rx_cpuid_valid,
    input wire [              7:0] iv_rx_cpuid ,
                             
    input wire                     i_tx_cpuid_valid,
    input wire [              7:0] iv_tx_cpuid ,
    
    output reg [THREAD_SUM*32-1:0] ov_cpu_backlog,
    
    output reg [THREAD_SUM*64-1:0] ov_thread_rcv_pkt_cnt,
    output reg [THREAD_SUM*64-1:0] ov_thread_send_pkt_cnt
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire [THREAD_SUM-1:0] cpu_add_sel,cpu_add_valid;
wire [THREAD_SUM-1:0] cpu_sub_sel,cpu_sub_valid;
/*----------------------------------------------------------------------
                                CPU统计计数器
----------------------------------------------------------------------*/

generate
    genvar i;
    for(i=0;i<THREAD_SUM;i=i+1) begin:cpu_load_cnt
        assign cpu_add_valid[i] = (cpu_add_sel[i] && i_rx_cpuid_valid);
        assign cpu_sub_valid[i] = (cpu_sub_sel[i] && i_tx_cpuid_valid);
        
        always @(posedge clk or negedge rst_n) begin
            if(rst_n == 1'b0) begin
                ov_cpu_backlog [i*32 +: 32] <= 32'b0;
                ov_thread_rcv_pkt_cnt [i*64 +: 64] <= 64'b0;
                ov_thread_send_pkt_cnt[i*64 +: 64] <= 64'b0;
            end
            else begin
                ov_thread_rcv_pkt_cnt [i*64 +: 64] <= ov_thread_rcv_pkt_cnt [i*64 +: 64] + cpu_add_valid[i];
                ov_thread_send_pkt_cnt[i*64 +: 64] <= ov_thread_send_pkt_cnt[i*64 +: 64] + cpu_sub_valid[i];
                case({cpu_add_valid[i],cpu_sub_valid[i]})
                    2'b01: ov_cpu_backlog[i*32 +: 32] <= ((|ov_cpu_backlog[i*32 +: 32]) == 1'b1) ? 
                                                            (ov_cpu_backlog[i*32 +: 32] - 1'b1) : 
                                                            ov_cpu_backlog[i*32 +: 32];
                    2'b10: ov_cpu_backlog[i*32 +: 32] <= ((&ov_cpu_backlog[i*32 +: 32]) == 1'b0) ? 
                                                            (ov_cpu_backlog[i*32 +: 32] + 1'b1) : 
                                                            ov_cpu_backlog[i*32 +: 32];
                    default:ov_cpu_backlog[i*32 +: 32] <= ov_cpu_backlog[i*32 +: 32];                                         
                endcase
            end
        end
    end
endgenerate
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
binary2onehot #(
    .WIDTH(8)
)rx_cpu_sel_inst(
    .i_bin(iv_rx_cpuid),
    .o_onehot(cpu_add_sel)
);

binary2onehot #(
    .WIDTH(8)
)tx_cpu_sel_inst(
    .i_bin(iv_tx_cpuid),
    .o_onehot(cpu_sub_sel)
);
endmodule
/*
CPULoadStateStatis#(
    .THREAD_SUM()
)
CLSS_Inst(
    .clk  (),   
    .rst_n(),
                          
//CPU负载信息             
    .i_rx_cpuid_valid(),
    .iv_rx_cpuid     (),
    
    .i_tx_cpuid_valid(),
    .iv_tx_cpuid     (),
    
    .ov_cpu_backlog  (),
    
    .ov_thread_rcv_pkt_cnt  (),
    .ov_thread_send_pkt_cnt ()
);
*/