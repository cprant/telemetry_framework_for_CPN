/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  New_NP_TOP.v
Target Device All
Dscription 

Data_Struct:
    1)
    
Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module New_NP_TOP #(
    parameter   VERSION      = 32'h23_0129_01,//8bit年后2位+16bit月日+8bit版本号
                THREAD_SUM   = 4,
                SGMII_SUM    = 4,
                BASER_SUM    = 1
)(
    //系统时钟和复位
    input  wire                 K7_HARD_SOFT_RST  ,

    input  wire                 FPGA_SYSCLKP_LVDS ,
    input  wire                 FPGA_SYSCLKN_LVDS ,

    input  wire                 FPGA_REFCLKP_LVDS ,
    input  wire                 FPGA_REFCLKN_LVDS ,
    
	output	reg		[1:0]		BCM5465_RST,
    
//BCM8558 MDIO
	output			[1:0]		FPGA_8558_MDC ,
	inout			[1:0]		FPGA_8558_MDIO,
	output			[1:0]		FPGA_8558_RST ,
    
	output reg					RTL8211_RST_N,
    
    //4千兆网口
    output wire [SGMII_SUM-1:0] FPGA_SGMII_TXP    ,
    output wire [SGMII_SUM-1:0] FPGA_SGMII_TXN    ,
    input  wire [SGMII_SUM-1:0] FPGA_SGMII_RXP    ,
    input  wire [SGMII_SUM-1:0] FPGA_SGMII_RXN    ,
    input  wire                 PHY_CLK_OUTP      ,
    
    //1万兆网口
    input  wire                 FPGA_SERDES_CLKP  ,
    input  wire                 FPGA_SERDES_CLKN  ,
    input  wire                 FPGA_SERDES_RXN   ,
    input  wire                 FPGA_SERDES_RXP   ,
    output wire                 FPGA_SERDES_TXN   ,
    output wire                 FPGA_SERDES_TXP   ,
                                                   
	input						SFP1_TX_FAULT	  ,
	output						SFP1_TX_DISABLE	  ,
	input						SFP1_MOD_ABS      ,
	input						SFP1_RX_LOS       ,
	output						SFP1_RS0          ,
	output						SFP1_RS1          ,
	output						SFP1_SCL          ,
	inout						SFP1_SDA          ,
                                                   
    //CPU网口                                      
    input                       FPGA_GMAC_RX_CLK  ,
    output                      FPGA_GMAC_GTX_CLK ,
    input           [3:0]       FPGA_GMAC_RXD     ,
    input                       FPGA_GMAC_RXDV    ,
    output          [3:0]       FPGA_GMAC_TXD     ,
    output                      FPGA_GMAC_TXEN    
    
);
/*************************************  ************
                  中间变量声明区域      
**************************************  ************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam  CPU_BYTE  = 1,
            Mbus_ID   = 1,
            
            SRC_STEP   = 32'h8_0000,
            SGMII_DST_STEP = 32'h8_0000,
            BASER_DST_STEP = 32'h6_6667,
            INIT_DLY   = 3,//应当大于src_clk和dst_clk之间的倍率
            TIME_WIDTH = 64;

wire                    user_rst_n;
wire                    w_soft_rst_n;

wire            clk_156p25              ;
wire            clk_125                 ;
wire            clk_200                 ;
wire            clk_312p5               ;
wire            locked                  ;
wire            locked1                 ;
wire            sys_rst_n               ;
        
        
reg	[31:0]  phy_cnt;

always @(posedge clk_125 or negedge sys_rst_n) begin           
 	if(~sys_rst_n) begin//reset cpld           
    	BCM5465_RST		<= 2'b0;
		RTL8211_RST_N	<= 1'b0;
		phy_cnt			<= 32'b0;    	
    end    	
	else begin     
		if (phy_cnt > 32'h201400 )begin	
			BCM5465_RST	    <= 2'b11;
			RTL8211_RST_N	<= 1'b1;
		end                	
        else if(phy_cnt	 <= 32'h201400 && phy_cnt > 32'h201000)begin			
        	BCM5465_RST		<= 2'b0;
			RTL8211_RST_N	<= 1'b0;
			phy_cnt			<= phy_cnt + 32'b1;
        end 
		else if(phy_cnt	 <= 32'h201000 && phy_cnt > 32'h200000)begin			
        	BCM5465_RST		<= 2'b11;
			RTL8211_RST_N	<= 1'b1;
			phy_cnt			<= phy_cnt + 32'b1;
        end                    	
		else begin            
			BCM5465_RST		<= 2'b0;
			RTL8211_RST_N	<= 1'b0;
			phy_cnt			<= phy_cnt + 32'b1;		
		end                                         
	end            
end
        
assign          SFP1_TX_DISABLE     = 1'b0;
assign          SFP1_RS0            = 1'b1;    
assign          SFP1_RS1            = 1'b1;    
assign			SFP1_SCL			= 1'b0;
        
assign			FPGA_8558_MDC[0]	= 1'b0;
assign			FPGA_8558_MDC[1]	= 1'b0;
        
/***************************************************
                  10G-MAC相关信号
****************************************************/

