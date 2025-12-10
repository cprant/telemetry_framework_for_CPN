/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  NetTelMeterEngine.v
Target Device All
Description 
    1)	接收并汇聚输入引擎和输出引擎模块触发产生的遥测信息
    2)	针对汇聚的遥测信息，封装生成网络遥测分组
    3)	将生成的遥测分组发往遥测服务器

Data_Struct:
    1)遥测信息
        [115:100] pkt_len
        [ 99: 36] timestamp
        [ 35: 16] flow label
        [ 15:  0] 帧的序列号seqnum
        
    2)int_axis_tdata
        [143:116] pkt_len
        [115: 52] 本地时间戳
        [ 51: 32] flow label
        [ 31: 16] 帧的序列号seqnum
        [ 15:  0] 接口标识
        
    3)遥测帧数据
        以太网(14B)  目的MAC是遥测服务器地址MAC
            DMAC=6
            SMAC=6
            LEN/TYPE=2
        IPv6头(40B） 目的IPv6地址为遥测服务器地址的IPv6头
            Version=6
            Traffic class=0
            Flow label=0
            Payload length=34
            Next Header=253（遥测帧）
            HopLimit=8
            SIP=本地IPv6地址
            DIP=遥测服务器地址
        遥测数据（34B）	
            2字节报文长度
            8字节本地时间戳
            4字节flow label
            2字节帧的序列号seqnum
            2字节接口标识
            4字节：CPU0的负载
            4字节：CPU1的负载
            4字节：CPU2的负载
            4字节：CPU3的负载

Author : LXJ
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
Caution:
    1)
*/

module NetTelMeterEngine#(
    parameter   THREAD_SUM     = 4,
                TM_SUM         = 10,
                LOCAL_CNT_STEP = 32'h8_0000,
                DATA_BYTE      = 1
)(
    input  wire [      TM_SUM-1:0] s_axis_clk  ,   
    input  wire [      TM_SUM-1:0] s_axis_rst_n,
                                   
    input  wire                    m_axis_clk  ,   
    input  wire                    m_axis_rst_n,
                          
//遥测数据输入接口
    output wire [      TM_SUM-1:0] s_tm_axis_tready,
    input  wire [      TM_SUM-1:0] s_tm_axis_tvalid,
    input  wire [  TM_SUM*116-1:0] s_tm_axis_tdata ,
                          
    input  wire                    m_axis_tready,
    output wire                    m_axis_tvalid,
    output wire [   DATA_BYTE-1:0] m_axis_tkeep,
    output wire [ DATA_BYTE*8-1:0] m_axis_tdata,
    output wire                    m_axis_tlast,
    output wire [            11:0] m_axis_tuser,
    
    input  wire [ THREAD_SUM*32-1:0] iv_cpu_loadstate,
    input  wire [           47:0] iv_smac_addr,
    input  wire [           47:0] iv_dmac_addr,
                           
    input  wire [          127:0] iv_sip_addr,
    input  wire [          127:0] iv_dip_addr,
    
(*mark_debug="true"*)    output  reg [          63:0] ov_local_cnt
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire         int_axis_tready;
wire         int_axis_tvalid;
wire [ 17:0] int_axis_tkeep ;
wire [143:0] int_axis_tdata ;
wire         int_axis_tlast ;
wire [  0:0] int_axis_tuser ;

wire         acf_axis_tready;
wire         acf_axis_tvalid;
wire [ 17:0] acf_axis_tkeep ;
wire [143:0] acf_axis_tdata ;
wire         acf_axis_tlast ;
wire [  0:0] acf_axis_tuser ;

wire [ 31:0] acf_free_space ;
(*mark_debug="true"*)wire [ 31:0] acf_used_space ;

wire [TM_SUM*144-1:0] tm_reg;
/*-----------------------------------------------------------------------
                    本地时间生成
-----------------------------------------------------------------------*/
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0)
        ov_local_cnt <= 64'b0;
    else
        ov_local_cnt <= ov_local_cnt + LOCAL_CNT_STEP;
