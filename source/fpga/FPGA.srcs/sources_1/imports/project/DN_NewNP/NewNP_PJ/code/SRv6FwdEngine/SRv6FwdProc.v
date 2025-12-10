/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  SRv6FwdProc.v
Target Device All
Dscription 
    (1)	接收快�?�交换模块查表并待转发的SRv6分组进行输出预处�?
    (2)	针对待输出的SRv6分组预处理，实现转发加�?�，包括
        1)	IPv6头部的目的IP地址替换
        2)	SRH的SL域修�?
Data_Struct: 
    1)Metadata    
        [127:120] 输入端口�? 8	输入端口�?
        [119:112] 输出端口�? 8	输出端口�?
        [111:101] 长度      11	报文长度
        [100: 99] 遥测标记  2	遥测标记，[99]输入遥测标记，[100]输出遥测标记
        [     98] 整形标记  1   整形转发标记  1代表整形
        [ 97: 88] 保留      10	保留�?
        [ 87: 84] 帧类�?	4	根据分组的C-TAG或以太网类型字段区分的帧类型
            0:IPv6-SRv6�?
            1:IPv6-其他�?
            2:错误IPv6报文，上报CPU
            3:错误SRv6报文，上报CPU
            4:出口节点SRv6报文，上报CPU
            5-7:保留
            8:TSMP�?
            9-14:保留
            15:丢弃报文
        [ 83: 64] 流ID	20	FlowID
            TSMP报文提取自DMAC的MID
            IPv6报文提取自FlowLabel
        [ 63: 48] 流编�? 16	
            SRv6报文时提取自SRH头部的Tag
            其他报文暂无意义
        [ 47:  0] 时间�?
    2)des_axis_tuser
        0:转发报文
        1:本机报文
        2:错误IPv6报文，上报CPU
        3:错误SRv6报文，上报CPU
    3)des_axis_tdata
        [143:136] hdr_ext_len
        [135:128] ipv6/srv6-nh
        [127:  0] srv6-segment_list[sel]
Caution:
    1)默认输入的全部为SRv6，且已经剥离以太网头(64bit对齐)
    2)注意，默认SRv6头之后至少要�?1字节的payload，否则会出现粘包问题(尾部处理出错)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6FwdProc(
//时钟复位信号
    input  wire         axis_clk,
    input  wire         axis_rst_n,
//报文分组数据接收接口
(*mark_debug="true"*)    output reg          s_axis_tready,
(*mark_debug="true"*)    input  wire         s_axis_tvalid,
    input  wire [ 15:0] s_axis_tkeep ,
(*mark_debug="true"*)    input  wire [127:0] s_axis_tdata ,
(*mark_debug="true"*)    input  wire         s_axis_tlast ,
(*mark_debug="true"*)    input  wire         s_axis_tuser ,
//分组数据输出接口
(*mark_debug="true"*)    input  wire         m_axis_tready,
(*mark_debug="true"*)    output wire         m_axis_tvalid,
    output wire [ 15:0] m_axis_tkeep,
(*mark_debug="true"*)    output wire [127:0] m_axis_tdata,
(*mark_debug="true"*)    output wire         m_axis_tlast,
(*mark_debug="true"*)    output wire         m_axis_tuser,
(*mark_debug="true"*)    output wire [  1:0] m_axis_tdest
);
/*-----------------------------------------------------------------------
                    中间变量声明区域
-----------------------------------------------------------------------*/
//本模块中�?有中间变�?(wire/reg/parameter)在此集中声明  
(*mark_debug="true"*)wire         s_axis_sop;
(*mark_debug="true"*)wire [  7:0] s_axis_line_id;
(*mark_debug="true"*)wire         s_axis_eop;

(*mark_debug="true"*)wire         acf_axis_sop;
(*mark_debug="true"*)wire [  7:0] acf_axis_line_id;
(*mark_debug="true"*)wire         acf_axis_eop;

wire         int_axis_tready;
reg          int_axis_tvalid;
reg  [ 15:0] int_axis_tkeep ;
reg  [127:0] int_axis_tdata ;
reg          int_axis_tlast ;
reg  [  0:0] int_axis_tuser ;

