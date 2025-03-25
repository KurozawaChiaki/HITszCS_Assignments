module EX_MEM_REG(
    input  wire clk,
    input  wire rst_n,
     
    input  wire [31:0] EX_pc,
    input  wire [31:0] EX_pc4,
    input  wire [31:0] EX_inst,
      
    input  wire [1:0]  EX_wdsel,
    input  wire        EX_rfwe,
    input  wire        EX_dmwe,
      
    input  wire [31:0] EX_ext,
    input  wire [31:0] EX_rfrD2,
    input  wire [31:0] EX_aluc,
     
    output reg  [31:0] MEM_pc,
    output reg  [31:0] MEM_pc4,
    output reg  [31:0] MEM_inst,
      
    output reg  [1:0]  MEM_wdsel,
    output reg         MEM_rfwe,
    output reg         MEM_dmwe,
      
    output reg  [31:0] MEM_ext, 
    output reg  [31:0] MEM_rfrD2,
    output reg  [31:0] MEM_aluc
    );
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_pc <= 32'b0;
        else        MEM_pc <= EX_pc;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_pc4 <= 32'b0;
        else        MEM_pc4 <= EX_pc4;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_inst <= 32'b0;
        else        MEM_inst <= EX_inst;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_wdsel <= 2'd0;
        else        MEM_wdsel <= EX_wdsel;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_rfwe <= 1'b0;
        else        MEM_rfwe <= EX_rfwe;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_dmwe <= 1'b0;
        else        MEM_dmwe <= EX_dmwe;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_ext <= 32'b0;
        else        MEM_ext <= EX_ext;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_rfrD2 <= 32'b0;
        else        MEM_rfrD2 <= EX_rfrD2;
    end
    
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)  MEM_aluc <= 32'b0;
        else        MEM_aluc <= EX_aluc;
    end
    
endmodule
