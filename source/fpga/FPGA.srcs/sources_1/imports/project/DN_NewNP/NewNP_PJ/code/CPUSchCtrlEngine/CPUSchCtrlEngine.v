/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CPUSchCtrlEngine.v
Target Device All
Dscription 
(1)	监测每个CPU的负载情况，包括:
    1)	CPU利用率
    2)	累计的分组个数等
(2)	根据负载信息将上CPU的分组分派到不同CPU核
(3)	接收CPU下发的数据分组，并发送到快速转发模块
(4)	实现CPU管理软件对硬件模块和引擎的配置管理通路(Localbus)

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
    
    2) cpu_loadstate
        [31:24] CPU负载百分比
        [23: 0] CPU线程积压报文数量
Caution: 
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module CPUSchCtrlEngine #(
    parameter PORT_SUM   = 4,
              THREAD_SUM = 4,
              Mbus_ID = 2,
              VERSION = 32'h2022_1015
)(
//时钟复位信号
    input  wire                  axis_clk  ,
    input  wire                  axis_rst_n,
    input  wire                  hcp_clk  ,
    input  wire                  hcp_rst_n,
//主机数据输入接口    
(*mark_debug="true"*)    output wire                  s_host_axis_tready,
(*mark_debug="true"*)    input  wire                  s_host_axis_tvalid,
    input  wire [          15:0] s_host_axis_tkeep ,
(*mark_debug="true"*)    input  wire [         127:0] s_host_axis_tdata ,
(*mark_debug="true"*)    input  wire                  s_host_axis_tlast ,
(*mark_debug="true"*)    input  wire [          11:0] s_host_axis_tuser ,
//主机数据输出接口                     
(*mark_debug="true"*)    input  wire                  m_host_axis_tready,
(*mark_debug="true"*)    output wire                  m_host_axis_tvalid,
    output wire [          15:0] m_host_axis_tkeep ,
(*mark_debug="true"*)    output wire [         127:0] m_host_axis_tdata ,
(*mark_debug="true"*)    output wire                  m_host_axis_tlast ,
(*mark_debug="true"*)    output wire [           0:0] m_host_axis_tuser ,
//网络数据输入接口            
(*mark_debug="true"*)    output wire                  s_netw_axis_tready,
(*mark_debug="true"*)    input  wire                  s_netw_axis_tvalid,
    input  wire [          15:0] s_netw_axis_tkeep ,
(*mark_debug="true"*)    input  wire [         127:0] s_netw_axis_tdata ,
(*mark_debug="true"*)    input  wire                  s_netw_axis_tlast ,
(*mark_debug="true"*)    input  wire [           0:0] s_netw_axis_tuser ,
//网络数据输出接口                 
(*mark_debug="true"*)    input  wire                  m_netw_axis_tready,
(*mark_debug="true"*)    output wire                  m_netw_axis_tvalid,
    output wire [          15:0] m_netw_axis_tkeep ,
(*mark_debug="true"*)    output wire [         127:0] m_netw_axis_tdata ,
(*mark_debug="true"*)    output wire                  m_netw_axis_tlast ,
(*mark_debug="true"*)    output wire [          11:0] m_netw_axis_tuser ,
//配置管理接口            
    output reg                   m_lb_cs_n ,
    input  wire                  m_lb_ack_n,
    output reg                   m_lb_wr_rd,
    output reg  [          31:0] m_lb_addr ,
    output reg  [          31:0] m_lb_wdata,
    input  wire [          31:0] m_lb_rdata,
//状态输出信号    
(*mark_debug="true"*)    output wire [THREAD_SUM*32-1:0] ov_cpu_loadstate,
//配置参数信号
(*mark_debug="true"*)    output wire [          47:0] ov_local_mac       ,
(*mark_debug="true"*)    output wire [          47:0] ov_perip_mac       ,
(*mark_debug="true"*)    output wire [          47:0] ov_meter_mac       ,
(*mark_debug="true"*)    output wire [         127:0] ov_local_ip        ,
(*mark_debug="true"*)    output wire [         127:0] ov_meter_ip        ,
(*mark_debug="true"*)    output wire [          31:0] ov_local_srv6_opbit,
(*mark_debug="true"*)    output wire                  o_soft_rst_n       ,
//统计信息
    input wire [PORT_SUM*64-1:0] iv_port_rcv_allpkt_cnt ,
    input wire [PORT_SUM*64-1:0] iv_port_rcv_filtpkt_cnt,
    input wire [PORT_SUM*64-1:0] iv_port_rcv_discpkt_cnt,
    input wire [PORT_SUM*64-1:0] iv_port_rcv_tm_cnt     , 
    input wire [PORT_SUM*64-1:0] iv_port_send_pkt_cnt   ,
    input wire [PORT_SUM*64-1:0] iv_port_send_tm_cnt    ,
                                               
    input wire [       1*64-1:0] iv_cpu_rcv_allpkt_cnt  ,
    input wire [       1*64-1:0] iv_cpu_rcv_filtpkt_cnt ,
    input wire [       1*64-1:0] iv_cpu_rcv_discpkt_cnt ,
    input wire [       1*64-1:0] iv_cpu_rcv_tm_cnt      , 
    input wire [       1*64-1:0] iv_cpu_send_pkt_cnt    ,
    input wire [       1*64-1:0] iv_cpu_send_tm_cnt     
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire                  hcp2apm_axis_tready;
wire                  hcp2apm_axis_tvalid;
wire [          15:0] hcp2apm_axis_tkeep ;
wire [         127:0] hcp2apm_axis_tdata ;
wire                  hcp2apm_axis_tlast ;
wire [           0:0] hcp2apm_axis_tuser ;

wire                  apm2crd_axis_tready;
wire                  apm2crd_axis_tvalid;
wire [          15:0] apm2crd_axis_tkeep ;
wire [         127:0] apm2crd_axis_tdata ;
wire                  apm2crd_axis_tlast ;
wire [           0:0] apm2crd_axis_tuser ;

(*mark_debug="true"*)wire                  ctc2apd_axis_tready;
(*mark_debug="true"*)wire                  ctc2apd_axis_tvalid;
(*mark_debug="true"*)wire [          15:0] ctc2apd_axis_tkeep ;
(*mark_debug="true"*)wire [         127:0] ctc2apd_axis_tdata ;
(*mark_debug="true"*)wire                  ctc2apd_axis_tlast ;
(*mark_debug="true"*)wire [          11:0] ctc2apd_axis_tuser ;
(*mark_debug="true"*)wire [           1:0] ctc2apd_axis_tdest ;

(*mark_debug="true"*)wire                  apd2hcp_axis_tready;
(*mark_debug="true"*)wire                  apd2hcp_axis_tvalid;
(*mark_debug="true"*)wire [          15:0] apd2hcp_axis_tkeep ;
(*mark_debug="true"*)wire [         127:0] apd2hcp_axis_tdata ;
(*mark_debug="true"*)wire                  apd2hcp_axis_tlast ;
(*mark_debug="true"*)wire [          11:0] apd2hcp_axis_tuser ;

(*mark_debug="true"*)wire                  crd2clss_valid;
(*mark_debug="true"*)wire [           7:0] crd2clss_cpuid;

(*mark_debug="true"*)wire                  ctc2clss_valid;
(*mark_debug="true"*)wire [           7:0] ctc2clss_cpuid;

(*mark_debug="true"*)wire                    int_lb_cs_n ;
(*mark_debug="true"*)reg                     int_lb_ack_n;
(*mark_debug="true"*)wire                    int_lb_wr_rd;//0:wr  1:rd
(*mark_debug="true"*)wire [            31:0] int_lb_addr ;
(*mark_debug="true"*)wire [            31:0] int_lb_wdata;
(*mark_debug="true"*)reg  [            31:0] int_lb_rdata;

reg                     sys_lb_cs_n ;
wire                    sys_lb_ack_n;
reg                     sys_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] sys_lb_addr ;
reg  [            31:0] sys_lb_wdata;
wire [            31:0] sys_lb_rdata;

