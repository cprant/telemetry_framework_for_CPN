/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  AXISDestSplit.v
Target Device All
Dscription 
    1)将送往多个目的端的AXIStream流复制并拆分为多个独立的流
    2)主要应用于各目的端处理性能不一致，同时都能接收的情况不多
      将流拆分后，可以通过在外部增加端口缓存或单独丢弃反压端口报文的逻辑避免出现性能最低的端口拖累其他端口
Data_Struct:
    1)bram_wdata/rdata
       [RAM_BIT-1     : DATA_BYTE*8] s_axis_tuser
       [DATA_BYTE*8-1 :           0] s_axis_tdata
       
    2)desfifo_wdata/rdata
       [DES_BIT-1                : DEEP_WIDTH*2+DATA_BYTE] s_axis_tdst
       [DEEP_WIDTH*2+DATA_BYTE-1 :           DEEP_WIDTH*2] s_axis_tkeep
       [DEEP_WIDTH*2-1           :             DEEP_WIDTH] s_axis_line_id
       [DEEP_WIDTH-1             :                      0] bram_waddr
        
        
Caution: 
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module AXISDestSplit # (
    parameter STREAM_SUM = 8,//支持分派的的AXIStream流数量
              DEEP_WIDTH = 9,
              DATA_BYTE  = 16,
              USER_BIT   = 1
)(
//时钟复位信号
    input  wire                   axis_clk,
    input  wire                   axis_rst_n,
//分组数据输入接口
    output reg                    s_axis_tready,
    input  wire                   s_axis_tvalid,
    input  wire [  DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                   s_axis_tlast,
    input  wire [   USER_BIT-1:0] s_axis_tuser,
    input  wire [ STREAM_SUM-1:0] s_axis_tdest,
//分组数据输出接口
    input  wire                   m_axis_tready,
    output wire                   m_axis_tvalid,
    output wire [  DATA_BYTE-1:0] m_axis_tkeep ,
    output wire [DATA_BYTE*8-1:0] m_axis_tdata ,
    output wire                   m_axis_tlast ,
    output wire [   USER_BIT-1:0] m_axis_tuser ,
    output wire [ STREAM_SUM-1:0] m_axis_tdest
);
/*-----------------------------------------------------------
                    中间变量声明区域
------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam  STREAM_LOG   = clogb2(STREAM_SUM),
            RAM_BIT      = USER_BIT + (DATA_BYTE*8),
            DES_BIT      = STREAM_SUM + DATA_BYTE + (DEEP_WIDTH*2);
wire                  s_axis_sop;
wire [DEEP_WIDTH-1:0] s_axis_line_id;
wire                  s_axis_eop;

wire                  int_axis_sop;
wire [           1:0] int_axis_line_id;
wire                  int_axis_eop;
             
reg                   bram_wr;
reg  [DEEP_WIDTH-1:0] bram_waddr;
reg  [   RAM_BIT-1:0] bram_wdata;
reg                   bram_rd;
reg  [DEEP_WIDTH-1:0] bram_raddr;
wire [   RAM_BIT-1:0] bram_rdata;

reg  [           0:0] desfifo_wr   ;
reg  [   DES_BIT-1:0] desfifo_wdata; 
reg  [           0:0] desfifo_rd   ;
wire [   DES_BIT-1:0] desfifo_rdata;
wire [           5:0] desfifo_usedw;
wire [           0:0] desfifo_full ;
wire [           0:0] desfifo_empty;

reg                   sel_outport_bit_valid;
reg  [STREAM_SUM-1:0] sel_outport_bit      ;
reg  [STREAM_SUM-1:0] sel_outport_bit_latch;

wire                   int_axis_tready;
reg                    int_axis_tvalid;
reg  [  DATA_BYTE-1:0] int_axis_tkeep ;
reg  [DATA_BYTE*8-1:0] int_axis_tdata ;
reg                    int_axis_tlast ;
reg  [   USER_BIT-1:0] int_axis_tuser ;
reg  [ STREAM_SUM-1:0] int_axis_tdest ;

wire [           31:0] int_axis_free_space;

reg  [   DEEP_WIDTH:0] bram_free_space;
        
reg  [ DEEP_WIDTH-1:0] wr_ptr;
        
reg  [ DEEP_WIDTH-1:0] rd_cnt;

reg  [ STREAM_SUM-1:0] op_bitmap;
wire [ STREAM_SUM-1:0] op_onehot;
wire [ STREAM_LOG-1:0] op_binary;
       
reg  [ STREAM_SUM-1:0] op_bitmap_sel; 
       
reg  [            0:0] bram_rd_last;
reg  [            0:0] bram_rd_dly;
       
reg  [DATA_BYTE + (DEEP_WIDTH*2)-1:0] des_reg; 
       
reg  [            1:0] trans_state;

localparam  IDLE_S  = 2'd0,
            TRANS_S = 2'd1,
            DISC_S  = 2'd2;
/*------------------------------------------
            输入接口处理
------------------------------------------*/
//AXI Stream Ready信号处理
//在RAM和DesFIFO仍有空间缓存时将ready信号置高，对于二者均留出一定余量
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)
        s_axis_tready <= 1'b0;
    else
        s_axis_tready <= (bram_free_space > 3'd4) && (desfifo_usedw < 6'd60);
