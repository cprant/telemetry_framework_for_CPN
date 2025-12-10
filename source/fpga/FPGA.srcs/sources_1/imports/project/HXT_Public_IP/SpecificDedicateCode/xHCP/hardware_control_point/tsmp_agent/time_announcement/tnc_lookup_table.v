// Copyright (C) 1953-2022 NUDT
// Verilog module name - tnc_lookup_table
// Version: V4.0.20220525
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tnc_lookup_table
(
       i_clk,
       i_rst_n,
       
       iv_hcp_mac   ,
       iv_syn_clk   ,
       i_cycle_start,
       
       ov_data     ,
       o_data_wr   ,

       a2t_ram_raddr,
       a2t_ram_rd,
       t2a_ram_rdata		
);

// I/O
// clk & rst
input                     i_clk;                   //125Mhz
input                     i_rst_n;

input         [47:0]      iv_hcp_mac   ;
input         [63:0]      iv_syn_clk   ;
input                     i_cycle_start;


output reg    [8:0]       ov_data     ;
output reg                o_data_wr   ;

output reg    [9:0]       a2t_ram_raddr;
output reg                a2t_ram_rd    ;
input         [127:0]     t2a_ram_rdata;

reg           [3:0]       rv_tlt_state;
reg           [31:0]      rv_offset_cnt;

reg			  [23:0]	  announce_pit;
reg			  [47:0]      dmac;
reg			  [47:0]      smac;
reg			  [15:0]	  taskid;
reg			  [15:0]	  cookies;
reg			  [63:0] 	  syn_clk;
reg			  [5:0]	announce_pkt_cnt;

