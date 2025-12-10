/*---------------------------------------------------------------------
    Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
-----------------------------------------------------------------------

Vendor C2Comm
Version 1.0
Filename  AXISDisp.v
Target Device All
Dscription 
    1)支持多路AXI Stream接口分派转发
    2)根据tdst信号进行端口选择
    3)仅支持bitmap形式转发

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


Author : cb
Revision List:
    rn2:    date:   modifier:   description:
    rn2:    date:   modifier:   description:
*/

module AXISDisp#(
    parameter STREAM_SUM = 8,//支持分派的的AXIStream流数量
              DATA_BYTE  = 8,
              USER_BIT   = 1
)(
//时钟复位信号
    input  wire                              s_axis_clk,
    input  wire                              s_axis_rst_n,
//报文分组数据接收接口
    output wire                              s_axis_tready,
    input  wire                              s_axis_tvalid,
    input  wire [             DATA_BYTE-1:0] s_axis_tkeep,
    input  wire [           DATA_BYTE*8-1:0] s_axis_tdata,
    input  wire                              s_axis_tlast,
    input  wire [              USER_BIT-1:0] s_axis_tuser,
    input  wire [            STREAM_SUM-1:0] s_axis_tdst,
//BE分组数据输出接口
    input  wire [            STREAM_SUM-1:0] m_axis_tready,
    output wire [            STREAM_SUM-1:0] m_axis_tvalid,
    output wire [  STREAM_SUM*DATA_BYTE-1:0] m_axis_tkeep,
    output wire [STREAM_SUM*DATA_BYTE*8-1:0] m_axis_tdata,
    output wire [            STREAM_SUM-1:0] m_axis_tlast,
    output wire [   STREAM_SUM*USER_BIT-1:0] m_axis_tuser
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
wire                           int_axis_tready;
wire                           int_axis_tvalid;
wire                           int_axis_tlast;
wire [STREAM_SUM+USER_BIT-1:0] int_axis_tuser;
wire [          DATA_BYTE-1:0] int_axis_tkeep;
wire [        DATA_BYTE*8-1:0] int_axis_tdata;
              
wire [         STREAM_SUM-1:0] glb_m_axis_tready;
reg  [         STREAM_SUM-1:0] glb_m_axis_tvalid;
reg                            glb_m_axis_tlast;
reg  [           USER_BIT-1:0] glb_m_axis_tuser;
reg  [          DATA_BYTE-1:0] glb_m_axis_tkeep;
reg  [        DATA_BYTE*8-1:0] glb_m_axis_tdata;

/*/////////////////////////////////////
           数据分类输出
*//////////////////////////////////////
assign int_axis_tready = ((glb_m_axis_tready & int_axis_tuser[STREAM_SUM-1:0]) == int_axis_tuser[STREAM_SUM-1:0]);

always @* begin
    glb_m_axis_tvalid = ((int_axis_tvalid == 1'b1) && (int_axis_tready == 1'b1)) ? int_axis_tuser[STREAM_SUM-1:0] : {STREAM_SUM{1'd0}};
    glb_m_axis_tlast  = int_axis_tlast;
    glb_m_axis_tuser  = int_axis_tuser[STREAM_SUM +: USER_BIT];
    glb_m_axis_tkeep  = int_axis_tkeep;
    glb_m_axis_tdata  = int_axis_tdata;
end

/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
AXISRegBuf#(            
    .PROMODE_EN             ( 1                     ),
    .DATA_BYTE              ( DATA_BYTE             ),
    .USER_BIT               ( STREAM_SUM+USER_BIT   )
)SAXISRegBuf_Inst(           
//时钟复位信号            
    .axis_clk               ( s_axis_clk            ),
    .axis_rst_n             ( s_axis_rst_n          ),
//AXI Stream输入接口            
    .s_axis_tready          ( s_axis_tready         ),
    .s_axis_tvalid          ( s_axis_tvalid         ),
    .s_axis_tkeep           ( s_axis_tkeep          ),
    .s_axis_tdata           ( s_axis_tdata          ),
    .s_axis_tlast           ( s_axis_tlast          ),
    .s_axis_tuser           ( {s_axis_tuser,s_axis_tdst}),

//AXI Stream输出接口                
    .m_axis_tready          ( int_axis_tready       ),
    .m_axis_tvalid          ( int_axis_tvalid       ),
    .m_axis_tkeep           ( int_axis_tkeep        ),
    .m_axis_tdata           ( int_axis_tdata        ),
    .m_axis_tlast           ( int_axis_tlast        ),
    .m_axis_tuser           ( int_axis_tuser        )
); 

generate
    genvar i;
    for(i=0;i<STREAM_SUM;i=i+1) begin:RegBuffer
        AXISRegBuf#(                             
            .PROMODE_EN         ( 1                     ),
            .DATA_BYTE          ( DATA_BYTE             ),                      
            .USER_BIT           ( USER_BIT              )                        
        )AXISRegBuf_Inst0(                           
        //时钟复位信号                             
            .axis_clk           ( s_axis_clk              ),               
            .axis_rst_n         ( s_axis_rst_n            ),             
        //AXI Stream输入接口                      
            .s_axis_tready      ( glb_m_axis_tready[i]  ),
            .s_axis_tvalid      ( glb_m_axis_tvalid[i]  ),
            .s_axis_tkeep       ( glb_m_axis_tkeep      ),    
            .s_axis_tdata       ( glb_m_axis_tdata      ),    
            .s_axis_tlast       ( glb_m_axis_tlast      ),    
            .s_axis_tuser       ( glb_m_axis_tuser      ),    
        //AXI Stream输出接口                          
            .m_axis_tready      ( m_axis_tready[i*1 +: 1]                    ),
            .m_axis_tvalid      ( m_axis_tvalid[i*1 +: 1]                    ),
            .m_axis_tkeep       ( m_axis_tkeep [i*DATA_BYTE   +:   DATA_BYTE]),
            .m_axis_tdata       ( m_axis_tdata [i*DATA_BYTE*8 +: DATA_BYTE*8]),
            .m_axis_tlast       ( m_axis_tlast [i*1 +: 1]                    ),
            .m_axis_tuser       ( m_axis_tuser [i*USER_BIT +: USER_BIT]      )     
        );
    end
endgenerate

endmodule

/*
AXISDisp#(
    .STREAM_SUM             (),
    .DATA_BYTE              (),
    .USER_BIT               ()
)(  
    .s_axis_clk             (),
    .s_axis_rst_n           (),
    
    .s_axis_tready          (),
    .s_axis_tvalid          (),
    .s_axis_tkeep           (),
    .s_axis_tdata           (),
    .s_axis_tlast           (),
    .s_axis_tuser           (),
    .s_axis_tdst            (),
    
    .m_axis_tready          (),
    .m_axis_tvalid          (),
    .m_axis_tkeep           (),
    .m_axis_tdata           (),
    .m_axis_tlast           (),
    .m_axis_tuser           ()
);
*/
















