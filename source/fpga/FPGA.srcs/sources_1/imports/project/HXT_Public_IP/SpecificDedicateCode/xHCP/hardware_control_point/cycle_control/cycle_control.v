// Copyright (C) 1953-2021 NUDT
// Verilog module name - cycle_control 
// Version: V4.0.20220607
// Created:
//         by - fenglin 
////////////////////////////////////////////////////////////////////////////
// Description:
//         global time synchronization 
//         generate report pulse base on global time
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module cycle_control 
(
        i_clk           ,
        i_rst_n         ,
        
        i_wr_cc         ,      
        iv_wdata_cc     ,      
        iv_addr_cc      ,
        i_addr_fixed_cc ,        
        i_rd_cc         ,      
              
        o_wr_cc         ,       
        ov_rdata_cc     ,        
        ov_raddr_cc     ,
        o_addr_fixed_cc ,   
  
        iv_syn_clk      ,
        i_syn_ok        ,    
        i_tsn_or_tte    , 
        iv_syn_clk_cycle,
       
        
        o_cycle_start
);
// clk & rst
input                 i_clk  ;
input                 i_rst_n;

input                 i_wr_cc;
input     [31:0]      iv_wdata_cc;
input     [18:0]      iv_addr_cc; 
input                 i_addr_fixed_cc;      
input                 i_rd_cc;

output                o_wr_cc; 
output    [31:0]      ov_rdata_cc;  
output    [18:0]      ov_raddr_cc;
output                o_addr_fixed_cc; 

input     [63:0]      iv_syn_clk      ;            // have syned global time 
input                 i_syn_ok        ;
input                 i_tsn_or_tte    ;
  
input     [31:0]      iv_syn_clk_cycle   ;

output                o_cycle_start   ;           // 1024 ms / 1.024ms pluse

wire      [31:0]      wv_cycle_length_cpe2pcj ; 
wire      [63:0]      wv_oper_base_cpe2pcj ;  

wire      [63:0]      wv_syn_clk ;  
command_parse_and_encapsulate_cc command_parse_and_encapsulate_cc_inst
(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                        
.i_wr_cc               (i_wr_cc),
.iv_wdata_cc           (iv_wdata_cc),
.iv_addr_cc            (iv_addr_cc),
.i_addr_fixed_cc       (i_addr_fixed_cc),       
.i_rd_cc               (i_rd_cc),
                        
.o_wr_cc               (o_wr_cc), 
.ov_rdata_cc           (ov_rdata_cc),
.ov_raddr_cc           (ov_raddr_cc),
.o_addr_fixed_cc       (o_addr_fixed_cc),
                       
.ov_cycle_length       (wv_cycle_length_cpe2pcj),
.ov_base_time          (wv_oper_base_cpe2pcj   ),
.o_cc_cfg              (),
.o_cc_err              ()
);
syn_clk_process syn_clk_process_inst(
.i_clk                 (i_clk                  ),
.i_rst_n               (i_rst_n                ),
                                               
.iv_syn_clk            (iv_syn_clk             ),
.i_syn_ok              (i_syn_ok               ),
.i_tsn_or_tte          (i_tsn_or_tte           ),
.iv_syn_clk_cycle      (iv_syn_clk_cycle       ),
.ov_syn_clk            (wv_syn_clk    )
);

cycle_start_generate cycle_start_generate_inst(
.i_clk                 (i_clk                  ),
.i_rst_n               (i_rst_n                ),
                                               
.iv_syn_clk            (wv_syn_clk             ),
.i_syn_ok              (i_syn_ok               ),

.iv_cycle_length       (wv_cycle_length_cpe2pcj),
.iv_base_time          (wv_oper_base_cpe2pcj   ),
.o_cycle_start         (o_cycle_start  )
);

endmodule