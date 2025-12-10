#Xilinx版本下的约束命令
proc vivado_sdc_ram {} {
    #定位找到所有ParamSdpram模块对应的实例化实体
    foreach ram_inst [get_cells -hier -filter {(ORIG_REF_NAME == ParamSdpram || REF_NAME == ParamSdpram)}] {
        puts "Inserting timing constraints for ParamSdpram instance $ram_inst"
        
        #获取读时钟和写时钟,
        set read_clk  [get_clocks -of_objects [get_pins $ram_inst/rdata_reg[0]/C]]
		#仅考虑分布式RAM在异步模式下的读写时钟隔离，Block RAM编译软件会自动隔离读写时钟
        set write_clk [get_clocks -of_objects [get_pins $ram_inst/ram_mem_reg*/WCLK]]
		
		if {($read_clk != $write_clk) && ($read_clk > 0) && ($write_clk > 0)} {
			set_false_path -from $write_clk -to [get_cells "$ram_inst/rdata_reg[*]"]
        }
    }
}

proc quartus_sdc_ram {} {
    puts "Quartus ParamSdpram Do nothing"
}

#通过vivado特有的版本命令提取编译软件的关键字
set ide_name [help]
if {[string match *quartus* $ide_name]} {
    quartus_sdc_ram
} else {
   vivado_sdc_ram
}

