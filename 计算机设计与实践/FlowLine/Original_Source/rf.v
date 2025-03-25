module rf(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [4:0]  rR1,
    input  wire [4:0]  rR2,
    input  wire [4:0]  wR,
    input  wire [31:0] wD,
    input  wire        rf_we,
    output wire [31:0] rf_rD1,
    output wire [31:0] rf_rD2
    );

    reg [31:0] regs [31:0];
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            for(i = 0; i < 32; i = i + 1) begin
                regs[i] <= 32'd0;
            end
        end else if(rf_we) begin
            regs[wR] <= wD;
        end else begin
            for(i = 0; i < 32; i = i + 1) begin
                regs[i] <= regs[i];
            end
        end
    end

    assign rf_rD1 = (rR1 == 5'd0) ? 32'b0 : regs[rR1];
    assign rf_rD2 = (rR2 == 5'd0) ? 32'b0 : regs[rR2];

endmodule