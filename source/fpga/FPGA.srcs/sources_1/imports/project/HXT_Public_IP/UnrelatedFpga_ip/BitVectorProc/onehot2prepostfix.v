////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor: C2Comm
Version: 1.0
Filename: onehot2prepostfix.v
Target Device: All
Dscription: 
    1)将onehot编码转变为前缀或后缀编码
    2)支持转变为前缀或后缀编码时，是否包含自己，以前缀为例：
        包含自己，  则4'B0010->4'B1110
        不包含自己，则4'B0010->4'B1100
      

Author : 刘晓骏
Revision List:
	rn1:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module onehot2prepostfix #(
    parameter PRE_OR_POST  = 0,//0:prefix  1:postfix
              INCLUDE_SELF = 0,//0:onehot's valid bit do not include in prefix  1:include
              WIDTH        = 4
               
)(
    input  wire [WIDTH-1:0] i_onehot,
    output wire [WIDTH-1:0] o_ppfix
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire [WIDTH-1:0] prefix_condition;
wire [WIDTH-1:0] int_prefix;

//***************************************************
//      Convert Onehot to Prefix
//***************************************************
generate
    genvar i;
    for(i=0;i<WIDTH;i=i+1)begin:calc_prefix
        //if [i:0] is 0,so the one hot's valid bit must be in the [WIDTH-1:i+1]
        //so the int_prefix[i] could be 0
        assign prefix_condition[i] = (INCLUDE_SELF == 1'b0) ? 
                                    ((i_onehot[i] == 1'b1) || ((|i_onehot[i:0]) == 1'b0)) : 
                                    ((|i_onehot[i:0]) == 1'b0);
                                                     
        assign int_prefix[i] = (prefix_condition[i] == 1'b1) ? 1'b0 : 1'b1;
    end
endgenerate


//judge outport prefix or postfix
assign o_ppfix = (PRE_OR_POST == 1'b0) ? int_prefix : ~int_prefix;
/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
endmodule
/*
onehot2prepostfix #(
    .PRE_OR_POST(),
    .INCLUDE_SELF(),
    .WIDTH()
)onehot2prepostfix_inst(
    .i_onehot(),
    .o_ppfix()
);
*/