localparam            INIT_S                = 4'd0,
                      WAIT                  = 4'd1,
                      WAIT_FIRST_S          = 4'd2,
                      WAIT_SECOND_S         = 4'd3,
                      GTE_DATA_S            = 4'd4,
					  GENERATE_DMAC			= 4'd5,
					  GENERATE_SMAC         = 4'd6,
					  GENERATE_ETH_TYPE     = 4'd7,
					  GENERATE_TSMP_HEADER  = 4'd8,
					  GENERATE_SYNC_CLK     = 4'd9,
					  GENERATE_TASKID		= 4'd10,
					  GENERATE_COOKIE       = 4'd11,
					  GENERATE_RESERVE      = 4'd12,
					  GENERATE_OFFSET       = 4'd13,
					  GENERATE_ZERO         = 4'd14,
					  GENERATE_LAST			= 4'd15;
                      
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        ov_data       	<= 9'h0;
        o_data_wr     	<= 1'h0;		
        a2t_ram_raddr   <= 10'h0;
        a2t_ram_rd      <= 1'h0;
        announce_pkt_cnt<= 6'b0;
        rv_offset_cnt   <= 32'h0;
        rv_tlt_state    <= INIT_S;
		announce_pit 	<= 24'b0;
		dmac		 	<= 48'b0;
		smac		 	<= 48'b0;
		taskid		 	<= 16'b0;
		cookies		 	<= 16'b0;
		syn_clk		 	<= 64'b0;
    end                        
    else begin
	    case(rv_tlt_state)
            INIT_S:begin
                if(i_cycle_start)begin  
                    a2t_ram_raddr    <= 10'h0;
                    a2t_ram_rd       <= 1'b1;
                    rv_offset_cnt    <= 32'b0;
                    rv_tlt_state     <= WAIT_FIRST_S;
                end
                else begin
                    a2t_ram_raddr   <= 10'h0;
                    a2t_ram_rd       <= 1'b0;
                    rv_offset_cnt  <= 32'h0;
                    rv_tlt_state   <= INIT_S;
                end	                
			end
			WAIT_FIRST_S:begin
				a2t_ram_rd        <= 1'b0;	
				rv_offset_cnt	  <= rv_offset_cnt + 1;
				rv_tlt_state      <= WAIT_SECOND_S;			
			end
			WAIT_SECOND_S:begin
				rv_offset_cnt	  <= rv_offset_cnt + 1;
				rv_tlt_state      <= GTE_DATA_S;			
			end		

			GTE_DATA_S:begin
				if (t2a_ram_rdata[127] == 1'b1) begin
					announce_pit 	<= t2a_ram_rdata[119:96];
					dmac		 	<= t2a_ram_rdata[79:32];
					taskid		 	<= t2a_ram_rdata[31:16];
					cookies		 	<= t2a_ram_rdata[15:0];
					smac		 	<= iv_hcp_mac;
					rv_offset_cnt	<= rv_offset_cnt + 1;
					rv_tlt_state 	<= WAIT;
				end
				else begin
					rv_offset_cnt	<= 32'b0;
					rv_tlt_state 	<= INIT_S;
				end
			end
			
			WAIT: begin
				if (i_cycle_start) begin
					rv_tlt_state	<= INIT_S;
					rv_offset_cnt	   <= 32'h0;
					rv_tlt_state	   <= WAIT_FIRST_S;

				end
				else begin
					if(rv_offset_cnt[7:0] == 8'd125) begin
						rv_offset_cnt[31:8] = rv_offset_cnt[31:8] +1'b1;
					end
					else begin
						rv_offset_cnt[31:8] = rv_offset_cnt[31:8];
					end
					
					if(rv_offset_cnt[31:8] == announce_pit)begin
						rv_offset_cnt	   <= rv_offset_cnt + 1;
						announce_pkt_cnt	   <= 6'd0;
						syn_clk                    <= iv_syn_clk;
						rv_tlt_state	   <= GENERATE_DMAC;
					end
					else begin
						rv_offset_cnt	   <= rv_offset_cnt + 1;
						rv_tlt_state       <= WAIT;
					end
				end
			end
			
			GENERATE_DMAC: begin
				o_data_wr 	      <= 1'b1;
				if (announce_pkt_cnt == 6'b0)begin
					ov_data		  <= {1'b1,dmac[47:40]};
					dmac          <= dmac << 8;
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_DMAC;
				end
				else if (announce_pkt_cnt < 6'd5) begin
					ov_data		  <= {1'b0,dmac[47:40]};
					dmac          <= dmac << 8;
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_DMAC;
				end
				else begin
					ov_data	  <= {1'b0,dmac[47:40]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_SMAC;
				end
			end
			
			GENERATE_SMAC: begin
				if (announce_pkt_cnt < 6'd11)begin
					ov_data	  <= {1'b0,smac[47:40]};
					smac          <= smac << 8;
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_SMAC;
				end
				else begin
					ov_data		  <= {1'b0,smac[47:40]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_ETH_TYPE;
				end
			end
			
			GENERATE_ETH_TYPE: begin
				if (announce_pkt_cnt == 6'd12)begin
					ov_data		  <= {1'b0,8'hff};
   					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_ETH_TYPE;
				end
				else begin
					ov_data		  <= {1'b0,8'h01};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_TSMP_HEADER;
				end
			end
			
			GENERATE_TSMP_HEADER: begin
				if (announce_pkt_cnt == 6'd14)begin
					ov_data		  <= {1'b0,8'h05};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_TSMP_HEADER;
				end
				else begin
					ov_data		  <= {1'b0,8'h01};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_OFFSET;
				end
			end

			GENERATE_OFFSET: begin
				if (announce_pkt_cnt == 6'd16) begin
					ov_data		  <= {1'b0,announce_pit[23:16]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_OFFSET;
				end
				else if (announce_pkt_cnt == 6'd17) begin
					ov_data		  <= {1'b0,announce_pit[15:8]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_OFFSET;
				end
				else begin
					ov_data		  <= {1'b0,announce_pit[7:0]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_TASKID;
				end
			end
			
			GENERATE_TASKID: begin
				if (announce_pkt_cnt == 6'd19)begin
					ov_data       <= {1'b0,taskid[15:8]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_TASKID;
				end
				else begin
					ov_data		  <= {1'b0,taskid[7:0]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_COOKIE;
				end
			end

			GENERATE_COOKIE: begin
				if (announce_pkt_cnt == 6'd21)begin
					ov_data		  <= {1'b0,cookies[15:8]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_COOKIE;
				end
				else begin
					ov_data		  <= {1'b0,cookies[7:0]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_SYNC_CLK;
				end
			end
			



			
			GENERATE_SYNC_CLK: begin
				if (announce_pkt_cnt < 6'd32)begin
					ov_data		  <= {1'b0,syn_clk[63:56]};
					syn_clk       <= syn_clk << 8;
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_SYNC_CLK;
				end
				else begin
					ov_data		  <= {1'b0,syn_clk[63:56]};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_ZERO;
				end
			end
			
			
			
			/*
			GENERATE_RESERVE: begin
				ov_data		  <= 9'b0;
				announce_pkt_cnt <= announce_pkt_cnt + 1;
				rv_offset_cnt <= rv_offset_cnt + 1;
				rv_tlt_state  <= GENERATE_OFFSET;
			end
			*/
			
			
			GENERATE_ZERO: begin
				if (announce_pkt_cnt < 6'd58) begin
					ov_data		  <= {1'b0,8'b0};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_ZERO;
				end
				else begin
					ov_data		  <= {1'b0,8'b0};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
                    		rv_tlt_state  <= GENERATE_LAST;
					
                end	                
			end
			
			GENERATE_LAST: begin
				if (announce_pkt_cnt == 6'd59) begin
					ov_data		  <= {1'b1,8'b0};
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt + 1;
					rv_tlt_state  <= GENERATE_LAST;
				end
				else begin
					o_data_wr	  <= 1'b0;
					announce_pkt_cnt <= announce_pkt_cnt + 1;
					rv_offset_cnt <= rv_offset_cnt +1;
					a2t_ram_rd    <= 1'b1;
					a2t_ram_raddr <= a2t_ram_raddr + 1'b1;
					rv_tlt_state  <= WAIT_FIRST_S;
				end
				
			end
			

            default:begin
				a2t_ram_raddr     <= 10'h0;
				a2t_ram_rd         <= 1'h0;
				rv_tlt_state        <= INIT_S;
            end
        endcase
    end
end	
endmodule
