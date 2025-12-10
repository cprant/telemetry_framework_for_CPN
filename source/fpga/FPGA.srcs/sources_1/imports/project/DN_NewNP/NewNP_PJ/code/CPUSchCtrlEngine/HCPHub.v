/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  HCPHub.v
Target Device All
Dscription 
    1)

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
Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module HCPHub#(
    parameter Mbus_ID = 2
)
(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
    input  wire         hcp_clk,
    input  wire         hcp_rst_n,
//报文分组数据接收接口
    output wire         s_axis_tready,
    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep,
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tlast,
    input  wire         s_axis_tuser,
//报文分组数据输出接口
    input  wire         m_axis_tready,
    output reg          m_axis_tvalid,
    output reg  [ 15:0] m_axis_tkeep,
    output reg  [127:0] m_axis_tdata,
    output reg          m_axis_tlast,
    output reg          m_axis_tuser,
//配置管理接口         
    output wire         m_lb_cs_n ,
    input  wire         m_lb_ack_n,
    output wire         m_lb_wr_rd,
    output wire [ 31:0] m_lb_addr ,
    output wire [ 31:0] m_lb_wdata,
    input  wire [ 31:0] m_lb_rdata
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
wire [  7:0] wv_gmii_rxd_ipfc2hcp;
wire [  0:0] w_gmii_dv_ipfc2hcp;

wire [  7:0] wv_gmii_txd_hcp2opfc;
wire [  0:0] w_gmii_en_hcp2opfc;

reg  [ 63:0] sel_command;
reg          sel_command_wr;
wire [ 63:0] sel_command_ack;
wire         sel_command_ack_wr;

wire [ 63:0] wv_command_1;
wire         w_command_wr_1;
reg  [ 63:0] rv_command_ack_1;
reg          r_command_ack_wr_1;

wire [ 63:0] wv_command_2;
wire         w_command_wr_2;
reg  [ 63:0] rv_command_ack_2;
reg          r_command_ack_wr_2;

wire [ 63:0] wv_command_3;
wire         w_command_wr_3;
reg  [ 63:0] rv_command_ack_3;
reg          r_command_ack_wr_3;

reg          ext_axis_tready;
wire         ext_axis_tvalid;
wire [ 15:0] ext_axis_tkeep ;
wire [127:0] ext_axis_tdata ;
wire         ext_axis_tlast ;
wire         ext_axis_tuser ;

wire         ext_axis_sop;
wire [  7:0] ext_axis_line_id;
wire         ext_axis_eop;
/*-----------------------------------------------------------------------
                    MBUS通路选择
-----------------------------------------------------------------------*/
always @* begin
    if(Mbus_ID == 1)begin
        sel_command        = wv_command_1;
        sel_command_wr     = w_command_wr_1;
        
        rv_command_ack_1    = sel_command_ack;
        r_command_ack_wr_1  = sel_command_ack_wr;

        rv_command_ack_2    = 64'd0;
        r_command_ack_wr_2  = 1'd0;

        rv_command_ack_3    = 64'd0;
        r_command_ack_wr_3  = 1'd0;
    end
    else if(Mbus_ID == 2)begin
        sel_command         = wv_command_2;
        sel_command_wr      = w_command_wr_2;
        
        rv_command_ack_1    = 64'd0;
        r_command_ack_wr_1  = 1'd0; 
        
        rv_command_ack_2    = sel_command_ack;
        r_command_ack_wr_2  = sel_command_ack_wr;
        
        rv_command_ack_3    = 64'd0;
        r_command_ack_wr_3  = 1'd0;
    end
    else begin
        sel_command         = wv_command_3;
        sel_command_wr      = w_command_wr_3;
        
        rv_command_ack_1    = 64'd0;
        r_command_ack_wr_1  = 1'd0; 
        
        rv_command_ack_2    = 64'd0;
        r_command_ack_wr_2  = 1'd0;
        
        rv_command_ack_3    = sel_command_ack;  
        r_command_ack_wr_3  = sel_command_ack_wr;
    end
end
/*-----------------------------------------------------------------------
                    输出报文Metadata修改
-----------------------------------------------------------------------*/
assign ext_axis_tuser = 1'b0;
always@(*) begin
    ext_axis_tready = m_axis_tready;
    
    m_axis_tvalid = ext_axis_tvalid;
    m_axis_tkeep  = ext_axis_tkeep ;
    m_axis_tlast  = ext_axis_tlast ;
    m_axis_tuser  = ext_axis_tuser ;
    if(ext_axis_sop == 1'b1) begin
        m_axis_tdata = {8'hFF,8'd0,
                        ext_axis_tdata[87:77],
                        2'b0,1'b0,10'b0,
                        4'd8,20'd0,16'd0,48'b0};
    end
    else begin
        m_axis_tdata = ext_axis_tdata ;
    end
end

/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
hardware_control_point hardware_control_point_inst(
.i_clk                          ( hcp_clk   ),
.i_rst_n                        ( hcp_rst_n ),

.ov_syn_clk                     (     ),
.ov_local_cnt                   (     ),
.ov_syn_clock_cycle             (     ),
.o_tsn_or_tte                   (     ),

.i_data_wr_from_tss             ( w_gmii_dv_ipfc2hcp    ),
.iv_data_from_tss               ( wv_gmii_rxd_ipfc2hcp  ),
.ov_data_to_tss                 ( wv_gmii_txd_hcp2opfc  ),
.o_data_wr_to_tss               ( w_gmii_en_hcp2opfc    ),

.i_gmii_rxclk_from_cpu          ( hcp_clk               ),
.i_gmii_rx_dv_from_cpu          ( 1'd0                  ),
.iv_gmii_rxd_from_cpu           ( 8'd0                  ),
.i_gmii_rx_er_from_cpu          ( 1'd0                  ),

.ov_gmii_txd_to_cpu             ( ),
.o_gmii_tx_en_to_cpu            ( ),
.o_gmii_txclk_to_cpu            ( ),
.o_gmii_tx_er_to_cpu            ( ),

.ov_local_id                    ( ),
.iv_tss_ver                     ( ),
.o_rc_rxenable                  ( ),
.o_st_rxenable                  ( ),

.i_tsmp_lookup_table_key_wr     ( 1'b0  ),
.iv_tsmp_lookup_table_key       ( 48'b0 ),
.ov_tsmp_lookup_table_outport   (  ),
.o_tsmp_lookup_table_outport_wr (  ),   

.iv_time_slot_length            ( ),
.iv_schedule_period             ( ),
.o_cycle_start                  ( ),

.o_wr_osm                       ( ),
.ov_wdata_osm                   ( ),
.ov_addr_osm                    ( ),
.o_addr_fix_osm                 ( ),
.o_rd_osm                       ( ),
.i_wr_osm                       ( 1'b0 ),
.iv_raddr_osm                   ( 19'b0),
.i_addr_fix_osm                 ( 1'b0 ),
.iv_rdata_osm                   ( 32'b0),

.ov_command_1                   ( wv_command_1          ),
.o_command_wr_1                 ( w_command_wr_1        ),
.iv_command_ack_1               ( rv_command_ack_1      ),
.i_command_ack_wr_1             ( r_command_ack_wr_1    ),
                                    
.ov_command_2                   ( wv_command_2          ),
.o_command_wr_2                 ( w_command_wr_2        ),
.iv_command_ack_2               ( rv_command_ack_2      ),
.i_command_ack_wr_2             ( r_command_ack_wr_2    ),
                                    
.ov_command_3                   ( wv_command_3          ),
.o_command_wr_3                 ( w_command_wr_3        ),
.iv_command_ack_3               ( rv_command_ack_3      ),
.i_command_ack_wr_3             ( r_command_ack_wr_3    )
);

CfgFmtCov #(
    .Mbus_ID                ( Mbus_ID           )
)
CfgFmtCov_inst(
    .user_clk               (hcp_clk           ),
    .user_rst_n             (hcp_rst_n         ),
                                
    .iv_command             (sel_command        ),
    .i_command_wr           (sel_command_wr     ),
    .ov_command_ack         (sel_command_ack    ),
    .o_command_ack_wr       (sel_command_ack_wr ),

    .o_m_lb_cs_n            (m_lb_cs_n        ),
    .i_m_lb_ack_n           (m_lb_ack_n       ),
    .o_m_lb_wr_rd           (m_lb_wr_rd       ),
    .ov_m_lb_addr           (m_lb_addr        ),
    .ov_m_lb_wdata          (m_lb_wdata       ),
    .iv_m_lb_rdata          (m_lb_rdata       )
);

InputPktFormatConvert InputPktFormatConvert_inst(    
    .axis_clk      ( axis_clk              ),
    .axis_rst_n    ( axis_rst_n            ),
    .hcp_clk       ( hcp_clk               ),
    .hcp_rst_n     ( hcp_rst_n             ),
                   
    .o_axis_tready ( s_axis_tready         ),
    .i_axis_tvalid ( s_axis_tvalid         ),
    .iv_axis_tkeep ( s_axis_tkeep          ),
    .iv_axis_tdata ( s_axis_tdata          ),
    .i_axis_tlast  ( s_axis_tlast          ),
                   
    .ov_gmii_rxd   ( wv_gmii_rxd_ipfc2hcp  ),
    .o_gmii_dv     ( w_gmii_dv_ipfc2hcp    ),
    .o_gmii_er     ( )
);

OutputPktFormatConvert OutputPktFormatConvert_inst(
    .axis_clk      ( axis_clk              ),
    .axis_rst_n    ( axis_rst_n            ),
    .hcp_clk       ( hcp_clk               ),
    .hcp_rst_n     ( hcp_rst_n             ),
                   
    .iv_gmii_txd   ( wv_gmii_txd_hcp2opfc  ),
    .i_gmii_en     ( w_gmii_en_hcp2opfc    ),
    .i_gmii_er     ( ),
                   
    .i_axis_tready ( ext_axis_tready     ),
    .o_axis_tvalid ( ext_axis_tvalid     ),
    .ov_axis_tkeep ( ext_axis_tkeep      ),
    .ov_axis_tdata ( ext_axis_tdata      ),
    .o_axis_tlast  ( ext_axis_tlast      )
);

PktLineDet #(8) extaxisLineDet_Inst(
    .user_clk      ( axis_clk          ),
    .user_rst_n    ( axis_rst_n        ),
                   
    .valid         ( ext_axis_tready & ext_axis_tvalid),
    .last          ( ext_axis_tlast      ),
                   
    .sop           ( ext_axis_sop        ),
    .line_id       ( ext_axis_line_id    ),
    .eop           ( ext_axis_eop        )
);
endmodule
/*
HCPHub#(
    .Mbus_ID()
)
HCPHub_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
    .hcp_clk   (),
    .hcp_rst_n (),
//报文分组数据接收接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//报文分组数据输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
//配置管理接口         
    .m_lb_cs_n (),
    .m_lb_ack_n(),
    .m_lb_wr_rd(),
    .m_lb_addr (),
    .m_lb_wdata(),
    .m_lb_rdata()
);
*/