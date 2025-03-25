module ID_EX_REG(
    input wire clk,
    input wire rst_n,

    input wire [31:0] ID_pc,
    input wire [31:0] ID_pc4,
    input wire [31:0] ID_inst,
    input wire [1:0]  ID_wdsel,
    input wire        ID_rfwe,
    input wire        ID_dmwe,
    input wire [31:0] ID_ext,
    input wire [31:0] ID_rfrD1,
    input wire [31:0] ID_rfrD2,
    input wire [31:0] ID_alub,
    input wire [2:0]  ID_aluop,

    output reg [31:0] EX_pc,
    output reg [31:0] EX_pc4,
    output reg [31:0] EX_inst,
    output reg [1:0]  EX_wdsel,
    output reg [31:0] EX_rfwe,
    output reg [31:0] EX_dmwe,
    output reg [31:0] EX_ext,   
    output reg [31:0] EX_rfrD1,
    output reg [31:0] EX_rfrD2,
    output reg [31:0] EX_alub,
    output reg [2:0]  EX_aluop
    );

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_pc <= 32'b0;
        end else begin
            EX_pc <= ID_pc;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_pc4 <= 32'b0;
        end else begin
            EX_pc4 <= ID_pc4;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_inst <= 32'b0;
        end else begin
            EX_inst <= ID_inst;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_wdsel <= 2'b0;
        end else begin
            EX_wdsel <= ID_wdsel;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_rfwe <= 1'b0;
        end else begin
            EX_rfwe <= ID_rfwe;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_dmwe <= 1'b0;
        end else begin
            EX_dmwe <= ID_dmwe;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_ext <= 32'b0;            
        end else begin
            EX_ext <= ID_ext;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_rfrD1 <= 32'b0;
        end else begin
            EX_rfrD1 <= ID_rfrD1;
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_rfrD2 <= 32'b0;
        end else begin
            EX_rfrD2 <= ID_rfrD2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_alub <= 32'b0;
        end else begin
            EX_alub <= ID_alub;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            EX_aluop <= 3'd0;
        end else begin
            EX_aluop <= ID_aluop;
        end
    end
endmodule