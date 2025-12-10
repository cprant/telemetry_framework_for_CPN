/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CBSOutputCtrl.v
Target Device All
Dscription 
    1)维护RTC寄存器
    2)根据RC分组MD数据中的优先级字段将分组分别写入高低两个优先级队列
    3)使用CBS整形器对高低两个优先级队列进行调度输出
    4)对每个队列的溢出情况进行记录，输出队列错误信号

Data_Struct:

Caution: 
    1)
Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CBSOutputCtrl#(
    parameter   DATA_BYTE    = 16,
                PORT_SUM     = 32,
                PORT_ID      = 0
)(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //RC分组数据输入接口
(*mark_debug="true"*)    output wire                     s_axis_tready,
(*mark_debug="true"*)    input  wire                     s_axis_tvalid,
(*mark_debug="true"*)    input  wire [    DATA_BYTE-1:0] s_axis_tkeep,
(*mark_debug="true"*)    input  wire [  DATA_BYTE*8-1:0] s_axis_tdata,
(*mark_debug="true"*)    input  wire                     s_axis_tlast,
(*mark_debug="true"*)    input  wire [              0:0] s_axis_tuser, 
    //RC分组数据输出接口
(*mark_debug="true"*)    input  wire                     m_axis_tready,
(*mark_debug="true"*)    output wire                     m_axis_tvalid,
(*mark_debug="true"*)    output wire [    DATA_BYTE-1:0] m_axis_tkeep,
(*mark_debug="true"*)    output wire [  DATA_BYTE*8-1:0] m_axis_tdata,
(*mark_debug="true"*)    output wire                     m_axis_tlast,
(*mark_debug="true"*)    output wire [              0:0] m_axis_tuser,
    //配置管理接口
(*mark_debug="true"*)    input  wire                     s_lb_cs_n,
(*mark_debug="true"*)    output wire                     s_lb_ack_n,
(*mark_debug="true"*)    input  wire                     s_lb_wr_rd,//0:wr  1:rd
(*mark_debug="true"*)    input  wire [             31:0] s_lb_addr,
(*mark_debug="true"*)    input  wire [             31:0] s_lb_wdata,
(*mark_debug="true"*)    output wire [             31:0] s_lb_rdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
(*mark_debug="true"*)wire                   int_hrc_axis_tready;
(*mark_debug="true"*)wire                   int_hrc_axis_tvalid;
(*mark_debug="true"*)wire [  DATA_BYTE-1:0] int_hrc_axis_tkeep ;
(*mark_debug="true"*)wire [DATA_BYTE*8-1:0] int_hrc_axis_tdata ;
(*mark_debug="true"*)wire                   int_hrc_axis_tlast ;
(*mark_debug="true"*)wire [            0:0] int_hrc_axis_tuser ;

(*mark_debug="true"*)wire                   int_lrc_axis_tready;
(*mark_debug="true"*)wire                   int_lrc_axis_tvalid;
(*mark_debug="true"*)wire [  DATA_BYTE-1:0] int_lrc_axis_tkeep ;
(*mark_debug="true"*)wire [DATA_BYTE*8-1:0] int_lrc_axis_tdata ;
(*mark_debug="true"*)wire                   int_lrc_axis_tlast ;
(*mark_debug="true"*)wire [            0:0] int_lrc_axis_tuser ;

(*mark_debug="true"*)wire                   ext_hrc_axis_tready;
(*mark_debug="true"*)wire                   ext_hrc_axis_tvalid;
(*mark_debug="true"*)wire [  DATA_BYTE-1:0] ext_hrc_axis_tkeep ;
(*mark_debug="true"*)wire [DATA_BYTE*8-1:0] ext_hrc_axis_tdata ;
(*mark_debug="true"*)wire                   ext_hrc_axis_tlast ;
(*mark_debug="true"*)wire [            0:0] ext_hrc_axis_tuser ;

(*mark_debug="true"*)wire                   ext_lrc_axis_tready;
(*mark_debug="true"*)wire                   ext_lrc_axis_tvalid;
(*mark_debug="true"*)wire [  DATA_BYTE-1:0] ext_lrc_axis_tkeep ;
(*mark_debug="true"*)wire [DATA_BYTE*8-1:0] ext_lrc_axis_tdata ;
(*mark_debug="true"*)wire                   ext_lrc_axis_tlast ;
(*mark_debug="true"*)wire [            0:0] ext_lrc_axis_tuser ;


(*mark_debug="true"*)wire [           31:0] hrc_idleslope_tick;
(*mark_debug="true"*)wire [           31:0] hrc_sendslope_tick;
(*mark_debug="true"*)wire [           31:0] hrc_hicredit      ;
(*mark_debug="true"*)wire [           31:0] hrc_locredit      ;
(*mark_debug="true"*)wire [           31:0] lrc_idleslope_tick;
(*mark_debug="true"*)wire [           31:0] lrc_sendslope_tick;
(*mark_debug="true"*)wire [           31:0] lrc_hicredit      ;
(*mark_debug="true"*)wire [           31:0] lrc_locredit      ;


(*mark_debug="true"*)wire [           31:0] Credit_H;
(*mark_debug="true"*)wire [           31:0] Credit_L;

(*mark_debug="true"*)wire [            1:0] Q_empty;
(*mark_debug="true"*)wire [            1:0] Q_Txing;

(*mark_debug="true"*)wire [            1:0] Tx_enable;




/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
RCPktPriorDisp#(
    .DATA_BYTE                  ( DATA_BYTE                 ),
    .PORT_SUM                   ( PORT_SUM                  )
)
RCPktPriorDisp_inst(   
    .axis_clk                   ( axis_clk                  ),
    .axis_rst_n                 ( axis_rst_n                ),

    .s_axis_tready              ( s_axis_tready             ),
    .s_axis_tvalid              ( s_axis_tvalid             ),
    .s_axis_tkeep               ( s_axis_tkeep              ),
    .s_axis_tdata               ( s_axis_tdata              ),
    .s_axis_tlast               ( s_axis_tlast              ),
    .s_axis_tuser               ( s_axis_tuser              ),

    .hrc_axis_tready            ( int_hrc_axis_tready       ),
    .hrc_axis_tvalid            ( int_hrc_axis_tvalid       ),
    .hrc_axis_tkeep             ( int_hrc_axis_tkeep        ),
    .hrc_axis_tdata             ( int_hrc_axis_tdata        ),
    .hrc_axis_tlast             ( int_hrc_axis_tlast        ),
    .hrc_axis_tuser             ( int_hrc_axis_tuser        ),
                                        
    .lrc_axis_tready            ( int_lrc_axis_tready       ),
    .lrc_axis_tvalid            ( int_lrc_axis_tvalid       ),
    .lrc_axis_tkeep             ( int_lrc_axis_tkeep        ),
    .lrc_axis_tdata             ( int_lrc_axis_tdata        ),
    .lrc_axis_tlast             ( int_lrc_axis_tlast        ),
    .lrc_axis_tuser             ( int_lrc_axis_tuser        )
);

