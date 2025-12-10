/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  LbExt.v
Target Device All
Dscription 
    1) 将Localbus总线传输的数据进行拼接，例如将2次32bit数据写入拼接为64bit数据
    2) 支持从高到底写入或从低到高写入，具体顺序由参数确定
Data_Struct:
    1)
    
Caution: 
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module LbExt #(
    parameter   ASYNC_MODE   = 1,
                CFG_ORDER    = 1,//0:从低到高，最后一个配置的是高地址   1:从高到低，最后一个配置的低地址
                LB_ADDR_WID  = 32,
                LB_DATA_WID  = 32,
                EXT_ADDR_WID =  4,
                EXT_DATA_SUM = 10
)(
//时钟复位信号
    input  wire                                clk,
    input  wire                                rst_n,
//输入Localbus信号                
    input  wire                                s_lb_cs_n,
    output reg                                 s_lb_ack_n,
    input  wire                                s_lb_wr_rd,//0:wr  1:rd
    input  wire [             LB_ADDR_WID-1:0] s_lb_addr,
    input  wire [             LB_DATA_WID-1:0] s_lb_wdata,
    output reg  [             LB_DATA_WID-1:0] s_lb_rdata,
//输出Localbus信号
    output reg                                 m_lb_cs_n,
    input  wire                                m_lb_ack_n,
    output wire                                m_lb_wr_rd,//0:wr  1:rd
    output wire [LB_ADDR_WID-EXT_ADDR_WID-1:0] m_lb_addr,
    output reg  [LB_DATA_WID*EXT_DATA_SUM-1:0] m_lb_wdata,
    input  wire [LB_DATA_WID*EXT_DATA_SUM-1:0] m_lb_rdata
);

/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire sync_s_cs_n;
wire sync_m_ack_n;

reg  [LB_DATA_WID-1:0] wr_extdata [EXT_DATA_SUM-1:0];
reg  [LB_DATA_WID-1:0] rd_extdata [EXT_DATA_SUM-1:0];

reg [1:0] ext_state;

localparam  IDLE_S    = 2'd0,
            MTR_ACK_S = 2'd1,
            SLV_RLS_S = 2'd2; 
/*----------------------------------------------------------
                    Localbus扩展
----------------------------------------------------------*/
localparam  LAST_REQ = (CFG_ORDER == 0) ?  EXT_DATA_SUM-1 : 0;

generate 
    genvar i;
    for(i=0; i<EXT_DATA_SUM; i=i+1) begin:LBDwordAssign
        always @(*) begin
            m_lb_wdata[i*LB_DATA_WID +: LB_DATA_WID] = wr_extdata[                           i];
            rd_extdata[                           i] = m_lb_rdata[i*LB_DATA_WID +: LB_DATA_WID];
        end
    end
endgenerate

