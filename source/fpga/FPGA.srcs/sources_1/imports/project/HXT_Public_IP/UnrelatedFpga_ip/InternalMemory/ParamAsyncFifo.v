////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  ParamAsyncFifo.v
Target Device All
Dscription 
    1)基于参数化的通用异步FIFO
    2)支持在不同FPGA平台通用
    3)但相比FPGA平台生成的Build-In FIFO IP，存在一定的资源浪费
      因为FPGA平台生成的IP是使用的RAM自带的寄存器资源，不占用本身的寄存器资源
    
Data_Struct:

Caution:
    1)
Author : lxj
Revision List:
	rn2:	date:	modifier:	description:
	rn2:	date:	modifier:	description:
*/
module ParamAsyncFifo #(
    parameter   ADDR_WIDTH = 4,
                DATA_WIDTH = 64
)(
//时钟复位
    input  wire                  wrclk,
    input  wire                  rdclk,
    input  wire                  aclr ,
//FIFO读写接口  
    input  wire                  wrreq,
    input  wire                  rdreq,  
    input  wire [DATA_WIDTH-1:0] data , 
    output wire [DATA_WIDTH-1:0] q    ,
//FIFO状态信号
    output reg  [ADDR_WIDTH-1:0] rdusedw,
    output reg  [ADDR_WIDTH-1:0] wrusedw,
    output wire                  wrfull,
    output wire                  rdfull,
    output wire                  empty
);
/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
//RAM接口
wire                  sdpram_wren ;
reg  [  ADDR_WIDTH:0] sdpram_waddr;
wire [DATA_WIDTH-1:0] sdpram_wdata;
    
wire                  sdpram_rden ;
reg  [  ADDR_WIDTH:0] sdpram_raddr;
wire [DATA_WIDTH-1:0] sdpram_rdata;
    
wire [  ADDR_WIDTH:0] rdusedw_comb;
wire [  ADDR_WIDTH:0] wrusedw_comb;


wire [  ADDR_WIDTH:0] waddr_next;

reg  [           1:0] pre_rd_cnt;
wire                  fifoctrl_pre_rdreq;
wire [  ADDR_WIDTH:0] raddr_next;
reg  [           0:0] rdreq_dly;//由于RAM有1拍延时，将读请求延时后标记返回的数据
wire                  rdata_valid;

reg  [  DATA_WIDTH:0] rdata_buff    [1:0];
reg  [  DATA_WIDTH:0] rdata_pipeline[1:0];
wire [           1:0] buffer_valid_flag  ;
wire [           1:0] pipeline_valid_flag;

wire [  ADDR_WIDTH:0] raddr_gray,raddr_bin_wrclksync;
wire [  ADDR_WIDTH:0] waddr_gray,waddr_bin_rdclksync;

reg  [  ADDR_WIDTH:0] raddr_gray_reg;
reg  [  ADDR_WIDTH:0] waddr_gray_reg;

reg  [  ADDR_WIDTH:0] raddr_gray_wrclksync [1:0];
reg  [  ADDR_WIDTH:0] waddr_gray_rdclksync [1:0];
/***************************************
            异步FIFO写控制
****************************************/
assign sdpram_wren  = wrreq;
assign sdpram_wdata = data;

assign waddr_next   = sdpram_waddr + sdpram_wren;

always @(posedge wrclk or posedge aclr)
    if(aclr == 1'b1) sdpram_waddr <= {(ADDR_WIDTH+1){1'b0}};
    else             sdpram_waddr <= waddr_next;
/***************************************
            异步FIFO读控制
****************************************/
//RAM的读请求除了用户本身的读以外，还有FIFO的预读(用于掩盖RAM本身的2拍延时)，但在RAM是空的时候不能读
assign sdpram_rden = (|rdusedw_comb[ADDR_WIDTH-1:0] == 1'b0) ? 1'b0 : fifoctrl_pre_rdreq | rdreq;

assign raddr_next  = sdpram_raddr + sdpram_rden;

always @(posedge rdclk or posedge aclr)
    if(aclr == 1'b1) sdpram_raddr <= {(ADDR_WIDTH+1){1'b0}};
    else              sdpram_raddr <= raddr_next;