reg                     dbg_lb_cs_n ;
wire                    dbg_lb_ack_n;
reg                     dbg_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] dbg_lb_addr ;
reg  [            31:0] dbg_lb_wdata;
wire [            31:0] dbg_lb_rdata;

(*mark_debug="true"*)wire [            47:0] wv_cpuid_mac;

wire [ THREAD_SUM*8-1:0] wv_cpu_percentage;
wire [THREAD_SUM*32-1:0] wv_cpu_backlog;

wire [             31:0] wv_cpu_backlimit;

wire [THREAD_SUM*64-1:0] wv_thread_rcv_pkt_cnt ;
wire [THREAD_SUM*64-1:0] wv_thread_send_pkt_cnt;

//拼接CPU负载状态信息
generate
    genvar i;
    for(i=0;i<THREAD_SUM;i=i+1) begin:CPULoadstate
        assign ov_cpu_loadstate[i*32 +: 32] = {wv_cpu_percentage[i*8 +: 8],
                                               wv_cpu_backlog[i*32 +: 24]};
    end
endgenerate
/*----------------------------------------------------------
                        配置地址分区
----------------------------------------------------------*/
reg [31:0] cur_lb_addr_reg,nxt_lb_addr_reg;

//锁存输入的localbus地址，以免wv_s_lb_addr释放后地址也被清零，导致ack_n选择出错
always @(*) nxt_lb_addr_reg = (int_lb_cs_n == 1'b0) ? int_lb_addr : cur_lb_addr_reg;
always @(posedge hcp_clk) cur_lb_addr_reg <= nxt_lb_addr_reg; 

always @* begin
    sys_lb_wr_rd = int_lb_wr_rd;
    sys_lb_addr  = int_lb_addr ;
    sys_lb_wdata = int_lb_wdata;
    
    dbg_lb_wr_rd = int_lb_wr_rd;
    dbg_lb_addr  = int_lb_addr ;
    dbg_lb_wdata = int_lb_wdata;
    
    m_lb_wr_rd = int_lb_wr_rd;
    m_lb_addr  = int_lb_addr ;
    m_lb_wdata = int_lb_wdata;
    
    if(nxt_lb_addr_reg[29:28] == 2'd0) begin//配置空间
        if(nxt_lb_addr_reg[27:24] == 4'd0) begin//系统配置
            sys_lb_cs_n  = int_lb_cs_n ;
            dbg_lb_cs_n  = 1'b1 ;
            m_lb_cs_n    = 1'b1 ; 
            
            int_lb_ack_n = sys_lb_ack_n;
            int_lb_rdata = sys_lb_rdata;
        end
        else begin//统计调试
            sys_lb_cs_n  = 1'b1 ;
            dbg_lb_cs_n  = int_lb_cs_n ;
            m_lb_cs_n = 1'b1      ; 
            
            int_lb_ack_n = dbg_lb_ack_n;
            int_lb_rdata = dbg_lb_rdata;
        end
    end
    else begin//外围配置
        sys_lb_cs_n  = 1'b1     ;
        dbg_lb_cs_n  = 1'b1 ;
        m_lb_cs_n = int_lb_cs_n; 
        
        int_lb_ack_n = m_lb_ack_n;
        int_lb_rdata = m_lb_rdata;
    end
end
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISMux#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .PKT_MODE   (1),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (2),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (9),//缓存FIFO的容量的指数位宽
    .DATA_BYTE  (16),
    .USER_BIT   (1),
    .MIN_PKTLINE(5)
)
AXISMux_Inst(
//时钟复位信号
    .s_axis_clk   ({2{axis_clk  }}),
    .s_axis_rst_n ({2{axis_rst_n}}),
    .m_axis_clk   (axis_clk  ),
    .m_axis_rst_n (axis_rst_n),
//固定优先级接口
    .iv_fix_prior ({2{1'b0}}),
//报文分组数据接收接口
    .s_axis_tready({s_netw_axis_tready,hcp2apm_axis_tready}),
    .s_axis_tvalid({s_netw_axis_tvalid,hcp2apm_axis_tvalid}),
    .s_axis_tkeep ({s_netw_axis_tkeep ,hcp2apm_axis_tkeep }),
    .s_axis_tdata ({s_netw_axis_tdata ,hcp2apm_axis_tdata }),
    .s_axis_tlast ({s_netw_axis_tlast ,hcp2apm_axis_tlast }),
    .s_axis_tuser ({s_netw_axis_tuser ,hcp2apm_axis_tuser }),
//报文分组数据输出接口
    .m_axis_tready(apm2crd_axis_tready),
    .m_axis_tvalid(apm2crd_axis_tvalid),
    .m_axis_tkeep (apm2crd_axis_tkeep ),
    .m_axis_tdata (apm2crd_axis_tdata ),
    .m_axis_tlast (apm2crd_axis_tlast ),
    .m_axis_tuser (apm2crd_axis_tuser )
);

CPURcvDisp #(
    .THREAD_SUM(THREAD_SUM)
)
CPURcvDisp_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//数据输入接口             
    .s_axis_tready(apm2crd_axis_tready),
    .s_axis_tvalid(apm2crd_axis_tvalid),
    .s_axis_tkeep (apm2crd_axis_tkeep ),
    .s_axis_tdata (apm2crd_axis_tdata ),
    .s_axis_tlast (apm2crd_axis_tlast ),
    .s_axis_tuser (apm2crd_axis_tuser ),
//数据输出接口             
    .m_axis_tready(m_host_axis_tready),
    .m_axis_tvalid(m_host_axis_tvalid),
    .m_axis_tkeep (m_host_axis_tkeep ),
    .m_axis_tdata (m_host_axis_tdata ),
    .m_axis_tlast (m_host_axis_tlast ),
    .m_axis_tuser (m_host_axis_tuser ),
//CPU负载信息                       
    .o_rx_cpuid_valid(crd2clss_valid),
    .ov_rx_cpuid     (crd2clss_cpuid),
    
    .iv_cpu_loadstate(ov_cpu_loadstate),
    .iv_cpu_backlimit(wv_cpu_backlimit),
//状态配置信息
    .iv_smac_addr(ov_local_mac),
    .iv_dmac_addr(wv_cpuid_mac)
);

CPUTransCtrl #(
    .THREAD_SUM(THREAD_SUM)
)
CPUTransCtrl_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//数据输入接口             
    .s_axis_tready(s_host_axis_tready),
    .s_axis_tvalid(s_host_axis_tvalid),
    .s_axis_tkeep (s_host_axis_tkeep ),
    .s_axis_tdata (s_host_axis_tdata ),
    .s_axis_tlast (s_host_axis_tlast ),
    .s_axis_tuser (s_host_axis_tuser ),
//数据输出接口             
    .m_axis_tready(ctc2apd_axis_tready),
    .m_axis_tvalid(ctc2apd_axis_tvalid),
    .m_axis_tkeep (ctc2apd_axis_tkeep ),
    .m_axis_tdata (ctc2apd_axis_tdata ),
    .m_axis_tlast (ctc2apd_axis_tlast ),
    .m_axis_tuser (ctc2apd_axis_tuser ),
    .m_axis_tdest (ctc2apd_axis_tdest ),
//CPU负载信息                       
    .o_tx_cpuid_valid(ctc2clss_valid),
    .ov_tx_cpuid     (ctc2clss_cpuid)
);

CPULoadStateStatis#(
    .THREAD_SUM(THREAD_SUM)
)
CLSS_Inst(
    .clk  (axis_clk  ),   
    .rst_n(axis_rst_n),
                          
//CPU负载信息             
    .i_rx_cpuid_valid(crd2clss_valid),
    .iv_rx_cpuid     (crd2clss_cpuid),
    
    .i_tx_cpuid_valid(ctc2clss_valid),
    .iv_tx_cpuid     (ctc2clss_cpuid),
    
    .ov_cpu_backlog  (wv_cpu_backlog),
    
    .ov_thread_rcv_pkt_cnt  (wv_thread_rcv_pkt_cnt ),
    .ov_thread_send_pkt_cnt (wv_thread_send_pkt_cnt)
);

