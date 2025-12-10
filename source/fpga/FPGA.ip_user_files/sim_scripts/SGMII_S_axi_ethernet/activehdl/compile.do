vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/xbip_utils_v3_0_9
vlib activehdl/xbip_pipe_v3_0_5
vlib activehdl/xbip_bram18k_v3_0_5
vlib activehdl/mult_gen_v12_0_14
vlib activehdl/axi_lite_ipif_v3_0_4
vlib activehdl/tri_mode_ethernet_mac_v9_0_13
vlib activehdl/gig_ethernet_pcs_pma_v16_1_5
vlib activehdl/xlconstant_v1_1_5
vlib activehdl/c_reg_fd_v12_0_5
vlib activehdl/c_mux_bit_v12_0_5
vlib activehdl/c_shift_ram_v12_0_12
vlib activehdl/xbip_dsp48_wrapper_v3_0_4
vlib activehdl/xbip_dsp48_addsub_v3_0_5
vlib activehdl/xbip_addsub_v3_0_5
vlib activehdl/c_addsub_v12_0_12
vlib activehdl/c_gate_bit_v12_0_5
vlib activehdl/xbip_counter_v3_0_5
vlib activehdl/c_counter_binary_v12_0_12
vlib activehdl/util_vector_logic_v2_0_1

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap xbip_utils_v3_0_9 activehdl/xbip_utils_v3_0_9
vmap xbip_pipe_v3_0_5 activehdl/xbip_pipe_v3_0_5
vmap xbip_bram18k_v3_0_5 activehdl/xbip_bram18k_v3_0_5
vmap mult_gen_v12_0_14 activehdl/mult_gen_v12_0_14
vmap axi_lite_ipif_v3_0_4 activehdl/axi_lite_ipif_v3_0_4
vmap tri_mode_ethernet_mac_v9_0_13 activehdl/tri_mode_ethernet_mac_v9_0_13
vmap gig_ethernet_pcs_pma_v16_1_5 activehdl/gig_ethernet_pcs_pma_v16_1_5
vmap xlconstant_v1_1_5 activehdl/xlconstant_v1_1_5
vmap c_reg_fd_v12_0_5 activehdl/c_reg_fd_v12_0_5
vmap c_mux_bit_v12_0_5 activehdl/c_mux_bit_v12_0_5
vmap c_shift_ram_v12_0_12 activehdl/c_shift_ram_v12_0_12
vmap xbip_dsp48_wrapper_v3_0_4 activehdl/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_5 activehdl/xbip_dsp48_addsub_v3_0_5
vmap xbip_addsub_v3_0_5 activehdl/xbip_addsub_v3_0_5
vmap c_addsub_v12_0_12 activehdl/c_addsub_v12_0_12
vmap c_gate_bit_v12_0_5 activehdl/c_gate_bit_v12_0_5
vmap xbip_counter_v3_0_5 activehdl/xbip_counter_v3_0_5
vmap c_counter_binary_v12_0_12 activehdl/c_counter_binary_v12_0_12
vmap util_vector_logic_v2_0_1 activehdl/util_vector_logic_v2_0_1

vlog -work xil_defaultlib  -sv2k12 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"D:/Xilinx/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_9 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_14 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work axi_lite_ipif_v3_0_4 -93 \
"../../../ipstatic/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \

vlog -work tri_mode_ethernet_mac_v9_0_13  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.v" \

vcom -work tri_mode_ethernet_mac_v9_0_13 -93 \
"../../../ipstatic/hdl/tri_mode_ethernet_mac_v9_0_rfs.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/common/bd_1953_mac_0_block_sync_block.v" \

vcom -work xil_defaultlib -93 \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_axi4_lite_ipif_top.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_axi4_lite_ipif_wrapper.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/statistics/bd_1953_mac_0_vector_decode.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0_block.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/synth/bd_1953_mac_0.v" \

vcom -work gig_ethernet_pcs_pma_v16_1_5 -93 \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.vhd" \

vlog -work gig_ethernet_pcs_pma_v16_1_5  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../ipstatic/hdl/gig_ethernet_pcs_pma_v16_1_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
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

vlog -work xlconstant_v1_1_5  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../ipstatic/hdl/xlconstant_v1_1_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_2/sim/bd_1953_xlconstant_phyadd_0.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_3/sim/bd_1953_xlconstant_config_vec_0.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_4/sim/bd_1953_xlconstant_config_val_0.v" \

vcom -work c_reg_fd_v12_0_5 -93 \
"../../../ipstatic/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work c_mux_bit_v12_0_5 -93 \
"../../../ipstatic/hdl/c_mux_bit_v12_0_vh_rfs.vhd" \

vcom -work c_shift_ram_v12_0_12 -93 \
"../../../ipstatic/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_5/sim/bd_1953_c_shift_ram_0_0.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_addsub_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_12 -93 \
"../../../ipstatic/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work c_gate_bit_v12_0_5 -93 \
"../../../ipstatic/hdl/c_gate_bit_v12_0_vh_rfs.vhd" \

vcom -work xbip_counter_v3_0_5 -93 \
"../../../ipstatic/hdl/xbip_counter_v3_0_vh_rfs.vhd" \

vcom -work c_counter_binary_v12_0_12 -93 \
"../../../ipstatic/hdl/c_counter_binary_v12_0_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_6/sim/bd_1953_c_counter_binary_0_0.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_7/sim/bd_1953_xlconstant_0_0.v" \

vlog -work util_vector_logic_v2_0_1  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../ipstatic/hdl/util_vector_logic_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_0/header_files" "+incdir+../../../../../IP/SGMII_S_axi_ethernet/header_files" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_8/sim/bd_1953_util_vector_logic_0_0.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/ip/ip_9/sim/bd_1953_reset_inv_0.v" \
"../../../../../IP/SGMII_S_axi_ethernet/bd_0/sim/bd_1953.v" \
"../../../../../IP/SGMII_S_axi_ethernet/sim/SGMII_S_axi_ethernet.v" \

vlog -work xil_defaultlib \
"glbl.v"

