onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib rgmii_ethernet_mac_m_opt

do {wave.do}

view wave
view structure
view signals

do {rgmii_ethernet_mac_m.udo}

run -all

quit -force
