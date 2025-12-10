////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISFifoStrBuf.v
Target Device All
Dscription 
    1)对AXI Stream接口通过FIFO进行缓存并输出
    2)按照流模式，有数据就会取出发送
    2)支持同步和异步两种模式
Data_Struct:
    1)
Caution: 
    1)如果PKT_MODE为报文模式时，FIFO深度至少为512(2的9次方)
    2)否则，深度也不应小于32(2的5次方)
    2)由于FIFO的empty和usedw存在延时，因此通过read_cnt记录可读读取次数,并且为了防止出现异步模式下rdusedw更新慢的情况
      在READ_S状态读空后判断rdusedw要判断至少有3拍数据，如果没有，则需要等待3个周期使得usedw更新(WAIT_S 2个周期，IDLE 1个周期)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module AXISFifoStrBuf #(
    parameter ASYNC_EN    = 1,//同步或异步  0：同步  1：异步
              DEEP_WIDTH  = 5,//缓存FIFO的容量的指数位宽
              DATA_BYTE   = 8,
              USER_BIT    = 1,
              MIN_PKTLINE = 4//默认按照最少每8拍是1个完整报文来评估SFIFO深度
)(
//时钟复位信号
    input  wire                   s_axis_clk,
    input  wire                   s_axis_rst_n,
    
    input  wire                   m_axis_clk,
    input  wire                   m_axis_rst_n,
//AXI Stream输入接口
    output reg                    s_axis_tready,
    input  wire                   s_axis_tvalid,
    input  wire [  DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire [   USER_BIT-1:0] s_axis_tuser,    
//AXI Stream输出接口
    input  wire                   m_axis_tready,
    output wire                   m_axis_tvalid,
    output wire [  DATA_BYTE-1:0] m_axis_tkeep,
    output wire [DATA_BYTE*8-1:0] m_axis_tdata,
    output wire                   m_axis_tlast,
    output wire [   USER_BIT-1:0] m_axis_tuser,
    
    output wire [           31:0] free_space,
    output wire [           31:0] used_space
);


//限定FIFO深度至少是32(2的5次方)
localparam  DFIFO_DEEP = (DEEP_WIDTH <5) ? 5 : DEEP_WIDTH,
            SFIFO_DEEP = (DFIFO_DEEP-clogb2(MIN_PKTLINE) < 5) ?  5 : DFIFO_DEEP-clogb2(MIN_PKTLINE);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam   DATA_BIT  = DATA_BYTE*8,
             DFIFO_BIT = 1+USER_BIT+DATA_BIT,//{tlast,tuser,tdata}
             SFIFO_BIT = DATA_BYTE;//tkeep
             
wire                   dfifo_sop;
wire [            7:0] dfifo_line_id;
wire                   dfifo_eop;
       
wire                   dfifo_wr   ;
wire [  DFIFO_BIT-1:0] dfifo_wdata; 
reg                    dfifo_rd   ;
wire [  DFIFO_BIT-1:0] dfifo_rdata;
wire [ DFIFO_DEEP-1:0] dfifo_wrusedw;
wire [ DFIFO_DEEP-1:0] dfifo_rdusedw;
wire                   dfifo_wrfull ;
wire                   dfifo_rdempty;

wire                   sfifo_wr   ;
wire [  SFIFO_BIT-1:0] sfifo_wdata; 
wire                   sfifo_rd   ;
wire [  SFIFO_BIT-1:0] sfifo_rdata;
wire [ SFIFO_DEEP-1:0] sfifo_wrusedw;
wire [ SFIFO_DEEP-1:0] sfifo_rdusedw;
wire                   sfifo_wrfull ;
wire                   sfifo_rdempty;

wire                   int_0_axis_tready;
reg                    int_0_axis_tvalid;
reg  [  DATA_BYTE-1:0] int_0_axis_tkeep ;
reg  [   DATA_BIT-1:0] int_0_axis_tdata ;
reg                    int_0_axis_tlast ;
reg  [   USER_BIT-1:0] int_0_axis_tuser ;   
       
wire                   int_1_axis_tready;
reg                    int_1_axis_tvalid;
reg  [  DATA_BYTE-1:0] int_1_axis_tkeep ;
reg  [   DATA_BIT-1:0] int_1_axis_tdata ;
reg                    int_1_axis_tlast ;
reg  [   USER_BIT-1:0] int_1_axis_tuser ;  
        
reg                    ext_0_axis_tready;
wire                   ext_0_axis_tvalid;
wire [  DATA_BYTE-1:0] ext_0_axis_tkeep ;
wire [   DATA_BIT-1:0] ext_0_axis_tdata ;
wire                   ext_0_axis_tlast ;
wire [   USER_BIT-1:0] ext_0_axis_tuser ;     

reg                  fifo_can_rd;

reg [ DFIFO_DEEP-1:0] read_cnt;//由于FIFO的ready和usedw存在延时，因此采用记录读取次数的方式

reg  [          1:0] read_state;

localparam  START_S = 2'd0,
            READ_S  = 2'd1,
            WAIT_S  = 2'd2;
/*/////////////////////////////////////
            输入接口处理
*//////////////////////////////////////
always @(posedge s_axis_clk or negedge s_axis_rst_n) begin
    if(s_axis_rst_n == 1'd0)
        s_axis_tready <= 1'b0;
    else if(((&sfifo_wrusedw[SFIFO_DEEP-1:2]) == 1'b0) && 
            ((&dfifo_wrusedw[DFIFO_DEEP-1:2]) == 1'b0))
        //仅在查表模式以及dfifo可接收的情况下接收报文
        s_axis_tready <= 1'b1;
    else
        s_axis_tready <= 1'b0;
end

assign dfifo_wr    = s_axis_tvalid & s_axis_tready;
assign dfifo_wdata = {s_axis_tlast,s_axis_tuser,s_axis_tdata};
assign sfifo_wr    = s_axis_tvalid & s_axis_tready & s_axis_tlast;
assign sfifo_wdata = s_axis_tkeep; 


assign free_space[31:DFIFO_DEEP]  = {(32-DFIFO_DEEP){1'b0}};
assign free_space[DFIFO_DEEP-1:0] = ~dfifo_wrusedw;

assign used_space[31:DFIFO_DEEP]  = {(32-DFIFO_DEEP){1'b0}};
assign used_space[DFIFO_DEEP-1:0] =  dfifo_rdusedw;
/*/////////////////////////////////////
            输出接口处理
*//////////////////////////////////////
//数据FIFO控制

//以下几类情况可以读取FIFO：
//仅有1个AXISRegBuf有空，则只有当前FIFO没有读出数据时可以继续读
//2个AXISRegBuf都有空，无论当前FIFO是否有读出的数据都可以继续读
always @* begin
    case({int_1_axis_tready,int_0_axis_tready,dfifo_rd})
        3'b100 :fifo_can_rd = 1'b1;
        3'b010 :fifo_can_rd = 1'b1;
        3'b110 :fifo_can_rd = 1'b1;
        3'b111 :fifo_can_rd = 1'b1;
        default:fifo_can_rd = 1'b0;//其他情况不能读或不存在
    endcase
end

            
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        dfifo_rd    <= 1'b0;
        read_state  <= START_S;
    end
    else  begin
        case(read_state)
            START_S: begin
                if(((|dfifo_rdusedw) == 1'b1) && 
                   (dfifo_rdempty == 1'b0) && 
                   (fifo_can_rd == 1'd1)) begin//DFIFO中有数据,并且当前状态可读
                    read_cnt   <= dfifo_rdusedw - 1'b1;//记录可读取次数
                    dfifo_rd   <= 1'b1;
                    read_state <= READ_S;
                end
                else begin
                    dfifo_rd   <= 1'b0;
                    read_state <= START_S;
                end
            end
            
            READ_S: begin
                if((fifo_can_rd == 1'd1) && (dfifo_rdempty == 1'b0)) begin//当前FIFO可读
                    if((|read_cnt) == 1'b1) begin//数据还未读完
                        read_cnt   <= read_cnt - 1'b1;//更新可读取次数
                        dfifo_rd   <= 1'b1;
                        read_state <= READ_S;  
                    end
                    else if(dfifo_rdusedw > 2'd2) begin//数据虽被读完，但仍有新的数据可读取
                        read_cnt   <= dfifo_rdusedw - 2'd3;//记录可读取次数
                        dfifo_rd   <= 1'b1;
                        read_state <= READ_S;
                    end
                    else begin
                        read_cnt   <= 2'd1;//等待FIFO usedw更新的周期
                        dfifo_rd   <= 1'b0;
                        read_state <= WAIT_S;
                    end
                end
                else begin
                    read_cnt   <= 2'd1;//等待FIFO usedw更新的周期
                    dfifo_rd   <= 1'b0;
                    read_state <= WAIT_S;
                end
            end
            
            WAIT_S: begin//等待FIFO usedw更新
                read_cnt[1:0]   <= read_cnt[1:0] - 1'b1;
                if((|read_cnt[1:0]) == 1'b0) begin//等待usedw更新完成
                    read_state <= START_S;
                end
                else begin
                    read_state <= WAIT_S;
                end
            end
            
            default: begin
                dfifo_rd    <= 1'b0;
                read_state  <= START_S;
            end
        endcase
    end
end



//在报文尾部被读出后，立刻读出sfifo中对应的尾部
//由于sfifo就是在报文尾部写入的，因此报文尾部被读出说明sfifo一定有值
assign sfifo_rd = dfifo_eop;

//FIFO读出数据处理
//
always @* begin
    case({int_1_axis_tready,ext_0_axis_tvalid})
        2'b00: begin//只有RegBuf0能收
        //将RegBuf0的数据输出到RegBuf1，由RegBuf0接收FIFO数据
            int_0_axis_tvalid = dfifo_rd;
            int_0_axis_tdata  = dfifo_rdata[DATA_BIT-1:0];
            int_0_axis_tlast  = dfifo_rdata[DFIFO_BIT-1:DATA_BIT+USER_BIT];
            int_0_axis_tuser  = dfifo_rdata[DATA_BIT+USER_BIT-1:DATA_BIT];
            int_0_axis_tkeep  = (dfifo_eop == 1'b1) ? sfifo_rdata : {DATA_BYTE{1'b1}};
            
            ext_0_axis_tready = 1'b0;
            
            int_1_axis_tvalid = 1'b0;
            int_1_axis_tdata  = {DATA_BIT {1'b0}} ;
            int_1_axis_tlast  = 1'b0 ;
            int_1_axis_tuser  = {USER_BIT {1'b0}} ;
            int_1_axis_tkeep  = {DATA_BYTE{1'b0}} ;
        end
        
        2'b10: begin//两个Regbuf都能收，将数据送到离出口近的Buf1
            int_0_axis_tvalid = 1'b0;
            int_0_axis_tdata  = {DATA_BIT {1'b0}} ;
            int_0_axis_tlast  = 1'b0 ;
            int_0_axis_tuser  = {USER_BIT {1'b0}} ;
            int_0_axis_tkeep  = {DATA_BYTE{1'b0}} ;
            
            ext_0_axis_tready = 1'b0;
            
            int_1_axis_tvalid = dfifo_rd;
            int_1_axis_tdata  = dfifo_rdata[DATA_BIT-1:0];
            int_1_axis_tlast  = dfifo_rdata[DFIFO_BIT-1:DATA_BIT+USER_BIT];
            int_1_axis_tuser  = dfifo_rdata[DATA_BIT+USER_BIT-1:DATA_BIT];
            int_1_axis_tkeep  = (dfifo_eop == 1'b1) ? sfifo_rdata : {DATA_BYTE{1'b1}};
            
        end
        
        2'b11: begin//只有RegBuf1能收
        //则需要将RegBuf0的数据输出到RegBuf1，由RegBuf0接收FIFO数据
            int_0_axis_tvalid = dfifo_rd;
            int_0_axis_tdata  = dfifo_rdata[DATA_BIT-1:0];
            int_0_axis_tlast  = dfifo_rdata[DFIFO_BIT-1:DATA_BIT+USER_BIT];
            int_0_axis_tuser  = dfifo_rdata[DATA_BIT+USER_BIT-1:DATA_BIT];
            int_0_axis_tkeep  = (dfifo_eop == 1'b1) ? sfifo_rdata : {DATA_BYTE{1'b1}};
            
            ext_0_axis_tready = 1'b1;
            
            int_1_axis_tvalid = ext_0_axis_tvalid;
            int_1_axis_tdata  = ext_0_axis_tdata ;
            int_1_axis_tlast  = ext_0_axis_tlast ;
            int_1_axis_tuser  = ext_0_axis_tuser ;
            int_1_axis_tkeep  = ext_0_axis_tkeep ;
        end

        default: begin//两个Buf都不能接收
            int_0_axis_tvalid = 1'b0;
            int_0_axis_tdata  = {DATA_BIT {1'b0}} ;
            int_0_axis_tlast  = 1'b0 ;
            int_0_axis_tuser  = {USER_BIT {1'b0}} ;
            int_0_axis_tkeep  = {DATA_BYTE{1'b0}} ;
            
            ext_0_axis_tready = 1'b0;
            
            int_1_axis_tvalid = 1'b0;
            int_1_axis_tdata  = {DATA_BIT {1'b0}} ;
            int_1_axis_tlast  = 1'b0 ;
            int_1_axis_tuser  = {USER_BIT {1'b0}} ;
            int_1_axis_tkeep  = {DATA_BYTE{1'b0}} ;
        end
    endcase
end

/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
function [31:0] clogb2;
    input [31:0] depth;
    reg [31:0] i,result;
begin
    for(i=0;2**i<depth;i=i+1)
        result=i+1;
    clogb2=i;//返回的结果是i，即求幂的逆计算
end
endfunction

PktLineDet SaxisLineDet_Inst(
    .user_clk(m_axis_clk),
    .user_rst_n(m_axis_rst_n),
        
    .valid(dfifo_rd),
    .last(dfifo_rdata[DFIFO_BIT-1]),
        
    .sop(dfifo_sop),
    .line_id(dfifo_line_id),
    .eop(dfifo_eop)
);

generate
    if(ASYNC_EN == 0) begin:SyncFifoInst
        assign dfifo_rdusedw = dfifo_wrusedw;
        assign sfifo_rdusedw = sfifo_wrusedw;
        ParamSyncFifo #(
            .DATA_WIDTH(DFIFO_BIT),
            .ADDR_WIDTH(DFIFO_DEEP)
        )sync_dfifo_inst(
            .clk    (m_axis_clk   ),
            .aclr   (~m_axis_rst_n),
                    
            .wrreq  (dfifo_wr   ),
            .data   (dfifo_wdata),
            .rdreq  (dfifo_rd   ),
            .q      (dfifo_rdata),
            
            .usedw  (dfifo_wrusedw),
            .full   (dfifo_wrfull ),
            .empty  (dfifo_rdempty)
        );
        
        ParamSyncFifo #(
            .DATA_WIDTH(SFIFO_BIT ),
            .ADDR_WIDTH(SFIFO_DEEP)
        )sync_sfifo_inst(
            .clk    (m_axis_clk   ),
            .aclr   (~m_axis_rst_n),
                    
            .wrreq  (sfifo_wr   ),
            .data   (sfifo_wdata),
            .rdreq  (sfifo_rd   ),
            .q      (sfifo_rdata),
            
            .usedw  (sfifo_wrusedw),
            .full   (sfifo_wrfull ),
            .empty  (sfifo_rdempty)
        ); 
    end
    else begin:AsyncFifoInst
        ParamAsyncFifo #(
            .DATA_WIDTH(DFIFO_BIT),
            .ADDR_WIDTH(DFIFO_DEEP)
        )async_dfifo_inst(
            .wrclk  (s_axis_clk),
            .rdclk  (m_axis_clk),
            .aclr   (~(s_axis_rst_n&m_axis_rst_n)),
                    
            .wrreq  (dfifo_wr     ),
            .data   (dfifo_wdata  ),
            .rdreq  (dfifo_rd     ),
            .q      (dfifo_rdata  ),
            
            .wrusedw(dfifo_wrusedw),
            .wrfull (dfifo_wrfull ),
            .rdfull (             ),
            .rdusedw(dfifo_rdusedw),
            .empty  (dfifo_rdempty)
        );
        
        ParamAsyncFifo #(
            .DATA_WIDTH(SFIFO_BIT ),
            .ADDR_WIDTH(SFIFO_DEEP)
        )async_sfifo_inst(
            .wrclk  (s_axis_clk),
            .rdclk  (m_axis_clk),
            .aclr   (~(s_axis_rst_n&m_axis_rst_n)),
                    
            .wrreq  (sfifo_wr     ),
            .data   (sfifo_wdata  ),
            .rdreq  (sfifo_rd     ),
            .q      (sfifo_rdata  ),
            
            .wrusedw(sfifo_wrusedw),
            .wrfull (sfifo_wrfull ),
            .rdfull (             ),
            .rdusedw(sfifo_rdusedw),
            .empty  (sfifo_rdempty)
        );
    end
endgenerate

AXISRegBuf #(
    .DATA_BYTE(DATA_BYTE),
    .USER_BIT (USER_BIT)
)AXISRegBuf_Inst0(
//时钟复位信号
    .axis_clk  (m_axis_clk  ),
    .axis_rst_n(m_axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(int_0_axis_tready),
    .s_axis_tvalid(int_0_axis_tvalid),
    .s_axis_tkeep (int_0_axis_tkeep ),
    .s_axis_tdata (int_0_axis_tdata ),
    .s_axis_tlast (int_0_axis_tlast ),
    .s_axis_tuser (int_0_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(ext_0_axis_tready),
    .m_axis_tvalid(ext_0_axis_tvalid),
    .m_axis_tkeep (ext_0_axis_tkeep ),
    .m_axis_tdata (ext_0_axis_tdata ),
    .m_axis_tlast (ext_0_axis_tlast ),
    .m_axis_tuser (ext_0_axis_tuser )
);

AXISRegBuf#(
    .DATA_BYTE(DATA_BYTE),
    .USER_BIT (USER_BIT)
)AXISRegBuf_Inst1(
//时钟复位信号
    .axis_clk  (m_axis_clk  ),
    .axis_rst_n(m_axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(int_1_axis_tready),
    .s_axis_tvalid(int_1_axis_tvalid),
    .s_axis_tkeep (int_1_axis_tkeep ),
    .s_axis_tdata (int_1_axis_tdata ),
    .s_axis_tlast (int_1_axis_tlast ),
    .s_axis_tuser (int_1_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser )
);

endmodule
/*
AXISFifoStrBuf#(
    .ASYNC_EN   (),
    .DEEP_WIDTH (),
    .DATA_BYTE  (),
    .USER_BIT   (),
    .MIN_PKTLINE()
)AXISFifoStrBuf_Inst(
//时钟复位信号
    .s_axis_clk  (),
    .s_axis_rst_n(),
    .m_axis_clk  (),
    .m_axis_rst_n(),
//AXI Stream输入接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),    
//AXI Stream输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
//状态信号
    .free_space(),
    .used_space()
);
*/