// (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:ip:axi_ethernet:7.1
// IP Revision: 5

(* X_CORE_INFO = "bd_074d,Vivado 2018.3" *)
(* CHECK_LICENSE_TYPE = "SGMII_M_axi_ethernet,bd_074d,{}" *)
(* CORE_GENERATION_INFO = "SGMII_M_axi_ethernet,bd_074d,{x_ipProduct=Vivado 2018.3,x_ipVendor=xilinx.com,x_ipLibrary=ip,x_ipName=axi_ethernet,x_ipVersion=7.1,x_ipCoreRevision=5,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,x_ipLicense=tri_mode_eth_mac@2015.04(bought),x_ipLicense=eth_avb_endpoint@2015.04(bought),Component_Name=SGMII_M_axi_ethernet,USE_BOARD_FLOW=false,ETHERNET_BOARD_INTERFACE=Custom,speed_1_2p5=1G,PHY_TYPE=SGMII,processor_mode=false,PHYRST_BOARD_INTERFACE=Custom,PHYRST_BOARD_INTERFACE_DUMMY_PORT=Custom,DIFFCL\
K_BOARD_INTERFACE=Custom,MDIO_BOARD_INTERFACE=Custom,ENABLE_LVDS=true,Enable_1588=false,ENABLE_AVB=false,Enable_1588_1step=false,Timer_Format=0,TIMER_CLK_PERIOD=4000,PHYADDR=1,gt_type=GTH,Include_IO=true,SupportLevel=1,GTinEx=false,TransceiverControl=false,EnableAsyncSGMII=false,ClockSelection=Sync,tx_in_upper_nibble=true,txlane0_placement=DIFF_PAIR_0,rxlane0_placement=DIFF_PAIR_0,txlane1_placement=DIFF_PAIR_1,rxlane1_placement=DIFF_PAIR_1,InstantiateBitslice0=false,rxnibblebitslice0used=false,R\
XMEM=4k,TXMEM=4k,TXCSUM=None,RXCSUM=None,TXVLAN_TRAN=false,RXVLAN_TRAN=false,TXVLAN_TAG=false,RXVLAN_TAG=false,TXVLAN_STRP=false,RXVLAN_STRP=false,MCAST_EXTEND=false,Frame_Filter=true,Number_of_Table_Entries=4,Statistics_Counters=true,Statistics_Reset=false,Statistics_Width=64bit,Enable_Pfc=false,drpclkrate=50.0,gtrefclkrate=125,lvdsclkrate=125,axiliteclkrate=125.0,axisclkrate=100.0,gtrefclksrc=clk0,gtlocation=X0Y0,SIMULATION_MODE=false}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module SGMII_M_axi_ethernet (
  s_axi_lite_resetn,
  s_axi_lite_clk,
  mac_irq,
  tx_mac_aclk,
  rx_mac_aclk,
  tx_reset,
  rx_reset,
  glbl_rst,
  tx_ifg_delay,
  status_vector,
  signal_detect,
  clk125_out,
  clk625_out,
  clk208_out,
  clk104_out,
  rst_125_out,
  mmcm_locked_out,
  mmcm_locked_out_end,
  phy_rst_n,
  s_axi_araddr,
  s_axi_arready,
  s_axi_arvalid,
  s_axi_awaddr,
  s_axi_awready,
  s_axi_awvalid,
  s_axi_bready,
  s_axi_bresp,
  s_axi_bvalid,
  s_axi_rdata,
  s_axi_rready,
  s_axi_rresp,
  s_axi_rvalid,
  s_axi_wdata,
  s_axi_wready,
  s_axi_wvalid,
  s_axis_tx_tdata,
  s_axis_tx_tlast,
  s_axis_tx_tready,
  s_axis_tx_tuser,
  s_axis_tx_tvalid,
  m_axis_rx_tdata,
  m_axis_rx_tlast,
  m_axis_rx_tuser,
  m_axis_rx_tvalid,
  s_axis_pause_tdata,
  s_axis_pause_tvalid,
  rx_statistics_statistics_data,
  rx_statistics_statistics_valid,
  tx_statistics_statistics_data,
  tx_statistics_statistics_valid,
  sgmii_rxn,
  sgmii_rxp,
  sgmii_txn,
  sgmii_txp,
  mdio_mdc,
  mdio_mdio_i,
  mdio_mdio_o,
  mdio_mdio_t,
  lvds_clk_clk,
  lvds_clk_clk_n,
  lvds_clk_clk_p
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.s_axi_lite_resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.s_axi_lite_resetn RST" *)
input wire s_axi_lite_resetn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.s_axi_lite_clk, FREQ_HZ 100000000, PHASE 0.000, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_lite_resetn, INSERT_VIP 0, ASSOCIATED_CLKEN CE" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.s_axi_lite_clk CLK" *)
input wire s_axi_lite_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.mac_irq, SENSITIVITY EDGE_RISING, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.mac_irq INTERRUPT" *)
output wire mac_irq;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.tx_mac_aclk, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, ASSOCIATED_BUSIF s_axis_pause:s_axis_tx, ASSOCIATED_RESET tx_reset, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.tx_mac_aclk CLK" *)
output wire tx_mac_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.rx_mac_aclk, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, ASSOCIATED_BUSIF m_axis_rx, ASSOCIATED_RESET rx_reset, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.rx_mac_aclk CLK" *)
output wire rx_mac_aclk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.tx_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.tx_reset RST" *)
output wire tx_reset;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.rx_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.rx_reset RST" *)
output wire rx_reset;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.glbl_rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.glbl_rst RST" *)
input wire glbl_rst;
input wire [7 : 0] tx_ifg_delay;
output wire [15 : 0] status_vector;
input wire signal_detect;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk125_out, FREQ_HZ 125000000, PHASE 0, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, ASSOCIATED_RESET rst_125_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk125_out CLK" *)
output wire clk125_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk625_out, FREQ_HZ 625000000, PHASE 0, CLK_DOMAIN bd_074d_pcs_pma_0_clk625_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk625_out CLK" *)
output wire clk625_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk208_out, FREQ_HZ 208333333, PHASE 0, CLK_DOMAIN bd_074d_pcs_pma_0_clk208_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk208_out CLK" *)
output wire clk208_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk104_out, FREQ_HZ 104166666, PHASE 0, CLK_DOMAIN bd_074d_pcs_pma_0_clk104_out, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk104_out CLK" *)
output wire clk104_out;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.rst_125_out, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.rst_125_out RST" *)
output wire rst_125_out;
output wire mmcm_locked_out;
input wire mmcm_locked_out_end;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.phy_rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0, BOARD.ASSOCIATED_PARAM PHYRST_BOARD_INTERFACE" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.phy_rst_n RST" *)
output wire [0 : 0] phy_rst_n;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *)
input wire [11 : 0] s_axi_araddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *)
output wire s_axi_arready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *)
input wire s_axi_arvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *)
input wire [11 : 0] s_axi_awaddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *)
output wire s_axi_awready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *)
input wire s_axi_awvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *)
input wire s_axi_bready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *)
output wire [1 : 0] s_axi_bresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *)
output wire s_axi_bvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *)
output wire [31 : 0] s_axi_rdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *)
input wire s_axi_rready;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *)
output wire [1 : 0] s_axi_rresp;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *)
output wire s_axi_rvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *)
input wire [31 : 0] s_axi_wdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *)
output wire s_axi_wready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER\
_BITS_PER_BYTE 0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *)
input wire s_axi_wvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TDATA" *)
input wire [7 : 0] s_axis_tx_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TLAST" *)
input wire s_axis_tx_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TREADY" *)
output wire s_axis_tx_tready;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TUSER" *)
input wire [0 : 0] s_axis_tx_tuser;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_tx, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TVALID" *)
input wire s_axis_tx_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TDATA" *)
output wire [7 : 0] m_axis_rx_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TLAST" *)
output wire m_axis_rx_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TUSER" *)
output wire m_axis_rx_tuser;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_rx, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TVALID" *)
output wire m_axis_rx_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TDATA" *)
input wire [15 : 0] s_axis_pause_tdata;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_pause, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_074d_pcs_pma_0_clk125_out, LAYERED_METADATA undef, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TVALID" *)
input wire s_axis_pause_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_data" *)
output wire [27 : 0] rx_statistics_statistics_data;
(* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_valid" *)
output wire rx_statistics_statistics_valid;
(* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_data" *)
output wire [31 : 0] tx_statistics_statistics_data;
(* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_valid" *)
output wire tx_statistics_statistics_valid;
(* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXN" *)
input wire sgmii_rxn;
(* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXP" *)
input wire sgmii_rxp;
(* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXN" *)
output wire sgmii_txn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sgmii, BOARD.ASSOCIATED_PARAM ETHERNET_BOARD_INTERFACE" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXP" *)
output wire sgmii_txp;
(* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDC" *)
output wire mdio_mdc;
(* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_I" *)
input wire mdio_mdio_i;
(* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_O" *)
output wire mdio_mdio_o;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME mdio, CAN_DEBUG false, BOARD.ASSOCIATED_PARAM MDIO_BOARD_INTERFACE" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_T" *)
output wire mdio_mdio_t;
(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 lvds_clk CLK_N" *)
input wire lvds_clk_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME lvds_clk, CAN_DEBUG false, FREQ_HZ 125000000, TYPE ETH_LVDS_CLK, BOARD.ASSOCIATED_PARAM DIFFCLK_BOARD_INTERFACE" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 lvds_clk CLK" *)
input wire lvds_clk_clk_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME lvds_clk, CAN_DEBUG false, FREQ_HZ 125000000, TYPE ETH_LVDS_CLK, BOARD.ASSOCIATED_PARAM DIFFCLK_BOARD_INTERFACE" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:diff_clock:1.0 lvds_clk CLK_P" *)
input wire lvds_clk_clk_p;

  bd_074d inst (
    .s_axi_lite_resetn(s_axi_lite_resetn),
    .s_axi_lite_clk(s_axi_lite_clk),
    .mac_irq(mac_irq),
    .tx_mac_aclk(tx_mac_aclk),
    .rx_mac_aclk(rx_mac_aclk),
    .tx_reset(tx_reset),
    .rx_reset(rx_reset),
    .glbl_rst(glbl_rst),
    .tx_ifg_delay(tx_ifg_delay),
    .status_vector(status_vector),
    .signal_detect(signal_detect),
    .clk125_out(clk125_out),
    .clk625_out(clk625_out),
    .clk208_out(clk208_out),
    .clk104_out(clk104_out),
    .rst_125_out(rst_125_out),
    .mmcm_locked_out(mmcm_locked_out),
	.mmcm_locked_out_end(mmcm_locked_out_end),
    .phy_rst_n(phy_rst_n),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arready(s_axi_arready),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awready(s_axi_awready),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_bready(s_axi_bready),
    .s_axi_bresp(s_axi_bresp),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_rready(s_axi_rready),
    .s_axi_rresp(s_axi_rresp),
    .s_axi_rvalid(s_axi_rvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_wready(s_axi_wready),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axis_tx_tdata(s_axis_tx_tdata),
    .s_axis_tx_tlast(s_axis_tx_tlast),
    .s_axis_tx_tready(s_axis_tx_tready),
    .s_axis_tx_tuser(s_axis_tx_tuser),
    .s_axis_tx_tvalid(s_axis_tx_tvalid),
    .m_axis_rx_tdata(m_axis_rx_tdata),
    .m_axis_rx_tlast(m_axis_rx_tlast),
    .m_axis_rx_tuser(m_axis_rx_tuser),
    .m_axis_rx_tvalid(m_axis_rx_tvalid),
    .s_axis_pause_tdata(s_axis_pause_tdata),
    .s_axis_pause_tvalid(s_axis_pause_tvalid),
    .rx_statistics_statistics_data(rx_statistics_statistics_data),
    .rx_statistics_statistics_valid(rx_statistics_statistics_valid),
    .tx_statistics_statistics_data(tx_statistics_statistics_data),
    .tx_statistics_statistics_valid(tx_statistics_statistics_valid),
    .sgmii_rxn(sgmii_rxn),
    .sgmii_rxp(sgmii_rxp),
    .sgmii_txn(sgmii_txn),
    .sgmii_txp(sgmii_txp),
    .mdio_mdc(mdio_mdc),
    .mdio_mdio_i(mdio_mdio_i),
    .mdio_mdio_o(mdio_mdio_o),
    .mdio_mdio_t(mdio_mdio_t),
    .lvds_clk_clk(lvds_clk_clk),
    .lvds_clk_clk_n(lvds_clk_clk_n),
    .lvds_clk_clk_p(lvds_clk_clk_p)
  );
endmodule
