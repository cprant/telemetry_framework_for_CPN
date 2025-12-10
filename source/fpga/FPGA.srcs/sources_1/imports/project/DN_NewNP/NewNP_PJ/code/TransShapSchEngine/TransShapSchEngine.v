/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  TransShapSchEngine.v
Target Device All
Dscription 
(1)	每个输出接口设置一个独立的整形调度引擎
(2)	根据IPv6目的地址对输入分组分类和处理
    1)	目的IPv6地址的[63:60]=4'b1000(FUNC=0x8xxxx)的分组作为RC分组进行整形调度
    2)	其他分组作为BE类型直通输出
(3)	实现令牌桶机制，根据RC流IPv6中的Flow Lable标识作为流ID，支持RC流单流测速
    1)	且IPv6目的地址的FUNC包含入口遥测指令
(4)	实现基于信用的整形机制CBS


Data_Struct: 
    2) 表项
        [357:352] 命中动作action
        [351:176] 掩码mask
        [175:112] 源ipv6高64位,
        [111: 48] 目的ipv6高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)
        [ 47: 32] IPv6+SRv6 Next_Header
            8 ipv6_nh
            8 srv6_nh
        [ 31: 16] 源端口
        [ 15:  0] 目的端口
    2)s_cfg_cmd
        0:读表项  
        1:写表项  
        2:自学习 
        3:清除
        
    3)s_cfg_resp
        [17:16]:Stat状态
            0:none
            1:正常
            2:错误
            3:保留
        [15:0]:index

Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module TransShapSchEngine#(
    parameter   PORT_SUM = 4
)
(
//时钟复位信号
    input  wire                    axis_clk,
    input  wire                    axis_rst_n,
//分组数据输入接口
    output wire                    s_axis_tready,
    input  wire                    s_axis_tvalid,
    input  wire [            15:0] s_axis_tkeep ,
    input  wire [           127:0] s_axis_tdata ,
    input  wire                    s_axis_tlast ,
    input  wire [             0:0] s_axis_tuser ,
//分组数据输出接口
    input  wire [  1*PORT_SUM-1:0] m_axis_tready,
    output wire [  1*PORT_SUM-1:0] m_axis_tvalid,
    output wire [ 16*PORT_SUM-1:0] m_axis_tkeep ,
    output wire [128*PORT_SUM-1:0] m_axis_tdata ,
    output wire [  1*PORT_SUM-1:0] m_axis_tlast ,
    output wire [  1*PORT_SUM-1:0] m_axis_tuser ,
//配置管理接口   
    input  wire                    s_lb_cs_n ,
    output reg                     s_lb_ack_n,
    input  wire                    s_lb_wr_rd,
    input  wire [            31:0] s_lb_addr ,
    input  wire [            31:0] s_lb_wdata,
    output reg  [            31:0] s_lb_rdata
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire                     rcpc2fm_axis_tready;
wire                     rcpc2fm_axis_tvalid;
wire [             15:0] rcpc2fm_axis_tkeep ;
wire [            127:0] rcpc2fm_axis_tdata ;
wire                     rcpc2fm_axis_tlast ;
wire [              0:0] rcpc2fm_axis_tuser ;

wire                     rcpc2beacf_axis_tready;
wire                     rcpc2beacf_axis_tvalid;
wire [             15:0] rcpc2beacf_axis_tkeep ;
wire [            127:0] rcpc2beacf_axis_tdata ;
wire                     rcpc2beacf_axis_tlast ;
wire [              0:0] rcpc2beacf_axis_tuser ;

wire                     fm2rcacf_axis_tready;
wire                     fm2rcacf_axis_tvalid;
wire [             15:0] fm2rcacf_axis_tkeep ;
wire [            127:0] fm2rcacf_axis_tdata ;
wire                     fm2rcacf_axis_tlast ;
wire [              0:0] fm2rcacf_axis_tuser ;

wire                     rcacf2cbssa_axis_tready;
wire                     rcacf2cbssa_axis_tvalid;
wire [             15:0] rcacf2cbssa_axis_tkeep ;
wire [            127:0] rcacf2cbssa_axis_tdata ;
wire                     rcacf2cbssa_axis_tlast ;
wire [              0:0] rcacf2cbssa_axis_tuser ;

wire [             31:0] rcacf_free_space;

(*mark_debug="true"*)wire                     beacf2apm_axis_tready;
(*mark_debug="true"*)wire                     beacf2apm_axis_tvalid;
(*mark_debug="true"*)wire [             15:0] beacf2apm_axis_tkeep ;
(*mark_debug="true"*)wire [            127:0] beacf2apm_axis_tdata ;
(*mark_debug="true"*)wire                     beacf2apm_axis_tlast ;
(*mark_debug="true"*)wire [              0:0] beacf2apm_axis_tuser ;

wire [             31:0] beacf_free_space;

(*mark_debug="true"*)wire                     cbssa2apm_axis_tready;
(*mark_debug="true"*)wire                     cbssa2apm_axis_tvalid;
(*mark_debug="true"*)wire [             15:0] cbssa2apm_axis_tkeep ;
(*mark_debug="true"*)wire [            127:0] cbssa2apm_axis_tdata ;
(*mark_debug="true"*)wire                     cbssa2apm_axis_tlast ;
(*mark_debug="true"*)wire [              0:0] cbssa2apm_axis_tuser ;


wire                     apm2disp_axis_tready;
wire                     apm2disp_axis_tvalid;
wire [             15:0] apm2disp_axis_tkeep ;
wire [            127:0] apm2disp_axis_tdata ;
wire                     apm2disp_axis_tlast ;
wire [              0:0] apm2disp_axis_tuser ;

reg                     fm_lb_cs_n ;
wire                    fm_lb_ack_n;
reg                     fm_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] fm_lb_addr ;
reg  [            31:0] fm_lb_wdata;
wire [            31:0] fm_lb_rdata;

