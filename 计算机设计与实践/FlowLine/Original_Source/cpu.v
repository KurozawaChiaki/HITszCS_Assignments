module cpu(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] IF_inst,
    output wire [31:0] IF_pc,
    input  wire [31:0] MEM_dmrd,
    output wire        MEM_dmwe,
    output wire [31:0] MEM_aluc,
    output wire [31:0] MEM_rdrD2,

    output wire        debug_wb_have_inst,
    output wire [31:0] debug_wb_pc,
    output wire        debug_wb_ena,
    output wire [4:0]  debug_wb_reg,
    output wire [31:0] debug_wb_value 
    );

    wire [31:0] ID_pc;
    wire        dpc_control;
    wire [31:0] ID_npc;
    wire [31:0] IF_npc;
    wire [31:0] ID_inst;

    branchhazard BH(
        .IF_pc        (IF_pc),
        .ID_pc        (ID_pc),
        .dpc_control  (dpc_control),
        .IF_inst      (IF_inst),
        .ID_inst      (ID_inst),
        .ID_npc       (ID_npc),
        .IF_npc       (IF_npc)
    );

    pc PC(
        .clk    (clk),
        .rst_n  (rst_n),
        .npc    (IF_npc),
        .pc_reg (IF_pc)
    );

    IF_ID_REG IF_ID(
        .clk         (clk),
        .rst_n       (rst_n),
        .dpc_control (dpc_control),
        .IF_inst     (IF_inst),
        .IF_npc      (IF_npc),
        .ID_inst     (ID_inst),
        .ID_npc      (ID_npc)
    );

    wire       re1;
    wire       re2;
    wire [2:0] br_ctrl;
    wire       br_true;
    wire [1:0] ID_wdsel;
    wire       ID_rfwe;
    wire       ID_dmwe;
    wire [2:0] sext_op;
    wire [1:0] npc_op;
    wire [2:0] ID_aluop;
    wire [1:0] alub_sel;

    control CU(
        .inst      (ID_inst),
        .re1       (re1),
        .re2       (re2),
        .br_ctrl   (br_ctrl),
        .br_true   (br_true),
        .npc_op    (npc_op),
        .sext_op   (sext_op),
        .alub_sel  (alub_sel),
        .alu_op    (ID_aluop),
        .wd_sel    (ID_wdsel),
        .rf_we     (ID_rfwe),
        .dram_we   (ID_dmwe)
    );

    wire [31:0] EX_pc;
    wire [31:0] EX_inst;
    wire [1:0]  EX_wdsel;
    wire        EX_rfwe;
    wire [31:0] EX_rfwd;
    wire [31:0] MEM_inst;
    wire        MEM_rfwe;
    wire [31:0] MEM_rfwd;
    wire [31:0] WB_inst;
    wire        WB_rfwe;
    wire [31:0] WB_rfwd;
    wire [1:0]  rd1_sel;
    wire [1:0]  rd2_sel;
    wire [31:0] fw1;
    wire [31:0] fw2;

    datahazard DH(
        .ID_inst      (ID_inst),
        .EX_inst      (EX_inst),
        .MEM_inst     (MEM_inst),
        .WB_inst      (WB_inst),
    
        .EX_rfwe      (EX_rfwe),
        .MEM_rfwe     (MEM_rfwe),
        .WB_rfwe      (WB_rfwe),
    
        .ID_pc        (ID_pc),
        .EX_pc        (EX_pc),
        
        .re1          (re1),
        .re2          (re2),
        .EX_wdsel     (EX_wdsel),
    
        .EX_rfwd      (EX_rfwd),
        .MEM_rfwd     (MEM_rfwd),
        .WB_rfwd      (WB_rfwd),

        .dpc_control  (dpc_control),
        .rd1_sel      (rd1_sel),
        .rd2_sel      (rd2_sel),
  
        .fw1          (fw1),
        .fw2          (fw2)
    );

    wire [31:0] ID_ext;
    wire [31:0] ID_rfrD1;
    wire [31:0] ID_pc4;
    npc NPC(
        .pc    (ID_pc),
        .imm   (ID_ext),
        .base  (ID_rfrD1),
        .pc4   (ID_pc4),
        .op    (npc_op),
        .npc   (ID_npc)
    );

    sext SEXT(
        .din  (ID_inst[31:7]),
        .op   (sext_op),
        .ext  (ID_ext)
    );

    wire [31:0] ID_rfrD1_pre;
    wire [31:0] ID_rfrD2_pre;
    rf RF(
        .clk    (clk),
        .rst_n  (rst_n),
        .rR1    (ID_inst[19:15]),
        .rR2    (ID_inst[24:20]),
        .rD1    (ID_rfrD1_pre),
        .rD2    (ID_rfrD2_pre),
        .rf_we  (WB_rfwe),
        .wR     (WB_inst[11:7]),
        .wD     (WB_rfwd)
    );

    mux 2RS1(
        .op   (rd1_sel),
        .a    (ID_rfrD1_pre),
        .b    (fw1),
        .c    (0),
        .d    (0),
        .out  (ID_rfrD1)
    );

    mux 2RS2(
        .op   (rd2_sel),
        .a    (ID_rfrD2_pre),
        .b    (fw2),
        .c    (0),
        .d    (0),
        .out  (ID_rfrD2)
    );

    comp COMP(
        .a        (ID_rfrD1),
        .b        (ID_rfrD2),
        .br_ctrl  (br_ctrl),
        .br_true  (br_true)
    );

    wire [31:0] ID_alub;
    mux 2ALUB2(
        .op   (alub_sel),
        .a    (ID_rfrD2),
        .b    (ID_ext),
        .c    (0),
        .d    (0),
        .out  (ID_alub)
    );

    wire [31:0] EX_pc4;
    wire        EX_dmwe;
    wire [31:0] EX_ext;
    wire [31:0] EX_rfrD1;
    wire [31:0] EX_rfrD2;
    wire [31:0] EX_alub;
    wire [2:0]  EX_aluop;

    ID_EX_REG ID_EX(
        .clk      (clk),
        .rst_n    (rst_n),
        .ID_pc    (ID_pc),
        .ID_pc4   (ID_pc4),
        .ID_inst  (ID_inst),
        .ID_wdsel (ID_wdsel),
        .ID_rfwe  (ID_rfwe),
        .ID_dmwe  (ID_dmwe),
        .ID_ext   (ID_ext),
        .ID_rfrD1 (ID_rfrD1),
        .ID_rfrD2 (ID_rfrD2),
        .ID_alub  (ID_alub),
        .ID_aluop (ID_aluop),

        .EX_pc    (EX_pc),
        .EX_pc4   (EX_pc4),
        .EX_inst  (EX_inst),
        .EX_wdsel (EX_wdsel),
        .EX_rfwe  (EX_rfwe),
        .EX_dmwe  (EX_dmwe),
        .EX_ext   (EX_ext),
        .EX_rfrD1 (EX_rfrD1),
        .EX_rfrD2 (EX_rfrD2),
        .EX_alub  (EX_alub),
        .EX_aluop (EX_aluop)
    );

    wire [31:0] EX_aluc;
    alu ALU(
        .a   (EX_rfrD1),
        .b   (EX_alub),
        .c   (EX_aluc),
        .op  (EX_aluop)
    );

    mux 2EXRF(
        .op  (EX_wdsel),
        .a   (EX_aluc),
        .b   (EX_pc4),
        .c   (EX_ext),
        .d   (0),
        .out (EX_rfwd)
    );

    wire [31:0] MEM_pc;
    wire [31:0] MEM_pc4;
    wire [31:0] MEM_wdsel;
    wire [31:0] MEM_ext;

    EX_MEM_REG EX_MEM(
        .clk         (clk),
        .rst_n       (rst_n),

        .EX_pc       (EX_pc),
        .EX_pc4      (EX_pc4),
        .EX_inst     (EX_inst),
        .EX_wdsel    (EX_wdsel),
        .EX_rfwe     (EX_rfwe),
        .EX_dmwe     (EX_dmwe),
        .EX_ext      (EX_ext),
        .EX_rfrD2    (EX_rfrD2),
        .EX_aluc     (EX_aluc),

        .MEM_pc      (MEM_pc),
        .MEM_pc4     (MEM_pc4),
        .MEM_inst    (MEM_inst),
        .MEM_wdsel   (MEM_wdsel),
        .MEM_rfwe    (MEM_rfwe),
        .MEM_dmwe    (MEM_dmwe),
        .MEM_ext     (MEM_ext),
        .MEM_rfrD2   (MEM_rfrD2),
        .MEM_aluc    (MEM_aluc)
    );

    mux 2RFWD(
        .op     (MEM_wdsel),
        .a      (MEM_aluc),
        .b      (MEM_pc4),
        .c      (MEM_ext),
        .d      (MEM_dmrd),
        .out    (MEM_rfwd)
    );
    wire [31:0] WB_pc;
    MEM_WB_REG MEM_WB(
        .clk            (clk),
        .rst_n          (rst_n),
        
        .MEM_pc         (MEM_pc),
        .MEM_inst       (MEM_inst),
                        
        .MEM_rfwe       (MEM_rfwe),
        .MEM_rfwd       (MEM_rfwd),
                        
        .WB_pc          (WB_pc),
        .WB_inst        (WB_inst),
                        
        .WB_rfwe        (WB_rfwe),
        .WB_rfwd        (WB_rfwd)
    );
    
    assign debug_wb_have_inst   =   (MEMpc != WBpc);
    assign debug_wb_pc          =   WB_pc;
    assign debug_wb_ena         =   WB_rfwe;
    assign debug_wb_reg         =   WB_inst[11:7];
    assign debug_wb_value       =   WB_rfwd;
endmodule