`timescale 1ns / 1ps

module cpu(
    input wire clk,
    input wire rst_n,
    input wire [31:0] inst,
    input wire [31:0] dm_rd,
    output wire [31:0] pc,
    output wire [31:0] alu_c,
    output wire dram_we,
    output wire [31:0] rf_rD2,
    output        debug_wb_have_inst,   // WB阶段是否有指令 (对单周期CPU，此flag恒为1)
    output [31:0] debug_wb_pc,          // WB阶段的PC (若wb_have_inst=0，此项可为任意值)
    output        debug_wb_ena,         // WB阶段的寄存器写使能 (若wb_have_inst=0，此项可为任意值)
    output [4:0]  debug_wb_reg,         // WB阶段写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output [31:0] debug_wb_value        // WB阶段写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
    );

    wire [31:0] npc;
    pc PC(
        .clk(clk),
        .rst_n(rst_n),
        .pc_reg(pc),
        .npc(npc)
    );

    wire [31:0] ext;
    wire [31:0] rf_rD1;
    wire npc_op;
    wire [31:0] pc4;
    npc NPC(
        .pc(pc),
        .alu_c(alu_c),
        .npc_op(npc_op),
        .npc(npc),
        .pc4(pc4)
    );

    wire [2:0] sext_op;
    sext sext(
        .din(inst[31:7]),
        .sext_op(sext_op),
        .ext(ext)
    );

    wire [31:0] rf_wd;
    wire [1:0]  wd_sel;
    mux to_wD(
        .a(alu_c),
        .b(pc4),
        .c(ext),
        .d(dm_rd),
        .sel_op(wd_sel),
        .out(rf_wd)
    );

    wire rf_wE;
    rf RF(
        .clk(clk),
        .rst_n(rst_n),
        .rR1(inst[19:15]),
        .rR2(inst[24:20]),
        .rD1(rf_rD1),
        .rD2(rf_rD2),
        .rf_we(rf_wE),
        .wR(inst[11:7]),
        .wD(rf_wd)
    );

    wire [1:0] alua_sel;
    wire [31:0] alu_a;
    mux alu_a_mux(
        .a(rf_rD1),
        .b(pc),
        .sel_op(alua_sel),
        .out(alu_a)
    );

    wire [1:0] alub_sel;
    wire [31:0] alu_b;
    mux alu_b_mux(
        .a(rf_rD2),
        .b(ext),
        .sel_op(alub_sel),
        .out(alu_b)
    );

    wire [2:0] alu_op;
    alu alu(
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .c(alu_c)
    );

    wire BrEq;
    wire BrLt;
    comp comp(
        .a(rf_rD1),
        .b(rf_rD2),
        .BrEq(BrEq),
        .BrLt(BrLt)
    );

    control CU(
        .inst(inst),
        .BrLt(BrLt),
        .BrEq(BrEq),
        .npc_op(npc_op),
        .sext_op(sext_op),
        .alu_op(alu_op),
        .alua_sel(alua_sel),
        .alub_sel(alub_sel),
        .wd_sel(wd_sel),
        .rf_we(rf_wE),
        .dram_we(dram_we)
    );

    assign debug_wb_have_inst = 1;
    assign debug_wb_pc = pc;
    assign debug_wb_ena = rf_wE;
    assign debug_wb_reg = inst[11:7];
    assign debug_wb_value = rf_wd;
endmodule
