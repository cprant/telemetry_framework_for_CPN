////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2020 C2comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//Vendor: C2comm
//Version: 0.1
//Filename: gray2binary.v
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
module gray2binary #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] i_gray,
    output wire [WIDTH-1:0] o_bin
);

assign o_bin[WIDTH-1] = i_gray[WIDTH-1];

generate
    genvar i;
    for(i=0;i<WIDTH-1;i=i+1)begin:gray2binary
        assign o_bin[i] = i_gray[i] ^ o_bin[i+1];
    end
endgenerate

endmodule
/*
gray2binary #(
    .WIDTH()
)gray2bin_inst(
    .i_gray(),
    .o_bin()
);
*/