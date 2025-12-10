//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_1953.bd
//Design : bd_1953
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "bd_1953,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=bd_1953,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=10,numReposBlks=10,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=SBD,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "SGMII_S_axi_ethernet.hwdef" *) 
module bd_1953
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
  wire [0:0]c_shift_ram_0_Q;
  wire clk104_1;
  wire clk125m_1;
  wire clk208_1;
  wire clk625_1;
  wire glbl_rst_1;
  wire [7:0]mac_gmii_RXD;
  wire mac_gmii_RX_DV;
  wire mac_gmii_RX_ER;
  wire [7:0]mac_gmii_TXD;
  wire mac_gmii_TX_EN;
  wire mac_gmii_TX_ER;
  wire [7:0]mac_m_axis_rx_TDATA;
  wire mac_m_axis_rx_TLAST;
  wire mac_m_axis_rx_TUSER;
  wire mac_m_axis_rx_TVALID;
  wire mac_mac_irq;
  wire mac_mdc;
  wire mac_mdio_o;
  wire mac_mdio_t;
  wire mac_rx_mac_aclk;
  wire mac_rx_reset;
  wire [27:0]mac_rx_statistics_statistics_data;
  wire mac_rx_statistics_statistics_valid;
  wire mac_speedis100;
  wire mac_speedis10100;
  wire mac_tx_mac_aclk;
  wire mac_tx_reset;
  wire [31:0]mac_tx_statistics_statistics_data;
  wire mac_tx_statistics_statistics_valid;
  wire mmcm_locked_1;
  wire pcs_pma_ext_mdio_pcs_pma_MDC;
  wire pcs_pma_ext_mdio_pcs_pma_MDIO_I;
  wire pcs_pma_ext_mdio_pcs_pma_MDIO_O;
  wire pcs_pma_ext_mdio_pcs_pma_MDIO_T;
  wire pcs_pma_mdio_o;
  wire pcs_pma_sgmii_RXN;
  wire pcs_pma_sgmii_RXP;
  wire pcs_pma_sgmii_TXN;
  wire pcs_pma_sgmii_TXP;
  wire pcs_pma_sgmii_clk_en;
  wire [15:0]pcs_pma_status_vector;
  wire [0:0]reset_inv_Res;
  wire rst_125_1;
  wire [11:0]s_axi_1_ARADDR;
  wire s_axi_1_ARREADY;
  wire s_axi_1_ARVALID;
  wire [11:0]s_axi_1_AWADDR;
  wire s_axi_1_AWREADY;
  wire s_axi_1_AWVALID;
  wire s_axi_1_BREADY;
  wire [1:0]s_axi_1_BRESP;
  wire s_axi_1_BVALID;
  wire [31:0]s_axi_1_RDATA;
  wire s_axi_1_RREADY;
  wire [1:0]s_axi_1_RRESP;
  wire s_axi_1_RVALID;
  wire [31:0]s_axi_1_WDATA;
  wire s_axi_1_WREADY;
  wire s_axi_1_WVALID;
  wire s_axi_lite_clk_1;
  wire s_axi_lite_resetn_1;
  wire [15:0]s_axis_pause_1_TDATA;
  wire s_axis_pause_1_TVALID;
  wire [7:0]s_axis_tx_1_TDATA;
  wire s_axis_tx_1_TLAST;
  wire s_axis_tx_1_TREADY;
  wire [0:0]s_axis_tx_1_TUSER;
  wire s_axis_tx_1_TVALID;
  wire signal_detect_1;
  wire [7:0]tx_ifg_delay_1;
  wire [0:0]util_vector_logic_0_Res;
  wire [0:0]xlconstant_0_dout;
  wire [0:0]xlconstant_config_val_dout;
  wire [4:0]xlconstant_config_vec_dout;
  wire [4:0]xlconstant_phyadd_dout;

  assign clk104_1 = clk104;
  assign clk125m_1 = clk125m;
  assign clk208_1 = clk208;
  assign clk625_1 = clk625;
  assign glbl_rst_1 = glbl_rst;
  assign m_axis_rx_tdata[7:0] = mac_m_axis_rx_TDATA;
  assign m_axis_rx_tlast = mac_m_axis_rx_TLAST;
  assign m_axis_rx_tuser = mac_m_axis_rx_TUSER;
  assign m_axis_rx_tvalid = mac_m_axis_rx_TVALID;
  assign mac_irq = mac_mac_irq;
  assign mdio_mdc = pcs_pma_ext_mdio_pcs_pma_MDC;
  assign mdio_mdio_o = pcs_pma_ext_mdio_pcs_pma_MDIO_O;
  assign mdio_mdio_t = pcs_pma_ext_mdio_pcs_pma_MDIO_T;
  assign mmcm_locked_1 = mmcm_locked;
  assign pcs_pma_ext_mdio_pcs_pma_MDIO_I = mdio_mdio_i;
  assign pcs_pma_sgmii_RXN = sgmii_rxn;
  assign pcs_pma_sgmii_RXP = sgmii_rxp;
  assign phy_rst_n[0] = c_shift_ram_0_Q;
  assign rst_125_1 = rst_125;
  assign rx_mac_aclk = mac_rx_mac_aclk;
  assign rx_reset = mac_rx_reset;
  assign rx_statistics_statistics_data[27:0] = mac_rx_statistics_statistics_data;
  assign rx_statistics_statistics_valid = mac_rx_statistics_statistics_valid;
  assign s_axi_1_ARADDR = s_axi_araddr[11:0];
  assign s_axi_1_ARVALID = s_axi_arvalid;
  assign s_axi_1_AWADDR = s_axi_awaddr[11:0];
  assign s_axi_1_AWVALID = s_axi_awvalid;
  assign s_axi_1_BREADY = s_axi_bready;
  assign s_axi_1_RREADY = s_axi_rready;
  assign s_axi_1_WDATA = s_axi_wdata[31:0];
  assign s_axi_1_WVALID = s_axi_wvalid;
  assign s_axi_arready = s_axi_1_ARREADY;
  assign s_axi_awready = s_axi_1_AWREADY;
  assign s_axi_bresp[1:0] = s_axi_1_BRESP;
  assign s_axi_bvalid = s_axi_1_BVALID;
  assign s_axi_lite_clk_1 = s_axi_lite_clk;
  assign s_axi_lite_resetn_1 = s_axi_lite_resetn;
  assign s_axi_rdata[31:0] = s_axi_1_RDATA;
  assign s_axi_rresp[1:0] = s_axi_1_RRESP;
  assign s_axi_rvalid = s_axi_1_RVALID;
  assign s_axi_wready = s_axi_1_WREADY;
  assign s_axis_pause_1_TDATA = s_axis_pause_tdata[15:0];
  assign s_axis_pause_1_TVALID = s_axis_pause_tvalid;
  assign s_axis_tx_1_TDATA = s_axis_tx_tdata[7:0];
  assign s_axis_tx_1_TLAST = s_axis_tx_tlast;
  assign s_axis_tx_1_TUSER = s_axis_tx_tuser[0];
  assign s_axis_tx_1_TVALID = s_axis_tx_tvalid;
  assign s_axis_tx_tready = s_axis_tx_1_TREADY;
  assign sgmii_txn = pcs_pma_sgmii_TXN;
  assign sgmii_txp = pcs_pma_sgmii_TXP;
  assign signal_detect_1 = signal_detect;
  assign status_vector[15:0] = pcs_pma_status_vector;
  assign tx_ifg_delay_1 = tx_ifg_delay[7:0];
  assign tx_mac_aclk = mac_tx_mac_aclk;
  assign tx_reset = mac_tx_reset;
  assign tx_statistics_statistics_data[31:0] = mac_tx_statistics_statistics_data;
  assign tx_statistics_statistics_valid = mac_tx_statistics_statistics_valid;
  bd_1953_c_counter_binary_0_0 c_counter_binary_0
       (.CLK(s_axi_lite_clk_1),
        .SCLR(util_vector_logic_0_Res),
        .THRESH0(c_counter_binary_0_THRESH0));
  bd_1953_c_shift_ram_0_0 c_shift_ram_0
       (.CE(c_counter_binary_0_THRESH0),
        .CLK(s_axi_lite_clk_1),
        .D(xlconstant_0_dout),
        .Q(c_shift_ram_0_Q),
        .SCLR(util_vector_logic_0_Res));
  bd_1953_mac_0 mac
       (.clk_enable(pcs_pma_sgmii_clk_en),
        .glbl_rstn(reset_inv_Res),
        .gmii_rx_dv(mac_gmii_RX_DV),
        .gmii_rx_er(mac_gmii_RX_ER),
        .gmii_rxd(mac_gmii_RXD),
        .gmii_tx_en(mac_gmii_TX_EN),
        .gmii_tx_er(mac_gmii_TX_ER),
        .gmii_txd(mac_gmii_TXD),
        .gtx_clk(clk125m_1),
        .mac_irq(mac_mac_irq),
        .mdc(mac_mdc),
        .mdio_i(pcs_pma_mdio_o),
        .mdio_o(mac_mdio_o),
        .mdio_t(mac_mdio_t),
        .pause_req(s_axis_pause_1_TVALID),
        .pause_val(s_axis_pause_1_TDATA),
        .rx_axi_rstn(reset_inv_Res),
        .rx_axis_mac_tdata(mac_m_axis_rx_TDATA),
        .rx_axis_mac_tlast(mac_m_axis_rx_TLAST),
        .rx_axis_mac_tuser(mac_m_axis_rx_TUSER),
        .rx_axis_mac_tvalid(mac_m_axis_rx_TVALID),
        .rx_mac_aclk(mac_rx_mac_aclk),
        .rx_reset(mac_rx_reset),
        .rx_statistics_valid(mac_rx_statistics_statistics_valid),
        .rx_statistics_vector(mac_rx_statistics_statistics_data),
        .s_axi_aclk(s_axi_lite_clk_1),
        .s_axi_araddr(s_axi_1_ARADDR),
        .s_axi_arready(s_axi_1_ARREADY),
        .s_axi_arvalid(s_axi_1_ARVALID),
        .s_axi_awaddr(s_axi_1_AWADDR),
        .s_axi_awready(s_axi_1_AWREADY),
        .s_axi_awvalid(s_axi_1_AWVALID),
        .s_axi_bready(s_axi_1_BREADY),
        .s_axi_bresp(s_axi_1_BRESP),
        .s_axi_bvalid(s_axi_1_BVALID),
        .s_axi_rdata(s_axi_1_RDATA),
        .s_axi_resetn(s_axi_lite_resetn_1),
        .s_axi_rready(s_axi_1_RREADY),
        .s_axi_rresp(s_axi_1_RRESP),
        .s_axi_rvalid(s_axi_1_RVALID),
        .s_axi_wdata(s_axi_1_WDATA),
        .s_axi_wready(s_axi_1_WREADY),
        .s_axi_wvalid(s_axi_1_WVALID),
        .speedis100(mac_speedis100),
        .speedis10100(mac_speedis10100),
        .tx_axi_rstn(reset_inv_Res),
        .tx_axis_mac_tdata(s_axis_tx_1_TDATA),
        .tx_axis_mac_tlast(s_axis_tx_1_TLAST),
        .tx_axis_mac_tready(s_axis_tx_1_TREADY),
        .tx_axis_mac_tuser(s_axis_tx_1_TUSER),
        .tx_axis_mac_tvalid(s_axis_tx_1_TVALID),
        .tx_ifg_delay(tx_ifg_delay_1),
        .tx_mac_aclk(mac_tx_mac_aclk),
        .tx_reset(mac_tx_reset),
        .tx_statistics_valid(mac_tx_statistics_statistics_valid),
        .tx_statistics_vector(mac_tx_statistics_statistics_data));
  bd_1953_pcs_pma_0 pcs_pma
       (.an_adv_config_val(1'b0),
        .an_adv_config_vector({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .an_restart_config(1'b0),
        .clk104(clk104_1),
        .clk125m(clk125m_1),
        .clk208(clk208_1),
        .clk625(clk625_1),
        .configuration_valid(xlconstant_config_val_dout),
        .configuration_vector(xlconstant_config_vec_dout),
        .ext_mdc(pcs_pma_ext_mdio_pcs_pma_MDC),
        .ext_mdio_i(pcs_pma_ext_mdio_pcs_pma_MDIO_I),
        .ext_mdio_o(pcs_pma_ext_mdio_pcs_pma_MDIO_O),
        .ext_mdio_t(pcs_pma_ext_mdio_pcs_pma_MDIO_T),
        .gmii_rx_dv(mac_gmii_RX_DV),
        .gmii_rx_er(mac_gmii_RX_ER),
        .gmii_rxd(mac_gmii_RXD),
        .gmii_tx_en(mac_gmii_TX_EN),
        .gmii_tx_er(mac_gmii_TX_ER),
        .gmii_txd(mac_gmii_TXD),
        .mdc(mac_mdc),
        .mdio_i(mac_mdio_o),
        .mdio_o(pcs_pma_mdio_o),
        .mdio_t_in(mac_mdio_t),
        .mmcm_locked(mmcm_locked_1),
        .phyaddr(xlconstant_phyadd_dout),
        .reset(rst_125_1),
        .rxn(pcs_pma_sgmii_RXN),
        .rxp(pcs_pma_sgmii_RXP),
        .sgmii_clk_en(pcs_pma_sgmii_clk_en),
        .signal_detect(signal_detect_1),
        .speed_is_100(mac_speedis100),
        .speed_is_10_100(mac_speedis10100),
        .status_vector(pcs_pma_status_vector),
        .txn(pcs_pma_sgmii_TXN),
        .txp(pcs_pma_sgmii_TXP));
  bd_1953_reset_inv_0 reset_inv
       (.Op1(glbl_rst_1),
        .Res(reset_inv_Res));
  bd_1953_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(s_axi_lite_resetn_1),
        .Res(util_vector_logic_0_Res));
  bd_1953_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  bd_1953_xlconstant_config_val_0 xlconstant_config_val
       (.dout(xlconstant_config_val_dout));
  bd_1953_xlconstant_config_vec_0 xlconstant_config_vec
       (.dout(xlconstant_config_vec_dout));
  bd_1953_xlconstant_phyadd_0 xlconstant_phyadd
       (.dout(xlconstant_phyadd_dout));
endmodule
