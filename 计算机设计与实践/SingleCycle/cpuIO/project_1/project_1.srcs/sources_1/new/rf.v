module rf(
    input  wire        clk,    
    input  wire        rst_n,
    input  wire [4:0]  rR1,   
    input  wire [4:0]  rR2,     
    input  wire [4:0]  wR,     
    input  wire [31:0] wD,     
    input  wire        wen,  
    output wire [31:0] rD1,   
    output wire [31:0] rD2
    );
    
    reg [31:0] regs [31:0];     
    
    integer i;
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(i = 0; i < 32; i = i + 1)
                regs[i] = 32'b0;
        end else if(wen) begin
            regs[wR] <= wD;
        end
    end
    
    assign rD1 = (rR1 == 5'd0) ? 32'b0 : regs[rR1];
    assign rD2 = (rR2 == 5'd0) ? 32'b0 : regs[rR2];
    
endmodule