reg          acf_axis_tready;
wire         acf_axis_tvalid;
wire [ 15:0] acf_axis_tkeep ;
wire [127:0] acf_axis_tdata ;
wire         acf_axis_tlast ;
wire [  0:0] acf_axis_tuser ;

wire [ 31:0] acf_free_space ;
wire [ 31:0] acf_used_space ;

wire         ides_axis_tready;
reg          ides_axis_tvalid;
reg  [ 17:0] ides_axis_tkeep ;
reg  [143:0] ides_axis_tdata ;
reg          ides_axis_tlast ;
reg  [  1:0] ides_axis_tuser ;

(*mark_debug="true"*)reg          odes_axis_tready;
(*mark_debug="true"*)wire         odes_axis_tvalid;
wire [ 17:0] odes_axis_tkeep ;
(*mark_debug="true"*)wire [143:0] odes_axis_tdata ;
(*mark_debug="true"*)wire         odes_axis_tlast ;
(*mark_debug="true"*)wire [  1:0] odes_axis_tuser ;

wire [ 31:0] des_free_space ;
(*mark_debug="true"*)wire [ 31:0] des_used_space ;


wire         disp_axis_tready;
reg          disp_axis_tvalid;
reg  [ 15:0] disp_axis_tkeep ;
reg  [127:0] disp_axis_tdata ;
reg          disp_axis_tlast ;
reg  [  0:0] disp_axis_tuser ;
reg  [  1:0] disp_axis_tdest ;

(*mark_debug="true"*)reg [  1:0] cur_proc_type  ,nxt_proc_type;
(*mark_debug="true"*)reg [  7:0] cur_srh_len    ,nxt_srh_len;
(*mark_debug="true"*)reg [  7:0] cur_srh_segleft,nxt_srh_segleft;
(*mark_debug="true"*)reg [  7:0] cur_srh_nh     ,nxt_srh_nh;
(*mark_debug="true"*)reg [127:0] cur_srh_seglist,nxt_srh_seglist;

(*mark_debug="true"*)reg [  7:0] last_entry_maxid;
/*-----------------------------------------------------------------------
                    处理字段采集
-----------------------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        cur_proc_type   <= 2'b0;
        cur_srh_segleft <= 8'b0;
        cur_srh_nh      <= 8'b0;
        cur_srh_seglist <= 127'b0;
    end
    else begin
        cur_proc_type   <= nxt_proc_type;
        cur_srh_len     <= nxt_srh_len  ;
        cur_srh_segleft <= nxt_srh_segleft;
        cur_srh_nh      <= nxt_srh_nh;
        cur_srh_seglist <= nxt_srh_seglist;
    end
end

always @(*) begin
    s_axis_tready     = int_axis_tready & ides_axis_tready;
    int_axis_tvalid   = s_axis_tvalid & s_axis_tready;
    int_axis_tkeep    = s_axis_tkeep ;
    int_axis_tdata    = s_axis_tdata ;
    int_axis_tlast    = s_axis_tlast ;
    int_axis_tuser    = s_axis_tuser ;

    last_entry_maxid  = (s_axis_tdata[55:49] > 7'b0) ? s_axis_tdata[55:49]-8'b1 : 8'b0;
    nxt_proc_type     = cur_proc_type  ;
    nxt_srh_len       = cur_srh_len    ;
    nxt_srh_segleft   = cur_srh_segleft;
    nxt_srh_nh        = cur_srh_nh     ;
    nxt_srh_seglist   = cur_srh_seglist;

    if((s_axis_tready == 1'b1) && (s_axis_tvalid == 1'b1)) begin 
        if(s_axis_line_id == 8'd1) begin//IPv6 Header
            nxt_srh_nh        = s_axis_tdata[79:72]  ;//先提取IPv6的Next Header
            if(s_axis_tdata[71:64] > 8'd0) begin//ipv6_hop_limit
                nxt_proc_type         = 2'd0;
                int_axis_tdata[71:64] = s_axis_tdata[71:64]-1'b1;
            end
            else begin//错误IPv6�?
                nxt_proc_type         = 2'd2;
            end
        end
        else if(s_axis_line_id == 8'd3) begin//SRv6 Header
            nxt_srh_segleft = s_axis_tdata[39:32];
            nxt_srh_len     = s_axis_tdata[55:48];
            if((s_axis_tdata[31:24] > last_entry_maxid) || 
               (s_axis_tdata[39:32] > (s_axis_tdata[31:24] + 1'b1))) begin
            //last_entry > last_entry_maxid or segment_left>last_entry+1，错误SRv6协议�?
                nxt_proc_type = 2'd3; 
            end
            else if(s_axis_tdata[39:32] > 8'd0) begin//segment_left
                nxt_proc_type = 2'd0; 
                int_axis_tdata[39:32] = s_axis_tdata[39:32]-1'b1;
            end
            else begin//本机
                nxt_proc_type = 2'd1; 
                nxt_srh_nh    = s_axis_tdata[63:56]  ;//本机转发报文�?要提取并替换SRv6的NH
            end
        end
        else if(s_axis_line_id == (cur_srh_segleft + 4'd3)) begin//报文中的srh_segleft+头部4�?,不能�?1,原因详见<NewNP设计>-2.2.1 SRv6头的原理
            nxt_srh_seglist = s_axis_tdata;
        end
    end
end

//输入报文描述符处�?
always @(*) begin
    ides_axis_tvalid = int_axis_tlast & int_axis_tvalid ;//        
    ides_axis_tkeep  = {17{1'b1}};//[ 16:0] 
    ides_axis_tdata  = {nxt_srh_len,nxt_srh_nh,nxt_srh_seglist};//[135:0] 
    ides_axis_tlast  = 1'b1;//        
    ides_axis_tuser  = nxt_proc_type;//[  1:0] 
end

/*-----------------------------------------------------------------------
                    输出报文处理
-----------------------------------------------------------------------*/
(*mark_debug="true"*)reg [3:0] cur_trans_state,nxt_trans_state;
reg [1:0] disp_axis_tdest_reg;

