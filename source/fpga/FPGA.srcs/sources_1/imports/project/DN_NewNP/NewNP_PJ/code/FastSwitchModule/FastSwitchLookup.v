/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  SRv6RcvFmtCov.v
Target Device All
Dscription 
    1)将接收的分组数据转换为128bit数据位宽并使用FIFO进行缓存,以保障添加Metadata增加性能开销不会影响端口接收
    2)将分组数据从FIFO中读取输出，删除以太网头
    3)按照分组数据格式添加Metadata，并填写部分字段
    4)根据MD中的分组类型字段提取并构造遥测信息输出

Data_Struct: 
    1) int_lb_w/rdata配置寄存器拼接表项
        [415:392] 保留位
        [391:384] 命中动作action
        
        [383:368] 保留位，用于填充配置表项以保障关键字字段32bit对齐
        [367:192] 掩码mask
        
        [191:176] 保留位，用于填充配置表项以保障关键字字段32bit对齐
        [175:160] IPv6+SRv6 Next_Header
            8 ipv6_nh
            8 srv6_nh
        [159:144] 源端口
        [143:128] 目的端口
        [127: 64] 源ipv6高64位
        [ 63:  0] 目的ipv6高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)
    
    2) rflu_s_cfg_w/rdata
        [359:352] 命中动作action

        [351:176] 掩码mask

        [175:160] IPv6+SRv6 Next_Header
            8 ipv6_nh
            8 srv6_nh
        [159:144] 源端口
        [143:128] 目的端口
        [127: 64] 源ipv6高64位
        [ 63:  0] 目的ipv6高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)
    
    3) s_key_axis_tdata关键字
        [175:160] IPv6+SRv6 Next_Header
            8 ipv6_nh
            8 srv6_nh
        [159:144] 源端口
        [143:128] 目的端口
        [127: 64] 源ipv6高64位
        [ 63:  0] 目的ipv6高64位(SRv6网络中IPv6地址的低64位为终端标识，不参与路由)
    
    4)s_cfg_cmd
        0:读表项  
        1:写表项  
        2:自学习 
        3:清除
        
    
    5)s_cfg_resp
        [17:16]:Stat状态
            0:none
            1:正常
            2:错误
            3:保留
        [15:0]:index

Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module FastSwitchLookup#(
    parameter ENT_SUM    = 64
)(
//时钟复位信号
    input  wire         clk  ,
    input  wire         rst_n,
//表项配置        
(*mark_debug="true"*)    input  wire         s_lb_cs_n ,
(*mark_debug="true"*)    output wire         s_lb_ack_n,
(*mark_debug="true"*)    input  wire         s_lb_wr_rd,
(*mark_debug="true"*)    input  wire [ 31:0] s_lb_addr ,
(*mark_debug="true"*)    input  wire [ 31:0] s_lb_wdata,
(*mark_debug="true"*)    output wire [ 31:0] s_lb_rdata,
//查表接口
(*mark_debug="true"*)    output wire         s_key_axis_tready,
(*mark_debug="true"*)    input  wire         s_key_axis_tvalid,
(*mark_debug="true"*)    input  wire [175:0] s_key_axis_tdata ,
    
(*mark_debug="true"*)    input  wire         m_rsl_axis_tready,
(*mark_debug="true"*)    output wire         m_rsl_axis_tvalid,
(*mark_debug="true"*)    output wire [  7:0] m_rsl_axis_tdata ,
(*mark_debug="true"*)    output wire [ 16:0] m_rsl_axis_tuser //{hit,index}
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
(*mark_debug="true"*)wire         int_lb_cs_n ;
(*mark_debug="true"*)reg          int_lb_ack_n;
(*mark_debug="true"*)wire         int_lb_wr_rd;
(*mark_debug="true"*)wire [ 27:0] int_lb_addr ;
(*mark_debug="true"*)wire [415:0] int_lb_wdata;
(*mark_debug="true"*)reg  [415:0] int_lb_rdata;

(*mark_debug="true"*)reg  [415:0] int_lb_rdata_reg;

(*mark_debug="true"*)reg          rflu_s_cfg_sel  ;//配置选择
(*mark_debug="true"*)reg  [  1:0] rflu_s_cfg_cmd  ;//0:读表项  1:写表项  2:自学习 3:清除
(*mark_debug="true"*)reg  [ 15:0] rflu_s_cfg_index;
(*mark_debug="true"*)reg  [359:0] rflu_s_cfg_wdata;
(*mark_debug="true"*)wire [ 17:0] rflu_s_cfg_resp ;//{stat,index}
(*mark_debug="true"*)wire [359:0] rflu_s_cfg_rdata;

(*mark_debug="true"*)reg  [  1:0] cur_ctrl_state,nxt_ctrl_state;
localparam  IDLE_S     = 2'd0,
            CFG_WAIT_S = 2'd1,
            CFG_ACK_S  = 2'd2;
/*----------------------------------------------------------
                   表项配置管理
----------------------------------------------------------*/
//缓存int_lb_rdata以便在localbus握手响应时能够保持读回的值
always @(posedge clk) int_lb_rdata_reg <= int_lb_rdata;

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) cur_ctrl_state <= IDLE_S;
    else              cur_ctrl_state <= nxt_ctrl_state;
