`timescale 1ns / 1ps

module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] alu_op,
    output wire [31:0] c
    );

    assign c = calculation(a, b, alu_op);

    function [31:0] calculation(input [31:0] a, input [31:0] b, input [2:0] op);
    begin
        case(op)
            3'b000: calculation = a + b;                    //add
            3'b001: calculation = a + ((~b) + 32'd1);       //sub
            3'b010: calculation = a & b;                    //and
            3'b011: calculation = a | b;                    //or
            3'b100: calculation = a ^ b;                    //xor
            3'b101: calculation = a << b[4:0];              //sll
            3'b110: calculation = a >> b[4:0];              //srl
            3'b111: calculation = ($signed(a)) >>> b[4:0];   //sra
            default: calculation = 32'b0;
        endcase 
    end
    endfunction
endmodule
