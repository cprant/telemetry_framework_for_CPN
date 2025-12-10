////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor C2Comm
Version 1.0
Filename  AXISByteExtract.v
Target Device All
Dscription 
    1)	在AXIStream传输中提取字节
Data_Struct: 
    1)
Caution:
    1)提取字节数不可大于每拍传输的字节数量
    2)例如每拍传输字节数为16，则提取字节数只能为1-15
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module AXISByteExtract#(
    parameter   EXTRACT_LEN  = 15,
                EXTRACT_SITE = 32,
                DATA_BYTE   = 16,
                USER_BIT    = 1
)(
//时钟复位信号
    input  wire                     axis_clk,
    input  wire                     axis_rst_n,
//提取数据
    input  wire                     m_extract_tready,
    output reg                      m_extract_tvalid,
    output reg  [EXTRACT_LEN*8-1:0] m_extract_tdata ,
//报文分组数据接收接口
    output wire                     s_axis_tready,
    input  wire                     s_axis_tvalid,
    input  wire [    DATA_BYTE-1:0] s_axis_tkeep ,
    input  wire [  DATA_BYTE*8-1:0] s_axis_tdata ,
    input  wire                     s_axis_tlast ,
    input  wire [     USER_BIT-1:0] s_axis_tuser ,  
//分组数据输出接口
    input  wire                     m_axis_tready,
    output wire                     m_axis_tvalid,
    output wire [    DATA_BYTE-1:0] m_axis_tkeep ,
    output wire [  DATA_BYTE*8-1:0] m_axis_tdata ,
    output wire                     m_axis_tlast ,
    output wire [     USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明
localparam  EXC_LINE   = EXTRACT_SITE/DATA_BYTE,
            EXC_BYTE   = EXTRACT_SITE%DATA_BYTE,
            CROSS_BYTE = ((EXC_BYTE + EXTRACT_LEN) > DATA_BYTE) ?
                          (EXC_BYTE + EXTRACT_LEN - DATA_BYTE) :
                          (DATA_BYTE - EXTRACT_LEN - EXC_BYTE);

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

wire                     cache_axis_tready;
wire                     cache_axis_tvalid;
wire [    DATA_BYTE-1:0] cache_axis_tkeep ;
wire [  DATA_BYTE*8-1:0] cache_axis_tdata ;
wire                     cache_axis_tlast ;
wire [     USER_BIT-1:0] cache_axis_tuser ;  

reg                      pre_axis_tready;
wire                     pre_axis_tvalid;
wire [    DATA_BYTE-1:0] pre_axis_tkeep ;
wire [  DATA_BYTE*8-1:0] pre_axis_tdata ;
wire                     pre_axis_tlast ;
wire [     USER_BIT-1:0] pre_axis_tuser ;  

wire                     post_axis_tready;
reg                      post_axis_tvalid;
reg  [    DATA_BYTE-1:0] post_axis_tkeep ;
reg  [  DATA_BYTE*8-1:0] post_axis_tdata ;
reg                      post_axis_tlast ;
reg  [     USER_BIT-1:0] post_axis_tuser ;   

reg                      tlast_reg;
reg  [     USER_BIT-1:0] tuser_reg;

wire                     intrx_axis_sop;
wire [             15:0] intrx_axis_line_id;
wire                     intrx_axis_eop;

reg  [DATA_BYTE*8-1:0] cur_extract_dreg,nxt_extract_dreg;
reg  [  DATA_BYTE-1:0] cur_extract_vreg,nxt_extract_vreg;

reg [1:0] cur_exc_state,nxt_exc_state;

localparam  START_S    = 2'd0,
            EXTRACT_S  = 2'd1,
            INSERT_S   = 2'd2,
            NEW_TAIL_S = 2'd3;
            
/*-----------------------------------------------------------------------
                     移除数据前处理
-----------------------------------------------------------------------*/
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        tlast_reg        <= 1'b0;
        tuser_reg        <= {USER_BIT{1'b0}};
        cur_extract_vreg <= {(DATA_BYTE){1'b0}};
        cur_extract_dreg <= {(DATA_BYTE){8'b0}};
        
        cur_exc_state <= START_S;
    end
    else begin
        tlast_reg        <= intrx_axis_tlast;
        tuser_reg        <= intrx_axis_tuser;
        cur_extract_vreg <= nxt_extract_vreg;
        cur_extract_dreg <= nxt_extract_dreg;
        
        cur_exc_state <= nxt_exc_state;
    end
end

always @(*) begin
    inttx_axis_tuser  = intrx_axis_tuser ; 
    case(cur_exc_state)
        START_S: begin
            if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1) &&(intrx_axis_line_id >= EXC_LINE)) begin
                intrx_axis_tready = 1'b1;
                nxt_extract_vreg = intrx_axis_tkeep;
                nxt_extract_dreg = intrx_axis_tdata;
                
                if(intrx_axis_tlast == 1'b1) begin//已经是尾巴
                //!!!注意，该情况下有可能出现尾巴被全部取光的情况
                    m_extract_tvalid = 1'b1;
                    m_extract_tdata  = intrx_axis_tdata[(DATA_BYTE-EXC_BYTE)*8-1 -: EXTRACT_LEN*8];

                    inttx_axis_tvalid = 1'b1;
                    
                    if(EXC_BYTE == 0) begin
                        //拼接数据全部在高位，方便处理
                        inttx_axis_tkeep  = {intrx_axis_tkeep[0 +: (DATA_BYTE-EXTRACT_LEN)],
                                           {EXTRACT_LEN{1'b0}}}; 
                        inttx_axis_tdata  = {intrx_axis_tdata[0 +: (DATA_BYTE-EXTRACT_LEN)*8],
                                           {EXTRACT_LEN{8'b0}}}; 
                    end
                    else if((EXC_BYTE + EXTRACT_LEN) == DATA_BYTE) begin//刚好取满
                        inttx_axis_tkeep  = {intrx_axis_tkeep[DATA_BYTE-1 -: EXC_BYTE],
                                           {EXTRACT_LEN{1'b0}}}; 
                        inttx_axis_tdata  = {intrx_axis_tdata[DATA_BYTE*8-1 -: EXC_BYTE*8],
                                           {EXTRACT_LEN{8'b0}}}; 
                    end
                    else begin
                        //将截成两半部分的tkeep和tdata拼接     
                        inttx_axis_tkeep  = {intrx_axis_tkeep[DATA_BYTE-1 -: EXC_BYTE],
                                           intrx_axis_tkeep[0 +: CROSS_BYTE],
                                           {EXTRACT_LEN{1'b0}}}; 
                        inttx_axis_tdata  = {intrx_axis_tdata[DATA_BYTE*8-1 -: EXC_BYTE*8],
                                           intrx_axis_tdata[0 +: CROSS_BYTE*8],
                                           {EXTRACT_LEN{8'b0}}}; 
                    end
                    inttx_axis_tlast  = 1'b1 ;   
                    nxt_exc_state   = START_S; 
                end
                else begin
                    m_extract_tvalid = 1'b0;
                    m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
                    
                    inttx_axis_tvalid = 1'b0; //不发送
                    inttx_axis_tkeep  = {DATA_BYTE{1'b0}}; 
                    inttx_axis_tdata  = {DATA_BYTE{8'b0}}; 
                    inttx_axis_tlast  = 1'b0 ;
                    
                    nxt_exc_state   = EXTRACT_S;
                end 
            end
            else begin
                intrx_axis_tready = inttx_axis_tready;
                
                nxt_extract_vreg = cur_extract_vreg;
                nxt_extract_dreg = cur_extract_dreg;
                
                m_extract_tvalid = 1'b0;
                m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
                
                inttx_axis_tvalid = intrx_axis_tvalid;       
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                
                nxt_exc_state = START_S;
            end
        end
        
        EXTRACT_S: begin
            if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1) && (m_extract_tready == 1'b1))begin
                intrx_axis_tready = 1'b1;
                nxt_extract_vreg = {intrx_axis_tkeep[0 +: (DATA_BYTE-EXTRACT_LEN)],{EXTRACT_LEN{1'b0}}};
                nxt_extract_dreg = {intrx_axis_tdata[0 +: (DATA_BYTE-EXTRACT_LEN)*8],{EXTRACT_LEN{8'b0}}};
                m_extract_tvalid = 1'b1;
                inttx_axis_tvalid  = 1'b1; 
                if((EXC_BYTE + EXTRACT_LEN) > DATA_BYTE) begin//需要跨行处理
                //需要跨行处理的必定是EXC_BYTE!=0,且只有前半部分的EXC_BYTE,且在高位
                    m_extract_tdata  = {cur_extract_dreg[(DATA_BYTE-EXC_BYTE)*8-1 : 0],
                                        intrx_axis_tdata[DATA_BYTE*8-1 -: CROSS_BYTE*8]};

                    inttx_axis_tkeep  = {cur_extract_vreg[DATA_BYTE-1 -: EXC_BYTE],
                                       intrx_axis_tkeep[(DATA_BYTE*2-EXTRACT_LEN-EXC_BYTE)-1 -: (DATA_BYTE-EXC_BYTE)]}; 
                    inttx_axis_tdata  = {cur_extract_dreg[DATA_BYTE*8-1 -: EXC_BYTE*8],
                                       intrx_axis_tdata[(DATA_BYTE*2-EXTRACT_LEN-EXC_BYTE)*8-1 -: (DATA_BYTE-EXC_BYTE)*8]}; 
                end
                else begin//本行即可正常提取
                    m_extract_tdata  = cur_extract_dreg[(DATA_BYTE-EXC_BYTE)*8-1 -: EXTRACT_LEN*8];
                    if(EXC_BYTE == 0) begin
                        //拼接数据全部在高位，方便处理
                        inttx_axis_tkeep  = {cur_extract_vreg[0 +: (DATA_BYTE-EXTRACT_LEN)],
                                           intrx_axis_tkeep[DATA_BYTE-1 -: EXTRACT_LEN]}; 
                        inttx_axis_tdata  = {cur_extract_dreg[0 +: (DATA_BYTE-EXTRACT_LEN)*8],
                                           intrx_axis_tdata[DATA_BYTE*8-1 -: EXTRACT_LEN*8]}; 
                    end
                    else if((EXC_BYTE + EXTRACT_LEN) == DATA_BYTE) begin
                        inttx_axis_tkeep  = {cur_extract_vreg[DATA_BYTE-1 -: EXC_BYTE],
                                           intrx_axis_tkeep[DATA_BYTE-1 -: (DATA_BYTE-EXC_BYTE)]}; 
                        inttx_axis_tdata  = {cur_extract_dreg[DATA_BYTE*8-1 -: EXC_BYTE*8],
                                           intrx_axis_tdata[DATA_BYTE*8-1 -:  (DATA_BYTE-EXC_BYTE)*8]}; 
                    end
                    else begin
                        //将截成两半部分的tkeep和tdata拼接     
                        inttx_axis_tkeep  = {cur_extract_vreg[DATA_BYTE-1 -: EXC_BYTE],
                                           cur_extract_vreg[0 +: CROSS_BYTE],
                                           intrx_axis_tkeep[DATA_BYTE-1 -: EXTRACT_LEN]}; 
                        inttx_axis_tdata  = {cur_extract_dreg[DATA_BYTE*8-1 -: EXC_BYTE*8],
                                           cur_extract_dreg[0 +: CROSS_BYTE*8],
                                           intrx_axis_tdata[DATA_BYTE*8-1 -: EXTRACT_LEN*8]}; 
                    end
                end
                
                if(intrx_axis_tlast == 1'b1) begin//已经是尾巴
                    if((|intrx_axis_tkeep[0 +: (DATA_BYTE-EXTRACT_LEN)]) == 1'b0) begin//无需生成新的尾部
                        inttx_axis_tlast  = 1'b1 ;   
                        nxt_exc_state   = START_S; 
                    end
                    else begin//生成新的尾巴
                        inttx_axis_tlast  = 1'b0 ;   
                        nxt_exc_state   = NEW_TAIL_S; 
                    end
                end
                else begin
                    inttx_axis_tlast  = 1'b0 ;       
                    nxt_exc_state   = INSERT_S;
                end 
            end
            else begin
                intrx_axis_tready     = 1'b0;
                
                nxt_extract_vreg = cur_extract_vreg;
                nxt_extract_dreg = cur_extract_dreg;
                
                m_extract_tvalid = 1'b0;
                m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
                
                inttx_axis_tvalid = 1'b0; 
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                nxt_exc_state = EXTRACT_S;
            end
        end
        
        INSERT_S: begin
            m_extract_tvalid = 1'b0;
            m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
            
            intrx_axis_tready = inttx_axis_tready;
                
            inttx_axis_tvalid = intrx_axis_tvalid;  
            if((inttx_axis_tready == 1'b1) && (intrx_axis_tvalid == 1'b1)) begin
                nxt_extract_vreg = {intrx_axis_tkeep[0 +: (DATA_BYTE-EXTRACT_LEN)],{EXTRACT_LEN{1'b0}}};
                nxt_extract_dreg = {intrx_axis_tdata[0 +: (DATA_BYTE-EXTRACT_LEN)*8],{EXTRACT_LEN{8'b0}}};
                
                inttx_axis_tkeep  = {cur_extract_vreg[DATA_BYTE-1 -: (DATA_BYTE-EXTRACT_LEN)],
                                   intrx_axis_tkeep[DATA_BYTE-1 -: EXTRACT_LEN]}; 
                inttx_axis_tdata  = {cur_extract_dreg[DATA_BYTE*8-1 -: (DATA_BYTE-EXTRACT_LEN)*8],
                                   intrx_axis_tdata[DATA_BYTE*8-1 -: EXTRACT_LEN*8]}; 
                if(intrx_axis_tlast == 1'b1) begin//发到报文尾
                    if((|(intrx_axis_tkeep[0 +: (DATA_BYTE-EXTRACT_LEN)])) == 1'b0) begin//无需生成新的尾部
                        inttx_axis_tlast  = 1'b1 ; 
                        nxt_exc_state   = START_S;
                    end
                    else begin//生成新的尾巴
                        inttx_axis_tlast  = 1'b0 ;       
                        nxt_exc_state   = NEW_TAIL_S;
                    end
                end
                else begin
                    inttx_axis_tlast  = 1'b0 ;       
                    nxt_exc_state   = INSERT_S;
                end
            end
            else begin
                nxt_extract_vreg = cur_extract_vreg;
                nxt_extract_dreg = cur_extract_dreg;
                
                inttx_axis_tkeep  = intrx_axis_tkeep ;       
                inttx_axis_tdata  = intrx_axis_tdata ;       
                inttx_axis_tlast  = intrx_axis_tlast ;  
                
                nxt_exc_state = INSERT_S;
            end
        end
        
        NEW_TAIL_S: begin
            nxt_extract_vreg = cur_extract_vreg;
            nxt_extract_dreg = cur_extract_dreg;
            
            m_extract_tvalid = 1'b0;
            m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
            
            intrx_axis_tready = 1'b0;
                
            inttx_axis_tvalid = 1'b1;  
            inttx_axis_tkeep  = {cur_extract_vreg[DATA_BYTE-1 -: (DATA_BYTE-EXTRACT_LEN)],
                               {EXTRACT_LEN{1'b0}}}; 
            inttx_axis_tdata  = {cur_extract_dreg[DATA_BYTE*8-1 -: (DATA_BYTE-EXTRACT_LEN)*8],
                               {EXTRACT_LEN{8'b0}}}; 
            inttx_axis_tlast  = 1'b1 ;  
            inttx_axis_tuser  = tuser_reg ; 
            if(inttx_axis_tready == 1'b1) begin
                nxt_exc_state = START_S;
            end
            else begin
                nxt_exc_state = NEW_TAIL_S;
            end
        end
        
        default: begin
            nxt_extract_vreg = {(EXTRACT_LEN){1'b0}};
            nxt_extract_dreg = {(EXTRACT_LEN){8'b0}};
            
            m_extract_tvalid = 1'b0;
            m_extract_tdata  = {(EXTRACT_LEN){8'b0}};
            
            intrx_axis_tready = 1'b0;
                
            inttx_axis_tvalid = 1'b1;  
            inttx_axis_tkeep  = {(DATA_BYTE){1'b0}}; 
            inttx_axis_tdata  = {(DATA_BYTE){8'b0}};   
            inttx_axis_tlast  = 1'b0 ; 
            nxt_exc_state = START_S;
        end
    endcase
end


/*-----------------------------------------------------------------------
                     移除数据尾部处理
-----------------------------------------------------------------------*/
reg [1:0] cur_post_state,nxt_post_state;

localparam  P_TRANS_S = 2'd0,
            P_TAIL_S  = 2'd1,
            P_DISC_S  = 2'd2;
always @(posedge axis_clk or negedge axis_rst_n) begin
    if(axis_rst_n == 1'b0) begin
        cur_post_state <= P_TRANS_S;
    end
    else begin
        cur_post_state <= nxt_post_state;
    end
end           
always @(*) begin
    post_axis_tkeep  = pre_axis_tkeep ;
    post_axis_tdata  = pre_axis_tdata ;
    post_axis_tlast  = pre_axis_tlast;
    post_axis_tuser  = pre_axis_tuser;  
    case(cur_post_state)
        P_TRANS_S: begin
            if((post_axis_tready == 1'b1) && 
               (cache_axis_tvalid == 1'b1) && 
               (pre_axis_tvalid == 1'b1)) begin//PreAXISRegBuf_Inst要缓存有1拍报文待传输
                pre_axis_tready = 1'b1;
                post_axis_tvalid = 1'b1;
                if(cache_axis_tlast == 1'b1) begin//传输到报文尾
                    if((|cache_axis_tkeep) == 1'b0) begin//尾部为空,将导数第二拍
                        post_axis_tlast  = 1'b1 ;
                        post_axis_tuser  = cache_axis_tuser ;   
                        nxt_post_state  = P_DISC_S;
                    end
                    else begin
                        nxt_post_state  = P_TAIL_S;
                    end
                end
                else begin 
                    nxt_post_state  = P_TRANS_S;
                end
            end
            else begin
                pre_axis_tready = 1'b0;
                post_axis_tvalid = 1'b0;
                nxt_post_state  = P_TRANS_S;
            end
        end
        
        P_DISC_S: begin//丢弃无用的尾部
            pre_axis_tready = 1'b1;
            post_axis_tvalid = 1'b0;
            if((pre_axis_tvalid == 1'b1) && (pre_axis_tlast == 1'b1)) begin
               nxt_post_state  = P_TRANS_S;
            end
            else begin
               nxt_post_state  = P_DISC_S;
            end
        end
        
        P_TAIL_S: begin//传输尾部
            pre_axis_tready = post_axis_tready;
            post_axis_tvalid = pre_axis_tvalid;
            if((post_axis_tready == 1'b1) && 
               (pre_axis_tvalid == 1'b1) && 
               (pre_axis_tlast == 1'b1)) begin
               nxt_post_state  = P_TRANS_S;
            end
            else begin
               nxt_post_state  = P_TAIL_S;
            end
        end
        
        default: begin
            pre_axis_tready = 1'b0;
            post_axis_tvalid = 1'b0;
            nxt_post_state  = P_TRANS_S;
        end
    endcase
end
/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
PktLineDet #(16) IntaxisLineDet_Inst(
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
)CacheAXISRegBuf_Inst(
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
    .m_axis_tready(cache_axis_tready),
    .m_axis_tvalid(cache_axis_tvalid),
    .m_axis_tkeep (cache_axis_tkeep ),
    .m_axis_tdata (cache_axis_tdata ),
    .m_axis_tlast (cache_axis_tlast ),
    .m_axis_tuser (cache_axis_tuser )
);
//注意，该模块PROMODE_EN只能是0，即只能让其缓存1拍数据，以方便识别尾部和倒数第二拍
AXISRegBuf#(
    .PROMODE_EN(0),
    .DATA_BYTE (DATA_BYTE),
    .USER_BIT  (USER_BIT)
)PreAXISRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(cache_axis_tready),    
    .s_axis_tvalid(cache_axis_tvalid),    
    .s_axis_tkeep (cache_axis_tkeep ),
    .s_axis_tdata (cache_axis_tdata ),
    .s_axis_tlast (cache_axis_tlast ),
    .s_axis_tuser (cache_axis_tuser ),    
//报文分组输出接口信号
    .m_axis_tready(pre_axis_tready),
    .m_axis_tvalid(pre_axis_tvalid),
    .m_axis_tkeep (pre_axis_tkeep ),
    .m_axis_tdata (pre_axis_tdata ),
    .m_axis_tlast (pre_axis_tlast ),
    .m_axis_tuser (pre_axis_tuser )
);

AXISRegBuf#(
    .PROMODE_EN(1),
    .DATA_BYTE (DATA_BYTE),
    .USER_BIT  (USER_BIT)
)PostAXISRegBuf_Inst(
//时钟复位信号
    .axis_clk  (axis_clk  ),
    .axis_rst_n(axis_rst_n),  
//报文分组输入接口信号         
    .s_axis_tready(post_axis_tready),    
    .s_axis_tvalid(post_axis_tvalid),    
    .s_axis_tkeep (post_axis_tkeep ),
    .s_axis_tdata (post_axis_tdata ),
    .s_axis_tlast (post_axis_tlast ),
    .s_axis_tuser (post_axis_tuser ),    
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
AXISByteExtract#(
    .EXTRACT_LEN(),
    .EXTRACT_SITE(),
    .DATA_BYTE  (),
    .USER_BIT   ()
)AXISExtract_Inst(
//时钟复位信号
    .axis_clk  (),
    .axis_rst_n(),
//提取数据
    .m_extract_tready(),
    .m_extract_tvalid(),
    .m_extract_tdata (),
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