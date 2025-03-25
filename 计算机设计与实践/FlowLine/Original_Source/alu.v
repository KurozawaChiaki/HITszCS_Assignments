module alu(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  op,
    output wire [31:0] c
    );

    assign c = calculate(a, b, op);
    function [31:0] calculate (input [31:0] a, input [31:0] b, input [2:0] op);
    begin
        case(op)
            3'd0:       calculate = a + b;                    // add
            3'd1:       calculate = a + ((~b) + 32'b1);       // sub
            3'd2:       calculate = a & b;                    // and
            3'd3:       calculate = a | b;                    // or
            3'd4:       calculate = a ^ b;                    // xor
            3'd5:       calculate = a << b[4:0];              // sll
            3'd6:       calculate = a >> b[4:0];              // srl
            3'd7:       calculate = ($signed(a)) >>> b[4:0];  // sra
            default:    calculate = 32'b0;
        endcase
    end
    endfunction
endmodule