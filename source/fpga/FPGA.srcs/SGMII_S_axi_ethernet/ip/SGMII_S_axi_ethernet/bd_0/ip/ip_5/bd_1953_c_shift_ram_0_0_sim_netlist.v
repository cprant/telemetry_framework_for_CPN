// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 16 17:10:08 2022
// Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top bd_1953_c_shift_ram_0_0 -prefix
//               bd_1953_c_shift_ram_0_0_ bd_1953_c_shift_ram_0_0_sim_netlist.v
// Design      : bd_1953_c_shift_ram_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_1953_c_shift_ram_0_0,c_shift_ram_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module bd_1953_c_shift_ram_0_0
   (D,
    CLK,
    CE,
    SCLR,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [0:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:clockenable:1.0 ce_intf CE" *) (* x_interface_parameter = "XIL_INTERFACENAME ce_intf, POLARITY ACTIVE_LOW" *) input CE;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency data_bitwidth format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} DATA_WIDTH 1}" *) output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12 U0
       (.A({1'b0,1'b0,1'b0,1'b0}),
        .CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

module bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv
   (q,
    clk,
    ce,
    d,
    sclr);
  output [0:0]q;
  input clk;
  input ce;
  input [0:0]d;
  input sclr;

  wire ce;
  wire clk;
  wire [0:0]d;
  wire \i_no_async_controls.output[1]_i_1_n_0 ;
  wire [0:0]q;
  wire sclr;

  LUT4 #(
    .INIT(16'h00E2)) 
    \i_no_async_controls.output[1]_i_1 
       (.I0(q),
        .I1(ce),
        .I2(d),
        .I3(sclr),
        .O(\i_no_async_controls.output[1]_i_1_n_0 ));
  FDRE #(
    .INIT(1'b0)) 
    \i_no_async_controls.output_reg[1] 
       (.C(clk),
        .CE(1'b1),
        .D(\i_no_async_controls.output[1]_i_1_n_0 ),
        .Q(q),
        .R(1'b0));
endmodule

(* C_ADDR_WIDTH = "4" *) (* C_AINIT_VAL = "0" *) (* C_DEFAULT_DATA = "0" *) 
(* C_DEPTH = "1" *) (* C_ELABORATION_DIR = "./" *) (* C_HAS_A = "0" *) 
(* C_HAS_CE = "1" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_MEM_INIT_FILE = "no_coe_file_loaded" *) (* C_OPT_GOAL = "0" *) 
(* C_PARSER_TYPE = "0" *) (* C_READ_MIF = "0" *) (* C_REG_LAST_BIT = "1" *) 
(* C_SHIFT_TYPE = "0" *) (* C_SINIT_VAL = "0" *) (* C_SYNC_ENABLE = "0" *) 
(* C_SYNC_PRIORITY = "1" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "1" *) 
(* C_XDEVICEFAMILY = "kintex7" *) (* downgradeipidentifiedwarnings = "yes" *) 
module bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12
   (A,
    D,
    CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    Q);
  input [3:0]A;
  input [0:0]D;
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  output [0:0]Q;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv i_synth
       (.CE(CE),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(SCLR));
endmodule

(* C_ADDR_WIDTH = "4" *) (* C_AINIT_VAL = "0" *) (* C_DEFAULT_DATA = "0" *) 
(* C_DEPTH = "1" *) (* C_ELABORATION_DIR = "./" *) (* C_HAS_A = "0" *) 
(* C_HAS_CE = "1" *) (* C_HAS_SCLR = "1" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_MEM_INIT_FILE = "no_coe_file_loaded" *) (* C_OPT_GOAL = "0" *) 
(* C_PARSER_TYPE = "0" *) (* C_READ_MIF = "0" *) (* C_REG_LAST_BIT = "1" *) 
(* C_SHIFT_TYPE = "0" *) (* C_SINIT_VAL = "0" *) (* C_SYNC_ENABLE = "0" *) 
(* C_SYNC_PRIORITY = "1" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "1" *) 
(* C_XDEVICEFAMILY = "kintex7" *) (* c_default_data_radix = "1" *) (* c_enable_rlocs = "0" *) 
(* c_generate_mif = "0" *) (* c_has_aclr = "0" *) (* c_has_ainit = "0" *) 
(* c_has_aset = "0" *) (* c_mem_init_radix = "1" *) (* downgradeipidentifiedwarnings = "yes" *) 
(* opt_mode = "AREA" *) (* optimize_primitives = "NO" *) (* shreg_extract = "yes" *) 
(* use_clock_enable = "YES" *) 
module bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy
   (a,
    d,
    clk,
    ce,
    aclr,
    aset,
    ainit,
    sclr,
    sset,
    sinit,
    q);
  input [3:0]a;
  input [0:0]d;
  input clk;
  input ce;
  input aclr;
  input aset;
  input ainit;
  input sclr;
  input sset;
  input sinit;
  output [0:0]q;

  wire ce;
  wire clk;
  wire [0:0]d;
  wire [0:0]q;
  wire sclr;

  bd_1953_c_shift_ram_0_0_c_reg_fd_v12_0_5_viv \gen_output_regs.output_regs 
       (.ce(ce),
        .clk(clk),
        .d(d),
        .q(q),
        .sclr(sclr));
endmodule

module bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_viv
   (Q,
    D,
    CLK,
    CE,
    SCLR);
  output [0:0]Q;
  input [0:0]D;
  input CLK;
  input CE;
  input SCLR;

  wire CE;
  wire CLK;
  wire [0:0]D;
  wire [0:0]Q;
  wire SCLR;

  (* C_AINIT_VAL = "0" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_HAS_ACLR = "0" *) 
  (* C_HAS_AINIT = "0" *) 
  (* C_HAS_ASET = "0" *) 
  (* C_HAS_CE = "1" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_SYNC_ENABLE = "0" *) 
  (* C_SYNC_PRIORITY = "1" *) 
  (* C_WIDTH = "1" *) 
  (* SHREG_EXTRACT = "yes" *) 
  (* c_addr_width = "4" *) 
  (* c_default_data = "0" *) 
  (* c_default_data_radix = "1" *) 
  (* c_depth = "1" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_generate_mif = "0" *) 
  (* c_has_a = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_mem_init_radix = "1" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "1" *) 
  (* c_shift_type = "0" *) 
  (* c_verbosity = "0" *) 
  (* c_xdevicefamily = "kintex7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* opt_mode = "AREA" *) 
  (* optimize_primitives = "NO" *) 
  (* use_clock_enable = "YES" *) 
  bd_1953_c_shift_ram_0_0_c_shift_ram_v12_0_12_legacy i_bb_inst
       (.a({1'b0,1'b0,1'b0,1'b0}),
        .aclr(1'b0),
        .ainit(1'b0),
        .aset(1'b0),
        .ce(CE),
        .clk(CLK),
        .d(D),
        .q(Q),
        .sclr(SCLR),
        .sinit(1'b0),
        .sset(1'b0));
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
