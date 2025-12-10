-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Fri Dec 16 17:12:24 2022
-- Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ SGMII_S_axi_ethernet_stub.vhdl
-- Design      : SGMII_S_axi_ethernet
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k325tffg676-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
    s_axi_lite_resetn : in STD_LOGIC;
    s_axi_lite_clk : in STD_LOGIC;
    mac_irq : out STD_LOGIC;
    tx_mac_aclk : out STD_LOGIC;
    rx_mac_aclk : out STD_LOGIC;
    tx_reset : out STD_LOGIC;
    rx_reset : out STD_LOGIC;
    glbl_rst : in STD_LOGIC;
    tx_ifg_delay : in STD_LOGIC_VECTOR ( 7 downto 0 );
    status_vector : out STD_LOGIC_VECTOR ( 15 downto 0 );
    signal_detect : in STD_LOGIC;
    clk125m : in STD_LOGIC;
    clk625 : in STD_LOGIC;
    clk208 : in STD_LOGIC;
    clk104 : in STD_LOGIC;
    rst_125 : in STD_LOGIC;
    mmcm_locked : in STD_LOGIC;
    phy_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_arready : out STD_LOGIC;
    s_axi_arvalid : in STD_LOGIC;
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 11 downto 0 );
    s_axi_awready : out STD_LOGIC;
    s_axi_awvalid : in STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_rdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_rready : in STD_LOGIC;
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rvalid : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_wready : out STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axis_tx_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axis_tx_tlast : in STD_LOGIC;
    s_axis_tx_tready : out STD_LOGIC;
    s_axis_tx_tuser : in STD_LOGIC_VECTOR ( 0 to 0 );
    s_axis_tx_tvalid : in STD_LOGIC;
    m_axis_rx_tdata : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_rx_tlast : out STD_LOGIC;
    m_axis_rx_tuser : out STD_LOGIC;
    m_axis_rx_tvalid : out STD_LOGIC;
    s_axis_pause_tdata : in STD_LOGIC_VECTOR ( 15 downto 0 );
    s_axis_pause_tvalid : in STD_LOGIC;
    rx_statistics_statistics_data : out STD_LOGIC_VECTOR ( 27 downto 0 );
    rx_statistics_statistics_valid : out STD_LOGIC;
    tx_statistics_statistics_data : out STD_LOGIC_VECTOR ( 31 downto 0 );
    tx_statistics_statistics_valid : out STD_LOGIC;
    sgmii_rxn : in STD_LOGIC;
    sgmii_rxp : in STD_LOGIC;
    sgmii_txn : out STD_LOGIC;
    sgmii_txp : out STD_LOGIC;
    mdio_mdc : out STD_LOGIC;
    mdio_mdio_i : in STD_LOGIC;
    mdio_mdio_o : out STD_LOGIC;
    mdio_mdio_t : out STD_LOGIC
  );

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "s_axi_lite_resetn,s_axi_lite_clk,mac_irq,tx_mac_aclk,rx_mac_aclk,tx_reset,rx_reset,glbl_rst,tx_ifg_delay[7:0],status_vector[15:0],signal_detect,clk125m,clk625,clk208,clk104,rst_125,mmcm_locked,phy_rst_n[0:0],s_axi_araddr[11:0],s_axi_arready,s_axi_arvalid,s_axi_awaddr[11:0],s_axi_awready,s_axi_awvalid,s_axi_bready,s_axi_bresp[1:0],s_axi_bvalid,s_axi_rdata[31:0],s_axi_rready,s_axi_rresp[1:0],s_axi_rvalid,s_axi_wdata[31:0],s_axi_wready,s_axi_wvalid,s_axis_tx_tdata[7:0],s_axis_tx_tlast,s_axis_tx_tready,s_axis_tx_tuser[0:0],s_axis_tx_tvalid,m_axis_rx_tdata[7:0],m_axis_rx_tlast,m_axis_rx_tuser,m_axis_rx_tvalid,s_axis_pause_tdata[15:0],s_axis_pause_tvalid,rx_statistics_statistics_data[27:0],rx_statistics_statistics_valid,tx_statistics_statistics_data[31:0],tx_statistics_statistics_valid,sgmii_rxn,sgmii_rxp,sgmii_txn,sgmii_txp,mdio_mdc,mdio_mdio_i,mdio_mdio_o,mdio_mdio_t";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bd_1953,Vivado 2018.3";
begin
end;
