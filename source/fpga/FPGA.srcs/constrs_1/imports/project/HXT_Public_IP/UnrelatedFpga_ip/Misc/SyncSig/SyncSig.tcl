#Xilinx版本下的约束命令
proc vivado_sdc_syncsig {} {
    #定位找到所有SyncSig模块对应的实例化实体
    foreach SyncSig_inst [get_cells -hier -filter {(ORIG_REF_NAME == SyncSig || REF_NAME == SyncSig)}] {
        puts "Inserting timing constraints for SyncSig instance $SyncSig_inst"
        
        #提取SyncSig模块中的同步级联寄存器，并其用ASYNC_REG绑定到1个cell中(Xilinx)
        #set sync_ffs [get_cells -hier -regexp {.*/sig_shift.*\[\d+\]} -filter "PARENT == $SyncSig_inst"]
		set sync_ffs [get_cells "$SyncSig_inst/sig_shift_reg[*]"]

        set_property ASYNC_REG TRUE $sync_ffs
        puts "      Set ASYNC_REG $sync_ffs"
        
        #切断外部输入的异步时钟域单bit信号与同步寄存器之间的时序分析路径
        set_false_path -to [get_pins -of_objects $sync_ffs -filter {NAME =~ *[0]/D}]
        puts "      Set FALSE_PATH to $sync_ffs"
    }
}

proc quartus_sdc_syncsig {} {
    foreach SyncSig_inst [get_entity_instances SyncSig] {
        puts "Inserting timing constraints for SyncSig instance $SyncSig_inst"
        
        #提取SyncSig模块中的同步级联寄存器
        set sync_ffs [get_keepers {$SyncSig_inst|*sig_shift*}]
        
        #切断外部输入的异步时钟域单bit信号与同步寄存器之间的时序分析路径
        puts "      Set FALSE_PATH to $sync_ffs"
        set_net_delay -from {$sync_ffs} -to {$sync_ffs} -max -get_value_from_clock_period min_clock_period -value_multiplier 0.8
        set_false_path -to [get_keepers {$SyncSig_inst|*sig_shift[0]}]
    }
}

#通过vivado特有的版本命令提取编译软件的关键字
set ide_name [help]
if {[string match *quartus* $ide_name]} {
    quartus_sdc_syncsig
} else {
    vivado_sdc_syncsig
}