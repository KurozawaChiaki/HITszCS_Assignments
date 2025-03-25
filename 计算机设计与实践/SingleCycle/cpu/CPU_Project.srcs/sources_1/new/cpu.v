`timescale 1ns / 1ps

module cpu(
    input wire clk,
    input wire rst_n
    );

    wire global_clk;
    cpuclk cpuclk(
        .clk_in1(clk),
        .clk_out1(global_clk)
    );

    wire [31:0] pc;
    wire [31:0] npc;
    pc PC(
        .clk(global_clk),
        .rst_n(rst_n),
        .pc_reg(pc),
        .npc(npc)
    );

    wire [31:0] ext;
    wire [31:0] rf_rD1;
    wire npc_op;
    wire [31:0] pc4;
    wire [31:0] alu_c;
    npc NPC(
        .pc(pc),
        .alu_c(alu_c),
        .npc_op(npc_op),
        .npc(npc),
        .pc4(pc4)
    );

    wire [31:0] inst;
    prgrom IM(
        .a(pc[15:2]),
        .spo(inst)
    );

    wire [2:0] sext_op;
    sext sext(
        .din(inst[31:7]),
        .sext_op(sext_op),
        .ext(ext)
    );

    wire [31:0] dm_rd;
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

    wire [31:0] rf_rD2;
    wire rf_wE;
    rf RF(
        .clk(global_clk),
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

    wire dram_we;
    wire ram_clk;
    assign ram_clk = ~global_clk;
    dram DM(
        .clk(ram_clk),
        .we(dram_we),
        .a(alu_c[15:2]),
        .d(rf_rD2),
        .spo(dm_rd)
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
endmodule
