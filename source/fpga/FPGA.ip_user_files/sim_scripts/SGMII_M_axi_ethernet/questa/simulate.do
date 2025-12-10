onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib SGMII_M_axi_ethernet_opt

do {wave.do}

view wave
view structure
view signals

do {SGMII_M_axi_ethernet.udo}

run -all

quit -force