end
/*-----------------------------------------------------------------------
                    输入遥测信息处理
-----------------------------------------------------------------------*/
generate
    genvar i;
    for(i=0;i<TM_SUM;i=i+1) begin:tm_clk
        assign tm_reg[i*144+64  +: 80] = s_tm_axis_tdata[i*116+36 +: 80];//64bit timestamp + 16bit pkt_len
        assign tm_reg[i*144+16  +: 48] = {12'b0,s_tm_axis_tdata[i*116 +: 36]};//32bit flow_label + 16bit seqnum
        assign tm_reg[i*144     +: 16] = i[15:0];//端口标识
    end
endgenerate
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISMux#(
    .ASYNC_EN   (1),//同步或异步  0：同步  1：异步
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (TM_SUM),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (6),//缓存FIFO的容量的指数位宽
    .DATA_BYTE  (18),
    .USER_BIT   (1),
    .MIN_PKTLINE(1)
)TMMux_Inst(
//时钟复位信号
    .s_axis_clk   (s_axis_clk  ),
    .s_axis_rst_n (s_axis_rst_n),
    .m_axis_clk   (m_axis_clk  ),
    .m_axis_rst_n (m_axis_rst_n),
//固定优先级接口
    .iv_fix_prior ({TM_SUM{1'b0}}),
//报文分组数据接收接口
    .s_axis_tready(s_tm_axis_tready),
    .s_axis_tvalid(s_tm_axis_tvalid),
    .s_axis_tkeep ({(TM_SUM*18){1'b1}}),
    .s_axis_tdata (tm_reg),
    .s_axis_tlast ({TM_SUM{1'b1}}),
    .s_axis_tuser ({TM_SUM{1'b0}}),
//BE分组数据输出接口
    .m_axis_tready(int_axis_tready),
    .m_axis_tvalid(int_axis_tvalid),
    .m_axis_tkeep (int_axis_tkeep ),
    .m_axis_tdata (int_axis_tdata ),
    .m_axis_tlast (int_axis_tlast ),
    .m_axis_tuser (int_axis_tuser )
);

AXISFifoBuf #(
    .ASYNC_EN               ( 0                 ),
    .DEEP_WIDTH             ( 9                 ),  //512个遥测数据
    .PKT_MODE               ( 0                 ),
    .DATA_BYTE              ( 18                ),  //MD共18字节 144位
    .USER_BIT               ( 1                 ),
    .MIN_PKTLINE            ( 1                 )   //最小1行即可缓存1个遥测数据
)RxDesBuf(  
    //ports 
    .s_axis_clk             ( m_axis_clk        ),
    .s_axis_rst_n           ( m_axis_rst_n      ),
        
    .m_axis_clk             ( m_axis_clk        ),
    .m_axis_rst_n           ( m_axis_rst_n      ),
        
    .s_axis_tready          ( int_axis_tready   ), //apm2acf
    .s_axis_tvalid          ( int_axis_tvalid   ),
    .s_axis_tkeep           ( int_axis_tkeep    ),
    .s_axis_tdata           ( int_axis_tdata    ),
    .s_axis_tlast           ( int_axis_tlast    ),
    .s_axis_tuser           ( int_axis_tuser    ),
        
    .m_axis_tready          ( acf_axis_tready   ), //acf2tmpg
    .m_axis_tvalid          ( acf_axis_tvalid   ),
    .m_axis_tkeep           ( acf_axis_tkeep    ),
    .m_axis_tdata           ( acf_axis_tdata    ),
    .m_axis_tlast           ( acf_axis_tlast    ),
    .m_axis_tuser           ( acf_axis_tuser    ),
        
    .free_space             ( acf_free_space    ),
    .used_space             ( acf_used_space    )
);  


TeleMeterPktGen#(
    .OUT_BYTE   (DATA_BYTE),
    .THREAD_SUM (THREAD_SUM)
)TMPG_Inst(
    .axis_clk        (m_axis_clk  ),   
    .axis_rst_n      (m_axis_rst_n),
                     
    .s_axis_tready   (acf_axis_tready),
    .s_axis_tvalid   (acf_axis_tvalid),
    .s_axis_tkeep    (acf_axis_tkeep ),
    .s_axis_tdata    (acf_axis_tdata ),
    .s_axis_tlast    (acf_axis_tlast ),
    .s_axis_tuser    (acf_axis_tuser ),
                     
    .m_axis_tready   (m_axis_tready),
    .m_axis_tvalid   (m_axis_tvalid),
    .m_axis_tkeep    (m_axis_tkeep ),
    .m_axis_tdata    (m_axis_tdata ),
    .m_axis_tlast    (m_axis_tlast ),
    .m_axis_tuser    (m_axis_tuser ),

    .iv_cpu_loadstate(iv_cpu_loadstate),
    .iv_smac_addr    (iv_smac_addr    ),
    .iv_dmac_addr    (iv_dmac_addr    ),
                      
    .iv_sip_addr     (iv_sip_addr     ),
    .iv_dip_addr     (iv_dip_addr     )
); 

endmodule
/*
NetTelMeterEngine#(
    .THREAD_SUM    (4),
    .TM_SUM        (1),
    .LOCAL_CNT_STEP(32'h8_0000),
    .DATA_BYTE     (1)
)NTME_Inst(
    .s_axis_clk      (),   
    .s_axis_rst_n    (),
                     
    .m_axis_clk      (),   
    .m_axis_rst_n    (),
                     
    .s_tm_axis_tready(),
    .s_tm_axis_tvalid(),
    .s_tm_axis_tdata (),
                     
    .m_axis_tready   (),
    .m_axis_tvalid   (),
    .m_axis_tkeep    (),
    .m_axis_tdata    (),
    .m_axis_tlast    (),
    .m_axis_tuser    (),

    .iv_cpu_loadstate(),
    .iv_smac_addr    (),
    .iv_dmac_addr    (),

    .iv_sip_addr     (),
    .iv_dip_addr     (),
    
    .ov_local_cnt    ()
);     
*/