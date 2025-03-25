module top(
    input  wire clk,
    input  wire rst_n,

    output wire        debug_wb_have_inst,
    output wire [31:0] debug_wb_pc,
    output wire        debug_wb_ena,
    output wire [4:0]  debug_wb_reg,
    output wire [31:0] debug_wb_value 
    );

    wire [31:0] pc;
    wire [31:0] inst;
     
    wire [31:0] alu_c;    // alu result
    wire [31:0] rf_rD2;   // reg file reg2 read data
    wire        dram_we;
    wire [31:0] dm_rd;
    wire        dram_we0;      // datamemory write enable
    wire [31:0] dm_rd0;   // data memory read data

    cpu CPU(
        .clk                    (clk),
        .rst_n                  (rst_n),

        .IF_inst                (inst),
        .IF_pc                  (pc),

        .MEM_dmrd               (dm_rd),
        .MEM_dmwe               (dram_we),
        .MEM_aluc               (alu_c),
        .MEM_rfrD2              (rf_rD2),

        .debug_wb_have_inst     (debug_wb_have_inst),
        .debug_wb_pc            (debug_wb_pc),
        .debug_wb_ena           (debug_wb_ena),
        .debug_wb_reg           (debug_wb_reg),
        .debug_wb_value         (debug_wb_value)
    );

    data_mem dmem(
        .clk    (clk),
        .we     (dram_we),
        .a      (alu_c[15:2]),
        .d      (rf_rD2),
        .spo    (dm_rd)
    );

    inst_mem imem(
        .a      (pc[15:2]),
        .spo    (inst)
    );

endmodule