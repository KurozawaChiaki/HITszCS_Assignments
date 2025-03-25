`timescale 1ns / 1ps

module comp(
    input wire [31:0] a,
    input wire [31:0] b,
    output wire BrEq,
    output wire BrLt
    );

    wire [31:0] c;
    assign c = a + ((~b) + 32'd1);

    assign BrEq = (c == 32'b0);

    assign BrLt = c[31];
endmodule
