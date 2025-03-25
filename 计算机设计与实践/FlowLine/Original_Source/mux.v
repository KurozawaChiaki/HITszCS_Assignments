module mux(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [31:0] c,
    input  wire [31:0] d,
    input  wire [1:0]  op,
    output wire [31:0] out
    );

    assign out = select(a, b, c, d, op);

    function [31:0] select(
        input [31:0] a,
        input [31:0] b,
        input [31:0] c,
        input [31:0] d,
        input [1:0]  op
    );
    begin
        case(op)
            2'd0:    select = a;
            2'd1:    select = b;
            2'd2:    select = c;
            2'd3:    select = d;
            default: select = 32'd0;
        endcase
    end
    endfunction
endmodule