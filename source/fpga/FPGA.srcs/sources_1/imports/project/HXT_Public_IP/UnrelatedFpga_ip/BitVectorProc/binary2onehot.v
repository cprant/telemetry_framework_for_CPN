////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2020 C2comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//Vendor: C2comm
//Version: 0.1
//Filename: binary2onehot.v
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
module binary2onehot #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0]      i_bin,
    output wire [(2**WIDTH)-1:0] o_onehot
);

generate
    genvar i;
    for(i=0;i<2**WIDTH;i=i+1)begin:onehot_cov
        assign o_onehot[i] = (i_bin == i) ? 1'b1 : 1'b0;
    end
endgenerate

endmodule
/*
binary2onehot #(
    .WIDTH()
)bin2onehot_inst(
    .i_bin(),
    .o_onehot()
);
*/