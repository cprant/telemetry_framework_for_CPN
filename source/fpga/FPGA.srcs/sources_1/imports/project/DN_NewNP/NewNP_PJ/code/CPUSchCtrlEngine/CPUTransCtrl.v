/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  CPUTransCtrl.v
Target Device All
Dscription 
    1)接收CPU下发的报文，并根据源目的MAC地址以及二层协议号对报文进行分类转发
    2)提取非TSMP帧的CPUID送往CPU负载状态统计模块更新队列负载状态
Data_Struct:
    1)Metadata    
        [127:120] 输入端口号 8	输入端口号
        [119:112] 输出端口号 8	输出端口号
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [ 98: 88] 保留      11	保留位
        [ 87: 84] 帧类型	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6帧
            1:IPv6-其他帧
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4-7:保留
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
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module CPUTransCtrl #(
    parameter   THREAD_SUM     = 8'd4
)(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
//数据输入接口   
    output wire         s_axis_tready,
    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep,
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tlast,
    input  wire [ 11:0] s_axis_tuser,
//数据输出接口   
    input  wire         m_axis_tready,
    output reg          m_axis_tvalid,
    output reg  [ 15:0] m_axis_tkeep,
    output reg  [127:0] m_axis_tdata,
    output reg          m_axis_tlast,
    output reg  [ 11:0] m_axis_tuser,
    output reg  [  1:0] m_axis_tdest,
//CPU负载信息             
    output reg          o_tx_cpuid_valid,
    output reg  [  7:0] ov_tx_cpuid 
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam   CPUID_WIDTH = clogb2(THREAD_SUM);

wire         acf_axis_sop;
wire [  7:0] acf_axis_line_id;
wire         acf_axis_eop;

reg          acf_axis_tready;
wire         acf_axis_tvalid;
wire [ 15:0] acf_axis_tkeep ;
wire [127:0] acf_axis_tdata ;
wire         acf_axis_tlast ;
wire [ 11:0] acf_axis_tuser ;

reg          cur_tsmp_flag,nxt_tsmp_flag;
reg          cur_srv6_flag,nxt_srv6_flag;
/*-----------------------------------------------------------------------
                    处理器帧发送控制
-----------------------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        cur_tsmp_flag <= 1'b0;
        cur_srv6_flag <= 1'b0;
    end
    else begin
        cur_tsmp_flag <= nxt_tsmp_flag;
        cur_srv6_flag <= nxt_srv6_flag;
    end
end   
                                
always @(*) begin
    acf_axis_tready = m_axis_tready;
    
    m_axis_tvalid = acf_axis_tvalid;
    m_axis_tkeep  = acf_axis_tkeep ;
    m_axis_tlast  = acf_axis_tlast ;
    m_axis_tuser  = acf_axis_tuser ;
    m_axis_tdata  = acf_axis_tdata ;
    
    if(acf_axis_sop == 1'b1)begin
        nxt_tsmp_flag = (acf_axis_tdata[87:84] == 4'd8);
        nxt_srv6_flag = (acf_axis_tdata[87:84] <= 4'd1);
    end
    else begin
        nxt_tsmp_flag = cur_tsmp_flag;
        nxt_srv6_flag = cur_srv6_flag;
    end
    
    m_axis_tdest  = {nxt_srv6_flag,nxt_tsmp_flag};

    o_tx_cpuid_valid = ((acf_axis_tready == 1'b1) && 
                        (acf_axis_tvalid == 1'b1) && 
                        (acf_axis_line_id == 8'b1));
    ov_tx_cpuid   = 8'd0+acf_axis_tdata[80 +: CPUID_WIDTH];
end

/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
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

PktLineDet #(8) ACFaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( acf_axis_tready & acf_axis_tvalid),
    .last                   ( acf_axis_tlast      ),
                        
    .sop                    ( acf_axis_sop        ),
    .line_id                ( acf_axis_line_id    ),
    .eop                    ( acf_axis_eop        )
);

AXISFifoBuf #(
    .ASYNC_EN               ( 0                 ),
    .DEEP_WIDTH             ( 9                 ),
    .PKT_MODE               ( 1                 ),
    .DATA_BYTE              ( 16                ),
    .USER_BIT               ( 12                )
)RxFifoBuf(  
    //ports 
    .s_axis_clk             ( axis_clk        ),
    .s_axis_rst_n           ( axis_rst_n      ),
        
    .m_axis_clk             ( axis_clk        ),
    .m_axis_rst_n           ( axis_rst_n      ),
        
    .s_axis_tready          ( s_axis_tready     ),
    .s_axis_tvalid          ( s_axis_tvalid     ),
    .s_axis_tkeep           ( s_axis_tkeep      ),
    .s_axis_tdata           ( s_axis_tdata      ),
    .s_axis_tlast           ( s_axis_tlast      ),
    .s_axis_tuser           ( s_axis_tuser      ),
        
    .m_axis_tready          ( acf_axis_tready   ),
    .m_axis_tvalid          ( acf_axis_tvalid   ),
    .m_axis_tkeep           ( acf_axis_tkeep    ),
    .m_axis_tdata           ( acf_axis_tdata    ),
    .m_axis_tlast           ( acf_axis_tlast    ),
    .m_axis_tuser           ( acf_axis_tuser    ),
        
    .free_space             (     ),
    .used_space             (     )
);  

endmodule
/*
CPUTransCtrl #(
    .THREAD_SUM()
)
CPUTransCtrl_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//数据输入接口             
    .s_axis_tready(),
    .s_axis_tvalid(),
    .s_axis_tkeep (),
    .s_axis_tdata (),
    .s_axis_tlast (),
    .s_axis_tuser (),
//数据输出接口             
    .m_axis_tready(),
    .m_axis_tvalid(),
    .m_axis_tkeep (),
    .m_axis_tdata (),
    .m_axis_tlast (),
    .m_axis_tuser (),
    .m_axis_tdest (),
//CPU负载信息                       
    .o_tx_cpuid_valid(),
    .ov_tx_cpuid     ()
);
*/