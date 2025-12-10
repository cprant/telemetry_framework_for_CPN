/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  DN_NewNP_Core.v
Target Device All
Dscription 
    1)	接收并汇聚输入引擎和输出引擎模块触发产生的遥测信息
    2)	针对汇聚的遥测信息，封装生成网络遥测分组
    3)	将生成的遥测分组发往遥测服务器

Data_Struct:
    1)遥测信息
        [115:100] pkt_len
        [ 99: 36] timestamp
        [ 35: 16] flow label
        [ 15:  0] 帧的序列号seqnum
        
    2)int_axis_tdata
        [127:64] 本地时间戳
        [ 63:32] flow label 
        [ 31:16] 帧的序列号seqnum
        [ 15: 0] 接口标识
        
    3)遥测帧数据
        以太网(14B)  目的MAC是遥测服务器地址MAC
            DMAC=6
            SMAC=6
            LEN/TYPE=2
        IPv6头(40B） 目的IPv6地址为遥测服务器地址的IPv6头
            Version=6
            Traffic class=0
            Flow label=0
            Payload length=34
            Next Header=253（遥测帧）
            HopLimit=8
            SIP=本地IPv6地址
            DIP=遥测服务器地址
        遥测数据（34B）	
            2字节报文长度
            8字节本地时间戳
            4字节flow label
            2字节帧的序列号seqnum
            2字节接口标识
            4字节：CPU0的负载
            4字节：CPU1的负载
            4字节：CPU2的负载
            4字节：CPU3的负载

Author : LXJ
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
Caution:
    1)
*/
module DN_NewNP_Core #(
    parameter   VERSION   = 32'h22_1004_01,//8bit年后2位+16bit月日+8bit版本号
                THREAD_SUM = 4,
                SGMII_SUM  = 4,
                BASER_SUM  = 1,
                CPU_BYTE   = 1,
                Mbus_ID    = 1,
                
                SRC_STEP   = 32'h8_0000,
                SGMII_DST_STEP = 32'h8_0000,
                BASER_DST_STEP = 32'h6_6667,
                INIT_DLY   = 3,//应当大于src_clk和dst_clk之间的倍率
                TIME_WIDTH = 64
)(
    input  wire                    s_cpu_axis_clk  ,   
    input  wire                    s_cpu_axis_rst_n,
                                   
    input  wire                    m_cpu_axis_clk  ,   
    input  wire                    m_cpu_axis_rst_n,
                   
    input  wire [   SGMII_SUM-1:0] s_sgmii_axis_clk  ,   
    input  wire [   SGMII_SUM-1:0] s_sgmii_axis_rst_n,
                                   
    input  wire [   SGMII_SUM-1:0] m_sgmii_axis_clk  ,   
    input  wire [   SGMII_SUM-1:0] m_sgmii_axis_rst_n,
                            
    input  wire [   BASER_SUM-1:0] s_baser_axis_clk  ,   
    input  wire [   BASER_SUM-1:0] s_baser_axis_rst_n,
                            
    input  wire [   BASER_SUM-1:0] m_baser_axis_clk  ,   
    input  wire [   BASER_SUM-1:0] m_baser_axis_rst_n,
    
    input  wire                    user_axis_clk  ,   
    input  wire                    user_axis_rst_n,
    
    input  wire                    hcp_clk  ,
    input  wire                    hcp_rst_n,
//CPU分分组数据接收接口
    output wire [         1*1-1:0] s_cpu_axis_tready,
    input  wire [         1*1-1:0] s_cpu_axis_tvalid,
    input  wire [  CPU_BYTE*1-1:0] s_cpu_axis_tkeep ,
    input  wire [8*CPU_BYTE*1-1:0] s_cpu_axis_tdata ,
    input  wire [         1*1-1:0] s_cpu_axis_tlast ,
    input  wire [         1*1-1:0] s_cpu_axis_tuser ,
//CPU分数据输出接口                  
    input  wire [         1*1-1:0] m_cpu_axis_tready,
    output wire [         1*1-1:0] m_cpu_axis_tvalid,
    output wire [  CPU_BYTE*1-1:0] m_cpu_axis_tkeep ,
    output wire [8*CPU_BYTE*1-1:0] m_cpu_axis_tdata ,
    output wire [         1*1-1:0] m_cpu_axis_tlast ,
    output wire [         1*1-1:0] m_cpu_axis_tuser ,
//SGMII分组数据接收接口
    output wire [ 1*SGMII_SUM-1:0] s_sgmii_axis_tready,
    input  wire [ 1*SGMII_SUM-1:0] s_sgmii_axis_tvalid,
    input  wire [ 1*SGMII_SUM-1:0] s_sgmii_axis_tkeep ,
    input  wire [ 8*SGMII_SUM-1:0] s_sgmii_axis_tdata ,
    input  wire [ 1*SGMII_SUM-1:0] s_sgmii_axis_tlast ,
    input  wire [ 1*SGMII_SUM-1:0] s_sgmii_axis_tuser ,
//SGMII数据输出接口
(*mark_debug="true"*)    input  wire [ 1*SGMII_SUM-1:0] m_sgmii_axis_tready,
(*mark_debug="true"*)    output wire [ 1*SGMII_SUM-1:0] m_sgmii_axis_tvalid,
(*mark_debug="true"*)    output wire [ 1*SGMII_SUM-1:0] m_sgmii_axis_tkeep ,
(*mark_debug="true"*)    output wire [ 8*SGMII_SUM-1:0] m_sgmii_axis_tdata ,
(*mark_debug="true"*)    output wire [ 1*SGMII_SUM-1:0] m_sgmii_axis_tlast ,
(*mark_debug="true"*)    output wire [ 1*SGMII_SUM-1:0] m_sgmii_axis_tuser ,
//BASE-R分组数据接收接口
    output wire [ 1*BASER_SUM-1:0] s_baser_axis_tready,
    input  wire [ 1*BASER_SUM-1:0] s_baser_axis_tvalid,
    input  wire [ 8*BASER_SUM-1:0] s_baser_axis_tkeep ,
    input  wire [64*BASER_SUM-1:0] s_baser_axis_tdata ,
    input  wire [ 1*BASER_SUM-1:0] s_baser_axis_tlast ,
    input  wire [ 1*BASER_SUM-1:0] s_baser_axis_tuser ,
//BASE-R数据输出接口           
    input  wire [ 1*BASER_SUM-1:0] m_baser_axis_tready,
    output wire [ 1*BASER_SUM-1:0] m_baser_axis_tvalid,
    output wire [ 8*BASER_SUM-1:0] m_baser_axis_tkeep ,
    output wire [64*BASER_SUM-1:0] m_baser_axis_tdata ,
    output wire [ 1*BASER_SUM-1:0] m_baser_axis_tlast ,
    output wire [ 1*BASER_SUM-1:0] m_baser_axis_tuser ,
    
    output wire                    o_soft_rst_n
);
/*----------------------------------------------------------
                    中间变量声明区域
----------------------------------------------------------*/
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
localparam  PORT_SUM = SGMII_SUM+BASER_SUM;

