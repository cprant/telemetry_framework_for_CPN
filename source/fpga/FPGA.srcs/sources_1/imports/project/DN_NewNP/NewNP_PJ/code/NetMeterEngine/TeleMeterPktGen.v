/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  TeleMeterPktGen.v
Target Device All
Dscription 
    1)根据轮询每个输入输出接口并缓存的遥测信息,得到20位的flowID和16位的seqnum
      并将端口号（4bit）和当前的本地时间（64bit）一共104bit写入遥测信息缓存的AXIS缓存FIFO中。
    2)当AXIS缓存FIFO非空时，遥测帧生成读取一个遥测信息
      并连同本地负载状态信息一起，生成遥测分组发往遥测服务器。

Data_Struct:
    1)s_axis_tdata
        [143:128] 报文长度pkt_len
        [127: 64] 本地时间戳
        [ 63: 32] flow label
        [ 31: 16] 帧的序列号seqnum
        [ 15:  0] 接口标识
        
    2)遥测帧数据
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
    3)Metadata    
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
Author : LXJ
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
Caution:
    1)
*/

module TeleMeterPktGen#(
    parameter   OUT_BYTE   = 1,
                THREAD_SUM = 4
)(
    input  wire                  axis_clk  ,   
    input  wire                  axis_rst_n,
                          
(*mark_debug="true"*)    output reg                   s_axis_tready,
(*mark_debug="true"*)    input  wire                  s_axis_tvalid,
    input  wire [          17:0] s_axis_tkeep ,
(*mark_debug="true"*)    input  wire [         143:0] s_axis_tdata ,
(*mark_debug="true"*)    input  wire                  s_axis_tlast ,
(*mark_debug="true"*)    input  wire                  s_axis_tuser ,
                          
(*mark_debug="true"*)    input  wire                  m_axis_tready,
(*mark_debug="true"*)    output wire                  m_axis_tvalid,
    output wire [  OUT_BYTE-1:0] m_axis_tkeep,
(*mark_debug="true"*)    output wire [OUT_BYTE*8-1:0] m_axis_tdata,
(*mark_debug="true"*)    output wire                  m_axis_tlast,
(*mark_debug="true"*)    output wire [          11:0] m_axis_tuser,
    
    input  wire [THREAD_SUM*32-1:0] iv_cpu_loadstate,
    input  wire [          47:0] iv_smac_addr,
    input  wire [          47:0] iv_dmac_addr,
                          
    input  wire [         127:0] iv_sip_addr,
    input  wire [         127:0] iv_dip_addr
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
localparam  TM_BYTE  = 16+72+THREAD_SUM*4,  //104byte=832bits
            SUB_RATIO = (TM_BYTE/OUT_BYTE) + (|(TM_BYTE%OUT_BYTE)); //104

wire                            int_axis_tready;
reg                             int_axis_tvalid;
reg  [  SUB_RATIO*OUT_BYTE-1:0] int_axis_tkeep ;
reg  [SUB_RATIO*OUT_BYTE*8-1:0] int_axis_tdata ;
reg                             int_axis_tlast ;
reg  [                    11:0] int_axis_tuser ;

wire [       THREAD_SUM*32-1:0] invert_cpu_loadstate;
/*-----------------------------------------------------------------------
                    测量报文生成
-----------------------------------------------------------------------*/
always @(*) begin
    s_axis_tready = int_axis_tready;
    
    int_axis_tvalid = ((int_axis_tready == 1'b1) && (s_axis_tvalid == 1'b1));
    int_axis_tkeep =  {TM_BYTE{1'b1}} << (SUB_RATIO*OUT_BYTE-TM_BYTE);
    int_axis_tdata = {8'h80,8'h0,TM_BYTE[10:0],2'd0,1'd0,10'd0,4'd1,20'd0,16'd0,48'd0,
                      iv_dmac_addr,iv_smac_addr,16'h86DD,
                      4'h6,8'h0,20'h0,16'd34,8'd253,8'd8,iv_sip_addr,iv_dip_addr,
                      s_axis_tdata,invert_cpu_loadstate} << ((SUB_RATIO*OUT_BYTE-TM_BYTE)*8);
                     
    int_axis_tlast = 1'b1;
    int_axis_tuser = {1'b0,TM_BYTE[10:0]};    
end 

/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
DataInvert #(
    .GRP_WIDTH(32),
    .GRP_SUM  (THREAD_SUM)
)LoadstateInvert_inst(
    .iv_data(iv_cpu_loadstate),
    .ov_data(invert_cpu_loadstate)
);

AXISWidthSub #(
    .BYTE_DIR               ( 1               ),
    .OUT_BYTE               ( OUT_BYTE        ),
    .SUB_SUM                ( SUB_RATIO       ),
    .USER_BIT               ( 12              )
)PktWidthSub_Inst(                             
    //ports                                    
    .axis_clk               ( axis_clk          ),
    .axis_rst_n             ( axis_rst_n        ),
                                
    .s_axis_tready          ( int_axis_tready   ),
    .s_axis_tvalid          ( int_axis_tvalid   ),
    .s_axis_tkeep           ( int_axis_tkeep    ),
    .s_axis_tdata           ( int_axis_tdata    ),
    .s_axis_tlast           ( int_axis_tlast    ),
    .s_axis_tuser           ( int_axis_tuser    ),
                                
    .m_axis_tready          ( m_axis_tready     ),
    .m_axis_tvalid          ( m_axis_tvalid     ),
    .m_axis_tkeep           ( m_axis_tkeep      ),
    .m_axis_tdata           ( m_axis_tdata      ),
    .m_axis_tlast           ( m_axis_tlast      ),
    .m_axis_tuser           ( m_axis_tuser      )
); 

endmodule
/*
TeleMeterPktGen#(
    .OUT_BYTE   (1),
    .THREAD_SUM (4)
)TMPG_Inst(
    .axis_clk        (),   
    .axis_rst_n      (),
                     
    .s_axis_tready   (),
    .s_axis_tvalid   (),
    .s_axis_tkeep    (),
    .s_axis_tdata    (),
    .s_axis_tlast    (),
    .s_axis_tuser    (),
                     
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
    .iv_dip_addr     ()
);     
*/