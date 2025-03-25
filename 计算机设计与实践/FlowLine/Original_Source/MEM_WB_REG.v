module MEM_WB_REG(
    input  wire clk,
    input  wire rst_n,
    
    input  wire [31:0] MEM_pc,
    input  wire [31:0] MEM_inst,
    
    input  wire        MEM_rfwe,
    input  wire [31:0] MEM_rfwd,
    
    output reg  [31:0] WB_pc,
    output reg  [31:0] WB_inst,
    
    output reg         WB_rfwe,
    output reg  [31:0] WB_rfwd
    );
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)  WB_pc <= 32'b0;
        else        WB_pc <= MEM_pc;
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)  WB_inst <= 32'b0;
        else        WB_inst <= MEM_inst;
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)  WB_rfwe <= 1'b0;
        else        WB_rfwe <= MEM_rfwe;
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(!rst_n)  WB_rfwd <= 32'b0;
        else        WB_rfwd <= MEM_rfwd;
    end
    
endmodule