wire                    cpuie2csce_axis_tready;
wire                    cpuie2csce_axis_tvalid;
wire [            15:0] cpuie2csce_axis_tkeep ;
wire [           127:0] cpuie2csce_axis_tdata ;
wire                    cpuie2csce_axis_tlast ;
wire [            11:0] cpuie2csce_axis_tuser ;

wire                    csce2cpuoe_axis_tready;
wire                    csce2cpuoe_axis_tvalid;
wire [            15:0] csce2cpuoe_axis_tkeep ;
wire [           127:0] csce2cpuoe_axis_tdata ;
wire                    csce2cpuoe_axis_tlast ;
wire [             0:0] csce2cpuoe_axis_tuser ;
//CPU调度整形模块与快速交换模块的收发接口
wire                    fsm2csce_axis_tready;
wire                    fsm2csce_axis_tvalid;
wire [            15:0] fsm2csce_axis_tkeep ;
wire [           127:0] fsm2csce_axis_tdata ;
wire                    fsm2csce_axis_tlast ;
wire [             0:0] fsm2csce_axis_tuser ;

wire                    csce2fsm_axis_tready;
wire                    csce2fsm_axis_tvalid;
wire [            15:0] csce2fsm_axis_tkeep ;
wire [           127:0] csce2fsm_axis_tdata ;
wire                    csce2fsm_axis_tlast ;
wire [            11:0] csce2fsm_axis_tuser ;
//SRv6模块与快速交换模块的收发接口
wire                    fsm2srfe_axis_tready;
wire                    fsm2srfe_axis_tvalid;
wire [            15:0] fsm2srfe_axis_tkeep ;
wire [           127:0] fsm2srfe_axis_tdata ;
wire                    fsm2srfe_axis_tlast ;
wire [             0:0] fsm2srfe_axis_tuser ;

wire                    srfe2fsm_axis_tready;
wire                    srfe2fsm_axis_tvalid;
wire [            15:0] srfe2fsm_axis_tkeep ;
wire [           127:0] srfe2fsm_axis_tdata ;
wire                    srfe2fsm_axis_tlast ;
wire [            11:0] srfe2fsm_axis_tuser ;
//CPU调度整形模块与快速交换模块的收发接口
wire                    ntme2fsm_axis_tready;
wire                    ntme2fsm_axis_tvalid;
wire [            15:0] ntme2fsm_axis_tkeep ;
wire [           127:0] ntme2fsm_axis_tdata ;
wire                    ntme2fsm_axis_tlast ;
wire [            11:0] ntme2fsm_axis_tuser ;
//输入输出引擎与快速交换模块的收发接口
wire [  1*PORT_SUM-1:0] srie2fsm_axis_tready;
wire [  1*PORT_SUM-1:0] srie2fsm_axis_tvalid;
wire [ 16*PORT_SUM-1:0] srie2fsm_axis_tkeep ;
wire [128*PORT_SUM-1:0] srie2fsm_axis_tdata ;
wire [  1*PORT_SUM-1:0] srie2fsm_axis_tlast ;
wire [ 12*PORT_SUM-1:0] srie2fsm_axis_tuser ;

wire                    fsm2tsse_axis_tready;
wire                    fsm2tsse_axis_tvalid;
wire [            15:0] fsm2tsse_axis_tkeep ;
wire [           127:0] fsm2tsse_axis_tdata ;
wire                    fsm2tsse_axis_tlast ;
wire [             0:0] fsm2tsse_axis_tuser ;

wire [  1*PORT_SUM-1:0] tsse2sroe_axis_tready;
wire [  1*PORT_SUM-1:0] tsse2sroe_axis_tvalid;
wire [ 16*PORT_SUM-1:0] tsse2sroe_axis_tkeep ;
wire [128*PORT_SUM-1:0] tsse2sroe_axis_tdata ;
wire [  1*PORT_SUM-1:0] tsse2sroe_axis_tlast ;
wire [  1*PORT_SUM-1:0] tsse2sroe_axis_tuser ;
//输出输出引擎提取的测量信息
wire [  1*PORT_SUM-1:0] srie2ntme_tm_axis_tready;
wire [  1*PORT_SUM-1:0] srie2ntme_tm_axis_tvalid;
wire [116*PORT_SUM-1:0] srie2ntme_tm_axis_tdata ;

wire [  1*PORT_SUM-1:0] sroe2ntme_tm_axis_tready;
wire [  1*PORT_SUM-1:0] sroe2ntme_tm_axis_tvalid;
wire [116*PORT_SUM-1:0] sroe2ntme_tm_axis_tdata ;

wire [            63:0] wv_local_cnt;