assign m_lb_addr  = s_lb_addr[LB_ADDR_WID-1:EXT_ADDR_WID];
assign m_lb_wr_rd = s_lb_wr_rd;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        s_lb_ack_n <= 1'b1;
        m_lb_cs_n  <= 1'b1;
        ext_state <= IDLE_S;
    end
    else begin
        case(ext_state)
            IDLE_S: begin
                s_lb_rdata <= {LB_DATA_WID*EXT_DATA_SUM{1'b0}};
                if((sync_s_cs_n == 1'b0) && (s_lb_wr_rd == 1'b0) && (sync_m_ack_n == 1'b1)) begin//写请求且m_lb已释放
                    if(s_lb_addr[EXT_ADDR_WID-1:0] == LAST_REQ) begin//当前传输的是最后一个分段
                        s_lb_ack_n <= 1'b1;
                        m_lb_cs_n  <= 1'b0;
                        wr_extdata[s_lb_addr[EXT_ADDR_WID-1:0]] <= s_lb_wdata;
                        ext_state  <= MTR_ACK_S;
                    end
                    else if(s_lb_addr[EXT_ADDR_WID-1:0] < (EXT_DATA_SUM-1)) begin
                    //当前传输的是指定的EXT_DATA_SUM有效数量内，但未到最后一个分段
                        s_lb_ack_n <= 1'b0;
                        m_lb_cs_n  <= 1'b1;
                        wr_extdata[s_lb_addr[EXT_ADDR_WID-1:0]] <= s_lb_wdata;
                        ext_state <= SLV_RLS_S;
                    end
                    else begin//未定义地址写入
                        s_lb_ack_n <= 1'b0;
                        m_lb_cs_n  <= 1'b1;
                        ext_state  <= SLV_RLS_S;
                    end
                end
                else if((sync_s_cs_n == 1'b0) && (s_lb_wr_rd == 1'b1) && (sync_m_ack_n == 1'b1)) begin//读请求且m_lb已释放
                    if(s_lb_addr[EXT_ADDR_WID-1:0] <= (EXT_DATA_SUM-1)) begin
                    //当前传输的是指定的EXT_DATA_SUM有效数量内
                        s_lb_ack_n <= 1'b1;
                        m_lb_cs_n  <= 1'b0;
                        ext_state <= MTR_ACK_S;
                    end
                    else begin//未定义地址写入
                        s_lb_ack_n <= 1'b0;
                        m_lb_cs_n  <= 1'b1;
                        ext_state  <= SLV_RLS_S;
                    end
                end
                else begin
                    s_lb_ack_n <= 1'b1;
                    m_lb_cs_n  <= 1'b1;
                    ext_state <= IDLE_S;
                end
            end
            
            MTR_ACK_S: begin
                s_lb_rdata <= rd_extdata[s_lb_addr[EXT_ADDR_WID-1:0]];
                if(sync_m_ack_n == 1'b0) begin//m_lb的请求响应返回，开始返回s_lb的请求响应
                    s_lb_ack_n <= 1'b0;
                    m_lb_cs_n  <= 1'b1;
                    ext_state  <= SLV_RLS_S;
                end
                else begin
                    s_lb_ack_n <= 1'b1;
                    m_lb_cs_n  <= 1'b0;
                    ext_state  <= MTR_ACK_S;
                end
            end
            
            SLV_RLS_S: begin
                if(sync_s_cs_n == 1'b1) begin//s_lb的请求释放OK
                    s_lb_ack_n <= 1'b1;
                    ext_state  <= IDLE_S;
                end
                else begin
                    s_lb_ack_n <= 1'b0;
                    ext_state  <= SLV_RLS_S;
                end
            end
            
            default: begin
                s_lb_ack_n <= 1'b1;
                m_lb_cs_n  <= 1'b1;
                ext_state <= IDLE_S;
            end
        endcase
    end
end

/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
generate
    if(ASYNC_MODE == 1) begin
        SyncSig #(
            .SYNC_REGS(2),
            .POLAR    (1'b1),
            .STRICT   (0)
        )cs_syncsig_inst(
            .clk    (clk),
            .rst_n  (rst_n),
            .in_sig (s_lb_cs_n),
            .out_sig(sync_s_cs_n)
        );

        SyncSig #(
            .SYNC_REGS(2),
            .POLAR    (1'b1),
            .STRICT   (0)
        )ack_syncsig_inst(
            .clk    (clk),
            .rst_n  (rst_n),
            .in_sig (m_lb_ack_n),
            .out_sig(sync_m_ack_n)
        );
    end
    else begin
        assign sync_s_cs_n  = s_lb_cs_n;
        assign sync_m_ack_n = m_lb_ack_n;
    end
endgenerate

endmodule
/*
LbExt #(
    .ASYNC_MODE   (),
    .CFG_ORDER    (),//0:从低到高，最后一个配置的是高地址   1:从高到低，最后一个配置的低地址
    .LB_ADDR_WID  (),
    .LB_DATA_WID  (),
    .EXT_ADDR_WID (),
    .EXT_DATA_SUM ()
)LbExt_Inst(
//时钟复位信号
    .clk  (),
    .rst_n(),
//输入Localbus信号                
    .s_lb_cs_n (),
    .s_lb_ack_n(),
    .s_lb_wr_rd(),//0:wr  1:rd
    .s_lb_addr (),
    .s_lb_wdata(),
    .s_lb_rdata(),
//输出Localbus信号
    .m_lb_cs_n (),
    .m_lb_ack_n(),
    .m_lb_wr_rd(),//0:wr  1:rd
    .m_lb_addr (),
    .m_lb_wdata(),
    .m_lb_rdata()
);
*/