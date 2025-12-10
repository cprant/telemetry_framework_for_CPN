// Copyright (C) 1953-2022 NUDT
// Verilog module name - cycle_start_judge 
// Version: V3.4.0.20220420
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps
module cycle_start_generate(
input                 i_clk,
input                 i_rst_n,
input                 i_syn_ok,
input     [31:0]      iv_cycle_length, 
input     [63:0]      iv_base_time, 
input     [63:0]      iv_syn_clk,              
output    reg         o_cycle_start
);         
 
reg       [63:0]      rv_cycle_start_time;
reg       [1:0]       pcj_state;
localparam            IDLE_S                   = 2'd0,
                      SET_CYCLE_STATE_TIME_S   = 2'd1,
                      START_CYCLE_S            = 2'd2;

always@(posedge i_clk or negedge i_rst_n)begin 
    if(!i_rst_n) begin
		 o_cycle_start          <=1'd0;
         rv_cycle_start_time    <=64'd0;
         pcj_state              <=IDLE_S;
    end
    else begin
        case(pcj_state)
        IDLE_S:begin           
            if(i_syn_ok ==1'b0)begin          
                o_cycle_start  <=1'd0;                
                pcj_state      <=IDLE_S;
            end
            else begin
                if((i_syn_ok==1'd1)&&(iv_base_time>64'd0))begin
                    rv_cycle_start_time    <= iv_base_time;	
                    o_cycle_start          <=1'd0;
                    pcj_state              <=SET_CYCLE_STATE_TIME_S;
                end 
                else begin
                    rv_cycle_start_time    <=64'd0;
                    o_cycle_start          <=1'd0;
                    pcj_state              <=IDLE_S;
                end	          					
            end
        end
        SET_CYCLE_STATE_TIME_S:begin 
            o_cycle_start<=1'b0;			
            if(rv_cycle_start_time <=iv_syn_clk)begin                  		
                rv_cycle_start_time<=rv_cycle_start_time+iv_cycle_length;
                if (i_syn_ok==1'd1)begin
                    pcj_state<=START_CYCLE_S; 
                end
                else begin
                    pcj_state<=IDLE_S;
                end            
            end
            else begin
                rv_cycle_start_time <= rv_cycle_start_time;
                if (i_syn_ok==1'd1)begin
                    pcj_state<=SET_CYCLE_STATE_TIME_S; 
                end
                else begin
                    pcj_state<=IDLE_S;
                end                   
            end   
        end
        START_CYCLE_S:begin
			o_cycle_start<=1'b1;  
			pcj_state <= SET_CYCLE_STATE_TIME_S;
        end
        default:begin
			o_cycle_start     <= 1'h0;
            rv_cycle_start_time       <=64'd0;
			pcj_state                 <=IDLE_S;	
		end  
        endcase           
    end       
end
endmodule