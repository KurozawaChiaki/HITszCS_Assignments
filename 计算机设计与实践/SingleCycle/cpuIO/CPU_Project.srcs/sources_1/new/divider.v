// 100Mto1k
module divider(
    input  wire clk_i,
    output reg  clk_o
    );
    
    reg [31:0] cnt = 32'h0000_0000;
    always @(posedge clk_i) begin
        cnt <= (cnt >= 32'd49999) ? 32'h0000_0000 : (cnt + 32'h0000_0001);
        clk_o <= cnt < 32'd25000;
    end
    
endmodule
