#Xilinx版本下的约束命令
proc vivado_sdc_SyncTimeCDC {} {
    #定位找到所有SyncTimeCDC模块对应的实例化实体
    foreach SyncTimeCDC_inst [get_cells -hier -filter {(ORIG_REF_NAME == SyncTimeCDC || REF_NAME == SyncTimeCDC)}] {
        puts "Inserting timing constraints for SyncTimeCDC instance $SyncTimeCDC_inst"
        puts "$SyncTimeCDC_inst"
        
        #获取源时钟和目的时钟,并选择最小周期
        set src_clk  [get_clocks -of_objects [get_pins $SyncTimeCDC_inst/src_update_synctime_reg[*]/C]]
        set dst_clk [get_clocks -of_objects [get_pins $SyncTimeCDC_inst/dst_update_synctime_reg[*]/C]]
        if {($dst_clk != $src_clk) && ($dst_clk > 0) && ($src_clk > 0)} {
			set dst_clk_period  [get_property -min PERIOD $dst_clk]
			set src_clk_period [get_property -min PERIOD $src_clk]
            
            set min_clk_period [expr $dst_clk_period < $src_clk_period ? $dst_clk_period : $src_clk_period]
            #max_delay_val为标记信号打的拍数
            set max_delay_val [expr $src_clk_period + $dst_clk_period]
			#将二者跨时钟域的部分用max_delay和bus_skew截断
            puts "set_max_delay src_update_synctime_reg to dst_update_synctime_reg"
            
            set src_timereg [get_pins $SyncTimeCDC_inst/src_update_synctime_reg[*]/C]
            set dst_timereg [get_pins $SyncTimeCDC_inst/dst_update_synctime_reg[*]/D]
                
            if  {($dst_timereg > 0) && ($src_timereg > 0)} {
                set_max_delay -from $src_timereg -to $dst_timereg -datapath_only $max_delay_val
                set_bus_skew -from $src_timereg -to $dst_timereg $min_clk_period
            }
		}
    }
}

proc quartus_sdc_SyncTimeCDC {} {
    #定位找到所有SyncTimeCDC模块对应的实例化实体
    foreach SyncTimeCDC_inst [get_entity_instances SyncTimeCDC] {
        puts "Inserting timing constraints for SyncTimeCDC instance $SyncTimeCDC_inst"
        #将二者跨时钟域的部分用max_delay和bus_skew截断
        # control skew for bits
        set_max_skew  -from [get_cells $SyncTimeCDC_inst|src_update_synctime[*]] -to [get_cells $SyncTimeCDC_inst|ov_synctime[*]] -get_skew_value_from_clock_period src_clock_period -skew_value_multiplier 0.8
        # path delay (exception for net delay)
        set_net_delay -from [get_cells $SyncTimeCDC_inst|src_update_synctime[*]] -to [get_cells $SyncTimeCDC_inst|ov_synctime[*]] -max -get_value_from_clock_period dst_clock_period -value_multiplier 0.8

        #relax setup and hold calculation
        set_max_delay -from [get_cells $SyncTimeCDC_inst|src_update_synctime[*]] -to [get_cells $SyncTimeCDC_inst|ov_synctime[*]] 100
        set_min_delay -from [get_cells $SyncTimeCDC_inst|src_update_synctime[*]] -to [get_cells $SyncTimeCDC_inst|ov_synctime[*]] -100
    }
}

#通过vivado特有的版本命令提取编译软件的关键字
set ide_name [help]
if {[string match *quartus* $ide_name]} {
    quartus_sdc_SyncTimeCDC
} else {
   vivado_sdc_SyncTimeCDC
}

