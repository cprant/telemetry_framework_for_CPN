// Copyright (C) 1953-2022 NUDT
// Verilog module name - tsmp_transmit_control
// Version: V3.4.0.20220301
// Created:
//         by - fenglin
////////////////////////////////////////////////////////////////////////////
// Description:
//         
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tsmp_transmit_control
(
        i_clk  ,
        i_rst_n,
       
        iv_data_nma  ,
	    i_data_wr_nma,

        iv_data_osp  ,
        i_data_wr_osp,
        
        iv_data_tfp  ,
        i_data_wr_tfp,
        
        iv_data_pop  ,
        i_data_wr_pop,

        ov_data,
        o_data_wr,
        
        ov_discard_pkt_cnt_fop_nma,
        ov_cut_pkt_cnt_fop_nma    ,
        ov_discard_pkt_cnt_fop_osp,
        ov_cut_pkt_cnt_fop_osp    ,
        ov_discard_pkt_cnt_fop_tfp,
        ov_cut_pkt_cnt_fop_tfp    ,
        ov_discard_pkt_cnt_fop_pop,
        ov_cut_pkt_cnt_fop_pop    
    
); 
// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n; 
// pkt input
input	   [8:0]	   iv_data_nma  ;
input	         	   i_data_wr_nma;
                       
input	   [8:0]	   iv_data_osp  ;
input	         	   i_data_wr_osp;
                       
input	   [8:0]	   iv_data_tfp  ;
input	         	   i_data_wr_tfp;
                       
input	   [8:0]	   iv_data_pop  ;
input	         	   i_data_wr_pop;

output     [8:0]	   ov_data  ;
output     	           o_data_wr;

output     [15:0]      ov_discard_pkt_cnt_fop_nma;
output     [15:0]      ov_cut_pkt_cnt_fop_nma    ;
output     [15:0]      ov_discard_pkt_cnt_fop_osp;
output     [15:0]      ov_cut_pkt_cnt_fop_osp    ;
output     [15:0]      ov_discard_pkt_cnt_fop_tfp;
output     [15:0]      ov_cut_pkt_cnt_fop_tfp    ;
output     [15:0]      ov_discard_pkt_cnt_fop_pop;
output     [15:0]      ov_cut_pkt_cnt_fop_pop    ;

wire       [8:0]	   wv_data_fop2fifo_nma  ;
wire       	           w_data_wr_fop2fifo_nma;
wire                   w_data_fifo_rden_cos2fifo_nma;
wire                   w_data_fifo_empty_fifo2cos_nma;
wire       [8:0]       wv_data_fifo_rdata_fifo2cos_nma;
wire       [10:0]      wv_fifo_usedw_fifo2fop_nma;

wire       [8:0]	   wv_data_fop2fifo_osp  ;
wire       	           w_data_wr_fop2fifo_osp;
wire                   w_data_fifo_rden_cos2fifo_osp;
wire                   w_data_fifo_empty_fifo2cos_osp;
wire       [8:0]       wv_data_fifo_rdata_fifo2cos_osp;
wire       [7:0]       wv_fifo_usedw_fifo2fop_osp;

wire       [8:0]	   wv_data_fop2fifo_tfp  ;
wire       	           w_data_wr_fop2fifo_tfp;
wire                   w_data_fifo_rden_cos2fifo_tfp;
wire                   w_data_fifo_empty_fifo2cos_tfp;
wire       [8:0]       wv_data_fifo_rdata_fifo2cos_tfp;
wire       [10:0]      wv_fifo_usedw_fifo2fop_tfp;

wire       [8:0]	   wv_data_fop2fifo_pop  ;
wire       	           w_data_wr_fop2fifo_pop;
wire                   w_data_fifo_rden_cos2fifo_pop;
wire                   w_data_fifo_empty_fifo2cos_pop;
wire       [8:0]       wv_data_fifo_rdata_fifo2cos_pop;
wire       [7:0]       wv_fifo_usedw_fifo2fop_pop;
fifo_overflow_protect#(.pkt_discard_fifousedw(11'h7ff-11'h40),.pkt_cut_fifousedw(11'h7ff-11'h1)) fifo_overflow_protect_nma_inst(
    .i_clk               (i_clk  ),
    .i_rst_n             (i_rst_n),

    .iv_data             (iv_data_nma  ),
    .i_data_wr           (i_data_wr_nma),

    .iv_fifo_usedw       (wv_fifo_usedw_fifo2fop_nma),
	.ov_data             (wv_data_fop2fifo_nma  ),
	.o_data_wr           (w_data_wr_fop2fifo_nma),

    .ov_discard_pkt_cnt  (ov_discard_pkt_cnt_fop_nma),
    .ov_cut_pkt_cnt      (ov_cut_pkt_cnt_fop_nma    )
);

