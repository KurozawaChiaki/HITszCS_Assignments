// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1.1 (win64) Build 3557992 Fri Jun  3 09:58:00 MDT 2022
// Date        : Sat Jul  9 13:02:49 2022
// Host        : AliVe running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               e:/Documents/Code/SoC_Lab/SingleCycle/cpuIO/project_1/project_1.srcs/sources_1/ip/prgrom/prgrom_stub.v
// Design      : prgrom
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tfgg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2022.1.1" *)
module prgrom(a, spo)
/* synthesis syn_black_box black_box_pad_pin="a[13:0],spo[31:0]" */;
  input [13:0]a;
  output [31:0]spo;
endmodule
