// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 16 17:10:42 2022
// Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top bd_1953_c_counter_binary_0_0 -prefix
//               bd_1953_c_counter_binary_0_0_ bd_1953_c_counter_binary_0_0_sim_netlist.v
// Design      : bd_1953_c_counter_binary_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_1953_c_counter_binary_0_0,c_counter_binary_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_counter_binary_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module bd_1953_c_counter_binary_0_0
   (CLK,
    SCLR,
    THRESH0,
    Q);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:thresh0_intf:l_intf:load_intf:up_intf:sinit_intf:sset_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:reset:1.0 sclr_intf RST" *) (* x_interface_parameter = "XIL_INTERFACENAME sclr_intf, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *) input SCLR;
  (* x_interface_info = "xilinx.com:signal:data:1.0 thresh0_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME thresh0_intf, LAYERED_METADATA undef" *) output THRESH0;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency bitwidth format long minimum {} maximum {}} value 24} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} DATA_WIDTH 24}" *) output [23:0]Q;

  wire CLK;
  wire [23:0]Q;
  wire SCLR;
  wire THRESH0;

  (* C_AINIT_VAL = "0" *) 
  (* C_CE_OVERRIDES_SYNC = "0" *) 
  (* C_FB_LATENCY = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_WIDTH = "24" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* c_count_by = "1" *) 
  (* c_count_mode = "0" *) 
  (* c_count_to = "1100000000000000000000" *) 
  (* c_has_load = "0" *) 
  (* c_has_thresh0 = "1" *) 
  (* c_latency = "1" *) 
  (* c_load_low = "0" *) 
  (* c_restrict_count = "1" *) 
  (* c_thresh0_value = "1100000000000000000000" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_1953_c_counter_binary_0_0_c_counter_binary_v12_0_12 U0
       (.CE(1'b1),
        .CLK(CLK),
        .L({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LOAD(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0),
        .THRESH0(THRESH0),
        .UP(1'b1));
endmodule

(* C_AINIT_VAL = "0" *) (* C_CE_OVERRIDES_SYNC = "0" *) (* C_COUNT_BY = "1" *) 
(* C_COUNT_MODE = "0" *) (* C_COUNT_TO = "1100000000000000000000" *) (* C_FB_LATENCY = "0" *) 
(* C_HAS_CE = "0" *) (* C_HAS_LOAD = "0" *) (* C_HAS_SCLR = "1" *) 
(* C_HAS_SINIT = "0" *) (* C_HAS_SSET = "0" *) (* C_HAS_THRESH0 = "1" *) 
(* C_IMPLEMENTATION = "0" *) (* C_LATENCY = "1" *) (* C_LOAD_LOW = "0" *) 
(* C_RESTRICT_COUNT = "1" *) (* C_SCLR_OVERRIDES_SSET = "1" *) (* C_SINIT_VAL = "0" *) 
(* C_THRESH0_VALUE = "1100000000000000000000" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "24" *) 
(* C_XDEVICEFAMILY = "kintex7" *) (* downgradeipidentifiedwarnings = "yes" *) 
module bd_1953_c_counter_binary_0_0_c_counter_binary_v12_0_12
   (CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    UP,
    LOAD,
    L,
    THRESH0,
    Q);
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  input UP;
  input LOAD;
  input [23:0]L;
  output THRESH0;
  output [23:0]Q;

  wire CLK;
  wire [23:0]Q;
  wire SCLR;
  wire THRESH0;

  (* C_AINIT_VAL = "0" *) 
  (* C_CE_OVERRIDES_SYNC = "0" *) 
  (* C_FB_LATENCY = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "1" *) 
  (* C_HAS_SINIT = "0" *) 
  (* C_HAS_SSET = "0" *) 
  (* C_IMPLEMENTATION = "0" *) 
  (* C_SCLR_OVERRIDES_SSET = "1" *) 
  (* C_SINIT_VAL = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_WIDTH = "24" *) 
  (* C_XDEVICEFAMILY = "kintex7" *) 
  (* c_count_by = "1" *) 
  (* c_count_mode = "0" *) 
  (* c_count_to = "1100000000000000000000" *) 
  (* c_has_load = "0" *) 
  (* c_has_thresh0 = "1" *) 
  (* c_latency = "1" *) 
  (* c_load_low = "0" *) 
  (* c_restrict_count = "1" *) 
  (* c_thresh0_value = "1100000000000000000000" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  bd_1953_c_counter_binary_0_0_c_counter_binary_v12_0_12_viv i_synth
       (.CE(1'b0),
        .CLK(CLK),
        .L({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .LOAD(1'b0),
        .Q(Q),
        .SCLR(SCLR),
        .SINIT(1'b0),
        .SSET(1'b0),
        .THRESH0(THRESH0),
        .UP(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
ZBY06y5BSEA3vwLtCYy6nxOZv3rYFFgZv5ABjBaqtaItkwdtQfFvZBIMhBOgu0+1i4DhnUz7pdYr
Y88DaxXmyw==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Q91nMYZhjxb8KT0ODrW+miquus8bIV0xJDXXyQLu4mbE2ZGK0HYqPk6xE96lKrNSpNViHea0rEyX
J3Qsb1QJLBM/4rnfg8PNzn8acqAN22JgnqyTntYQVpk0fARej5ldkyKbsCPgkFDFJQnDbUHBIcF2
clV1QCjE7A3SvN91cV0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
fpeDNxCbq4trL0iAEhu+gbl4Rix2OTBKp+3DlpwRVRrJB8M79X6xv2dY4g29GTJWY/qcPCM3xauG
RxLbIsN70w9DSrpdJ31jxXSOp/N0b21smrkPYOGR9al1eBkfjYMFWbiVzWEKHK/6z705awwEunRN
qhtuKyDzs9JphrMi08O8ld4FYuGNYbtDOUXkizCIgaOdAfQTq0yCDea9z6uJ5sQUPwqrjRIroSnJ
mW8XvC4+hFTtIH4kcsR/hWe9eHVCVq7yIdgTrHznDz5I4c7+A0ZUoahnR5dHirQC2z7KKzrCldej
93tdxPQksB7VjPElshg8WP1MGrwn+7hvSijdSw==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
No6agU7QCIBdcP4teTJDlwXV+g3qBzu8V5gqFUsql+qUP2ZRyYvAPscmGZyPnHh9xvIYYFmXqCE7
RRM/BcEtyrJ9GJvahRcE/doL0n1EHIOASw/MZnFHkf6gtqWvN+SIv29/H/UyUfhuDXqJBGjBGBRs
+/RValRovCLF1SU7AdbCQbWKJbpj9JDmu7gpnhPbkiKkLcd0L7j/KcvlPBvHLG2JvHXct9Oyye9y
FJ190Nne/diMvLsfTBKIzRzQiV/kj3aSYxw4yzuKLbdVZ9eZYqFHwhjBXrVIvIAq9zy3Z0JajEGH
8Eg7Z1uVL2BNbnB2qP4/6a3wYkq6RDa/mFw99g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Au9tuW8YCiySVmtwoSZ2LqBsVMwu9uzGBs0i03rtA+ohnDzpS7/saWzSdnxtvJsmHKLPTnuG8etw
O+1iKknogGQAhYN8j4DK0/PmelqEJy8N5vwkQ/o6l1cfVFLfqvAMRbZ7lkPzco2SCT7/KjEJHW7i
5gy7tqPxnW7QwYv2vH65EVqe0p2tQ2kCHVUvvPaAZbeDzA1LHleCahBpWEI3g5wztTT869s7a4yn
1IeWyD5NV38NHHcwqubPZ09C1Vm5NLAHW7sEnM3is9mRkFnCh/x4Fb6Ecuu4bJYFhgmNzCCKgYK9
PEdkW2OgY7EzDM7ocQQuoE0+aHQvw9lRdJm00Q==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
n8+Js6UruWrTa5ioc59l4AeAloQ6ZDwzPNPXUOknQWFRecrzd2eOQ2KSf6tv5Oxix315yAoI88kJ
L1R7xZeU1dj4QCJCinzjHZXGEfUurXJVEcq84ofioKIpCyBd7YnxOq469vjhUCYiTJvMARwPVvDY
U+jspt29lk+k5/XFur0=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HvScITgcbiG4YgkXwlLAPuMki7p9oPIAapsMuPCpK/tVnY9llE0MvUk/POKYiMFRuKgzht1jfNyM
pX8Qwv3/+iDiBgwTwibzi053ET+OglbpoF/MDrRErGx8VRvmBKwxnlefbxg6dCEzjNwYuFpDkHVT
YZySWRuz7hA0uzRJwLLkvg9LoVoAsjHpp+GqlpSqfuVaV3IJzpIboKGmFv2qLj7Z3k2aE4HhZfXc
HclRJsWxw/CA2DK86EGTnPC71xJNT7pgY1DSHCglqFwF35L0FfZes57Wpz5Ka6YR9dKPNCocMfXO
DZKOoy0+Zz/G4HOrhtHGxgzfEtHjRq0ZthhxDQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
iUhdqWDiCfcCQlHPxWpEqyNVCFa5midLrQdJPRHxIl8XE3Yj/n/34FkLiLv+Spsr7oI9k5aWK4a+
nuxaCv3dQ7nWYbRW7qtmcBaNAd2imWaENmRCX+S+4viyJ5tQa2wOaBTERr8Vkz5vLTxyERaL8La6
FmTar2jBS0q4rvo4wDyqC9At6c2AgeQfBAAwZBoZXPDZEDgPs7cgDntSHrkgJnpq0QUWVXq1OthY
NmkdEgw+Rl7uhegi+zAr65vStIlHWx2dslIgoDjSCIG56oAP2sYheJ6RETUC1pyEPJNK/uKrFBSk
tqXQC/n9X4xb8SpmzAORTE+AblofdBAcpalS8A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
5c2qOa9r97KJafoRSeQ5Cv/fMHvstbs6UZnj0zsX+vNddqpmrkfriWwEUBXGM7V/uc4n26FR82wN
LDuA3G+iDKaKKoPjyHN08NO5106/pLDF9cX/yrTSW3Y5UuCc8Vq3SdCrXZ6riV2LdYQCTLMUAgEK
fKVwW4hb9lYC374IaGczvrHdFzNwBVjiW3YljkqThYAwr/1rohgYNjk8fDbdLV6SSO1cMdOKFnGO
tMEhfTGAJOcQOBuq3Z+vJ5ewZVfFLdlEy/4XgOpiW57BtWnCBrLZidUHB6aAhPVbF2NN4PCZrYbB
KcRhoiV8KpkOwGjSqWZnUr62pyWy4umLyd/O6Q==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 1952)
`pragma protect data_block
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
8p87MjfZkA==
`pragma protect end_protected
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "FMSH Encrypt Tool"
`pragma protect encrypt_agent_info = "FMSH Encrypt Version 1.0"
`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="base64", line_length=76, bytes=256)
`pragma protect key_block
Fe+tViTRi2EVqh/wUAvtwV18wAFQgpfvABMlQvE5VeAqlIo0s2udfdDZfS2CSJCroSp3nj3vFU7s
GIPirwFFTsxZWDcB5l9riIQNL1xdGkJD95N/bVb315KLXS+Gh0IHdlnSM18GgfEiJk6PNi0n7gIq
hGn+H6a4Occ78CSXiFj8yfrTPcPq48fg7Zc1ZdVWpqcNTpu8lrWeNnI992uyNFIrASspTHqR9H3q
0Ceu94T/sJzdTo5tdO05dFFsW8tgbmRuLWo+AQ08ztq//7WMjOJlQQK6O6+/ZIlDd4Kl6q7Q4Jvp
Djh9YzjtD3QYSSdXFwBLA2CB8Fp/0AuntdTW6A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QvW0wggszi9ry0fKyc0er6nV45DDvSdrBCyvxDvVA8Xwovcdn6tFqMsLl1Ngzy/ehMgKl9XCjZ6G
6l4T8JK2ek72KPhrx8eVpTfNjo/EC6v4LaV8l0IxB7sIUgEGep8vkg42moiVtaQqZ2uPJLEk5Zkf
4LTJtKG0aKZweVi0xtQpe/xADkGtsX+jrEulkaafT9ox1BdQhiz6b/qV8IGQdutBCzxY4etZbDhi
bV8/tkT0wE6jE2z6yPzDq0ui/JKPrY+3hO8vSOc+TxiVwC1d2LXL/Oyl8FjuRWAH3l5POZaf7M3t
V2PpJzpc29sz1SL6X5MkIOdneFR2Npu1EFMBdQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TSwgq8WoWZWH4cXSMmi+4AIiWZKNaEedM1IJnSP3ETFqLbocZncofkii402ShB4X7NrA0r4tgz0P
oXGNISSOlBJQzNlBU87gQv/STW8NN43sFMrRlZlNcwpW75+6xZzDre0BLvw4JAYsLJllLw3+snel
Z1qoXS3lPgqC1VvVJbOHEOOdghA/U+onuThEZS2LlSPUhBDeo3zraCJ9MYkJdrJpWV+hr9RDjmAR
WYZcUpJib/O6fhsV/v+4LYCEFmeZnmmcmiE2wTksCgjkoSJCPEZxHjkq9O+9e0pjR2t+RUUP7rvA
Q5TydO4QEnnhmF76T8ggYKsIcBSSkDpnDERJUA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 10528)
`pragma protect data_block
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
/A==
`pragma protect end_protected
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
