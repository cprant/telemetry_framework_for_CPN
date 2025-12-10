////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor: C2Comm
Version: 1.0
Filename: DataInvert.v
Target Device: All
Dscription: 
    1)将输入的数据按照指定的bit组进行倒序
        常用于主机序和网络序转换

    注意，要倒序的数据必须是2的倍数
Author : 刘晓骏
Revision List:
	rn1:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module DataInvert #(
    parameter GRP_WIDTH = 8,
              GRP_SUM   = 4
               
)(
    input  wire [GRP_WIDTH*GRP_SUM-1:0] iv_data,
    output wire [GRP_WIDTH*GRP_SUM-1:0] ov_data
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 

//***************************************************
//      Convert Binary to Prefix
//***************************************************
generate
    genvar i;
    for(i=0;i<GRP_SUM;i=i+1)begin:test
        assign ov_data[i*GRP_WIDTH +: GRP_WIDTH] = iv_data[(GRP_SUM-i)*GRP_WIDTH-1 -: GRP_WIDTH];
    end
endgenerate

/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
endmodule
/*
DataInvert #(
    .GRP_WIDTH(),
    .GRP_SUM  ()
)DataInvert_inst(
    .iv_data(),
    .ov_data()
);
*/