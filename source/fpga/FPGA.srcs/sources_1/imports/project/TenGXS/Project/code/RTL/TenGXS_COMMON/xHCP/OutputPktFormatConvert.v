
/************************************************************************
       Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
************************************************************************/
/*
Vendor C2Comm
Version 1.0
Filename  OutputPktFormatConvert.v
Target Device All
Dscription 
    1)接收本地上报的控制BE分组
    2)将接收的分组数据由GMII接口信号转换成axi_stream信号
    3)为分组增加MD，将分组的DMAC还原并将记录在DMAC中的时间戳移到MD

Data_Struct:    
    1)Metadata    
        [127:120]   输入端口号       8   输入端口号
        [119: 88]   输出端口号       32  输出端口号
        [ 87: 77]   报文长度         11  报文的长度，不包含Metadata长度
        [ 76: 73]   帧类型           4   根据分组的C-TAG或以太网类型字段区分的帧类型
            0:ST帧
            1:RC帧
            2:BE帧
            3:PTP帧
            4:TSMP帧
            5:PCF帧
        [ 72: 69]   帧优先级         4   不同类型分组的优先级，与帧类型字段配合使用
        [ 68: 42] 保留             27  保留
        [ 41: 32] 时间槽             10  报文的接收时间槽，用于ST流进行注入控制
        [ 31:  0] 接收时间戳         32  报文的接收时间戳,用于透明时钟域计算，只需要32bit即可满足计算要求，单位8ns

Caution: 

Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module OutputPktFormatConvert#(
    parameter   TIME_MAX   = 64'h3D_0900_0000,
                D_CLK_UNIT = 1,
                INIT_DLY   = 3
)(
    //时钟复位信号
    input  wire         axis_clk  ,
    input  wire         axis_rst_n,
    input  wire         hcp_clk  ,
    input  wire         hcp_rst_n,
    //与HCP逻辑对应的接口
    input  wire [  7:0] iv_gmii_txd,
    input  wire         i_gmii_en,
    input  wire         i_gmii_er,

    input  wire         i_axis_tready,
    output wire         o_axis_tvalid,
    output wire [ 15:0] ov_axis_tkeep,
    output wire [127:0] ov_axis_tdata,
    output wire         o_axis_tlast
);

/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
reg          s_axis_tvalid;
reg  [ 15:0] s_axis_tkeep;
reg  [127:0] s_axis_tdata;
reg          s_axis_tlast;
reg          s_axis_tuser;

wire         int_axis_tready;
wire         int_axis_tvalid;
wire [ 15:0] int_axis_tkeep;
wire [127:0] int_axis_tdata;
wire         int_axis_tlast;
wire         int_axis_tuser;

wire [ 31:0] used_space; 

wire         ext_axis_tready;
wire         ext_axis_tvalid;
wire [ 15:0] ext_axis_tkeep;
wire [127:0] ext_axis_tdata;
wire         ext_axis_tlast;
wire         ext_axis_tuser;

wire         w_sfifo_rd;
wire [ 10:0] wv_sfifo_rdata;
wire [  5:0] wv_sfifo_rdusedw;
wire         w_sfifo_full;
wire         w_sfifo_empty;

reg  [  3:0] rv_rcv_cnt;

reg  [  3:0] rv_pkt_infifo_cnt;
reg  [ 10:0] rv_pktin_lenght;
reg  [ 10:0] rv_rcvpkt_len_reg;
reg          r_rcv_pkt_finish;

reg  [127:0] int_aixs_tadta_reg;

wire [  0:0] m_axis_sop;

reg  [  2:0] rcv_state;
localparam   R_IDLE_S  = 3'd0,
             MD_S      = 3'd1,
             INFIFO_S  = 3'd2,
             DISCARD_S = 3'd3;
/************************************************************************
                                分组格式转换并写入FIFO
*************************************************************************/

