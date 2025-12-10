// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 16 17:12:24 2022
// Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top SGMII_S_axi_ethernet -prefix
//               SGMII_S_axi_ethernet_ SGMII_S_axi_ethernet_sim_netlist.v
// Design      : SGMII_S_axi_ethernet
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "SGMII_S_axi_ethernet,bd_1953,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "bd_1953,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module SGMII_S_axi_ethernet
   (s_axi_lite_resetn,
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
    clk125m,
    clk625,
    clk208,
    clk104,
    rst_125,
    mmcm_locked,
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
    mdio_mdio_t);
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.s_axi_lite_resetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.s_axi_lite_resetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input s_axi_lite_resetn;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.s_axi_lite_clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.s_axi_lite_clk, FREQ_HZ 100000000, PHASE 0.000, ASSOCIATED_BUSIF s_axi, ASSOCIATED_RESET s_axi_lite_resetn, INSERT_VIP 0, ASSOCIATED_CLKEN CE" *) input s_axi_lite_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.mac_irq INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.mac_irq, SENSITIVITY EDGE_RISING, PortWidth 1" *) output mac_irq;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.tx_mac_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.tx_mac_aclk, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_1953_mac_0_tx_mac_aclk, ASSOCIATED_BUSIF s_axis_pause:s_axis_tx, ASSOCIATED_RESET tx_reset, INSERT_VIP 0" *) output tx_mac_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.rx_mac_aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.rx_mac_aclk, FREQ_HZ 125000000, PHASE 0.000, CLK_DOMAIN bd_1953_mac_0_rx_mac_aclk, ASSOCIATED_BUSIF m_axis_rx, ASSOCIATED_RESET rx_reset, INSERT_VIP 0" *) output rx_mac_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.tx_reset RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.tx_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) output tx_reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.rx_reset RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.rx_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) output rx_reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.glbl_rst RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.glbl_rst, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input glbl_rst;
  input [7:0]tx_ifg_delay;
  output [15:0]status_vector;
  input signal_detect;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk125m CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk125m, FREQ_HZ 125000000, PHASE 0, ASSOCIATED_RESET rst_125, INSERT_VIP 0" *) input clk125m;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk625 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk625, FREQ_HZ 625000000, PHASE 0, INSERT_VIP 0" *) input clk625;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk208 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk208, FREQ_HZ 208333333, PHASE 0, INSERT_VIP 0" *) input clk208;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.clk104 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.clk104, FREQ_HZ 104166666, PHASE 0, INSERT_VIP 0" *) input clk104;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.rst_125 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.rst_125, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input rst_125;
  input mmcm_locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.phy_rst_n RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.phy_rst_n, POLARITY ACTIVE_LOW, INSERT_VIP 0, BOARD.ASSOCIATED_PARAM PHYRST_BOARD_INTERFACE" *) output [0:0]phy_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *) input [11:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *) input [11:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *) input s_axi_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 12, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 0, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TDATA" *) input [7:0]s_axis_tx_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TLAST" *) input s_axis_tx_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TREADY" *) output s_axis_tx_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TUSER" *) input [0:0]s_axis_tx_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TVALID" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_tx, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 125000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_tx_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TDATA" *) output [7:0]m_axis_rx_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TLAST" *) output m_axis_rx_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TUSER" *) output m_axis_rx_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TVALID" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_rx, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 125000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_rx_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TDATA" *) input [15:0]s_axis_pause_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TVALID" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_pause, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 125000000, PHASE 0.000, LAYERED_METADATA undef, INSERT_VIP 0" *) input s_axis_pause_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_data" *) output [27:0]rx_statistics_statistics_data;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_valid" *) output rx_statistics_statistics_valid;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_data" *) output [31:0]tx_statistics_statistics_data;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_valid" *) output tx_statistics_statistics_valid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXN" *) input sgmii_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXP" *) input sgmii_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXN" *) output sgmii_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXP" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME sgmii, BOARD.ASSOCIATED_PARAM ETHERNET_BOARD_INTERFACE" *) output sgmii_txp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDC" *) output mdio_mdc;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_I" *) input mdio_mdio_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_O" *) output mdio_mdio_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_T" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME mdio, CAN_DEBUG false, BOARD.ASSOCIATED_PARAM MDIO_BOARD_INTERFACE" *) output mdio_mdio_t;

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

  (* HW_HANDOFF = "SGMII_S_axi_ethernet.hwdef" *) 
  SGMII_S_axi_ethernet_bd_1953 inst
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
endmodule

