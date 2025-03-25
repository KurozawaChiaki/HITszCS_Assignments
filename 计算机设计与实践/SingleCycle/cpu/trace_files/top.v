`timescale 1ns / 1ps

module top(
    input clk,
    input rst_n,
    output        debug_wb_have_inst,   // WB阶段是否有指令 (对单周期CPU，此flag恒为1)
    output [31:0] debug_wb_pc,          // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
    output        debug_wb_ena,         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
    output [4:0]  debug_wb_reg,         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output [31:0] debug_wb_value        // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
);

wire [31:0] inst;
wire [31:0] dm_rd;
wire [31:0] pc;
wire [31:0] alu_c;
wire dram_we;
wire ram_clk;
assign ram_clk = ~clk;
wire [31:0] rf_rD2;

cpu mini_rv_u (
    .clk(clk),
    .rst_n(rst_n),
    .inst(inst),
    .dm_rd(dm_rd),
    .pc(pc),
    .alu_c(alu_c),
    .dram_we(dram_we),
    .rf_rD2(rf_rD2),
    .debug_wb_ena(debug_wb_ena),
    .debug_wb_have_inst(debug_wb_have_inst),
    .debug_wb_pc(debug_wb_pc),
    .debug_wb_reg(debug_wb_reg),
    .debug_wb_value(debug_wb_value)
);
// 下面两个模块，只需要实例化并连线，不需要添加文件
inst_mem imem(
    .a(pc[15:2]),
    .spo(inst)
);

data_mem dmem(
    .clk(ram_clk),
    .we(dram_we),
    .a(alu_c[15:2]),
    .d(rf_rD2),
    .spo(dm_rd)
);
endmodule
