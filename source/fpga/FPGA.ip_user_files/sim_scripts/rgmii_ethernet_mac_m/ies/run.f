-makelib ies_lib/xil_defaultlib -sv \
  "D:/vivado/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/vivado/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/vivado/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xbip_utils_v3_0_9 \
  "../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xbip_pipe_v3_0_5 \
  "../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/xbip_bram18k_v3_0_5 \
  "../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/mult_gen_v12_0_14 \
  "../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/axi_lite_ipif_v3_0_4 \
  "../../../ipstatic/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib ies_lib/tri_mode_ethernet_mac_v9_0_13 \
  "../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.v" \
-endlib
-makelib ies_lib/tri_mode_ethernet_mac_v9_0_13 \
  "../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/common/rgmii_ethernet_mac_m_block_reset_sync.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/common/rgmii_ethernet_mac_m_block_sync_block.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m_clk_en_gen.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/physical/rgmii_ethernet_mac_m_rgmii_v2_0_if.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m_block.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m_support.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m_support_clocking.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m_support_resets.v" \
  "../../../../New_NP_PJ.srcs/rgmii_ethernet_mac_m/ip/rgmii_ethernet_mac_m/synth/rgmii_ethernet_mac_m.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

