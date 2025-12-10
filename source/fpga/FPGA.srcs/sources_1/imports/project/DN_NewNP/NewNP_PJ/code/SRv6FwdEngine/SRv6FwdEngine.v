////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  SRv6FwdEngine.v
Target Device All
Dscription 
    (1)	接收快速交换模块查表并待转发的SRv6分组进行输出预处理
    (2)	针对待输出的SRv6分组预处理，实现转发加速，包括
        1)	IPv6头部的目的IP地址替换
        2)	SRH的SL域修改
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
    2)des_axis_tuser
        0:转发报文
        1:本机报文
        2:错误IPv6报文，上报CPU
        3:错误SRv6报文，上报CPU
    3)des_axis_tdata
        [143:136] hdr_ext_len
        [135:128] ipv6/srv6-nh
        [127:  0] srv6-segment_list[sel]
Caution:
    1)默认输入的全部为SRv6，且已经剥离以太网头(64bit对齐)
    2)注意，默认SRv6头之后至少要有1字节的payload，否则会出现粘包问题(尾部处理出错)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6FwdEngine(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
//报文分组数据接收接口
    output wire         s_axis_tready,
    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep ,
    input  wire [127:0] s_axis_tdata ,
    input  wire         s_axis_tlast ,
    input  wire         s_axis_tuser ,
//分组数据输出接口
    input  wire         m_axis_tready,
    output wire         m_axis_tvalid,
    output wire [ 15:0] m_axis_tkeep,
    output wire [127:0] m_axis_tdata,
    output wire         m_axis_tlast,
    output wire [ 11:0] m_axis_tuser,
//配置寄存器
    input  wire [ 47:0] iv_smac_addr,
    input  wire [ 47:0] iv_dmac_addr
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam  ETH_SITE = 16;
  
wire         aethe2srfp_axis_tready;
wire         aethe2srfp_axis_tvalid;
wire [ 15:0] aethe2srfp_axis_tkeep ;
wire [127:0] aethe2srfp_axis_tdata ;
wire         aethe2srfp_axis_tlast ;
wire [  0:0] aethe2srfp_axis_tuser ;

wire         srfp2apd_axis_tready;
wire         srfp2apd_axis_tvalid;
wire [ 15:0] srfp2apd_axis_tkeep ;
wire [127:0] srfp2apd_axis_tdata ;
wire         srfp2apd_axis_tlast ;
wire [  0:0] srfp2apd_axis_tuser ;
wire [  1:0] srfp2apd_axis_tdest ;

wire         apd2apm_axis_tready;
wire         apd2apm_axis_tvalid;
wire [ 15:0] apd2apm_axis_tkeep ;
wire [127:0] apd2apm_axis_tdata ;
wire         apd2apm_axis_tlast ;
wire [  0:0] apd2apm_axis_tuser ;

wire         apd2asre_axis_tready;
wire         apd2asre_axis_tvalid;
wire [ 15:0] apd2asre_axis_tkeep ;
wire [127:0] apd2asre_axis_tdata ;
wire         apd2asre_axis_tlast ;
wire [  0:0] apd2asre_axis_tuser ;

wire         asre2apm_axis_tready;
wire         asre2apm_axis_tvalid;
wire [ 15:0] asre2apm_axis_tkeep ;
wire [127:0] asre2apm_axis_tdata ;
wire         asre2apm_axis_tlast ;
wire [  0:0] asre2apm_axis_tuser ;

wire         apm2aethi_axis_tready;
wire         apm2aethi_axis_tvalid;
wire [ 15:0] apm2aethi_axis_tkeep ;
wire [127:0] apm2aethi_axis_tdata ;
wire         apm2aethi_axis_tlast ;
wire [  0:0] apm2aethi_axis_tuser ;
reg  [ 10:0] cur_apm2aethi_axis_len,nxt_apm2aethi_axis_len;

wire         apm2aethi_axis_sop;
wire [  7:0] apm2aethi_axis_line_id;
wire         apm2aethi_axis_eop;

wire            aethi_insert_tready;
reg             aethi_insert_tvalid;
reg  [14*8-1:0] aethi_insert_tdata ;

/*-----------------------------------------------------------------------
                    处理字段采集
-----------------------------------------------------------------------*/
AXISByteExtract#(
    .EXTRACT_LEN(14),
    .EXTRACT_SITE(ETH_SITE),
    .DATA_BYTE  (16),
    .USER_BIT   (1)
)
AXISEthExtract_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//提取数据
    .m_extract_tready(1'b1),
    .m_extract_tvalid(),
    .m_extract_tdata (),
//报文分组数据接收接口
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),  
//分组数据输出接口
    .m_axis_tready(aethe2srfp_axis_tready),
    .m_axis_tvalid(aethe2srfp_axis_tvalid),
    .m_axis_tkeep (aethe2srfp_axis_tkeep ),
    .m_axis_tdata (aethe2srfp_axis_tdata ),
    .m_axis_tlast (aethe2srfp_axis_tlast ),
    .m_axis_tuser (aethe2srfp_axis_tuser )
);

