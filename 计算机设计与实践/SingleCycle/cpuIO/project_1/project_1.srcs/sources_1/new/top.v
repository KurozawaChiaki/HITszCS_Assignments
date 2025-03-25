module top(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [23:0] sw,
    output wire [23:0] led,
    output wire        led0_en,
    output wire        led1_en,
    output wire        led2_en,
    output wire        led3_en,
    output wire        led4_en,
    output wire        led5_en,
    output wire        led6_en,
    output wire        led7_en,
    output wire        led_ca ,
    output wire        led_cb ,
    output wire        led_cc ,
    output wire        led_cd ,
    output wire        led_ce ,
    output wire        led_cf ,
    output wire        led_cg ,
    output wire        led_dp 
    // output wire        debug_wb_have_inst,   
    // output wire [31:0] debug_wb_pc,          
    // output wire        debug_wb_ena,         
    // output wire [4:0]  debug_wb_reg,     
    // output wire [31:0] debug_wb_value        
    );
    
    wire        clk_o;
    wire [31:0] content;
    wire [31:0] pc;
    wire [31:0] inst;
    wire        globalclk;  // 25MHz
    wire        dram_we0;
    wire        dram_we;
    wire [31:0] alu_c;
    wire [31:0] rf_rD2;
    wire [31:0] dm_rd0;
    wire [31:0] dm_rd;
    wire        led_wen;
    wire        display_wen;
    wire [23:0] led_content;

    cpuclk CPUCLK(
        .clk_in1    (clk),
        .clk_out1   (globalclk)
    );
    
    cpu CPU(
        .clk                 (globalclk),
        .rst_n               (~rst_n),
        .sw                  (sw),
        .led                 (led),
        .content             (content),
        .pc                  (pc),
        .inst                (inst),
        .alu_c               (alu_c),
        .dm_rd               (dm_rd),
        .rf_rD2              (rf_rD2),
        .dram_we             (dram_we)
        // .debug_wb_have_inst  (debug_wb_have_inst),
        // .debug_wb_ena        (debug_wb_ena),
        // .debug_wb_pc         (debug_wb_pc),
        // .debug_wb_reg        (debug_wb_reg),
        // .debug_wb_value      (debug_wb_value)
    );

    // 64KB IROM
    prgrom IM(
        .a      (pc[15:2]),
        .spo    (inst)
    );
    
    wire [31:0] waddr_tmp = alu_c - 16'h4000;
    dram DM(
        .clk    (globalclk),
        .we     (dram_we0),
        .a      (waddr_tmp[15:2]),
        .d      (rf_rD2),
        .spo    (dm_rd0)
    );

    // I/O select (datamemory, switch, led)
    iosel DSL(
        .clk          (globalclk),
        .rst_n        (~rst_n),
        .addr         (alu_c),
        .dm_we        (dram_we),
        .dm_rd0       (dm_rd0),
        .sw           (sw),
        .din          (rf_rD2),
        .dm_rd        (dm_rd),
        .led          (led_content),
        .dm_we0       (dram_we0),
        .content      (content),
        .led_wen      (led_wen),
        .display_wen  (display_wen)
    );

    led LED(
        .din   (led_content),
        .wen   (led_wen),
        .dout  (led)
    );
    
    divider DVDR(clk, clk_o);
    
    display DP(clk_o, 1, content, display_wen,
        led0_en, led1_en, led2_en, led3_en,
        led4_en, led5_en, led6_en, led7_en,
        led_ca, led_cb, led_cc, led_cd,
        led_ce, led_cf, led_cg, led_dp
    );
    
endmodule