wire                    csce_lb_cs_n ;
reg                     csce_lb_ack_n;
wire                    csce_lb_wr_rd;//0:wr  1:rd
wire [            31:0] csce_lb_addr ;
wire [            31:0] csce_lb_wdata;
reg  [            31:0] csce_lb_rdata;


reg                     fsm_lb_cs_n ;
wire                    fsm_lb_ack_n;
reg                     fsm_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] fsm_lb_addr ;
reg  [            31:0] fsm_lb_wdata;
wire [            31:0] fsm_lb_rdata;

reg                     tsse_lb_cs_n ;
reg                     tsse_lb_ack_n;
reg                     tsse_lb_wr_rd;//0:wr  1:rd
reg  [            31:0] tsse_lb_addr ;
reg  [            31:0] tsse_lb_wdata;
reg  [            31:0] tsse_lb_rdata;

reg                     tsse_lb_cs_n_reg ;
wire                    tsse_lb_ack_n_reg;
reg                     tsse_lb_wr_rd_reg;//0:wr  1:rd
reg  [            31:0] tsse_lb_addr_reg ;
reg  [            31:0] tsse_lb_wdata_reg;
wire [            31:0] tsse_lb_rdata_reg;

//状态输出信号    
wire [THREAD_SUM*32-1:0] wv_cpu_loadstate;
//配置参数信号         
wire [            47:0] wv_local_mac;
wire [            47:0] wv_perip_mac;
wire [            47:0] wv_meter_mac;
wire [           127:0] wv_local_ip ;
wire [           127:0] wv_meter_ip ;
wire [            31:0] wv_local_srv6_opbit;
/*----------------------------------------------------------
                        配置地址分区
----------------------------------------------------------*/

