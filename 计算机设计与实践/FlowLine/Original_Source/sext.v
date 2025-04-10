module sext(
    input  wire [24:0] din,
    input  wire [2:0]  op,
    output wire [31:0] ext
    );

    assign ext = sext_generator(din, op);

    function [31:0] sext_generator(
        input [24:0] din,
        input [2:0]  op
    );
    begin
        case(op)
            3'd0:     sext_generator = {{20{din[24]}}, din[24:13]};                                     // I-type
            3'd1:     sext_generator = {{19{din[24]}}, din[24], din[0], din[23:18], din[4:1], 1'b0};    // B-type
            3'd2:     sext_generator = {{11{din[24]}}, din[24], din[12:5], din[13], din[23:14], 1'b0};  // J-type
            3'd3:     sext_generator = {{20{din[24]}}, din[24:18], din[4:0]};                           // S-type
            3'd4:     sext_generator = {din[24:5], 12'b0};                                              // U-type
            default:  sext_generator = 32'b0;
        endcase
    end
    endfunction

endmodule