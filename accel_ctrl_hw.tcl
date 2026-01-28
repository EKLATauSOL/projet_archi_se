package require -exact qsys 16.1

# 
# module accel_ctrl
# 
set_module_property DESCRIPTION "Accelerometer ADXL345 Interface"
set_module_property NAME accel_ctrl
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME accel_ctrl
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false

# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL accel_ctrl
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file accel_ctrl.vhd VHDL PATH peripherique/accel_ctrl.vhd TOP_LEVEL_FILE

# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset reset Input 1


# 
# connection point avs (Avalon MM Slave)
# 
add_interface avs avalon end
set_interface_property avs addressUnits WORDS
set_interface_property avs associatedClock clock
set_interface_property avs associatedReset reset
set_interface_property avs bitsPerSymbol 8
set_interface_property avs burstOnBurstBoundariesOnly false
set_interface_property avs burstcountUnits WORDS
set_interface_property avs explicitAddressSpan 0
set_interface_property avs holdTime 0
set_interface_property avs linewrapBursts false
set_interface_property avs maximumPendingReadTransactions 0
set_interface_property avs maximumPendingWriteTransactions 0
set_interface_property avs readLatency 1
set_interface_property avs readWaitTime 1
set_interface_property avs setupTime 0
set_interface_property avs timingUnits Cycles
set_interface_property avs writeWaitTime 0
set_interface_property avs ENABLED true
set_interface_property avs EXPORT_OF ""
set_interface_property avs PORT_NAME_MAP ""
set_interface_property avs CMSIS_SVD_VARIABLES ""
set_interface_property avs SVD_ADDRESS_GROUP ""

add_interface_port avs avs_address address Input 2
add_interface_port avs avs_read read Input 1
add_interface_port avs avs_write write Input 1
add_interface_port avs avs_writedata writedata Input 32
add_interface_port avs avs_readdata readdata Output 32
add_interface_port avs avs_waitrequest waitrequest Output 1
set_interface_assignment avs embeddedsw.configuration.isFlash 0
set_interface_assignment avs embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avs embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avs embeddedsw.configuration.isPrintableDevice 0


# 
# connection point accel (Conduit)
# 
add_interface accel conduit end
set_interface_property accel associatedClock clock
set_interface_property accel associatedReset ""
set_interface_property accel ENABLED true
set_interface_property accel EXPORT_OF ""
set_interface_property accel PORT_NAME_MAP ""
set_interface_property accel CMSIS_SVD_VARIABLES ""
set_interface_property accel SVD_ADDRESS_GROUP ""

add_interface_port accel GSENSOR_CS_N gsensor_cs_n Output 1
add_interface_port accel GSENSOR_SCLK gsensor_sclk Output 1
add_interface_port accel GSENSOR_SDI gsensor_sdi Output 1
add_interface_port accel GSENSOR_SDO gsensor_sdo Input 1