end

always @(*) begin
    case(cur_ctrl_state)
        IDLE_S: begin
            int_lb_ack_n = 1'b1;
            int_lb_rdata = 416'b0;
            if(int_lb_cs_n == 1'b0)begin//配置请求
               rflu_s_cfg_sel   = 1'b1;
               rflu_s_cfg_cmd   = (int_lb_wr_rd == 1'b0) ? 2'd1 : 2'd0;
               rflu_s_cfg_index = int_lb_addr[15:0];
               rflu_s_cfg_wdata = {int_lb_wdata[391:384],
                                   int_lb_wdata[367:192],
                                   int_lb_wdata[175:  0]};
               
               nxt_ctrl_state   = CFG_WAIT_S;
            end
            else begin
               rflu_s_cfg_sel   = 1'b0;
               rflu_s_cfg_cmd   = 2'd0;
               rflu_s_cfg_index = 16'd0;
               rflu_s_cfg_wdata = 360'd0;
               
               nxt_ctrl_state   = IDLE_S;
            end
        end
        
        CFG_WAIT_S: begin
            rflu_s_cfg_sel   = 1'b0;
            rflu_s_cfg_cmd   = 2'd0;
            rflu_s_cfg_index = 16'd0;
            rflu_s_cfg_wdata = 360'd0;
            if(rflu_s_cfg_resp[17:16] == 2'b0) begin//未返回响应
                int_lb_ack_n   = 1'b1;
                int_lb_rdata   = 416'b0;
                nxt_ctrl_state = CFG_WAIT_S;
            end
            else begin
                int_lb_ack_n   = 1'b0;
                int_lb_rdata   = {24'b0,rflu_s_cfg_rdata[359:352],
                                  16'b0,rflu_s_cfg_rdata[351:176],
                                  16'b0,rflu_s_cfg_rdata[175:  0]};
                nxt_ctrl_state = CFG_ACK_S;
            end
        end
        
        CFG_ACK_S: begin
            rflu_s_cfg_sel   = 1'b0;
            rflu_s_cfg_cmd   = 2'd0;
            rflu_s_cfg_index = 16'd0;
            rflu_s_cfg_wdata = 360'd0;

            int_lb_rdata   =  int_lb_rdata_reg;
            if(int_lb_cs_n == 1'b0) begin
                int_lb_ack_n   = 1'b0;
                nxt_ctrl_state = CFG_ACK_S;
            end
            else begin
                int_lb_ack_n   = 1'b1;
                nxt_ctrl_state = IDLE_S;
            end
        end
        
        default: begin
            rflu_s_cfg_sel   = 1'b0;
            rflu_s_cfg_cmd   = 2'd0;
            rflu_s_cfg_index = 16'd0;
            rflu_s_cfg_wdata = 360'd0;
            int_lb_ack_n     = 1'b1;
            int_lb_rdata     = 416'b0;
            nxt_ctrl_state   = IDLE_S;
        end
    endcase
end

/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
LbExt #(
    .ASYNC_MODE   (1),
    .CFG_ORDER    (0),//0:从低到高，最后一个配置的是高地址   1:从高到低，最后一个配置的低地址
    .LB_ADDR_WID  (32),
    .LB_DATA_WID  (32),
    .EXT_ADDR_WID (4),
    .EXT_DATA_SUM (13)
)LbExt_Inst(
//时钟复位信号
    .clk  (clk  ),
    .rst_n(rst_n),
//输入Localbus信号                
    .s_lb_cs_n (s_lb_cs_n ),
    .s_lb_ack_n(s_lb_ack_n),
    .s_lb_wr_rd(s_lb_wr_rd),//0:wr  1:rd
    .s_lb_addr (s_lb_addr ),
    .s_lb_wdata(s_lb_wdata),
    .s_lb_rdata(s_lb_rdata),
//输出Localbus信号
    .m_lb_cs_n (int_lb_cs_n ),
    .m_lb_ack_n(int_lb_ack_n),
    .m_lb_wr_rd(int_lb_wr_rd),//0:wr  1:rd
    .m_lb_addr (int_lb_addr ),
    .m_lb_wdata(int_lb_wdata),
    .m_lb_rdata(int_lb_rdata)
);

RegFastLookupUnit#(
    .ENT_SUM    (ENT_SUM),
    .KEY_WIDTH  (176    ),
    .RSL_WIDTH  (8      ),
    .MASK_EN    (1      ),
    .AGE_PERIOD (300    )
)RFLU_Inst(
//时钟复位信号
    .clk         (clk  ),
    .rst_n       (rst_n),
//表项配置接口-基于Localbus扩展
    .s_cfg_sel   (rflu_s_cfg_sel  ),//配置选择
    .s_cfg_cmd   (rflu_s_cfg_cmd  ),//0:读表项  1:写表项  2:自学习 3:清除
    .s_cfg_index (rflu_s_cfg_index),
    .s_cfg_wdata (rflu_s_cfg_wdata),
    .s_cfg_resp  (rflu_s_cfg_resp ),//{stat(),index}
    .s_cfg_rdata (rflu_s_cfg_rdata),
//查表接口
    .s_key_axis_tready(s_key_axis_tready),
    .s_key_axis_tvalid(s_key_axis_tvalid),
    .s_key_axis_tdata (s_key_axis_tdata ),

    .m_rsl_axis_tready(m_rsl_axis_tready),
    .m_rsl_axis_tvalid(m_rsl_axis_tvalid),
    .m_rsl_axis_tdata (m_rsl_axis_tdata ),
    .m_rsl_axis_tuser (m_rsl_axis_tuser ),//{hit(),index}
//查表单元状态信息
    .iv_age_period    (16'b0)
);
endmodule
/*
FastSwitchLookup#(
    .ENT_SUM()
)FastSwitchLookup_Inst(
//时钟复位信号
    .clk  (),
    .rst_n(),
//表项配置               
    .s_lb_cs_n (),
    .s_lb_ack_n(),
    .s_lb_wr_rd(),
    .s_lb_addr (),
    .s_lb_wdata(),
    .s_lb_rdata(),
//查表接口
    .s_key_axis_tready(),
    .s_key_axis_tvalid(),
    .s_key_axis_tdata (),
                      
    .m_rsl_axis_tready(),
    .m_rsl_axis_tvalid(),
    .m_rsl_axis_tdata (),
    .m_rsl_axis_tuser ()//{hit,index}
);
*/