HCPHub#(
    .Mbus_ID(Mbus_ID)
)
HCPHub_Inst(
//时钟复位信号
    .axis_clk  (axis_clk),
    .axis_rst_n(axis_rst_n),
    .hcp_clk   (hcp_clk  ),
    .hcp_rst_n (hcp_rst_n),
//报文分组数据接收接口
    .s_axis_tready(apd2hcp_axis_tready),
    .s_axis_tvalid(apd2hcp_axis_tvalid),
    .s_axis_tkeep (apd2hcp_axis_tkeep ),
    .s_axis_tdata (apd2hcp_axis_tdata ),
    .s_axis_tlast (apd2hcp_axis_tlast ),
    .s_axis_tuser (apd2hcp_axis_tuser[11]),
//报文分组数据输出接口
    .m_axis_tready(hcp2apm_axis_tready),
    .m_axis_tvalid(hcp2apm_axis_tvalid),
    .m_axis_tkeep (hcp2apm_axis_tkeep ),
    .m_axis_tdata (hcp2apm_axis_tdata ),
    .m_axis_tlast (hcp2apm_axis_tlast ),
    .m_axis_tuser (hcp2apm_axis_tuser ),
//配置管理接口         
    .m_lb_cs_n (int_lb_cs_n ),
    .m_lb_ack_n(int_lb_ack_n),
    .m_lb_wr_rd(int_lb_wr_rd),
    .m_lb_addr (int_lb_addr ),
    .m_lb_wdata(int_lb_wdata),
    .m_lb_rdata(int_lb_rdata)
);  

