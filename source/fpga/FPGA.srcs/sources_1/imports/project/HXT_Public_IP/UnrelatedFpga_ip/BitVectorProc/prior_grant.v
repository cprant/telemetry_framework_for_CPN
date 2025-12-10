////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2016-2030 C2Comm, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
/*
Vendor: C2Comm
Version: 1.0
Filename: prior_grant.v
Target Device: All
Dscription: 
    1)可参数化，通过修改参数可支持任意数量请求的调度
    2)支持每个周期实现1次有效调度
    3)支持用户配置特定优先级
    4)优先级约束条件依次为
        用户配置优先级>上一次的被选中的前缀掩码优先级
    5)通过PRIOR_LOW_OR_HIGH可支持优先级按bit位从低到高或从高到底  

Author : 刘晓骏
Revision List:
	rn1:1.1 date:20200514 modifier:lxj 
	description:
		last_grant_prior在get==1时，应当赋值为grant_prior，而不是保持原值
	
	rn2:	date:	modifier:	description:
*/
module prior_grant #(
    parameter GRANT_WIDTH = 8,
              PRIOR_LOW_OR_HIGH = 0
)(
    input wire                    clk,
    input wire                    rst_n,
               
    input wire  [GRANT_WIDTH-1:0] req,
               
    input wire                    get,
               
    input wire  [GRANT_WIDTH-1:0] fix_prior,
               
    output wire [GRANT_WIDTH-1:0] grant_prior
);
/*//////////////////////////////////////////////////////////
                    中间变量声明区域
*///////////////////////////////////////////////////////////
//本模块中所有中间变量(wire/reg/parameter)在此集中声明 
reg  [GRANT_WIDTH-1:0] last_grant_prior;

//将onehot编码变成prefix编码(prefix_bit)，用来作为掩码
//例如，5’b00100将会变为5’b11000。
wire [GRANT_WIDTH-1:0] prefix_prior;  

reg  [GRANT_WIDTH-1:0] select_req;  
//***************************************************
//                优先级处理
//***************************************************
//缓存上一次分配的优先级
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        last_grant_prior <= {GRANT_WIDTH{1'b0}};
    end
    else begin
        if(get == 1'b1) begin
            last_grant_prior <= grant_prior;//modify by lxj 20200514
        end
        else begin
            last_grant_prior <= last_grant_prior;
        end
    end
end

//优先级选择
always @* begin
    if((|(prefix_prior & fix_prior & req)) == 1'b1)
    //同时满足prefix_prior/fix_prior/req后还有可分配的bit，即可以从其结果中选择优先级
        select_req = prefix_prior & fix_prior & req;
    else if((|(prefix_prior & req)) == 1'b1)
    //退而求其次，同时满足prefix_prior/req后还有可分配的bit
        select_req = prefix_prior & req; 
    else if((|(fix_prior & req)) == 1'b1)
    //退而求其次，fix_prior/req后还有可分配的bit
        select_req = fix_prior & req; 
    else//只能选择req
        select_req = req;
end


/*//////////////////////////////////////////////////////////
                   IP调用区域
*///////////////////////////////////////////////////////////
//本模块调用的所有IP在该区域实例化
//例如fifo/ram/grant之类的IP.... 
onehot2prepostfix #(
    .PRE_OR_POST(PRIOR_LOW_OR_HIGH),
    //优先级从低到高用postfix，从高到底则用prefix
    .INCLUDE_SELF(0),
    .WIDTH(GRANT_WIDTH)
)onehot2prepostfix_inst(
    .i_onehot(last_grant_prior),
    .o_ppfix(prefix_prior)
);

bitmap2onehot #(
    .PRIOR_LOW_OR_HIGH(PRIOR_LOW_OR_HIGH),
    .WIDTH(GRANT_WIDTH)
)bitmap2onehot_inst(
    .i_bitmap(select_req),
    .o_onehot(grant_prior)
);
endmodule
/*
prior_grant #(
    .GRANT_WIDTH(),
    .PRIOR_LOW_OR_HIGH()
)prior_grant_inst(
    .clk(),
    .rst_n(),
    
    .req(),
    
    .get(),
    
    .fix_prior(),
    
    .grant_prior()
);
*/