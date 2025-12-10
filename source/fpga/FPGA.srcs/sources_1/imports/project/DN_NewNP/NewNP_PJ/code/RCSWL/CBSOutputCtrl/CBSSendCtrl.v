/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CBSSendCtrl.v
Target Device All
Dscription 
    1)根据输入的分组输出使能信号进行高低优先级RC队列调度输出

Data_Struct:

Caution: 
    1)
Author : wjj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CBSSendCtrl(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //信用值
(*mark_debug="true"*)    input  wire [             31:0] Credit_H,
(*mark_debug="true"*)    input  wire [             31:0] Credit_L,
    //ready信号
(*mark_debug="true"*)    input  wire                     m_axis_tready,
    //队列状态
(*mark_debug="true"*)    input  wire [              1:0] Q_empty,
    //输出控制
(*mark_debug="true"*)    output reg  [              1:0] Tx_enable
);




/************************************************************************
                                队列输出控制
*************************************************************************/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        Tx_enable         <= 2'b00;
    end
    else begin
        if(Credit_H[31] == 1'b1 && m_axis_tready == 1'b1 && Q_empty[1] == 1'b0)begin
            Tx_enable[1]        <= 1'b1;
        end
        else begin
            Tx_enable[1]        <= 1'b0;
        end
        
        if(Credit_L[31] == 1'b1 && m_axis_tready == 1'b1 && Q_empty[0] == 1'b0)begin
            Tx_enable[0]        <= 1'b1;
        end
        else begin
            Tx_enable[0]        <= 1'b0;
        end
    end
end


endmodule

/*

CBSSendCtrl CBSSendCtrl_inst(
    //时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
    //信用值
    .Credit_H(),
    .Credit_L(),
    //ready信号
    .m_axis_tready(),
    //队列状态
    .Q_empty(),
    //输出控制
    .Tx_enable()
);

*/