always @(posedge hcp_clk or negedge hcp_rst_n) begin
    if(hcp_rst_n == 1'b0)begin
        s_axis_tvalid       <= 1'd0;
        s_axis_tkeep        <= 16'd0;
        s_axis_tdata        <= 128'd0;
        s_axis_tlast        <= 1'd0;
        s_axis_tuser        <= 1'd0;
        
        int_aixs_tadta_reg  <= 128'd0;
        
        rv_pkt_infifo_cnt   <= 4'd0;
        rv_pktin_lenght     <= 11'd0;
        rv_rcvpkt_len_reg   <= 11'd0;
        r_rcv_pkt_finish    <= 1'd0;
        
        rv_rcv_cnt          <= 4'd0;
        
        rcv_state           <= R_IDLE_S;
    end
    else begin
        case(rcv_state)
        R_IDLE_S:begin
            s_axis_tvalid       <= 1'd0;
            s_axis_tkeep        <= 16'd0;
            s_axis_tdata        <= 128'd0;
            s_axis_tlast        <= 1'd0;
            s_axis_tuser        <= 1'd0;
            
            int_aixs_tadta_reg  <= 128'd0;
            
            r_rcv_pkt_finish    <= 1'd0;
            if(i_gmii_en == 1'd1)begin
                rv_pkt_infifo_cnt   <= 4'd1;
                rv_pktin_lenght     <= 11'd1;
                
                s_axis_tdata[127:120]       <= iv_gmii_txd;
                
                rcv_state <= (used_space[8] == 1'b1) ? DISCARD_S : MD_S;//存在溢出风险时丢弃发送报文
            end
            else begin
                rcv_state           <= R_IDLE_S;
            end
        end
        
        DISCARD_S: begin
            s_axis_tvalid       <= 1'd0;
            s_axis_tkeep        <= 16'd0;
            s_axis_tdata        <= 128'd0;
            s_axis_tlast        <= 1'd0;
            s_axis_tuser        <= 1'd0;
            
            r_rcv_pkt_finish    <= 1'd0;
            if(i_gmii_en == 1'd1)begin
                rcv_state           <= DISCARD_S;
            end
            else begin
                rcv_state           <= R_IDLE_S;
            end
        end
        
        MD_S:begin
            if(i_gmii_en == 1'd1)begin
                rv_pktin_lenght     <= rv_pktin_lenght + 11'd1;
                
                rv_pkt_infifo_cnt   <= rv_pkt_infifo_cnt + 4'd1;
                case(rv_pkt_infifo_cnt)
                4'd1: begin
                    int_aixs_tadta_reg[8*14+7:8*14]   <= iv_gmii_txd;
                    int_aixs_tadta_reg[8*15+7:8*15]   <= s_axis_tdata[127:120];
                end
                4'd2: int_aixs_tadta_reg[8*13+7:8*13]   <= iv_gmii_txd;
                4'd3: int_aixs_tadta_reg[8*12+7:8*12]   <= iv_gmii_txd;
                4'd4: int_aixs_tadta_reg[8*11+7:8*11]   <= iv_gmii_txd;
                4'd5: int_aixs_tadta_reg[8*10+7:8*10]   <= iv_gmii_txd;
                4'd6: int_aixs_tadta_reg[8*9+7 :8*9 ]   <= iv_gmii_txd;
                4'd7: int_aixs_tadta_reg[8*8+7 :8*8 ]   <= iv_gmii_txd;
                4'd8: int_aixs_tadta_reg[8*7+7 :8*7 ]   <= iv_gmii_txd;
                4'd9: int_aixs_tadta_reg[8*6+7 :8*6 ]   <= iv_gmii_txd;
                4'd10:int_aixs_tadta_reg[8*5+7 :8*5 ]   <= iv_gmii_txd;
                4'd11:int_aixs_tadta_reg[8*4+7 :8*4 ]   <= iv_gmii_txd;
                4'd12:int_aixs_tadta_reg[8*3+7 :8*3 ]   <= iv_gmii_txd;
                4'd13:int_aixs_tadta_reg[8*2+7 :8*2 ]   <= iv_gmii_txd;
                4'd14:int_aixs_tadta_reg[8*1+7 :8*1 ]   <= iv_gmii_txd;
                4'd15:int_aixs_tadta_reg[8*0+7 :8*0 ]   <= iv_gmii_txd;
                default:int_aixs_tadta_reg  <= 128'd0;
                endcase
                if(rv_pkt_infifo_cnt == 4'd14)begin
                    s_axis_tvalid     <= 1'd1;
                    s_axis_tkeep      <= 16'hFFFF;
                    s_axis_tlast      <= 1'd0;
                    
                    s_axis_tdata[127:120]  <= 8'hFF;//输入端口号，HCP下发，默认为FF
                    s_axis_tdata[119: 88]  <= 32'd1;//输出端口号，由控制BE查表转发模块填写
                    s_axis_tdata[ 87: 77]  <= 11'd0;//分组长度
                    s_axis_tdata[ 72: 69]  <= 4'd0;//帧优先级
                    s_axis_tdata[ 68: 42]  <= 27'd0;//保留
                    s_axis_tdata[ 41: 32]  <= 10'd0;//时间槽
                    s_axis_tdata[ 31:  0]  <= 31'd0;
                    if(int_aixs_tadta_reg[31:16] == 16'hFF01)begin
                        s_axis_tdata[ 76: 73]   <= 4'd4;//帧类型，HCP下发的为TSMP
                    end
                    else if(int_aixs_tadta_reg[31:16] == 16'h88F7)begin
                        s_axis_tdata[ 76: 73]   <= 4'd3;//帧类型，HCP下发的为PTP
                    end
                    else if(int_aixs_tadta_reg[31:16] == 16'h891D)begin
                        s_axis_tdata[ 76: 73]   <= 4'd5;//帧类型，HCP下发的为PCF
                    end
                    else begin
                        s_axis_tdata[ 76: 73]   <= 4'd2;//BE类型
                    end
                end
                else if(rv_pkt_infifo_cnt == 4'd15)begin
                    s_axis_tvalid       <= 1'd1;
                    s_axis_tkeep        <= 16'hFFFF;
                    s_axis_tdata        <= {int_aixs_tadta_reg[127:8],iv_gmii_txd};
                    s_axis_tlast        <= 1'd0;
                    
                    rcv_state           <= INFIFO_S;
                end
                else begin
                    s_axis_tvalid       <= 1'd0;
                    s_axis_tkeep        <= 16'hFFFF;
                    s_axis_tlast        <= 1'd0;
                end
            end
            else begin
                rcv_state           <= DISCARD_S;
            end
        end
        
        INFIFO_S:begin
            if(i_gmii_en == 1'd1)begin
                rcv_state           <= INFIFO_S;
                
                rv_pktin_lenght     <= rv_pktin_lenght + 11'd1;
                case(rv_pkt_infifo_cnt)
                4'd0: s_axis_tdata[8*15+7:8*15]   <= iv_gmii_txd;
                4'd1: s_axis_tdata[8*14+7:8*14]   <= iv_gmii_txd;
                4'd2: s_axis_tdata[8*13+7:8*13]   <= iv_gmii_txd;
                4'd3: s_axis_tdata[8*12+7:8*12]   <= iv_gmii_txd;
                4'd4: s_axis_tdata[8*11+7:8*11]   <= iv_gmii_txd;
                4'd5: s_axis_tdata[8*10+7:8*10]   <= iv_gmii_txd;
                4'd6: s_axis_tdata[8*9+7 :8*9 ]   <= iv_gmii_txd;
                4'd7: s_axis_tdata[8*8+7 :8*8 ]   <= iv_gmii_txd;
                4'd8: s_axis_tdata[8*7+7 :8*7 ]   <= iv_gmii_txd;
                4'd9: s_axis_tdata[8*6+7 :8*6 ]   <= iv_gmii_txd;
                4'd10:s_axis_tdata[8*5+7 :8*5 ]   <= iv_gmii_txd;
                4'd11:s_axis_tdata[8*4+7 :8*4 ]   <= iv_gmii_txd;
                4'd12:s_axis_tdata[8*3+7 :8*3 ]   <= iv_gmii_txd;
                4'd13:s_axis_tdata[8*2+7 :8*2 ]   <= iv_gmii_txd;
                4'd14:s_axis_tdata[8*1+7 :8*1 ]   <= iv_gmii_txd;
                4'd15:s_axis_tdata[8*0+7 :8*0 ]   <= iv_gmii_txd;
                endcase
                rv_pkt_infifo_cnt   <= rv_pkt_infifo_cnt + 4'd1;
                if(rv_pkt_infifo_cnt == 4'd15)begin
                    s_axis_tvalid     <= 1'd1;
                    s_axis_tkeep      <= 16'hFFFF;
                    s_axis_tlast      <= 1'd0;
                end
                else begin
                    s_axis_tvalid     <= 1'd0;
                    s_axis_tkeep      <= 16'hFFFF;
                    s_axis_tlast      <= 1'd0;
                end
            end
            else begin
                rv_rcvpkt_len_reg   <= rv_pktin_lenght;
                r_rcv_pkt_finish    <= 1'd1;
                
                rcv_state           <= R_IDLE_S;
                if(rv_pkt_infifo_cnt == 4'd0)begin
                    s_axis_tvalid       <= 1'd0;
                    s_axis_tkeep        <= 16'hFFFF;
                    s_axis_tlast        <= 1'd1;
                end
                else begin
                    s_axis_tvalid       <= 1'd1;
                    s_axis_tlast        <= 1'd1;
                    case(rv_pkt_infifo_cnt)
                    4'd1: s_axis_tkeep    <= 16'b1000_0000_0000_0000;
                    4'd2: s_axis_tkeep    <= 16'b1100_0000_0000_0000;
                    4'd3: s_axis_tkeep    <= 16'b1110_0000_0000_0000;
                    4'd4: s_axis_tkeep    <= 16'b1111_0000_0000_0000;
                    4'd5: s_axis_tkeep    <= 16'b1111_1000_0000_0000;
                    4'd6: s_axis_tkeep    <= 16'b1111_1100_0000_0000;
                    4'd7: s_axis_tkeep    <= 16'b1111_1110_0000_0000;
                    4'd8: s_axis_tkeep    <= 16'b1111_1111_0000_0000;
                    4'd9: s_axis_tkeep    <= 16'b1111_1111_1000_0000;
                    4'd10:s_axis_tkeep    <= 16'b1111_1111_1100_0000;
                    4'd11:s_axis_tkeep    <= 16'b1111_1111_1110_0000;
                    4'd12:s_axis_tkeep    <= 16'b1111_1111_1111_0000;
                    4'd13:s_axis_tkeep    <= 16'b1111_1111_1111_1000;
                    4'd14:s_axis_tkeep    <= 16'b1111_1111_1111_1100;
                    4'd15:s_axis_tkeep    <= 16'b1111_1111_1111_1110;
                    default:s_axis_tkeep    <= 16'b1111_1111_1111_1111;
                    endcase
                end
            end
        end
        
        default:begin
            s_axis_tvalid       <= 1'd0;
            s_axis_tkeep        <= 16'd0;
            s_axis_tdata        <= 128'd0;
            s_axis_tlast        <= 1'd0;
            s_axis_tuser        <= 1'd0;
                
            rv_pkt_infifo_cnt   <= 4'd0;
            rv_pktin_lenght     <= 11'd0;
            rv_rcvpkt_len_reg   <= 11'd0;
            
            rcv_state           <= R_IDLE_S;
        end
        endcase
    end
end

assign int_axis_tvalid      = s_axis_tvalid;
assign int_axis_tkeep       = s_axis_tkeep;
assign int_axis_tdata       = s_axis_tdata;
assign int_axis_tlast       = ((s_axis_tvalid == 1'd1) && (i_gmii_en == 1'd0)) ? 1'd1:1'd0;
assign int_axis_tuser       = s_axis_tuser;

/************************************************************************
                                从FIFO中提取分组并构造MD输出
*************************************************************************/
assign ext_axis_tready = i_axis_tready;
assign o_axis_tvalid   = ext_axis_tvalid;
assign ov_axis_tkeep   = ext_axis_tkeep;
assign o_axis_tlast    = ext_axis_tlast;
assign ov_axis_tdata   = (m_axis_sop == 1'd1) ? 
                         {ext_axis_tdata[127:88],wv_sfifo_rdata,ext_axis_tdata[76:0]} : ext_axis_tdata;

assign w_sfifo_rd = m_axis_sop;
/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISFifoBuf #(
    .ASYNC_EN               ( 1                     ), //同步或异步  0：同步  1：异步
    .DEEP_WIDTH             ( 9                     ), //缓存FIFO的容量的指数位宽
    .PKT_MODE               ( 1                     ), //处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE              ( 16                    ),
    .USER_BIT               ( 1                     )
)RxFifoBuf(     
    //ports     
    .s_axis_clk             ( hcp_clk               ),
    .s_axis_rst_n           ( hcp_rst_n             ),
            
    .m_axis_clk             ( axis_clk              ),
    .m_axis_rst_n           ( axis_rst_n            ),
            
    .s_axis_tready          ( int_axis_tready       ),
    .s_axis_tvalid          ( int_axis_tvalid       ),
    .s_axis_tkeep           ( int_axis_tkeep        ),
    .s_axis_tdata           ( int_axis_tdata        ),
    .s_axis_tlast           ( int_axis_tlast        ),
    .s_axis_tuser           ( int_axis_tuser        ),
            
    .m_axis_tready          ( ext_axis_tready       ),
    .m_axis_tvalid          ( ext_axis_tvalid       ),
    .m_axis_tkeep           ( ext_axis_tkeep        ),
    .m_axis_tdata           ( ext_axis_tdata        ),
    .m_axis_tlast           ( ext_axis_tlast        ),
    .m_axis_tuser           ( ext_axis_tuser        ),
            
    .free_space             (                       ),
    .used_space             ( used_space            )
);      
        
ParamAsyncFifo #(       
    .ADDR_WIDTH             ( 6                     ),
    .DATA_WIDTH             ( 11                    )
)sfifo_inst(        
    .wrclk                  ( hcp_clk               ),
    .rdclk                  ( axis_clk              ),
    .aclr                   ( !axis_rst_n           ),
                                
    .wrreq                  ( r_rcv_pkt_finish      ),
    .rdreq                  ( w_sfifo_rd            ),
    .data                   ( rv_rcvpkt_len_reg     ),
    .q                      ( wv_sfifo_rdata        ),
        
    .rdusedw                (wv_sfifo_rdusedw       ),
    .wrusedw                (                       ),
    .wrfull                 ( w_sfifo_full          ),
    .rdfull                 (                       ),
    .empty                  ( w_sfifo_empty         )
            
);      
        
PktLineDet #(       
    .WIDTH(8)       
)m_axis_inst(       
    .user_clk               ( axis_clk              ),
    .user_rst_n             ( axis_rst_n            ),
    .valid                  ( {ext_axis_tvalid & ext_axis_tready}),
    .last                   ( ext_axis_tlast        ),
    .sop                    ( m_axis_sop            ),
    .line_id                (                       ),
    .eop                    (                       )
);  

endmodule

/*
OutputPktFormatConvert #(
    .TIME_MAX               ( TIME_MAX              ),
    .D_CLK_UNIT             ( D_CLK_UNIT            ),
    .INIT_DLY               ( INIT_DLY              )
)OutputPktFormatConvert_inst(
    .axis_clk               (),
    .axis_rst_n             (),
    .hcp_clk                (),
    .hcp_rst_n              (),

    .iv_lcoal_cnt           (),

    .iv_gmii_txd            (),
    .i_gmii_en              (),
    .i_gmii_er              (),

    .i_axis_tready          (),
    .o_axis_tvalid          (),
    .ov_axis_tkeep          (),
    .ov_axis_tdata          (),
    .o_axis_tlast           ()
);
*/