ParamSyncFifo #(
    .DATA_WIDTH             ( 9),
    .ADDR_WIDTH             ( 11)
)
nma_packet_cache_inst(              
    .clk                    ( i_clk                             ),
    .aclr                   ( ~i_rst_n                          ),
                              
    .wrreq                  ( w_data_wr_fop2fifo_nma            ),
    .data                   ( wv_data_fop2fifo_nma              ),
    .rdreq                  ( w_data_fifo_rden_cos2fifo_nma     ),
    .q                      ( wv_data_fifo_rdata_fifo2cos_nma   ),
                              
    .usedw                  ( wv_fifo_usedw_fifo2fop_nma        ),
    .full                   ( ),
    .empty                  ( w_data_fifo_empty_fifo2cos_nma    )
); 
/*
syncfifo_showahead_aclr_w9d2048 nma_packet_cache_inst(
    .data  (wv_data_fop2fifo_nma), 
    .wrreq (w_data_wr_fop2fifo_nma),
    .rdreq (w_data_fifo_rden_cos2fifo_nma),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_data_fifo_rdata_fifo2cos_nma),    
    .usedw (wv_fifo_usedw_fifo2fop_nma),
    .full  (), 
    .empty (w_data_fifo_empty_fifo2cos_nma) 
);
*/
fifo_overflow_protect#(.pkt_discard_fifousedw(11'h0ff-11'h40),.pkt_cut_fifousedw(11'h0ff-11'h1)) fifo_overflow_protect_osp_inst(
    .i_clk               (i_clk  ),
    .i_rst_n             (i_rst_n),

    .iv_data             (iv_data_osp  ),
    .i_data_wr           (i_data_wr_osp),

    .iv_fifo_usedw       ({3'b0,wv_fifo_usedw_fifo2fop_osp}),
	.ov_data             (wv_data_fop2fifo_osp  ),
	.o_data_wr           (w_data_wr_fop2fifo_osp),

    .ov_discard_pkt_cnt  (ov_discard_pkt_cnt_fop_osp),
    .ov_cut_pkt_cnt      (ov_cut_pkt_cnt_fop_osp    )
);

ParamSyncFifo #(
    .DATA_WIDTH             ( 9),
    .ADDR_WIDTH             ( 8)
)
osp_packet_cache_inst(              
    .clk                    ( i_clk                             ),
    .aclr                   ( ~i_rst_n                          ),
                              
    .wrreq                  ( w_data_wr_fop2fifo_osp            ),
    .data                   ( wv_data_fop2fifo_osp              ),
    .rdreq                  ( w_data_fifo_rden_cos2fifo_osp     ),
    .q                      ( wv_data_fifo_rdata_fifo2cos_osp   ),
                              
    .usedw                  ( wv_fifo_usedw_fifo2fop_osp        ),
    .full                   ( ),
    .empty                  ( w_data_fifo_empty_fifo2cos_osp    )
); 
/*
syncfifo_showahead_aclr_w9d256 osp_packet_cache_inst(
    .data  (wv_data_fop2fifo_osp), 
    .wrreq (w_data_wr_fop2fifo_osp),
    .rdreq (w_data_fifo_rden_cos2fifo_osp),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_data_fifo_rdata_fifo2cos_osp),    
    .usedw (wv_fifo_usedw_fifo2fop_osp),
    .full  (), 
    .empty (w_data_fifo_empty_fifo2cos_osp) 
);
*/
fifo_overflow_protect#(.pkt_discard_fifousedw(11'h7ff-11'h40),.pkt_cut_fifousedw(11'h7ff-11'h1)) fifo_overflow_protect_tfp_inst(
    .i_clk               (i_clk  ),
    .i_rst_n             (i_rst_n),

    .iv_data             (iv_data_tfp  ),
    .i_data_wr           (i_data_wr_tfp),

    .iv_fifo_usedw       (wv_fifo_usedw_fifo2fop_tfp),
	.ov_data             (wv_data_fop2fifo_tfp  ),
	.o_data_wr           (w_data_wr_fop2fifo_tfp),

    .ov_discard_pkt_cnt  (ov_discard_pkt_cnt_fop_tfp),
    .ov_cut_pkt_cnt      (ov_cut_pkt_cnt_fop_tfp    )
);

