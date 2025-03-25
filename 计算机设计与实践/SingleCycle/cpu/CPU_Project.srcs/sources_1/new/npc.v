`timescale 1ns / 1ps

module npc(
    input wire [31:0] pc,
    input wire [31:0] alu_c,
    output wire [31:0] npc,
    output wire [31:0] pc4
    );

    assign pc4 = pc + 4;

    assign npc = nextPC(pc, alu_c, npc_op);

    function [31:0] nextPC(input [31:0] pc, input [31:0] alu_c, input op);
    begin
        case(op)
            1'b0: nextPC = pc + 4;
            1'b1: nextPC = alu_c;
            default: nextPC = pc + 4; 
        endcase
    end
    endfunction
endmodule
