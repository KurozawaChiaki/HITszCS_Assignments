`timescale 1ns / 1ps

module mux(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [31:0] c,
    input wire [31:0] d,
    input wire [1:0] sel_op,
    output wire [31:0] out
    );

    assign out = select(a, b, c, d, sel_op);

    function [31:0] select(input [31:0] a, input [31:0] b, input [31:0] c, input [31:0] d, input [1:0] op);
    begin
        case(op)
            2'b00: select = a;
            2'b01: select = b;
            2'b10: select = c;
            2'b11: select = d;
            default: select = 32'b0;
        endcase
    end
    endfunction
endmodule