ParamSyncFifo #(
    .DATA_WIDTH             ( 9),
    .ADDR_WIDTH             ( 11)
)
tfp_packet_cache_inst(              
    .clk                    ( i_clk                             ),
    .aclr                   ( ~i_rst_n                          ),
                              
    .wrreq                  ( w_data_wr_fop2fifo_tfp            ),
    .data                   ( wv_data_fop2fifo_tfp              ),
    .rdreq                  ( w_data_fifo_rden_cos2fifo_tfp     ),
    .q                      ( wv_data_fifo_rdata_fifo2cos_tfp   ),
                              
    .usedw                  ( wv_fifo_usedw_fifo2fop_tfp        ),
    .full                   ( ),
    .empty                  ( w_data_fifo_empty_fifo2cos_tfp    )
); 
/*
syncfifo_showahead_aclr_w9d2048 tfp_packet_cache_inst(
    .data  (wv_data_fop2fifo_tfp), 
    .wrreq (w_data_wr_fop2fifo_tfp),
    .rdreq (w_data_fifo_rden_cos2fifo_tfp),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_data_fifo_rdata_fifo2cos_tfp),    
    .usedw (wv_fifo_usedw_fifo2fop_tfp),
    .full  (), 
    .empty (w_data_fifo_empty_fifo2cos_tfp) 
);
*/
fifo_overflow_protect#(.pkt_discard_fifousedw(11'h0ff-11'h40),.pkt_cut_fifousedw(11'h0ff-11'h1)) fifo_overflow_protect_pop_inst(
    .i_clk               (i_clk  ),
    .i_rst_n             (i_rst_n),

    .iv_data             (iv_data_pop  ),
    .i_data_wr           (i_data_wr_pop),

    .iv_fifo_usedw       ({3'b0,wv_fifo_usedw_fifo2fop_pop}),
	.ov_data             (wv_data_fop2fifo_pop  ),
	.o_data_wr           (w_data_wr_fop2fifo_pop),

    .ov_discard_pkt_cnt  (ov_discard_pkt_cnt_fop_pop),
    .ov_cut_pkt_cnt      (ov_cut_pkt_cnt_fop_pop    )
);

ParamSyncFifo #(
    .DATA_WIDTH             ( 9),
    .ADDR_WIDTH             ( 8)
)
pop_packet_cache_inst(              
    .clk                    ( i_clk                             ),
    .aclr                   ( ~i_rst_n                          ),
                              
    .wrreq                  ( w_data_wr_fop2fifo_pop            ),
    .data                   ( wv_data_fop2fifo_pop              ),
    .rdreq                  ( w_data_fifo_rden_cos2fifo_pop     ),
    .q                      ( wv_data_fifo_rdata_fifo2cos_pop   ),
                              
    .usedw                  ( wv_fifo_usedw_fifo2fop_pop        ),
    .full                   ( ),
    .empty                  ( w_data_fifo_empty_fifo2cos_pop    )
); 
/*
syncfifo_showahead_aclr_w9d256 pop_packet_cache_inst(
    .data  (wv_data_fop2fifo_pop), 
    .wrreq (w_data_wr_fop2fifo_pop),
    .rdreq (w_data_fifo_rden_cos2fifo_pop),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_data_fifo_rdata_fifo2cos_pop),    
    .usedw (wv_fifo_usedw_fifo2fop_pop),
    .full  (), 
    .empty (w_data_fifo_empty_fifo2cos_pop) 
);
*/
controller_output_schedule controller_output_schedule_inst
(
        .i_clk              (i_clk            ),
        .i_rst_n            (i_rst_n          ),
                                              
	    .i_fifo_empty_nma   (w_data_fifo_empty_fifo2cos_nma ),
        .o_fifo_rden_nma    (w_data_fifo_rden_cos2fifo_nma  ),
        .iv_fifo_rdata_nma  (wv_data_fifo_rdata_fifo2cos_nma),
                                             
	    .i_fifo_empty_osp   (w_data_fifo_empty_fifo2cos_osp ),
        .o_fifo_rden_osp    (w_data_fifo_rden_cos2fifo_osp  ),
        .iv_fifo_rdata_osp  (wv_data_fifo_rdata_fifo2cos_osp),
                                           
	    .i_fifo_empty_tfp   (w_data_fifo_empty_fifo2cos_tfp ),
        .o_fifo_rden_tfp    (w_data_fifo_rden_cos2fifo_tfp  ),
        .iv_fifo_rdata_tfp  (wv_data_fifo_rdata_fifo2cos_tfp),          
                                          
	    .i_fifo_empty_pop   (w_data_fifo_empty_fifo2cos_pop ),
        .o_fifo_rden_pop    (w_data_fifo_rden_cos2fifo_pop  ),
        .iv_fifo_rdata_pop  (wv_data_fifo_rdata_fifo2cos_pop),  
                                            
        .ov_data            (ov_data          ),
        .o_data_wr          (o_data_wr        )
); 
endmodule