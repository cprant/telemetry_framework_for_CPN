////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  RstExtend.v
Target Device All
Dscription 
    1)

Data_Struct:
   1)

Caution:
    1)
Author  刘晓骏
Revision List:
	rn1:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module RstExtend #(
    parameter	RESET_CYCLE = 12500000
	)(
        input  wire clk,
        input  wire int_rst_n,
        
        output reg  ext_rst_n
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
reg [31:0] reset_cnt;

always @(posedge clk or negedge int_rst_n) begin
    if(~int_rst_n) begin
        reset_cnt <= 32'b0;
        ext_rst_n <= 1'b0;
    end
    else begin
        if(reset_cnt < RESET_CYCLE) begin
            reset_cnt <= reset_cnt + 32'd1;
            ext_rst_n <= 1'b0;
        end
        else begin
            reset_cnt <= reset_cnt;
            ext_rst_n <= 1'b1;
        end
    end
end

endmodule
/*
RstExtend #(
    .RESET_CYCLE()
)RstExtend_inst(
    .clk(),
    .int_rst_n(),
    .ext_rst_n()
);
*/