// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 16 17:12:24 2022
// Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top SGMII_S_axi_ethernet -prefix
//               SGMII_S_axi_ethernet_ SGMII_S_axi_ethernet_stub.v
// Design      : SGMII_S_axi_ethernet
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bd_1953,Vivado 2018.3" *)
module SGMII_S_axi_ethernet(s_axi_lite_resetn, s_axi_lite_clk, mac_irq, 
  tx_mac_aclk, rx_mac_aclk, tx_reset, rx_reset, glbl_rst, tx_ifg_delay, status_vector, 
  signal_detect, clk125m, clk625, clk208, clk104, rst_125, mmcm_locked, phy_rst_n, s_axi_araddr, 
  s_axi_arready, s_axi_arvalid, s_axi_awaddr, s_axi_awready, s_axi_awvalid, s_axi_bready, 
  s_axi_bresp, s_axi_bvalid, s_axi_rdata, s_axi_rready, s_axi_rresp, s_axi_rvalid, s_axi_wdata, 
  s_axi_wready, s_axi_wvalid, s_axis_tx_tdata, s_axis_tx_tlast, s_axis_tx_tready, 
  s_axis_tx_tuser, s_axis_tx_tvalid, m_axis_rx_tdata, m_axis_rx_tlast, m_axis_rx_tuser, 
  m_axis_rx_tvalid, s_axis_pause_tdata, s_axis_pause_tvalid, 
  rx_statistics_statistics_data, rx_statistics_statistics_valid, 
  tx_statistics_statistics_data, tx_statistics_statistics_valid, sgmii_rxn, sgmii_rxp, 
  sgmii_txn, sgmii_txp, mdio_mdc, mdio_mdio_i, mdio_mdio_o, mdio_mdio_t)
/* synthesis syn_black_box black_box_pad_pin="s_axi_lite_resetn,s_axi_lite_clk,mac_irq,tx_mac_aclk,rx_mac_aclk,tx_reset,rx_reset,glbl_rst,tx_ifg_delay[7:0],status_vector[15:0],signal_detect,clk125m,clk625,clk208,clk104,rst_125,mmcm_locked,phy_rst_n[0:0],s_axi_araddr[11:0],s_axi_arready,s_axi_arvalid,s_axi_awaddr[11:0],s_axi_awready,s_axi_awvalid,s_axi_bready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_rdata[31:0],s_axi_rready,s_axi_rresp[1:0],s_axi_rvalid,s_axi_wdata[31:0],s_axi_wready,s_axi_wvalid,s_axis_tx_tdata[7:0],s_axis_tx_tlast,s_axis_tx_tready,s_axis_tx_tuser[0:0],s_axis_tx_tvalid,m_axis_rx_tdata[7:0],m_axis_rx_tlast,m_axis_rx_tuser,m_axis_rx_tvalid,s_axis_pause_tdata[15:0],s_axis_pause_tvalid,rx_statistics_statistics_data[27:0],rx_statistics_statistics_valid,tx_statistics_statistics_data[31:0],tx_statistics_statistics_valid,sgmii_rxn,sgmii_rxp,sgmii_txn,sgmii_txp,mdio_mdc,mdio_mdio_i,mdio_mdio_o,mdio_mdio_t" */;
  input s_axi_lite_resetn;
  input s_axi_lite_clk;
  output mac_irq;
  output tx_mac_aclk;
  output rx_mac_aclk;
  output tx_reset;
  output rx_reset;
  input glbl_rst;
  input [7:0]tx_ifg_delay;
  output [15:0]status_vector;
  input signal_detect;
  input clk125m;
  input clk625;
  input clk208;
  input clk104;
  input rst_125;
  input mmcm_locked;
  output [0:0]phy_rst_n;
  input [11:0]s_axi_araddr;
  output s_axi_arready;
  input s_axi_arvalid;
  input [11:0]s_axi_awaddr;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input s_axi_wvalid;
  input [7:0]s_axis_tx_tdata;
  input s_axis_tx_tlast;
  output s_axis_tx_tready;
  input [0:0]s_axis_tx_tuser;
  input s_axis_tx_tvalid;
  output [7:0]m_axis_rx_tdata;
  output m_axis_rx_tlast;
  output m_axis_rx_tuser;
  output m_axis_rx_tvalid;
  input [15:0]s_axis_pause_tdata;
  input s_axis_pause_tvalid;
  output [27:0]rx_statistics_statistics_data;
  output rx_statistics_statistics_valid;
  output [31:0]tx_statistics_statistics_data;
  output tx_statistics_statistics_valid;
  input sgmii_rxn;
  input sgmii_rxp;
  output sgmii_txn;
  output sgmii_txp;
  output mdio_mdc;
  input mdio_mdio_i;
  output mdio_mdio_o;
  output mdio_mdio_t;
endmodule