SysMgmtCtrl #(
    .THREAD_SUM (THREAD_SUM),
    .VERSION    (VERSION)
)SysMgmtCtrl_Inst(
//时钟复位信号
    .clk             (hcp_clk  ),
    .rst_n           (hcp_rst_n),
//CPU状态信号       
    .iv_cpu_backlog     (wv_cpu_backlog),
    .ov_cpu_percentage  (wv_cpu_percentage),
    .ov_cpu_backlimit   (wv_cpu_backlimit),
//配置参数信号
    .ov_local_mac       (ov_local_mac       ),
    .ov_cpuid_mac       (wv_cpuid_mac       ),
    .ov_perip_mac       (ov_perip_mac       ),
    .ov_meter_mac       (ov_meter_mac       ),
    .ov_local_ip        (ov_local_ip        ),
    .ov_meter_ip        (ov_meter_ip        ),
    .ov_local_srv6_opbit(ov_local_srv6_opbit),
    .o_soft_rst_n       (o_soft_rst_n       ),
//配置管理接口
    .s_lb_cs_n       (sys_lb_cs_n ),
    .s_lb_ack_n      (sys_lb_ack_n),
    .s_lb_wr_rd      (sys_lb_wr_rd),
    .s_lb_addr       (sys_lb_addr ),
    .s_lb_wdata      (sys_lb_wdata),
    .s_lb_rdata      (sys_lb_rdata)
);            

