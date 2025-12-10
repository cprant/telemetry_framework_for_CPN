/*------------------------------------------------------------
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
------------------------------------------------------------
Vendor C2Comm
Version 1.0
Filename  SyncTimeCDC.v
Target Device All
Dscription 
    1)维护本地时钟计数器
    2)检测输入的时钟计数器，当二者出现更新后发起更新请求更新本地时钟

Data_Struct:

Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module SyncTimeCDC #(
    parameter   SRC_STEP   = 32'h8_0000,
                DST_STEP   = 32'h6_6667,
                INIT_DLY   = 3,//应当大于src_clk和dst_clk之间的倍率
                TIME_WIDTH = 64,
                TIME_REGDLY = 1
)(
//时钟复位信号
    input  wire                   src_clk,
    input  wire                   src_rst_n,
    input  wire                   dst_clk,
    input  wire                   dst_rst_n,
                            
    input  wire  [          31:0] iv_sync_period ,
    input  wire  [TIME_WIDTH-1:0] iv_max_synctime,
//本地设备时钟复位信号
    input  wire  [TIME_WIDTH-1:0] iv_synctime,
//时间槽和设备时钟输出
    output reg   [TIME_WIDTH-1:0] ov_synctime
);
/*--------------------------------------------------
                    中间变量声明区域
--------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam DLY_SUM         = (INIT_DLY > 3) ? INIT_DLY : 3;//保障至少有3拍延时来进行亚稳态

localparam COMPENSATE_TIME = SRC_STEP + (DLY_SUM+2)*DST_STEP;//同步补偿延时，补偿对时的过程中延时的时间

reg  [TIME_WIDTH-1:0] src_synctime_reg;
             
reg  [          31:0] src_update_period_cnt;
reg                   src_update_flag;
reg  [TIME_WIDTH-1:0] src_update_synctime;
     
reg  [TIME_WIDTH-1:0] dst_update_synctime;
reg                   dst_done_flag;
reg                   dst_update_req;

wire                  sync_src_update_flag;
wire                  sync_dst_done_flag;

wire [TIME_WIDTH-1:0] wv_synctime;

reg [1:0] src_state;
localparam  SRC_IDLE_S = 2'd0,
            SRC_UPDATE_S = 2'd1,
            SRC_RELEASE_S = 2'd2;
            
reg [1:0] dst_state;
localparam  DST_IDLE_S    = 2'd0,
            DST_UPDATE_S  = 2'd1,
            DST_RELEASE_S = 2'd2;
/*--------------------------------------------------
                输入时钟缓存
--------------------------------------------------*/
//对于输入的时钟，通过寄存器打拍，以减少时钟布线路径，优化时序
generate
    if(TIME_REGDLY == 1) begin
        reg [TIME_WIDTH-1:0] rv_synctime;
        always @(posedge src_clk or negedge src_rst_n) begin
            if(src_rst_n == 1'b0) begin
                rv_synctime <= {(TIME_WIDTH){1'b0}};
            end
            else begin
                rv_synctime <= ((iv_synctime + SRC_STEP) < iv_max_synctime) ? 
                                iv_synctime + SRC_STEP : iv_synctime + SRC_STEP - iv_max_synctime;
            end
        end
        
        assign wv_synctime = rv_synctime;
    end
    else if(TIME_REGDLY > 1) begin
        reg [TIME_WIDTH*TIME_REGDLY-1:0] rv_synctime;
        always @(posedge src_clk or negedge src_rst_n) begin
            if(src_rst_n == 1'b0) begin
                rv_synctime <= {(TIME_WIDTH*TIME_REGDLY){1'b0}};
            end
            else begin
                rv_synctime[TIME_WIDTH*TIME_REGDLY-1:TIME_WIDTH] <= rv_synctime[0 +: (TIME_REGDLY-1)*TIME_WIDTH];
                
                rv_synctime[0 +: TIME_WIDTH] <= ((iv_synctime + TIME_WIDTH*TIME_REGDLY) < iv_max_synctime) ? 
                                                  iv_synctime + TIME_WIDTH*TIME_REGDLY : iv_synctime + TIME_WIDTH*TIME_REGDLY - iv_max_synctime;
            end
        end
        
        assign wv_synctime = rv_synctime[TIME_WIDTH*TIME_REGDLY-1 -: TIME_WIDTH];
    end
    else begin
    
        assign wv_synctime = iv_synctime;
    end
endgenerate
/*--------------------------------------------------
                输入时钟检测
--------------------------------------------------*/
always @(posedge src_clk or negedge src_rst_n) begin
    if(src_rst_n == 1'b0)
        src_synctime_reg <= {TIME_WIDTH{1'b0}};
    else
        src_synctime_reg <= wv_synctime;
end


always @(posedge src_clk or negedge src_rst_n) begin
    if(src_rst_n == 1'b0) begin
        src_update_period_cnt <= 32'b0;
        src_update_flag       <= 1'b0;
        src_update_synctime   <= {TIME_WIDTH{1'b0}};
        src_state             <= SRC_IDLE_S;
    end
    else begin
        case(src_state)
            SRC_IDLE_S: begin
                src_update_synctime   <= wv_synctime;
                if(((wv_synctime > src_synctime_reg) && ((wv_synctime - src_synctime_reg) > SRC_STEP)) || 
                    (wv_synctime <= src_synctime_reg) || 
                    (src_update_period_cnt >= iv_sync_period)) begin
                //理论上输入应当比上一拍大，否则，要么修正跳回了，要么是累加到最大值跳圈了，都需要发起更新
                //iv_synctime更新/跳圈、以及超时更新
                    src_update_period_cnt <= 32'd0;
                    src_update_flag       <= 1'b1;
                    src_state             <= SRC_UPDATE_S;
                end
                else begin
                    src_update_period_cnt <= src_update_period_cnt + 1'b1;
                    src_update_flag    <= 1'b0;
                    src_state          <= SRC_IDLE_S;
                end
            end
            
            SRC_UPDATE_S: begin
                src_update_period_cnt <= 32'd0;
                src_update_synctime   <= src_update_synctime;
                if(sync_dst_done_flag == 1'b1) begin//对端接收到请求并完成更新
                    src_update_flag    <= 1'b0;
                    src_state          <= SRC_RELEASE_S;
                end
                else begin
                    src_update_flag    <= 1'b1;
                    src_state          <= SRC_UPDATE_S;
                end
            end
            
            SRC_RELEASE_S: begin//等待对端完成信号释放
                src_update_period_cnt <= 32'd0;
                src_update_flag       <= 1'b0;
                src_update_synctime   <= src_update_synctime;
                if(sync_dst_done_flag == 1'b1) begin//对端完成信号未释放
                    src_state         <= SRC_RELEASE_S;
                end
                else begin
                    src_state         <= SRC_IDLE_S;
                end
            end
            
            default:  begin
                src_update_period_cnt <= 32'b0;
                src_update_flag       <= 1'b0;
                src_update_synctime   <= {TIME_WIDTH{1'b0}};
                src_state             <= SRC_IDLE_S;
            end
        endcase
    end
end

/*--------------------------------------------------
                同步化src时钟
--------------------------------------------------*/
always @(posedge dst_clk or negedge dst_rst_n) begin
    if(dst_rst_n == 1'b0) begin
        dst_update_req       <= 1'b0;
        dst_update_synctime  <= {TIME_WIDTH{1'b0}};
        dst_done_flag        <= 1'b0;
        dst_state            <= DST_IDLE_S;
    end
    else begin
        case(dst_state)
            DST_IDLE_S: begin
                dst_done_flag      <= 1'b0;
                if(sync_src_update_flag == 1'b1) begin//接收到更新请求
                    dst_update_req      <= 1'b1;
                    dst_update_synctime <= src_update_synctime;
                    dst_state           <= DST_UPDATE_S;
                end
                else begin
                    dst_update_req      <= 1'b0;
                    dst_update_synctime <= dst_update_synctime;
                    dst_state           <= DST_IDLE_S;
                end
            end
            
            DST_UPDATE_S: begin
                dst_update_req      <= 1'b0;
                dst_update_synctime <= dst_update_synctime;
                if(sync_src_update_flag == 1'b1) begin//对端请求信号未释放
                    dst_done_flag   <= 1'b1;
                    dst_state         <= DST_UPDATE_S;
                end
                else begin
                    dst_done_flag   <= 1'b0;
                    dst_state         <= DST_RELEASE_S;
                end
            end
            
            DST_RELEASE_S: begin//完成更新并释放
                dst_update_req      <= 1'b0;
                dst_update_synctime <= dst_update_synctime;
                dst_done_flag     <= 1'b0;
                if(sync_src_update_flag == 1'b1) begin//对端请求信号未释放
                    dst_state         <= DST_RELEASE_S;
                end
                else begin
                    dst_state         <= DST_IDLE_S;
                end
            end
            
            default:  begin
                dst_update_req       <= 1'b0;
                dst_update_synctime  <= {TIME_WIDTH{1'b0}};
                dst_done_flag      <= 1'b0;
                dst_state            <= DST_IDLE_S;
            end
        endcase
    end
end

always @(posedge dst_clk or negedge dst_rst_n) begin
    if(dst_rst_n == 1'b0) begin
        ov_synctime <= {TIME_WIDTH{1'b0}};
    end
    else if(dst_update_req == 1'b1) begin
        ov_synctime <= (dst_update_synctime >= (iv_max_synctime - COMPENSATE_TIME)) ? 
                        dst_update_synctime + COMPENSATE_TIME -iv_max_synctime : dst_update_synctime + COMPENSATE_TIME;
    end
    else begin
        ov_synctime <= (ov_synctime >= (iv_max_synctime - DST_STEP)) ? 
                        ov_synctime + DST_STEP - iv_max_synctime : ov_synctime + DST_STEP;
    end
end

/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
SyncSig #(
    .SYNC_REGS(DLY_SUM),
    .POLAR    (0),
    .STRICT   (1)
)DstSync_src_update_flag_Inst(
    .clk    (dst_clk),
    .rst_n  (dst_rst_n),
    .in_sig (src_update_flag),
    .out_sig(sync_src_update_flag)
);

SyncSig #(
    .SYNC_REGS(DLY_SUM),
    .POLAR    (0),
    .STRICT   (1)
)SrcSync_dst_done_flag_Inst(
    .clk    (src_clk),
    .rst_n  (src_rst_n),
    .in_sig (dst_done_flag),
    .out_sig(sync_dst_done_flag)
);
endmodule
/*SyncTimeCDC #(
    .SRC_STEP               ( 32'h6_6667    ),
    .DST_STEP               ( 32'h6_6667    ),
    .INIT_DLY               ( 3             ),
    .TIME_WIDTH             ( 64            )
)SyncTimeCDC_Inst(
    //时钟复位信号
    .src_clk                (),
    .src_rst_n              (),
    .dst_clk                (),
    .dst_rst_n              (),
                            
    .iv_sync_period         (),
    .iv_max_synctime        (),
    //输入本地时钟        
    .iv_synctime            (),
    //输出本地时钟        
    .ov_synctime            ()
);
*/