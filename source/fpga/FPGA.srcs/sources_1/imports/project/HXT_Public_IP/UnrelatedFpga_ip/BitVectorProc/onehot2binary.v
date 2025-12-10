////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2020 C2comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//Vendor: C2comm
//Version: 0.1
//Filename: onehot2binary.v
//Target Device: All
//Dscription: 
//  1)Convert Onehot to Binary by Matrix
//  2)
//  3)
//
//Author : 
//History List:
//	rn1:	date:	modifier:	description:
//
module onehot2binary #(
    parameter WIDTH = 4
)(
    input  wire [(2**WIDTH)-1:0] i_onehot,
    output wire [WIDTH-1:0]      o_bin
);
//***************************************************
//        Intermediate variable Declaration
//***************************************************
//all wire/reg/parameter variable 
//should be declare below here
wire [WIDTH-1:0]      index_array           [(2**WIDTH)-1:0];
wire [(2**WIDTH)-1:0] inverted_index_matrix [WIDTH-1:0];

//***************************************************
//      Calculate Onehot to Binary by Matrix
//***************************************************
/*通过倒置矩阵计算，根据i_onehot选择有效索引的输出
    步骤1、通过i_onehot对全部索引index进行预处理
           将i_onehot中bit为0的位对应的index全部清零，仅保留bit为1的位，并将该位赋值为bit位的标号
           例如i_onehot==4'b1000,则仅将index_array[3]的值赋值为3，其余全部清零
       
    步骤2、将预处理的结果作为矩阵进行导致倒置，即行(row)/列(col)互换，方便后续进行计算
    
    步骤3、将倒置的矩阵的行(row)进行按位或操作，由于或操作的特性，即可得到有效输出
            如果全为0，则该bit为0
            只要有1bit为1(由于步骤1对其他信号进行了清零，也只会出现1bit为1)，则经过计算会保留该位的1
*/

//步骤1
//set the one-hot's every bit to binaray's index array
//and set only the bit which val is 1 to valid index,clear another index
generate
    genvar i;
    for(i=0;i<2**WIDTH;i=i+1)begin:test
        assign index_array[i] = (i_onehot[i] == 1'b0) ? {WIDTH{1'b0}} : i;
    end
endgenerate

//步骤2
//invert the index array ,so it could be viewed a inverted matrix
generate
    genvar row,col;
    for(row=0;row<2**WIDTH;row=row+1)begin:col_test
        for(col=0;col<WIDTH;col=col+1)begin:col_test1
            assign inverted_index_matrix[col][row] = index_array[row][col];
        end
    end
endgenerate

//步骤3
//calc the value which is the valid index
generate
    genvar j;
    for(j=0;j<WIDTH;j=j+1)begin:o_bin_test
        assign o_bin[j] = (|inverted_index_matrix[j]);
    end
endgenerate

endmodule
/*
onehot2binary #(
    .WIDTH()
)bin2onehot_inst(
    .i_onehot(),
    .o_bin()
);
*/