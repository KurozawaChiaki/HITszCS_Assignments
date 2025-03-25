module comp(
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  br_ctrl,
    output wire        br_true
    );

    wire [31:0] c;
    assign c = a + ((~b) + 32'd1); //sub
    
    assign br_true = branch(c, br_ctrl);
    function [31:0] branch(
        input [31:0] c, 
        input [2:0] br_ctrl
    );
    begin
        case(br_ctrl)
            3'd0:    branch = 1'b0;
            3'd1:    branch = (c == 32'b0); //beq
            3'd2:    branch = (c != 32'b0); //bne
            3'd3:    branch = c[31];        //blt
            3'd4:    branch = ~c[31];       //bge
            default: branch = 1'b0;
        endcase
    end
    endfunction
endmodule