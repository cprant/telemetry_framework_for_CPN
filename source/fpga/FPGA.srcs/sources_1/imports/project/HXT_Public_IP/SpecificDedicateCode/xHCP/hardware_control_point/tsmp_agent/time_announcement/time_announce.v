// Copyright (C) 1953-2022 NUDT
// Verilog module name - time_announcement 
// Version: V4.0.20220525
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         use RAM to cahce the tnc table
//         lookup table 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module time_announcement
(
        i_clk        ,
        i_rst_n      ,
        
        iv_syn_clk   ,
        iv_hcp_mac   ,
        i_cycle_start,
              
        iv_addr      , 
        iv_wdata     , 
        i_addr_fixed , 
        i_wr         , 
        i_rd         ,                
        o_wr         , 
        ov_addr      , 
        o_addr_fixed , 
        ov_rdata     , 

        ov_data      ,
        o_data_wr   	   
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;
input      [63:0]      iv_syn_clk;
input      [47:0]      iv_hcp_mac;
input                  i_cycle_start;
//lookup table RAM
input      [18:0]      iv_addr      ;
input      [31:0]      iv_wdata     ;
input                  i_addr_fixed ;
input                  i_wr         ;
input                  i_rd         ;            
output                 o_wr         ;
output     [18:0]      ov_addr      ;
output                 o_addr_fixed ;
output     [31:0]      ov_rdata     ;

output     [8:0]       ov_data     ;
output                 o_data_wr   ;

wire	   			   ram0_wr;
wire	   			   ram0_rd;	
wire	   			   ram1_wr;
wire	   			   ram1_rd;
wire	   			   ram2_wr;
wire	   			   ram2_rd;	
wire	   			   ram3_wr;
wire	   			   ram3_rd;

wire        [31:0]	   ram0_rdata;
wire    	[31:0]	   ram1_rdata;
wire    	[31:0]	   ram2_rdata;
wire    	[31:0]	   ram3_rdata;

wire        [31:0]	   ram0_wdata;
wire    	[31:0]	   ram1_wdata;
wire    	[31:0]	   ram2_wdata;
wire    	[31:0]	   ram3_wdata;

wire	   [9:0]	   a2t_ram_raddr;
wire				   a2t_ram_rd;
wire	   [127:0]	   t2a_ram_rdata;			


address_encode address_encode_inst(
.i_clk             (i_clk             ),
.i_rst_n           (i_rst_n           ),

.iv_addr           (iv_addr           ),                         
.i_addr_fixed      (i_addr_fixed      ),                                        
.i_wr              (i_wr              ),         
.i_rd              (i_rd              ), 
.iv_wdata		   (iv_wdata          ),       
                                   
.o_wr              (o_wr              ),
.ov_addr           (ov_addr           ),
.o_addr_fixed      (o_addr_fixed      ),
.ov_rdata		   (ov_rdata          ),

.ram0_wr   		   (ram0_wr   		  ),
.ram0_rd  		   (ram0_rd  		  ),
.ram0_rdata  	   (ram0_rdata  	  ),
.ram0_wdata  	   (ram0_wdata  	  ),

.ram1_wr   		   (ram1_wr   		  ),
.ram1_rd  		   (ram1_rd  		  ),
.ram1_rdata  	   (ram1_rdata  	  ),
.ram1_wdata  	   (ram1_wdata  	  ),

.ram2_wr   		   (ram2_wr   		  ),
.ram2_rd  		   (ram2_rd  		  ),
.ram2_rdata  	   (ram2_rdata  	  ),
.ram2_wdata  	   (ram2_wdata  	  ),


.ram3_wr   		   (ram3_wr   		  ),
.ram3_rd  		   (ram3_rd  		  ),
.ram3_rdata  	   (ram3_rdata  	  ),
.ram3_wdata  	   (ram3_wdata  	  )
);

tnc_lookup_table tnc_lookup_table_inst(
.i_clk             (i_clk                 ),
.i_rst_n           (i_rst_n               ),
.iv_hcp_mac        (iv_hcp_mac            ),
.iv_syn_clk        (iv_syn_clk            ),
.i_cycle_start     (i_cycle_start         ),
                    
.ov_data           (ov_data               ),
.o_data_wr         (o_data_wr             ),
                    
.a2t_ram_raddr     (a2t_ram_raddr        ),
.a2t_ram_rd        (a2t_ram_rd            ),
.t2a_ram_rdata	   (t2a_ram_rdata		  )
);

ParamTdpram_rddly #(
    .ADDR_WIDTH                 ( 10),
    .DATA_WIDTH                 ( 32)
)ram32x1024_ram0(      
    .clk                        ( i_clk                 ),
        
    .we_a                       ( ram0_wr               ),
    .wdata_a                    ( ram0_wdata            ),
    .addr_a                     ( iv_addr[11:2]         ),
    .rdata_a                    ( ram0_rdata            ),
        
    .we_b                       ( 1'd0                  ),
    .wdata_b                    ( 32'h0                 ),
    .addr_b                     ( a2t_ram_raddr         ),
    .rdata_b                    ( t2a_ram_rdata[127:96] )
);

ParamTdpram_rddly #(
    .ADDR_WIDTH                 ( 10),
    .DATA_WIDTH                 ( 32)
)ram32x1024_ram1(      
    .clk                        ( i_clk                 ),
        
    .we_a                       ( ram1_wr               ),
    .wdata_a                    ( ram1_wdata            ),
    .addr_a                     ( iv_addr[11:2]         ),
    .rdata_a                    ( ram1_rdata            ),
        
    .we_b                       ( 1'd0                  ),
    .wdata_b                    ( 32'h0                 ),
    .addr_b                     ( a2t_ram_raddr         ),
    .rdata_b                    ( t2a_ram_rdata[95:64 ] )
);

ParamTdpram_rddly #(
    .ADDR_WIDTH                 ( 10),
    .DATA_WIDTH                 ( 32)
)ram32x1024_ram2(      
    .clk                        ( i_clk                 ),
        
    .we_a                       ( ram2_wr               ),
    .wdata_a                    ( ram2_wdata            ),
    .addr_a                     ( iv_addr[11:2]         ),
    .rdata_a                    ( ram2_rdata            ),
        
    .we_b                       ( 1'd0                  ),
    .wdata_b                    ( 32'h0                 ),
    .addr_b                     ( a2t_ram_raddr         ),
    .rdata_b                    ( t2a_ram_rdata[63:32]  )
);

ParamTdpram_rddly #(
    .ADDR_WIDTH                 ( 10),
    .DATA_WIDTH                 ( 32)
)ram32x1024_ram3(      
    .clk                        ( i_clk                 ),
        
    .we_a                       ( ram3_wr               ),
    .wdata_a                    ( ram3_wdata            ),
    .addr_a                     ( iv_addr[11:2]         ),
    .rdata_a                    ( ram3_rdata            ),
        
    .we_b                       ( 1'd0                  ),
    .wdata_b                    ( 32'h0                 ),
    .addr_b                     ( a2t_ram_raddr         ),
    .rdata_b                    ( t2a_ram_rdata[31:0]   )
);
/*
ram32x1024 ram32x1024_ram0(

.data_a            (ram0_wdata),
.data_b            (128'h0),          
.address_a         (iv_addr[11:2]),
.address_b         (a2t_ram_raddr),
.wren_a            (ram0_wr),
.wren_b            (1'b0),      
.clock             (i_clk),
.rden_a            (ram0_rd),
.rden_b            (a2t_ram_rd),              
.q_a               (ram0_rdata),
.q_b               (t2a_ram_rdata[127:96])
);

ram32x1024 ram32x1024_ram1(

.data_a            (ram1_wdata),
.data_b            (128'h0),          
.address_a         (iv_addr[11:2]),
.address_b         (a2t_ram_raddr),
.wren_a            (ram1_wr),
.wren_b            (1'b0),      
.clock             (i_clk),
.rden_a            (ram1_rd),
.rden_b            (a2t_ram_rd),              
.q_a               (ram1_rdata),
.q_b               (t2a_ram_rdata[95:64])
);

ram32x1024 ram32x1024_ram2(

.data_a            (ram2_wdata),
.data_b            (128'h0),          
.address_a         (iv_addr[11:2]),
.address_b         (a2t_ram_raddr),
.wren_a            (ram2_wr),
.wren_b            (1'b0),      
.clock             (i_clk),
.rden_a            (ram2_rd),
.rden_b            (a2t_ram_rd),              
.q_a               (ram2_rdata),
.q_b               (t2a_ram_rdata[63:32])
);

ram32x1024 ram32x1024_ram3(

.data_a            (ram3_wdata),
.data_b            (128'h0),          
.address_a         (iv_addr[11:2]),
.address_b         (a2t_ram_raddr),
.wren_a            (ram3_wr),
.wren_b            (1'b0),      
.clock             (i_clk),
.rden_a            (ram3_rd),
.rden_b            (a2t_ram_rd),              
.q_a               (ram3_rdata),
.q_b               (t2a_ram_rdata[31:0])
);
*/

endmodule
