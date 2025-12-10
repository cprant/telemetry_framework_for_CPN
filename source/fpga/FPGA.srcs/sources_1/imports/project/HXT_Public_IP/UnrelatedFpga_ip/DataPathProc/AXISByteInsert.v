////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISByteInsert.v
Target Device All
Dscription 
    1)	在AXIStream传输中插入字节
Data_Struct: 
    1)
Caution:
    1)插入字节数不可大于每拍传输的字节数量
    2)例如每拍传输字节数为16，则提取字节数只能为1-15
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module AXISByteInsert#(
    parameter   INSERT_LEN  = 15,
                INSERT_SITE = 32,
                DATA_BYTE   = 16,
                USER_BIT    = 1
)(
//时钟复位信号
    input  wire                    axis_clk,
    input  wire                    axis_rst_n,
//插入数据
    output wire                    s_insert_tready,
    input  wire                    s_insert_tvalid,
    input  wire [INSERT_LEN*8-1:0] s_insert_tdata ,
//报文分组数据接收接口
    output wire                    s_axis_tready,
    input  wire                    s_axis_tvalid,
    input  wire [   DATA_BYTE-1:0] s_axis_tkeep ,
    input  wire [ DATA_BYTE*8-1:0] s_axis_tdata ,
    input  wire                    s_axis_tlast ,
    input  wire [    USER_BIT-1:0] s_axis_tuser ,  
//分组数据输出接口
    input  wire                    m_axis_tready,
    output wire                    m_axis_tvalid,
    output wire [   DATA_BYTE-1:0] m_axis_tkeep ,
    output wire [ DATA_BYTE*8-1:0] m_axis_tdata ,
    output wire                    m_axis_tlast ,
    output wire [    USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam  INS_LINE   = INSERT_SITE/DATA_BYTE,
            INS_BYTE   = INSERT_SITE%DATA_BYTE,
            CROSS_BYTE = ((INS_BYTE + INSERT_LEN) > DATA_BYTE) ? 
                         (INS_BYTE + INSERT_LEN - DATA_BYTE) : 
                         (DATA_BYTE - INS_BYTE - INSERT_LEN);

reg                      intrx_axis_tready;
wire                     intrx_axis_tvalid;
wire [    DATA_BYTE-1:0] intrx_axis_tkeep ;
wire [  DATA_BYTE*8-1:0] intrx_axis_tdata ;
wire                     intrx_axis_tlast ;
wire [     USER_BIT-1:0] intrx_axis_tuser ;  

wire                     inttx_axis_tready;
reg                      inttx_axis_tvalid;
reg  [    DATA_BYTE-1:0] inttx_axis_tkeep ;
reg  [  DATA_BYTE*8-1:0] inttx_axis_tdata ;
reg                      inttx_axis_tlast ;
reg  [     USER_BIT-1:0] inttx_axis_tuser ;  

reg                      int_insert_tready;
wire                     int_insert_tvalid;
wire [ INSERT_LEN*8-1:0] int_insert_tdata ;
    
wire          intrx_axis_sop;
wire [  15:0] intrx_axis_line_id;
wire          intrx_axis_eop;

reg                    tlast_reg;
reg [    USER_BIT-1:0] tuser_reg;
reg [ DATA_BYTE*8-1:0] cur_prev_dreg,nxt_prev_dreg;
reg [   DATA_BYTE-1:0] cur_prev_vreg,nxt_prev_vreg;

reg [1:0] cur_ins_state,nxt_ins_state;

localparam  START_S    = 4'd0,
            INTER_S    = 4'd1,
            INSERT_S   = 4'd2,
            NEW_TAIL_S = 4'd3;
            
/*-----------------------------------------------------------------------
                     插入数据处理
-----------------------------------------------------------------------*/

always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        tlast_reg <= 1'b0;
        tuser_reg <= {USER_BIT{1'b0}};
        
        cur_prev_vreg <= {(DATA_BYTE){1'b0}};
        cur_prev_dreg <= {(DATA_BYTE){8'b0}};
        
        cur_ins_state <= START_S;
    end
    else begin
        tlast_reg <= ((intrx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1)) ? intrx_axis_tlast : tlast_reg;
        tuser_reg <= ((intrx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1)) ? intrx_axis_tuser : tuser_reg;
        
        cur_prev_vreg <= nxt_prev_vreg;
        cur_prev_dreg <= nxt_prev_dreg;
        
        cur_ins_state <= nxt_ins_state;
    end
end

always @(*) begin
    case(cur_ins_state)
        START_S: begin
            inttx_axis_tuser = intrx_axis_tuser ; 
            nxt_prev_vreg  = intrx_axis_tkeep;
            nxt_prev_dreg  = intrx_axis_tdata;
            if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1) && (intrx_axis_line_id >= INS_LINE)) begin
                if(int_insert_tvalid == 1'b1) begin
                    intrx_axis_tready = 1'b1;
                    inttx_axis_tvalid = 1'b1; 
                    if((INS_BYTE + INSERT_LEN) > DATA_BYTE) begin//需要跨行处理
                        int_insert_tready = 1'b0;
                        inttx_axis_tkeep  = {intrx_axis_tkeep[DATA_BYTE-1 -: INS_BYTE],
                                           {(DATA_BYTE-INS_BYTE){1'b1}}}; 
                        inttx_axis_tdata  = {intrx_axis_tdata[DATA_BYTE*8-1 -: INS_BYTE*8],
                                           int_insert_tdata[INSERT_LEN*8-1 -: (DATA_BYTE-INS_BYTE)*8]}; 
                        inttx_axis_tlast  = 1'b0 ;
                        nxt_ins_state   = INTER_S;//跨行处理状态
                    end
                    else begin//本行即可正常插入
                        int_insert_tready = 1'b1;
                        if(INS_BYTE == 0) begin
                            inttx_axis_tkeep  = {{INSERT_LEN{1'b1}},
                                               intrx_axis_tkeep[DATA_BYTE-1 -: (DATA_BYTE-INSERT_LEN)]}; 
                            inttx_axis_tdata  = {int_insert_tdata,
                                               intrx_axis_tdata[DATA_BYTE*8-1 -: (DATA_BYTE-INSERT_LEN)*8]}; 
                        end
                        else if((INS_BYTE + INSERT_LEN) == DATA_BYTE) begin
                            inttx_axis_tkeep  = {intrx_axis_tkeep[DATA_BYTE-1 -: INS_BYTE],
                                               {INSERT_LEN{1'b1}}}; 
                            inttx_axis_tdata  = {intrx_axis_tdata[DATA_BYTE*8-1 -: INS_BYTE*8],
                                               int_insert_tdata}; 
                        end
                        else begin
                            inttx_axis_tkeep  = {intrx_axis_tkeep[DATA_BYTE-1 -: INS_BYTE],
                                               {INSERT_LEN{1'b1}},
                                               intrx_axis_tkeep[(DATA_BYTE-INS_BYTE)-1 -: CROSS_BYTE]}; 
                            inttx_axis_tdata  = {intrx_axis_tdata[DATA_BYTE*8-1 -: INS_BYTE*8],
                                               int_insert_tdata,
                                               intrx_axis_tdata[(DATA_BYTE-INS_BYTE)*8-1 -: CROSS_BYTE*8]}; 
                        end
                        
                        if(intrx_axis_tlast == 1'b1) begin//发到报文尾
                            if((|(intrx_axis_tkeep[0 +: INSERT_LEN])) == 1'b0) begin//无需生成新的尾部
                                inttx_axis_tlast  = 1'b1 ; 
                                nxt_ins_state   = START_S;
                            end
                            else begin//生成新的尾巴
                                inttx_axis_tlast  = 1'b0 ;       
                                nxt_ins_state   = NEW_TAIL_S;
                            end
                        end
                        else begin
                            inttx_axis_tlast  = 1'b0 ;       
                            nxt_ins_state   = INSERT_S;
                        end
                    end
                end
                else begin
                    intrx_axis_tready = 1'b0;
                    int_insert_tready = 1'b0;
                    inttx_axis_tvalid = 1'b0; 
                    inttx_axis_tkeep  = intrx_axis_tkeep ;       
                    inttx_axis_tdata  = intrx_axis_tdata ;  
                    inttx_axis_tlast  = intrx_axis_tlast ; 
                    
                    nxt_ins_state = START_S;
                end
            end
            else begin
                //对于报文都传完了都还没到指定位置的错误情况下，丢弃输入的插入数据
                int_insert_tready = ((inttx_axis_tready == 1'b1) & 
                                     (intrx_axis_tvalid == 1'b1) & 
                                     (intrx_axis_tlast  == 1'b1));
                
                intrx_axis_tready = inttx_axis_tready;
                
                inttx_axis_tvalid = intrx_axis_tvalid;       
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                
                nxt_ins_state = START_S;
            end
        end
        
        INTER_S: begin
            if((inttx_axis_tready == 1'b1) && (tlast_reg == 1'b1))begin//上一拍已经是尾巴，当拍进行收尾
                int_insert_tready = 1'b1;
                intrx_axis_tready = 1'b0;
                
                nxt_prev_vreg = cur_prev_vreg;
                nxt_prev_dreg = cur_prev_dreg;
                
                inttx_axis_tvalid = 1'b1; 
                inttx_axis_tkeep    = {cur_prev_vreg[(DATA_BYTE-INS_BYTE)-1 : 0],
                                     {INS_BYTE{1'b0}}}; 
                inttx_axis_tdata    = {cur_prev_dreg[(DATA_BYTE-INS_BYTE)*8-1 : 0],
                                     {INS_BYTE{8'b0}}}; 
                inttx_axis_tlast  = 1'b1 ;                      
                inttx_axis_tuser  = tuser_reg ;   
                nxt_ins_state   = START_S;        
            end
            else if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1) && (tlast_reg == 1'b0)) begin
                int_insert_tready = 1'b1;
                intrx_axis_tready = 1'b1;
                nxt_prev_vreg = intrx_axis_tkeep;
                nxt_prev_dreg = intrx_axis_tdata;
                inttx_axis_tvalid = 1'b1; 
                inttx_axis_tkeep    = {{CROSS_BYTE{1'b1}},
                                     cur_prev_vreg[(DATA_BYTE-INS_BYTE)-1 : 0],
                                     intrx_axis_tkeep[DATA_BYTE-1 -: (DATA_BYTE-INSERT_LEN)]}; 
                inttx_axis_tdata    = {int_insert_tdata[0 +: CROSS_BYTE*8],
                                     cur_prev_dreg[(DATA_BYTE-INS_BYTE)*8-1 : 0],
                                     intrx_axis_tdata[DATA_BYTE*8-1 -: (DATA_BYTE-INSERT_LEN)*8]}; 
                if(intrx_axis_tlast == 1'b1) begin//发到报文尾
                    if((|(intrx_axis_tkeep[0 +: INSERT_LEN])) == 1'b0) begin//无需生成新的尾部
                        inttx_axis_tlast  = intrx_axis_tlast ; 
                        nxt_ins_state   = START_S;
                    end
                    else begin//生成新的尾巴
                        inttx_axis_tlast  = 1'b0 ;       
                        nxt_ins_state   = NEW_TAIL_S;
                    end
                end
                else begin
                    inttx_axis_tlast  = 1'b0 ;       
                    nxt_ins_state   = INSERT_S;
                end  
                inttx_axis_tuser  = intrx_axis_tuser ;         
            end
            else begin
                int_insert_tready = 1'b0;
                intrx_axis_tready     = inttx_axis_tready;
                
                nxt_prev_vreg = cur_prev_vreg;
                nxt_prev_dreg = cur_prev_dreg;
                
                inttx_axis_tvalid = 1'b0; 
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                inttx_axis_tuser  = intrx_axis_tuser ; 
                nxt_ins_state = INTER_S;
            end
        end
        
        INSERT_S: begin
            int_insert_tready = 1'b0;
            intrx_axis_tready = inttx_axis_tready;
                
            inttx_axis_tvalid = intrx_axis_tvalid;  
            inttx_axis_tuser  = intrx_axis_tuser ; 
            if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1)) begin
                nxt_prev_vreg = intrx_axis_tkeep;
                nxt_prev_dreg = intrx_axis_tdata;
                
                inttx_axis_tkeep  = {cur_prev_vreg[INSERT_LEN-1 : 0],
                                   intrx_axis_tkeep[DATA_BYTE-1 -: (DATA_BYTE-INSERT_LEN)]}; 
                inttx_axis_tdata  = {cur_prev_dreg[INSERT_LEN*8-1 : 0],
                                   intrx_axis_tdata[DATA_BYTE*8-1 -: (DATA_BYTE-INSERT_LEN)*8]}; 
                if(intrx_axis_tlast == 1'b1) begin//发到报文尾
                    if((|(intrx_axis_tkeep[0 +: INSERT_LEN])) == 1'b0) begin//无需生成新的尾部
                        inttx_axis_tlast  = intrx_axis_tlast ; 
                        nxt_ins_state   = START_S;
                    end
                    else begin//生成新的尾巴
                        inttx_axis_tlast  = 1'b0 ;       
                        nxt_ins_state   = NEW_TAIL_S;
                    end
                end
                else begin
                    inttx_axis_tlast  = 1'b0 ;       
                    nxt_ins_state   = INSERT_S;
                end
            end
            else begin
                nxt_prev_vreg = cur_prev_vreg;
                nxt_prev_dreg = cur_prev_dreg;
                
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                
                nxt_ins_state = INSERT_S;
            end
        end
        
        NEW_TAIL_S: begin
            nxt_prev_vreg = cur_prev_vreg;
            nxt_prev_dreg = cur_prev_dreg;
            
            int_insert_tready = 1'b0;
            
            intrx_axis_tready = 1'b0;
                
            inttx_axis_tvalid = 1'b1;  
            inttx_axis_tkeep  = {cur_prev_vreg[INSERT_LEN-1 : 0],
                               {(DATA_BYTE-INSERT_LEN){1'b0}}}; 
            inttx_axis_tdata  = {cur_prev_dreg[INSERT_LEN*8-1 : 0],
                               {(DATA_BYTE-INSERT_LEN){8'b0}}};   
            inttx_axis_tlast  = 1'b1 ;  
            inttx_axis_tuser  = tuser_reg ; 
            if(inttx_axis_tready == 1'b1) begin
                nxt_ins_state = START_S;
            end
            else begin
                nxt_ins_state = NEW_TAIL_S;
            end
        end
        
        default: begin
            nxt_prev_vreg = {(DATA_BYTE){1'b0}};
            nxt_prev_dreg = {(DATA_BYTE){8'b0}};
            
            int_insert_tready = 1'b0;
            
            intrx_axis_tready = 1'b0;
                
            inttx_axis_tvalid = 1'b1;  
            inttx_axis_tkeep  = {(DATA_BYTE){1'b0}}; 
            inttx_axis_tdata  = {(DATA_BYTE){8'b0}};   
            inttx_axis_tlast  = 1'b0 ;  
            inttx_axis_tuser  = {(USER_BIT){1'b0}}; 
            
            nxt_ins_state = START_S;
        end
    endcase
end

/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
PktLineDet #(16) PreaxisLineDet_Inst(
    .user_clk               ( axis_clk          ),
    .user_rst_n             ( axis_rst_n        ),
                            
    .valid                  ( intrx_axis_tready & intrx_axis_tvalid),
    .last                   ( intrx_axis_tlast      ),
                              
    .sop                    ( intrx_axis_sop        ),
    .line_id                ( intrx_axis_line_id    ),
    .eop                    ( intrx_axis_eop        )
);
AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (INSERT_LEN),
    .USER_BIT  (1)
)InsertRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),
//AXI Stream输入接口
    .s_axis_tready(s_insert_tready),
    .s_axis_tvalid(s_insert_tvalid),
    .s_axis_tkeep ({INSERT_LEN{1'b1}}),
    .s_axis_tdata (s_insert_tdata),
    .s_axis_tlast (1'b1),
    .s_axis_tuser (1'b0),    
//AXI Stream输出接口
    .m_axis_tready(int_insert_tready),
    .m_axis_tvalid(int_insert_tvalid),
    .m_axis_tkeep (),
    .m_axis_tdata (int_insert_tdata),
    .m_axis_tlast (),
    .m_axis_tuser ()
);

AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (DATA_BYTE),
    .USER_BIT  (USER_BIT)
)RxDataRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(s_axis_tready),    
    .s_axis_tvalid(s_axis_tvalid),    
    .s_axis_tkeep (s_axis_tkeep ),
    .s_axis_tdata (s_axis_tdata ),
    .s_axis_tlast (s_axis_tlast ),
    .s_axis_tuser (s_axis_tuser ),    
//报文分组输出接口信号
    .m_axis_tready(intrx_axis_tready),
    .m_axis_tvalid(intrx_axis_tvalid),
    .m_axis_tkeep (intrx_axis_tkeep ),
    .m_axis_tdata (intrx_axis_tdata ),
    .m_axis_tlast (intrx_axis_tlast ),
    .m_axis_tuser (intrx_axis_tuser )
);

AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (DATA_BYTE),
    .USER_BIT  (USER_BIT)
)TxDataRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(inttx_axis_tready),    
    .s_axis_tvalid(inttx_axis_tvalid),    
    .s_axis_tkeep (inttx_axis_tkeep ),
    .s_axis_tdata (inttx_axis_tdata ),
    .s_axis_tlast (inttx_axis_tlast ),
    .s_axis_tuser (inttx_axis_tuser ),    
//报文分组输出接口信号
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tkeep (m_axis_tkeep ),
    .m_axis_tdata (m_axis_tdata ),
    .m_axis_tlast (m_axis_tlast ),
    .m_axis_tuser (m_axis_tuser )
);
endmodule
/*
AXISByteInsert#(
    .INSERT_LEN (),
    .INSERT_SITE(),
    .PROMODE_EN (),
    .DATA_BYTE  (),
    .USER_BIT   ()
)AXISByteInsert_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//插入数据
    .s_insert_tready(),
    .s_insert_tvalid(),
    .s_insert_tdata (),
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