SRv6FwdProc SRv6FwdProc_Inst(  
    .axis_clk             (axis_clk  ),
    .axis_rst_n           (axis_rst_n),
    
    .s_axis_tready        (aethe2srfp_axis_tready),
    .s_axis_tvalid        (aethe2srfp_axis_tvalid),
    .s_axis_tkeep         (aethe2srfp_axis_tkeep ),
    .s_axis_tdata         (aethe2srfp_axis_tdata ),
    .s_axis_tlast         (aethe2srfp_axis_tlast ),
    .s_axis_tuser         (aethe2srfp_axis_tuser ),
                          
    .m_axis_tready        (srfp2apd_axis_tready),
    .m_axis_tvalid        (srfp2apd_axis_tvalid),
    .m_axis_tkeep         (srfp2apd_axis_tkeep ),
    .m_axis_tdata         (srfp2apd_axis_tdata ),
    .m_axis_tlast         (srfp2apd_axis_tlast ),
    .m_axis_tuser         (srfp2apd_axis_tuser ),
    .m_axis_tdest         (srfp2apd_axis_tdest )
);

AXISDisp#(
    .STREAM_SUM             (2),
    .DATA_BYTE              (16),
    .USER_BIT               (1)
)
AXISDisp_Inst(  
    .s_axis_clk             (axis_clk  ),
    .s_axis_rst_n           (axis_rst_n),
    
    .s_axis_tready          (srfp2apd_axis_tready),
    .s_axis_tvalid          (srfp2apd_axis_tvalid),
    .s_axis_tkeep           (srfp2apd_axis_tkeep ),
    .s_axis_tdata           (srfp2apd_axis_tdata ),
    .s_axis_tlast           (srfp2apd_axis_tlast ),
    .s_axis_tuser           (srfp2apd_axis_tuser ),
    .s_axis_tdst            (srfp2apd_axis_tdest ),
    
    .m_axis_tready          ({apd2apm_axis_tready,apd2asre_axis_tready}),
    .m_axis_tvalid          ({apd2apm_axis_tvalid,apd2asre_axis_tvalid}),
    .m_axis_tkeep           ({apd2apm_axis_tkeep ,apd2asre_axis_tkeep }),
    .m_axis_tdata           ({apd2apm_axis_tdata ,apd2asre_axis_tdata }),
    .m_axis_tlast           ({apd2apm_axis_tlast ,apd2asre_axis_tlast }),
    .m_axis_tuser           ({apd2apm_axis_tuser ,apd2asre_axis_tuser })
);

AXISByteExtract#(
    .EXTRACT_LEN(8),
    .EXTRACT_SITE(56),
    .DATA_BYTE  (16),
    .USER_BIT   (1)
)
AXISSRv6Extract_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//提取数据
    .m_extract_tready(1'b1),
    .m_extract_tvalid(),
    .m_extract_tdata (),
//报文分组数据接收接口
    .s_axis_tready(apd2asre_axis_tready),
    .s_axis_tvalid(apd2asre_axis_tvalid),
    .s_axis_tkeep (apd2asre_axis_tkeep ),
    .s_axis_tdata (apd2asre_axis_tdata ),
    .s_axis_tlast (apd2asre_axis_tlast ),
    .s_axis_tuser (apd2asre_axis_tuser ),  
//分组数据输出接口
    .m_axis_tready(asre2apm_axis_tready),
    .m_axis_tvalid(asre2apm_axis_tvalid),
    .m_axis_tkeep (asre2apm_axis_tkeep ),
    .m_axis_tdata (asre2apm_axis_tdata ),
    .m_axis_tlast (asre2apm_axis_tlast ),
    .m_axis_tuser (asre2apm_axis_tuser )
);

