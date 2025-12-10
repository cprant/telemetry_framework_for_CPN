// Copyright (C) 1953-2021 NUDT
// Verilog module name - command_parse_and_encapsulate_tan
// Version: V4.0.20220525
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module address_encode(
        i_clk            ,       
        i_rst_n          ,      
                         
        iv_addr          ,         
        i_addr_fixed     ,               
        i_wr             ,      
        i_rd             , 
		iv_wdata		 ,
		
        o_wr             ,      
        ov_addr          ,      
        o_addr_fixed     ,
		ov_rdata		 ,
     
                         
          
        ram0_wr    ,         
        ram0_rd    ,
		ram0_rdata  ,
		ram0_wdata,
       
        ram1_wr    ,         
        ram1_rd    ,
		ram1_rdata  ,
		ram1_wdata,
          
        ram2_wr    ,         
        ram2_rd    ,
		ram2_rdata  ,
		ram2_wdata,
          
        ram3_wr    ,         
        ram3_rd,
		ram3_rdata,
		ram3_wdata
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;

input       [18:0]      iv_addr;                         
input                   i_addr_fixed;                                          
input                   i_wr;         
input                   i_rd;
input       [31:0]      iv_wdata;      

output reg              o_wr             ;
output reg [18:0]       ov_addr          ;
output reg              o_addr_fixed     ;
output reg [31:0] 		ov_rdata		 ;
//configuration 

output 	                ram0_wr    ;   
output                  ram0_rd    ;
input 	   [31:0]		ram0_rdata ;
output 	   [31:0]		ram0_wdata ;		 


output               	ram1_wr    ;   
output                  ram1_rd    ; 
input 	   [31:0]		ram1_rdata ;
output 	   [31:0]		ram1_wdata ;	

 
output              	ram2_wr    ;   
output                  ram2_rd    ; 
input 	   [31:0]		ram2_rdata ;
output 	   [31:0]		ram2_wdata ;	


output         		    ram3_wr    ;   
output                  ram3_rd    ;
input 	   [31:0]		ram3_rdata ;
output 	   [31:0]		ram3_wdata ;	

assign ram0_wdata	= iv_wdata;
assign ram1_wdata	= iv_wdata;
assign ram2_wdata	= iv_wdata;
assign ram3_wdata	= iv_wdata;
assign ram0_wr 		= i_wr & ~iv_addr[1] & ~iv_addr[0]; 
assign ram1_wr		= i_wr & ~iv_addr[1] & iv_addr[0]; 
assign ram2_wr 		= i_wr & iv_addr[1]  & ~iv_addr[0]; 
assign ram3_wr 		= i_wr & iv_addr[1]  & iv_addr[0]; 

assign ram0_rd 		= i_rd & ~iv_addr[1] & ~iv_addr[0]; 
assign ram1_rd		= i_rd & ~iv_addr[1] & iv_addr[0]; 
assign ram2_rd 		= i_rd & iv_addr[1]  & ~iv_addr[0]; 
assign ram3_rd 		= i_rd & iv_addr[1]  & iv_addr[0]; 

/*
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		ram0_wr <= 1'b0;
		ram1_wr <= 1'b0;
		ram2_wr <= 1'b0;
		ram3_wr <= 1'b0;

	end
	else begin
		if (i_wr) begin
			if ((!i_addr_fixed) && (iv_addr <= 19'd4095))begin 
				case (iv_addr[1:0])
					2'b00: begin
						ram0_wr <= 1'b1;
						ram1_wr <= 1'b0;
						ram2_wr <= 1'b0;
						ram3_wr <= 1'b0;	
					end
					2'b01: begin
						ram0_wr <= 1'b0;
						ram1_wr <= 1'b1;
						ram2_wr <= 1'b0;
						ram3_wr <= 1'b0;
					end
					2'b10: begin
						ram0_wr <= 1'b0;
						ram1_wr <= 1'b0;
						ram2_wr <= 1'b1;
						ram3_wr <= 1'b0;
					end
					2'b11: begin
						ram0_wr <= 1'b0;
					    ram1_wr <= 1'b0;
					    ram2_wr <= 1'b0;
					    ram3_wr <= 1'b1;
					end
				endcase
			end
			else begin
				ram0_wr <= 1'b0;
				ram1_wr <= 1'b0;
				ram2_wr <= 1'b0;
				ram3_wr <= 1'b0;
			end
		end
		else begin
			ram0_wr <= 1'b0;
			ram1_wr <= 1'b0;
			ram2_wr <= 1'b0;
			ram3_wr <= 1'b0;
		end
	end
	
end
*/


reg  [18:0]  rd_addr_reg;

/*

always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		
		rd_addr_reg		<= 19'b0;
		ram0_rd 		<= 1'b0;
		ram1_rd 		<= 1'b0;
		ram2_rd 		<= 1'b0;
		ram3_rd 		<= 1'b0;
	end
	else begin
		if (i_rd) begin
			if ((!i_addr_fixed) && (iv_addr <= 19'd4095))begin 
				rd_addr_reg <= iv_addr;
				case (iv_addr[1:0])
					2'b00: begin
						ram0_rd <= 1'b1;
						ram1_rd <= 1'b0;
						ram2_rd <= 1'b0;
						ram3_rd <= 1'b0;	
					end
					2'b01: begin
						ram0_rd <= 1'b0;
						ram1_rd <= 1'b1;
						ram2_rd <= 1'b0;
						ram3_rd <= 1'b0;
					end
					2'b10: begin
						ram0_rd <= 1'b0;
						ram1_rd <= 1'b0;
						ram2_rd <= 1'b1;
						ram3_rd <= 1'b0;
					end
					2'b11: begin
						ram0_rd <= 1'b0;
					    ram1_rd <= 1'b0;
					    ram2_rd <= 1'b0;
					    ram3_rd <= 1'b1;
					end
				endcase
			end
			else begin
				ram0_rd <= 1'b0;
				ram1_rd <= 1'b0;
				ram2_rd <= 1'b0;
				ram3_rd <= 1'b0;
			end
		end
		else begin
			ram0_rd <= 1'b0;
			ram1_rd <= 1'b0;
			ram2_rd <= 1'b0;
			ram3_rd <= 1'b0;
		end
	end
end
*/
reg  [2:0]   rd_reg_count;

reg  [18:0]  rd_addr_reg0;
reg  [18:0]  rd_addr_reg1;
reg  [18:0]  rd_addr_reg2;

always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
		rd_addr_reg0 <= 18'b0;
		rd_addr_reg1 <= 18'b0;
		rd_addr_reg2 <= 18'b0;
	end
	else begin
		rd_addr_reg0	<= rd_addr_reg;
		rd_addr_reg1	<= rd_addr_reg0;
		rd_addr_reg2	<= rd_addr_reg1;
	end
end

reg			 rd_reg;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
		rd_addr_reg		<= 19'b0;
		rd_reg			<= 1'b0;
        rd_reg_count    <= 3'b0;
		o_addr_fixed    <= 1'b0;
    end
    else begin
		if (i_rd) begin
            if ((!i_addr_fixed) && (iv_addr <= 19'd4095))begin 
                rd_reg		<= 1'b1;
                rd_addr_reg <= iv_addr;
            end
		end 
		else begin
			rd_reg		<= 1'b0;
			rd_addr_reg <= rd_addr_reg;
		end
		
		rd_reg_count    <= {rd_reg_count[1:0], rd_reg};
		
		if(rd_reg_count[2]) begin
			ov_addr	    	<= 	rd_addr_reg2;
			o_wr			<=  1'b1;
			o_addr_fixed	<=  1'b0;
			case (rd_addr_reg2[1:0])
				2'b00: ov_rdata <= ram0_rdata;
				2'b01: ov_rdata <= ram1_rdata;	
				2'b10: ov_rdata <= ram2_rdata;
				2'b11: ov_rdata <= ram3_rdata;
			endcase
		end
		else begin
			o_wr			<= 1'b0;
			o_addr_fixed	<=  1'b0;
		end
    end
end  
 
endmodule