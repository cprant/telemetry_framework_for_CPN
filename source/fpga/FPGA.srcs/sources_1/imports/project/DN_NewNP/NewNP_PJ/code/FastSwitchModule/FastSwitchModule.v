/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  FastSwitchModule.v
Target Device All
Dscription 
    (1)	接收并汇聚来自千兆网口、万兆网口、CPU、SRv6转发引擎以及网络要测引擎的分组
    (2)	提取汇聚分组的五元组，基于带掩码的五元组信息对IPv6或SRv6分组进行转发
        1)	目的IPv6地址高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)
        2)	源IPv6地址高64位；
        3)	NH16位
        4)	目的端口号16位
        5)	源端口号16位
        6)	176位掩码，1表示对应位参与匹配，0代表不参与匹配
        7)	转发动作共8位，采用bitmap方式，支持多端口转发
    (3)	实现并行寄存器查表引擎，支持32条带掩码的转发规则
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
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module FastSwitchModule # (
    parameter   PORT_SUM = 32,
                ENT_SUM  = 64,
                
                INPORT_SUM  = PORT_SUM+3,//网络端口+CPU+SRv6处理+Meter
                OUTPORT_SUM = PORT_SUM+2//网络端口+CPU+SRv6处理
)(
//时钟复位信号
    input  wire                    axis_clk,
    input  wire                    axis_rst_n,
//分组数据输入接口
(*mark_debug="true"*)    output wire [  1*INPORT_SUM-1:0] s_axis_tready,
(*mark_debug="true"*)    input  wire [  1*INPORT_SUM-1:0] s_axis_tvalid,
(*mark_debug="true"*)    input  wire [ 16*INPORT_SUM-1:0] s_axis_tkeep ,
(*mark_debug="true"*)    input  wire [128*INPORT_SUM-1:0] s_axis_tdata ,
(*mark_debug="true"*)    input  wire [  1*INPORT_SUM-1:0] s_axis_tlast ,
(*mark_debug="true"*)    input  wire [ 12*INPORT_SUM-1:0] s_axis_tuser ,
//高优先级BE分组数据输出接口
(*mark_debug="true"*)    input  wire [           1*3-1:0] m_axis_tready,
(*mark_debug="true"*)    output wire [           1*3-1:0] m_axis_tvalid,
(*mark_debug="true"*)    output wire [          16*3-1:0] m_axis_tkeep ,
(*mark_debug="true"*)    output wire [         128*3-1:0] m_axis_tdata ,
(*mark_debug="true"*)    output wire [           1*3-1:0] m_axis_tlast ,
(*mark_debug="true"*)    output wire [           1*3-1:0] m_axis_tuser ,
//配置管理接口                    
    input  wire                    s_lb_cs_n ,
    output wire                    s_lb_ack_n,
    input  wire                    s_lb_wr_rd,
    input  wire [            31:0] s_lb_addr ,
    input  wire [            31:0] s_lb_wdata,
    output wire [            31:0] s_lb_rdata,
//配置寄存器
    input wire  [ OUTPORT_SUM-1:0] iv_local_srv6_opbit
);
/*-----------------------------------------------------------
                    中间变量声明区域
------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire                fsm2ipfp_axis_tready;
wire                fsm2ipfp_axis_tvalid;
wire [        15:0] fsm2ipfp_axis_tkeep ;
wire [       127:0] fsm2ipfp_axis_tdata ;
wire                fsm2ipfp_axis_tlast ;
wire [         0:0] fsm2ipfp_axis_tuser ;
             
wire                srpp2fsm_axis_tready;
             
wire                fsm_axis_tready;
             
wire                srkp2fslu_key_axis_tready;
wire                srkp2fslu_key_axis_tvalid;
wire [       175:0] srkp2fslu_key_axis_tdata ;
             
wire                   fslu2ipfp_rsl_axis_tready;
wire                   fslu2ipfp_rsl_axis_tvalid;
wire [OUTPORT_SUM-1:0] fslu2ipfp_rsl_axis_tdata ;
wire [           16:0] fslu2ipfp_rsl_axis_tuser ;//{hit,index}

wire                   ipfp2apd_axis_tready;
wire                   ipfp2apd_axis_tvalid;
wire [           15:0] ipfp2apd_axis_tkeep ;
wire [          127:0] ipfp2apd_axis_tdata ;
wire                   ipfp2apd_axis_tlast ;
wire [            0:0] ipfp2apd_axis_tuser ;
wire [OUTPORT_SUM-1:0] ipfp2apd_axis_tdest ;

assign fsm_axis_tready = fsm2ipfp_axis_tready & srpp2fsm_axis_tready;
FastSwitchMux#(
    .PORT_SUM   (INPORT_SUM)
)
FastSwitchMux_Inst(
//时钟复位信号
    .axis_clk   (axis_clk  ),
    .axis_rst_n (axis_rst_n),
//报文分组数据接收接口
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(fsm_axis_tready    ),
    .m_axis_tvalid(fsm2ipfp_axis_tvalid),
    .m_axis_tkeep (fsm2ipfp_axis_tkeep ),
    .m_axis_tdata (fsm2ipfp_axis_tdata ),
    .m_axis_tlast (fsm2ipfp_axis_tlast ),
    .m_axis_tuser (fsm2ipfp_axis_tuser )
);

SRv6KeyParser SRv6KeyParser_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//报文分组数据接收接口
    .s_axis_tready(srpp2fsm_axis_tready),
    .s_axis_tvalid(fsm2ipfp_axis_tvalid & fsm_axis_tready),
    .s_axis_tkeep (fsm2ipfp_axis_tkeep ),
    .s_axis_tdata (fsm2ipfp_axis_tdata ),
    .s_axis_tlast (fsm2ipfp_axis_tlast ),
    .s_axis_tuser (fsm2ipfp_axis_tuser ),
//关键字输出
    .m_key_axis_tready(srkp2fslu_key_axis_tready),
    .m_key_axis_tvalid(srkp2fslu_key_axis_tvalid),
    .m_key_axis_tdata (srkp2fslu_key_axis_tdata )
);

FastSwitchLookup#(
    .ENT_SUM(ENT_SUM)
)FastSwitchLookup_Inst(
//时钟复位信号
    .clk  (axis_clk  ),
    .rst_n(axis_rst_n),
//表项配置               
    .s_lb_cs_n (s_lb_cs_n ),
    .s_lb_ack_n(s_lb_ack_n),
    .s_lb_wr_rd(s_lb_wr_rd),
    .s_lb_addr (s_lb_addr ),
    .s_lb_wdata(s_lb_wdata),
    .s_lb_rdata(s_lb_rdata),
//查表接口
    .s_key_axis_tready(srkp2fslu_key_axis_tready),
    .s_key_axis_tvalid(srkp2fslu_key_axis_tvalid),
    .s_key_axis_tdata (srkp2fslu_key_axis_tdata ),
                      
    .m_rsl_axis_tready(fslu2ipfp_rsl_axis_tready),
    .m_rsl_axis_tvalid(fslu2ipfp_rsl_axis_tvalid),
    .m_rsl_axis_tdata (fslu2ipfp_rsl_axis_tdata ),
    .m_rsl_axis_tuser (fslu2ipfp_rsl_axis_tuser )//{hit,index}
);


IPv6FwdProc#(
    .PORT_SUM   (OUTPORT_SUM),
    .CPU_PORTID (PORT_SUM   )//CPU对应的内部端口编号紧挨着网络端口
)
IPv6FwdProc_Inst(
//时钟复位信号
    .axis_clk   (axis_clk  ),
    .axis_rst_n (axis_rst_n),
//报文分组数据接收接口
    .s_axis_tready(fsm2ipfp_axis_tready),
    .s_axis_tvalid(fsm2ipfp_axis_tvalid & fsm_axis_tready),
    .s_axis_tkeep (fsm2ipfp_axis_tkeep ),
    .s_axis_tdata (fsm2ipfp_axis_tdata ),
    .s_axis_tlast (fsm2ipfp_axis_tlast ),
    .s_axis_tuser (fsm2ipfp_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(ipfp2apd_axis_tready),
    .m_axis_tvalid(ipfp2apd_axis_tvalid),
    .m_axis_tkeep (ipfp2apd_axis_tkeep ),
    .m_axis_tdata (ipfp2apd_axis_tdata ),
    .m_axis_tlast (ipfp2apd_axis_tlast ),
    .m_axis_tuser (ipfp2apd_axis_tuser ),
    .m_axis_tdest (ipfp2apd_axis_tdest ),
    
//查表结果输入接口
    .s_rsl_axis_tready(fslu2ipfp_rsl_axis_tready),
    .s_rsl_axis_tvalid(fslu2ipfp_rsl_axis_tvalid),
    .s_rsl_axis_tdata (fslu2ipfp_rsl_axis_tdata ),
    .s_rsl_axis_tuser (fslu2ipfp_rsl_axis_tuser ),
//配置寄存器
    .iv_local_srv6_opbit(iv_local_srv6_opbit)
);

AXISDisp#(
    .STREAM_SUM             (3),
    .DATA_BYTE              (16),
    .USER_BIT               (1)
)
AXISDisp_Inst(  
    .s_axis_clk             (axis_clk  ),
    .s_axis_rst_n           (axis_rst_n),
    
    .s_axis_tready          (ipfp2apd_axis_tready),
    .s_axis_tvalid          (ipfp2apd_axis_tvalid),
    .s_axis_tkeep           (ipfp2apd_axis_tkeep ),
    .s_axis_tdata           (ipfp2apd_axis_tdata ),
    .s_axis_tlast           (ipfp2apd_axis_tlast ),
    .s_axis_tuser           (ipfp2apd_axis_tuser ),
    .s_axis_tdst            ({ipfp2apd_axis_tdest[PORT_SUM +: 2], (|ipfp2apd_axis_tdest[PORT_SUM-1:0])}),
    
    .m_axis_tready          (m_axis_tready),
    .m_axis_tvalid          (m_axis_tvalid),
    .m_axis_tkeep           (m_axis_tkeep ),
    .m_axis_tdata           (m_axis_tdata ),
    .m_axis_tlast           (m_axis_tlast ),
    .m_axis_tuser           (m_axis_tuser )
);
endmodule
/*
FastSwitchModule#(
    .PORT_SUM (),
    .ENT_SUM  ()
)
FastSwitchModule_Inst(
//时钟复位信号
    .axis_clk   (),
    .axis_rst_n (),
//报文分组数据接收接口
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