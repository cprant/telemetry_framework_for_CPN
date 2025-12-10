/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  IPv6FwdProc.v
Target Device All
Dscription 
    1)接收并缓存汇聚后的分组以及返回的查表后结果
    2)根据查表结果对缓存分组进行丢弃或转发处理
    3)对于多端口转发的分组进行拆分和复制，对该部分子功能，可基于公司现有代码少量修改(BEMultiCastProc)
Data_Struct:
    1)Metadata    
        [127:120] 输入端口号 8	输入端口号
        [119:112] 输出端口号 8	输出端口号
            0-3:
                SGMII 0-3
            4:
                BASER
            5:
                CPU
            6:
                SRv6Fwd
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [     98] 整形标记  1   整形转发标记  1代表整形
        [ 97: 88] 保留      10	保留位
        [ 87: 84] 帧类型	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6帧
            1:IPv6-其他帧
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4:出口节点SRv6报文
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
Caution: 
    1)默认输入数据128bit
    2)每个报文提取信息均为一行，默认对端必定可接收该解析信息，无需控制反压
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module IPv6FwdProc # (
    parameter   PORT_SUM    = 32,
                CPU_PORTID  = 5
)(
//时钟复位信号
    input  wire                axis_clk,
    input  wire                axis_rst_n,
//分组数据输入接口
(*mark_debug="true"*)    output wire                s_axis_tready,
(*mark_debug="true"*)    input  wire                s_axis_tvalid,
    input  wire [        15:0] s_axis_tkeep ,
(*mark_debug="true"*)    input  wire [       127:0] s_axis_tdata ,
(*mark_debug="true"*)    input  wire                s_axis_tlast ,
(*mark_debug="true"*)    input  wire [         0:0] s_axis_tuser ,
//分组数据输出接口
(*mark_debug="true"*)    input  wire                m_axis_tready,
(*mark_debug="true"*)    output reg                 m_axis_tvalid,
    output reg  [        15:0] m_axis_tkeep ,
(*mark_debug="true"*)    output reg  [       127:0] m_axis_tdata ,
(*mark_debug="true"*)    output reg                 m_axis_tlast ,
(*mark_debug="true"*)    output reg  [         0:0] m_axis_tuser ,
(*mark_debug="true"*)    output reg  [PORT_SUM-1:0] m_axis_tdest ,
//查表结果输入接口
(*mark_debug="true"*)    output reg                 s_rsl_axis_tready,
(*mark_debug="true"*)    input  wire                s_rsl_axis_tvalid,
(*mark_debug="true"*)    input  wire [PORT_SUM-1:0] s_rsl_axis_tdata ,
(*mark_debug="true"*)    input  wire [        16:0] s_rsl_axis_tuser,//{hit,index}
//配置寄存器
(*mark_debug="true"*)    input wire  [PORT_SUM-1:0] iv_local_srv6_opbit
);
/*-----------------------------------------------------------
                    中间变量声明区域
------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam  PORT_LOG   = clogb2(PORT_SUM);

(*mark_debug="true"*)wire                int_axis_sop;
(*mark_debug="true"*)wire [         1:0] int_axis_line_id;
(*mark_debug="true"*)wire                int_axis_eop;

(*mark_debug="true"*)wire                post_axis_sop;
(*mark_debug="true"*)wire [         1:0] post_axis_line_id;
(*mark_debug="true"*)wire                post_axis_eop;

(*mark_debug="true"*)reg                 acf_axis_tready;
(*mark_debug="true"*)wire                acf_axis_tvalid;
(*mark_debug="true"*)wire [        15:0] acf_axis_tkeep ;
(*mark_debug="true"*)wire [       127:0] acf_axis_tdata ;
(*mark_debug="true"*)wire                acf_axis_tlast ;
(*mark_debug="true"*)wire [         0:0] acf_axis_tuser ;
(*mark_debug="true"*)wire [        31:0] acf_axis_free_space;

(*mark_debug="true"*)wire                int_axis_tready;
(*mark_debug="true"*)reg                 int_axis_tvalid;
(*mark_debug="true"*)reg  [        15:0] int_axis_tkeep ;
(*mark_debug="true"*)reg  [       127:0] int_axis_tdata ;
(*mark_debug="true"*)reg                 int_axis_tlast ;
(*mark_debug="true"*)reg  [         0:0] int_axis_tuser ;
(*mark_debug="true"*)reg  [PORT_SUM-1:0] int_axis_tdest ;

(*mark_debug="true"*)reg                 post_axis_tready;
(*mark_debug="true"*)wire                post_axis_tvalid;
(*mark_debug="true"*)wire [        15:0] post_axis_tkeep ;
(*mark_debug="true"*)wire [       127:0] post_axis_tdata ;
(*mark_debug="true"*)wire                post_axis_tlast ;
(*mark_debug="true"*)wire [         0:0] post_axis_tuser ;
(*mark_debug="true"*)wire [PORT_SUM-1:0] post_axis_tdest ;

(*mark_debug="true"*)reg  [PORT_SUM-1:0] tdest_reg;

(*mark_debug="true"*)wire [PORT_LOG-1:0] op_binary;

(*mark_debug="true"*)reg  [         0:0] cur_fwd_state,nxt_fwd_state;

localparam  IDLE_S  = 1'd0,
            TRANS_S = 1'd1;

/*------------------------------------------
            输入报文转发处理
------------------------------------------*/
//对于错误IPv6报文/错误SRv6报文/出口节点SRv6报文 固定上报CPU，其他根据查表结果转发
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'd0) begin
        tdest_reg     <= {PORT_SUM{1'b0}};
        cur_fwd_state <= IDLE_S;
    end
    else begin
        tdest_reg     <= (int_axis_sop == 1'b1) ? int_axis_tdest : tdest_reg;
        cur_fwd_state <= nxt_fwd_state;
    end
end

always @* begin
    int_axis_tkeep  = acf_axis_tkeep;
    int_axis_tdata  = acf_axis_tdata;
    int_axis_tlast  = acf_axis_tlast;
    int_axis_tuser  = acf_axis_tuser;
    case(cur_fwd_state)
        IDLE_S: begin
            if((acf_axis_tvalid == 1'b1) && 
               (s_rsl_axis_tvalid == 1'b1) && 
               (int_axis_tready == 1'b1)) begin//有数据且有查表结果,且FIFO可缓存
                s_rsl_axis_tready = 1'b1;
                acf_axis_tready   = 1'b1;
                
                int_axis_tvalid   = 1'b1;
                if((int_axis_tdata[87:84] == 4'd2) || 
                   (int_axis_tdata[87:84] == 4'd3)) begin//需要上报CPU的错误报文
                    int_axis_tdest  = (1<<CPU_PORTID)+{PORT_SUM{1'b0}};
                end
                else if(int_axis_tdata[87:84] == 4'd4) begin//出口节点SRv6报文
                    int_axis_tdest  = iv_local_srv6_opbit;
                end
                else if(s_rsl_axis_tuser[16] == 1'b0) begin//查表未命中
                    int_axis_tdest  = {PORT_SUM{1'b0}};
                end
                else begin
                    int_axis_tdest  = s_rsl_axis_tdata;
                end
                nxt_fwd_state = TRANS_S;
            end 
            else begin
                s_rsl_axis_tready = 1'b0;
                acf_axis_tready   = 1'b0;
                
                int_axis_tvalid   = 1'b0;
                int_axis_tdest    = {PORT_SUM{1'b0}};
                nxt_fwd_state     = IDLE_S;
            end 
        end
        
        TRANS_S: begin
            s_rsl_axis_tready = 1'b0;
            acf_axis_tready   = int_axis_tready;
            
            int_axis_tvalid   = acf_axis_tvalid;
            int_axis_tdest    = tdest_reg;
            
            if((int_axis_tready == 1'b1) && 
               (acf_axis_tvalid == 1'b1) && 
               (acf_axis_tlast == 1'b1))begin//发送到尾部
                nxt_fwd_state = IDLE_S;
            end
            else begin
                nxt_fwd_state = TRANS_S;
            end
        end
        
        default: begin
            s_rsl_axis_tready = 1'b0;
            acf_axis_tready   = 1'b0;
            
            int_axis_tvalid   = 1'b0;
            int_axis_tdest    = {PORT_SUM{1'b0}};
            nxt_fwd_state     = IDLE_S;
        end
    endcase
end

/*------------------------------------------
            输出报文字段修改
------------------------------------------*/
//修改输出报文Metadata的Outport字段
always @* begin
    post_axis_tready = m_axis_tready;
    
    m_axis_tvalid = post_axis_tvalid;
    m_axis_tkeep  = post_axis_tkeep;
    
    m_axis_tdata[127:120] = post_axis_tdata[127:120];
    m_axis_tdata[119:112] = (post_axis_sop == 1'b1) ? (op_binary + 8'b0) : post_axis_tdata[119:112];
    m_axis_tdata[111:  0] = post_axis_tdata[111:  0];
    
    m_axis_tlast  = post_axis_tlast;
    m_axis_tuser  = post_axis_tuser;
    m_axis_tdest  = post_axis_tdest;
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

onehot2binary #(
    .WIDTH(PORT_LOG)
)oponehot2bin_inst(
    .i_onehot(post_axis_tdest + {(2**PORT_LOG){1'b0}}),//累加2**PORT_LOG,以保障仿真输入的数据无高阻态
    .o_bin  (op_binary )
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

PktLineDet #(2) PostaxisLineDet_Inst(
    .user_clk(axis_clk),
    .user_rst_n(axis_rst_n),
        
    .valid(post_axis_tready & post_axis_tvalid),
    .last(post_axis_tlast),
        
    .sop(post_axis_sop),
    .line_id(post_axis_line_id),
    .eop(post_axis_eop)
);


AXISFifoBuf#(
    .ASYNC_EN  (0 ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH(6 ),//缓存FIFO的容量的指数位宽
    .PKT_MODE  (0 ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE (16),
    .USER_BIT  (1)
)IntSAXIFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk  (axis_clk  ),
    .s_axis_rst_n(axis_rst_n),
    .m_axis_clk  (axis_clk  ),
    .m_axis_rst_n(axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(acf_axis_tready),
    .m_axis_tvalid(acf_axis_tvalid),
    .m_axis_tkeep (acf_axis_tkeep ),
    .m_axis_tdata (acf_axis_tdata ),
    .m_axis_tlast (acf_axis_tlast ),
    .m_axis_tuser (acf_axis_tuser ),
    
    .free_space   (acf_axis_free_space)
);

AXISDestSplit # (
    .STREAM_SUM(PORT_SUM),//支持分派的的AXIStream流数量,默认值为8
    .DEEP_WIDTH(9),//默认值为9,
    .DATA_BYTE (16),//默认值为16,
    .USER_BIT  (1) //默认值为1
)APDS_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//分组数据输入接口
    .s_axis_tready(int_axis_tready),
    .s_axis_tvalid(int_axis_tvalid),
    .s_axis_tkeep (int_axis_tkeep ),
    .s_axis_tdata (int_axis_tdata ),
    .s_axis_tlast (int_axis_tlast ),
    .s_axis_tuser (int_axis_tuser ),
    .s_axis_tdest (int_axis_tdest ),
//分组数据输出接口
    .m_axis_tready(post_axis_tready),
    .m_axis_tvalid(post_axis_tvalid),
    .m_axis_tkeep (post_axis_tkeep ),
    .m_axis_tdata (post_axis_tdata ),
    .m_axis_tlast (post_axis_tlast ),
    .m_axis_tuser (post_axis_tuser ),
    .m_axis_tdest (post_axis_tdest )
);

endmodule
/*
IPv6FwdProc#(
    .PORT_SUM   (PORT_SUM),
    .CPU_PORTID (CPU_PORTID)
)
IPv6FwdProc_Inst(
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
    .m_axis_tuser (),
//查表结果输入接口
    .s_rsl_axis_tready(),
    .s_rsl_axis_tvalid(),
    .s_rsl_axis_tdata (),
    .s_rsl_axis_tuser (),
//配置寄存器
    .iv_local_srv6_opbit()
);
*/
