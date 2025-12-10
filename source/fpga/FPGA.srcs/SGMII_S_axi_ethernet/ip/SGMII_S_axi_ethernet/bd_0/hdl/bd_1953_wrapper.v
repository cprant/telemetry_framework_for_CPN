//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_1953_wrapper.bd
//Design : bd_1953_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_1953_wrapper
   (clk104,
    clk125m,
    clk208,
    clk625,
    glbl_rst,
    m_axis_rx_tdata,
    m_axis_rx_tlast,
    m_axis_rx_tuser,
    m_axis_rx_tvalid,
    mac_irq,
    mdio_mdc,
    mdio_mdio_io,
    mmcm_locked,
    phy_rst_n,
    rst_125,
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
  input clk104;
  input clk125m;
  input clk208;
  input clk625;
  input glbl_rst;
  output [7:0]m_axis_rx_tdata;
  output m_axis_rx_tlast;
  output m_axis_rx_tuser;
  output m_axis_rx_tvalid;
  output mac_irq;
  output mdio_mdc;
  inout mdio_mdio_io;
  input mmcm_locked;
  output [0:0]phy_rst_n;
  input rst_125;
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

  wire clk104;
  wire clk125m;
  wire clk208;
  wire clk625;
  wire glbl_rst;
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
  wire mmcm_locked;
  wire [0:0]phy_rst_n;
  wire rst_125;
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

  bd_1953 bd_1953_i
       (.clk104(clk104),
        .clk125m(clk125m),
        .clk208(clk208),
        .clk625(clk625),
        .glbl_rst(glbl_rst),
        .m_axis_rx_tdata(m_axis_rx_tdata),
        .m_axis_rx_tlast(m_axis_rx_tlast),
        .m_axis_rx_tuser(m_axis_rx_tuser),
        .m_axis_rx_tvalid(m_axis_rx_tvalid),
        .mac_irq(mac_irq),
        .mdio_mdc(mdio_mdc),
        .mdio_mdio_i(mdio_mdio_i),
        .mdio_mdio_o(mdio_mdio_o),
        .mdio_mdio_t(mdio_mdio_t),
        .mmcm_locked(mmcm_locked),
        .phy_rst_n(phy_rst_n),
        .rst_125(rst_125),
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