//FIFO的预读，用于掩盖RAM本身的2拍延时
assign fifoctrl_pre_rdreq = (pre_rd_cnt < 2'b10);//预读2拍数据

always @(posedge rdclk or posedge aclr) begin
    if(aclr == 1'b1) begin
        pre_rd_cnt <= 2'b0;
    end
    else begin
        pre_rd_cnt <= pre_rd_cnt + sdpram_rden - rdreq;
    end
end

//由于RAM有1拍延时，将读请求延时后标记返回的数据
always @(posedge rdclk or posedge aclr) begin
    if(aclr == 1'b1) begin
        rdreq_dly <= 1'b0;
    end
    else begin
        rdreq_dly <= sdpram_rden;
    end
end

assign rdata_valid = rdreq_dly;



//缓存并管理从RAM中读出并缓存的2级数据
assign buffer_valid_flag   = {rdata_buff[1][DATA_WIDTH],
                              rdata_buff[0][DATA_WIDTH]};
                              
assign pipeline_valid_flag = {rdata_pipeline[1][DATA_WIDTH],
                              rdata_pipeline[0][DATA_WIDTH]};

always @ (*) begin
    case({rdreq,rdata_valid})
        2'b00: begin
            rdata_pipeline[0] = rdata_buff[0];
            rdata_pipeline[1] = rdata_buff[1];
        end
        
        2'b01: begin
            case(buffer_valid_flag)
                2'b00: begin
                    rdata_pipeline[0] = rdata_buff[0];
                    rdata_pipeline[1] = {1'b1,sdpram_rdata};
                end
                
                2'b01: begin
                    rdata_pipeline[0] = {1'b1,sdpram_rdata};
                    rdata_pipeline[1] = rdata_buff[0];
                end
                
                2'b10: begin
                    rdata_pipeline[0] = {1'b1,sdpram_rdata};
                    rdata_pipeline[1] = rdata_buff[1];
                end
                
                2'b11: begin//理论上不应该出现
                    rdata_pipeline[0] = {1'b1,sdpram_rdata};
                    rdata_pipeline[1] = rdata_buff[1];
                    //$display("[%m] sdpram Read Output Cache overflow,time=%10d",$time);
                end
            endcase
        end

        2'b10: begin
            rdata_pipeline[0]= {1'b0,rdata_buff[0][DATA_WIDTH-1:0]};
            rdata_pipeline[1] = rdata_buff[0];
        end
        
        2'b11: begin
            case(buffer_valid_flag)
                2'b10: begin
                    rdata_pipeline[0] = rdata_buff[0];
                    rdata_pipeline[1] = {1'b1,sdpram_rdata};
                end
                
                2'b11: begin
                    rdata_pipeline[0] = {1'b1,sdpram_rdata};
                    rdata_pipeline[1] = rdata_buff[0];
                end
                
                default: begin
                    rdata_pipeline[0] = rdata_buff[0];
                    rdata_pipeline[1] = rdata_buff[1];
                    //$display("[%m] sdpram Read Output Cache Head Error=%10d",$time);
                end
            endcase
            
        end
    endcase
end


always @(posedge rdclk or posedge aclr) begin
    if(aclr == 1'b1) begin
        rdata_buff[0] <= {(DATA_WIDTH+1){1'b0}};
        rdata_buff[1] <= {(DATA_WIDTH+1){1'b0}};
    end
    else begin
        rdata_buff[0] <= rdata_pipeline[0];
        rdata_buff[1] <= rdata_pipeline[1];
    end
end

assign q = rdata_buff[1][DATA_WIDTH-1:0];

/***************************************
            异步FIFO统计状态维护
****************************************/
always @(posedge wrclk) waddr_gray_reg <= waddr_gray;
always @(posedge rdclk) begin
    waddr_gray_rdclksync[0] <= waddr_gray_reg;//在读时钟域接收并缓存格雷码写地址
    waddr_gray_rdclksync[1] <= waddr_gray_rdclksync[0];
end

always @(posedge rdclk) raddr_gray_reg <= raddr_gray;
always @(posedge wrclk) begin
    raddr_gray_wrclksync[0] <= raddr_gray_reg;//在写时钟域接收并缓存格雷码读地址
    raddr_gray_wrclksync[1] <= raddr_gray_wrclksync[0];
end

                            
assign wrusedw_comb = waddr_next - raddr_bin_wrclksync;//no need precise
always @(posedge wrclk or posedge aclr) begin
    if(aclr == 1'b1) begin
        wrusedw <= {(ADDR_WIDTH){1'b0}};
    end
    else begin
        if((waddr_next[ADDR_WIDTH] == raddr_bin_wrclksync[ADDR_WIDTH]) && 
           (waddr_next[ADDR_WIDTH-1:0] < raddr_bin_wrclksync[ADDR_WIDTH-1:0]) )begin
            wrusedw <= wrusedw;
        end
        else begin
            wrusedw <= wrusedw_comb[ADDR_WIDTH-1:0];//no need precise
        end
       
    end
end


assign rdusedw_comb = waddr_bin_rdclksync - sdpram_raddr;
// + pre_rd_cnt + sdpram_rden - rdreq; ??need be solve
always @(posedge rdclk or posedge aclr) begin
    if(aclr == 1'b1) begin
        rdusedw <= {(ADDR_WIDTH){1'b0}};
    end
    else begin
        if((waddr_bin_rdclksync[ADDR_WIDTH] == sdpram_raddr[ADDR_WIDTH]) && 
           (waddr_bin_rdclksync[ADDR_WIDTH-1:0] < sdpram_raddr[ADDR_WIDTH-1:0]))begin
            rdusedw <= rdusedw;
        end
        else begin
            rdusedw <= rdusedw_comb[ADDR_WIDTH-1:0] + pipeline_valid_flag[0]+ pipeline_valid_flag[1] - sdpram_rden;
        end
    end
end
assign empty = ~(buffer_valid_flag[1] & pipeline_valid_flag[1]);
assign wrfull = &wrusedw[ADDR_WIDTH-1:1];
assign rdfull = &rdusedw[ADDR_WIDTH-1:1];

/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
binary2gray #(
    .WIDTH(ADDR_WIDTH+1)
)waddr_gray_inst(
    .i_bin(sdpram_waddr),
    .o_gray(waddr_gray)
);

binary2gray #(
    .WIDTH(ADDR_WIDTH+1)
)raddr_gray_inst(
    .i_bin(sdpram_raddr),
    .o_gray(raddr_gray)
);

gray2binary #(
    .WIDTH(ADDR_WIDTH+1)
)waddr_bin_rdclksync_inst(
    .i_gray(waddr_gray_rdclksync[1]),
    .o_bin(waddr_bin_rdclksync)
);

gray2binary #(
    .WIDTH(ADDR_WIDTH+1)
)raddr_bin_wrclksync_inst(
    .i_gray(raddr_gray_wrclksync[1]),
    .o_bin(raddr_bin_wrclksync)
);

ParamSdpram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
)ParamSdpram_inst(
    .wrclk (wrclk ),
    .rdclk (rdclk ),     
    .aclr  (aclr  ),
    //写端口
    .wren  (sdpram_wren ),
    .waddr (sdpram_waddr[ADDR_WIDTH-1:0]),
    .wdata (sdpram_wdata),
    //读端口
    .rden  (sdpram_rden ),
    .raddr (sdpram_raddr[ADDR_WIDTH-1:0]),
    .rdata (sdpram_rdata)
);

endmodule
/*
ParamAsyncFifo #(
    .ADDR_WIDTH(),
    .DATA_WIDTH()
)ParamAsyncFifo_Inst(
//时钟复位
    .wrclk  (),
    .rdclk  (),
    .aclr   (),
//FIFO读写接口  
    .wrreq(),
    .rdreq(),  
    .data (), 
    .q    (),
//FIFO状态信号
    .rdusedw(),
    .wrusedw(),
    .wrfull (),
    .rdfull (),
    .empty()
);
*/