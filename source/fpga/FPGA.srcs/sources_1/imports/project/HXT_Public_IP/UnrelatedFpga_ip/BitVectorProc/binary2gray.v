////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2020 C2comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//Vendor: C2comm
//Version: 0.1
//Filename: binary2gray.v
//Target Device: All
//Dscription: 
//  1)
//  2)
//  3)
//
//Author : 
//History List:
//	rn1:	date:	modifier:	description:
//
module binary2gray #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] i_bin,
    output wire [WIDTH-1:0] o_gray
);

assign o_gray = {1'b0,i_bin[WIDTH-1:1]} ^ i_bin;

endmodule
/*
binary2gray #(
    .WIDTH()
)bin2gray_inst(
    .i_bin(),
    .o_gray()
);
*/
