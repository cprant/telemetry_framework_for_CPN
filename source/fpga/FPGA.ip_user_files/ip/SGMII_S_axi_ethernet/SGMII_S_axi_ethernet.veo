// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
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

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
SGMII_S_axi_ethernet your_instance_name (
  .s_axi_lite_resetn(s_axi_lite_resetn),                            // input wire s_axi_lite_resetn
  .s_axi_lite_clk(s_axi_lite_clk),                                  // input wire s_axi_lite_clk
  .mac_irq(mac_irq),                                                // output wire mac_irq
  .tx_mac_aclk(tx_mac_aclk),                                        // output wire tx_mac_aclk
  .rx_mac_aclk(rx_mac_aclk),                                        // output wire rx_mac_aclk
  .tx_reset(tx_reset),                                              // output wire tx_reset
  .rx_reset(rx_reset),                                              // output wire rx_reset
  .glbl_rst(glbl_rst),                                              // input wire glbl_rst
  .tx_ifg_delay(tx_ifg_delay),                                      // input wire [7 : 0] tx_ifg_delay
  .status_vector(status_vector),                                    // output wire [15 : 0] status_vector
  .signal_detect(signal_detect),                                    // input wire signal_detect
  .clk125m(clk125m),                                                // input wire clk125m
  .clk625(clk625),                                                  // input wire clk625
  .clk208(clk208),                                                  // input wire clk208
  .clk104(clk104),                                                  // input wire clk104
  .rst_125(rst_125),                                                // input wire rst_125
  .mmcm_locked(mmcm_locked),                                        // input wire mmcm_locked
  .phy_rst_n(phy_rst_n),                                            // output wire [0 : 0] phy_rst_n
  .s_axi_araddr(s_axi_araddr),                                      // input wire [11 : 0] s_axi_araddr
  .s_axi_arready(s_axi_arready),                                    // output wire s_axi_arready
  .s_axi_arvalid(s_axi_arvalid),                                    // input wire s_axi_arvalid
  .s_axi_awaddr(s_axi_awaddr),                                      // input wire [11 : 0] s_axi_awaddr
  .s_axi_awready(s_axi_awready),                                    // output wire s_axi_awready
  .s_axi_awvalid(s_axi_awvalid),                                    // input wire s_axi_awvalid
  .s_axi_bready(s_axi_bready),                                      // input wire s_axi_bready
  .s_axi_bresp(s_axi_bresp),                                        // output wire [1 : 0] s_axi_bresp
  .s_axi_bvalid(s_axi_bvalid),                                      // output wire s_axi_bvalid
  .s_axi_rdata(s_axi_rdata),                                        // output wire [31 : 0] s_axi_rdata
  .s_axi_rready(s_axi_rready),                                      // input wire s_axi_rready
  .s_axi_rresp(s_axi_rresp),                                        // output wire [1 : 0] s_axi_rresp
  .s_axi_rvalid(s_axi_rvalid),                                      // output wire s_axi_rvalid
  .s_axi_wdata(s_axi_wdata),                                        // input wire [31 : 0] s_axi_wdata
  .s_axi_wready(s_axi_wready),                                      // output wire s_axi_wready
  .s_axi_wvalid(s_axi_wvalid),                                      // input wire s_axi_wvalid
  .s_axis_tx_tdata(s_axis_tx_tdata),                                // input wire [7 : 0] s_axis_tx_tdata
  .s_axis_tx_tlast(s_axis_tx_tlast),                                // input wire s_axis_tx_tlast
  .s_axis_tx_tready(s_axis_tx_tready),                              // output wire s_axis_tx_tready
  .s_axis_tx_tuser(s_axis_tx_tuser),                                // input wire [0 : 0] s_axis_tx_tuser
  .s_axis_tx_tvalid(s_axis_tx_tvalid),                              // input wire s_axis_tx_tvalid
  .m_axis_rx_tdata(m_axis_rx_tdata),                                // output wire [7 : 0] m_axis_rx_tdata
  .m_axis_rx_tlast(m_axis_rx_tlast),                                // output wire m_axis_rx_tlast
  .m_axis_rx_tuser(m_axis_rx_tuser),                                // output wire m_axis_rx_tuser
  .m_axis_rx_tvalid(m_axis_rx_tvalid),                              // output wire m_axis_rx_tvalid
  .s_axis_pause_tdata(s_axis_pause_tdata),                          // input wire [15 : 0] s_axis_pause_tdata
  .s_axis_pause_tvalid(s_axis_pause_tvalid),                        // input wire s_axis_pause_tvalid
  .rx_statistics_statistics_data(rx_statistics_statistics_data),    // output wire [27 : 0] rx_statistics_statistics_data
  .rx_statistics_statistics_valid(rx_statistics_statistics_valid),  // output wire rx_statistics_statistics_valid
  .tx_statistics_statistics_data(tx_statistics_statistics_data),    // output wire [31 : 0] tx_statistics_statistics_data
  .tx_statistics_statistics_valid(tx_statistics_statistics_valid),  // output wire tx_statistics_statistics_valid
  .sgmii_rxn(sgmii_rxn),                                            // input wire sgmii_rxn
  .sgmii_rxp(sgmii_rxp),                                            // input wire sgmii_rxp
  .sgmii_txn(sgmii_txn),                                            // output wire sgmii_txn
  .sgmii_txp(sgmii_txp),                                            // output wire sgmii_txp
  .mdio_mdc(mdio_mdc),                                              // output wire mdio_mdc
  .mdio_mdio_i(mdio_mdio_i),                                        // input wire mdio_mdio_i
  .mdio_mdio_o(mdio_mdio_o),                                        // output wire mdio_mdio_o
  .mdio_mdio_t(mdio_mdio_t)                                        // output wire mdio_mdio_t
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file SGMII_S_axi_ethernet.v when simulating
// the core, SGMII_S_axi_ethernet. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.

