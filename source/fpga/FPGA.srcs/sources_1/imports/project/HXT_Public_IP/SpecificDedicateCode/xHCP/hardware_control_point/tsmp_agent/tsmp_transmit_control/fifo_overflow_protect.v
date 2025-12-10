// Copyright (C) 1953-2022 NUDT
// Verilog module name - fifo_overflow_protect
// Version: V4.0.0.20220620
// Created:
//         by - fenglin
////////////////////////////////////////////////////////////////////////////
// Description:
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module fifo_overflow_protect#(parameter pkt_discard_fifousedw = 11'd192,parameter pkt_cut_fifousedw = 11'd192)
(
       i_clk  ,
       i_rst_n,
       
       iv_data   ,
       i_data_wr ,
	   
       iv_fifo_usedw,
	   ov_data      ,
	   o_data_wr    ,
       
       ov_discard_pkt_cnt,
       ov_cut_pkt_cnt    
);

// I/O
// clk & rst
input                  i_clk  ;
input                  i_rst_n;  
// pkt input
input	   [8:0]	   iv_data  ;
input	         	   i_data_wr;
// pkt output
input      [10:0]      iv_fifo_usedw      ;
output reg [8:0]	   ov_data            ;
output reg	           o_data_wr          ;

output reg [15:0]      ov_discard_pkt_cnt ;
output reg [15:0]      ov_cut_pkt_cnt     ;

reg        [1:0]       rv_fop_state       ;
localparam  IDLE_S                      = 2'd0,
            WRITE_FIFO_S                = 2'd1,
            DISCARD_DATA_S              = 2'd2; 
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data            <= 9'b0;
		o_data_wr          <= 1'b0;
        
        ov_discard_pkt_cnt <= 16'b0;
        ov_cut_pkt_cnt     <= 16'b0;
		rv_fop_state       <= IDLE_S;
    end
    else begin
		case(rv_fop_state)
			IDLE_S:begin  
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin//first cycle.    
                    if(iv_fifo_usedw >= pkt_discard_fifousedw)begin
                        ov_data       <= 9'b0;
                        o_data_wr     <= 1'b0;
                        ov_discard_pkt_cnt <= ov_discard_pkt_cnt + 1'b1;
                        rv_fop_state  <= DISCARD_DATA_S;
                    end
                    else begin
                        ov_data       <= iv_data       ;
                        o_data_wr     <= i_data_wr     ;
                        rv_fop_state  <= WRITE_FIFO_S  ;
                    end                    
                end
                else begin
                    ov_data      <= 9'b0;
                    o_data_wr    <= 1'b0;
                    rv_fop_state <= IDLE_S;                
                end
            end
            WRITE_FIFO_S:begin
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin//last cycle.    
                    o_data_wr    <= i_data_wr;
                    ov_data      <= iv_data;
                    rv_fop_state <= IDLE_S;
                end
                else if((i_data_wr == 1'b1) && (iv_data[8] == 1'b0))begin//middle cycle.
                    if(iv_fifo_usedw == pkt_cut_fifousedw)begin
                        o_data_wr      <= i_data_wr;
                        ov_data        <= {1'b1,iv_data[7:0]};
                        ov_cut_pkt_cnt <= ov_cut_pkt_cnt + 1'b1;
                        rv_fop_state   <= DISCARD_DATA_S;
                    end
                    else begin
                        o_data_wr    <= i_data_wr;
                        ov_data      <= iv_data;
                        rv_fop_state <= WRITE_FIFO_S;
                    end
                end
                else begin
                    o_data_wr    <= 1'b0;
                    ov_data      <= 9'b0;
                    rv_fop_state <= IDLE_S;
                end                
			end      
            DISCARD_DATA_S:begin
                o_data_wr    <= 1'b0;
                ov_data      <= 9'b0;
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin//last cycle
                    rv_fop_state <= IDLE_S;                   
                end
                else begin
                    rv_fop_state <= DISCARD_DATA_S;  
                end                
            end
			default:begin
                ov_data      <= 9'b0;
                o_data_wr    <= 1'b0;
                rv_fop_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule