/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  FastSwitchMux.v
Target Device All
Dscription 
    1)支持多路AXI Stream接口的汇聚和转发
    2)为报文Metadata添加长度信息

Data_Struct:
    1)Metadata    
        [127:120] 输入端口号 8	输入端口号
        [119:112] 输出端口号 8	输出端口号
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [     98] 整形标记  1   整形转发标记  1代表整形
        [ 97: 88] 保留      10	保留位
        [ 87: 84] 帧类型	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6帧
            1:IPv6-其他帧
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4:出口节点SRv6报文，上报CPU
            5-7:保留
            8:TSMP帧
            9-14:保留
            15:丢弃报文
        [ 83: 64] 流ID	20	FlowID
            TSMP报文提取自DMAC的MID
            IPv6报文提取自FlowLabel
        [ 63: 48] 流编号 16	
            SRv6报文时提取自SRH头部的Tag
            其他报文暂无意义
        [ 47:  0] 时间戳

Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module FastSwitchMux#(
    parameter PORT_SUM = 8
)
(
//时钟复位信号
    input  wire                    axis_clk  ,
    input  wire                    axis_rst_n,
//报文分组数据接收接口
    output wire [  1*PORT_SUM-1:0] s_axis_tready,
    input  wire [  1*PORT_SUM-1:0] s_axis_tvalid,
    input  wire [ 16*PORT_SUM-1:0] s_axis_tkeep ,
    input  wire [128*PORT_SUM-1:0] s_axis_tdata ,
    input  wire [  1*PORT_SUM-1:0] s_axis_tlast ,
    input  wire [ 12*PORT_SUM-1:0] s_axis_tuser ,
//分组数据输出接口
    input  wire                    m_axis_tready,
    output reg                     m_axis_tvalid,
    output reg  [            15:0] m_axis_tkeep ,
    output reg  [           127:0] m_axis_tdata ,
    output reg                     m_axis_tlast ,
    output reg  [             0:0] m_axis_tuser 
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
wire         apm2len_axis_tready;
wire         apm2len_axis_tvalid;
wire [ 15:0] apm2len_axis_tkeep ;
wire [127:0] apm2len_axis_tdata ;
wire         apm2len_axis_tlast ;
wire [ 11:0] apm2len_axis_tuser ;

reg          acf_axis_tready;
wire         acf_axis_tvalid;
wire [ 15:0] acf_axis_tkeep ;
wire [127:0] acf_axis_tdata ;
wire         acf_axis_tlast ;
wire [  0:0] acf_axis_tuser ;

wire [ 31:0] acf_free_space;

reg          lenfifo_wr   ;
reg  [ 11:0] lenfifo_wdata; 
reg          lenfifo_rd , lenfifo_rd_reg;
wire [ 11:0] lenfifo_rdata;
wire [  5:0] lenfifo_usedw;
wire         lenfifo_full ;
wire         lenfifo_empty;
/*----------------------------------------------------------
                    汇聚报文处理
----------------------------------------------------------*/
//缓存汇聚的tuser，tuser组成为{1bit valid + 11bit len}
always @(*) begin
    lenfifo_wr = ((apm2len_axis_tvalid == 1'b1) && 
                  (apm2len_axis_tready == 1'b1) && 
                  (apm2len_axis_tlast  == 1'b1));
                  
    lenfifo_wdata = apm2len_axis_tuser;         
end

/*----------------------------------------------------------
                    汇聚报文处理
----------------------------------------------------------*/
reg  [  1:0] cur_fsm_state,nxt_fsm_state;

localparam START_S = 3'd0,
           TRANS_S = 3'd1,
           DISC_S  = 3'd2;
           
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        lenfifo_rd_reg <= 1'b0;
        cur_fsm_state  <= START_S;
    end
    else begin
        lenfifo_rd_reg <= lenfifo_rd;
        cur_fsm_state <= nxt_fsm_state;
    end
end

always @(*) begin
    m_axis_tkeep  = acf_axis_tkeep ; 
    m_axis_tdata  = acf_axis_tdata ; 
    m_axis_tlast  = acf_axis_tlast ; 
    m_axis_tuser  = acf_axis_tuser ; 
    case(cur_fsm_state)
        START_S: begin
            if((lenfifo_empty == 1'b0) && 
               (acf_axis_tvalid == 1'b1) && 
               (m_axis_tready == 1'b1)) begin
                acf_axis_tready = m_axis_tready;
                lenfifo_rd = 1'b1;
                m_axis_tdata[111:101]= lenfifo_rdata[10:0]; 
                if(lenfifo_rdata[11] == 1'b1) begin//错误报文
                    m_axis_tvalid = 1'b0; 
                    nxt_fsm_state = DISC_S;
                end
                else begin
                    m_axis_tvalid = acf_axis_tvalid; 
                    nxt_fsm_state = TRANS_S;
                end    
            end
            else begin
                acf_axis_tready = 1'b0;
                lenfifo_rd = 1'b0;
                m_axis_tvalid = 1'b0; 
                nxt_fsm_state = START_S;
            end
        end
        
        TRANS_S: begin
            lenfifo_rd = 1'b0;
            acf_axis_tready = m_axis_tready;
            m_axis_tvalid = acf_axis_tvalid; 
            if((acf_axis_tvalid == 1'b1) && 
               (acf_axis_tlast == 1'b1) && 
               (m_axis_tready == 1'b1)) begin
                nxt_fsm_state = START_S;
            end
            else begin
                nxt_fsm_state = TRANS_S;
            end
        end
        
        DISC_S: begin
            lenfifo_rd = 1'b0;
            acf_axis_tready = 1'b1;
            m_axis_tvalid = 1'b0; 
            if((acf_axis_tvalid == 1'b1) && 
               (acf_axis_tlast == 1'b1) && 
               (m_axis_tready == 1'b1)) begin
                nxt_fsm_state = START_S;
            end
            else begin
                nxt_fsm_state = DISC_S;
            end
        end
        
        default: begin
            lenfifo_rd = 1'b0;
            acf_axis_tready = 1'b0;
            m_axis_tvalid = 1'b0; 
            nxt_fsm_state = START_S;
        end
    endcase
end
/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISMux#(
    .ASYNC_EN   (0),//同步或异步  0：同步  1：异步
    .PKT_MODE   (1),//处理模式，0：流处理模式  1：报文处理模式
    .STREAM_SUM (PORT_SUM),//支持汇聚的的AXIStream流数量
    .DEEP_WIDTH (9),//缓存FIFO的容量的指数位宽
    .DATA_BYTE  (16),
    .USER_BIT   (12),
    .MIN_PKTLINE(5)
)
AXISMux_Inst(
//时钟复位信号
    .s_axis_clk   ({PORT_SUM{axis_clk  }}),
    .s_axis_rst_n ({PORT_SUM{axis_rst_n}}),
    .m_axis_clk   (axis_clk  ),
    .m_axis_rst_n (axis_rst_n),
//固定优先级接口
    .iv_fix_prior ({PORT_SUM{1'b0}}),
//报文分组数据接收接口
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),
//报文分组数据输出接口
    .m_axis_tready(apm2len_axis_tready),
    .m_axis_tvalid(apm2len_axis_tvalid),
    .m_axis_tkeep (apm2len_axis_tkeep ),
    .m_axis_tdata (apm2len_axis_tdata ),
    .m_axis_tlast (apm2len_axis_tlast ),
    .m_axis_tuser (apm2len_axis_tuser )
);

AXISFifoBuf#(
    .ASYNC_EN  (0 ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH(9 ),//缓存FIFO的容量的指数位宽
    .PKT_MODE  (1 ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE (16),
    .USER_BIT  (1 )
)IntSAXIFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk  (axis_clk  ),
    .s_axis_rst_n(axis_rst_n),
    .m_axis_clk  (axis_clk  ),
    .m_axis_rst_n(axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(apm2len_axis_tready),
    .s_axis_tvalid(apm2len_axis_tvalid),
    .s_axis_tkeep (apm2len_axis_tkeep ),
    .s_axis_tdata (apm2len_axis_tdata ),
    .s_axis_tlast (apm2len_axis_tlast ),
    .s_axis_tuser (1'b0),    
//AXI Stream输出接口
    .m_axis_tready(acf_axis_tready),
    .m_axis_tvalid(acf_axis_tvalid),
    .m_axis_tkeep (acf_axis_tkeep ),
    .m_axis_tdata (acf_axis_tdata ),
    .m_axis_tlast (acf_axis_tlast ),
    .m_axis_tuser (acf_axis_tuser ),
    
    .free_space   (acf_free_space)
);

ParamSyncFifo #(   
    .DATA_WIDTH   ( 12               ),
    .ADDR_WIDTH   ( 6                )
)async_mfifo_inst(
    .clk          ( axis_clk   ),
    .aclr         ( ~axis_rst_n),
                  
    .wrreq        ( lenfifo_wr        ),
    .data         ( lenfifo_wdata     ),
    .rdreq        ( lenfifo_rd_reg    ),
    .q            ( lenfifo_rdata     ),
                         
    .usedw        ( lenfifo_usedw     ),
    .full         ( lenfifo_full      ),
    .empty        ( lenfifo_empty     )
);

endmodule
/*
FastSwitchMux#(
    .PORT_SUM   ()
)
FastSwitchMux_Inst(
//时钟复位信号
    .axis_clk   (),
    .axis_rst_n (),
//报文分组数据接收接口
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//分组数据输出接口
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser ()
);
*/