always @(posedge hcp_clk or negedge hcp_rst_n) begin
    if(hcp_rst_n == 1'b0)begin
        
        tsse_lb_cs_n_reg    <= 1'b1;
        tsse_lb_wr_rd_reg   <= 1'b0;
        tsse_lb_addr_reg    <= 32'd0;
        tsse_lb_wdata_reg   <= 32'd0;
        
    end
    else begin
        tsse_lb_cs_n_reg    <= tsse_lb_cs_n;  
        tsse_lb_ack_n       <= tsse_lb_ack_n_reg; 
        tsse_lb_wr_rd_reg   <= tsse_lb_wr_rd; 
        tsse_lb_addr_reg    <= tsse_lb_addr ;
        tsse_lb_wdata_reg   <= tsse_lb_wdata;
        tsse_lb_rdata       <= tsse_lb_rdata_reg;
       
    end

end



reg [31:0] cur_lb_addr_reg,nxt_lb_addr_reg;

//锁存输入的localbus地址，以免wv_s_lb_addr释放后地址也被清零，导致ack_n选择出错
always @(*) nxt_lb_addr_reg = (csce_lb_cs_n == 1'b0) ? csce_lb_addr : cur_lb_addr_reg;
always @(posedge hcp_clk) cur_lb_addr_reg <= nxt_lb_addr_reg; 

always @* begin
    fsm_lb_wr_rd = csce_lb_wr_rd;
    fsm_lb_addr  = csce_lb_addr ;
    fsm_lb_wdata = csce_lb_wdata;
    
    tsse_lb_wr_rd = csce_lb_wr_rd;
    tsse_lb_addr  = csce_lb_addr ;
    tsse_lb_wdata = csce_lb_wdata;
    
    if(nxt_lb_addr_reg[29:28] == 2'd1) begin//快速交换模块
        fsm_lb_cs_n  = csce_lb_cs_n ;
        tsse_lb_cs_n = 1'b1      ; 
        
        csce_lb_ack_n = fsm_lb_ack_n;
        csce_lb_rdata = fsm_lb_rdata;
    end
    else if(nxt_lb_addr_reg[29:28] == 2'd2) begin//整形模块
        fsm_lb_cs_n  = 1'b1     ;
        tsse_lb_cs_n = csce_lb_cs_n; 
        
        csce_lb_ack_n = tsse_lb_ack_n;
        csce_lb_rdata = tsse_lb_rdata;
    end
    else begin
        fsm_lb_cs_n  = 1'b1;
        tsse_lb_cs_n = 1'b1; 
        
        csce_lb_ack_n = csce_lb_cs_n;
        csce_lb_rdata = csce_lb_wdata;
    end
end
/*-----------------------------------------------------------------------
                    IP调用区域
-----------------------------------------------------------------------*/
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 

//统计信息
wire [PORT_SUM*64-1:0] wv_port_rcv_allpkt_cnt ;
wire [PORT_SUM*64-1:0] wv_port_rcv_filtpkt_cnt;
wire [PORT_SUM*64-1:0] wv_port_rcv_discpkt_cnt;
wire [PORT_SUM*64-1:0] wv_port_rcv_tm_cnt     ; 
wire [PORT_SUM*64-1:0] wv_port_send_pkt_cnt   ;
wire [PORT_SUM*64-1:0] wv_port_send_tm_cnt    ;

wire [       1*64-1:0] wv_cpu_rcv_allpkt_cnt  ;
wire [       1*64-1:0] wv_cpu_rcv_filtpkt_cnt ;
wire [       1*64-1:0] wv_cpu_rcv_discpkt_cnt ;
wire [       1*64-1:0] wv_cpu_rcv_tm_cnt      ; 
wire [       1*64-1:0] wv_cpu_send_pkt_cnt    ;
wire [       1*64-1:0] wv_cpu_send_tm_cnt     ;

//接口数据处理
generate
    genvar i;
    for(i=0;i<PORT_SUM;i=i+1) begin:netport
        if(i < SGMII_SUM) begin:sgmii_engine
            SRv6InputEngine #(
                .PORT_ID                (i),
                .IN_BYTE                (1),
                .SRC_STEP               (SRC_STEP),
                .DST_STEP               (SGMII_DST_STEP),
                .INIT_DLY               (INIT_DLY  ),
                .TIME_WIDTH             (TIME_WIDTH)
            )
            SRIE_Inst(
            //时钟复位信号
                .s_axis_clk    (s_sgmii_axis_clk  [i]),
                .s_axis_rst_n  (s_sgmii_axis_rst_n[i]),
                .m_axis_clk    (user_axis_clk  ),
                .m_axis_rst_n  (user_axis_rst_n),
                .localcnt_clk  (user_axis_clk  ),
                .localcnt_rst_n(user_axis_rst_n),
            //本地同步时钟                
                .iv_local_cnt  (wv_local_cnt),
            //报文分组数据接收接口
                .s_axis_tready(s_sgmii_axis_tready[i*1 +: 1]),
                .s_axis_tvalid(s_sgmii_axis_tvalid[i*1 +: 1]),
                .s_axis_tkeep (s_sgmii_axis_tkeep [i*1 +: 1]),
                .s_axis_tdata (s_sgmii_axis_tdata [i*8 +: 8]),
                .s_axis_tlast (s_sgmii_axis_tlast [i*1 +: 1]),
                .s_axis_tuser (s_sgmii_axis_tuser [i*1 +: 1]),
            //分组数据输出接口
                .m_axis_tready(srie2fsm_axis_tready[i*1   +:  1]),
                .m_axis_tvalid(srie2fsm_axis_tvalid[i*1   +:  1]),
                .m_axis_tkeep (srie2fsm_axis_tkeep [i*16  +: 16]),
                .m_axis_tdata (srie2fsm_axis_tdata [i*128 +:128]),
                .m_axis_tlast (srie2fsm_axis_tlast [i*1   +:  1]),
                .m_axis_tuser (srie2fsm_axis_tuser [i*12  +: 12]),
            //遥测数据输出接口
                .m_tm_axis_tready(srie2ntme_tm_axis_tready[i*1   +:  1]),
                .m_tm_axis_tvalid(srie2ntme_tm_axis_tvalid[i*1   +:  1]),
                .m_tm_axis_tdata (srie2ntme_tm_axis_tdata [i*116 +:116]),
            //统计信息
                .ov_rcv_allpkt_cnt (wv_port_rcv_allpkt_cnt [i*64 +:64]),
                .ov_rcv_filtpkt_cnt(wv_port_rcv_filtpkt_cnt[i*64 +:64]),
                .ov_rcv_discpkt_cnt(wv_port_rcv_discpkt_cnt[i*64 +:64]),
                .ov_rcv_tm_cnt     (wv_port_rcv_tm_cnt     [i*64 +:64])
            );
        
            SRv6OutputEngine #(
                .OUT_BYTE      (1),
                .SRC_STEP      (SRC_STEP),
                .DST_STEP      (SGMII_DST_STEP),
                .INIT_DLY      (INIT_DLY  ),
                .TIME_WIDTH    (TIME_WIDTH)
            )
            SROE_Inst(
            //时钟复位信号
                .s_axis_clk    (user_axis_clk  ),
                .s_axis_rst_n  (user_axis_rst_n),
                .m_axis_clk    (m_sgmii_axis_clk  [i]),
                .m_axis_rst_n  (m_sgmii_axis_rst_n[i]),
                .localcnt_clk  (user_axis_clk  ),
                .localcnt_rst_n(user_axis_rst_n),
            //本地同步时钟                
                .iv_local_cnt  (wv_local_cnt),
            //报文分组数据接收接口
                .s_axis_tready(tsse2sroe_axis_tready[i*1   +:  1]),
                .s_axis_tvalid(tsse2sroe_axis_tvalid[i*1   +:  1]),
                .s_axis_tkeep (tsse2sroe_axis_tkeep [i*16  +: 16]),
                .s_axis_tdata (tsse2sroe_axis_tdata [i*128 +:128]),
                .s_axis_tlast (tsse2sroe_axis_tlast [i*1   +:  1]),
                .s_axis_tuser (tsse2sroe_axis_tuser [i*1   +:  1]),
            //分组数据输出接口
                .m_axis_tready(m_sgmii_axis_tready[i*1 +: 1]),
                .m_axis_tvalid(m_sgmii_axis_tvalid[i*1 +: 1]),
                .m_axis_tkeep (m_sgmii_axis_tkeep [i*1 +: 1]),
                .m_axis_tdata (m_sgmii_axis_tdata [i*8 +: 8]),
                .m_axis_tlast (m_sgmii_axis_tlast [i*1 +: 1]),
                .m_axis_tuser (m_sgmii_axis_tuser [i*1 +: 1]),
            //遥测数据输出接口
                .m_tm_axis_tready(sroe2ntme_tm_axis_tready[i*1   +:  1]),
                .m_tm_axis_tvalid(sroe2ntme_tm_axis_tvalid[i*1   +:  1]),
                .m_tm_axis_tdata (sroe2ntme_tm_axis_tdata [i*116 +:116]),
            //统计信息
                .ov_send_pkt_cnt(wv_port_send_pkt_cnt[i*64 +:64]),
                .ov_send_tm_cnt (wv_port_send_tm_cnt [i*64 +:64])
            );
        end
        else begin:baser_engine
            SRv6InputEngine #(
                .PORT_ID                (i),
                .IN_BYTE                (8),
                .SRC_STEP               (SRC_STEP),
                .DST_STEP               (BASER_DST_STEP),
                .INIT_DLY               (INIT_DLY  ),
                .TIME_WIDTH             (TIME_WIDTH)
            )
            SRIE_Inst(
            //时钟复位信号
                .s_axis_clk    (s_baser_axis_clk  [i-SGMII_SUM]),
                .s_axis_rst_n  (s_baser_axis_rst_n[i-SGMII_SUM]),
                .m_axis_clk    (user_axis_clk  ),
                .m_axis_rst_n  (user_axis_rst_n),
                .localcnt_clk  (user_axis_clk  ),
                .localcnt_rst_n(user_axis_rst_n),
            //本地同步时钟                
                .iv_local_cnt  (wv_local_cnt),
            //报文分组数据接收接口
                .s_axis_tready(s_baser_axis_tready[(i-SGMII_SUM)*1 +: 1]),
                .s_axis_tvalid(s_baser_axis_tvalid[(i-SGMII_SUM)*1 +: 1]),
                .s_axis_tkeep (s_baser_axis_tkeep [(i-SGMII_SUM)*8 +: 8]),
                .s_axis_tdata (s_baser_axis_tdata [(i-SGMII_SUM)*64+:64]),
                .s_axis_tlast (s_baser_axis_tlast [(i-SGMII_SUM)*1 +: 1]),
                .s_axis_tuser (s_baser_axis_tuser [(i-SGMII_SUM)*1 +: 1]),
            //分组数据输出接口
                .m_axis_tready(srie2fsm_axis_tready[i*1   +:  1]),
                .m_axis_tvalid(srie2fsm_axis_tvalid[i*1   +:  1]),
                .m_axis_tkeep (srie2fsm_axis_tkeep [i*16  +: 16]),
                .m_axis_tdata (srie2fsm_axis_tdata [i*128 +:128]),
                .m_axis_tlast (srie2fsm_axis_tlast [i*1   +:  1]),
                .m_axis_tuser (srie2fsm_axis_tuser [i*12  +: 12]),
            //遥测数据输出接口
                .m_tm_axis_tready(srie2ntme_tm_axis_tready[i*1   +:  1]),
                .m_tm_axis_tvalid(srie2ntme_tm_axis_tvalid[i*1   +:  1]),
                .m_tm_axis_tdata (srie2ntme_tm_axis_tdata [i*116 +:116]),
            //统计信息
                .ov_rcv_allpkt_cnt (wv_port_rcv_allpkt_cnt [i*64 +:64]),
                .ov_rcv_filtpkt_cnt(wv_port_rcv_filtpkt_cnt[i*64 +:64]),
                .ov_rcv_discpkt_cnt(wv_port_rcv_discpkt_cnt[i*64 +:64]),
                .ov_rcv_tm_cnt     (wv_port_rcv_tm_cnt     [i*64 +:64])
            );
            
            SRv6OutputEngine #(
                .OUT_BYTE      (8),
                .SRC_STEP      (SRC_STEP),
                .DST_STEP      (BASER_DST_STEP),
                .INIT_DLY      (INIT_DLY  ),
                .TIME_WIDTH    (TIME_WIDTH)
            )
            SROE_Inst(
            //时钟复位信号
                .s_axis_clk    (user_axis_clk  ),
                .s_axis_rst_n  (user_axis_rst_n),
                .m_axis_clk    (m_baser_axis_clk  [i-SGMII_SUM]),
                .m_axis_rst_n  (m_baser_axis_rst_n[i-SGMII_SUM]),
                .localcnt_clk  (user_axis_clk  ),
                .localcnt_rst_n(user_axis_rst_n),
            //本地同步时钟                
                .iv_local_cnt  (wv_local_cnt),
            //报文分组数据接收接口
                .s_axis_tready(tsse2sroe_axis_tready[i*1   +:  1]),
                .s_axis_tvalid(tsse2sroe_axis_tvalid[i*1   +:  1]),
                .s_axis_tkeep (tsse2sroe_axis_tkeep [i*16  +: 16]),
                .s_axis_tdata (tsse2sroe_axis_tdata [i*128 +:128]),
                .s_axis_tlast (tsse2sroe_axis_tlast [i*1   +:  1]),
                .s_axis_tuser (tsse2sroe_axis_tuser [i*1   +:  1]),
            //分组数据输出接口
                .m_axis_tready(m_baser_axis_tready[(i-SGMII_SUM)*1 +: 1]),
                .m_axis_tvalid(m_baser_axis_tvalid[(i-SGMII_SUM)*1 +: 1]),
                .m_axis_tkeep (m_baser_axis_tkeep [(i-SGMII_SUM)*8 +: 8]),
                .m_axis_tdata (m_baser_axis_tdata [(i-SGMII_SUM)*64+:64]),
                .m_axis_tlast (m_baser_axis_tlast [(i-SGMII_SUM)*1 +: 1]),
                .m_axis_tuser (m_baser_axis_tuser [(i-SGMII_SUM)*1 +: 1]),
            //遥测数据输出接口
                .m_tm_axis_tready(sroe2ntme_tm_axis_tready[i*1   +:  1]),
                .m_tm_axis_tvalid(sroe2ntme_tm_axis_tvalid[i*1   +:  1]),
                .m_tm_axis_tdata (sroe2ntme_tm_axis_tdata [i*116 +:116]),
            //统计信息
                .ov_send_pkt_cnt(wv_port_send_pkt_cnt[i*64 +:64]),
                .ov_send_tm_cnt (wv_port_send_tm_cnt [i*64 +:64])
            );
        end
    end
