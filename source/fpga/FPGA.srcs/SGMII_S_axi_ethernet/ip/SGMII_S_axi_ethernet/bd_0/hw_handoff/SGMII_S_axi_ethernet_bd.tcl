
################################################################
# This is a generated script based on design: bd_1953
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source bd_1953_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7k325tffg676-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name bd_1953

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./bd_0

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_msg_id "BD_TCL-110" "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_msg_id "BD_TCL-008" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_msg_id "BD_TCL-009" "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-111" "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-010" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_msg_id "BD_TCL-112" "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_msg_id "BD_TCL-113" "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_msg_id "BD_TCL-011" "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir -bdsource SBD $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design -bdsource SBD $design_name} errmsg] } {
     common::send_msg_id "BD_TCL-012" "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set m_axis_rx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $m_axis_rx
  set mdio [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mdio_rtl:1.0 mdio ]
  set rx_statistics [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_tri_mode_ethernet_mac:statistics_rtl:1.0 rx_statistics ]
  set s_axi [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {17} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $s_axi
  set s_axis_pause [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $s_axis_pause
  set s_axis_tx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_tx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $s_axis_tx
  set sgmii [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:sgmii_rtl:1.0 sgmii ]
  set tx_statistics [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_tri_mode_ethernet_mac:statistics_rtl:1.0 tx_statistics ]

  # Create ports
  set clk104 [ create_bd_port -dir I -type clk clk104 ]
  set clk125m [ create_bd_port -dir I -type clk clk125m ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {rst_125} \
   CONFIG.FREQ_HZ {125000000} \
 ] $clk125m
  set clk208 [ create_bd_port -dir I -type clk clk208 ]
  set clk625 [ create_bd_port -dir I -type clk clk625 ]
  set glbl_rst [ create_bd_port -dir I -type rst glbl_rst ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $glbl_rst
  set mac_irq [ create_bd_port -dir O -type intr mac_irq ]
  set_property -dict [ list \
   CONFIG.SENSITIVITY {EDGE_RISING} \
 ] $mac_irq
  set mmcm_locked [ create_bd_port -dir I mmcm_locked ]
  set phy_rst_n [ create_bd_port -dir O -from 0 -to 0 -type rst phy_rst_n ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $phy_rst_n
  set rst_125 [ create_bd_port -dir I -type rst rst_125 ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $rst_125
  set rx_mac_aclk [ create_bd_port -dir O -type clk rx_mac_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m_axis_rx} \
   CONFIG.ASSOCIATED_RESET {rx_reset} \
   CONFIG.FREQ_HZ {125000000} \
 ] $rx_mac_aclk
  set rx_reset [ create_bd_port -dir O -type rst rx_reset ]
  set s_axi_lite_clk [ create_bd_port -dir I -type clk s_axi_lite_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi} \
   CONFIG.ASSOCIATED_RESET {s_axi_lite_resetn} \
 ] $s_axi_lite_clk
  set s_axi_lite_resetn [ create_bd_port -dir I -type rst s_axi_lite_resetn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $s_axi_lite_resetn
  set signal_detect [ create_bd_port -dir I signal_detect ]
  set status_vector [ create_bd_port -dir O -from 15 -to 0 status_vector ]
  set tx_ifg_delay [ create_bd_port -dir I -from 7 -to 0 tx_ifg_delay ]
  set tx_mac_aclk [ create_bd_port -dir O -type clk tx_mac_aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axis_pause:s_axis_tx} \
   CONFIG.ASSOCIATED_RESET {tx_reset} \
   CONFIG.FREQ_HZ {125000000} \
 ] $tx_mac_aclk
  set tx_reset [ create_bd_port -dir O -type rst tx_reset ]

  # Create instance: c_counter_binary_0, and set properties
  set c_counter_binary_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_counter_binary:12.0 c_counter_binary_0 ]
  set_property -dict [ list \
   CONFIG.Final_Count_Value {300000} \
   CONFIG.Increment_Value {1} \
   CONFIG.Output_Width {24} \
   CONFIG.Restrict_Count {true} \
   CONFIG.SCLR {true} \
   CONFIG.Sync_Threshold_Output {true} \
   CONFIG.Threshold_Value {300000} \
 ] $c_counter_binary_0

  # Create instance: c_shift_ram_0, and set properties
  set c_shift_ram_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:c_shift_ram:12.0 c_shift_ram_0 ]
  set_property -dict [ list \
   CONFIG.AsyncInitVal {0} \
   CONFIG.CE {true} \
   CONFIG.DefaultData {0} \
   CONFIG.Depth {1} \
   CONFIG.SCLR {true} \
   CONFIG.SyncInitVal {0} \
   CONFIG.Width {1} \
 ] $c_shift_ram_0

  # Create instance: mac, and set properties
  set mac [ create_bd_cell -type ip -vlnv xilinx.com:ip:tri_mode_ethernet_mac:9.0 mac ]
  set_property -dict [ list \
   CONFIG.Data_Rate {1_Gbps} \
   CONFIG.ETHERNET_BOARD_INTERFACE {Custom} \
   CONFIG.Enable_1588 {false} \
   CONFIG.Enable_1588_1step {false} \
   CONFIG.Enable_AVB {false} \
   CONFIG.Enable_MDIO {true} \
   CONFIG.Enable_Priority_Flow_Control {false} \
   CONFIG.Frame_Filter {true} \
   CONFIG.Half_Duplex {false} \
   CONFIG.Int_Mode_Type {SGMII} \
   CONFIG.MAC_Speed {Tri_speed} \
   CONFIG.MDIO_BOARD_INTERFACE {Custom} \
   CONFIG.MII_IO {true} \
   CONFIG.Make_MDIO_External {false} \
   CONFIG.Management_Interface {true} \
   CONFIG.Number_of_Table_Entries {4} \
   CONFIG.Physical_Interface {Internal} \
   CONFIG.RX_Inband_TS_Enable {false} \
   CONFIG.Statistics_Counters {true} \
   CONFIG.Statistics_Reset {false} \
   CONFIG.Statistics_Width {64bit} \
   CONFIG.SupportLevel {0} \
   CONFIG.TX_Inband_CF_Enable {false} \
   CONFIG.Timer_Format {Time_of_day} \
   CONFIG.USE_BOARD_FLOW {FALSE} \
 ] $mac

  # Create instance: pcs_pma, and set properties
  set pcs_pma [ create_bd_cell -type ip -vlnv xilinx.com:ip:gig_ethernet_pcs_pma:16.1 pcs_pma ]
  set_property -dict [ list \
   CONFIG.Auto_Negotiation {TRUE} \
   CONFIG.ClockSelection {Sync} \
   CONFIG.DIFFCLK_BOARD_INTERFACE {Custom} \
   CONFIG.DrpClkRate {50.0} \
   CONFIG.ETHERNET_BOARD_INTERFACE {Custom} \
   CONFIG.EXAMPLE_SIMULATION {0} \
   CONFIG.EnableAsyncSGMII {false} \
   CONFIG.Enable_1588 {false} \
   CONFIG.Ext_Management_Interface {true} \
   CONFIG.GT_Location {X0Y0} \
   CONFIG.GT_Type {GTH} \
   CONFIG.GTinEx {false} \
   CONFIG.InstantiateBitslice0 {false} \
   CONFIG.LvdsRefClk {125} \
   CONFIG.MDIO_BOARD_INTERFACE {Custom} \
   CONFIG.Management_Interface {TRUE} \
   CONFIG.MaxDataRate {1G} \
   CONFIG.NumOfLanes {1} \
   CONFIG.Physical_Interface {LVDS} \
   CONFIG.RefClkRate {125} \
   CONFIG.RefClkSrc {clk0} \
   CONFIG.RxLane0_Placement {DIFF_PAIR_0} \
   CONFIG.RxNibbleBitslice0Used {false} \
   CONFIG.SGMII_Mode {10_100_1000} \
   CONFIG.SGMII_PHY_Mode {FALSE} \
   CONFIG.Standard {SGMII} \
   CONFIG.SupportLevel {Include_Shared_Logic_in_Example_Design} \
   CONFIG.Timer_Format {Time_of_day} \
   CONFIG.TransceiverControl {false} \
   CONFIG.TxLane0_Placement {DIFF_PAIR_0} \
   CONFIG.Tx_In_Upper_Nibble {1} \
   CONFIG.USE_BOARD_FLOW {false} \
 ] $pcs_pma

  # Create instance: reset_inv, and set properties
  set reset_inv [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reset_inv ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
 ] $reset_inv

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_config_val, and set properties
  set xlconstant_config_val [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_config_val ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {1} \
   CONFIG.CONST_WIDTH {1} \
 ] $xlconstant_config_val

  # Create instance: xlconstant_config_vec, and set properties
  set xlconstant_config_vec [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_config_vec ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {16} \
   CONFIG.CONST_WIDTH {5} \
 ] $xlconstant_config_vec

  # Create instance: xlconstant_phyadd, and set properties
  set xlconstant_phyadd [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_phyadd ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {2} \
   CONFIG.CONST_WIDTH {5} \
 ] $xlconstant_phyadd

  # Create interface connections
  connect_bd_intf_net -intf_net mac_gmii [get_bd_intf_pins mac/gmii] [get_bd_intf_pins pcs_pma/gmii_pcs_pma]
  connect_bd_intf_net -intf_net mac_m_axis_rx [get_bd_intf_ports m_axis_rx] [get_bd_intf_pins mac/m_axis_rx]
  connect_bd_intf_net -intf_net mac_rx_statistics [get_bd_intf_ports rx_statistics] [get_bd_intf_pins mac/rx_statistics]
  connect_bd_intf_net -intf_net mac_tx_statistics [get_bd_intf_ports tx_statistics] [get_bd_intf_pins mac/tx_statistics]
  connect_bd_intf_net -intf_net pcs_pma_ext_mdio_pcs_pma [get_bd_intf_ports mdio] [get_bd_intf_pins pcs_pma/ext_mdio_pcs_pma]
  connect_bd_intf_net -intf_net pcs_pma_sgmii [get_bd_intf_ports sgmii] [get_bd_intf_pins pcs_pma/sgmii]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_ports s_axi] [get_bd_intf_pins mac/s_axi]
  connect_bd_intf_net -intf_net s_axis_pause_1 [get_bd_intf_ports s_axis_pause] [get_bd_intf_pins mac/s_axis_pause]
  connect_bd_intf_net -intf_net s_axis_tx_1 [get_bd_intf_ports s_axis_tx] [get_bd_intf_pins mac/s_axis_tx]

  # Create port connections
  connect_bd_net -net c_counter_binary_0_THRESH0 [get_bd_pins c_counter_binary_0/THRESH0] [get_bd_pins c_shift_ram_0/CE]
  connect_bd_net -net c_shift_ram_0_Q [get_bd_ports phy_rst_n] [get_bd_pins c_shift_ram_0/Q]
  connect_bd_net -net clk104_1 [get_bd_ports clk104] [get_bd_pins pcs_pma/clk104]
  connect_bd_net -net clk125m_1 [get_bd_ports clk125m] [get_bd_pins mac/gtx_clk] [get_bd_pins pcs_pma/clk125m]
  connect_bd_net -net clk208_1 [get_bd_ports clk208] [get_bd_pins pcs_pma/clk208]
  connect_bd_net -net clk625_1 [get_bd_ports clk625] [get_bd_pins pcs_pma/clk625]
  connect_bd_net -net glbl_rst_1 [get_bd_ports glbl_rst] [get_bd_pins reset_inv/Op1]
  connect_bd_net -net mac_mac_irq [get_bd_ports mac_irq] [get_bd_pins mac/mac_irq]
  connect_bd_net -net mac_mdc [get_bd_pins mac/mdc] [get_bd_pins pcs_pma/mdc]
  connect_bd_net -net mac_mdio_o [get_bd_pins mac/mdio_o] [get_bd_pins pcs_pma/mdio_i]
  connect_bd_net -net mac_mdio_t [get_bd_pins mac/mdio_t] [get_bd_pins pcs_pma/mdio_t_in]
  connect_bd_net -net mac_rx_mac_aclk [get_bd_ports rx_mac_aclk] [get_bd_pins mac/rx_mac_aclk]
  connect_bd_net -net mac_rx_reset [get_bd_ports rx_reset] [get_bd_pins mac/rx_reset]
  connect_bd_net -net mac_speedis100 [get_bd_pins mac/speedis100] [get_bd_pins pcs_pma/speed_is_100]
  connect_bd_net -net mac_speedis10100 [get_bd_pins mac/speedis10100] [get_bd_pins pcs_pma/speed_is_10_100]
  connect_bd_net -net mac_tx_mac_aclk [get_bd_ports tx_mac_aclk] [get_bd_pins mac/tx_mac_aclk]
  connect_bd_net -net mac_tx_reset [get_bd_ports tx_reset] [get_bd_pins mac/tx_reset]
  connect_bd_net -net mmcm_locked_1 [get_bd_ports mmcm_locked] [get_bd_pins pcs_pma/mmcm_locked]
  connect_bd_net -net pcs_pma_mdio_o [get_bd_pins mac/mdio_i] [get_bd_pins pcs_pma/mdio_o]
  connect_bd_net -net pcs_pma_sgmii_clk_en [get_bd_pins mac/clk_enable] [get_bd_pins pcs_pma/sgmii_clk_en]
  connect_bd_net -net pcs_pma_status_vector [get_bd_ports status_vector] [get_bd_pins pcs_pma/status_vector]
  connect_bd_net -net reset_inv_Res [get_bd_pins mac/glbl_rstn] [get_bd_pins mac/rx_axi_rstn] [get_bd_pins mac/tx_axi_rstn] [get_bd_pins reset_inv/Res]
  connect_bd_net -net rst_125_1 [get_bd_ports rst_125] [get_bd_pins pcs_pma/reset]
  connect_bd_net -net s_axi_lite_clk_1 [get_bd_ports s_axi_lite_clk] [get_bd_pins c_counter_binary_0/CLK] [get_bd_pins c_shift_ram_0/CLK] [get_bd_pins mac/s_axi_aclk]
  connect_bd_net -net s_axi_lite_resetn_1 [get_bd_ports s_axi_lite_resetn] [get_bd_pins mac/s_axi_resetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net signal_detect_1 [get_bd_ports signal_detect] [get_bd_pins pcs_pma/signal_detect]
  connect_bd_net -net tx_ifg_delay_1 [get_bd_ports tx_ifg_delay] [get_bd_pins mac/tx_ifg_delay]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins c_counter_binary_0/SCLR] [get_bd_pins c_shift_ram_0/SCLR] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins c_shift_ram_0/D] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_config_val_dout [get_bd_pins pcs_pma/configuration_valid] [get_bd_pins xlconstant_config_val/dout]
  connect_bd_net -net xlconstant_config_vec_dout [get_bd_pins pcs_pma/configuration_vector] [get_bd_pins xlconstant_config_vec/dout]
  connect_bd_net -net xlconstant_phyadd_dout [get_bd_pins pcs_pma/phyaddr] [get_bd_pins xlconstant_phyadd/dout]

  # Create address segments
  create_bd_addr_seg -range 0x00020000 -offset 0x00000000 [get_bd_addr_spaces s_axi] [get_bd_addr_segs mac/s_axi/Reg] SEG_mac_Reg


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


