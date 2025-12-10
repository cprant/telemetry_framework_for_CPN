/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  SRv6OutputEngine.v
Target Device All
Dscription 
    (1)	接收带输出的分组数据，并转换为千兆或万兆接口MAC可接收的格式
    (2)	删除发送分组Metadata，增加以太网头，并将发送分组位宽转换为64bit(万兆)/8bit(千兆)
    (3)	支持对于接收的特定SRv6帧进行遥测
        1)	到达或发出的IPv6帧的NH为43（SRv6帧）
        2)	且IPv6目的地址的FUNC包含入口遥测指令
    (4)	接口协议采用标准AXI-Stream，位宽可参数化


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
    
    2)遥测信息
        [115:100] pkt_len
        [ 99: 36] timestamp
        [ 35: 16] flow label
        [ 15:  0] 帧的序列号seqnum
        
Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6OutputEngine #(
    parameter   OUT_BYTE    = 1,
                SRC_STEP   = 32'h8_0000,
                DST_STEP   = 32'h6_6667,
                INIT_DLY   = 3,//应当大于src_clk和dst_clk之间的倍率
                TIME_WIDTH = 64
)(
//时钟复位信号
    input  wire                  s_axis_clk  ,
    input  wire                  s_axis_rst_n,
    input  wire                  m_axis_clk  ,
    input  wire                  m_axis_rst_n,
    input  wire                  localcnt_clk  ,
    input  wire                  localcnt_rst_n,
//本地同步时钟                
    input  wire [          63:0] iv_local_cnt,
//报文分组数据接收接口   
    output wire                  s_axis_tready,
    input  wire                  s_axis_tvalid,
    input  wire [          15:0] s_axis_tkeep ,
    input  wire [         127:0] s_axis_tdata ,
    input  wire                  s_axis_tlast ,
    input  wire [           0:0] s_axis_tuser ,
//分组数据输出接口
    input  wire                  m_axis_tready,
    output wire                  m_axis_tvalid,
    output wire [  OUT_BYTE-1:0] m_axis_tkeep ,
    output wire [OUT_BYTE*8-1:0] m_axis_tdata ,
    output wire                  m_axis_tlast ,
    output wire [           0:0] m_axis_tuser ,
//遥测数据输出接口   
    input  wire                  m_tm_axis_tready,
    output wire                  m_tm_axis_tvalid,
    output wire [         115:0] m_tm_axis_tdata ,
//统计信息
    output wire [          63:0] ov_send_pkt_cnt,
    output wire [          63:0] ov_send_tm_cnt
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam SUB_RATIO = 16/OUT_BYTE;

wire [ 63:0] wv_local_cnt;

wire         w_md_tvalid;
wire [127:0] wv_md_tdata;

wire         stfc2sub_axis_tready;
wire         stfc2sub_axis_tvalid;
wire [ 15:0] stfc2sub_axis_tkeep ;
wire [127:0] stfc2sub_axis_tdata ;
wire         stfc2sub_axis_tlast ;
wire [  0:0] stfc2sub_axis_tuser ;
/*----------------------------------------------------------
                   IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 

SyncTimeCDC #(
    .SRC_STEP               ( SRC_STEP      ),
    .DST_STEP               ( DST_STEP      ),
    .INIT_DLY               ( INIT_DLY      ),
    .TIME_WIDTH             ( TIME_WIDTH    )
)SyncTimeCDC_Inst(
    //时钟复位信号
    .src_clk                (localcnt_clk  ),
    .src_rst_n              (localcnt_rst_n),
    .dst_clk                (m_axis_clk  ),
    .dst_rst_n              (m_axis_rst_n),
                            
    .iv_sync_period         (32'd1024),
    .iv_max_synctime        ({64{1'b1}}),
    //输入本地时钟        
    .iv_synctime            (iv_local_cnt),
    //输出本地时钟        
    .ov_synctime            (wv_local_cnt)
);
SRv6TransFmtCov SRv6TransFmtCov_Inst(
//时钟复位信号
    .s_axis_clk             (s_axis_clk  ),
    .s_axis_rst_n           (s_axis_rst_n),
    .m_axis_clk             (m_axis_clk  ),
    .m_axis_rst_n           (m_axis_rst_n),
    //本地同步时钟        
    .iv_local_cnt           (wv_local_cnt),
//报文分组数据接收接口
    .s_axis_tready          (s_axis_tready),
    .s_axis_tvalid          (s_axis_tvalid),
    .s_axis_tkeep           (s_axis_tkeep ),
    .s_axis_tdata           (s_axis_tdata ),
    .s_axis_tlast           (s_axis_tlast ),
    .s_axis_tuser           (s_axis_tuser ),
//分组数据输出接口
    .m_axis_tready          (stfc2sub_axis_tready),
    .m_axis_tvalid          (stfc2sub_axis_tvalid),
    .m_axis_tkeep           (stfc2sub_axis_tkeep ),
    .m_axis_tdata           (stfc2sub_axis_tdata ),
    .m_axis_tlast           (stfc2sub_axis_tlast ),
    .m_axis_tuser           (stfc2sub_axis_tuser ),   
    
    .m_tm_axis_tready       (m_tm_axis_tready),
    .m_tm_axis_tvalid       (m_tm_axis_tvalid),
    .m_tm_axis_tdata        (m_tm_axis_tdata ),
//统计信息
    .ov_send_pkt_cnt        (ov_send_pkt_cnt),
    .ov_send_tm_cnt         (ov_send_tm_cnt )
);

AXISWidthSub #(
    .BYTE_DIR(1),
    .OUT_BYTE(OUT_BYTE),//输出接口数据位宽，单位为字节，最高支持1024字节
    .SUB_SUM (SUB_RATIO),//输出相对输入缩减倍数，即将输入数据位宽除以输出数据位宽,支持倍数范围2~1024倍
    .USER_BIT(1)//tuser信号的位宽
)PktWidthSub_inst(
//时钟复位信号
    .axis_clk  (m_axis_clk  ),
    .axis_rst_n(m_axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(stfc2sub_axis_tready),    
    .s_axis_tvalid(stfc2sub_axis_tvalid),    
    .s_axis_tkeep (stfc2sub_axis_tkeep ),
    .s_axis_tdata (stfc2sub_axis_tdata ),
    .s_axis_tlast (stfc2sub_axis_tlast ),
    .s_axis_tuser (stfc2sub_axis_tuser ),    
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
SRv6OutputEngine #(
    .OUT_BYTE      (),
    .SRC_STEP      (),
    .DST_STEP      (),
    .INIT_DLY      (),
    .TIME_WIDTH    ()
)SRv6OutputEngine_Inst(
//时钟复位信号
    .s_axis_clk    (),
    .s_axis_rst_n  (),
    .m_axis_clk    (),
    .m_axis_rst_n  (),
    .localcnt_clk  (),
    .localcnt_rst_n(),
//本地同步时钟                
    .iv_local_cnt  (),
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
//遥测数据输出接口
    .m_tm_axis_tready(),
    .m_tm_axis_tvalid(),
    .m_tm_axis_tdata (),
//统计信息
    .ov_send_pkt_cnt(),
    .ov_send_tm_cnt ()
);
*/