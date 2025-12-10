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
        
    2)遥测信息
        [115:100] pkt_len
        [ 99: 36] timestamp
        [ 35: 16] flow label
        [ 15:  0] 帧的序列号seqnum

Caution:
    1)
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module SRv6RcvFmtCov(
//时钟复位信号
    input  wire         s_axis_clk,
    input  wire         s_axis_rst_n,
    input  wire         m_axis_clk,
    input  wire         m_axis_rst_n,
//Metadata数据输入接口
    input  wire         i_md_tvalid,
    input  wire [127:0] iv_md_tdata,
//本地同步时钟        
    input  wire [ 63:0] iv_local_cnt,
//报文分组数据接收接口
(*mark_debug="true"*)    output wire         s_axis_tready,
(*mark_debug="true"*)    input  wire         s_axis_tvalid,
(*mark_debug="true"*)    input  wire [ 15:0] s_axis_tkeep,
(*mark_debug="true"*)    input  wire [127:0] s_axis_tdata,
(*mark_debug="true"*)    input  wire         s_axis_tlast,
(*mark_debug="true"*)    input  wire         s_axis_tuser,
//分组数据输出接口
(*mark_debug="true"*)    input  wire         m_axis_tready,
(*mark_debug="true"*)    output reg          m_axis_tvalid,
(*mark_debug="true"*)    output reg  [ 15:0] m_axis_tkeep,
(*mark_debug="true"*)    output reg  [127:0] m_axis_tdata,
(*mark_debug="true"*)    output reg          m_axis_tlast,
(*mark_debug="true"*)    output reg  [ 11:0] m_axis_tuser,
//遥测数据输出接口
(*mark_debug="true"*)    input  wire         m_tm_axis_tready,
(*mark_debug="true"*)    output reg          m_tm_axis_tvalid,
(*mark_debug="true"*)    output reg  [115:0] m_tm_axis_tdata ,
//统计信息
(*mark_debug="true"*)    output reg  [ 63:0] ov_rcv_allpkt_cnt,
(*mark_debug="true"*)    output reg  [ 63:0] ov_rcv_filtpkt_cnt,
(*mark_debug="true"*)    output reg  [ 63:0] ov_rcv_discpkt_cnt,
(*mark_debug="true"*)    output reg  [ 63:0] ov_rcv_tm_cnt 
);
/*----------------------------------------------------------------------
                                中间变量声明区域
----------------------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
(*mark_debug="true"*)reg          acf_axis_tready;
(*mark_debug="true"*)wire         acf_axis_tvalid;
(*mark_debug="true"*)wire [ 15:0] acf_axis_tkeep ;
(*mark_debug="true"*)wire [127:0] acf_axis_tdata ;
(*mark_debug="true"*)wire         acf_axis_tlast ;
(*mark_debug="true"*)wire [  0:0] acf_axis_tuser ;

(*mark_debug="true"*)wire [ 31:0] acf_free_space ;
(*mark_debug="true"*)wire [ 31:0] acf_used_space ;

(*mark_debug="true"*)wire         mfifo_wr   ;
(*mark_debug="true"*)wire [127:0] mfifo_wdata; 
(*mark_debug="true"*)reg          mfifo_rd   ;
(*mark_debug="true"*)wire [127:0] mfifo_rdata;
(*mark_debug="true"*)wire [  5:0] mfifo_wrusedw;
(*mark_debug="true"*)wire [  5:0] mfifo_rdusedw;
(*mark_debug="true"*)wire         mfifo_wrfull ;
(*mark_debug="true"*)wire         mfifo_rdempty;

(*mark_debug="true"*)reg          tm_vreg;  //valid
(*mark_debug="true"*)reg  [115:0] tm_dreg;  //data

(*mark_debug="true"*)reg  [  1:0] rfc_state;

localparam START_S = 3'd0,
           TRANS_S = 3'd1,
           DISC_S  = 3'd2;
           
(*mark_debug="true"*)wire [4:0] line_byte;

/*----------------------------------------------------------------------
                                统计信息
----------------------------------------------------------------------*/
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        ov_rcv_allpkt_cnt  <= 64'b0;
        ov_rcv_filtpkt_cnt <= 64'b0;
        ov_rcv_discpkt_cnt <= 64'b0;
        ov_rcv_tm_cnt      <= 64'b0;
    end
    else begin
        if(acf_axis_tready && acf_axis_tvalid && acf_axis_tlast)begin
            ov_rcv_allpkt_cnt  <= ov_rcv_allpkt_cnt  + 64'd1;
        end
        else begin
            ov_rcv_allpkt_cnt  <= ov_rcv_allpkt_cnt ;
        end
        
        if(m_axis_tready && m_axis_tvalid && m_axis_tlast)begin
            ov_rcv_filtpkt_cnt <= ov_rcv_filtpkt_cnt + 64'd1;
        end
        else begin
            ov_rcv_filtpkt_cnt <= ov_rcv_filtpkt_cnt ;
        end
        
        if(acf_axis_tready && acf_axis_tvalid && acf_axis_tlast && (rfc_state == DISC_S))begin
            ov_rcv_discpkt_cnt <= ov_rcv_discpkt_cnt + 64'd1;
        end
        else begin
            ov_rcv_discpkt_cnt <= ov_rcv_discpkt_cnt ;
        end
        
        if(m_tm_axis_tready && m_tm_axis_tvalid)begin
            ov_rcv_tm_cnt      <= ov_rcv_tm_cnt      + 64'd1;
        end
        else begin
            ov_rcv_tm_cnt      <= ov_rcv_tm_cnt ;
        end
    
    end