wire                    TenGmac_coreclk_out     ;

(*mark_debug="true"*)wire [          7:0] TenGmac_pcspma_status   ;

wire                    TenGmac_axis_tx_tready  ;
wire [            63:0] TenGmac_axis_tx_tdata   ;
wire [             7:0] TenGmac_axis_tx_tkeep   ;
wire                    TenGmac_axis_tx_tlast   ;
wire                    TenGmac_axis_tx_tuser   ;
wire                    TenGmac_axis_tx_tvalid  ;
                              
wire [            63:0] TenGmac_axis_rx_tdata   ;
wire [             7:0] TenGmac_axis_rx_tkeep   ;
wire                    TenGmac_axis_rx_tlast   ;
wire                    TenGmac_axis_rx_tuser   ;
wire                    TenGmac_axis_rx_tvalid  ;

/***************************************************
                  1G-MAC相关信号
****************************************************/

wire                    OneGmac_clk125_out         ;
wire                    OneGmac_clk625_out         ;
wire                    OneGmac_clk208_out         ;
wire                    OneGmac_clk104_out         ;
wire                    OneGmac_rst_125_out        ;
wire                    OneGmac_mmcm_locked_out    ;
wire                    OneGmac_mmcm_locked_out_end;

(*mark_debug="true"*)wire [16*SGMII_SUM-1:0] OneGmac_status_vector       ;

wire [   SGMII_SUM-1:0] tx_mac_aclk                ;
wire [   SGMII_SUM-1:0] rx_mac_aclk                ;
wire [   SGMII_SUM-1:0] tx_reset                   ;
wire [   SGMII_SUM-1:0] rx_reset                   ;

wire [   SGMII_SUM-1:0] OneGmac_axis_tx_tready     ;
wire [ 8*SGMII_SUM-1:0] OneGmac_axis_tx_tdata      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_tx_tlast      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_tx_tuser      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_tx_tvalid     ;
                                            
wire [ 8*SGMII_SUM-1:0] OneGmac_axis_rx_tdata      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_rx_tlast      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_rx_tuser      ;
wire [   SGMII_SUM-1:0] OneGmac_axis_rx_tvalid     ;


/***************************************************
                  CPU网口-MAC相关信号
****************************************************/

(*mark_debug="true"*)wire [27:0]     CPUNetMac_rx_statistics_vector;
(*mark_debug="true"*)wire            CPUNetMac_rx_statistics_valid ;

wire            CPUNetMac_rx_mac_aclk         ;
wire            CPUNetMac_rx_reset            ;
(*mark_debug="true"*)wire            CPUNetMac_rx_enable           ;
(*mark_debug="true"*)wire [ 7:0]     CPUNetMac_rx_axis_mac_tdata   ;
(*mark_debug="true"*)wire            CPUNetMac_rx_axis_mac_tvalid  ;
(*mark_debug="true"*)wire            CPUNetMac_rx_axis_mac_tlast   ;
(*mark_debug="true"*)wire            CPUNetMac_rx_axis_mac_tuser   ;

(*mark_debug="true"*)wire [27:0]     CPUNetMac_tx_statistics_vector;
(*mark_debug="true"*)wire            CPUNetMac_tx_statistics_valid ;

wire            CPUNetMac_tx_mac_aclk         ;
wire            CPUNetMac_tx_reset            ;
(*mark_debug="true"*)wire            CPUNetMac_tx_enable           ;
(*mark_debug="true"*)wire [ 7:0]     CPUNetMac_tx_axis_mac_tdata   ;
(*mark_debug="true"*)wire            CPUNetMac_tx_axis_mac_tvalid  ;
(*mark_debug="true"*)wire            CPUNetMac_tx_axis_mac_tlast   ;
(*mark_debug="true"*)wire            CPUNetMac_tx_axis_mac_tuser   ;
(*mark_debug="true"*)wire            CPUNetMac_tx_axis_mac_tready  ;

/*----------------------------------------------------------
                     时钟复位管理
----------------------------------------------------------*/
assign sys_rst_n           = locked & locked1 ; 

