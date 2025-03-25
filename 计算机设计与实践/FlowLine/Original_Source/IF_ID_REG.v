module IF_ID_REG(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        dpc_control,
    input  wire [31:0] IF_pc,
    input  wire [31:0] IF_inst,
    output reg  [31:0] ID_pc = 0,
    output reg  [31:0] ID_inst = 0
    );

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ID_pc <= 32'b0;
        end else if(dpc_control) begin
            ID_pc <= ID_pc;
        end else begin
            ID_pc <= IF_pc;
        end
    end

    reg cnt = 0;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            ID_inst <= 32'b0;
            cnt     <= 1'b0;
        end else if(~cnt) begin
            ID_inst <= 32'b0;
            cnt     <= 1'b1;
        end else if(dpc_control) begin
            ID_inst <= ID_inst;
        end else begin
            ID_inst <= IF_inst;
        end
    end

endmodule