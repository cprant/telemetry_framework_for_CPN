
/************************************************************************
       Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
************************************************************************/
/*
Vendor C2Comm
Version 1.0
Filename  RCCfgMgmt.v
Target Device All
Dscription 
    1)解析CBS控制参数

Data_Struct:    

Caution: 

Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CBSCfgMgmt#(
    parameter   PORT_ID  = 0
)(
    //时钟复位信号
    input  wire         user_clk  ,
    input  wire         user_rst_n,
    //配置管理接口
(*mark_debug="true"*)    input  wire         s_lb_cs_n ,
(*mark_debug="true"*)    output reg          s_lb_ack_n,
(*mark_debug="true"*)    input  wire         s_lb_wr_rd,
(*mark_debug="true"*)    input  wire [ 31:0] s_lb_addr ,
(*mark_debug="true"*)    input  wire [ 31:0] s_lb_wdata,
(*mark_debug="true"*)    output reg  [ 31:0] s_lb_rdata,
    //RC转发表配置管理接口
(*mark_debug="true"*)    output reg [ 31:0] ov_hrc_idleslope_tick,
(*mark_debug="true"*)    output reg [ 31:0] ov_hrc_sendslope_tick,
(*mark_debug="true"*)    output reg [ 31:0] ov_hrc_hicredit      ,
(*mark_debug="true"*)    output reg [ 31:0] ov_hrc_locredit      ,
(*mark_debug="true"*)    output reg [ 31:0] ov_lrc_idleslope_tick,
(*mark_debug="true"*)    output reg [ 31:0] ov_lrc_sendslope_tick,
(*mark_debug="true"*)    output reg [ 31:0] ov_lrc_hicredit      ,
(*mark_debug="true"*)    output reg [ 31:0] ov_lrc_locredit      
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
(*mark_debug="true"*)wire         sync_cs_valid;

(*mark_debug="true"*)reg  [  2:0] ccm_state;
localparam   IDLE_S   = 3'd0,
             WRITE_S  = 3'd1,
             READ_S   = 3'd2,
             ACK_S    = 3'd3;

(*mark_debug="true"*)reg  [ 30:0] hrc_hiCredit;
(*mark_debug="true"*)reg  [ 30:0] hrc_loCredit;
(*mark_debug="true"*)reg  [ 30:0] lrc_hiCredit;
(*mark_debug="true"*)reg  [ 30:0] lrc_loCredit;

/*//////////////////////////////////////////////////////////
                    本地配置管理
*///////////////////////////////////////////////////////////