RstExtend #(
    .RESET_CYCLE(625000000)
)
RstExtend_5s_inst(
    .clk(clk_125),
    .int_rst_n(sys_rst_n & w_soft_rst_n),
    .ext_rst_n(user_rst_n)
); 

SYS_PLL clk_wiz_0 (
    // Clock out ports
    .clk_out1               (clk_156p25         ),
    .clk_out2               (clk_125            ),
    .clk_out3               (clk_312p5          ),
    .clk_out4               (                   ),
    // Status and control signals                
    .resetn                 (K7_HARD_SOFT_RST   ),
    .locked                 (locked             ), 
    // Clock in ports                            
    .clk_in1_p              (FPGA_SYSCLKP_LVDS  ),
    .clk_in1_n              (FPGA_SYSCLKN_LVDS  )
);

DELAY_PLL clk_wiz_1 (
    // Clock out ports
    .clk_out1               (clk_200            )
    // Status and control signals
,   .resetn                 (K7_HARD_SOFT_RST   )
,   .locked                 (locked1            )
    // Clock in ports
,   .clk_in1_p              (FPGA_REFCLKP_LVDS  )
,   .clk_in1_n              (FPGA_REFCLKN_LVDS  )
);  

/*----------------------------------------------------------
                     10G-MAC核
----------------------------------------------------------*/
SFP_M_axi_10g_ethernet SFP_M_axi_10g_ethernet_inst (
    .tx_axis_aresetn        (sys_rst_n                      ),      // input wire tx_axis_aresetn
    .rx_axis_aresetn        (sys_rst_n                      ),      // input wire rx_axis_aresetn
    .tx_ifg_delay           (8'd12                          ),      // input wire [7 : 0] tx_ifg_delay
    .dclk                   (clk_125                        ),      // input wire dclk
    .txp                    (FPGA_SERDES_TXP                ),
    .txn                    (FPGA_SERDES_TXN                ),
    .rxp                    (FPGA_SERDES_RXP                ),
    .rxn                    (FPGA_SERDES_RXN                ),
    .signal_detect          (1'b1                           ),      // input wire signal_detect
    .tx_fault               (1'b0                           ),      // input wire tx_fault
    .tx_disable             (                               ),      // output wire tx_disable
    .pcspma_status          (TenGmac_pcspma_status          ),      // output wire [7 : 0] pcspma_status
    .sim_speedup_control    (1'b0                           ),      // input wire sim_speedup_control
    .rxrecclk_out           (                               ),      // output wire rxrecclk_out
    .s_axi_aclk             (TenGmac_coreclk_out            ),      // input wire s_axi_aclk
    .s_axi_aresetn          (sys_rst_n                      ),      // input wire s_axi_aresetn
    .xgmacint               (                               ),      // output wire xgmacint
    .areset_datapathclk_out (                               ),      // output wire areset_datapathclk_out
    .txusrclk_out           (                               ),      // output wire txusrclk_out
    .txusrclk2_out          (                               ),      // output wire txusrclk2_out
    .gttxreset_out          (                               ),      // output wire gttxreset_out
    .gtrxreset_out          (                               ),      // output wire gtrxreset_out
    .txuserrdy_out          (                               ),      // output wire txuserrdy_out
    .coreclk_out            (TenGmac_coreclk_out            ),      // output wire coreclk_out
    .resetdone_out          (                               ),      // output wire resetdone_out
    .reset_counter_done_out (                               ),      // output wire reset_counter_done_out
    .qplllock_out           (                               ),      // output wire qplllock_out
    .qplloutclk_out         (                               ),      // output wire qplloutclk_out
    .qplloutrefclk_out      (                               ),      // output wire qplloutrefclk_out
    .refclk_p               (FPGA_SERDES_CLKP               ),      // input wire refclk_p
    .refclk_n               (FPGA_SERDES_CLKN               ),      // input wire refclk_n
    .reset                  (~sys_rst_n                     ),      // input wire reset
    .s_axi_araddr           (11'b0                          ),      // input wire [10 : 0] s_axi_araddr
    .s_axi_arready          (                               ),      // output wire s_axi_arready
    .s_axi_arvalid          (1'b0                           ),      // input wire s_axi_arvalid
    .s_axi_awaddr           (11'b0                          ),      // input wire [10 : 0] s_axi_awaddr
    .s_axi_awready          (                               ),      // output wire s_axi_awready
    .s_axi_awvalid          (1'b0                           ),      // input wire s_axi_awvalid
    .s_axi_bready           (1'b0                           ),      // input wire s_axi_bready
    .s_axi_bresp            (                               ),      // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid           (                               ),      // output wire s_axi_bvalid
    .s_axi_rdata            (                               ),      // output wire [31 : 0] s_axi_rdata
    .s_axi_rready           (1'b0                           ),      // input wire s_axi_rready
    .s_axi_rresp            (                               ),      // output wire [1 : 0] s_axi_rresp
    .s_axi_rvalid           (                               ),      // output wire s_axi_rvalid
    .s_axi_wdata            (32'b0                          ),      // input wire [31 : 0] s_axi_wdata
    .s_axi_wready           (                               ),      // output wire s_axi_wready
    .s_axi_wvalid           (1'b0                           ),      // input wire s_axi_wvalid
    
    .s_axis_tx_tready       (TenGmac_axis_tx_tready         ),
    .s_axis_tx_tdata        (TenGmac_axis_tx_tdata          ),
    .s_axis_tx_tkeep        (TenGmac_axis_tx_tkeep          ),
    .s_axis_tx_tlast        (TenGmac_axis_tx_tlast          ),
    .s_axis_tx_tuser        (1'd0                           ),
    .s_axis_tx_tvalid       (TenGmac_axis_tx_tvalid         ),
    
    .m_axis_rx_tdata        (TenGmac_axis_rx_tdata          ),
    .m_axis_rx_tkeep        (TenGmac_axis_rx_tkeep          ),
    .m_axis_rx_tlast        (TenGmac_axis_rx_tlast          ),
    .m_axis_rx_tuser        (TenGmac_axis_rx_tuser          ),
    .m_axis_rx_tvalid       (TenGmac_axis_rx_tvalid         ),
    .s_axis_pause_tdata     (16'b0                          ),      // input wire [15 : 0] s_axis_pause_tdata
    .s_axis_pause_tvalid    (1'b0                           ),      // input wire s_axis_pause_tvalid
    .tx_statistics_valid    (                               ),      // output wire tx_statistics_valid
    .tx_statistics_vector   (                               ),      // output wire [25 : 0] tx_statistics_vector
    .rx_statistics_valid    (                               ),      // output wire rx_statistics_valid
    .rx_statistics_vector   (                               )       // output wire [29 : 0] rx_statistics_vector
    );

/*----------------------------------------------------------
                     1G-MAC核-LVDS
----------------------------------------------------------*/
IDELAYCTRL core_idelayctrl_i 
 (
   .REFCLK                  (OneGmac_clk208_out         ),
   .RST                     (~OneGmac_mmcm_locked_out    ),
   
   .RDY                     (OneGmac_mmcm_locked_out_end)
 );

generate
genvar i_sgmii;
  for (i_sgmii=0; i_sgmii<SGMII_SUM; i_sgmii = i_sgmii + 1) begin: sgmii_interface
    if (i_sgmii == 0) begin
      SGMII_M_axi_ethernet axi_1g_ethernet(
        .s_axi_lite_resetn              (sys_rst_n                  ),      // input wire tx_axis_aresetn
        .s_axi_lite_clk                 (clk_125                    ),      // input wire rx_axis_aresetn
        .mac_irq                        (                           ),
        .tx_mac_aclk                    (tx_mac_aclk[i_sgmii]       ),
        .rx_mac_aclk                    (rx_mac_aclk[i_sgmii]       ),
        .tx_reset                       (tx_reset[i_sgmii]          ),
        .rx_reset                       (rx_reset[i_sgmii]          ),
        .glbl_rst                       (~sys_rst_n                 ),
        .tx_ifg_delay                   (8'd12                      ),      // input wire [7 : 0] tx_ifg_delay
        .status_vector                  (OneGmac_status_vector[i_sgmii*16 +: 16]),
//      .rx_axis_filter_tuser           (                           ),
        .signal_detect                  (1'b1                       ),      // input wire signal_detect
        .clk125_out                     (OneGmac_clk125_out         ),      // output wire clk125_out
        .clk625_out                     (OneGmac_clk625_out         ),      // output wire clk625_out
        .clk208_out                     (OneGmac_clk208_out         ),      // output wire clk208_out
        .clk104_out                     (OneGmac_clk104_out         ),      // output wire clk104_out
        .rst_125_out                    (OneGmac_rst_125_out        ),      // output wire rst_125_out
        .mmcm_locked_out                (OneGmac_mmcm_locked_out    ),
        .mmcm_locked_out_end            (OneGmac_mmcm_locked_out_end),
        .phy_rst_n                      (                           ),
        .s_axi_araddr                   (11'b0                      ),      // input wire [10 : 0] s_axi_araddr
        .s_axi_arready                  (                           ),      // output wire s_axi_arready
        .s_axi_arvalid                  (1'b0                       ),      // input wire s_axi_arvalid
        .s_axi_awaddr                   (11'b0                      ),      // input wire [10 : 0] s_axi_awaddr
        .s_axi_awready                  (                           ),      // output wire s_axi_awready
        .s_axi_awvalid                  (1'b0                       ),      // input wire s_axi_awvalid
        .s_axi_bready                   (1'b0                       ),      // input wire s_axi_bready
        .s_axi_bresp                    (                           ),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid                   (                           ),      // output wire s_axi_bvalid
        .s_axi_rdata                    (                           ),      // output wire [31 : 0] s_axi_rdata
        .s_axi_rready                   (1'b0                       ),      // input wire s_axi_rready
        .s_axi_rresp                    (                           ),      // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid                   (                           ),      // output wire s_axi_rvalid
        .s_axi_wdata                    (32'b0                      ),      // input wire [31 : 0] s_axi_wdata
        .s_axi_wready                   (                           ),      // output wire s_axi_wready
        .s_axi_wvalid                   (1'b0                       ),      // input wire s_axi_wvalid
            
        .s_axis_tx_tready               (OneGmac_axis_tx_tready [i_sgmii]       ),
        .s_axis_tx_tdata                (OneGmac_axis_tx_tdata  [i_sgmii*8 +: 8]),
        .s_axis_tx_tlast                (OneGmac_axis_tx_tlast  [i_sgmii]       ),
        .s_axis_tx_tuser                (OneGmac_axis_tx_tuser  [i_sgmii]       ),
        .s_axis_tx_tvalid               (OneGmac_axis_tx_tvalid [i_sgmii]       ),
    
        .m_axis_rx_tdata                (OneGmac_axis_rx_tdata  [i_sgmii*8 +: 8]),
        .m_axis_rx_tlast                (OneGmac_axis_rx_tlast  [i_sgmii]       ),
        .m_axis_rx_tuser                (OneGmac_axis_rx_tuser  [i_sgmii]       ),
        .m_axis_rx_tvalid               (OneGmac_axis_rx_tvalid [i_sgmii]       ),
        .s_axis_pause_tdata             (16'b0                      ),      // input wire [15 : 0] s_axis_pause_tdata
        .s_axis_pause_tvalid            (1'b0                       ),      // input wire s_axis_pause_tvalid       
        .rx_statistics_statistics_data  (                           ),
        .rx_statistics_statistics_valid (                           ),
        .tx_statistics_statistics_data  (                           ),
        .tx_statistics_statistics_valid (                           ),      
        .sgmii_rxn                      (FPGA_SGMII_RXN[i_sgmii]    ),
        .sgmii_rxp                      (FPGA_SGMII_RXP[i_sgmii]    ),
        .sgmii_txn                      (FPGA_SGMII_TXN[i_sgmii]    ),
        .sgmii_txp                      (FPGA_SGMII_TXP[i_sgmii]    ),
        .mdio_mdc                       (                           ),
        .mdio_mdio_i                    (1'b1                       ),
        .mdio_mdio_o                    (                           ),
        .mdio_mdio_t                    (                           ),
        .lvds_clk_clk                   (PHY_CLK_OUTP               )
    );
    end
    else begin
      SGMII_S_axi_ethernet axi_1g_ethernet(
        .s_axi_lite_resetn              (sys_rst_n                  ),            // input wire tx_axis_aresetn
        .s_axi_lite_clk                 (clk_125                    ),            // input wire rx_axis_aresetn
        .mac_irq                        (), 
        .tx_mac_aclk                    (tx_mac_aclk[i_sgmii]       ),
        .rx_mac_aclk                    (rx_mac_aclk[i_sgmii]       ),
        .tx_reset                       (tx_reset[i_sgmii]          ),
        .rx_reset                       (rx_reset[i_sgmii]          ),
        .glbl_rst                       (~sys_rst_n                 ),
        .tx_ifg_delay                   (8'd12                      ),                  // input wire [7 : 0] tx_ifg_delay
        .status_vector                  (OneGmac_status_vector[i_sgmii*16 +: 16]),
//      .rx_axis_filter_tuser           (                           ),
        .signal_detect                  (1'b1                       ),      // input wire signal_detect
        .clk125m                        (OneGmac_clk125_out         ),      // input wire clk125m
        .clk625                         (OneGmac_clk625_out         ),      // input wire clk625
        .clk208                         (OneGmac_clk208_out         ),      // input wire clk208
        .clk104                         (OneGmac_clk104_out         ),      // input wire clk104
        .rst_125                        (OneGmac_rst_125_out        ),      // input wire rst_125
        .mmcm_locked                    (OneGmac_mmcm_locked_out    ),
        .phy_rst_n                      (                           ),
        .s_axi_araddr                   (11'b0                      ),      // input wire [10 : 0] s_axi_araddr
        .s_axi_arready                  (                           ),      // output wire s_axi_arready
        .s_axi_arvalid                  (1'b0                       ),      // input wire s_axi_arvalid
        .s_axi_awaddr                   (11'b0                      ),      // input wire [10 : 0] s_axi_awaddr
        .s_axi_awready                  (                           ),      // output wire s_axi_awready
        .s_axi_awvalid                  (1'b0                       ),      // input wire s_axi_awvalid
        .s_axi_bready                   (1'b0                       ),      // input wire s_axi_bready
        .s_axi_bresp                    (                           ),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid                   (                           ),      // output wire s_axi_bvalid
        .s_axi_rdata                    (                           ),      // output wire [31 : 0] s_axi_rdata
        .s_axi_rready                   (1'b0                       ),      // input wire s_axi_rready
        .s_axi_rresp                    (                           ),      // output wire [1 : 0] s_axi_rresp
        .s_axi_rvalid                   (                           ),      // output wire s_axi_rvalid
        .s_axi_wdata                    (32'b0                      ),      // input wire [31 : 0] s_axi_wdata
        .s_axi_wready                   (                           ),      // output wire s_axi_wready
        .s_axi_wvalid                   (1'b0                       ),      // input wire s_axi_wvalid
            
        .s_axis_tx_tready               (OneGmac_axis_tx_tready [i_sgmii]       ),
        .s_axis_tx_tdata                (OneGmac_axis_tx_tdata  [i_sgmii*8 +: 8]),
        .s_axis_tx_tlast                (OneGmac_axis_tx_tlast  [i_sgmii]       ),
        .s_axis_tx_tuser                (OneGmac_axis_tx_tuser  [i_sgmii]       ),
        .s_axis_tx_tvalid               (OneGmac_axis_tx_tvalid [i_sgmii]       ),
                                        
        .m_axis_rx_tdata                (OneGmac_axis_rx_tdata  [i_sgmii*8 +: 8]),
        .m_axis_rx_tlast                (OneGmac_axis_rx_tlast  [i_sgmii]       ),
        .m_axis_rx_tuser                (OneGmac_axis_rx_tuser  [i_sgmii]       ),
        .m_axis_rx_tvalid               (OneGmac_axis_rx_tvalid [i_sgmii]       ),
        .s_axis_pause_tdata             (16'b0                      ),      // input wire [15 : 0] s_axis_pause_tdata
        .s_axis_pause_tvalid            (1'b0                       ),      // input wire s_axis_pause_tvalid       
        .rx_statistics_statistics_data  (                           ),
        .rx_statistics_statistics_valid (                           ),
        .tx_statistics_statistics_data  (                           ),
        .tx_statistics_statistics_valid (                           ),      
        .sgmii_rxn                      (FPGA_SGMII_RXN[i_sgmii]    ),
        .sgmii_rxp                      (FPGA_SGMII_RXP[i_sgmii]    ),
        .sgmii_txn                      (FPGA_SGMII_TXN[i_sgmii]    ),
        .sgmii_txp                      (FPGA_SGMII_TXP[i_sgmii]    ),
        .mdio_mdc                       (                           ),
        .mdio_mdio_i                    (1'b1                       ),
        .mdio_mdio_o                    (                           ),
        .mdio_mdio_t                    (                           )
    );
    end
 end
endgenerate


/*----------------------------------------------------------
                     CPU网口-MAC核-RGMII
----------------------------------------------------------*/
rgmii_ethernet_mac_m rgmii_inst0 (
    .gtx_clk                (clk_125                        ),      // input wire gtx_clk
    .gtx_clk_out            (                               ),      // output wire gtx_clk_out
    .gtx_clk90_out          (                               ),      // output wire gtx_clk90_out
    .glbl_rstn              (sys_rst_n                      ),      // input wire glbl_rstn
    .rx_axi_rstn            (sys_rst_n                      ),      // input wire rx_axi_rstn
    .tx_axi_rstn            (sys_rst_n                      ),      // input wire tx_axi_rstn
    .rx_statistics_vector   (CPUNetMac_rx_statistics_vector ),      // output wire [27 : 0] rx_statistics_vector
    .rx_statistics_valid    (CPUNetMac_rx_statistics_valid  ),      // output wire rx_statistics_valid
    .rx_mac_aclk            (CPUNetMac_rx_mac_aclk          ),      // output wire rx_mac_aclk
    .rx_reset               (CPUNetMac_rx_reset             ),      // output wire rx_reset
    .rx_enable              (CPUNetMac_rx_enable            ),      // output wire rx_enable
    .rx_axis_mac_tdata      (CPUNetMac_rx_axis_mac_tdata    ),      // output wire [7 : 0] rx_axis_mac_tdata
    .rx_axis_mac_tvalid     (CPUNetMac_rx_axis_mac_tvalid   ),      // output wire rx_axis_mac_tvalid
    .rx_axis_mac_tlast      (CPUNetMac_rx_axis_mac_tlast    ),      // output wire rx_axis_mac_tlast
    .rx_axis_mac_tuser      (CPUNetMac_rx_axis_mac_tuser    ),      // output wire rx_axis_mac_tuser
    .tx_ifg_delay           (8'b0                           ),      // input wire [7 : 0] tx_ifg_delay
    .tx_statistics_vector   (CPUNetMac_tx_statistics_vector ),      // output wire [31 : 0] tx_statistics_vector
    .tx_statistics_valid    (CPUNetMac_tx_statistics_valid  ),      // output wire tx_statistics_valid
    .tx_mac_aclk            (CPUNetMac_tx_mac_aclk          ),      // output wire tx_mac_aclk
    .tx_reset               (CPUNetMac_tx_reset             ),      // output wire tx_reset
    .tx_enable              (CPUNetMac_tx_enable            ),      // output wire tx_enable
    .tx_axis_mac_tdata      (CPUNetMac_tx_axis_mac_tdata    ),      // input wire [7 : 0] tx_axis_mac_tdata
    .tx_axis_mac_tvalid     (CPUNetMac_tx_axis_mac_tvalid   ),      // input wire tx_axis_mac_tvalid
    .tx_axis_mac_tlast      (CPUNetMac_tx_axis_mac_tlast    ),      // input wire tx_axis_mac_tlast
    .tx_axis_mac_tuser      (CPUNetMac_tx_axis_mac_tuser    ),      // input wire [0 : 0] tx_axis_mac_tuser
    .tx_axis_mac_tready     (CPUNetMac_tx_axis_mac_tready   ),      // output wire tx_axis_mac_tready
    .pause_req              (1'b0                           ),      // input wire pause_req
    .pause_val              (16'b0                          ),      // input wire [15 : 0] pause_val
    .refclk                 (clk_200                        ),      // input wire refclk
    .speedis100             (                               ),      // output wire speedis100
    .speedis10100           (                               ),      // output wire speedis10100
    .rgmii_txd              (FPGA_GMAC_TXD                  ),      // output wire [3 : 0] rgmii_txd
    .rgmii_tx_ctl           (FPGA_GMAC_TXEN                 ),      // output wire rgmii_tx_ctl
    .rgmii_txc              (FPGA_GMAC_GTX_CLK              ),      // output wire rgmii_txc
    .rgmii_rxd              (FPGA_GMAC_RXD                  ),      // input wire [3 : 0] rgmii_rxd
    .rgmii_rx_ctl           (FPGA_GMAC_RXDV                 ),      // input wire rgmii_rx_ctl
    .rgmii_rxc              (FPGA_GMAC_RX_CLK               ),      // input wire rgmii_rxc
    .inband_link_status     (                               ),      // output wire inband_link_status
    .inband_clock_speed     (                               ),      // output wire [1 : 0] inband_clock_speed
    .inband_duplex_status   (                               ),      // output wire inband_duplex_status
    .rx_configuration_vector({16'h3,32'h22221111,32'h07086806}),    // input wire [79 : 0] rx_configuration_vector
    .tx_configuration_vector({16'h3,32'h22223333,32'h07086006})     // input wire [79 : 0] tx_configuration_vector
);


/*----------------------------------------------------------
                     用户逻辑
----------------------------------------------------------*/
DN_NewNP_Core #(
    .VERSION                (VERSION                    ),//8bit年后2位+16bit月日+8bit版本号
    .THREAD_SUM             (THREAD_SUM                 ),
    .SGMII_SUM              (SGMII_SUM                  ),
    .BASER_SUM              (BASER_SUM                  ),
    .CPU_BYTE               (CPU_BYTE                   ),
    .Mbus_ID                (Mbus_ID                    ),
        
    .SRC_STEP               (SRC_STEP                   ),
    .SGMII_DST_STEP         (SGMII_DST_STEP             ),
    .BASER_DST_STEP         (BASER_DST_STEP             ),
    .INIT_DLY               (INIT_DLY                   ),//应当大于src_clk和dst_clk之间的倍率
    .TIME_WIDTH             (TIME_WIDTH                 )
)
DN_NewNP_Core_Inst(                  
    .s_cpu_axis_clk         (CPUNetMac_rx_mac_aclk      ),   
    .s_cpu_axis_rst_n       (~CPUNetMac_rx_reset        ),
        
    .m_cpu_axis_clk         (CPUNetMac_tx_mac_aclk      ), 
    .m_cpu_axis_rst_n       (~CPUNetMac_tx_reset        ),
    
    .s_sgmii_axis_clk       (rx_mac_aclk           [3:0]),  
    .s_sgmii_axis_rst_n     (~rx_reset             [3:0]),
                            
    .m_sgmii_axis_clk       (tx_mac_aclk           [3:0]),  
    .m_sgmii_axis_rst_n     (~tx_reset             [3:0]),
                
    .s_baser_axis_clk       (TenGmac_coreclk_out        ),   
    .s_baser_axis_rst_n     (sys_rst_n                  ),
                
    .m_baser_axis_clk       (TenGmac_coreclk_out        ),   
    .m_baser_axis_rst_n     (sys_rst_n                  ),
    
    .user_axis_clk          (clk_125                    ),   
    .user_axis_rst_n        (user_rst_n                  ),
                                                        
    .hcp_clk                (clk_125                    ),
    .hcp_rst_n              (user_rst_n                  ),
//CPU分分组数据接收接口
    .s_cpu_axis_tready      (                            ),
    .s_cpu_axis_tvalid      (CPUNetMac_rx_axis_mac_tvalid),
    .s_cpu_axis_tkeep       (CPUNetMac_rx_axis_mac_tvalid),
    .s_cpu_axis_tdata       (CPUNetMac_rx_axis_mac_tdata ),
    .s_cpu_axis_tlast       (CPUNetMac_rx_axis_mac_tlast ),
    .s_cpu_axis_tuser       (CPUNetMac_rx_axis_mac_tuser ),
//CPU分数据输出接口                       
    .m_cpu_axis_tready      (CPUNetMac_tx_axis_mac_tready),
    .m_cpu_axis_tvalid      (CPUNetMac_tx_axis_mac_tvalid),
    .m_cpu_axis_tkeep       (                            ),
    .m_cpu_axis_tdata       (CPUNetMac_tx_axis_mac_tdata ),
    .m_cpu_axis_tlast       (CPUNetMac_tx_axis_mac_tlast ),
    .m_cpu_axis_tuser       (CPUNetMac_tx_axis_mac_tuser ),
//SGMII分组数据接收接口
    .s_sgmii_axis_tready    (                           ),
    .s_sgmii_axis_tvalid    (OneGmac_axis_rx_tvalid[3:0]),
    .s_sgmii_axis_tkeep     (OneGmac_axis_rx_tvalid[3:0]),
    .s_sgmii_axis_tdata     (OneGmac_axis_rx_tdata [0 +:32]),
    .s_sgmii_axis_tlast     (OneGmac_axis_rx_tlast [3:0]),
    .s_sgmii_axis_tuser     (OneGmac_axis_rx_tuser [3:0]),
//SGMII数据输出接口                       
    .m_sgmii_axis_tready    (OneGmac_axis_tx_tready[3:0]),
    .m_sgmii_axis_tvalid    (OneGmac_axis_tx_tvalid[3:0]),
    .m_sgmii_axis_tkeep     (                           ),
    .m_sgmii_axis_tdata     (OneGmac_axis_tx_tdata [0 +:32]),
    .m_sgmii_axis_tlast     (OneGmac_axis_tx_tlast [3:0]),
    .m_sgmii_axis_tuser     (OneGmac_axis_tx_tuser [3:0]),
//BASE-R分组数据接收接口        
    .s_baser_axis_tready    (                           ), 
    .s_baser_axis_tvalid    (TenGmac_axis_rx_tvalid     ),
    .s_baser_axis_tkeep     (TenGmac_axis_rx_tkeep      ),
    .s_baser_axis_tdata     (TenGmac_axis_rx_tdata      ),
    .s_baser_axis_tlast     (TenGmac_axis_rx_tlast      ),
    .s_baser_axis_tuser     (TenGmac_axis_rx_tuser      ),
//SGMII数据输出接口                   
    .m_baser_axis_tready    (TenGmac_axis_tx_tready     ),
    .m_baser_axis_tvalid    (TenGmac_axis_tx_tvalid     ),
    .m_baser_axis_tkeep     (TenGmac_axis_tx_tkeep      ),
    .m_baser_axis_tdata     (TenGmac_axis_tx_tdata      ),
    .m_baser_axis_tlast     (TenGmac_axis_tx_tlast      ),
    .m_baser_axis_tuser     (TenGmac_axis_tx_tuser      ),

    .o_soft_rst_n           (w_soft_rst_n               )
);

endmodule
