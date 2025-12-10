////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor: C2Comm
Version: 1.0
Filename: bitmap2onehot.v
Target Device: All
Dscription: 
    1)可参数化，通过修改参数可支持任意位宽
    2)选择输入bitmap中的第一个有效bit并清零剩余的bit位
      

Author : 刘晓骏
Revision List:
	rn1:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/

module bitmap2onehot #(
    parameter PRIOR_LOW_OR_HIGH  = 0,//0:select start from low bit     1:from high bit
              WIDTH              = 4
               
)(
    input  wire [WIDTH-1:0] i_bitmap,
    output wire [WIDTH-1:0] o_onehot
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 

//***************************************************
//                  bitmap有效位选择
//***************************************************
generate
    genvar i;
    if(PRIOR_LOW_OR_HIGH == 0) begin//select start from low bit
        assign o_onehot[0] = (i_bitmap[0] == 1'b1) ? 1'b1 : 1'b0;
        
        for(i=1;i<WIDTH;i=i+1)begin:sel_low_prior
            //current bit is 1,and the other bits which index lower is 0
            //so it is the highest prior bit
            assign o_onehot[i] = ((i_bitmap[i] == 1'b1) && 
                                  ((|i_bitmap[i-1:0]) == 1'b0)
                                  ) ? 1'b1 : 1'b0;
        end
    end
    else begin
        assign o_onehot[WIDTH-1] = (i_bitmap[WIDTH-1] == 1'b1) ? 1'b1 : 1'b0;
        
        for(i=0;i<WIDTH-1;i=i+1)begin:sel_high_prior
            //current bit is 1,and the value of other bits which index higher is 0
            //so it is the highest prior bit
            assign o_onehot[i] = ((i_bitmap[i] == 1'b1) && 
                                  ((|i_bitmap[WIDTH-1:i+1]) == 1'b0)
                                  ) ? 1'b1 : 1'b0;
        end
    end
endgenerate

/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
endmodule
/*
bitmap2onehot #(
    .PRIOR_LOW_OR_HIGH(),
    .WIDTH()
)bitmap2onehot_inst(
    .i_bitmap(),
    .o_onehot()
);
*/