reg                     cbs_lb_cs_n ;
reg                     cbs_lb_ack_n;
reg                     cbs_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] cbs_lb_addr ;
reg  [            31:0] cbs_lb_wdata;
reg  [            31:0] cbs_lb_rdata;

reg                     cbs_lb_cs_n_reg ;
wire                    cbs_lb_ack_n_reg;
reg                     cbs_lb_wr_rd_reg;//0:wr  1:rd
reg  [            31:0] cbs_lb_addr_reg ;
reg  [            31:0] cbs_lb_wdata_reg;
wire [            31:0] cbs_lb_rdata_reg;

wire                     disp_axis_sop;
wire [              7:0] disp_axis_line_id;
wire                     disp_axis_eop;

reg  [     PORT_SUM-1:0] disp_axis_tdest;
reg  [     PORT_SUM-1:0] disp_axis_tdest_reg;
/*----------------------------------------------------------
                        配置地址分区
----------------------------------------------------------*/
reg [31:0] cur_lb_addr_reg,nxt_lb_addr_reg;

//锁存输入的localbus地址，以免wv_s_lb_addr释放后地址也被清零，导致ack_n选择出错
always @(*) nxt_lb_addr_reg = (s_lb_cs_n == 1'b0) ? s_lb_addr : cur_lb_addr_reg;
always @(posedge axis_clk) cur_lb_addr_reg <= nxt_lb_addr_reg; 

always @* begin
    fm_lb_wr_rd = s_lb_wr_rd;
    fm_lb_addr  = s_lb_addr ;
    fm_lb_wdata = s_lb_wdata;
    
    cbs_lb_wr_rd = s_lb_wr_rd;
    cbs_lb_addr  = s_lb_addr ;
    cbs_lb_wdata = s_lb_wdata;
    
    case(nxt_lb_addr_reg[27:24])
        4'd0: begin//FlowMeter配置
            fm_lb_cs_n  = s_lb_cs_n ;
            cbs_lb_cs_n = 1'b1      ; 
            
            s_lb_ack_n = fm_lb_ack_n;
            s_lb_rdata = fm_lb_rdata;
        end
        
        4'd1: begin//CBS配置
            fm_lb_cs_n  = 1'b1     ;
            cbs_lb_cs_n = s_lb_cs_n; 
            
            s_lb_ack_n = cbs_lb_ack_n;
            s_lb_rdata = cbs_lb_rdata;
        end
        
        default: begin
            fm_lb_cs_n = 1'b1;
            cbs_lb_cs_n = 1'b1; 
            
            s_lb_ack_n = s_lb_cs_n  ;
            s_lb_rdata = s_lb_wdata;
        end
    endcase
end


always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)begin
        
        cbs_lb_cs_n_reg    <= 1'b1;
        cbs_lb_wr_rd_reg   <= 1'b0;
        cbs_lb_addr_reg    <= 32'd0;
        cbs_lb_wdata_reg   <= 32'd0;
        
    end
    else begin
        cbs_lb_cs_n_reg    <= cbs_lb_cs_n;  
        cbs_lb_ack_n       <= cbs_lb_ack_n_reg; 
        cbs_lb_wr_rd_reg   <= cbs_lb_wr_rd; 
        cbs_lb_addr_reg    <= cbs_lb_addr ;
        cbs_lb_wdata_reg   <= cbs_lb_wdata;
        cbs_lb_rdata       <= cbs_lb_rdata_reg;
       
    end