DbgMgmtCtrl #(
    .PORT_SUM   (PORT_SUM),
    .THREAD_SUM (THREAD_SUM)
)DbgMgmtCtrl_Inst(
//时钟复位信号
    .clk                    (hcp_clk  ),
    .rst_n                  (hcp_rst_n),
//输入状态信号          
    .iv_port_rcv_allpkt_cnt (iv_port_rcv_allpkt_cnt ),
    .iv_port_rcv_filtpkt_cnt(iv_port_rcv_filtpkt_cnt),
    .iv_port_rcv_discpkt_cnt(iv_port_rcv_discpkt_cnt),
    .iv_port_rcv_tm_cnt     (iv_port_rcv_tm_cnt     ), 
    .iv_port_send_pkt_cnt   (iv_port_send_pkt_cnt   ),
    .iv_port_send_tm_cnt    (iv_port_send_tm_cnt    ),
                                           
    .iv_cpu_rcv_allpkt_cnt  (iv_cpu_rcv_allpkt_cnt  ),
    .iv_cpu_rcv_filtpkt_cnt (iv_cpu_rcv_filtpkt_cnt ),
    .iv_cpu_rcv_discpkt_cnt (iv_cpu_rcv_discpkt_cnt ),
    .iv_cpu_rcv_tm_cnt      (iv_cpu_rcv_tm_cnt      ), 
    .iv_cpu_send_pkt_cnt    (iv_cpu_send_pkt_cnt    ),
    .iv_cpu_send_tm_cnt     (iv_cpu_send_tm_cnt     ),

    .iv_thread_rcv_pkt_cnt  (wv_thread_rcv_pkt_cnt  ),
    .iv_thread_send_pkt_cnt (wv_thread_send_pkt_cnt ),
//配置管理接口
    .s_lb_cs_n       (dbg_lb_cs_n ),
    .s_lb_ack_n      (dbg_lb_ack_n),
    .s_lb_wr_rd      (dbg_lb_wr_rd),
    .s_lb_addr       (dbg_lb_addr ),
    .s_lb_wdata      (dbg_lb_wdata),
    .s_lb_rdata      (dbg_lb_rdata)
);