AXISMux#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (2),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (1),//缓存FIFO的容量的指数位宽
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
    .iv_fix_prior (2'b0),
//报文分组数据接收接口
    .s_axis_tready({apd2apm_axis_tready,asre2apm_axis_tready}),
    .s_axis_tvalid({apd2apm_axis_tvalid,asre2apm_axis_tvalid}),
    .s_axis_tkeep ({apd2apm_axis_tkeep ,asre2apm_axis_tkeep }),
    .s_axis_tdata ({apd2apm_axis_tdata ,asre2apm_axis_tdata }),
    .s_axis_tlast ({apd2apm_axis_tlast ,asre2apm_axis_tlast }),
    .s_axis_tuser ({apd2apm_axis_tuser ,asre2apm_axis_tuser }),
//报文分组数据输出接口
    .m_axis_tready(apm2aethi_axis_tready & aethi_insert_tready),
    .m_axis_tvalid(apm2aethi_axis_tvalid),
    .m_axis_tkeep (apm2aethi_axis_tkeep ),
    .m_axis_tdata (apm2aethi_axis_tdata ),
    .m_axis_tlast (apm2aethi_axis_tlast ),
    .m_axis_tuser (apm2aethi_axis_tuser )
);

always @(*) begin
    aethi_insert_tvalid = apm2aethi_axis_sop;
    aethi_insert_tdata  = {iv_dmac_addr + apm2aethi_axis_tdata[119:112],
                           iv_smac_addr,
                           16'h86DD};
end
    
PktLineDet #(8) SaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( aethi_insert_tready & apm2aethi_axis_tvalid & apm2aethi_axis_tready),
    .last                   ( apm2aethi_axis_tlast      ),
                            
    .sop                    ( apm2aethi_axis_sop        ),
    .line_id                ( apm2aethi_axis_line_id    ),
    .eop                    ( apm2aethi_axis_eop        )
);

//提取MD中的长度字段
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)  cur_apm2aethi_axis_len <= {11{1'b0}};
    else                    cur_apm2aethi_axis_len <= nxt_apm2aethi_axis_len;
end 
always @(*) begin
    nxt_apm2aethi_axis_len = (apm2aethi_axis_sop == 1'b1) ? 
                              apm2aethi_axis_tdata[111:101] : cur_apm2aethi_axis_len;
end

AXISByteInsert#(
    .INSERT_LEN (14),
    .INSERT_SITE(ETH_SITE),
    .DATA_BYTE  (16),
    .USER_BIT   (12)
)AXISEthInsert_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//插入数据
    .s_insert_tready(aethi_insert_tready),
    .s_insert_tvalid(aethi_insert_tvalid),
    .s_insert_tdata (aethi_insert_tdata ),
//报文分组数据接收接口
    .s_axis_tready(apm2aethi_axis_tready),
    .s_axis_tvalid(aethi_insert_tready & apm2aethi_axis_tvalid),
    .s_axis_tkeep (apm2aethi_axis_tkeep ),
    .s_axis_tdata (apm2aethi_axis_tdata ),
    .s_axis_tlast (apm2aethi_axis_tlast ),
    .s_axis_tuser ({apm2aethi_axis_tuser,cur_apm2aethi_axis_len}),  
//分组数据输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser )
);
endmodule
/*
SRv6FwdEngine SRv6FwdEngine_Inst(  
    .axis_clk             (),
    .axis_rst_n           (),
    
    .s_axis_tready        (),
    .s_axis_tvalid        (),
    .s_axis_tkeep         (),
    .s_axis_tdata         (),
    .s_axis_tlast         (),
    .s_axis_tuser         (),
                          
    .m_axis_tready        (),
    .m_axis_tvalid        (),
    .m_axis_tkeep         (),
    .m_axis_tdata         (),
    .m_axis_tlast         (),
    .m_axis_tuser         (),
    
    .iv_smac_addr         (),
    .iv_dmac_addr         ()
);
*/