end

//输入数据缓存进RAM
always @* begin
    bram_wr    = ((s_axis_tready == 1'b1) && (s_axis_tvalid == 1'b1));
    bram_waddr = wr_ptr;
    bram_wdata = {s_axis_tuser,s_axis_tdata};
end

//写指针控制
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0)
        wr_ptr <= {DEEP_WIDTH{1'b0}};
    else
        wr_ptr <= (bram_wr == 1'b1) ? (wr_ptr + 1'b1) : wr_ptr;
end

//报文尾部记录当前报文头部地址,同时写入报文地址及描述信息
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        desfifo_wr    <= 1'b0;
        desfifo_wdata <= {DES_BIT{1'b0}};
    end
    else if(s_axis_sop == 1'b1) begin//记录写入地址
        desfifo_wr    <= 1'b0;
        desfifo_wdata[DEEP_WIDTH-1:0] <= bram_waddr;
    end
    else if(s_axis_eop == 1'b1) begin
        desfifo_wr    <= 1'b1;
        desfifo_wdata <= {s_axis_tdest,s_axis_tkeep,s_axis_line_id,desfifo_wdata[DEEP_WIDTH-1:0]};//报文尾部tkeep/报文拍数/地址
    end
    else begin
        desfifo_wr    <= 1'b0;
        desfifo_wdata <= desfifo_wdata;
    end
end

/*------------------------------------------
        RAM读数据及多播报文复制
------------------------------------------*/
always @(posedge axis_clk)begin
    if(axis_rst_n == 1'b0)begin
        bram_free_space <= {1'b1,{(DEEP_WIDTH-1){1'b1}}};
    end
    else begin
        bram_free_space <= bram_free_space-bram_wr+rd_cnt;
    end
end

//在初次时判断时采用描述符FIFO中的值，后续则采用状态机维护的op_bitmap
always @* begin
    if(((trans_state == IDLE_S) || ((|op_bitmap) == 1'b0)) && 
       (desfifo_empty == 1'b0)) begin//空闲状态或者当前报文快要发完时，仍有新的转发请求
        op_bitmap_sel  = desfifo_rdata[DES_BIT-1 : DEEP_WIDTH*2+DATA_BYTE];
    end
    else begin
        op_bitmap_sel  = op_bitmap;
    end
end


always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        rd_cnt        <= {DEEP_WIDTH{1'b0}};
        desfifo_rd    <= 1'b0;
        sel_outport_bit_valid <= 1'b0;
        bram_rd       <= 1'b0;
        bram_raddr    <= {DEEP_WIDTH{1'b0}};
        op_bitmap     <= {STREAM_SUM{1'b0}};
        des_reg       <= {(DATA_BYTE + (DEEP_WIDTH*2)){1'b0}};
        trans_state   <= IDLE_S;
    end
    else begin
        case(trans_state)
            IDLE_S: begin
                rd_cnt       <= {DEEP_WIDTH{1'b0}};
                if((desfifo_empty == 1'b0) && (int_axis_free_space > 32'd8))begin
                //有完整写入的报文(描述符不为空)
                //同时AXIS输出buffer具有足够的缓冲区可以缓存读出的数据(即使模块m_axis_tready为低也能够缓存从RAM中已经读出的数据)
                    desfifo_rd   <= 1'b1;
                    des_reg      <= desfifo_rdata[DEEP_WIDTH*2+DATA_BYTE-1 : 0];//记录报文描述符(除了tdest)，方便后续循环读取
                    if((|desfifo_rdata[DES_BIT-1 : DEEP_WIDTH*2+DATA_BYTE]) == 1'b1)begin//存在单播/组播/广播分组待发送
                        op_bitmap   <= op_bitmap_sel & (~op_onehot);//清除掉输出
                        sel_outport_bit_valid <= 1'b1;
                        sel_outport_bit       <= op_onehot;
                        bram_rd     <= 1'b1;
                        bram_raddr  <= desfifo_rdata[DEEP_WIDTH-1 : 0];
                        trans_state <= TRANS_S;
                    end
                    else begin//丢弃
                        sel_outport_bit_valid <= 1'b0;
                        bram_rd       <= 1'b0;
                        trans_state   <= DISC_S;
                    end
                end
                else begin     
                    desfifo_rd    <= 1'b0;
                    sel_outport_bit_valid <= 1'b0;
                    bram_rd       <= 1'b0;
                    trans_state   <= IDLE_S;
                end
            end
            
            TRANS_S: begin
                if(int_axis_free_space > 32'd8) begin
                    if(bram_raddr == (des_reg[DEEP_WIDTH-1 : 0] + des_reg[DEEP_WIDTH*2-1 : DEEP_WIDTH])) begin//已经读完尾部数据
                        if((|op_bitmap) == 1'b0) begin//已经是最后一个待发送的报文
                            rd_cnt      <= des_reg[DEEP_WIDTH*2-1 : DEEP_WIDTH] + 9'h1;//更新读数量
                            if((desfifo_empty == 1'b0) && (int_axis_free_space > 32'd8))begin
                            //有完整写入的报文(描述符不为空)以及对应的查表结果
                            //同时AXIS输出buffer具有足够的缓冲区可以缓存读出的数据(即使模块m_axis_tready为低也能够缓存从RAM中已经读出的数据)
                                desfifo_rd   <= 1'b1;
                                des_reg      <= desfifo_rdata[DEEP_WIDTH*2+DATA_BYTE-1 : 0];//记录报文描述符(除了tdest)，方便后续循环读取
                                if((|desfifo_rdata[DES_BIT-1 : DEEP_WIDTH*2+DATA_BYTE]) == 1'b1)begin//存在单播/组播/广播分组待发送
                                    op_bitmap     <= op_bitmap_sel & (~op_onehot);//清除掉输出
                                    sel_outport_bit_valid <= 1'b1;
                                    sel_outport_bit       <= op_onehot;
                                    bram_rd       <= 1'b1;
                                    bram_raddr    <= desfifo_rdata[DEEP_WIDTH-1 : 0];
                                    trans_state   <= TRANS_S;
                                end
                                else begin//丢弃
                                    sel_outport_bit_valid     <= 1'b0;
                                    bram_rd      <= 1'b0;
                                    trans_state  <= DISC_S;
                                end
                            end
                            else begin     
                                desfifo_rd    <= 1'b0;
                                sel_outport_bit_valid <= 1'b0;
                                bram_rd       <= 1'b0;
                                trans_state   <= IDLE_S;
                            end
                        end
                        else begin//还有端口需要发送
                            rd_cnt       <= {DEEP_WIDTH{1'b0}};
                            desfifo_rd    <= 1'b0;
                            
                            op_bitmap     <= op_bitmap & (~op_onehot);//更新输出端口
                            sel_outport_bit_valid <= 1'b1;
                            sel_outport_bit       <= op_onehot;
                            
                            bram_rd       <= 1'b1;
                            bram_raddr    <= des_reg[DEEP_WIDTH-1 : 0];
                            trans_state   <= TRANS_S;
                        end
                    end
                    else begin
                        rd_cnt        <= 9'b0;
                        desfifo_rd    <= 1'b0;
                        sel_outport_bit_valid <= 1'b0;
                        
                        bram_rd       <= 1'b1;
                        bram_raddr    <= bram_raddr + 1'b1;
                        trans_state   <= TRANS_S;
                    end
                end
                else begin
                    rd_cnt       <= {DEEP_WIDTH{1'b0}};
                    desfifo_rd    <= 1'b0;
                    sel_outport_bit_valid <= 1'b0;
                    bram_rd       <= 1'b0;
                    trans_state   <= TRANS_S;
                end
            end
            
            DISC_S: begin 
                rd_cnt      <= des_reg[DEEP_WIDTH*2-1 : DEEP_WIDTH] + 9'h1;//更新读数量
                desfifo_rd    <= 1'b0;
                sel_outport_bit_valid <= 1'b0;
                bram_rd       <= 1'b0;
                trans_state   <= IDLE_S;
            end
            
            default: begin
                rd_cnt       <= {DEEP_WIDTH{1'b0}};
                desfifo_rd    <= 1'b0;
                sel_outport_bit_valid <= 1'b0;
                bram_rd       <= 1'b0;
                bram_raddr    <= {DEEP_WIDTH{1'b0}};
                trans_state <= IDLE_S;
            end
        endcase
    end
end

/*------------------------------------------
          读返回数据处理
------------------------------------------*/
//将bram_rd/sel_outport_bit延迟1拍，以便和读响应数据对齐
//同时将sel_outport_bit和锁存des_reg的s_axis_tkeep域，用于生成tdest以及尾部的tkeep
reg [DATA_BYTE-1:0] tkeep_dly;
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'd0) begin
        bram_rd_dly      <= 1'b0;
        bram_rd_last     <= 1'b0;
        tkeep_dly        <= {(DATA_BYTE){1'b0}};
        sel_outport_bit_latch <= {(STREAM_SUM){1'b0}};
    end
    else begin
        bram_rd_dly           <= bram_rd;
        bram_rd_last          <= (bram_raddr == (des_reg[DEEP_WIDTH-1 : 0] + des_reg[DEEP_WIDTH*2-1 : DEEP_WIDTH]));
        tkeep_dly             <= des_reg[DEEP_WIDTH*2+DATA_BYTE-1 : DEEP_WIDTH*2];
        sel_outport_bit_latch <= (sel_outport_bit_valid == 1'b1) ? sel_outport_bit : sel_outport_bit_latch;
    end
end

always @* begin
    int_axis_tvalid = bram_rd_dly;
    int_axis_tkeep  = (int_axis_eop == 1'b0) ? {(DATA_BYTE){1'b1}} : tkeep_dly;
    int_axis_tdata  = bram_rdata[DATA_BYTE*8-1 : 0];
    int_axis_tlast  = bram_rd_last;
    int_axis_tuser  = bram_rdata[RAM_BIT-1 : DATA_BYTE*8];
    int_axis_tdest  = sel_outport_bit_latch;//更新输出端口
end
/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
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

PktLineDet #(DEEP_WIDTH) SaxisLineDet_Inst(
    .user_clk(axis_clk),
    .user_rst_n(axis_rst_n),
        
    .valid(s_axis_tready & s_axis_tvalid),
    .last(s_axis_tlast),
        
    .sop(s_axis_sop),
    .line_id(s_axis_line_id),
    .eop(s_axis_eop)
);

PktLineDet #(2) IntaxisLineDet_Inst(
    .user_clk(axis_clk),
    .user_rst_n(axis_rst_n),
        
    .valid(int_axis_tready & int_axis_tvalid),
    .last(int_axis_tlast),
        
    .sop(int_axis_sop),
    .line_id(int_axis_line_id),
    .eop(int_axis_eop)
);

ParamSdpram # (
    .DATA_WIDTH(RAM_BIT),
    .ADDR_WIDTH(DEEP_WIDTH)
)sync_bram_inst(
    .wrclk (axis_clk ),
    .rdclk (axis_clk ),   
    .aclr  (~axis_rst_n),
    
    .wren  (bram_wr),     
    .waddr (bram_waddr),  
    .wdata (bram_wdata), 
    
    .rden  (bram_rd),      
    .raddr (bram_raddr),    
    .rdata (bram_rdata)
);

bitmap2onehot #(
    .PRIOR_LOW_OR_HIGH(0),
    .WIDTH(STREAM_SUM)
)opbitmap2onehot_inst(
    .i_bitmap(op_bitmap_sel),
    .o_onehot(op_onehot)
);

onehot2binary #(
    .WIDTH(STREAM_LOG)
)oponehot2bin_inst(
    .i_onehot(sel_outport_bit_latch + {(2**STREAM_LOG){1'b0}}),//累加2**STREAM_LOG,以保障仿真输入的数据无高阻态
    .o_bin  (op_binary )
);

ParamSyncFifo #(
    .DATA_WIDTH(DES_BIT),
    .ADDR_WIDTH(6)
)sync_desfifo_inst(
    .clk    (axis_clk     ),
    .aclr   (~axis_rst_n  ),
            
    .wrreq  (desfifo_wr   ),
    .data   (desfifo_wdata),
    .rdreq  (desfifo_rd   ),
    .q      (desfifo_rdata),
            
    .usedw  (desfifo_usedw),
    .full   (desfifo_full ),
    .empty  (desfifo_empty)
);

AXISFifoBuf#(
    .ASYNC_EN  (0 ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH(6 ),//缓存FIFO的容量的指数位宽
    .PKT_MODE  (0 ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE (DATA_BYTE),
    .USER_BIT  (USER_BIT+STREAM_SUM)
)IntSAXIFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk  (axis_clk  ),
    .s_axis_rst_n(axis_rst_n),
    .m_axis_clk  (axis_clk  ),
    .m_axis_rst_n(axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(int_axis_tready),
    .s_axis_tvalid(int_axis_tvalid),
    .s_axis_tkeep (int_axis_tkeep ),
    .s_axis_tdata (int_axis_tdata ),
    .s_axis_tlast (int_axis_tlast ),
    .s_axis_tuser ({int_axis_tuser,int_axis_tdest}),    
//AXI Stream输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser ({m_axis_tuser,m_axis_tdest}),
    
    .free_space   (int_axis_free_space)
);

endmodule
/*
AXISDestSplit # (
    .STREAM_SUM(),//支持分派的的AXIStream流数量,默认值为8
    .DEEP_WIDTH(),//默认值为9,
    .DATA_BYTE (),//默认值为16,
    .USER_BIT  () //默认值为1
)APDS_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//分组数据输入接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
    .s_axis_tdest (),
//分组数据输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
    .m_axis_tdest ()
);
*/