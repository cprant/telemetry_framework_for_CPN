
/************************************************************************
       Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
************************************************************************/
/*
Vendor C2Comm
Version 1.0
Filename  InputPktFormatConvert.v
Target Device All
Dscription 
    1)接收与本地通信的控制BE分组
    2)将接收的分组数据由axi_stream信号转换成GMII接口信号
    2)将分组MD丢弃，并将MD的接收时间戳移到分组DMAC位置

Data_Struct:    

Caution: 
    
Author : cb
Revision List:
    rn1:    date:20211223 modifier:lxj
    description:
        在hcp_rx中的FIFO读写控制逻辑存在BUG，如果报文发送过快，会导致错包，因此需要将配置速率限制
        复用rv_pkt_timestamp寄存器低5bit，为每个报文传输添加20拍间隔(8前导符+12帧间隔)
        规避HCP逻辑中的hcp_rx 读FIFO溢出出错
    
    rn2:    date:   modifier:   description:
*/

module InputPktFormatConvert#(
    parameter   TIME_MAX   = 64'h3D_0900_0000,
                D_CLK_UNIT = 1,
                INIT_DLY   = 3
)(
    //时钟复位信号
    input  wire         axis_clk  ,
    input  wire         axis_rst_n,
    input  wire         hcp_clk  ,
    input  wire         hcp_rst_n,
    //分组输入接口
    output wire         o_axis_tready,
    input  wire         i_axis_tvalid,
    input  wire [ 15:0] iv_axis_tkeep,
    input  wire [127:0] iv_axis_tdata,
    input  wire         i_axis_tlast,
    //与HCP逻辑对应的接口
    output reg  [  7:0] ov_gmii_rxd,
    output reg          o_gmii_dv,
    output wire         o_gmii_er
);

/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
//dfifo缓存分组数据
reg          r_dfifo_rd;
wire [128:0] wv_dfifo_rdata;
wire [  7:0] wv_dfifo_rdusedw;
wire         w_dfifo_empty;
wire         w_dfifo_full;

//sfifo缓存分组状态信息
reg  [ 4:0]  rv_sfifo_wdata;
reg          r_sfifo_rd;
wire [  4:0] wv_sfifo_rdata;
wire [  5:0] wv_sfifo_rdusedw;
wire         w_sfifo_empty;

reg  [  3:0] rv_pktout_cnt;
reg  [  4:0] rv_pktgap_cnt;

reg  [  2:0] ipfc_state;
localparam   IDLE_S = 3'd0,
             WAIT_S = 3'd1,
             ETH_S  = 3'd2,
             TRAN_S = 3'd3,
             GAP_S  = 3'd4;

assign o_gmii_er        = 1'd0;
assign o_axis_tready    = ~w_dfifo_full;
/************************************************************************
                                格式转换
*************************************************************************/

