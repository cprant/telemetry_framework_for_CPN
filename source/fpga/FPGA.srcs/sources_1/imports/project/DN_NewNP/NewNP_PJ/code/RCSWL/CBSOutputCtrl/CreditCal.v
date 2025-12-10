/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CreditCal.v
Target Device All
Dscription 
    1)根据参数以及链路状态计算队列信用值
Data_Struct:

        
Caution: 
    1)
Author : wjj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CreditCal #(
    parameter   RAMADDR_WID  = 14,
                TABLE_WID    = 33
)(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //参数
(*mark_debug="true"*)    input  wire [             31:0] iv_hrc_idleslope_tick,
(*mark_debug="true"*)    input  wire [             31:0] iv_hrc_sendslope_tick,
(*mark_debug="true"*)    input  wire [             31:0] iv_hrc_hicredit      ,
(*mark_debug="true"*)    input  wire [             31:0] iv_hrc_locredit      ,
(*mark_debug="true"*)    input  wire [             31:0] iv_lrc_idleslope_tick,
(*mark_debug="true"*)    input  wire [             31:0] iv_lrc_sendslope_tick,
(*mark_debug="true"*)    input  wire [             31:0] iv_lrc_hicredit      ,
(*mark_debug="true"*)    input  wire [             31:0] iv_lrc_locredit      ,
    //状态
(*mark_debug="true"*)    input  wire [              1:0] Q_empty,
(*mark_debug="true"*)    input  wire [              1:0] Q_Txing,
    //信用输出
(*mark_debug="true"*)    output reg  [             31:0] Credit_H,
(*mark_debug="true"*)    output reg  [             31:0] Credit_L
);



/************************************************************************
                                信用计算
*************************************************************************/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)begin
        Credit_H        <= 32'h8000_0000;
    end
    else begin
        if(Q_empty[1] == 1'b1)begin
            if(Credit_H[31] == 1'b1)begin
                Credit_H        <= 32'h8000_0000;
            end
            else begin
                Credit_H        <= Credit_H + iv_hrc_idleslope_tick;
            end
        end
        else begin
            if(Q_Txing[1] == 1'b1)begin
                Credit_H        <= ((Credit_H - iv_hrc_sendslope_tick) < iv_hrc_locredit) ? iv_hrc_locredit : (Credit_H - iv_hrc_sendslope_tick);
            end
            else begin
                Credit_H        <= ((Credit_H + iv_hrc_idleslope_tick) < iv_hrc_hicredit) ? (Credit_H + iv_hrc_idleslope_tick) : iv_hrc_hicredit;
            end
        end
    end

end

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)begin
        Credit_L        <= 32'h8000_0000;
    end
    else begin
        if(Q_empty[0] == 1'b1)begin
            if(Credit_L[31] == 1'b1)begin
                Credit_L        <= 32'h8000_0000;
            end
            else begin
                Credit_L        <= Credit_L + iv_lrc_idleslope_tick;
            end
        end
        else begin
            if(Q_Txing[0] == 1'b1)begin
                Credit_L        <= ((Credit_L - iv_lrc_sendslope_tick) < iv_lrc_locredit) ? iv_lrc_locredit : (Credit_L - iv_lrc_sendslope_tick);
            end
            else begin
                Credit_L        <= ((Credit_L + iv_lrc_idleslope_tick) < iv_lrc_hicredit) ? (Credit_L + iv_lrc_idleslope_tick) : iv_lrc_hicredit;
            end
        end
    end

end

endmodule

/*
CreditCal CreditCal_inst(
    .axis_clk               ( ),
    .axis_rst_n             ( ),


    .iv_hrc_idleslope_tick  ( ),
    .iv_hrc_sendslope_tick  ( ),
    .iv_hrc_hicredit        ( ),
    .iv_hrc_locredit        ( ),
    .iv_lrc_idleslope_tick  ( ),
    .iv_lrc_sendslope_tick  ( ),
    .iv_lrc_hicredit        ( ),
    .iv_lrc_locredit        ( ),
    
    .Q_empty                ( ),
    .Q_Txing                ( ),

    .Credit_H               ( ),
    .Credit_L               ( )
);
*/
