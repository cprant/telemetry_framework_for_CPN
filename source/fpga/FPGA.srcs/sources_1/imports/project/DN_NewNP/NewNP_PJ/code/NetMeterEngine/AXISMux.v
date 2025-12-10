/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  AXISMux.v
Target Device All
Dscription 
    1)支持多路AXI Stream接口的汇聚和转发
    2)支持报文处理模式和流模式
        0：流处理模式，随到随取  
        1：报文处理模式，接收完整报文后再取出发送
    3)支持同步和异步两种模式

Data_Struct:
    1)

Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module AXISMux#(
    parameter ASYNC_EN   = 1,//同步或异步  0：同步  1：异步
              PKT_MODE   = 0,//处理模式，0：流处理模式  1：报文处理模式
              STREAM_SUM = 8,//支持汇聚的的AXIStream流数量
              DEEP_WIDTH = 5,//缓存FIFO的容量的指数位宽
              DATA_BYTE  = 8,
              USER_BIT   = 1,
              MIN_PKTLINE= 8
)
(
//时钟复位信号
    input  wire [            STREAM_SUM-1:0] s_axis_clk,
    input  wire [            STREAM_SUM-1:0] s_axis_rst_n,
    input  wire                              m_axis_clk,
    input  wire                              m_axis_rst_n,
//固定优先级接口
    input  wire [            STREAM_SUM-1:0] iv_fix_prior,
//报文分组数据接收接口
    output wire [            STREAM_SUM-1:0] s_axis_tready,
    input  wire [            STREAM_SUM-1:0] s_axis_tvalid,
    input  wire [  STREAM_SUM*DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [STREAM_SUM*DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire [            STREAM_SUM-1:0] s_axis_tlast,
    input  wire [   STREAM_SUM*USER_BIT-1:0] s_axis_tuser,
//BE分组数据输出接口
    input  wire                              m_axis_tready,
    output wire                              m_axis_tvalid,
    output wire [             DATA_BYTE-1:0] m_axis_tkeep,
    output wire [           DATA_BYTE*8-1:0] m_axis_tdata,
    output wire                              m_axis_tlast,
    output wire [              USER_BIT-1:0] m_axis_tuser
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明  
function [31:0] clogb2;
    input [31:0] depth;
    reg [31:0] i,result;
    begin
        for(i=0;2**i<depth;i=i+1)
            result=i+1;
        clogb2=i;//返回的结果是i，即求幂的逆计算
    end
endfunction

//计算流数量的二进制,以及2的幂次方，用于后续的调度计算，详见后续代码onehot2binary的应用
localparam  STREAM_SUM_BIN = clogb2(STREAM_SUM),
            STREAM_SUM_POW = 2**clogb2(STREAM_SUM);
    
reg  [    STREAM_SUM-1:0] grant_req;
reg                       grant_get;
wire [    STREAM_SUM-1:0] grant_prior;
reg  [    STREAM_SUM-1:0] grant_reg;
wire [STREAM_SUM_BIN-1:0] grant_reg_bin;

wire [  7:0] sel_axis_line_id;
wire         sel_axis_sop;
wire         sel_axis_eop;

reg  [ STREAM_SUM-1:0] int_axis_tready ;
wire [ STREAM_SUM-1:0] int_axis_tvalid ;
wire [  DATA_BYTE-1:0] int_axis_tkeep  [STREAM_SUM-1:0];
wire [DATA_BYTE*8-1:0] int_axis_tdata  [STREAM_SUM-1:0];
wire [ STREAM_SUM-1:0] int_axis_tlast  ;
wire [   USER_BIT-1:0] int_axis_tuser  [STREAM_SUM-1:0];

wire [            0:0] sel_axis_tready;        
reg  [            0:0] sel_axis_tvalid;
reg  [  DATA_BYTE-1:0] sel_axis_tkeep ;
reg  [DATA_BYTE*8-1:0] sel_axis_tdata ;
reg  [            0:0] sel_axis_tlast ;
reg  [   USER_BIT-1:0] sel_axis_tuser ;

//调度固定优先级,赋予默认值，防止输入的优先级为赋值，默认的高阻态阻碍仿真
reg  [ STREAM_SUM-1:0] wv_fix_prior = {STREAM_SUM{1'b1}};

reg  [            0:0] grant_state;

localparam  IDLE_S = 1'b0,
            SEND_S = 1'b1;
/*----------------------------------------------------------
                   调度处理
----------------------------------------------------------*/
always @(*) wv_fix_prior = iv_fix_prior;

//调度条件是对应Buf有且开始发送数据
//选择的依据是Buffer有数据正在发送且没有被接收
//由于grant_state中根据报文尾更新grant_req时，int_axis_tvalid必定为高，因此不能直接使用tvalid作为grant_req
always @(*) grant_req = (int_axis_tvalid & (~grant_reg));

always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        grant_reg   <= {STREAM_SUM{1'b0}};
        grant_get   <= 1'b0;
        grant_state <= IDLE_S;
    end
    else begin
        case(grant_state)
            IDLE_S: begin
                if((|grant_prior) == 1'b0) begin//没有可调度的端口
                    grant_get   <= 1'b0;
                    grant_reg   <= {STREAM_SUM{1'b0}};
                    grant_state <= IDLE_S;
                end
                else begin
                    grant_get   <= 1'b1;
                    grant_reg   <= grant_prior;
                    grant_state <= SEND_S;
                end
            end
            
            SEND_S: begin//等待调度结束重新开始
                if(sel_axis_eop == 1'b1) begin
                    if((|grant_prior) == 1'b0) begin//没有可调度的端口
                        grant_get   <= 1'b0;
                        grant_reg   <= {STREAM_SUM{1'b0}};
                        grant_state <= IDLE_S;
                    end
                    else begin
                        grant_get   <= 1'b1;
                        grant_reg   <= grant_prior;
                        grant_state <= SEND_S;
                    end
                end
                else begin//保持调度的值
                    grant_get   <= 1'b0;
                    grant_reg   <= grant_reg;
                    grant_state <= SEND_S;
                end
            end
            
            default: begin
                grant_reg   <= {STREAM_SUM{1'b0}};
                grant_get   <= 1'b0;
                grant_state <= IDLE_S;
            end
        endcase
    end
end

/*----------------------------------------------------------
                   AXIS输入流选择
----------------------------------------------------------*/
always @(*) begin
    int_axis_tready = (sel_axis_tready == 1'b1) ? grant_reg : {STREAM_SUM{1'b0}};
    
    sel_axis_tvalid = int_axis_tvalid[grant_reg_bin] & grant_reg[grant_reg_bin];
    sel_axis_tkeep  = int_axis_tkeep [grant_reg_bin];
    sel_axis_tdata  = int_axis_tdata [grant_reg_bin];
    sel_axis_tlast  = int_axis_tlast [grant_reg_bin];
    sel_axis_tuser  = int_axis_tuser [grant_reg_bin];
end
/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 

onehot2binary #(
    .WIDTH(STREAM_SUM_BIN)
)bin2onehot_inst(
    .i_onehot(grant_reg + {STREAM_SUM_POW{1'b0}}),
    .o_bin(grant_reg_bin)
);

PktLineDet SaxisLineDet_Inst(
    .user_clk(m_axis_clk),
    .user_rst_n(m_axis_rst_n),
        
    .valid(sel_axis_tready & sel_axis_tvalid),
    .last(sel_axis_tlast),
        
    .sop(sel_axis_sop),
    .line_id(sel_axis_line_id),
    .eop(sel_axis_eop)
);


prior_grant #(
    .GRANT_WIDTH(STREAM_SUM),
    .PRIOR_LOW_OR_HIGH(0)
)pkt_grant_inst(
    .clk  (m_axis_clk),
    .rst_n(m_axis_rst_n),
    .req  (grant_req),
     
    .get(grant_get),
    .fix_prior(wv_fix_prior),
    .grant_prior(grant_prior)
);

generate
    genvar i;
    for(i=0;i<STREAM_SUM;i=i+1) begin:StrBuffer
        if((ASYNC_EN == 0) && (PKT_MODE == 0) && (DEEP_WIDTH <= 1)) begin//同步模式、流处理且缓存需求小于等于1，即采用寄存器即可
            AXISRegBuf#(
                .PROMODE_EN(DEEP_WIDTH),//通过DEEP_WIDTH确定进阶版还是标准版，相比标准版，多了1级缓存，时序更优
                .DATA_BYTE (DATA_BYTE ),
                .USER_BIT  (USER_BIT  )
            )AXISRegBuf_Inst(
            //时钟复位信号
                .axis_clk     (m_axis_clk),
                .axis_rst_n   (m_axis_rst_n),
            //AXI Stream输入接口
                .s_axis_tready(s_axis_tready[i*1 +: 1]),
                .s_axis_tvalid(s_axis_tvalid[i*1 +: 1]),
                .s_axis_tkeep (s_axis_tkeep [i*DATA_BYTE +: DATA_BYTE]),
                .s_axis_tdata (s_axis_tdata [i*DATA_BYTE*8 +: DATA_BYTE*8]),
                .s_axis_tlast (s_axis_tlast [i*1 +: 1]),
                .s_axis_tuser (s_axis_tuser [i*USER_BIT +: USER_BIT]),      
            //AXI Stream输出接口
                .m_axis_tready(int_axis_tready[i]),
                .m_axis_tvalid(int_axis_tvalid[i]),
                .m_axis_tkeep (int_axis_tkeep [i]),
                .m_axis_tdata (int_axis_tdata [i]),
                .m_axis_tlast (int_axis_tlast [i]),
                .m_axis_tuser (int_axis_tuser [i])
            );
        end
        else begin//其他情况采用FIFO
            AXISFifoBuf#(
                .ASYNC_EN   (ASYNC_EN   ),//同步或异步  0：同步  1：异步
                .DEEP_WIDTH (DEEP_WIDTH ),//缓存FIFO的容量的指数位宽
                .PKT_MODE   (PKT_MODE   ),//处理模式，0：流处理模式  1：报文处理模式
                .DATA_BYTE  (DATA_BYTE  ),
                .USER_BIT   (USER_BIT   ),
                .MIN_PKTLINE(MIN_PKTLINE)
            )AXISFifoBuf_Inst(
            //时钟复位信号
                .s_axis_clk  (s_axis_clk  [i]),
                .s_axis_rst_n(s_axis_rst_n[i]),
                .m_axis_clk  (m_axis_clk     ),
                .m_axis_rst_n(m_axis_rst_n   ),
            //AXI Stream输入接口
                .s_axis_tready(s_axis_tready[i*1 +: 1]),
                .s_axis_tvalid(s_axis_tvalid[i*1 +: 1]),
                .s_axis_tkeep (s_axis_tkeep [i*DATA_BYTE   +:   DATA_BYTE]),
                .s_axis_tdata (s_axis_tdata [i*DATA_BYTE*8 +: DATA_BYTE*8]),
                .s_axis_tlast (s_axis_tlast [i*1 +: 1]),
                .s_axis_tuser (s_axis_tuser [i*USER_BIT +: USER_BIT]),    
            //AXI Stream输出接口
                .m_axis_tready(int_axis_tready[i]),
                .m_axis_tvalid(int_axis_tvalid[i]),
                .m_axis_tkeep (int_axis_tkeep [i]),
                .m_axis_tdata (int_axis_tdata [i]),
                .m_axis_tlast (int_axis_tlast [i]),
                .m_axis_tuser (int_axis_tuser [i]),
                
                .free_space(),
                .used_space()
            );
        end
    end
endgenerate

AXISRegBuf#(
    .PROMODE_EN(1),//输出选择进阶版，相比标准版，多了1级缓存，时序更优
    .DATA_BYTE (DATA_BYTE ),
    .USER_BIT  (USER_BIT  )
)AXISRegBuf_Inst0(
//时钟复位信号
    .axis_clk     (m_axis_clk),
    .axis_rst_n   (m_axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(sel_axis_tready),
    .s_axis_tvalid(sel_axis_tvalid),
    .s_axis_tkeep (sel_axis_tkeep),
    .s_axis_tdata (sel_axis_tdata),
    .s_axis_tlast (sel_axis_tlast),
    .s_axis_tuser (sel_axis_tuser),    
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
AXISMux#(
    .ASYNC_EN   (),//同步或异步  0：同步  1：异步
    .PKT_MODE   (),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (),//缓存FIFO的容量的指数位宽
    .DATA_BYTE  (),
    .USER_BIT   (),
    .MIN_PKTLINE()
)
(
//时钟复位信号
    .s_axis_clk   (),
    .s_axis_rst_n (),
    .m_axis_clk   (),
    .m_axis_rst_n (),
//固定优先级接口
    .iv_fix_prior (),
//报文分组数据接收接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//BE分组数据输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser ()
);
*/