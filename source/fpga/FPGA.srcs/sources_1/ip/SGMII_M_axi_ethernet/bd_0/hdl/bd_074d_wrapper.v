//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_074d_wrapper.bd
//Design : bd_074d_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_074d_wrapper
   (clk104_out,
    clk125_out,
    clk208_out,
    clk625_out,
    glbl_rst,
    lvds_clk_clk_n,
    lvds_clk_clk_p,
    m_axis_rx_tdata,
    m_axis_rx_tlast,
    m_axis_rx_tuser,
    m_axis_rx_tvalid,
    mac_irq,
    mdio_mdc,
    mdio_mdio_io,
    mmcm_locked_out,
    phy_rst_n,
    rst_125_out,
    rx_mac_aclk,
    rx_reset,
    rx_statistics_statistics_data,
    rx_statistics_statistics_valid,
    s_axi_araddr,
    s_axi_arready,
    s_axi_arvalid,
    s_axi_awaddr,
    s_axi_awready,
    s_axi_awvalid,
    s_axi_bready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_lite_clk,
    s_axi_lite_resetn,
    s_axi_rdata,
    s_axi_rready,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_wdata,
    s_axi_wready,
    s_axi_wvalid,
    s_axis_pause_tdata,
    s_axis_pause_tvalid,
    s_axis_tx_tdata,
    s_axis_tx_tlast,
    s_axis_tx_tready,
    s_axis_tx_tuser,
    s_axis_tx_tvalid,
    sgmii_rxn,
    sgmii_rxp,
    sgmii_txn,
    sgmii_txp,
    signal_detect,
    status_vector,
    tx_ifg_delay,
    tx_mac_aclk,
    tx_reset,
    tx_statistics_statistics_data,
    tx_statistics_statistics_valid);
  output clk104_out;
  output clk125_out;
  output clk208_out;
  output clk625_out;
  input glbl_rst;
  input lvds_clk_clk_n;
  input lvds_clk_clk_p;
  output [7:0]m_axis_rx_tdata;
  output m_axis_rx_tlast;
  output m_axis_rx_tuser;
  output m_axis_rx_tvalid;
  output mac_irq;
  output mdio_mdc;
  inout mdio_mdio_io;
  output mmcm_locked_out;
  output [0:0]phy_rst_n;
  output rst_125_out;
  output rx_mac_aclk;
  output rx_reset;
  output [27:0]rx_statistics_statistics_data;
  output rx_statistics_statistics_valid;
  input [11:0]s_axi_araddr;
  output s_axi_arready;
  input s_axi_arvalid;
  input [11:0]s_axi_awaddr;
  output s_axi_awready;
  input s_axi_awvalid;
  input s_axi_bready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_lite_clk;
  input s_axi_lite_resetn;
  output [31:0]s_axi_rdata;
  input s_axi_rready;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input [31:0]s_axi_wdata;
  output s_axi_wready;
  input s_axi_wvalid;
  input [15:0]s_axis_pause_tdata;
  input s_axis_pause_tvalid;
  input [7:0]s_axis_tx_tdata;
  input s_axis_tx_tlast;
  output s_axis_tx_tready;
  input [0:0]s_axis_tx_tuser;
  input s_axis_tx_tvalid;
  input sgmii_rxn;
  input sgmii_rxp;
  output sgmii_txn;
  output sgmii_txp;
  input signal_detect;
  output [15:0]status_vector;
  input [7:0]tx_ifg_delay;
  output tx_mac_aclk;
  output tx_reset;
  output [31:0]tx_statistics_statistics_data;
  output tx_statistics_statistics_valid;

  wire clk104_out;
  wire clk125_out;
  wire clk208_out;
  wire clk625_out;
  wire glbl_rst;
  wire lvds_clk_clk_n;
  wire lvds_clk_clk_p;
  wire [7:0]m_axis_rx_tdata;
  wire m_axis_rx_tlast;
  wire m_axis_rx_tuser;
  wire m_axis_rx_tvalid;
  wire mac_irq;
  wire mdio_mdc;
  wire mdio_mdio_i;
  wire mdio_mdio_io;
  wire mdio_mdio_o;
  wire mdio_mdio_t;
  wire mmcm_locked_out;
  wire [0:0]phy_rst_n;
  wire rst_125_out;
  wire rx_mac_aclk;
  wire rx_reset;
  wire [27:0]rx_statistics_statistics_data;
  wire rx_statistics_statistics_valid;
  wire [11:0]s_axi_araddr;
  wire s_axi_arready;
  wire s_axi_arvalid;
  wire [11:0]s_axi_awaddr;
  wire s_axi_awready;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire s_axi_lite_clk;
  wire s_axi_lite_resetn;
  wire [31:0]s_axi_rdata;
  wire s_axi_rready;
  wire [1:0]s_axi_rresp;
  wire s_axi_rvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire s_axi_wvalid;
  wire [15:0]s_axis_pause_tdata;
  wire s_axis_pause_tvalid;
  wire [7:0]s_axis_tx_tdata;
  wire s_axis_tx_tlast;
  wire s_axis_tx_tready;
  wire [0:0]s_axis_tx_tuser;
  wire s_axis_tx_tvalid;
  wire sgmii_rxn;
  wire sgmii_rxp;
  wire sgmii_txn;
  wire sgmii_txp;
  wire signal_detect;
  wire [15:0]status_vector;
  wire [7:0]tx_ifg_delay;
  wire tx_mac_aclk;
  wire tx_reset;
  wire [31:0]tx_statistics_statistics_data;
  wire tx_statistics_statistics_valid;

  bd_074d bd_074d_i
       (.clk104_out(clk104_out),
        .clk125_out(clk125_out),
        .clk208_out(clk208_out),
        .clk625_out(clk625_out),
        .glbl_rst(glbl_rst),
        .lvds_clk_clk_n(lvds_clk_clk_n),
        .lvds_clk_clk_p(lvds_clk_clk_p),
        .m_axis_rx_tdata(m_axis_rx_tdata),
        .m_axis_rx_tlast(m_axis_rx_tlast),
        .m_axis_rx_tuser(m_axis_rx_tuser),
        .m_axis_rx_tvalid(m_axis_rx_tvalid),
        .mac_irq(mac_irq),
        .mdio_mdc(mdio_mdc),
        .mdio_mdio_i(mdio_mdio_i),
        .mdio_mdio_o(mdio_mdio_o),
        .mdio_mdio_t(mdio_mdio_t),
        .mmcm_locked_out(mmcm_locked_out),
        .phy_rst_n(phy_rst_n),
        .rst_125_out(rst_125_out),
        .rx_mac_aclk(rx_mac_aclk),
        .rx_reset(rx_reset),
        .rx_statistics_statistics_data(rx_statistics_statistics_data),
        .rx_statistics_statistics_valid(rx_statistics_statistics_valid),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arready(s_axi_arready),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awready(s_axi_awready),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_lite_clk(s_axi_lite_clk),
        .s_axi_lite_resetn(s_axi_lite_resetn),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axis_pause_tdata(s_axis_pause_tdata),
        .s_axis_pause_tvalid(s_axis_pause_tvalid),
        .s_axis_tx_tdata(s_axis_tx_tdata),
        .s_axis_tx_tlast(s_axis_tx_tlast),
        .s_axis_tx_tready(s_axis_tx_tready),
        .s_axis_tx_tuser(s_axis_tx_tuser),
        .s_axis_tx_tvalid(s_axis_tx_tvalid),
        .sgmii_rxn(sgmii_rxn),
        .sgmii_rxp(sgmii_rxp),
        .sgmii_txn(sgmii_txn),
        .sgmii_txp(sgmii_txp),
        .signal_detect(signal_detect),
        .status_vector(status_vector),
        .tx_ifg_delay(tx_ifg_delay),
        .tx_mac_aclk(tx_mac_aclk),
        .tx_reset(tx_reset),
        .tx_statistics_statistics_data(tx_statistics_statistics_data),
        .tx_statistics_statistics_valid(tx_statistics_statistics_valid));
  IOBUF mdio_mdio_iobuf
       (.I(mdio_mdio_o),
        .IO(mdio_mdio_io),
        .O(mdio_mdio_i),
        .T(mdio_mdio_t));
endmodule