end

/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
RCPktClassify RCPktClassify_Inst(
//时钟复位信号
    .axis_clk        (axis_clk  ),
    .axis_rst_n      (axis_rst_n),
//分组数据输入接口
    .s_axis_tready   (s_axis_tready),
    .s_axis_tvalid   (s_axis_tvalid),
    .s_axis_tkeep    (s_axis_tkeep ),
    .s_axis_tdata    (s_axis_tdata ),
    .s_axis_tlast    (s_axis_tlast ),
    .s_axis_tuser    (s_axis_tuser ),
//分组数据输出接口
    .m_be_axis_tready(rcpc2beacf_axis_tready),
    .m_be_axis_tvalid(rcpc2beacf_axis_tvalid),
    .m_be_axis_tkeep (rcpc2beacf_axis_tkeep ),
    .m_be_axis_tdata (rcpc2beacf_axis_tdata ),
    .m_be_axis_tlast (rcpc2beacf_axis_tlast ),
    .m_be_axis_tuser (rcpc2beacf_axis_tuser ),  
                     
    .m_rc_axis_tready(rcpc2fm_axis_tready),
    .m_rc_axis_tvalid(rcpc2fm_axis_tvalid),
    .m_rc_axis_tkeep (rcpc2fm_axis_tkeep ),
    .m_rc_axis_tdata (rcpc2fm_axis_tdata ),
    .m_rc_axis_tlast (rcpc2fm_axis_tlast ),
    .m_rc_axis_tuser (rcpc2fm_axis_tuser )
);

AXISFifoBuf#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH (10),//缓存FIFO的容量的指数位宽
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (16),
    .USER_BIT   (1),
    .MIN_PKTLINE(4)
)BEAXISFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk   (axis_clk   ),
    .s_axis_rst_n (axis_rst_n ),
    .m_axis_clk   (axis_clk   ),
    .m_axis_rst_n (axis_rst_n ),
//AXI Stream输入接口
    .s_axis_tready(rcpc2beacf_axis_tready),
    .s_axis_tvalid(rcpc2beacf_axis_tvalid),
    .s_axis_tkeep (rcpc2beacf_axis_tkeep ),
    .s_axis_tdata (rcpc2beacf_axis_tdata ),
    .s_axis_tlast (rcpc2beacf_axis_tlast ),
    .s_axis_tuser (rcpc2beacf_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(beacf2apm_axis_tready),
    .m_axis_tvalid(beacf2apm_axis_tvalid),
    .m_axis_tkeep (beacf2apm_axis_tkeep ),
    .m_axis_tdata (beacf2apm_axis_tdata ),
    .m_axis_tlast (beacf2apm_axis_tlast ),
    .m_axis_tuser (beacf2apm_axis_tuser ),
//状态信号                               
    .free_space   (beacf_free_space      ),
    .used_space   (                    )
);