always @(*)begin
    if(user_rst_n == 1'b0)begin
        ov_hrc_hicredit         = 32'h0;
        ov_hrc_locredit         = 32'h0;
        ov_lrc_hicredit         = 32'h0;
        ov_lrc_locredit         = 32'h0;
    end
    else begin
        ov_hrc_hicredit         = {1'b1,hrc_hiCredit};
        ov_hrc_locredit         = {1'b0,hrc_loCredit};
        ov_lrc_hicredit         = {1'b1,lrc_hiCredit};
        ov_lrc_locredit         = {1'b0,lrc_loCredit};

    end

end

/*//////////////////////////////////////////////////////////
                    本地配置管理
*///////////////////////////////////////////////////////////

always @(posedge user_clk or negedge user_rst_n)begin
    if(user_rst_n == 1'b0)begin
        s_lb_ack_n              <= 1'd1;
        s_lb_rdata              <= 32'd0;
        
        ov_hrc_idleslope_tick   <= 32'd0;
        ov_hrc_sendslope_tick   <= 32'd0;
        ov_lrc_idleslope_tick   <= 32'd0;
        ov_lrc_sendslope_tick   <= 32'd0;
        
        hrc_hiCredit            <= 31'h7FFF_FFFF;
        hrc_loCredit            <= 31'h0;
        lrc_hiCredit            <= 31'h7FFF_FFFF;
        lrc_loCredit            <= 31'h0;
        
        
        ccm_state               <= IDLE_S;
    end
    else begin
        case(ccm_state)
        IDLE_S:begin
            s_lb_ack_n              <= 1'd1;
            s_lb_rdata              <= 32'd0;
            //if((sync_cs_valid == 1'd1) && (s_lb_addr[6:2] == 5'd1)) $display("s_lb_addr6-2:%x,  PORT_ID:%x",s_lb_addr[6:2],PORT_ID);
            if((sync_cs_valid == 1'd1) && (s_lb_addr[7:3] == PORT_ID))begin
                if(s_lb_wr_rd == 1'd0)begin
                    ccm_state           <= WRITE_S;
                end
                else begin
                    ccm_state           <= READ_S;
                end
            end
            else begin
                ccm_state           <= IDLE_S;
            end
        end
        
        WRITE_S:begin
            s_lb_ack_n          <= 1'd0;
            if(s_lb_addr[2:0] == 3'd0)begin
                ov_hrc_idleslope_tick   <= s_lb_wdata[31:0];
            end
            else if(s_lb_addr[2:0] == 3'd1)begin
                ov_hrc_sendslope_tick   <= s_lb_wdata[31:0];
            end
            else if(s_lb_addr[2:0] == 3'd2)begin
                hrc_hiCredit            <= s_lb_wdata[31:0]; 
            end
            else if(s_lb_addr[2:0] == 3'd3)begin
                hrc_loCredit            <= s_lb_wdata[31:0];
            end
            else if(s_lb_addr[2:0] == 3'd4)begin
                ov_lrc_idleslope_tick   <= s_lb_wdata[31:0];
            end
            else if(s_lb_addr[2:0] == 3'd5)begin
                ov_lrc_sendslope_tick   <= s_lb_wdata[31:0];
            end
            else if(s_lb_addr[2:0] == 3'd6)begin
                lrc_hiCredit            <= s_lb_wdata[31:0];
            end
            else begin
                lrc_loCredit            <= s_lb_wdata[31:0];
            end
            ccm_state           <= ACK_S;
        end
        
        READ_S:begin
            s_lb_ack_n          <= 1'd0;
            
            ccm_state           <= ACK_S;
            if(s_lb_addr[2:0] == 3'd0)begin
                s_lb_rdata          <= {1'b0,ov_hrc_idleslope_tick};
            end
            else if(s_lb_addr[2:0] == 3'd1)begin
                s_lb_rdata          <= {1'b0,ov_hrc_sendslope_tick};
            end
            else if(s_lb_addr[2:0] == 3'd2)begin
                s_lb_rdata          <= {1'b0,hrc_hiCredit};
            end
            else if(s_lb_addr[2:0] == 3'd3)begin
                s_lb_rdata          <= {1'b0,hrc_loCredit};
            end
            else if(s_lb_addr[2:0] == 3'd4)begin
                s_lb_rdata          <= {1'b0,ov_lrc_idleslope_tick};
            end
            else if(s_lb_addr[2:0] == 3'd5)begin
                s_lb_rdata          <= {1'b0,ov_lrc_sendslope_tick};
            end
            else if(s_lb_addr[2:0] == 3'd6)begin
                s_lb_rdata          <= {1'b0,lrc_hiCredit};
            end
            else begin
                s_lb_rdata          <= {1'b0,lrc_loCredit};
            end
        end
        
        ACK_S:begin
            if(sync_cs_valid == 1'b0)begin
                s_lb_ack_n          <= 1'd1;
                
                ccm_state           <= IDLE_S;
            end
            else begin
            
                s_lb_ack_n          <= 1'd0;
                
                ccm_state           <= ACK_S;
            end
        end
        
        default:begin
            s_lb_ack_n              <= 1'd1;
            s_lb_rdata              <= 32'd0;
            
            ccm_state               <= IDLE_S;
        end
        endcase
    end
end

/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
SyncSig cs_sync_inst(
    .clk                    ( user_clk          ),
    .rst_n                  ( user_rst_n        ),
    
    .in_sig                 ( ~s_lb_cs_n    ),
    .out_sig                ( sync_cs_valid    )
);
endmodule

/*
CBSCfgMgmt CBSCfgMgmt_inst(
    .user_clk               ( ),
    .user_rst_n             ( ),

    .s_lb_cs_n              ( ),
    .s_lb_ack_n             ( ),
    .s_lb_wr_rd             ( ),
    .s_lb_addr              ( ),
    .s_lb_wdata             ( ),
    .s_lb_rdata             ( ),

    .ov_hrc_idleslope_tick  ( ),
    .ov_hrc_sendslope_tick  ( ),
    .ov_hrc_hicredit        ( ),
    .ov_hrc_locredit        ( ),
    .ov_lrc_idleslope_tick  ( ),
    .ov_lrc_sendslope_tick  ( ),
    .ov_lrc_hicredit        ( ),
    .ov_lrc_locredit        ( )
);
*/