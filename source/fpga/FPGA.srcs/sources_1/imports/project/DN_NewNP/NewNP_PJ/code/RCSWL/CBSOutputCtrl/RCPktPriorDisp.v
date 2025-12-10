/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  RCPktPriorDisp.v
Target Device All
Dscription 
    1)根据分组MD中的优先级字段将RC分组区分为高低优先级

Data_Struct:
    1)Metadata    
        [127:120]   输入端口号       8   输入端口号
        [119: 88]   输出端口号       32  输出端口号
        [ 87: 77]   报文长度         11  报文的长度，不包含Metadata长度
        [ 76: 73]   帧类型           4   根据分组的C-TAG或以太网类型字段区分的帧类型
            0:ST帧
            1:RC帧
            2:BE帧
            3:PTP帧
            4:TSMP帧
            5:PCF帧
        [ 72: 69]   帧优先级         4   不同类型分组的优先级，与帧类型字段配合使用
        [ 68: 48]   保留             21  保留
        [ 47: 32]   时间槽           16  报文的接收时间槽，用于ST流进行注入控制
        [ 31:  0]   接收时间戳       32  报文的接收时间戳,用于透明时钟域计算，只需要32bit即可满足计算要求，单位8ns
Caution: 
    1)
Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module RCPktPriorDisp#(
    parameter   DATA_BYTE    = 16,
                PORT_SUM     = 32
)(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //RC分组数据输入接口
    output wire                     s_axis_tready,
    input  wire                     s_axis_tvalid,
    input  wire [    DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [  DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                     s_axis_tlast,
    input  wire [              0:0] s_axis_tuser, 
    //高优先级RC分组数据输出接口
    input  wire                     hrc_axis_tready,
    output wire                     hrc_axis_tvalid,
    output wire [    DATA_BYTE-1:0] hrc_axis_tkeep,
    output wire [  DATA_BYTE*8-1:0] hrc_axis_tdata,
    output wire                     hrc_axis_tlast,
    output wire [              0:0] hrc_axis_tuser,
    //高优先级RC分组数据输出接口
    input  wire                     lrc_axis_tready,
    output wire                     lrc_axis_tvalid,
    output wire [    DATA_BYTE-1:0] lrc_axis_tkeep,
    output wire [  DATA_BYTE*8-1:0] lrc_axis_tdata,
    output wire                     lrc_axis_tlast,
    output wire [              0:0] lrc_axis_tuser
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire                     s_axis_sop;
wire [              7:0] s_axis_line_id;
wire                     s_axis_eop;
                    
reg  [              1:0] cur_pkt_prior;
wire [              1:0] nxt_pkt_prior;

wire                     int_axis_tready;
wire                     int_axis_tvalid;
wire [    DATA_BYTE-1:0] int_axis_tkeep ;
wire [  DATA_BYTE*8-1:0] int_axis_tdata ;
wire                     int_axis_tlast ;
wire [              2:0] int_axis_tuser ;

wire                     ext_axis_tready;
wire                     ext_axis_tvalid;
wire [    DATA_BYTE-1:0] ext_axis_tkeep ;
wire [  DATA_BYTE*8-1:0] ext_axis_tdata ;
wire                     ext_axis_tlast ;
wire [              2:0] ext_axis_tuser ;
/*---------------------------------------------------------
                   分组优先级识别
---------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) cur_pkt_prior <= 2'd0;
    else                   cur_pkt_prior <= nxt_pkt_prior;
end

assign nxt_pkt_prior = (s_axis_sop == 1'd1) ? 
                       ((s_axis_tdata[69] == 1'd0) ? 2'b01: 2'b10) : cur_pkt_prior;

/*---------------------------------------------------------
                   分组输入缓存
---------------------------------------------------------*/

assign s_axis_tready   = int_axis_tready;
assign int_axis_tvalid = s_axis_tvalid;
assign int_axis_tkeep  = s_axis_tkeep;
assign int_axis_tdata  = s_axis_tdata;
assign int_axis_tlast  = s_axis_tlast;
assign int_axis_tuser  = {s_axis_tuser,nxt_pkt_prior};

/*---------------------------------------------------------
                   分组分派
---------------------------------------------------------*/
assign ext_axis_tready  = ({hrc_axis_tready,lrc_axis_tready} & ext_axis_tuser[1:0]) == ext_axis_tuser[1:0];

assign lrc_axis_tvalid  = ext_axis_tvalid & ext_axis_tuser[0];
assign lrc_axis_tkeep   = ext_axis_tkeep;
assign lrc_axis_tdata   = ext_axis_tdata;
assign lrc_axis_tlast   = ext_axis_tlast;
assign lrc_axis_tuser   = ext_axis_tuser[2];

assign hrc_axis_tvalid  = ext_axis_tvalid & ext_axis_tuser[1];
assign hrc_axis_tkeep   = ext_axis_tkeep;
assign hrc_axis_tdata   = ext_axis_tdata;
assign hrc_axis_tlast   = ext_axis_tlast;
assign hrc_axis_tuser   = ext_axis_tuser[2];
                          
/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 

PktLineDet #(8) SaxisLineDet_Inst(
    .user_clk       ( axis_clk          ),
    .user_rst_n     ( axis_rst_n        ),
                      
    .valid          ( s_axis_tready & s_axis_tvalid),
    .last           ( s_axis_tlast      ),
                      
    .sop            ( s_axis_sop        ),
    .line_id        ( s_axis_line_id    ),
    .eop            ( s_axis_eop        )
);

AXISFifoBuf#(
    .ASYNC_EN       ( 0                 ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH     ( 5                 ),//缓存FIFO的容量的指数位宽
    .PKT_MODE       ( 0                 ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE      ( DATA_BYTE         ),
    .USER_BIT       ( 3                 )
)RCPktData_Inst(
//时钟复位信号
    .s_axis_clk     ( axis_clk          ),
    .s_axis_rst_n   ( axis_rst_n        ),
    .m_axis_clk     ( axis_clk          ),
    .m_axis_rst_n   ( axis_rst_n        ),
//AXI Stream输入接口  
    .s_axis_tready  ( int_axis_tready   ),
    .s_axis_tvalid  ( int_axis_tvalid   ),
    .s_axis_tkeep   ( int_axis_tkeep    ),
    .s_axis_tdata   ( int_axis_tdata    ),
    .s_axis_tlast   ( int_axis_tlast    ),
    .s_axis_tuser   ( int_axis_tuser    ),    
//AXI Stream输出接口        
    .m_axis_tready  ( ext_axis_tready   ),
    .m_axis_tvalid  ( ext_axis_tvalid   ),
    .m_axis_tkeep   ( ext_axis_tkeep    ),
    .m_axis_tdata   ( ext_axis_tdata    ),
    .m_axis_tlast   ( ext_axis_tlast    ),
    .m_axis_tuser   ( ext_axis_tuser    ),
                      
    .free_space     ( ),
    .used_space     ( )
);
endmodule

/*
RCPktPriorDisp#(
    .DATA_BYTE                  ( ),
    .PORT_SUM                   ( )
)RCPktPriorDisp_inst(
    .axis_clk                   ( ),
    .axis_rst_n                 ( ),

    .s_axis_tready              ( ),
    .s_axis_tvalid              ( ),
    .s_axis_tkeep               ( ),
    .s_axis_tdata               ( ),
    .s_axis_tlast               ( ),
    .s_axis_tuser               ( ),

    .hrc_axis_tready            ( ),
    .hrc_axis_tvalid            ( ),
    .hrc_axis_tkeep             ( ),
    .hrc_axis_tdata             ( ),
    .hrc_axis_tlast             ( ),
    .hrc_axis_tuser             ( ),

    .lrc_axis_tready            ( ),
    .lrc_axis_tvalid            ( ),
    .lrc_axis_tkeep             ( ),
    .lrc_axis_tdata             ( ),
    .lrc_axis_tlast             ( ),
    .lrc_axis_tuser             ( )
);
*/