localparam  START_S   = 4'd0,
            REPLACE_S = 4'd1,
            DEL_SEG_S = 4'd2,
            TRANS_S   = 4'd3;
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        disp_axis_tdest_reg   <= 2'b0;
        cur_trans_state       <= START_S;
    end
    else begin
        disp_axis_tdest_reg   <= disp_axis_tdest;
        cur_trans_state       <= nxt_trans_state;
    end
end

always @(*) begin
    disp_axis_tkeep = acf_axis_tkeep;
    disp_axis_tdata = acf_axis_tdata;
    disp_axis_tlast = acf_axis_tlast;
    disp_axis_tuser = acf_axis_tuser;
    disp_axis_tdest = disp_axis_tdest_reg;
    case(cur_trans_state)
        START_S: begin
            if((acf_axis_tvalid == 1'b1) && 
               (odes_axis_tvalid == 1'b1) && 
               (disp_axis_tready == 1'b1)) begin //有报文完成预处理，且对端可接�?
                acf_axis_tready  = 1'b1;
                disp_axis_tvalid = 1'b1;
                disp_axis_tdest = (odes_axis_tuser == 2'd1) ? 2'b01:2'b10;//仅本机报文需要删除SRH�?
                
                disp_axis_tdata[98] = odes_axis_tdata[63]; //修改MD中的整形标记�?20230111
                
                if(odes_axis_tuser < 2'd2) begin//转发报文或本机报�?
                //替换IPv6的NH和DIP
                    odes_axis_tready = 1'b0;
                    //本机报文经过该模块删除SRH头后，需要将Metadata.Type�?要修改为IPv6-其他帧，以便再次查表转发
                    disp_axis_tdata[87:84] = (odes_axis_tuser == 2'd1) ? 4'd1:disp_axis_tdata[87:84];
                    nxt_trans_state  = REPLACE_S;
                end
                else begin//错误IPv6报文或错误SRv6报文，上报CPU
                    odes_axis_tready = 1'b1;
                    disp_axis_tdata[87:84] = {2'b0,odes_axis_tuser};
                    nxt_trans_state = TRANS_S;
                end
            end
            else begin//报文未完成处�?
                acf_axis_tready  = 1'b0;
                odes_axis_tready = 1'b0;
                disp_axis_tvalid    = 1'b0;
                nxt_trans_state  = START_S;
            end
        end
        
        REPLACE_S: begin
            acf_axis_tready  = disp_axis_tready;
            disp_axis_tvalid = acf_axis_tvalid;
            if((acf_axis_tvalid == 1'b1) && (acf_axis_tready == 1'b1)) begin
                if(acf_axis_line_id == 8'd1) begin//IPv6-Header,替换NH
                    odes_axis_tready = 1'b0;
                    disp_axis_tdata[95:80] = (disp_axis_tdest_reg == 2'b01) ? 
                                              (disp_axis_tdata[95:80] - {odes_axis_tdata[143:136]+1'b1,3'b0}) : disp_axis_tdata[95:80];//修改IPv6 Payload_Len(原本的长度减去SRH长度)
                    disp_axis_tdata[79:72] = odes_axis_tdata[135:128];//替换NH
                    nxt_trans_state  = REPLACE_S;
                end
                else if(acf_axis_line_id == 8'd2) begin//替换DIP[127:64]
                    odes_axis_tready = 1'b0;
                    disp_axis_tdata[63:0] = odes_axis_tdata[127:64];
                    nxt_trans_state  = REPLACE_S;
                end
                else begin// (acf_axis_line_id == 8'd3) IPv6-DIP[63:0]
                    disp_axis_tdata[127:64] = odes_axis_tdata[63:0];//替换DIP[63:0]
                    if(disp_axis_tdest_reg == 2'b01) begin//剔除SRH头中Segment_list�?(�?64bit控制字段未剔除，后续采用AXISRemove继续)
                        odes_axis_tready = 1'b0;//odes完成任务可以被读�?
                        nxt_trans_state  = DEL_SEG_S;
                    end
                    else begin
                        odes_axis_tready = 1'b1;//odes完成任务可以被读�?
                        nxt_trans_state  = TRANS_S;
                    end
                end
            end
            else begin
                odes_axis_tready = 1'b0;
                nxt_trans_state  = REPLACE_S;
            end
        end
        
        DEL_SEG_S: begin
            acf_axis_tready  = 1'b1;
            if((acf_axis_tvalid == 1'b1) && 
               ((acf_axis_line_id == (odes_axis_tdata[143:137]+4'd3)) || (acf_axis_tlast == 1'b1))) begin
                disp_axis_tvalid = 1'b0;
                odes_axis_tready = 1'b1;
                nxt_trans_state  = TRANS_S;//默认SRv6头之后至少要�?1字节的payload，否则会出现粘包问题(尾部处理出错)
            end
            else begin
                disp_axis_tvalid = 1'b0;
                odes_axis_tready = 1'b0;
                nxt_trans_state  = DEL_SEG_S;
            end
        end
        
        TRANS_S: begin
            acf_axis_tready  = disp_axis_tready;
            disp_axis_tvalid = acf_axis_tvalid;
            odes_axis_tready = 1'b0;
            if((acf_axis_tvalid == 1'b1) && (acf_axis_tready == 1'b1) && (acf_axis_tlast == 1'b1)) begin
                nxt_trans_state  = START_S;
            end
            else begin
                nxt_trans_state  = TRANS_S;
            end
        end
        
        default: begin
            acf_axis_tready  = 1'b0;
            disp_axis_tvalid = 1'b0;
            odes_axis_tready = 1'b0;
            nxt_trans_state  = START_S;
        end
    endcase
end
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的�?有IP在该区域实例�?
//例如fifo/ram/grant之类的IP.... 
PktLineDet #(8) SaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( s_axis_tready & s_axis_tvalid),
    .last                   ( s_axis_tlast      ),
                            
    .sop                    ( s_axis_sop        ),
    .line_id                ( s_axis_line_id    ),
    .eop                    ( s_axis_eop        )
);

PktLineDet #(8) AcfaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( acf_axis_tready & acf_axis_tvalid),
    .last                   ( acf_axis_tlast      ),
                            
    .sop                    ( acf_axis_sop        ),
    .line_id                ( acf_axis_line_id    ),
    .eop                    ( acf_axis_eop        )
);

AXISFifoBuf #(
    .ASYNC_EN               ( 0               ),
    .DEEP_WIDTH             ( 9               ),
    .PKT_MODE               ( 1               ),
    .DATA_BYTE              ( 16              ),
    .USER_BIT               ( 1               ),
    .MIN_PKTLINE            ( 4               )
)
RxFifoBuf(  
    //ports 
    .s_axis_clk             ( axis_clk        ),
    .s_axis_rst_n           ( axis_rst_n      ),
        
    .m_axis_clk             ( axis_clk        ),
    .m_axis_rst_n           ( axis_rst_n      ),
        
    .s_axis_tready          ( int_axis_tready ),
    .s_axis_tvalid          ( int_axis_tvalid ),
    .s_axis_tkeep           ( int_axis_tkeep  ),
    .s_axis_tdata           ( int_axis_tdata  ),
    .s_axis_tlast           ( int_axis_tlast  ),
    .s_axis_tuser           ( int_axis_tuser  ),
        
    .m_axis_tready          ( acf_axis_tready ),
    .m_axis_tvalid          ( acf_axis_tvalid ),
    .m_axis_tkeep           ( acf_axis_tkeep  ),
    .m_axis_tdata           ( acf_axis_tdata  ),
    .m_axis_tlast           ( acf_axis_tlast  ),
    .m_axis_tuser           ( acf_axis_tuser  ),
                                              
    .free_space             ( acf_free_space  ),
    .used_space             ( acf_used_space  )
); 

AXISFifoBuf #(
    .ASYNC_EN               ( 0               ),
    .DEEP_WIDTH             ( 7               ),
    .PKT_MODE               ( 1               ),
    .DATA_BYTE              ( 18              ),
    .USER_BIT               ( 2               ),
    .MIN_PKTLINE            ( 1               )
)
DesFifoBuf(  
    //ports 
    .s_axis_clk             ( axis_clk        ),
    .s_axis_rst_n           ( axis_rst_n      ),
        
    .m_axis_clk             ( axis_clk        ),
    .m_axis_rst_n           ( axis_rst_n      ),
        
    .s_axis_tready          ( ides_axis_tready   ),
    .s_axis_tvalid          ( ides_axis_tvalid   ),
    .s_axis_tkeep           ( ides_axis_tkeep    ),
    .s_axis_tdata           ( ides_axis_tdata    ),
    .s_axis_tlast           ( ides_axis_tlast    ),
    .s_axis_tuser           ( ides_axis_tuser    ),
        
    .m_axis_tready          ( odes_axis_tready ),
    .m_axis_tvalid          ( odes_axis_tvalid ),
    .m_axis_tkeep           ( odes_axis_tkeep  ),
    .m_axis_tdata           ( odes_axis_tdata  ),
    .m_axis_tlast           ( odes_axis_tlast  ),
    .m_axis_tuser           ( odes_axis_tuser  ),
                                              
    .free_space             ( des_free_space  ),
    .used_space             ( des_used_space  )
);

AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (16),
    .USER_BIT  (3)
)AXISRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(disp_axis_tready),
    .s_axis_tvalid(disp_axis_tvalid),
    .s_axis_tkeep (disp_axis_tkeep ),
    .s_axis_tdata (disp_axis_tdata ),
    .s_axis_tlast (disp_axis_tlast ),
    .s_axis_tuser ({disp_axis_tuser,disp_axis_tdest}),    
//AXI Stream输出接口
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser ({m_axis_tuser,m_axis_tdest})
);
endmodule
/*
SRv6FwdProc SRv6FwdProc_Inst(  
    .axis_clk             (),
    .axis_rst_n           (),
    
    .s_axis_tready        (),
    .s_axis_tvalid        (),
    .s_axis_tkeep         (),
    .s_axis_tdata         (),
    .s_axis_tlast         (),
    .s_axis_tuser         (),
                          
    .m_axis_tready        (),
    .m_axis_tvalid        (),
    .m_axis_tkeep         (),
    .m_axis_tdata         (),
    .m_axis_tlast         (),
    .m_axis_tuser         ()
);
*/