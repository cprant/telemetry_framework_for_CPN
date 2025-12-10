-- (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:ip:axi_ethernet:7.1
-- IP Revision: 5

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT SGMII_M_axi_ethernet
  PORT (
    s_axi_lite_resetn : IN STD_LOGIC;
    s_axi_lite_clk : IN STD_LOGIC;
    mac_irq : OUT STD_LOGIC;
    tx_mac_aclk : OUT STD_LOGIC;
    rx_mac_aclk : OUT STD_LOGIC;
    tx_reset : OUT STD_LOGIC;
    rx_reset : OUT STD_LOGIC;
    glbl_rst : IN STD_LOGIC;
    tx_ifg_delay : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    status_vector : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal_detect : IN STD_LOGIC;
    clk125_out : OUT STD_LOGIC;
    clk625_out : OUT STD_LOGIC;
    clk208_out : OUT STD_LOGIC;
    clk104_out : OUT STD_LOGIC;
    rst_125_out : OUT STD_LOGIC;
    mmcm_locked_out : OUT STD_LOGIC;
    phy_rst_n : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    s_axi_araddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_arready : OUT STD_LOGIC;
    s_axi_arvalid : IN STD_LOGIC;
    s_axi_awaddr : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
    s_axi_awready : OUT STD_LOGIC;
    s_axi_awvalid : IN STD_LOGIC;
    s_axi_bready : IN STD_LOGIC;
    s_axi_bresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_bvalid : OUT STD_LOGIC;
    s_axi_rdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_rready : IN STD_LOGIC;
    s_axi_rresp : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_rvalid : OUT STD_LOGIC;
    s_axi_wdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_wready : OUT STD_LOGIC;
    s_axi_wvalid : IN STD_LOGIC;
    s_axis_tx_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    s_axis_tx_tlast : IN STD_LOGIC;
    s_axis_tx_tready : OUT STD_LOGIC;
    s_axis_tx_tuser : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    s_axis_tx_tvalid : IN STD_LOGIC;
    m_axis_rx_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_rx_tlast : OUT STD_LOGIC;
    m_axis_rx_tuser : OUT STD_LOGIC;
    m_axis_rx_tvalid : OUT STD_LOGIC;
    s_axis_pause_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    s_axis_pause_tvalid : IN STD_LOGIC;
    rx_statistics_statistics_data : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
    rx_statistics_statistics_valid : OUT STD_LOGIC;
    tx_statistics_statistics_data : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    tx_statistics_statistics_valid : OUT STD_LOGIC;
    sgmii_rxn : IN STD_LOGIC;
    sgmii_rxp : IN STD_LOGIC;
    sgmii_txn : OUT STD_LOGIC;
    sgmii_txp : OUT STD_LOGIC;
    mdio_mdc : OUT STD_LOGIC;
    mdio_mdio_i : IN STD_LOGIC;
    mdio_mdio_o : OUT STD_LOGIC;
    mdio_mdio_t : OUT STD_LOGIC;
    lvds_clk_clk_n : IN STD_LOGIC;
    lvds_clk_clk_p : IN STD_LOGIC
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : SGMII_M_axi_ethernet
  PORT MAP (
    s_axi_lite_resetn => s_axi_lite_resetn,
    s_axi_lite_clk => s_axi_lite_clk,
    mac_irq => mac_irq,
    tx_mac_aclk => tx_mac_aclk,
    rx_mac_aclk => rx_mac_aclk,
    tx_reset => tx_reset,
    rx_reset => rx_reset,
    glbl_rst => glbl_rst,
    tx_ifg_delay => tx_ifg_delay,
    status_vector => status_vector,
    signal_detect => signal_detect,
    clk125_out => clk125_out,
    clk625_out => clk625_out,
    clk208_out => clk208_out,
    clk104_out => clk104_out,
    rst_125_out => rst_125_out,
    mmcm_locked_out => mmcm_locked_out,
    phy_rst_n => phy_rst_n,
    s_axi_araddr => s_axi_araddr,
    s_axi_arready => s_axi_arready,
    s_axi_arvalid => s_axi_arvalid,
    s_axi_awaddr => s_axi_awaddr,
    s_axi_awready => s_axi_awready,
    s_axi_awvalid => s_axi_awvalid,
    s_axi_bready => s_axi_bready,
    s_axi_bresp => s_axi_bresp,
    s_axi_bvalid => s_axi_bvalid,
    s_axi_rdata => s_axi_rdata,
    s_axi_rready => s_axi_rready,
    s_axi_rresp => s_axi_rresp,
    s_axi_rvalid => s_axi_rvalid,
    s_axi_wdata => s_axi_wdata,
    s_axi_wready => s_axi_wready,
    s_axi_wvalid => s_axi_wvalid,
    s_axis_tx_tdata => s_axis_tx_tdata,
    s_axis_tx_tlast => s_axis_tx_tlast,
    s_axis_tx_tready => s_axis_tx_tready,
    s_axis_tx_tuser => s_axis_tx_tuser,
    s_axis_tx_tvalid => s_axis_tx_tvalid,
    m_axis_rx_tdata => m_axis_rx_tdata,
    m_axis_rx_tlast => m_axis_rx_tlast,
    m_axis_rx_tuser => m_axis_rx_tuser,
    m_axis_rx_tvalid => m_axis_rx_tvalid,
    s_axis_pause_tdata => s_axis_pause_tdata,
    s_axis_pause_tvalid => s_axis_pause_tvalid,
    rx_statistics_statistics_data => rx_statistics_statistics_data,
    rx_statistics_statistics_valid => rx_statistics_statistics_valid,
    tx_statistics_statistics_data => tx_statistics_statistics_data,
    tx_statistics_statistics_valid => tx_statistics_statistics_valid,
    sgmii_rxn => sgmii_rxn,
    sgmii_rxp => sgmii_rxp,
    sgmii_txn => sgmii_txn,
    sgmii_txp => sgmii_txp,
    mdio_mdc => mdio_mdc,
    mdio_mdio_i => mdio_mdio_i,
    mdio_mdio_o => mdio_mdio_o,
    mdio_mdio_t => mdio_mdio_t,
    lvds_clk_clk_n => lvds_clk_clk_n,
    lvds_clk_clk_p => lvds_clk_clk_p
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file SGMII_M_axi_ethernet.vhd when simulating
-- the core, SGMII_M_axi_ethernet. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