FlowMeter FlowMeter_Inst(
//时钟复位信号
    .axis_clk        (axis_clk  ),
    .axis_rst_n      (axis_rst_n),
//分组数据输入接口
    .s_axis_tready(rcpc2fm_axis_tready),
    .s_axis_tvalid(rcpc2fm_axis_tvalid),
    .s_axis_tkeep (rcpc2fm_axis_tkeep ),
    .s_axis_tdata (rcpc2fm_axis_tdata ),
    .s_axis_tlast (rcpc2fm_axis_tlast ),
    .s_axis_tuser (rcpc2fm_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(fm2rcacf_axis_tready),
    .m_axis_tvalid(fm2rcacf_axis_tvalid),
    .m_axis_tkeep (fm2rcacf_axis_tkeep ),
    .m_axis_tdata (fm2rcacf_axis_tdata ),
    .m_axis_tlast (fm2rcacf_axis_tlast ),
    .m_axis_tuser (fm2rcacf_axis_tuser ),  
//配置管理接口         
    .s_lb_cs_n    (fm_lb_cs_n ),
    .s_lb_ack_n   (fm_lb_ack_n),
    .s_lb_wr_rd   (fm_lb_wr_rd),
    .s_lb_addr    (fm_lb_addr ),
    .s_lb_wdata   (fm_lb_wdata),
    .s_lb_rdata   (fm_lb_rdata)
);

AXISFifoBuf#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH (10),//缓存FIFO的容量的指数位宽
    .PKT_MODE   (0),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (16),
    .USER_BIT   (1),
    .MIN_PKTLINE(4)
)RCAXISFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk   (axis_clk   ),
    .s_axis_rst_n (axis_rst_n ),
    .m_axis_clk   (axis_clk   ),
    .m_axis_rst_n (axis_rst_n ),
//AXI Stream输入接口
    .s_axis_tready(fm2rcacf_axis_tready),
    .s_axis_tvalid(fm2rcacf_axis_tvalid),
    .s_axis_tkeep (fm2rcacf_axis_tkeep ),
    .s_axis_tdata (fm2rcacf_axis_tdata ),
    .s_axis_tlast (fm2rcacf_axis_tlast ),
    .s_axis_tuser (fm2rcacf_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(rcacf2cbssa_axis_tready),
    .m_axis_tvalid(rcacf2cbssa_axis_tvalid),
    .m_axis_tkeep (rcacf2cbssa_axis_tkeep ),
    .m_axis_tdata (rcacf2cbssa_axis_tdata ),
    .m_axis_tlast (rcacf2cbssa_axis_tlast ),
    .m_axis_tuser (rcacf2cbssa_axis_tuser ),
//状态信号                               
    .free_space   (rcacf_free_space      ),
    .used_space   (                    )
);

