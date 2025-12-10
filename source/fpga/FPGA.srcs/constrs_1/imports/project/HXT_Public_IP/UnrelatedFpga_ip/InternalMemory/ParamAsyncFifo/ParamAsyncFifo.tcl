#Xilinx版本下的约束命令
proc vivado_sdc_asyncfifo {} {
    #定位找到所有ParamAsyncFifo模块对应的实例化实体
    foreach asyncfifo_inst [get_cells -hier -filter {(ORIG_REF_NAME == ParamAsyncFifo || REF_NAME == ParamAsyncFifo)}] {
        puts "Inserting timing constraints for ParamAsyncFifo instance $asyncfifo_inst"
        puts "$asyncfifo_inst"
        
        #获取读时钟和写时钟,并选择最小周期
        set read_clk  [get_clocks -of_objects [get_pins $asyncfifo_inst/sdpram_raddr_reg[0]/C]]
        set write_clk [get_clocks -of_objects [get_pins $asyncfifo_inst/sdpram_waddr_reg[0]/C]]
        if {($read_clk != $write_clk) && ($read_clk > 0) && ($write_clk > 0)} {
			set read_clk_period  [get_property -min PERIOD $read_clk]
			set write_clk_period [get_property -min PERIOD $write_clk]

			set min_clk_period [expr $read_clk_period < $write_clk_period ? $read_clk_period : $write_clk_period]
			
			#获取读写指针的格雷码寄存器，将二者跨时钟域的部分用max_delay和bus_skew截断
			if {([llength [get_cells $asyncfifo_inst/raddr_gray_reg_reg[*]]] > 0) && ([llength [get_cells $asyncfifo_inst/raddr_gray_wrclksync_reg[0][*]]] > 0)} {
				puts "set_max_delay raddr_gray_reg_reg to raddr_gray_wrclksync_reg"
				set_max_delay -from [get_cells $asyncfifo_inst/raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst/raddr_gray_wrclksync_reg[0][*]] -datapath_only $read_clk_period
				set_bus_skew  -from [get_cells $asyncfifo_inst/raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst/raddr_gray_wrclksync_reg[0][*]] $min_clk_period
			}
			
			if {([llength [get_cells $asyncfifo_inst/waddr_gray_reg_reg[*]]] > 0) && ([llength [get_cells $asyncfifo_inst/waddr_gray_rdclksync_reg[0][*]]] > 0)} {
				puts "set_max_delay waddr_gray_reg_reg to waddr_gray_rdclksync_reg"
				set_max_delay -from [get_cells $asyncfifo_inst/waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst/waddr_gray_rdclksync_reg[0][*]] -datapath_only $write_clk_period
				set_bus_skew  -from [get_cells $asyncfifo_inst/waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst/waddr_gray_rdclksync_reg[0][*]] $min_clk_period
			}
		}
    }
}

proc quartus_sdc_asyncfifo {} {
    #定位找到所有ParamAsyncFifo模块对应的实例化实体
    foreach asyncfifo_inst [get_entity_instances ParamAsyncFifo] {
        puts "Inserting timing constraints for ParamAsyncFifo instance $asyncfifo_inst"
        #获取读指针的格雷码寄存器，将二者跨时钟域的部分用max_delay和bus_skew截断
        # control skew for bits
        set_max_skew  -from [get_cells $asyncfifo_inst|raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg[0][*]] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
        # path delay (exception for net delay)
        set_net_delay -from [get_cells $asyncfifo_inst|raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg[0][*]] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        # mstable delay
        set_net_delay -from [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg*] -to [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg*] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        
        #relax setup and hold calculation
        set_max_delay -from [get_cells $asyncfifo_inst|raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg[0][*]] 100
        set_min_delay -from [get_cells $asyncfifo_inst|raddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|raddr_gray_wrclksync_reg[0][*]] -100
        
        #获取读指针的格雷码寄存器，将二者跨时钟域的部分用max/min_delay和max/net_skew截断
        # control skew for bits
        set_max_skew -from [get_cells $asyncfifo_inst|waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg[0][*]] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
        # path delay (exception for net delay)
        set_net_delay -from [get_cells $asyncfifo_inst|waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg[0][*]] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        # mstable delay
        set_net_delay -from [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg*] -to [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg*] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8
        #relax setup and hold calculation
        set_max_delay -from [get_cells $asyncfifo_inst|waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg[0][*]] 100
        set_min_delay -from [get_cells $asyncfifo_inst|waddr_gray_reg_reg[*]] -to [get_cells $asyncfifo_inst|waddr_gray_rdclksync_reg[0][*]] -100

    }
}

#通过vivado特有的版本命令提取编译软件的关键字
set ide_name [help]
if {[string match *quartus* $ide_name]} {
    quartus_sdc_asyncfifo
} else {
   vivado_sdc_asyncfifo
}

