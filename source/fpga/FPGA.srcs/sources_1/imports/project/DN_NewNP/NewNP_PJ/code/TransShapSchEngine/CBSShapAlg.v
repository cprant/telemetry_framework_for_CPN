/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CBSShapAlg.v
Target Device All
Dscription 
    1)实现基于信用的整形机制CBS
    2)对高低两个优先级队列进行调度输出

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

Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module CBSShapAlg#(
    parameter PORT_SUM = 8
)
(
//时钟复位信号
    input  wire                    axis_clk,
    input  wire                    axis_rst_n,
//分组数据输入接口
    output reg                     s_axis_tready,
    input  wire                    s_axis_tvalid,
    input  wire [            15:0] s_axis_tkeep ,
    input  wire [           127:0] s_axis_tdata ,
    input  wire                    s_axis_tlast ,
    input  wire [             0:0] s_axis_tuser ,
//分组数据输出接口
    input  wire                    m_axis_tready,
    output wire                    m_axis_tvalid,
    output wire [            15:0] m_axis_tkeep ,
    output wire [           127:0] m_axis_tdata ,
    output wire                    m_axis_tlast ,
    output wire [             0:0] m_axis_tuser ,
//配置管理接口         
    input  wire                    s_lb_cs_n ,
    output wire                    s_lb_ack_n,
    input  wire                    s_lb_wr_rd,
    input  wire [            31:0] s_lb_addr ,
    input  wire [            31:0] s_lb_wdata,
    output wire [            31:0] s_lb_rdata
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire                     s_axis_sop;
wire [              7:0] s_axis_line_id;
wire                     s_axis_eop;

wire [            255:0] outport_onehot;

wire                     disp_axis_tready;
reg                      disp_axis_tvalid;
reg  [             15:0] disp_axis_tkeep ;
reg  [            127:0] disp_axis_tdata ;
reg                      disp_axis_tlast ;
reg  [              0:0] disp_axis_tuser ;
reg  [     PORT_SUM-1:0] disp_axis_tdest ;
reg  [     PORT_SUM-1:0] disp_axis_tdest_reg ; 

wire                     wv_cbsoc_lb_cs_n ;
wire [   1*PORT_SUM-1:0] wv_cbsoc_lb_ack_n;
wire                     wv_cbsoc_lb_wr_rd;
wire [             31:0] wv_cbsoc_lb_addr ;
wire [             31:0] wv_cbsoc_lb_wdata;
wire [  32*PORT_SUM-1:0] wv_cbsoc_lb_rdata;

wire [     PORT_SUM-1:0] rcpd2cbsoc_axis_tready;
wire [     PORT_SUM-1:0] rcpd2cbsoc_axis_tvalid;
wire [  16*PORT_SUM-1:0] rcpd2cbsoc_axis_tkeep ;
wire [16*PORT_SUM*8-1:0] rcpd2cbsoc_axis_tdata ;
wire [     PORT_SUM-1:0] rcpd2cbsoc_axis_tlast ;
wire [     PORT_SUM-1:0] rcpd2cbsoc_axis_tuser ;

wire [     PORT_SUM-1:0] cbsoc2apm_axis_tready;
wire [     PORT_SUM-1:0] cbsoc2apm_axis_tvalid;
wire [  16*PORT_SUM-1:0] cbsoc2apm_axis_tkeep ;
wire [16*PORT_SUM*8-1:0] cbsoc2apm_axis_tdata ;
wire [     PORT_SUM-1:0] cbsoc2apm_axis_tlast ;
wire [     PORT_SUM-1:0] cbsoc2apm_axis_tuser ;
/*-----------------------------------------------------------------------
                    CBS控制接口分配
-----------------------------------------------------------------------*/
assign wv_cbsoc_lb_cs_n     = (wv_cbsoc_lb_addr[8:3] >= PORT_SUM) ? 1'd1 : s_lb_cs_n;
//避免配置的端口号要超过实际实例化的端口号数量
assign wv_cbsoc_lb_wr_rd    = s_lb_wr_rd;
assign wv_cbsoc_lb_addr     = s_lb_addr;
assign wv_cbsoc_lb_wdata    = s_lb_wdata;

assign s_lb_ack_n       = (s_lb_addr[8:3] >= PORT_SUM) ? s_lb_cs_n : wv_cbsoc_lb_ack_n[s_lb_addr[8:3]];
//避免配置的端口号要超过实际实例化的端口号数量

assign s_lb_rdata       = (s_lb_addr[8:3] >= PORT_SUM) ? s_lb_wdata : wv_cbsoc_lb_rdata[32*s_lb_addr[8:3] +: 32];

/*-----------------------------------------------------------------------
                    报文端口分类
-----------------------------------------------------------------------*/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        disp_axis_tdest_reg   <= {PORT_SUM{1'b0}};
    end
    else begin
        disp_axis_tdest_reg   <= disp_axis_tdest;
    end
end

always @(*) begin
    s_axis_tready   = disp_axis_tready;
    disp_axis_tvalid = s_axis_tvalid;
    disp_axis_tkeep  = s_axis_tkeep;
    disp_axis_tdata  = s_axis_tdata;
    disp_axis_tlast  = s_axis_tlast;
    disp_axis_tuser  = s_axis_tuser;
    if(s_axis_sop == 1'b1)
        disp_axis_tdest = outport_onehot[PORT_SUM-1:0];
    else
        disp_axis_tdest  = disp_axis_tdest_reg;
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

binary2onehot #(
    .WIDTH      (8))
index2entsel_inst(
    //ports
    .i_bin          ( s_axis_tdata[119:112]),
    .o_onehot       ( outport_onehot )
);

AXISDisp#(
    .STREAM_SUM             ( PORT_SUM           ),
    .DATA_BYTE              ( 16                 ),
    .USER_BIT               ( 1                  )
)
CBSAXISD_inst(              
    .s_axis_clk             (  axis_clk           ),
    .s_axis_rst_n           (  axis_rst_n         ),
                            
    .s_axis_tready          ( disp_axis_tready     ),
    .s_axis_tvalid          ( disp_axis_tvalid     ),
    .s_axis_tkeep           ( disp_axis_tkeep      ),
    .s_axis_tdata           ( disp_axis_tdata      ),
    .s_axis_tlast           ( disp_axis_tlast      ),
    .s_axis_tuser           ( disp_axis_tuser      ),
    .s_axis_tdst            ( disp_axis_tdest      ),
                            
    .m_axis_tready          ( rcpd2cbsoc_axis_tready    ),
    .m_axis_tvalid          ( rcpd2cbsoc_axis_tvalid    ),
    .m_axis_tkeep           ( rcpd2cbsoc_axis_tkeep     ),
    .m_axis_tdata           ( rcpd2cbsoc_axis_tdata     ),
    .m_axis_tlast           ( rcpd2cbsoc_axis_tlast     ),
    .m_axis_tuser           ( rcpd2cbsoc_axis_tuser     )
);


generate 
    genvar i;
    for(i=0;i<PORT_SUM;i=i+1) begin : CBSOutputCtrl
        CBSOutputCtrl #(
            .PORT_ID                ( i                     )
        )
        CBSOutputCtrl_inst(
            .axis_clk               ( axis_clk            ),
            .axis_rst_n             ( axis_rst_n          ),
       
            .s_axis_tready          ( rcpd2cbsoc_axis_tready[i*1   +:   1]),
            .s_axis_tvalid          ( rcpd2cbsoc_axis_tvalid[i*1   +:   1]),
            .s_axis_tkeep           ( rcpd2cbsoc_axis_tkeep [i*16  +:  16]),
            .s_axis_tdata           ( rcpd2cbsoc_axis_tdata [i*128 +: 128]),
            .s_axis_tlast           ( rcpd2cbsoc_axis_tlast [i*1   +:   1]),
            .s_axis_tuser           ( rcpd2cbsoc_axis_tuser [i*1   +:   1]),
        
            .m_axis_tready          ( cbsoc2apm_axis_tready[i*1   +:   1]),
            .m_axis_tvalid          ( cbsoc2apm_axis_tvalid[i*1   +:   1]),
            .m_axis_tkeep           ( cbsoc2apm_axis_tkeep [i*16  +:  16]),
            .m_axis_tdata           ( cbsoc2apm_axis_tdata [i*128 +: 128]),
            .m_axis_tlast           ( cbsoc2apm_axis_tlast [i*1   +:   1]),
            .m_axis_tuser           ( cbsoc2apm_axis_tuser [i*1   +:   1]),
        
            .s_lb_cs_n              ( wv_cbsoc_lb_cs_n      ),
            .s_lb_ack_n             ( wv_cbsoc_lb_ack_n[i*1  +:  1]),
            .s_lb_wr_rd             ( wv_cbsoc_lb_wr_rd     ),
            .s_lb_addr              ( wv_cbsoc_lb_addr      ),
            .s_lb_wdata             ( wv_cbsoc_lb_wdata     ),
            .s_lb_rdata             ( wv_cbsoc_lb_rdata[i*32 +: 32])
        );
    end
endgenerate

AXISMux#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (PORT_SUM),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (1),//缓存FIFO的容量的指数位宽
    .DATA_BYTE  (16),
    .USER_BIT   (1),
    .MIN_PKTLINE(5)
)
AXISMux_Inst(
//时钟复位信号
    .s_axis_clk   ({PORT_SUM{axis_clk  }}),
    .s_axis_rst_n ({PORT_SUM{axis_rst_n}}),
    .m_axis_clk   (axis_clk  ),
    .m_axis_rst_n (axis_rst_n),
//固定优先级接口
    .iv_fix_prior ({PORT_SUM{1'b0}}),
//报文分组数据接收接口
    .s_axis_tready(cbsoc2apm_axis_tready),
    .s_axis_tvalid(cbsoc2apm_axis_tvalid),
    .s_axis_tkeep (cbsoc2apm_axis_tkeep ),
    .s_axis_tdata (cbsoc2apm_axis_tdata ),
    .s_axis_tlast (cbsoc2apm_axis_tlast ),
    .s_axis_tuser (cbsoc2apm_axis_tuser ),
//报文分组数据输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser )
);
endmodule
/*
CBSShapAlg#(
    .PORT_SUM()
)
CBSShapAlg_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//分组数据输入接口
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