always @(posedge hcp_clk or negedge hcp_rst_n) begin
    if(hcp_rst_n == 1'b0)begin
        ov_gmii_rxd         <= 8'd0;
        o_gmii_dv           <= 1'd0;

        r_dfifo_rd          <= 1'd0;
        r_sfifo_rd          <= 1'd0;
        
        rv_pktout_cnt       <= 4'd0;

        ipfc_state          <= IDLE_S;
    end
    else begin
        case(ipfc_state)
        IDLE_S:begin
            ov_gmii_rxd         <= 8'd0;
            o_gmii_dv           <= 1'd0;
            
            r_sfifo_rd          <= 1'd0;
            rv_pktout_cnt       <= 4'd0;
            rv_pktgap_cnt       <= 5'd0;
            if((w_sfifo_empty == 1'b0) && (w_dfifo_empty == 1'b0))begin
            //必须是sfifo和dfifo均不为空才能开始读
            //如果axis_clk远快于hcp_clk时，可能出现sfifo不为空，但dfifo仍显示为空的情况 LXJ20211223
                r_dfifo_rd          <= 1'd1;
                
                ipfc_state          <= WAIT_S;
            end
            else begin
                r_dfifo_rd          <= 1'd0;
            
                ipfc_state          <= IDLE_S;
            end
        end
        
        WAIT_S:begin
            r_dfifo_rd          <= 1'd0;
            
            ipfc_state          <= ETH_S;
        end
        
        ETH_S:begin
            o_gmii_dv           <= 1'd1;
            case(rv_pktout_cnt)
            4'd0: ov_gmii_rxd         <= wv_dfifo_rdata[8*15+7:8*15];
            4'd1: ov_gmii_rxd         <= wv_dfifo_rdata[8*14+7:8*14];
            4'd2: ov_gmii_rxd         <= wv_dfifo_rdata[8*13+7:8*13];
            4'd3: ov_gmii_rxd         <= wv_dfifo_rdata[8*12+7:8*12];
            4'd4: ov_gmii_rxd         <= wv_dfifo_rdata[8*11+7:8*11];
            4'd5: ov_gmii_rxd         <= wv_dfifo_rdata[8*10+7:8*10];
            4'd6: ov_gmii_rxd         <= wv_dfifo_rdata[8*9+7 :8*9];
            4'd7: ov_gmii_rxd         <= wv_dfifo_rdata[8*8+7 :8*8];
            4'd8: ov_gmii_rxd         <= wv_dfifo_rdata[8*7+7 :8*7];
            4'd9: ov_gmii_rxd         <= wv_dfifo_rdata[8*6+7 :8*6];
            4'd10:ov_gmii_rxd         <= wv_dfifo_rdata[8*5+7 :8*5];
            4'd11:ov_gmii_rxd         <= wv_dfifo_rdata[8*4+7 :8*4];
            4'd12:ov_gmii_rxd         <= wv_dfifo_rdata[8*3+7 :8*3];
            4'd13:ov_gmii_rxd         <= wv_dfifo_rdata[8*2+7 :8*2];
            4'd14:ov_gmii_rxd         <= wv_dfifo_rdata[8*1+7 :8*1];
            4'd15:ov_gmii_rxd         <= wv_dfifo_rdata[8*0+7 :8*0];
            endcase
            rv_pktout_cnt       <= rv_pktout_cnt + 4'd1;
            if(rv_pktout_cnt == 4'd14)begin
                r_dfifo_rd          <= 1'd1;
                
                ipfc_state          <= ETH_S;
            end
            else if(rv_pktout_cnt == 4'd15)begin
                r_dfifo_rd          <= 1'd0;
                
                ipfc_state          <= TRAN_S;
            end
            else begin
                r_dfifo_rd          <= 1'd0;
                
                ipfc_state          <= ETH_S;
            end
        end
        
        TRAN_S:begin
            o_gmii_dv           <= 1'd1;
            if(wv_dfifo_rdata[128] == 1'd0)begin
                case(rv_pktout_cnt)
                4'd0: ov_gmii_rxd         <= wv_dfifo_rdata[8*15+7:8*15];
                4'd1: ov_gmii_rxd         <= wv_dfifo_rdata[8*14+7:8*14];
                4'd2: ov_gmii_rxd         <= wv_dfifo_rdata[8*13+7:8*13];
                4'd3: ov_gmii_rxd         <= wv_dfifo_rdata[8*12+7:8*12];
                4'd4: ov_gmii_rxd         <= wv_dfifo_rdata[8*11+7:8*11];
                4'd5: ov_gmii_rxd         <= wv_dfifo_rdata[8*10+7:8*10];
                4'd6: ov_gmii_rxd         <= wv_dfifo_rdata[8*9+7 :8*9];
                4'd7: ov_gmii_rxd         <= wv_dfifo_rdata[8*8+7 :8*8];
                4'd8: ov_gmii_rxd         <= wv_dfifo_rdata[8*7+7 :8*7];
                4'd9: ov_gmii_rxd         <= wv_dfifo_rdata[8*6+7 :8*6];
                4'd10:ov_gmii_rxd         <= wv_dfifo_rdata[8*5+7 :8*5];
                4'd11:ov_gmii_rxd         <= wv_dfifo_rdata[8*4+7 :8*4];
                4'd12:ov_gmii_rxd         <= wv_dfifo_rdata[8*3+7 :8*3];
                4'd13:ov_gmii_rxd         <= wv_dfifo_rdata[8*2+7 :8*2];
                4'd14:ov_gmii_rxd         <= wv_dfifo_rdata[8*1+7 :8*1];
                4'd15:ov_gmii_rxd         <= wv_dfifo_rdata[8*0+7 :8*0];
                endcase
                rv_pktout_cnt       <= rv_pktout_cnt + 4'd1;
                
                ipfc_state          <= TRAN_S;
                if(rv_pktout_cnt == 4'd14)begin
                    r_dfifo_rd          <= 1'd1;
                end
                else begin
                    r_dfifo_rd          <= 1'd0;
                end
            end
            else begin
                case(rv_pktout_cnt)
                4'd0: ov_gmii_rxd         <= wv_dfifo_rdata[8*15+7:8*15];
                4'd1: ov_gmii_rxd         <= wv_dfifo_rdata[8*14+7:8*14];
                4'd2: ov_gmii_rxd         <= wv_dfifo_rdata[8*13+7:8*13];
                4'd3: ov_gmii_rxd         <= wv_dfifo_rdata[8*12+7:8*12];
                4'd4: ov_gmii_rxd         <= wv_dfifo_rdata[8*11+7:8*11];
                4'd5: ov_gmii_rxd         <= wv_dfifo_rdata[8*10+7:8*10];
                4'd6: ov_gmii_rxd         <= wv_dfifo_rdata[8*9+7 :8*9];
                4'd7: ov_gmii_rxd         <= wv_dfifo_rdata[8*8+7 :8*8];
                4'd8: ov_gmii_rxd         <= wv_dfifo_rdata[8*7+7 :8*7];
                4'd9: ov_gmii_rxd         <= wv_dfifo_rdata[8*6+7 :8*6];
                4'd10:ov_gmii_rxd         <= wv_dfifo_rdata[8*5+7 :8*5];
                4'd11:ov_gmii_rxd         <= wv_dfifo_rdata[8*4+7 :8*4];
                4'd12:ov_gmii_rxd         <= wv_dfifo_rdata[8*3+7 :8*3];
                4'd13:ov_gmii_rxd         <= wv_dfifo_rdata[8*2+7 :8*2];
                4'd14:ov_gmii_rxd         <= wv_dfifo_rdata[8*1+7 :8*1];
                4'd15:ov_gmii_rxd         <= wv_dfifo_rdata[8*0+7 :8*0];
                endcase
                
                rv_pktout_cnt       <= rv_pktout_cnt + 4'd1;
                if(rv_pktout_cnt == wv_sfifo_rdata - 4'd1)begin
                    r_sfifo_rd          <= 1'd1;
                    r_dfifo_rd          <= 1'd1;
                    ipfc_state          <= GAP_S;
                end
                else begin
                    ipfc_state          <= TRAN_S;
                end
            end
        end
        
        GAP_S: begin
        //复用rv_pkt_timestamp寄存器低5bit，为每个报文传输添加24拍间隔(在HCP内部逻辑hcp_fram_parse中，添加了24拍间隔，如果不加最终会导致出错)
        //规避HCP逻辑中的hcp_rx 读FIFO溢出出错 LXJ20211223
            ov_gmii_rxd         <= 8'd0;
            o_gmii_dv           <= 1'd0;
            
            r_sfifo_rd          <= 1'd0;
            r_dfifo_rd          <= 1'd0;
            rv_pktgap_cnt       <= rv_pktgap_cnt + 5'd1;
            if(rv_pktgap_cnt < 5'd22)begin
                ipfc_state          <= GAP_S;
            end
            else begin
                ipfc_state          <= IDLE_S;
            end
        end
        
        default:begin
            ov_gmii_rxd         <= 8'd0;
            o_gmii_dv           <= 1'd0;
                
            r_dfifo_rd          <= 1'd0;
            r_sfifo_rd          <= 1'd0;
            rv_pktout_cnt       <= 4'd0;
                
            ipfc_state          <= IDLE_S;
        end
        endcase
    end
end

/************************************************************************
                                分组TKEEP信号转换
*************************************************************************/
always @* begin
    case(iv_axis_tkeep)
    16'b1000_0000_0000_0000:rv_sfifo_wdata = 5'd1;
    16'b1100_0000_0000_0000:rv_sfifo_wdata = 5'd2;
    16'b1110_0000_0000_0000:rv_sfifo_wdata = 5'd3;
    16'b1111_0000_0000_0000:rv_sfifo_wdata = 5'd4;
    16'b1111_1000_0000_0000:rv_sfifo_wdata = 5'd5;
    16'b1111_1100_0000_0000:rv_sfifo_wdata = 5'd6;
    16'b1111_1110_0000_0000:rv_sfifo_wdata = 5'd7;
    16'b1111_1111_0000_0000:rv_sfifo_wdata = 5'd8;
    16'b1111_1111_1000_0000:rv_sfifo_wdata = 5'd9;
    16'b1111_1111_1100_0000:rv_sfifo_wdata = 5'd10;
    16'b1111_1111_1110_0000:rv_sfifo_wdata = 5'd11;
    16'b1111_1111_1111_0000:rv_sfifo_wdata = 5'd12;
    16'b1111_1111_1111_1000:rv_sfifo_wdata = 5'd13;
    16'b1111_1111_1111_1100:rv_sfifo_wdata = 5'd14;
    16'b1111_1111_1111_1110:rv_sfifo_wdata = 5'd15;
    16'b1111_1111_1111_1111:rv_sfifo_wdata = 5'd16;
    default:rv_sfifo_wdata = 5'd0;
    endcase
end

/************************************************************************
                                IP调用区域
*************************************************************************/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
ParamAsyncFifo #(
    .ADDR_WIDTH             ( 8                 ),
    .DATA_WIDTH             ( 129               )
)dfifo_inst(
    .wrclk                  ( axis_clk          ),
    .rdclk                  ( hcp_clk           ),
    .aclr                   ( !axis_rst_n       ),
                              
    .wrreq                  ( i_axis_tvalid & o_axis_tready),
    .rdreq                  ( r_dfifo_rd        ),
    .data                   ( {i_axis_tlast,iv_axis_tdata}),
    .q                      ( wv_dfifo_rdata    ),

    .rdusedw                (wv_dfifo_rdusedw   ),
    .wrusedw                (                   ),
    .wrfull                 ( w_dfifo_full      ),
    .rdfull                 (                   ),
    .empty                  ( w_dfifo_empty     )
);

ParamAsyncFifo #(
    .ADDR_WIDTH             ( 6                 ),
    .DATA_WIDTH             ( 5                 )
)sfifo_inst(
    .wrclk                  ( axis_clk          ),
    .rdclk                  ( hcp_clk           ),
    .aclr                   ( !axis_rst_n       ),
                              
    .wrreq                  (i_axis_tvalid & o_axis_tready & i_axis_tlast),
    .rdreq                  ( r_sfifo_rd        ),
    .data                   ( rv_sfifo_wdata    ),
    .q                      ( wv_sfifo_rdata    ),

    .rdusedw                (wv_sfifo_rdusedw),
    .wrusedw                (                   ),
    .wrfull                 (                   ),
    .rdfull                 (                   ),
    .empty                  ( w_sfifo_empty     )
);

endmodule

/*
InputPktFormatConvert #(
    .TIME_MAX               ( TIME_MAX              ),
    .D_CLK_UNIT             ( D_CLK_UNIT            ),
    .INIT_DLY               ( INIT_DLY              )
)InputPktFormatConvert_inst(
    .axis_clk               (),
    .axis_rst_n             (),
    .hcp_clk                (),
    .hcp_rst_n              (),

    .o_axis_tready          (),
    .i_axis_tvalid          (),
    .iv_axis_tkeep          (),
    .iv_axis_tdata          (),
    .i_axis_tlast           (),

    .ov_gmii_rxd            (),
    .o_gmii_dv              (),
    .o_gmii_er              (),
);
*/