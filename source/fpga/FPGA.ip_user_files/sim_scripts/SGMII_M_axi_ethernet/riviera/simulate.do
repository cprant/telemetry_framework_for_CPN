onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+SGMII_M_axi_ethernet -L xil_defaultlib -L xpm -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.SGMII_M_axi_ethernet xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {SGMII_M_axi_ethernet.udo}

run -all

endsim

quit -force
