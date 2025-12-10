/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CPURcvDisp.v
Target Device All
Dscription 
    1)根据CPU负载状态统计模块提供的当前CPU队列负载情况
    2)判定将帧分派到不同处理器核上进行处理
    3)通过设置目的MAC来区分送往不同CPU核的帧
    4)在传输完整帧后提供该帧的CPUID供CPU负载状态统计模块更新队列负载状态
    5) !!!默认只分派SRv6报文，对于其他报文原样转发
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
        
    2) cpu_loadstate
        [31:24] CPU负载百分比
        [23: 0] CPU线程积压报文数量
Caution: 
    1)THREAD_SUM必须大于1
    2)配置的iv_dmac_addr默认为CPU0的MAC地址
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module CPURcvDisp #(
    parameter   THREAD_SUM     = 8'd4
)(
//时钟复位信号
    input  wire                   axis_clk,
    input  wire                   axis_rst_n,
//数据输入接口             
    output reg                    s_axis_tready,
    input  wire                   s_axis_tvalid,
    input  wire [           15:0] s_axis_tkeep,
    input  wire [          127:0] s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire [            0:0] s_axis_tuser,
//数据输出接口             
    input  wire                   m_axis_tready,
    output wire                   m_axis_tvalid,
    output wire [           15:0] m_axis_tkeep,
    output wire [          127:0] m_axis_tdata,
    output wire                   m_axis_tlast,
    output wire [            0:0] m_axis_tuser,
//CPU负载信息                       
    output reg                    o_rx_cpuid_valid,
    output reg  [            7:0] ov_rx_cpuid ,

    input  wire [THREAD_SUM*32-1:0] iv_cpu_loadstate,
    input  wire [             31:0] iv_cpu_backlimit,
//状态配置信息
    input  wire [           47:0] iv_smac_addr,
    input  wire [           47:0] iv_dmac_addr
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明

wire         s_axis_sop;
wire [  7:0] s_axis_line_id;
wire         s_axis_eop;
      
wire         int_axis_tready;
reg          int_axis_tvalid;
reg  [ 15:0] int_axis_tkeep ;
reg  [127:0] int_axis_tdata ;
reg          int_axis_tlast ;
reg  [  0:0] int_axis_tuser ;
      
reg          inport_srv6_flag;
reg          outport_srv6_flag;
reg  [  7:0] round_cnt;//轮询计数器，从0循环累加到THREAD_SUM-1
reg  [  7:0] sel_cpuid;
/*----------------------------------------------------------------------
                                空闲CPU择优
----------------------------------------------------------------------*/
/*由于本身就是临时模块，没必要做的太精确
因此目前暂时按照最简单的每个周期轮询比较，选择最小值的方式来实现
仅从CPU1开始分派，默认CPU0为管理监控CPU

！！！！实际上总体方案上的实现就只支持4个CPU的分派：
    0号CPU监控，送错误报文以及配置报文
    1和2号CPU接收入口SRv6报文
    3号CPU接收出口SRv6报文
*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        round_cnt <= 8'd3;
        sel_cpuid <= 8'd1;
    end
    else begin
        if((iv_cpu_loadstate[1*32 +: 24] < iv_cpu_backlimit) || 
           (iv_cpu_loadstate[1*32 +: 24] < iv_cpu_loadstate[2*32 +: 24]) || 
           ((iv_cpu_loadstate[1*32 +: 24] == iv_cpu_loadstate[2*32 +: 24]) && (iv_cpu_loadstate[1*32+24 +: 8] < iv_cpu_loadstate[2*32+24 +: 8])))begin
            //若以下三个条件之一成立，DMAC[1:0]=01 //送CPU1
            //若Backlog_CPU1低于阈值
            //若Backlog_CPU1< Backlog_CPU2
            //若Backlog_CPU1=Backlog_CPU2且load_CPU1<load_CPU2
            round_cnt <= 8'd3;
            sel_cpuid <= 8'd1;
        end
        else if(iv_cpu_loadstate[2*32+24 +: 8] < 8'd255) begin
            round_cnt <= 8'd3;
            sel_cpuid <= 8'd2;
        end
        else begin
            round_cnt <= (round_cnt < (THREAD_SUM-1)) ? 
                          round_cnt + 1'b1 : 8'd3;
                              
            sel_cpuid <= (iv_cpu_loadstate[round_cnt*32 +: 32] < iv_cpu_loadstate[sel_cpuid*32 +: 32]) ? 
                          round_cnt : sel_cpuid;
        end
    end
end
/*-----------------------------------------------------------------------
                    处理器状态感知帧分派
-----------------------------------------------------------------------*/
always @(posedge axis_clk) begin
    inport_srv6_flag  <= (s_axis_sop == 1'b1) ? 
                         (s_axis_tdata[87:84] == 4'd1) : 1'b0;
    
    outport_srv6_flag <= (s_axis_sop == 1'b1) ? 
                         (s_axis_tdata[87:84] == 4'd4) : 1'b0;   
end

always @(*) begin
    s_axis_tready = int_axis_tready;
    
    int_axis_tvalid = s_axis_tvalid;
    int_axis_tkeep  = s_axis_tkeep ;
    int_axis_tlast  = s_axis_tlast ;
    int_axis_tuser  = s_axis_tuser ;
    
    
    if((s_axis_tready == 1'b1) && 
       (s_axis_tvalid == 1'b1) && 
       (s_axis_line_id == 1'b1)) begin
        o_rx_cpuid_valid = 1'b1;
        if(inport_srv6_flag == 1'b1) begin
            int_axis_tdata   = {iv_dmac_addr+sel_cpuid,
                                iv_smac_addr,
                                s_axis_tdata[31:0]};
            ov_rx_cpuid      = sel_cpuid;
        end
        else if(outport_srv6_flag == 1'b1) begin
            int_axis_tdata   = {iv_dmac_addr+8'd3,
                                iv_smac_addr,
                                s_axis_tdata[31:0]};
            ov_rx_cpuid      = 8'd3;
        end
        else begin
            int_axis_tdata   = s_axis_tdata ;
            ov_rx_cpuid      = 8'b0;
        end
    end
    else begin
        int_axis_tdata   = s_axis_tdata ;
        o_rx_cpuid_valid = 1'b0;
        ov_rx_cpuid      = 8'b0;
    end
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

AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (16),
    .USER_BIT  (1)
)AXISRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(int_axis_tready),    
    .s_axis_tvalid(int_axis_tvalid),    
    .s_axis_tkeep (int_axis_tkeep ),
    .s_axis_tdata (int_axis_tdata ),
    .s_axis_tlast (int_axis_tlast ),
    .s_axis_tuser (int_axis_tuser ),    
//报文分组输出接口信号
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser )
);

endmodule
/*
CPURcvDisp #(
    .THREAD_SUM()
)
CPURcvDisp_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//数据输入接口             
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//数据输出接口             
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
//CPU负载信息                       
    .o_rx_cpuid_valid(),
    .ov_rx_cpuid     (),
    
    .iv_cpu_loadstate(),
    .iv_cpu_backlimit(),
//状态配置信息
    .iv_smac_addr(),
    .iv_dmac_addr()
);
*/