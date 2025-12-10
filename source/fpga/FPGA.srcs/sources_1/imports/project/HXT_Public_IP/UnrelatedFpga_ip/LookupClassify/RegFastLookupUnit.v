/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  RegFastLookupUnit.v
Target Device All
Dscription 
    1)维护多组寄存器作为查表表项
    2)提供表项配置接口实现外部对表项的配置和读取
    3)接收查表请求对表项并行匹配，并输出命中的表项索引
    4)同时内置老化计数器，支持表项老化,老化本身没有那么精确,因此无需考虑每拍时钟的周期
Data_Struct:
    1)s_cfg_cmd
        0:读表项  
        1:写表项  
        2:自学习 
        3:清除
    2)s_cfg_resp
        [17:16]:Stat状态
            0:none
            1:正常
            2:错误
            3:保留
        [15:0]:index
    3)s_cfg_data
        RSL
        MASK
        KEY
    4)ent_typ_reg
        0:无效表项                     
        1:静态配置表项,用户手动配置，不会老化 
        2:动态自学习表项，收老化影响   
        3：老化表项，已经老化失效的表项
Author : lxj
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/
module RegFastLookupUnit#(
    parameter ENT_SUM    = 64 ,
              KEY_WIDTH  = 64 ,
              RSL_WIDTH  = 16 ,
              MASK_EN    = 0  ,
              AGE_PERIOD = 300,

              ENT_WIDTH = (MASK_EN == 1'b0) ? RSL_WIDTH + KEY_WIDTH : RSL_WIDTH + KEY_WIDTH*2//用户无需配置，仅方便端口声明
)(
//时钟复位信号
    input  wire                 clk  ,
    input  wire                 rst_n,
//表项配置接口-基于Localbus扩展
(*mark_debug="true"*)    input  wire                 s_cfg_sel,//配置选择
(*mark_debug="true"*)    input  wire [          1:0] s_cfg_cmd,//0:读表项  1:写表项  2:自学习 3:清除
(*mark_debug="true"*)    input  wire [         15:0] s_cfg_index,
(*mark_debug="true"*)    input  wire [ENT_WIDTH-1:0] s_cfg_wdata,
(*mark_debug="true"*)    output reg  [         17:0] s_cfg_resp,//{stat,index}
(*mark_debug="true"*)    output reg  [ENT_WIDTH-1:0] s_cfg_rdata,
//查表接口
(*mark_debug="true"*)    output wire                 s_key_axis_tready,
(*mark_debug="true"*)    input  wire                 s_key_axis_tvalid,
(*mark_debug="true"*)    input  wire [KEY_WIDTH-1:0] s_key_axis_tdata ,
    
(*mark_debug="true"*)    input  wire                 m_rsl_axis_tready,
(*mark_debug="true"*)    output wire                 m_rsl_axis_tvalid,
(*mark_debug="true"*)    output wire [RSL_WIDTH-1:0] m_rsl_axis_tdata ,
(*mark_debug="true"*)    output wire [         16:0] m_rsl_axis_tuser ,//{hit,index}
//查表单元状态信息
(*mark_debug="true"*)    input  wire [         15:0] iv_age_period
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam ENT_LOG  = clogb2(ENT_SUM),
           KEY_BYTE = (KEY_WIDTH>>3) + (|(KEY_WIDTH%8)),
           RSL_BYTE = (RSL_WIDTH>>3) + (|(RSL_WIDTH%8));
            
(*mark_debug="true"*)reg                   intrx0_cfg_sel_reg   , intrx1_cfg_sel_reg  ;
(*mark_debug="true"*)reg  [           1:0] intrx0_cfg_cmd_reg   , intrx1_cfg_cmd_reg  ;
(*mark_debug="true"*)reg  [          15:0] intrx0_cfg_index_reg , intrx1_cfg_index_reg;
(*mark_debug="true"*)reg  [ ENT_WIDTH-1:0] intrx0_cfg_wdata_reg , intrx1_cfg_wdata_reg;
       
(*mark_debug="true"*)reg                   intm_key_axis_tready;
(*mark_debug="true"*)wire                  intm_key_axis_tvalid;
(*mark_debug="true"*)wire [KEY_BYTE*8-1:0] intm_key_axis_tdata ;

(*mark_debug="true"*)wire                  ints_rsl_axis_tready;
(*mark_debug="true"*)reg                   ints_rsl_axis_tvalid;
(*mark_debug="true"*)reg  [RSL_BYTE*8-1:0] ints_rsl_axis_tdata ;
(*mark_debug="true"*)reg  [          16:0] ints_rsl_axis_tuser ;//表项索引
(*mark_debug="true"*)wire                  intm_rsl_axis_tready;
(*mark_debug="true"*)wire                  intm_rsl_axis_tvalid;
(*mark_debug="true"*)wire [RSL_BYTE*8-1:0] intm_rsl_axis_tdata ;
(*mark_debug="true"*)wire [          16:0] intm_rsl_axis_tuser ;//表项索引
(*mark_debug="true"*)wire [          31:0] rsl_free_space;

//0:无效表项                     1:静态配置表项,用户手动配置，不会老化 
//2:动态自学习表项，收老化影响   3：老化表项，已经老化失效的表项
(*mark_debug="true"*)reg  [          1:0] ent_typ_reg [ENT_SUM-1:0];//表项类型记录 
(*mark_debug="true"*)reg  [         15:0] ent_age_reg [ENT_SUM-1:0];//老化时刻记录
(*mark_debug="true"*)reg  [KEY_WIDTH-1:0] ent_key_reg [ENT_SUM-1:0];//关键字记录
(*mark_debug="true"*)reg  [KEY_WIDTH-1:0] ent_msk_reg [ENT_SUM-1:0];//关键字掩码
(*mark_debug="true"*)reg  [RSL_WIDTH-1:0] ent_rsl_reg [ENT_SUM-1:0];//查表结果记录

(*mark_debug="true"*)wire [KEY_WIDTH-1:0] cfg_key_field;
(*mark_debug="true"*)wire [KEY_WIDTH-1:0] cfg_msk_field;
(*mark_debug="true"*)wire [RSL_WIDTH-1:0] cfg_rsl_field;

(*mark_debug="true"*)wire [  ENT_SUM-1:0] ent_exist;//表项已存在标记,用于自学习
(*mark_debug="true"*)reg  [  ENT_SUM-1:0] ent_empty;//表项空闲标记
(*mark_debug="true"*)reg  [  ENT_SUM-1:0] aging_flag;//老化标记

(*mark_debug="true"*)wire [  ENT_SUM-1:0] ent_learn_req;//自学习请求
(*mark_debug="true"*)wire [  ENT_SUM-1:0] ent_learn_sel;
(*mark_debug="true"*)reg  [  ENT_SUM-1:0] ent_learn_sel_reg;//空表项选择,用于自学习
(*mark_debug="true"*)wire [  ENT_SUM-1:0] ent_cfg_sel;
(*mark_debug="true"*)reg  [  ENT_SUM-1:0] ent_cfg_sel_reg;//表项配置请求
(*mark_debug="true"*)wire [  ENT_LOG-1:0] ent_learn_index;//自学习表项的二进制索引

(*mark_debug="true"*)reg  [  ENT_SUM-1:0] lookup_hit;//查表命中标记
(*mark_debug="true"*)wire [  ENT_LOG-1:0] lookup_hit_index;//查表命中标记的表项索引

(*mark_debug="true"*)reg  [          0:0] lookup_valid_dly;
    
(*mark_debug="true"*)reg  [          26:0] age_pulse_cnt;
(*mark_debug="true"*)reg  [          15:0] age_timer;
            
(*mark_debug="true"*)wire [          15:0] wv_age_peirod;

/*----------------------------------------------------------
                    表项配置接口处理
----------------------------------------------------------*/
//表项学习请求，有已存在的表项则更新存在的表项，不存在的表项则选择空表项
assign ent_learn_req = ((|ent_exist) == 1'b1) ? ent_exist : ent_empty;

//缓存所有输入的配置信号，以优化时序
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        intrx0_cfg_sel_reg   <= 1'b0;
        intrx0_cfg_cmd_reg   <= 2'b0;
        intrx0_cfg_index_reg <= 16'b0;
        intrx0_cfg_wdata_reg <= {ENT_WIDTH{1'b0}};
        
        intrx1_cfg_sel_reg   <= 1'b0;
        intrx1_cfg_cmd_reg   <= 2'b0;
        intrx1_cfg_index_reg <= 16'b0;
        intrx1_cfg_wdata_reg <= {ENT_WIDTH{1'b0}};
    end
    else begin
        intrx0_cfg_sel_reg   <= s_cfg_sel;
        intrx0_cfg_cmd_reg   <= s_cfg_cmd;
        intrx0_cfg_index_reg <= s_cfg_index;
        intrx0_cfg_wdata_reg <= s_cfg_wdata;
        
        intrx1_cfg_sel_reg   <= intrx0_cfg_sel_reg  ;
        intrx1_cfg_cmd_reg   <= intrx0_cfg_cmd_reg  ;
        intrx1_cfg_index_reg <= intrx0_cfg_index_reg;
        intrx1_cfg_wdata_reg <= intrx0_cfg_wdata_reg;
    end
end
//缓存1拍各表项的选择信号，以优化时序
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        ent_learn_sel_reg <= {ENT_WIDTH{1'b0}};
        ent_cfg_sel_reg   <= {ENT_WIDTH{1'b0}};
    end
    else begin
        ent_learn_sel_reg <= ent_learn_sel;
        ent_cfg_sel_reg   <= ent_cfg_sel  ;
    end
end

//配置信号缓存2拍，而选择信号选用缓存1拍的配置信号，然后再缓存1拍，因此intrx1配置信号和选择信号将同拍
//所有配置请求均可无反压处理,即单纯根据数延时拍数返回响应结果即可
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        s_cfg_resp  <= 18'd0;
        s_cfg_rdata <= {ENT_WIDTH{1'b0}};
    end
    else if(intrx1_cfg_sel_reg == 1'b1) begin//配置请求延时2拍后开始处理
        case(intrx1_cfg_cmd_reg) 
            2'd0: begin//读表项
                s_cfg_resp[17:16] <= ((ent_typ_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]] == 2'd0) || 
                                      (ent_typ_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]] == 2'd3)) ? 
                                      2'd2 : 2'd1;//用错误表示空表项
                s_cfg_resp[15: 0] <= intrx1_cfg_index_reg;
                s_cfg_rdata       <= (MASK_EN == 1'b1) ? 
                                     {ent_rsl_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]],
                                      ent_msk_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]],
                                      ent_key_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]]} : 
                                     {ent_rsl_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]],
                                      ent_key_reg[intrx1_cfg_index_reg[ENT_LOG-1:0]]};
            end
            
            2'd1: begin//写表项
                s_cfg_resp[17:16] <= 2'd1;
                s_cfg_resp[15: 0] <= intrx1_cfg_index_reg;
            end
            
            2'd2: begin//自学习
                if((|ent_learn_sel_reg) == 1'b0) begin//学习失败
                    s_cfg_resp[17:16] <= 2'd2;
                    s_cfg_resp[15: 0] <= 16'b0;
                end
                else begin
                    s_cfg_resp[17:16] <= 2'd1;
                    s_cfg_resp[15: 0] <= ent_learn_index + 16'b0;
                end
            end
            
            2'd3: begin//清除
                s_cfg_resp[17:16] <= 2'b1;
                s_cfg_resp[15: 0] <= intrx1_cfg_index_reg;
            end
        endcase
    end
    else begin
        s_cfg_resp <= 18'd0;//无响应状态
    end
end
/*----------------------------------------------------------
                    老化计时
----------------------------------------------------------*/
//老化时间秒计时，以8ns为周期，计满2^27约为1s
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) age_pulse_cnt <= 27'b0;
    else              age_pulse_cnt <= age_pulse_cnt + 1'b1;
end

always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) age_timer <= 16'b0;
    else              age_timer <= age_timer + (&age_pulse_cnt);
end 

//确认老化周期，用户配置就按用户的，否则按默认的
assign wv_age_peirod = (iv_age_period > 16'b0) ? iv_age_period : AGE_PERIOD;

/*----------------------------------------------------------
                    表项维护
----------------------------------------------------------*/
assign cfg_key_field = intrx1_cfg_wdata_reg[KEY_WIDTH-1:0];
assign cfg_msk_field = (MASK_EN == 1'b1) ? 
                        intrx1_cfg_wdata_reg[KEY_WIDTH +: KEY_WIDTH] : 
                        {KEY_WIDTH{1'b1}};//需要掩码就配置掩码，否则掩码默认全为1，即不掩
assign cfg_rsl_field = intrx1_cfg_wdata_reg[ENT_WIDTH-1 -: RSL_WIDTH]; 

generate 
    genvar i;
    for(i=0;i<ENT_SUM;i=i+1) begin : EntryMgmt
        //表项寄存器空标记和老化标记
        always @(posedge clk or negedge rst_n) begin
            if(rst_n == 1'b0) begin
                ent_empty [i] <= 1'b0;
                aging_flag[i] <= 1'b0;
            end
            else begin
                ent_empty [i] <= ((ent_typ_reg[i] == 2'd0) | (ent_typ_reg[i] == 2'd3));//标记当前空表项，方便自学习时选择
                aging_flag[i] <= ((AGE_PERIOD > 0) & (ent_typ_reg[i] == 2'd2) & 
                                  (((age_timer >= ent_age_reg[i]) && ((age_timer - ent_age_reg[i]) >= wv_age_peirod)) || 
                                  ((age_timer < ent_age_reg[i]) && ((16'hFFFF + age_timer - ent_age_reg[i]) >= wv_age_peirod)))
                                 );
            end
        end
        
        //自学习判断是否有已存在的表项
        assign ent_exist[i] = ((intrx0_cfg_cmd_reg == 2'd2) && (intrx0_cfg_wdata_reg[KEY_WIDTH-1:0] == ent_key_reg[i]));
        
        always @(posedge clk or negedge rst_n) begin
            if(rst_n == 1'b0) begin
                ent_typ_reg[i] <= 2'd0;
                ent_age_reg[i] <= 16'd0;
                ent_key_reg[i] <= {KEY_WIDTH{1'b0}};
                ent_msk_reg[i] <= {KEY_WIDTH{1'b1}};
                ent_rsl_reg[i] <= {RSL_WIDTH{1'b0}};
            end
            else if((intrx1_cfg_cmd_reg == 2'd1) && (ent_cfg_sel_reg[i] == 1'd1)) begin//表项静态配置
                ent_typ_reg[i] <= 2'd1;
                ent_age_reg[i] <= ent_age_reg[i];
                ent_key_reg[i] <= cfg_key_field;
                ent_msk_reg[i] <= cfg_msk_field;
                ent_rsl_reg[i] <= cfg_rsl_field;
            end
            else if((intrx1_cfg_cmd_reg == 2'd2) && ((ent_learn_sel_reg[i] == 1'd1)))begin//表项自学习
                ent_typ_reg[i] <= 2'd2;
                ent_age_reg[i] <= age_timer;
                ent_key_reg[i] <= cfg_key_field;
                ent_msk_reg[i] <= cfg_msk_field;
                ent_rsl_reg[i] <= cfg_rsl_field;
            end
            else if((intrx1_cfg_cmd_reg == 2'd3) && (ent_cfg_sel_reg[i] == 1'd1))begin//表项清除
                ent_typ_reg[i] <= 2'd0;
                ent_age_reg[i] <= 16'd0;
                ent_key_reg[i] <= {KEY_WIDTH{1'b0}};
                ent_msk_reg[i] <= {KEY_WIDTH{1'b1}};
                ent_rsl_reg[i] <= {RSL_WIDTH{1'b0}};
            end
            else if(aging_flag[i] == 1'b1) begin//表项老化
                ent_typ_reg[i] <= 2'd3;
                ent_age_reg[i] <= ent_age_reg[i];
                ent_key_reg[i] <= ent_key_reg[i];
                ent_msk_reg[i] <= ent_msk_reg[i];
                ent_rsl_reg[i] <= ent_rsl_reg[i];
            end
            else begin//保持表项状态
                ent_typ_reg[i] <= ent_typ_reg[i];
                ent_age_reg[i] <= ent_age_reg[i];
                ent_key_reg[i] <= ent_key_reg[i];
                ent_msk_reg[i] <= ent_msk_reg[i];
                ent_rsl_reg[i] <= ent_rsl_reg[i];
            end
        end 
        
        //查表请求检索
        always @(posedge clk or negedge rst_n) begin
            if(rst_n == 1'b0) begin
                lookup_hit[i] <= 1'b0;
            end
            else if((intm_key_axis_tvalid == 1'b1) && (intm_key_axis_tready == 1'b1))begin
                lookup_hit[i] <= ((|((intm_key_axis_tdata ^ ent_key_reg[i]) & ent_msk_reg[i])) == 1'b0);
            end
            else begin
                lookup_hit[i] <= 1'b0;
            end
        end
    end
endgenerate

/*----------------------------------------------------------
                    查表请求及结果处理
----------------------------------------------------------*/
//通过延时生成最终返回的查表结果所在的时间
always @(posedge clk) lookup_valid_dly <= ((intm_key_axis_tvalid == 1'b1) && (intm_key_axis_tready == 1'b1));

//当查表结果缓存FIFO可继续缓存一定突发时才允许查表
always @(posedge clk) intm_key_axis_tready <= (rsl_free_space > 32'd4);

//查表结果返回
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        ints_rsl_axis_tvalid <= 1'b0;
        ints_rsl_axis_tdata  <= {RSL_BYTE{8'b0}};
        ints_rsl_axis_tuser  <= 17'b0;
    end
    else if(lookup_valid_dly == 1'b1) begin
        ints_rsl_axis_tvalid      <= 1'b1;
        ints_rsl_axis_tdata       <= ent_rsl_reg[lookup_hit_index];
        ints_rsl_axis_tuser[16]   <= (|lookup_hit);
        ints_rsl_axis_tuser[15:0] <= lookup_hit_index+16'b0;
    end
    else begin
        ints_rsl_axis_tvalid <= 1'b0;
        ints_rsl_axis_tuser  <= 17'b0;
    end
end

//查表结果缓存后输出
assign intm_rsl_axis_tready = m_rsl_axis_tready;
assign m_rsl_axis_tvalid    = intm_rsl_axis_tvalid;
assign m_rsl_axis_tdata     = intm_rsl_axis_tdata[RSL_WIDTH-1:0];
assign m_rsl_axis_tuser     = intm_rsl_axis_tuser ;
/*----------------------------------------------------------
                    IP调用区域
----------------------------------------------------------*/
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

binary2onehot #(
    .WIDTH      (ENT_LOG))
index2entsel_inst(
    //ports
    .i_bin          ( intrx0_cfg_index_reg[ENT_LOG-1:0]),
    .o_onehot       ( ent_cfg_sel             )
);

bitmap2onehot #(
    .PRIOR_LOW_OR_HIGH      ( 0      ),
    .WIDTH                  (ENT_SUM))
entrylearn_bitmap2onehot(
    //ports
    .i_bitmap       ( ent_learn_req),
    .o_onehot       ( ent_learn_sel)
);

onehot2binary #(
    .WIDTH      ( ENT_LOG ))
learnindex_onehot2bin(
    //ports
    .i_onehot       ( ent_learn_sel_reg ),
    .o_bin          ( ent_learn_index    )
);

onehot2binary #(
    .WIDTH      ( ENT_LOG ))
hit_onehot2bin(
    //ports
    .i_onehot   ( lookup_hit       ),
    .o_bin      ( lookup_hit_index )
);

AXISRegBuf#(
    .DATA_BYTE (KEY_BYTE),
    .USER_BIT  (1       ),
    .PROMODE_EN(1       )//输出选择进阶版，相比标准版，多了1级缓存，时序更优
)KeyRegBuf_Inst(
//时钟复位信号
    .axis_clk     (clk  ),
    .axis_rst_n   (rst_n),
//AXI Stream输入接口
    .s_axis_tready(s_key_axis_tready),
    .s_axis_tvalid(s_key_axis_tvalid),
    .s_axis_tkeep ({KEY_BYTE{1'b1}} ),
    .s_axis_tdata (s_key_axis_tdata+{(KEY_BYTE*8){1'b0}}),
    .s_axis_tlast (1'b1             ),
    .s_axis_tuser (1'b0             ),    
//AXI Stream输出接口
    .m_axis_tready(intm_key_axis_tready),
    .m_axis_tvalid(intm_key_axis_tvalid),
    .m_axis_tkeep (                    ),
    .m_axis_tdata (intm_key_axis_tdata ),
    .m_axis_tlast (                    ),
    .m_axis_tuser (                    )
);

AXISFifoBuf#(
    .ASYNC_EN   ( 0      ),//同步或异步  0：同步  1：异步
    .DEEP_WIDTH ( 5      ),//缓存FIFO的容量的指数位宽
    .PKT_MODE   ( 0      ),//处理模式，0：流处理模式  1：报文处理模式
    .DATA_BYTE  (RSL_BYTE),
    .USER_BIT   (17      ),
    .MIN_PKTLINE( 1      )
)RslFifoBuf_Inst(
//时钟复位信号
    .s_axis_clk   (clk         ),
    .s_axis_rst_n (rst_n       ),
    .m_axis_clk   (clk         ),
    .m_axis_rst_n (rst_n       ),
//AXI Stream输入接口
    .s_axis_tready(ints_rsl_axis_tready),
    .s_axis_tvalid(ints_rsl_axis_tvalid),
    .s_axis_tkeep ({RSL_BYTE{1'b1}}    ),
    .s_axis_tdata (ints_rsl_axis_tdata ),
    .s_axis_tlast (1'b1                ),
    .s_axis_tuser (ints_rsl_axis_tuser ),    
//AXI Stream输出接口
    .m_axis_tready(intm_rsl_axis_tready),
    .m_axis_tvalid(intm_rsl_axis_tvalid),
    .m_axis_tkeep (                    ),
    .m_axis_tdata (intm_rsl_axis_tdata ),
    .m_axis_tlast (                    ),
    .m_axis_tuser (intm_rsl_axis_tuser ),
//状态信号                               
    .free_space   (rsl_free_space      ),
    .used_space   (                    )
);

endmodule
/*
RegFastLookupUnit#(
    .ENT_SUM    (64 ),
    .KEY_WIDTH  (64 ),
    .RSL_WIDTH  (16 ),
    .MASK_EN    (0  ),
    .AGE_PERIOD (300)
)RFLU_Inst(
//时钟复位信号
    .clk         (),
    .rst_n       (),
//表项配置接口-基于Localbus扩展
    .s_cfg_sel   (),//配置选择
    .s_cfg_cmd   (),//0:读表项  1:写表项  2:自学习 3:清除
    .s_cfg_index (),
    .s_cfg_wdata (),
    .s_cfg_resp  (),//{stat(),index}
    .s_cfg_rdata (),
//查表接口
    .s_key_axis_tready(),
    .s_key_axis_tvalid(),
    .s_key_axis_tdata (),

    .m_rsl_axis_tready(),
    .m_rsl_axis_tvalid(),
    .m_rsl_axis_tdata (),
    .m_rsl_axis_tuser (),//{hit(),index}
//查表单元状态信息
    .iv_age_period    ()
);
*/