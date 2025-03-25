`timescale 1ns / 1ps

module sext(
    input wire [24:0] din,
    input wire [2:0] sext_op,
    output wire [31:0] ext 
    );

    assign ext = decoder(din, sext_op);
    function [31:0] decoder(input [24:0] din, input [2:0] op);
    begin
        case(op)
            3'b000: decoder = {{20{din[24]}}, din[24:13]};
            3'b001: decoder = {{19{din[24]}}, din[24], din[0], din[23:18], din[4:1], 1'b0};
            3'b010: decoder = {{11{din[24]}}, din[24], din[12:5], din[13], din[23:14], 1'b0};
            3'b011: decoder = {{20{din[24]}}, din[24:18], din[4:0]};
            3'b100: decoder = {din[24:5], 12'b0};
            default: decoder = 32'd0;
        endcase
    end
    endfunction
endmodule