AXISFifoBuf#(
    .ASYNC_EN                   ( 0                         ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH                 ( 5                         ),//缓存FIFO的容量的指数位宽
    .PKT_MODE                   ( 1                         ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE                  ( DATA_BYTE                 ),
    .USER_BIT                   ( 1                         )
)
HRCPkt_Inst(                   
//时钟复位信号                    
    .s_axis_clk                 ( axis_clk                  ),
    .s_axis_rst_n               ( axis_rst_n                ),
    .m_axis_clk                 ( axis_clk                  ),
    .m_axis_rst_n               ( axis_rst_n                ),
//AXI Stream输入接口              
    .s_axis_tready              ( int_hrc_axis_tready       ),
    .s_axis_tvalid              ( int_hrc_axis_tvalid       ),
    .s_axis_tkeep               ( int_hrc_axis_tkeep        ),
    .s_axis_tdata               ( int_hrc_axis_tdata        ),
    .s_axis_tlast               ( int_hrc_axis_tlast        ),
    .s_axis_tuser               ( int_hrc_axis_tuser        ),    
//AXI Stream输出接口                    
    .m_axis_tready              ( ext_hrc_axis_tready       ),
    .m_axis_tvalid              ( ext_hrc_axis_tvalid       ),
    .m_axis_tkeep               ( ext_hrc_axis_tkeep        ),
    .m_axis_tdata               ( ext_hrc_axis_tdata        ),
    .m_axis_tlast               ( ext_hrc_axis_tlast        ),
    .m_axis_tuser               ( ext_hrc_axis_tuser        ),
                                
    .free_space                 ( ),
    .used_space                 ( )
);

AXISFifoBuf#(
    .ASYNC_EN                   ( 0                         ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH                 ( 5                         ),//缓存FIFO的容量的指数位宽
    .PKT_MODE                   ( 1                         ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE                  ( DATA_BYTE                 ),
    .USER_BIT                   ( 1                         )
)
LRCPkt_Inst(                   
//时钟复位信号                    
    .s_axis_clk                 ( axis_clk                  ),
    .s_axis_rst_n               ( axis_rst_n                ),
    .m_axis_clk                 ( axis_clk                  ),
    .m_axis_rst_n               ( axis_rst_n                ),
//AXI Stream输入接口              
    .s_axis_tready              ( int_lrc_axis_tready       ),
    .s_axis_tvalid              ( int_lrc_axis_tvalid       ),
    .s_axis_tkeep               ( int_lrc_axis_tkeep        ),
    .s_axis_tdata               ( int_lrc_axis_tdata        ),
    .s_axis_tlast               ( int_lrc_axis_tlast        ),
    .s_axis_tuser               ( int_lrc_axis_tuser        ),    
//AXI Stream输出接口                    
    .m_axis_tready              ( ext_lrc_axis_tready       ),
    .m_axis_tvalid              ( ext_lrc_axis_tvalid       ),
    .m_axis_tkeep               ( ext_lrc_axis_tkeep        ),
    .m_axis_tdata               ( ext_lrc_axis_tdata        ),
    .m_axis_tlast               ( ext_lrc_axis_tlast        ),
    .m_axis_tuser               ( ext_lrc_axis_tuser        ),
                                
    .free_space                 ( ),
    .used_space                 ( )
);


CBSQueueCtrl#(
    .DATA_BYTE                  ( DATA_BYTE                 ),
    .PORT_SUM                   ( PORT_SUM                  )
)CBSQueueCtrl_inst(
    .axis_clk                   ( axis_clk                  ),
    .axis_rst_n                 ( axis_rst_n                ),

    .Q_empty                    (Q_empty),
    .Q_Txing                    (Q_Txing),
    .Tx_enable                  (Tx_enable),

    .hrc_axis_tready            ( ext_hrc_axis_tready       ),
    .hrc_axis_tvalid            ( ext_hrc_axis_tvalid       ),
    .hrc_axis_tkeep             ( ext_hrc_axis_tkeep        ),
    .hrc_axis_tdata             ( ext_hrc_axis_tdata        ),
    .hrc_axis_tlast             ( ext_hrc_axis_tlast        ),
    .hrc_axis_tuser             ( ext_hrc_axis_tuser        ),

    .lrc_axis_tready            ( ext_lrc_axis_tready       ),
    .lrc_axis_tvalid            ( ext_lrc_axis_tvalid       ),
    .lrc_axis_tkeep             ( ext_lrc_axis_tkeep        ),
    .lrc_axis_tdata             ( ext_lrc_axis_tdata        ),
    .lrc_axis_tlast             ( ext_lrc_axis_tlast        ),
    .lrc_axis_tuser             ( ext_lrc_axis_tuser        ),

    .m_axis_tready              ( m_axis_tready             ),
    .m_axis_tvalid              ( m_axis_tvalid             ),
    .m_axis_tkeep               ( m_axis_tkeep              ),
    .m_axis_tdata               ( m_axis_tdata              ),
    .m_axis_tlast               ( m_axis_tlast              ),
    .m_axis_tuser               ( m_axis_tuser              )
);

CBSSendCtrl CBSSendCtrl_inst(
    //时钟复位信号
    .axis_clk                   ( axis_clk                  ),
    .axis_rst_n                 ( axis_rst_n                ),
    //信用值
    .Credit_H                   (Credit_H),
    .Credit_L                   (Credit_L),
    //ready信号
    .m_axis_tready              (m_axis_tready),
    //队列状态
    .Q_empty                    (Q_empty),
    //输出控制
    .Tx_enable                  (Tx_enable)
);

CBSCfgMgmt# (
    .PORT_ID                ( PORT_ID                   )
)CBSCfgMgmt_inst(
    .user_clk               ( axis_clk                  ),
    .user_rst_n             ( axis_rst_n                ),

    .s_lb_cs_n              ( s_lb_cs_n                 ),
    .s_lb_ack_n             ( s_lb_ack_n                ),
    .s_lb_wr_rd             ( s_lb_wr_rd                ),
    .s_lb_addr              ( s_lb_addr                 ),
    .s_lb_wdata             ( s_lb_wdata                ),
    .s_lb_rdata             ( s_lb_rdata                ),

    .ov_hrc_idleslope_tick  ( hrc_idleslope_tick        ),
    .ov_hrc_sendslope_tick  ( hrc_sendslope_tick        ),
    .ov_hrc_hicredit        ( hrc_hicredit              ),
    .ov_hrc_locredit        ( hrc_locredit              ),
    .ov_lrc_idleslope_tick  ( lrc_idleslope_tick        ),
    .ov_lrc_sendslope_tick  ( lrc_sendslope_tick        ),
    .ov_lrc_hicredit        ( lrc_hicredit              ),
    .ov_lrc_locredit        ( lrc_locredit              )
);

