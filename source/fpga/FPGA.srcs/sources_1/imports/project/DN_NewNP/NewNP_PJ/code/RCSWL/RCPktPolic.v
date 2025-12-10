/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  RCPktPolic.v
Target Device All
Dscription 
    1)维护RRC转发表
    2)根据接收的RC分组描述符查找转发表，并将查表结果(包括分组输出端口号以及分组优先级)输出

Data_Struct:
    1)des_tdata    
        [ 30: 26]   分组输入端口号     1  
        [ 25: 14]   分组长度           12  
        [ 13:  0]   STREAM_ID          14  

        
Caution: 
    1)
Author : wjj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module RCPktPolic #(
    parameter   RAMADDR_WID  = 14,
                TABLE_WID    = 33
)(
    //时钟复位信号
    input  wire                     axis_clk  ,
    input  wire                     axis_rst_n,
    //查表通道
(*mark_debug="true"*)    input  wire [             30:0] iv_des_tdata,
(*mark_debug="true"*)    input  wire                     i_des_tvalid,
(*mark_debug="true"*)    output reg  [              1:0] o_pkt_discard,
(*mark_debug="true"*)    output reg  [             31:0] o_pkt_outputbit,
    //配置管理接口
(*mark_debug="true"*)    input  wire                     s_lb_cs_n,
(*mark_debug="true"*)    output wire                     s_lb_ack_n,
(*mark_debug="true"*)    input  wire                     s_lb_wr_rd,//0:wr  1:rd
(*mark_debug="true"*)    input  wire [             31:0] s_lb_addr,
(*mark_debug="true"*)    input  wire [             31:0] s_lb_wdata,
(*mark_debug="true"*)    output reg  [             31:0] s_lb_rdata
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
(*mark_debug="true"*)reg                      entrytable_wr;
(*mark_debug="true"*)reg  [  RAMADDR_WID-1:0] entrytable_waddr;
(*mark_debug="true"*)reg  [    TABLE_WID-1:0] entrytable_wdata;
(*mark_debug="true"*)reg                      entrytable_rd;
(*mark_debug="true"*)reg  [  RAMADDR_WID-1:0] entrytable_raddr;
(*mark_debug="true"*)wire [    TABLE_WID-1:0] entrytable_rdata;

(*mark_debug="true"*)wire                     sync_cs_n;
(*mark_debug="true"*)reg                      wack_n;
(*mark_debug="true"*)reg                      rack_n;
                         
(*mark_debug="true"*)reg  [           2:0]    wctrl_state;
(*mark_debug="true"*)reg  [           3:0]    rctrl_state;

localparam  W_INIT_S    = 3'd0,
            W_IDLE_S    = 3'd1,
            W_CFG_ASM_S = 3'd2,
            W_ACK_S     = 3'd3,
            W_UP_ASM_S  = 3'd4;

localparam  R_IDLE_S     = 4'd0,
            R_CFG_WAIT_S = 4'd1,
            R_CFG_SEL_S  = 4'd2,
            R_CFG_ACK_S  = 4'd3,
            R_LK_WAIT_S  = 4'd4,
            R_LK_RLS_S   = 4'd5;
            
            
(*mark_debug="true"*)reg                      Lookup_valid;
(*mark_debug="true"*)reg                      Lookup_valid_delay;
(*mark_debug="true"*)reg  [  RAMADDR_WID-1:0] Lookup_addr ;
(*mark_debug="true"*)reg  [    TABLE_WID-1:0] Lookup_data ;
(*mark_debug="true"*)reg                      update_valid;
(*mark_debug="true"*)reg  [    TABLE_WID-1:0] update_data ,nxt_update_data ;

(*mark_debug="true"*)reg  [             63:0] Local_Time;
(*mark_debug="true"*)reg  [             63:0] Time_X;
(*mark_debug="true"*)wire [             63:0] Time_int;
(*mark_debug="true"*)reg  [             63:0] Time_Y;
            
            
assign s_lb_ack_n = wack_n & rack_n;

assign Time_int   = (Lookup_data[TABLE_WID-3:TABLE_WID-12]<<7);

/*----------------------------------------------------------
                    单速测速算法
----------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        Lookup_valid_delay      <= 1'b0;
        Local_Time              <= 64'h0;
        
        update_data             <= {TABLE_WID{1'b0}};
    end
    else begin
        update_data             <= nxt_update_data;
    
        if(Lookup_valid == 1'b1)
            Lookup_valid_delay      <= 1'b1;
        else
            Lookup_valid_delay      <= 1'b0;
            
        Local_Time              <= Local_Time + 64'h1;
    end
    
end

always @(*) begin
    nxt_update_data     = {TABLE_WID{1'b0}};//20220817-保证后续逻辑就算没有涉及到部分bit位的赋值，也有默认赋值
    if(axis_rst_n == 1'b0) begin
        update_valid        = 1'b0;
        o_pkt_discard       = 2'b00;
        Time_X              = 64'h0;
        Time_Y              = 64'h0;
        nxt_update_data     = {TABLE_WID{1'b0}};
        
        o_pkt_outputbit     = 32'd0;
    end
    else begin
        if(Lookup_valid == 1'b1 && Lookup_valid_delay == 1'b0)begin
        
            o_pkt_outputbit             = Lookup_data[32*7-1:32*6];
        
            if(Lookup_data[TABLE_WID-1] == 1'b1)begin
                if(Local_Time >= Lookup_data[32*6-1:32*4])begin
                    Time_X                  = Local_Time - Lookup_data[32*6-1:32*4];
                    Time_Y                  = (Time_int> Time_X)? Time_X:Time_int;
                    
                    o_pkt_discard           = 2'b10;
                    update_valid            = 1'b1;
                    nxt_update_data[32*8-1:32*6]= Lookup_data[32*8-1:32*6];
                    nxt_update_data[32*6-1:32*4]= Local_Time + Lookup_data[TABLE_WID-13:TABLE_WID-32] - Time_Y;//更新NextRxTime
                    nxt_update_data[32*4-1:32*3]= Lookup_data[32*4-1:32*3]+32'h1;
                    nxt_update_data[32*3-1:32*0]= Lookup_data[32*3-1:32*0];
                end
                else begin
                    Time_X              = 64'h0;
                    Time_Y              = 64'h0;
                
                    o_pkt_discard           = 2'b11;
                    update_valid            = 1'b1;
                    nxt_update_data[32*8-1:32*3]= Lookup_data[32*8-1:32*3];
                    nxt_update_data[32*3-1:32*0]= {{Lookup_data[32*3-1:32*2]+32'h1},64'h0};
                end
            end
            else begin
                Time_X              = 64'h0;
                Time_Y              = 64'h0;
            
                o_pkt_discard           = 2'b11;
                update_valid            = 1'b1;
                nxt_update_data[32*8-1:32*3]= Lookup_data[32*8-1:32*3];
                nxt_update_data[32*3-1:32*0]= {{Lookup_data[32*3-1:32*2]+32'h1},64'h0};
            end
        end
        else begin
        
            o_pkt_outputbit     = 32'd0;
        
            Time_X              = 64'h0;
            Time_Y              = 64'h0;
        
            o_pkt_discard           = 2'b00;
            update_valid            = 1'b0;
            nxt_update_data         = update_data;
        end
    end

end

/*----------------------------------------------------------
                   表项写请求
----------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        wack_n              <= 1'b1;
            
        entrytable_wr       <= 1'b0;
        entrytable_waddr    <= {RAMADDR_WID{1'b0}};
        entrytable_wdata    <= {TABLE_WID{1'b0}};
            
        wctrl_state         <= W_INIT_S;
    end
    else begin
        case(wctrl_state)
            W_INIT_S: begin//复位后初始化,清空表项
                entrytable_wr       <= 1'b1;
                entrytable_waddr    <= entrytable_waddr + 1'b1;
                if((&entrytable_waddr) == 1'b1) begin
                    wctrl_state      <= W_IDLE_S;
                end
                else begin
                    wctrl_state      <= W_INIT_S;
                end
            end
            
            W_IDLE_S:begin//空闲状态
                wack_n           <= 1'b1;
                entrytable_wr    <= 1'b0;
                
                if((s_lb_ack_n == 1'b1) && (sync_cs_n  == 1'b0) && (s_lb_wr_rd == 1'b0))begin//写请求
                    wctrl_state     <= W_CFG_ASM_S;
                end
                else if(update_valid == 1'b1)begin
                    wctrl_state     <= W_UP_ASM_S;
                end
                else begin
                    wctrl_state      <= W_IDLE_S;
                end
                
            end
            
            W_CFG_ASM_S: begin

                if(s_lb_addr[2:0] == 3'd0)begin
                    entrytable_wr       <= 1'b0;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {s_lb_wdata,224'd0};
                end
                else if(s_lb_addr[2:0] == 3'd1)begin
                    entrytable_wr       <= 1'b0;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*7],s_lb_wdata,192'd0};
                end
                else if(s_lb_addr[2:0] == 3'd2)begin
                    entrytable_wr       <= 1'b0;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*6],s_lb_wdata,160'd0};
                end
                else if(s_lb_addr[2:0] == 3'd3)begin
                    entrytable_wr       <= 1'b0;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*5],s_lb_wdata,128'd0};
                end
                else if(s_lb_addr[2:0] == 3'd4)begin
                    entrytable_wr       <= 1'b0;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*4],s_lb_wdata,96'd0};
                end
                else if(s_lb_addr[2:0] == 3'd5)begin
                    entrytable_wr       <= 1'b1;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*3],s_lb_wdata,64'd0};
                end
                else if(s_lb_addr[2:0] == 3'd6)begin
                    entrytable_wr       <= 1'b1;
                    entrytable_waddr    <= s_lb_addr[3 +: RAMADDR_WID];
                    entrytable_wdata    <= {entrytable_wdata[32*8-1:32*2],s_lb_wdata,32'd0};
                end
                else begin
                    entrytable_wr       <= 1'b0;
                end
            
                wack_n          <= 1'b0;
                
                wctrl_state     <= W_ACK_S;
            end
            
            W_ACK_S: begin
                entrytable_wr   <= 1'b0;
                if((sync_cs_n  == 1'b0) && (s_lb_wr_rd == 1'b0))begin//Localbus未释放
                   wack_n           <= 1'b0;
                   wctrl_state      <= W_ACK_S;
                end
                else begin//已释放
                    wack_n          <= 1'b1;
                    wctrl_state     <= W_IDLE_S;
                end
            end
            
            W_UP_ASM_S:begin
                entrytable_wr   <= 1'b1;
                entrytable_waddr<= Lookup_addr;
                entrytable_wdata<= update_data;
                wctrl_state     <= W_IDLE_S;
            end
            
            default: begin
                wack_n              <= 1'b1;
                entrytable_wr       <= 1'b0;
                entrytable_waddr    <= {RAMADDR_WID{1'b0}};
                wctrl_state         <= W_IDLE_S;
            end
        endcase
    end
end

/*----------------------------------------------------------
                   表项读请求
----------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        rack_n          <= 1'b1;
        
        entrytable_rd   <= 1'b0;
        
        Lookup_addr     <= 14'h0;
        Lookup_valid    <= 1'b0;
        Lookup_data     <= {TABLE_WID{1'b0}};
        
        rctrl_state     <= R_IDLE_S;
    end
    else begin
        case(rctrl_state)
            R_IDLE_S: begin
                Lookup_valid    <= 1'b0;
                Lookup_data     <= Lookup_data;
                
                rack_n          <= 1'b1;
                if((i_des_tvalid == 1'b1) && (wctrl_state != W_INIT_S))begin//外部有表项读申请，并且此时表项完成初始化
                    entrytable_rd       <= 1'b1;
                    entrytable_raddr    <= iv_des_tdata[13:0];
                    Lookup_addr         <= iv_des_tdata[13:0];
                    
                    rctrl_state         <= R_LK_WAIT_S;
                end
                else if((s_lb_ack_n == 1'b1) && (sync_cs_n  == 1'b0) && (s_lb_wr_rd == 1'b1))begin//读请求
                    entrytable_rd       <= 1'b1;
                    entrytable_raddr    <= s_lb_addr[3 +: RAMADDR_WID];//获取RAM读地址
                    Lookup_addr         <= Lookup_addr;
                    
                    rctrl_state         <= R_CFG_WAIT_S;
                end
                else begin
                    entrytable_rd       <= 1'b0;
                    
                    rctrl_state         <= R_IDLE_S;
                end
            end
            
            R_CFG_WAIT_S: begin
                entrytable_rd       <= 1'b0;
                
                rctrl_state         <= R_CFG_SEL_S;
            end
            
            R_CFG_SEL_S: begin
                rack_n              <= 1'b0;
                
                rctrl_state    <= R_CFG_ACK_S;
                if(s_lb_addr[2:0] == 3'd0)begin
                    s_lb_rdata          <= entrytable_rdata[32*8-1:32*7];
                end
                else if(s_lb_addr[2:0] == 3'd1)begin
                    s_lb_rdata          <= entrytable_rdata[32*7-1:32*6];
                end
                else if(s_lb_addr[2:0] == 3'd2)begin
                    s_lb_rdata          <= entrytable_rdata[32*6-1:32*5];
                end
                else if(s_lb_addr[2:0] == 3'd3)begin
                    s_lb_rdata          <= entrytable_rdata[32*5-1:32*4];
                end
                else if(s_lb_addr[2:0] == 3'd4)begin
                    s_lb_rdata          <= entrytable_rdata[32*4-1:32*3];
                end
                else if(s_lb_addr[2:0] == 3'd5)begin
                    s_lb_rdata          <= entrytable_rdata[32*3-1:32*2];
                end
                else if(s_lb_addr[2:0] == 3'd6)begin
                    s_lb_rdata          <= entrytable_rdata[32*2-1:32*1];
                end
                else begin          
                    s_lb_rdata          <= 32'd0;
                end
            end

            R_CFG_ACK_S: begin
                if((sync_cs_n  == 1'b0) && (s_lb_wr_rd == 1'b1))begin//Localbus读请求未释放
                    rack_n          <= 1'b0;
                    
                    rctrl_state     <= R_CFG_ACK_S;
                end 
                else begin//已释放 
                    rack_n          <= 1'b1;
                    
                    rctrl_state     <= R_IDLE_S;
                end
            end
            
            R_LK_WAIT_S: begin//等待查表结果
                entrytable_rd   <= 1'b0;
                
                rctrl_state     <= R_LK_RLS_S;
            end
            
            R_LK_RLS_S: begin//等待查表请求释放
                Lookup_valid    <= 1'b1;
                Lookup_data     <= entrytable_rdata;
            
                if(i_des_tvalid == 1'b0)
                    rctrl_state    <= R_IDLE_S;
                else
                    rctrl_state    <= R_LK_RLS_S;
            end
            
            default: begin
                rack_n          <= 1'b1;
                entrytable_rd   <= 1'b0;
                
                Lookup_addr     <= 14'h0;
                Lookup_valid    <= 1'b0;
                Lookup_data     <= {TABLE_WID{1'b0}};
                
                rctrl_state     <= R_IDLE_S;
            end
        endcase
    end
end

/*---------------------------------------------------------
                   IP调用区域
---------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 

SyncSig #(
    .SYNC_REGS      ( 2                 ),
    .POLAR          ( 1'b1              ),
    .STRICT         ( 0                 )
)cs_syncsig_inst(   
    .clk            ( axis_clk          ),
    .rst_n          ( axis_rst_n        ),
    .in_sig         ( s_lb_cs_n         ),
    .out_sig        ( sync_cs_n         )
);  
    
ParamSdpram # ( 
    .DATA_WIDTH     ( TABLE_WID         ),
    .ADDR_WIDTH     ( RAMADDR_WID       )
)entrytable_inst(   
    .wrclk          ( axis_clk          ),  
    .rdclk          ( axis_clk          ),  
    .aclr           ( ~axis_rst_n       ),
                      
    .wren           ( entrytable_wr     ),     
    .waddr          ( entrytable_waddr  ),  
    .wdata          ( entrytable_wdata  ), 
                             
    .rden           ( entrytable_rd     ),      
    .raddr          ( entrytable_raddr  ),    
    .rdata          ( entrytable_rdata  )
);
endmodule

/*
RCPktPolic #(
    .RAMADDR_WID            (),
    .TABLE_WID              ()
)RCPktPolic_inst(
    .axis_clk               (),
    .axis_rst_n             (),

    .iv_des_tdata           (),
    .i_des_tvalid           (),
    .o_pkt_discard          (),

    .s_lb_cs_n              (),
    .s_lb_ack_n             (),
    .s_lb_wr_rd             (),
    .s_lb_addr              (),
    .s_lb_wdata             (),
    .s_lb_rdata             ()
);
*/