(* HW_HANDOFF = "SGMII_S_axi_ethernet.hwdef" *) 
module SGMII_S_axi_ethernet_bd_1953
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
    mdio_mdio_i,
    mdio_mdio_o,
    mdio_mdio_t,
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK104 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK104, CLK_DOMAIN bd_1953_clk104, FREQ_HZ 104166666, INSERT_VIP 0, PHASE 0" *) input clk104;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK125M CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK125M, ASSOCIATED_RESET rst_125, CLK_DOMAIN bd_1953_clk125m, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0" *) input clk125m;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK208 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK208, CLK_DOMAIN bd_1953_clk208, FREQ_HZ 208333333, INSERT_VIP 0, PHASE 0" *) input clk208;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.CLK625 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.CLK625, CLK_DOMAIN bd_1953_clk625, FREQ_HZ 625000000, INSERT_VIP 0, PHASE 0" *) input clk625;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.GLBL_RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.GLBL_RST, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input glbl_rst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis_rx, FREQ_HZ 125000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1" *) output [7:0]m_axis_rx_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TLAST" *) output m_axis_rx_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TUSER" *) output m_axis_rx_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis_rx TVALID" *) output m_axis_rx_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 INTR.MAC_IRQ INTERRUPT" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME INTR.MAC_IRQ, PortWidth 1, SENSITIVITY EDGE_RISING" *) output mac_irq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDC" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME mdio, CAN_DEBUG false" *) output mdio_mdc;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_I" *) input mdio_mdio_i;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_O" *) output mdio_mdio_o;
  (* X_INTERFACE_INFO = "xilinx.com:interface:mdio:1.0 mdio MDIO_T" *) output mdio_mdio_t;
  input mmcm_locked;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.PHY_RST_N RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.PHY_RST_N, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) output [0:0]phy_rst_n;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RST_125 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RST_125, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input rst_125;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.RX_MAC_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.RX_MAC_ACLK, ASSOCIATED_BUSIF m_axis_rx, ASSOCIATED_RESET rx_reset, CLK_DOMAIN bd_1953_mac_0_rx_mac_aclk, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) output rx_mac_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.RX_RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.RX_RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) output rx_reset;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_data" *) output [27:0]rx_statistics_statistics_data;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 rx_statistics statistics_valid" *) output rx_statistics_statistics_valid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi, ADDR_WIDTH 17, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 0, HAS_CACHE 0, HAS_LOCK 0, HAS_PROT 0, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 0, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 1, NUM_READ_OUTSTANDING 1, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 1, NUM_WRITE_THREADS 1, PHASE 0.000, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [11:0]s_axi_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARREADY" *) output s_axi_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi ARVALID" *) input s_axi_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWADDR" *) input [11:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BREADY" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.S_AXI_LITE_CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.S_AXI_LITE_CLK, ASSOCIATED_BUSIF s_axi, ASSOCIATED_CLKEN CE, ASSOCIATED_RESET s_axi_lite_resetn, CLK_DOMAIN bd_1953_s_axi_lite_clk, FREQ_HZ 100000000, INSERT_VIP 0, PHASE 0.000" *) input s_axi_lite_clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.S_AXI_LITE_RESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.S_AXI_LITE_RESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input s_axi_lite_resetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RDATA" *) output [31:0]s_axi_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RREADY" *) input s_axi_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RRESP" *) output [1:0]s_axi_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi RVALID" *) output s_axi_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi WVALID" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_pause, FREQ_HZ 125000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 2, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [15:0]s_axis_pause_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_pause TVALID" *) input s_axis_pause_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis_tx, FREQ_HZ 125000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 1" *) input [7:0]s_axis_tx_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TLAST" *) input s_axis_tx_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TREADY" *) output s_axis_tx_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TUSER" *) input [0:0]s_axis_tx_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis_tx TVALID" *) input s_axis_tx_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXN" *) input sgmii_rxn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii RXP" *) input sgmii_rxp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXN" *) output sgmii_txn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:sgmii:1.0 sgmii TXP" *) output sgmii_txp;
  input signal_detect;
  output [15:0]status_vector;
  input [7:0]tx_ifg_delay;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.TX_MAC_ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.TX_MAC_ACLK, ASSOCIATED_BUSIF s_axis_pause:s_axis_tx, ASSOCIATED_RESET tx_reset, CLK_DOMAIN bd_1953_mac_0_tx_mac_aclk, FREQ_HZ 125000000, INSERT_VIP 0, PHASE 0.000" *) output tx_mac_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.TX_RESET RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.TX_RESET, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) output tx_reset;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_data" *) output [31:0]tx_statistics_statistics_data;
  (* X_INTERFACE_INFO = "xilinx.com:display_tri_mode_ethernet_mac:statistics:1.0 tx_statistics statistics_valid" *) output tx_statistics_statistics_valid;

  wire c_counter_binary_0_THRESH0;
  wire clk104;
  wire clk125m;
  wire clk208;
  wire clk625;
  wire glbl_rst;
  wire [7:0]m_axis_rx_tdata;
  wire m_axis_rx_tlast;
  wire m_axis_rx_tuser;
  wire m_axis_rx_tvalid;
  wire [7:0]mac_gmii_RXD;
  wire mac_gmii_RX_DV;
  wire mac_gmii_RX_ER;
  wire [7:0]mac_gmii_TXD;
  wire mac_gmii_TX_EN;
  wire mac_gmii_TX_ER;
  wire mac_irq;
  wire mac_mdc;
  wire mac_mdio_o;
  wire mac_mdio_t;
  wire mac_speedis100;
  wire mac_speedis10100;
  wire mdio_mdc;
  wire mdio_mdio_i;
  wire mdio_mdio_o;
  wire mdio_mdio_t;
  wire mmcm_locked;
  wire pcs_pma_mdio_o;
  wire pcs_pma_sgmii_clk_en;
  wire [0:0]phy_rst_n;
  wire reset_inv_Res;
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
  wire util_vector_logic_0_Res;
  wire xlconstant_0_dout;
  wire xlconstant_config_val_dout;
  wire [4:0]xlconstant_config_vec_dout;
  wire [4:0]xlconstant_phyadd_dout;
  wire [23:0]NLW_c_counter_binary_0_Q_UNCONNECTED;
  wire [4:0]NLW_mac_rx_axis_filter_tuser_UNCONNECTED;
  wire NLW_pcs_pma_an_interrupt_UNCONNECTED;
  wire NLW_pcs_pma_gmii_isolate_UNCONNECTED;
  wire NLW_pcs_pma_mdio_t_UNCONNECTED;
  wire NLW_pcs_pma_sgmii_clk_f_UNCONNECTED;
  wire NLW_pcs_pma_sgmii_clk_r_UNCONNECTED;

  (* X_CORE_INFO = "c_counter_binary_v12_0_12,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_c_counter_binary_0_0 c_counter_binary_0
       (.CLK(s_axi_lite_clk),
        .Q(NLW_c_counter_binary_0_Q_UNCONNECTED[23:0]),
        .SCLR(util_vector_logic_0_Res),
        .THRESH0(c_counter_binary_0_THRESH0));
  (* X_CORE_INFO = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_c_shift_ram_0_0 c_shift_ram_0
       (.CE(c_counter_binary_0_THRESH0),
        .CLK(s_axi_lite_clk),
        .D(xlconstant_0_dout),
        .Q(phy_rst_n),
        .SCLR(util_vector_logic_0_Res));
  (* X_CORE_INFO = "bd_1953_mac_0_block,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_mac_0 mac
       (.clk_enable(pcs_pma_sgmii_clk_en),
        .glbl_rstn(reset_inv_Res),
        .gmii_rx_dv(mac_gmii_RX_DV),
        .gmii_rx_er(mac_gmii_RX_ER),
        .gmii_rxd(mac_gmii_RXD),
        .gmii_tx_en(mac_gmii_TX_EN),
        .gmii_tx_er(mac_gmii_TX_ER),
        .gmii_txd(mac_gmii_TXD),
        .gtx_clk(clk125m),
        .mac_irq(mac_irq),
        .mdc(mac_mdc),
        .mdio_i(pcs_pma_mdio_o),
        .mdio_o(mac_mdio_o),
        .mdio_t(mac_mdio_t),
        .pause_req(s_axis_pause_tvalid),
        .pause_val(s_axis_pause_tdata),
        .rx_axi_rstn(reset_inv_Res),
        .rx_axis_filter_tuser(NLW_mac_rx_axis_filter_tuser_UNCONNECTED[4:0]),
        .rx_axis_mac_tdata(m_axis_rx_tdata),
        .rx_axis_mac_tlast(m_axis_rx_tlast),
        .rx_axis_mac_tuser(m_axis_rx_tuser),
        .rx_axis_mac_tvalid(m_axis_rx_tvalid),
        .rx_mac_aclk(rx_mac_aclk),
        .rx_reset(rx_reset),
        .rx_statistics_valid(rx_statistics_statistics_valid),
        .rx_statistics_vector(rx_statistics_statistics_data),
        .s_axi_aclk(s_axi_lite_clk),
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
        .s_axi_resetn(s_axi_lite_resetn),
        .s_axi_rready(s_axi_rready),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wready(s_axi_wready),
        .s_axi_wvalid(s_axi_wvalid),
        .speedis100(mac_speedis100),
        .speedis10100(mac_speedis10100),
        .tx_axi_rstn(reset_inv_Res),
        .tx_axis_mac_tdata(s_axis_tx_tdata),
        .tx_axis_mac_tlast(s_axis_tx_tlast),
        .tx_axis_mac_tready(s_axis_tx_tready),
        .tx_axis_mac_tuser(s_axis_tx_tuser),
        .tx_axis_mac_tvalid(s_axis_tx_tvalid),
        .tx_ifg_delay(tx_ifg_delay),
        .tx_mac_aclk(tx_mac_aclk),
        .tx_reset(tx_reset),
        .tx_statistics_valid(tx_statistics_statistics_valid),
        .tx_statistics_vector(tx_statistics_statistics_data));
  SGMII_S_axi_ethernet_bd_1953_pcs_pma_0 pcs_pma
       (.an_adv_config_val(1'b0),
        .an_adv_config_vector({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .an_interrupt(NLW_pcs_pma_an_interrupt_UNCONNECTED),
        .an_restart_config(1'b0),
        .clk104(clk104),
        .clk125m(clk125m),
        .clk208(clk208),
        .clk625(clk625),
        .configuration_valid(xlconstant_config_val_dout),
        .configuration_vector(xlconstant_config_vec_dout),
        .ext_mdc(mdio_mdc),
        .ext_mdio_i(mdio_mdio_i),
        .ext_mdio_o(mdio_mdio_o),
        .ext_mdio_t(mdio_mdio_t),
        .gmii_isolate(NLW_pcs_pma_gmii_isolate_UNCONNECTED),
        .gmii_rx_dv(mac_gmii_RX_DV),
        .gmii_rx_er(mac_gmii_RX_ER),
        .gmii_rxd(mac_gmii_RXD),
        .gmii_tx_en(mac_gmii_TX_EN),
        .gmii_tx_er(mac_gmii_TX_ER),
        .gmii_txd(mac_gmii_TXD),
        .mdc(mac_mdc),
        .mdio_i(mac_mdio_o),
        .mdio_o(pcs_pma_mdio_o),
        .mdio_t(NLW_pcs_pma_mdio_t_UNCONNECTED),
        .mdio_t_in(mac_mdio_t),
        .mmcm_locked(mmcm_locked),
        .phyaddr(xlconstant_phyadd_dout),
        .reset(rst_125),
        .rxn(sgmii_rxn),
        .rxp(sgmii_rxp),
        .sgmii_clk_en(pcs_pma_sgmii_clk_en),
        .sgmii_clk_f(NLW_pcs_pma_sgmii_clk_f_UNCONNECTED),
        .sgmii_clk_r(NLW_pcs_pma_sgmii_clk_r_UNCONNECTED),
        .signal_detect(signal_detect),
        .speed_is_100(mac_speedis100),
        .speed_is_10_100(mac_speedis10100),
        .status_vector(status_vector),
        .txn(sgmii_txn),
        .txp(sgmii_txp));
  (* X_CORE_INFO = "util_vector_logic_v2_0_1_util_vector_logic,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_reset_inv_0 reset_inv
       (.Op1(glbl_rst),
        .Res(reset_inv_Res));
  (* X_CORE_INFO = "util_vector_logic_v2_0_1_util_vector_logic,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(s_axi_lite_resetn),
        .Res(util_vector_logic_0_Res));
  (* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_0_0,xlconstant_v1_1_5_xlconstant,{}" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  (* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_config_val_0,xlconstant_v1_1_5_xlconstant,{}" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_xlconstant_config_val_0 xlconstant_config_val
       (.dout(xlconstant_config_val_dout));
  (* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_config_vec_0,xlconstant_v1_1_5_xlconstant,{}" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_xlconstant_config_vec_0 xlconstant_config_vec
       (.dout(xlconstant_config_vec_dout));
  (* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_phyadd_0,xlconstant_v1_1_5_xlconstant,{}" *) 
  (* DowngradeIPIdentifiedWarnings = "yes" *) 
  (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
  SGMII_S_axi_ethernet_bd_1953_xlconstant_phyadd_0 xlconstant_phyadd
       (.dout(xlconstant_phyadd_dout));
endmodule

(* X_CORE_INFO = "c_counter_binary_v12_0_12,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_c_counter_binary_0_0
   (CLK,
    SCLR,
    THRESH0,
    Q);
  input CLK;
  input SCLR;
  output THRESH0;
  output [23:0]Q;


endmodule

(* X_CORE_INFO = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_c_shift_ram_0_0
   (D,
    CLK,
    CE,
    SCLR,
    Q);
  input [0:0]D;
  input CLK;
  input CE;
  input SCLR;
  output [0:0]Q;


endmodule

(* X_CORE_INFO = "bd_1953_mac_0_block,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_mac_0
   (gtx_clk,
    glbl_rstn,
    rx_axi_rstn,
    tx_axi_rstn,
    rx_statistics_vector,
    rx_statistics_valid,
    rx_mac_aclk,
    rx_reset,
    rx_axis_mac_tdata,
    rx_axis_mac_tvalid,
    rx_axis_mac_tlast,
    rx_axis_mac_tuser,
    rx_axis_filter_tuser,
    tx_ifg_delay,
    tx_statistics_vector,
    tx_statistics_valid,
    tx_mac_aclk,
    tx_reset,
    tx_axis_mac_tdata,
    tx_axis_mac_tvalid,
    tx_axis_mac_tlast,
    tx_axis_mac_tuser,
    tx_axis_mac_tready,
    pause_req,
    pause_val,
    clk_enable,
    speedis100,
    speedis10100,
    gmii_txd,
    gmii_tx_en,
    gmii_tx_er,
    gmii_rxd,
    gmii_rx_dv,
    gmii_rx_er,
    mdio_i,
    mdio_o,
    mdio_t,
    mdc,
    s_axi_aclk,
    s_axi_resetn,
    s_axi_awaddr,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_araddr,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rvalid,
    s_axi_rready,
    mac_irq);
  input gtx_clk;
  input glbl_rstn;
  input rx_axi_rstn;
  input tx_axi_rstn;
  output [27:0]rx_statistics_vector;
  output rx_statistics_valid;
  output rx_mac_aclk;
  output rx_reset;
  output [7:0]rx_axis_mac_tdata;
  output rx_axis_mac_tvalid;
  output rx_axis_mac_tlast;
  output rx_axis_mac_tuser;
  output [4:0]rx_axis_filter_tuser;
  input [7:0]tx_ifg_delay;
  output [31:0]tx_statistics_vector;
  output tx_statistics_valid;
  output tx_mac_aclk;
  output tx_reset;
  input [7:0]tx_axis_mac_tdata;
  input tx_axis_mac_tvalid;
  input tx_axis_mac_tlast;
  input tx_axis_mac_tuser;
  output tx_axis_mac_tready;
  input pause_req;
  input [15:0]pause_val;
  input clk_enable;
  output speedis100;
  output speedis10100;
  output [7:0]gmii_txd;
  output gmii_tx_en;
  output gmii_tx_er;
  input [7:0]gmii_rxd;
  input gmii_rx_dv;
  input gmii_rx_er;
  input mdio_i;
  output mdio_o;
  output mdio_t;
  output mdc;
  input s_axi_aclk;
  input s_axi_resetn;
  input [11:0]s_axi_awaddr;
  input s_axi_awvalid;
  output s_axi_awready;
  input [31:0]s_axi_wdata;
  input s_axi_wvalid;
  output s_axi_wready;
  output [1:0]s_axi_bresp;
  output s_axi_bvalid;
  input s_axi_bready;
  input [11:0]s_axi_araddr;
  input s_axi_arvalid;
  output s_axi_arready;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rvalid;
  input s_axi_rready;
  output mac_irq;


endmodule

module SGMII_S_axi_ethernet_bd_1953_pcs_pma_0
   (txp,
    txn,
    rxp,
    rxn,
    clk125m,
    clk625,
    clk208,
    clk104,
    mmcm_locked,
    sgmii_clk_r,
    sgmii_clk_f,
    sgmii_clk_en,
    speed_is_10_100,
    speed_is_100,
    gmii_txd,
    gmii_tx_en,
    gmii_tx_er,
    gmii_rxd,
    gmii_rx_dv,
    gmii_rx_er,
    gmii_isolate,
    ext_mdc,
    ext_mdio_i,
    ext_mdio_o,
    ext_mdio_t,
    mdio_t_in,
    mdc,
    mdio_i,
    mdio_o,
    mdio_t,
    phyaddr,
    configuration_vector,
    configuration_valid,
    an_interrupt,
    an_adv_config_vector,
    an_adv_config_val,
    an_restart_config,
    status_vector,
    reset,
    signal_detect);
  output txp;
  output txn;
  input rxp;
  input rxn;
  input clk125m;
  input clk625;
  input clk208;
  input clk104;
  input mmcm_locked;
  output sgmii_clk_r;
  output sgmii_clk_f;
  output sgmii_clk_en;
  input speed_is_10_100;
  input speed_is_100;
  input [7:0]gmii_txd;
  input gmii_tx_en;
  input gmii_tx_er;
  output [7:0]gmii_rxd;
  output gmii_rx_dv;
  output gmii_rx_er;
  output gmii_isolate;
  output ext_mdc;
  input ext_mdio_i;
  output ext_mdio_o;
  output ext_mdio_t;
  input mdio_t_in;
  input mdc;
  input mdio_i;
  output mdio_o;
  output mdio_t;
  input [4:0]phyaddr;
  input [4:0]configuration_vector;
  input configuration_valid;
  output an_interrupt;
  input [15:0]an_adv_config_vector;
  input an_adv_config_val;
  input an_restart_config;
  output [15:0]status_vector;
  input reset;
  input signal_detect;


endmodule

(* X_CORE_INFO = "util_vector_logic_v2_0_1_util_vector_logic,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_reset_inv_0
   (Op1,
    Res);
  input [0:0]Op1;
  output [0:0]Res;


endmodule

(* X_CORE_INFO = "util_vector_logic_v2_0_1_util_vector_logic,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_util_vector_logic_0_0
   (Op1,
    Res);
  input [0:0]Op1;
  output [0:0]Res;


endmodule

(* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_0_0,xlconstant_v1_1_5_xlconstant,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_xlconstant_0_0
   (dout);
  output [0:0]dout;

  wire \<const1> ;

  assign dout[0] = \<const1> ;
  VCC VCC
       (.P(\<const1> ));
endmodule

(* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_config_val_0,xlconstant_v1_1_5_xlconstant,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_xlconstant_config_val_0
   (dout);
  output [0:0]dout;

  wire \<const1> ;

  assign dout[0] = \<const1> ;
  VCC VCC
       (.P(\<const1> ));
endmodule

(* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_config_vec_0,xlconstant_v1_1_5_xlconstant,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_xlconstant_config_vec_0
   (dout);
  output [4:0]dout;

  wire \<const0> ;
  wire \<const1> ;

  assign dout[4] = \<const1> ;
  assign dout[3] = \<const0> ;
  assign dout[2] = \<const0> ;
  assign dout[1] = \<const0> ;
  assign dout[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
endmodule

(* CHECK_LICENSE_TYPE = "bd_1953_xlconstant_phyadd_0,xlconstant_v1_1_5_xlconstant,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "xlconstant_v1_1_5_xlconstant,Vivado 2018.3" *) 
module SGMII_S_axi_ethernet_bd_1953_xlconstant_phyadd_0
   (dout);
  output [4:0]dout;

  wire \<const0> ;
  wire \<const1> ;

  assign dout[4] = \<const0> ;
  assign dout[3] = \<const0> ;
  assign dout[2] = \<const0> ;
  assign dout[1] = \<const1> ;
  assign dout[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