end

/*----------------------------------------------------------------------
                                输入处理
----------------------------------------------------------------------*/
assign mfifo_wr    = i_md_tvalid;
assign mfifo_wdata = iv_md_tdata;
/*----------------------------------------------------------------------
                                接收格式处理
----------------------------------------------------------------------*/
assign line_byte = acf_axis_tkeep[ 0] + acf_axis_tkeep[ 1] + acf_axis_tkeep[ 2] + acf_axis_tkeep[ 3] +
                   acf_axis_tkeep[ 4] + acf_axis_tkeep[ 5] + acf_axis_tkeep[ 6] + acf_axis_tkeep[ 7] +
                   acf_axis_tkeep[ 8] + acf_axis_tkeep[ 9] + acf_axis_tkeep[10] + acf_axis_tkeep[11] +
                   acf_axis_tkeep[12] + acf_axis_tkeep[13] + acf_axis_tkeep[14] + acf_axis_tkeep[15];


always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        acf_axis_tready  <= 1'b0;
        mfifo_rd         <= 1'b0;
        m_axis_tvalid    <= 1'b0;
        m_axis_tdata     <= 128'b0;
        rfc_state        <= START_S;
    end
    else begin
        case(rfc_state)
            START_S: begin
                m_axis_tlast <= 1'b0;
                m_axis_tuser <= 12'b0;//累加长度，不包含Metadata
                m_axis_tkeep <= {16{1'b1}};
                if((acf_axis_tvalid == 1'b1) && (mfifo_rdempty == 1'b0))begin//有数据正在输入,且包含Metadata
                    acf_axis_tready <= 1'b1;
                    mfifo_rd        <= 1'b1;
                    m_axis_tdata    <= mfifo_rdata;
                    if((m_axis_tready == 1'b1) && 
                       ((mfifo_rdata[87:84] == 4'd0) || 
                        (mfifo_rdata[87:84] == 4'd1) || 
                        (mfifo_rdata[87:84] == 4'd4) ||
                        (mfifo_rdata[87:84] == 4'd8))
                       ) begin//报文为正确类型,先发送Metadata
                        m_axis_tvalid <= 1'b1;
                        rfc_state     <= TRANS_S;
                    end
                    else begin//对方无法接收完整分组，丢弃数据
                        m_axis_tvalid <= 1'b0;
                        rfc_state     <= DISC_S;
                    end
                end
                else begin//无数据
                    acf_axis_tready  <= 1'b0;
                    mfifo_rd         <= 1'b0;
                    m_axis_tvalid    <= 1'b0;
                    rfc_state        <= START_S;
                end
            end

            DISC_S: begin
                mfifo_rd        <= 1'b0;
                m_axis_tvalid   <= 1'b0;
                
                if((acf_axis_tvalid == 1'b1) && (acf_axis_tlast == 1'b1))begin//报文尾部传输完成
                    acf_axis_tready <= 1'b0;
                    rfc_state       <= START_S;
                end
                else begin
                    acf_axis_tready <= 1'b1;
                    rfc_state       <= DISC_S;
                end
            end

            TRANS_S: begin
                mfifo_rd           <= 1'b0;
                
                m_axis_tvalid      <= acf_axis_tvalid;
                m_axis_tlast       <= acf_axis_tlast;
                m_axis_tkeep       <= acf_axis_tkeep;
                m_axis_tdata       <= acf_axis_tdata;
                m_axis_tuser[  11] <= acf_axis_tuser;
                m_axis_tuser[10:0] <= (acf_axis_tvalid == 1'b1)? 
                                         m_axis_tuser[10:0] + line_byte : m_axis_tuser[10:0];
                                         
                if((acf_axis_tvalid == 1'b1) && (acf_axis_tlast == 1'b1))begin//报文尾部传输完成
                    acf_axis_tready <= 1'b0;
                    rfc_state       <= START_S;
                end
                else begin
                    acf_axis_tready <= 1'b1;
                    rfc_state       <= TRANS_S;
                end

            end
            default: begin
                acf_axis_tready  <= 1'b0;
                mfifo_rd         <= 1'b0;
                m_axis_tvalid    <= 1'b0;
                m_axis_tdata     <= 128'b0;
                rfc_state        <= START_S;
            end
        endcase

    end
end

/*----------------------------------------------------------------------
                                遥测信息输出
----------------------------------------------------------------------*/
always @(posedge m_axis_clk or negedge m_axis_rst_n) begin
    if(m_axis_rst_n == 1'b0) begin
        tm_vreg <= 1'b0;
        tm_dreg <= 116'b0;
    end
    else begin
        tm_vreg <= m_tm_axis_tvalid;
        tm_dreg <= m_tm_axis_tdata;
    end
end

always @(*) begin
    if(mfifo_rd == 1'b1)begin//记录除长度外的其他3个字段信息
        m_tm_axis_tvalid = 1'b0;
        if(mfifo_rdata[99]==1'b1)//输入遥测
            m_tm_axis_tdata  = {1'b1,15'b0,iv_local_cnt,mfifo_rdata[83:48]};//1bit 遥测标记+15bit rsv + 64 bit timestamp+ 20bit flowlabel+ 16bit tagid
        else//非遥测
            m_tm_axis_tdata  = 116'b0;
    end
    else if((m_axis_tready == 1'b1) && 
            (m_axis_tvalid == 1'b1) && 
            (m_axis_tlast == 1'b1) && 
            (tm_dreg[115] == 1'b1)) begin//报文尾部且属于输入遥测,添加长度,并输出遥测信息
        m_tm_axis_tvalid = 1'b1;
        m_tm_axis_tdata  = {5'b0,m_axis_tuser[10:0],tm_dreg[99:0]};
    end
    else if(m_tm_axis_tready == 1'b1)begin
        m_tm_axis_tvalid = 1'b0;
        m_tm_axis_tdata  = tm_dreg;
    end
    else begin
        m_tm_axis_tvalid = tm_vreg;
        m_tm_axis_tdata  = tm_dreg;
    end
end
/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISFifoBuf #(
    .ASYNC_EN               ( 1                 ),
    .DEEP_WIDTH             ( 6                 ),
    .PKT_MODE               ( 0                 ),
    .DATA_BYTE              ( 16                ),
    .USER_BIT               ( 1                 ),
    .MIN_PKTLINE            ( 4                 )
)RxFifoBuf(  
    //ports 
    .s_axis_clk             ( s_axis_clk        ),
    .s_axis_rst_n           ( s_axis_rst_n      ),
        
    .m_axis_clk             ( m_axis_clk        ),
    .m_axis_rst_n           ( m_axis_rst_n      ),
        
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
        
    .free_space             ( acf_free_space    ),
    .used_space             ( acf_used_space    )
);  
    
ParamAsyncFifo #(   
    .DATA_WIDTH             ( 128               ),
    .ADDR_WIDTH             ( 6                 )
)async_mfifo_inst(  
    .wrclk                  ( s_axis_clk        ),
    .rdclk                  ( m_axis_clk        ),
    .aclr                   ( ~(s_axis_rst_n&m_axis_rst_n)),
                            
    .wrreq                  ( mfifo_wr          ),
    .data                   ( mfifo_wdata       ),
    .rdreq                  ( mfifo_rd          ),
    .q                      ( mfifo_rdata       ),
                                    
    .wrusedw                ( mfifo_wrusedw     ),
    .wrfull                 ( mfifo_wrfull      ),
    .rdfull                 (                   ),
    .rdusedw                ( mfifo_rdusedw     ),
    .empty                  ( mfifo_rdempty     )
);
endmodule

/*
SRv6RcvFmtCov SRv6RcvFmtCov_Inst(
    .s_axis_clk             (),
    .s_axis_rst_n           (),
    .m_axis_clk             (),
    .m_axis_rst_n           (),
    //本地同步时钟        
    .iv_local_cnt           (),
        
    .i_md_tvalid            (),
    .iv_md_tdata            (),
        
    .s_axis_tready          (),
    .s_axis_tvalid          (),
    .s_axis_tkeep           (),
    .s_axis_tdata           (),
    .s_axis_tlast           (),
    .s_axis_tuser           (),
        
    .m_axis_tready          (),
    .m_axis_tvalid          (),
    .m_axis_tkeep           (),
    .m_axis_tdata           (),
    .m_axis_tlast           (),
    .m_axis_tuser           (),   
    
    .m_tm_axis_tready       (),
    .m_tm_axis_tvalid       (),
    .m_tm_axis_tkeep        (),
//统计信息
    .ov_rcv_allpkt_cnt      (),
    .ov_rcv_filtpkt_cnt     (),
    .ov_rcv_discpkt_cnt     (),
    .ov_rcv_tm_cnt          ()
);
*/