CBSShapAlg#(
    .PORT_SUM(PORT_SUM)
)
CBSShapAlg_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//分组数据输入接口
    .s_axis_tready(rcacf2cbssa_axis_tready),
    .s_axis_tvalid(rcacf2cbssa_axis_tvalid),
    .s_axis_tkeep (rcacf2cbssa_axis_tkeep ),
    .s_axis_tdata (rcacf2cbssa_axis_tdata ),
    .s_axis_tlast (rcacf2cbssa_axis_tlast ),
    .s_axis_tuser (rcacf2cbssa_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(cbssa2apm_axis_tready),
    .m_axis_tvalid(cbssa2apm_axis_tvalid),
    .m_axis_tkeep (cbssa2apm_axis_tkeep ),
    .m_axis_tdata (cbssa2apm_axis_tdata ),
    .m_axis_tlast (cbssa2apm_axis_tlast ),
    .m_axis_tuser (cbssa2apm_axis_tuser ),
//配置管理接口         
    .s_lb_cs_n    (cbs_lb_cs_n_reg ),
    .s_lb_ack_n   (cbs_lb_ack_n_reg),
    .s_lb_wr_rd   (cbs_lb_wr_rd_reg),
    .s_lb_addr    (cbs_lb_addr_reg ),
    .s_lb_wdata   (cbs_lb_wdata_reg),
    .s_lb_rdata   (cbs_lb_rdata_reg)
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
    .iv_fix_prior (2'b10),
//报文分组数据接收接口
    .s_axis_tready({cbssa2apm_axis_tready,beacf2apm_axis_tready}),
    .s_axis_tvalid({cbssa2apm_axis_tvalid,beacf2apm_axis_tvalid}),
    .s_axis_tkeep ({cbssa2apm_axis_tkeep ,beacf2apm_axis_tkeep }),
    .s_axis_tdata ({cbssa2apm_axis_tdata ,beacf2apm_axis_tdata }),
    .s_axis_tlast ({cbssa2apm_axis_tlast ,beacf2apm_axis_tlast }),
    .s_axis_tuser ({cbssa2apm_axis_tuser ,beacf2apm_axis_tuser }),
//报文分组数据输出接口
    .m_axis_tready(apm2disp_axis_tready),
    .m_axis_tvalid(apm2disp_axis_tvalid),
    .m_axis_tkeep (apm2disp_axis_tkeep ),
    .m_axis_tdata (apm2disp_axis_tdata ),
    .m_axis_tlast (apm2disp_axis_tlast ),
    .m_axis_tuser (apm2disp_axis_tuser )
);


//提取输出端口并转为onehot编码以进行报文分派
PktLineDet #(8) DispaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( apm2disp_axis_tready & apm2disp_axis_tvalid),
    .last                   ( apm2disp_axis_tlast      ),
                            
    .sop                    ( disp_axis_sop        ),
    .line_id                ( disp_axis_line_id    ),
    .eop                    ( disp_axis_eop        )
);

wire [PORT_SUM-1:0] outport_onehot;
binary2onehot #(
    .WIDTH      (8))
index2entsel_inst(
    //ports
    .i_bin          ( apm2disp_axis_tdata[119:112]),
    .o_onehot       ( outport_onehot )
);

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        disp_axis_tdest_reg   <= {PORT_SUM{1'b0}};
    end
    else begin
        disp_axis_tdest_reg   <= disp_axis_tdest;
    end
end

always @(*) begin
    if(disp_axis_sop == 1'b1)
        disp_axis_tdest = outport_onehot[PORT_SUM-1:0];
    else
        disp_axis_tdest  = disp_axis_tdest_reg;
end
AXISDisp#(
    .STREAM_SUM             ( PORT_SUM           ),
    .DATA_BYTE              ( 16                 ),
    .USER_BIT               ( 1                  )
)
RCAXISD_inst(              
    .s_axis_clk             (  axis_clk           ),
    .s_axis_rst_n           (  axis_rst_n         ),
                            
    .s_axis_tready          ( apm2disp_axis_tready    ),
    .s_axis_tvalid          ( apm2disp_axis_tvalid    ),
    .s_axis_tkeep           ( apm2disp_axis_tkeep     ),
    .s_axis_tdata           ( apm2disp_axis_tdata     ),
    .s_axis_tlast           ( apm2disp_axis_tlast     ),
    .s_axis_tuser           ( apm2disp_axis_tuser     ),
    .s_axis_tdst            ( disp_axis_tdest         ),
                            
    .m_axis_tready          ( m_axis_tready    ),
    .m_axis_tvalid          ( m_axis_tvalid    ),
    .m_axis_tkeep           ( m_axis_tkeep     ),
    .m_axis_tdata           ( m_axis_tdata     ),
    .m_axis_tlast           ( m_axis_tlast     ),
    .m_axis_tuser           ( m_axis_tuser     )
);
endmodule
/*
TransShapSchEngine#(
    .PORT_SUM()
)
TransShapSchEngine_Inst(
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
    .s_lb_cs_n (),
    .s_lb_ack_n(),
    .s_lb_wr_rd(),
    .s_lb_addr (),
    .s_lb_wdata(),
    .s_lb_rdata()
);
*/