CreditCal CreditCal_inst(
    .axis_clk               ( axis_clk                  ),
    .axis_rst_n             ( axis_rst_n                ),


    .iv_hrc_idleslope_tick  ( hrc_idleslope_tick        ),
    .iv_hrc_sendslope_tick  ( hrc_sendslope_tick        ),
    .iv_hrc_hicredit        ( hrc_hicredit              ),
    .iv_hrc_locredit        ( hrc_locredit              ),
    .iv_lrc_idleslope_tick  ( lrc_idleslope_tick        ),
    .iv_lrc_sendslope_tick  ( lrc_sendslope_tick        ),
    .iv_lrc_hicredit        ( lrc_hicredit              ),
    .iv_lrc_locredit        ( lrc_locredit              ),
    
    .Q_empty                ( Q_empty                   ),
    .Q_Txing                ( Q_Txing                   ),

    .Credit_H               ( Credit_H                  ),
    .Credit_L               ( Credit_L                  )
);

endmodule
/*
CBSOutputCtrl#(
    .DATA_BYTE                  ( ),
    .PORT_SUM                   ( )
)CBSOutputCtrl_inst(
    .axis_clk                   ( ),
    .axis_rst_n                 ( ),
                                  
    .s_axis_tready              ( ),
    .s_axis_tvalid              ( ),
    .s_axis_tkeep               ( ),
    .s_axis_tdata               ( ),
    .s_axis_tlast               ( ),
    .s_axis_tuser               ( ),
                                  
    .m_axis_tready              ( ),
    .m_axis_tvalid              ( ),
    .m_axis_tkeep               ( ),
    .m_axis_tdata               ( ),
    .m_axis_tlast               ( ),
    .m_axis_tuser               ( ),
                                  
    .s_lb_cs_n                  ( ),
    .s_lb_ack_n                 ( ),
    .s_lb_wr_rd                 ( ),
    .s_lb_addr                  ( ),
    .s_lb_wdata                 ( ),
    .s_lb_rdata                 ( )
);
*/