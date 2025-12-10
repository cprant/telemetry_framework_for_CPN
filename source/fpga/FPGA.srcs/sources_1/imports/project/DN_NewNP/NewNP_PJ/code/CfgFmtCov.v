
/************************************************************************
       Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
************************************************************************/
/*
Vendor C2Comm
Version 1.0
Filename  LocalCfgParser.v
Target Device All
Dscription 
    1)接收HCP的配置信息
    2)转换成localbus接口

Data_Struct:    
    ov_hw_state：
        0：关闭状态，丢弃进入CtrlBEMgmt的所有报文
        1：配置状态，仅允许配置报文进入CtrlBEMgmt
        2：同步状态，允许配置报文与同步报文进入CtrlBEMgmt
        3：工作状态，允许所有报文进入CtrlBEMgmt
Caution: 

Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module CfgFmtCov #(
    parameter   Mbus_ID = 1 //连接到HCP的Mbus序号
)(
    //时钟复位信号
    input  wire         user_clk  ,
    input  wire         user_rst_n,
    //HCP输入command接口
    input  wire [ 63:0] iv_command,
    input  wire         i_command_wr,
    output reg  [ 63:0] ov_command_ack,
    output reg          o_command_ack_wr,
    //BE转发平面localbus通信输出接口
    output reg          o_m_lb_cs_n,
    input  wire         i_m_lb_ack_n,
    output reg          o_m_lb_wr_rd,
    output reg  [ 31:0] ov_m_lb_addr,
    output reg  [ 31:0] ov_m_lb_wdata,
    input  wire [ 31:0] iv_m_lb_rdata
    );

/************************************************************************
                                中间变量声明区域
*************************************************************************/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
wire [  1:0] hcp_mbus_id;

//command_fifo
reg          cfifo_rd   ;
wire [ 63:0] cfifo_rdata;
wire [  0:0] cfifo_empty;

wire         sync_ack_valid;

reg  [  2:0] convert_state;
localparam   IDLE_S   = 3'd0,
             WRITE_S  = 3'd1,
             READ_S   = 3'd2,
             ACK_S    = 3'd3,
             WAIT_S   = 3'd4;
             
assign hcp_mbus_id = Mbus_ID;
/*//////////////////////////////////////////////////////////
                    格式转换
*///////////////////////////////////////////////////////////

always @(posedge user_clk or negedge user_rst_n) begin
    if(user_rst_n == 1'b0)begin
        o_m_lb_cs_n         <= 1'd1;
        o_m_lb_wr_rd        <= 1'd0;
        ov_m_lb_addr        <= 31'd0;
        ov_m_lb_wdata       <= 32'd0;
            
        cfifo_rd            <= 1'd0;
            
        ov_command_ack      <= 64'd0;
        o_command_ack_wr    <= 1'd0;
        
        convert_state       <= IDLE_S;
    end
    else begin
        case(convert_state)
        IDLE_S:begin
            ov_command_ack      <= 64'd0;
            o_command_ack_wr    <= 1'd0;
                
            o_m_lb_cs_n         <= 1'd1;
            o_m_lb_wr_rd        <= 1'd0;
            ov_m_lb_wdata       <= 32'd0;
            if((cfifo_empty == 1'd0) && (sync_ack_valid == 1'b0))begin
            //增加ack信号释放的判断，避免连续请求时，上次请求的ack未释放导致的请求误判 lxj20220104
                if(cfifo_rdata[63:62] == 2'd0)begin
                    cfifo_rd            <= 1'd0;
                    
                    convert_state       <= WRITE_S;
                end
                else if(cfifo_rdata[63:62] == 2'd2) begin
                    cfifo_rd            <= 1'd0;
                    
                    convert_state       <= READ_S;
                end
                else begin
                    cfifo_rd            <= 1'd1;
                    
                    convert_state       <= IDLE_S;
                end
            end
            else begin
                cfifo_rd            <= 1'd0;
                
                convert_state       <= IDLE_S;
            end
        end
        
        WRITE_S:begin
            cfifo_rd            <= 1'd1;

            o_m_lb_cs_n         <= 1'd0;
            o_m_lb_wr_rd        <= 1'd0;
            ov_m_lb_addr        <= {hcp_mbus_id,cfifo_rdata[61:32]};
            ov_m_lb_wdata       <= cfifo_rdata[31:0];
                
            convert_state       <= ACK_S;

        end
        
        READ_S:begin
            cfifo_rd            <= 1'd1;
            
            o_m_lb_cs_n         <= 1'd0;
            o_m_lb_wr_rd        <= 1'd1;
            ov_m_lb_addr        <= {hcp_mbus_id,cfifo_rdata[61:32]};
                
            convert_state       <= ACK_S;
        end
        
        ACK_S:begin
            cfifo_rd            <= 1'd0;
            if(sync_ack_valid == 1'd1)begin
                o_m_lb_cs_n         <= 1'd1;
                
                convert_state       <= WAIT_S;
                if(o_m_lb_wr_rd == 1'd1)begin
                    ov_command_ack      <= {2'd3,ov_m_lb_addr[29:0],iv_m_lb_rdata[31:0]};
                    o_command_ack_wr    <= 1'd1;
                end
                else begin
                    ov_command_ack      <= 64'd0;
                    o_command_ack_wr    <= 1'd0;
                end
            end
            else begin
                o_m_lb_cs_n         <= 1'd0;
                    
                convert_state       <= ACK_S;
            end
        end
        
        WAIT_S:begin
            o_m_lb_cs_n         <= 1'd1;
            o_m_lb_wr_rd        <= 1'd0;
            ov_m_lb_wdata       <= 32'd0;
                
            cfifo_rd            <= 1'd0;
                
            ov_command_ack      <= 64'd0;
            o_command_ack_wr    <= 1'd0;
            
            convert_state       <= IDLE_S;
        end
        
        default:begin
            o_m_lb_cs_n         <= 1'd1;
            o_m_lb_wr_rd        <= 1'd0;
            ov_m_lb_addr        <= 32'd0;
            ov_m_lb_wdata       <= 32'd0;
                
            cfifo_rd            <= 1'd0;
                
            ov_command_ack      <= 64'd0;
            o_command_ack_wr    <= 1'd0;
            
            convert_state       <= IDLE_S;
        end
        endcase
    end
end

/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
ParamSyncFifo #(
    .DATA_WIDTH(64),
    .ADDR_WIDTH(8)
)command_fifo_inst(
    .clk    (user_clk       ),
    .aclr   (~user_rst_n    ),
            
    .wrreq  (i_command_wr   ),
    .data   (iv_command     ),
    .rdreq  (cfifo_rd       ),
    .q      (cfifo_rdata    ),
            
    .usedw  (               ),
    .full   (               ),
    .empty  (cfifo_empty    )
);

SyncSig ack_sync_inst(
    .clk                    ( user_clk          ),
    .rst_n                  ( user_rst_n        ),
    
    .in_sig                 ( ~i_m_lb_ack_n     ),
    .out_sig                ( sync_ack_valid    )
);

endmodule

/*
CfgFmtCov(
    .user_clk               (),
    .user_rst_n             (),

    .iv_command             (),
    .i_command_wr           (),
    .ov_command_ack         (),
    .o_command_ack_wr       (),

    .o_m_lb_cs_n            (),
    .i_m_lb_ack_n           (),
    .o_m_lb_wr_rd           (),
    .ov_m_lb_addr           (),
    .ov_m_lb_wdata          (),
    .iv_m_lb_rdata          ()
    );
*/

