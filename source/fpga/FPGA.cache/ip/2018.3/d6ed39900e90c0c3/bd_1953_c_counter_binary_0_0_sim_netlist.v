// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Fri Dec 16 17:10:42 2022
// Host        : DESKTOP-CQ69JDQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ bd_1953_c_counter_binary_0_0_sim_netlist.v
// Design      : bd_1953_c_counter_binary_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k325tffg676-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "bd_1953_c_counter_binary_0_0,c_counter_binary_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_counter_binary_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_counter_binary_v12_0_12 U0
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
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_counter_binary_v12_0_12
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_counter_binary_v12_0_12_viv i_synth
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
AQaZPHQoXURaXdrjlFQ=
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