endgenerate

//CPU管理控制
SRv6InputEngine #(
    .PORT_ID                (255),
    .IN_BYTE                (1)
)
CPUIE_Inst(
//时钟复位信号
    .s_axis_clk    (s_cpu_axis_clk  ),
    .s_axis_rst_n  (s_cpu_axis_rst_n),
    .m_axis_clk    (user_axis_clk  ),
    .m_axis_rst_n  (user_axis_rst_n),
    .localcnt_clk  (user_axis_clk  ),
    .localcnt_rst_n(user_axis_rst_n),
//本地同步时钟                
    .iv_local_cnt  (64'b0),
//报文分组数据接收接口
    .s_axis_tready(s_cpu_axis_tready),
    .s_axis_tvalid(s_cpu_axis_tvalid),
    .s_axis_tkeep (s_cpu_axis_tkeep ),
    .s_axis_tdata (s_cpu_axis_tdata ),
    .s_axis_tlast (s_cpu_axis_tlast ),
    .s_axis_tuser (s_cpu_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(cpuie2csce_axis_tready),
    .m_axis_tvalid(cpuie2csce_axis_tvalid),
    .m_axis_tkeep (cpuie2csce_axis_tkeep ),
    .m_axis_tdata (cpuie2csce_axis_tdata ),
    .m_axis_tlast (cpuie2csce_axis_tlast ),
    .m_axis_tuser (cpuie2csce_axis_tuser ),
//遥测数据输出接口
    .m_tm_axis_tready(1'b1),
    .m_tm_axis_tvalid(),
    .m_tm_axis_tdata (),
//统计信息
    .ov_rcv_allpkt_cnt (wv_cpu_rcv_allpkt_cnt ),
    .ov_rcv_filtpkt_cnt(wv_cpu_rcv_filtpkt_cnt),
    .ov_rcv_discpkt_cnt(wv_cpu_rcv_discpkt_cnt),
    .ov_rcv_tm_cnt     (wv_cpu_rcv_tm_cnt     )
);

SRv6OutputEngine #(
    .OUT_BYTE      (1)
)
CPUOE_Inst(
//时钟复位信号
    .s_axis_clk    (user_axis_clk  ),
    .s_axis_rst_n  (user_axis_rst_n),
    .m_axis_clk    (m_cpu_axis_clk  ),
    .m_axis_rst_n  (m_cpu_axis_rst_n),
    .localcnt_clk  (user_axis_clk  ),
    .localcnt_rst_n(user_axis_rst_n),
//本地同步时钟                
    .iv_local_cnt  (64'b0),
//报文分组数据接收接口
    .s_axis_tready(csce2cpuoe_axis_tready),
    .s_axis_tvalid(csce2cpuoe_axis_tvalid),
    .s_axis_tkeep (csce2cpuoe_axis_tkeep ),
    .s_axis_tdata (csce2cpuoe_axis_tdata ),
    .s_axis_tlast (csce2cpuoe_axis_tlast ),
    .s_axis_tuser (csce2cpuoe_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(m_cpu_axis_tready),
    .m_axis_tvalid(m_cpu_axis_tvalid),
    .m_axis_tkeep (m_cpu_axis_tkeep ),
    .m_axis_tdata (m_cpu_axis_tdata ),
    .m_axis_tlast (m_cpu_axis_tlast ),
    .m_axis_tuser (m_cpu_axis_tuser ),
//遥测数据输出接口
    .m_tm_axis_tready(1'b0),
    .m_tm_axis_tvalid(),
    .m_tm_axis_tdata (),
//统计信息
    .ov_send_pkt_cnt(wv_cpu_send_pkt_cnt),
    .ov_send_tm_cnt (wv_cpu_send_tm_cnt )
);

CPUSchCtrlEngine #(
    .PORT_SUM(PORT_SUM),
    .THREAD_SUM(THREAD_SUM),
    .Mbus_ID(Mbus_ID),
    .VERSION(VERSION)
)
CPUSCE_Inst(
//时钟复位信号
    .axis_clk  (user_axis_clk  ),
    .axis_rst_n(user_axis_rst_n),
    .hcp_clk   (hcp_clk  ),
    .hcp_rst_n (hcp_rst_n),
//主机数据输入接口    
    .s_host_axis_tready(cpuie2csce_axis_tready),
    .s_host_axis_tvalid(cpuie2csce_axis_tvalid),
    .s_host_axis_tkeep (cpuie2csce_axis_tkeep ),
    .s_host_axis_tdata (cpuie2csce_axis_tdata ),
    .s_host_axis_tlast (cpuie2csce_axis_tlast ),
    .s_host_axis_tuser (cpuie2csce_axis_tuser ),
//主机数据输出接口                     
    .m_host_axis_tready(csce2cpuoe_axis_tready),
    .m_host_axis_tvalid(csce2cpuoe_axis_tvalid),
    .m_host_axis_tkeep (csce2cpuoe_axis_tkeep ),
    .m_host_axis_tdata (csce2cpuoe_axis_tdata ),
    .m_host_axis_tlast (csce2cpuoe_axis_tlast ),
    .m_host_axis_tuser (csce2cpuoe_axis_tuser ),
//网络数据输入接口            
    .s_netw_axis_tready(fsm2csce_axis_tready),
    .s_netw_axis_tvalid(fsm2csce_axis_tvalid),
    .s_netw_axis_tkeep (fsm2csce_axis_tkeep ),
    .s_netw_axis_tdata (fsm2csce_axis_tdata ),
    .s_netw_axis_tlast (fsm2csce_axis_tlast ),
    .s_netw_axis_tuser (fsm2csce_axis_tuser ),
//网络数据输出接口                 
    .m_netw_axis_tready(csce2fsm_axis_tready),
    .m_netw_axis_tvalid(csce2fsm_axis_tvalid),
    .m_netw_axis_tkeep (csce2fsm_axis_tkeep ),
    .m_netw_axis_tdata (csce2fsm_axis_tdata ),
    .m_netw_axis_tlast (csce2fsm_axis_tlast ),
    .m_netw_axis_tuser (csce2fsm_axis_tuser ),
//配置管理接口            
    .m_lb_cs_n (csce_lb_cs_n ),
    .m_lb_ack_n(csce_lb_ack_n),
    .m_lb_wr_rd(csce_lb_wr_rd),
    .m_lb_addr (csce_lb_addr ),
    .m_lb_wdata(csce_lb_wdata),
    .m_lb_rdata(csce_lb_rdata),
//状态输出信号    
    .ov_cpu_loadstate(wv_cpu_loadstate),
//配置参数信号
    .ov_local_mac       (wv_local_mac),
    .ov_perip_mac       (wv_perip_mac),
    .ov_meter_mac       (wv_meter_mac),
    .ov_local_ip        (wv_local_ip ),
    .ov_meter_ip        (wv_meter_ip ),
    .ov_local_srv6_opbit(wv_local_srv6_opbit),
    .o_soft_rst_n       (o_soft_rst_n),
//统计信号
    .iv_port_rcv_allpkt_cnt (wv_port_rcv_allpkt_cnt ),
    .iv_port_rcv_filtpkt_cnt(wv_port_rcv_filtpkt_cnt),
    .iv_port_rcv_discpkt_cnt(wv_port_rcv_discpkt_cnt),
    .iv_port_rcv_tm_cnt     (wv_port_rcv_tm_cnt     ),
    .iv_port_send_pkt_cnt   (wv_port_send_pkt_cnt   ),
    .iv_port_send_tm_cnt    (wv_port_send_tm_cnt    ),
                             
    .iv_cpu_rcv_allpkt_cnt  (wv_cpu_rcv_allpkt_cnt  ),
    .iv_cpu_rcv_filtpkt_cnt (wv_cpu_rcv_filtpkt_cnt ),
    .iv_cpu_rcv_discpkt_cnt (wv_cpu_rcv_discpkt_cnt ),
    .iv_cpu_rcv_tm_cnt      (wv_cpu_rcv_tm_cnt      ),
    .iv_cpu_send_pkt_cnt    (wv_cpu_send_pkt_cnt    ),
    .iv_cpu_send_tm_cnt     (wv_cpu_send_tm_cnt     )
);

FastSwitchModule#(
    .PORT_SUM(PORT_SUM),
    .ENT_SUM (16)
)
FastSwitchModule_Inst(
//时钟复位信号
    .axis_clk   (user_axis_clk  ),
    .axis_rst_n (user_axis_rst_n),
//报文分组数据接收接口
    .s_axis_tready({ntme2fsm_axis_tready,srfe2fsm_axis_tready,csce2fsm_axis_tready,srie2fsm_axis_tready}),
    .s_axis_tvalid({ntme2fsm_axis_tvalid,srfe2fsm_axis_tvalid,csce2fsm_axis_tvalid,srie2fsm_axis_tvalid}),
    .s_axis_tkeep ({ntme2fsm_axis_tkeep ,srfe2fsm_axis_tkeep ,csce2fsm_axis_tkeep ,srie2fsm_axis_tkeep }),
    .s_axis_tdata ({ntme2fsm_axis_tdata ,srfe2fsm_axis_tdata ,csce2fsm_axis_tdata ,srie2fsm_axis_tdata }),
    .s_axis_tlast ({ntme2fsm_axis_tlast ,srfe2fsm_axis_tlast ,csce2fsm_axis_tlast ,srie2fsm_axis_tlast }),
    .s_axis_tuser ({ntme2fsm_axis_tuser ,srfe2fsm_axis_tuser ,csce2fsm_axis_tuser ,srie2fsm_axis_tuser }),
//分组数据输出接口 
    .m_axis_tready({fsm2srfe_axis_tready,fsm2csce_axis_tready,fsm2tsse_axis_tready}),
    .m_axis_tvalid({fsm2srfe_axis_tvalid,fsm2csce_axis_tvalid,fsm2tsse_axis_tvalid}),
    .m_axis_tkeep ({fsm2srfe_axis_tkeep ,fsm2csce_axis_tkeep ,fsm2tsse_axis_tkeep }),
    .m_axis_tdata ({fsm2srfe_axis_tdata ,fsm2csce_axis_tdata ,fsm2tsse_axis_tdata }),
    .m_axis_tlast ({fsm2srfe_axis_tlast ,fsm2csce_axis_tlast ,fsm2tsse_axis_tlast }),
    .m_axis_tuser ({fsm2srfe_axis_tuser ,fsm2csce_axis_tuser ,fsm2tsse_axis_tuser }),
//配置管理接口
    .s_lb_cs_n    (fsm_lb_cs_n ),
    .s_lb_ack_n   (fsm_lb_ack_n),
    .s_lb_wr_rd   (fsm_lb_wr_rd),
    .s_lb_addr    (fsm_lb_addr ),
    .s_lb_wdata   (fsm_lb_wdata),
    .s_lb_rdata   (fsm_lb_rdata),
//配置寄存器
    .iv_local_srv6_opbit(wv_local_srv6_opbit)
);

TransShapSchEngine#(
    .PORT_SUM(PORT_SUM)
)
TSSE_Inst(
//时钟复位信号
    .axis_clk  (user_axis_clk  ),
    .axis_rst_n(user_axis_rst_n),
//分组数据输入接口
    .s_axis_tready(fsm2tsse_axis_tready),
    .s_axis_tvalid(fsm2tsse_axis_tvalid),
    .s_axis_tkeep (fsm2tsse_axis_tkeep ),
    .s_axis_tdata (fsm2tsse_axis_tdata ),
    .s_axis_tlast (fsm2tsse_axis_tlast ),
    .s_axis_tuser (fsm2tsse_axis_tuser ),
//分组数据输出接口
    .m_axis_tready(tsse2sroe_axis_tready),
    .m_axis_tvalid(tsse2sroe_axis_tvalid),
    .m_axis_tkeep (tsse2sroe_axis_tkeep ),
    .m_axis_tdata (tsse2sroe_axis_tdata ),
    .m_axis_tlast (tsse2sroe_axis_tlast ),
    .m_axis_tuser (tsse2sroe_axis_tuser ),
//配置管理接口   
    .s_lb_cs_n    (tsse_lb_cs_n_reg ),
    .s_lb_ack_n   (tsse_lb_ack_n_reg),
    .s_lb_wr_rd   (tsse_lb_wr_rd_reg),
    .s_lb_addr    (tsse_lb_addr_reg ),
    .s_lb_wdata   (tsse_lb_wdata_reg),
    .s_lb_rdata   (tsse_lb_rdata_reg)
);

SRv6FwdEngine SRv6FwdEngine_Inst(  
    .axis_clk             (user_axis_clk  ),
    .axis_rst_n           (user_axis_rst_n),
    
    .s_axis_tready        (fsm2srfe_axis_tready),
    .s_axis_tvalid        (fsm2srfe_axis_tvalid),
    .s_axis_tkeep         (fsm2srfe_axis_tkeep ),
    .s_axis_tdata         (fsm2srfe_axis_tdata ),
    .s_axis_tlast         (fsm2srfe_axis_tlast ),
    .s_axis_tuser         (fsm2srfe_axis_tuser ),
                          
    .m_axis_tready        (srfe2fsm_axis_tready),
    .m_axis_tvalid        (srfe2fsm_axis_tvalid),
    .m_axis_tkeep         (srfe2fsm_axis_tkeep ),
    .m_axis_tdata         (srfe2fsm_axis_tdata ),
    .m_axis_tlast         (srfe2fsm_axis_tlast ),
    .m_axis_tuser         (srfe2fsm_axis_tuser ),
    
    .iv_smac_addr         (wv_local_mac),
    .iv_dmac_addr         (wv_perip_mac)
);


NetTelMeterEngine#(
    .THREAD_SUM    (THREAD_SUM),
    .TM_SUM        (PORT_SUM*2),
    .LOCAL_CNT_STEP(SRC_STEP),
    .DATA_BYTE     (16)
)NTME_Inst(
    .s_axis_clk      ({m_baser_axis_clk,m_sgmii_axis_clk,{PORT_SUM{user_axis_clk}}}),   
    .s_axis_rst_n    ({m_baser_axis_rst_n,m_sgmii_axis_rst_n,{PORT_SUM{user_axis_rst_n}}}),
                     
    .m_axis_clk      (user_axis_clk  ),   
    .m_axis_rst_n    (user_axis_rst_n),
                     
    .s_tm_axis_tready({sroe2ntme_tm_axis_tready,srie2ntme_tm_axis_tready}),
    .s_tm_axis_tvalid({sroe2ntme_tm_axis_tvalid,srie2ntme_tm_axis_tvalid}),
    .s_tm_axis_tdata ({sroe2ntme_tm_axis_tdata ,srie2ntme_tm_axis_tdata }),
                     
    .m_axis_tready   (ntme2fsm_axis_tready),
    .m_axis_tvalid   (ntme2fsm_axis_tvalid),
    .m_axis_tkeep    (ntme2fsm_axis_tkeep ),
    .m_axis_tdata    (ntme2fsm_axis_tdata ),
    .m_axis_tlast    (ntme2fsm_axis_tlast ),
    .m_axis_tuser    (ntme2fsm_axis_tuser ),

    .iv_cpu_loadstate(wv_cpu_loadstate),
    .iv_smac_addr    (wv_local_mac),
    .iv_dmac_addr    (wv_meter_mac),

    .iv_sip_addr     (wv_local_ip),
    .iv_dip_addr     (wv_meter_ip),
    
    .ov_local_cnt    (wv_local_cnt)
);
endmodule
/*
DN_NewNP_Core #(
    .VERSION  (32'h22_1004_01),//8bit年后2位+16bit月日+8bit版本号
    .THREAD_SUM  (4),
    .SGMII_SUM(4),
    .BASER_SUM(1),
    .CPU_BYTE (1),
    .Mbus_ID  (1),
    
    .SRC_STEP      (32'h8_0000),
    .SGMII_DST_STEP(32'h8_0000),
    .BASER_DST_STEP(32'h6_6667),
    .INIT_DLY      ( 3),//应当大于src_clk和dst_clk之间的倍率
    .TIME_WIDTH    (64)
)
DN_NewNP_Core_Inst(                  
    .s_cpu_axis_clk  (),   
    .s_cpu_axis_rst_n(),

    .m_cpu_axis_clk  (),   
    .m_cpu_axis_rst_n(),
    
    .s_sgmii_axis_clk  (),   
    .s_sgmii_axis_rst_n(),
    
    .m_sgmii_axis_clk  (),   
    .m_sgmii_axis_rst_n(),
    
    .s_baser_axis_clk  (),   
    .s_baser_axis_rst_n(),
    
    .m_baser_axis_clk  (),   
    .m_baser_axis_rst_n(),
    
    .user_axis_clk  (),   
    .user_axis_rst_n(),
    
    .hcp_clk  (),
    .hcp_rst_n(),
//CPU分分组数据接收接口
    .s_cpu_axis_tready(),
    .s_cpu_axis_tvalid(),
    .s_cpu_axis_tkeep (),
    .s_cpu_axis_tdata (),
    .s_cpu_axis_tlast (),
    .s_cpu_axis_tuser (),
//CPU分数据输出接口                  
    .m_cpu_axis_tready(),
    .m_cpu_axis_tvalid(),
    .m_cpu_axis_tkeep (),
    .m_cpu_axis_tdata (),
    .m_cpu_axis_tlast (),
    .m_cpu_axis_tuser (),
//SGMII分组数据接收接口
    .s_sgmii_axis_tready(),
    .s_sgmii_axis_tvalid(),
    .s_sgmii_axis_tkeep (),
    .s_sgmii_axis_tdata (),
    .s_sgmii_axis_tlast (),
    .s_sgmii_axis_tuser (),
//SGMII数据输出接口
    .m_sgmii_axis_tready(),
    .m_sgmii_axis_tvalid(),
    .m_sgmii_axis_tkeep (),
    .m_sgmii_axis_tdata (),
    .m_sgmii_axis_tlast (),
    .m_sgmii_axis_tuser (),
//BASE-R分组数据接收接口
    .s_baser_axis_tready(),
    .s_baser_axis_tvalid(),
    .s_baser_axis_tkeep (),
    .s_baser_axis_tdata (),
    .s_baser_axis_tlast (),
    .s_baser_axis_tuser (),
//SGMII数据输出接口           
    .m_baser_axis_tready(),
    .m_baser_axis_tvalid(),
    .m_baser_axis_tkeep (),
    .m_baser_axis_tdata (),
    .m_baser_axis_tlast (),
    .m_baser_axis_tuser (),

    .o_soft_rst_n()
);
*/