-makelib xcelium_lib/xil_defaultlib -sv \
  "D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/xbip_utils_v3_0_9 \
  "../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_pipe_v3_0_5 \
  "../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_bram18k_v3_0_5 \
  "../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/mult_gen_v12_0_14 \
  "../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_lite_ipif_v3_0_4 \
  "../../../ipstatic/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/tri_mode_ethernet_mac_v9_0_13 \
  "../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.v" \
-endlib
-makelib xcelium_lib/tri_mode_ethernet_mac_v9_0_13 \
  "../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/common/bd_1953_mac_0_block_sync_block.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_axi4_lite_ipif_top.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_axi4_lite_ipif_wrapper.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/statistics/bd_1953_mac_0_vector_decode.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_block.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0.v" \
-endlib
-makelib xcelium_lib/gig_ethernet_pcs_pma_v16_1_5 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/gig_ethernet_pcs_pma_v16_1_5 \
  "../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/bd_1953_pcs_pma_0_reset_wtd_timer.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_adapt/bd_1953_pcs_pma_0_clk_gen.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_adapt/bd_1953_pcs_pma_0_johnson_cntr.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/bd_1953_pcs_pma_0_reset_sync.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_adapt/bd_1953_pcs_pma_0_rx_rate_adapt.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_adapt/bd_1953_pcs_pma_0_sgmii_adapt.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/bd_1953_pcs_pma_0_sync_block.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_adapt/bd_1953_pcs_pma_0_tx_rate_adapt.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_gearbox_10b_6b.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_gearbox_6b_10b.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_sgmii_eye_monitor.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_sgmii_phy_calibration.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_sgmii_comma_alignment.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_lvds_transceiver/bd_1953_pcs_pma_0_decode_8b10b_lut_base.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/sgmii_lvds_transceiver/bd_1953_pcs_pma_0_encode_8b10b_lut_base.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_sgmii_phy_iob.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_gpio_sgmii_top.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/lvds_transceiver/bd_1953_pcs_pma_0_lvds_transceiver.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/bd_1953_pcs_pma_0_block.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_1/synth/bd_1953_pcs_pma_0.v" \
-endlib
-makelib xcelium_lib/xlconstant_v1_1_5 \
  "../../../ipstatic/hdl/xlconstant_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_2/sim/bd_1953_xlconstant_phyadd_0.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_3/sim/bd_1953_xlconstant_config_vec_0.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_4/sim/bd_1953_xlconstant_config_val_0.v" \
-endlib
-makelib xcelium_lib/c_reg_fd_v12_0_5 \
  "../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_mux_bit_v12_0_5 \
  "../../../ipstatic/hdl/c_mux_bit_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_shift_ram_v12_0_12 \
  "../../../ipstatic/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_5/sim/bd_1953_c_shift_ram_0_0.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_wrapper_v3_0_4 \
  "../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_addsub_v3_0_5 \
  "../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_addsub_v3_0_5 \
  "../../../ipstatic/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_addsub_v12_0_12 \
  "../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_gate_bit_v12_0_5 \
  "../../../ipstatic/hdl/c_gate_bit_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_counter_v3_0_5 \
  "../../../ipstatic/hdl/xbip_counter_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_counter_binary_v12_0_12 \
  "../../../ipstatic/hdl/c_counter_binary_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_6/sim/bd_1953_c_counter_binary_0_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_7/sim/bd_1953_xlconstant_0_0.v" \
-endlib
-makelib xcelium_lib/util_vector_logic_v2_0_1 \
  "../../../ipstatic/hdl/util_vector_logic_v2_0_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_8/sim/bd_1953_util_vector_logic_0_0.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_9/sim/bd_1953_reset_inv_0.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/bd_0/sim/bd_1953.v" \
  "../../../../../IP/SGMII_S_axi_ethernet/sim/SGMII_S_axi_ethernet.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