AXISDisp#(
    .STREAM_SUM             (2),
    .DATA_BYTE              (16),
    .USER_BIT               (12)
)
AXISDisp_Inst(  
    .s_axis_clk             (axis_clk  ),
    .s_axis_rst_n           (axis_rst_n),
    
    .s_axis_tready          (ctc2apd_axis_tready),
    .s_axis_tvalid          (ctc2apd_axis_tvalid),
    .s_axis_tkeep           (ctc2apd_axis_tkeep ),
    .s_axis_tdata           (ctc2apd_axis_tdata ),
    .s_axis_tlast           (ctc2apd_axis_tlast ),
    .s_axis_tuser           (ctc2apd_axis_tuser ),
    .s_axis_tdst            (ctc2apd_axis_tdest ),
    
    .m_axis_tready          ({m_netw_axis_tready,apd2hcp_axis_tready}),
    .m_axis_tvalid          ({m_netw_axis_tvalid,apd2hcp_axis_tvalid}),
    .m_axis_tkeep           ({m_netw_axis_tkeep ,apd2hcp_axis_tkeep }),
    .m_axis_tdata           ({m_netw_axis_tdata ,apd2hcp_axis_tdata }),
    .m_axis_tlast           ({m_netw_axis_tlast ,apd2hcp_axis_tlast }),
    .m_axis_tuser           ({m_netw_axis_tuser ,apd2hcp_axis_tuser })
);
endmodule
/*
CPUSchCtrlEngine #(
    .THREAD_SUM(),
    .Mbus_ID(),
    .VERSION()
)CPUSchCtrlEngine_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
    .hcp_clk   (),
    .hcp_rst_n (),
//主机数据输入接口    
    .s_host_axis_tready(),
    .s_host_axis_tvalid(),
    .s_host_axis_tkeep (),
    .s_host_axis_tdata (),
    .s_host_axis_tlast (),
    .s_host_axis_tuser (),
//主机数据输出接口                     
    .m_host_axis_tready(),
    .m_host_axis_tvalid(),
    .m_host_axis_tkeep (),
    .m_host_axis_tdata (),
    .m_host_axis_tlast (),
    .m_host_axis_tuser (),
//网络数据输入接口            
    .s_netw_axis_tready(),
    .s_netw_axis_tvalid(),
    .s_netw_axis_tkeep (),
    .s_netw_axis_tdata (),
    .s_netw_axis_tlast (),
    .s_netw_axis_tuser (),
//网络数据输出接口                 
    .m_netw_axis_tready(),
    .m_netw_axis_tvalid(),
    .m_netw_axis_tkeep (),
    .m_netw_axis_tdata (),
    .m_netw_axis_tlast (),
    .m_netw_axis_tuser (),
//配置管理接口            
    .m_lb_cs_n (),
    .m_lb_ack_n(),
    .m_lb_wr_rd(),
    .m_lb_addr (),
    .m_lb_wdata(),
    .m_lb_rdata(),
//状态输出信号    
    .ov_cpu_loadstate(),
//配置参数信号
    .ov_local_mac       (),
    .ov_perip_mac       (),
    .ov_meter_mac       (),
    .ov_local_ip        (),
    .ov_meter_ip        (),
    .ov_local_srv6_opbit(),
    .o_soft_rst_n       (),
//统计信号
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
    .iv_cpu_send_tm_cnt     ()
);
*/