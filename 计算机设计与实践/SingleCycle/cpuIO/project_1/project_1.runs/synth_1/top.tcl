# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param tcl.collectionResultDisplayLimit 0
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tfgg484-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.cache/wt [current_project]
set_property parent.project_path C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.xpr [current_project]
set_property XPM_LIBRARIES XPM_CDC [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo c:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files -quiet C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/synthesized_ip/dram/dram.dcp
set_property used_in_implementation false [get_files C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/synthesized_ip/dram/dram.dcp]
add_files -quiet C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/synthesized_ip/prgrom/prgrom.dcp
set_property used_in_implementation false [get_files C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/synthesized_ip/prgrom/prgrom.dcp]
read_verilog -library xil_defaultlib {
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/alu.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/comp.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/control.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/cpu.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/display.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/divider.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/iosel.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/mux.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/npc.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/pc.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/rf.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/sext.v
  C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/new/top.v
}
read_ip -quiet C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/ip/cpuclk/cpuclk.xci
set_property used_in_implementation false [get_files -all c:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/ip/cpuclk/cpuclk_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/ip/cpuclk/cpuclk.xdc]
set_property used_in_implementation false [get_files -all c:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/sources_1/ip/cpuclk/cpuclk_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/constrs_1/new/pin.xdc
set_property used_in_implementation false [get_files C:/Users/lenovo/Downloads/22_7_7_SingleCycle/SingleCycle/cpuIO/CPU_Project.srcs/constrs_1/new/pin.xdc]

set_param ips.enableIPCacheLiteLoad 1
close [open __synthesis_is_running__ w]

synth_design -top top -part xc7a100tfgg484-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_utilization_synth.rpt -pb top_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
