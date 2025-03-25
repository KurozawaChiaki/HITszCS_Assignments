module led(
    input  wire [31:0] din,
    input  wire        wen,
    output wire [23:0] dout
    );

    assign dout = wEnable(wen, din[23:0]);
    function [23:0] wEnable(
        input        wen,
        input [23:0] din
    );
    begin
        if(wen) begin
            wEnable = din;
        end else begin
            wEnable = 24'b0;
        end
    end
    endfunction

endmodule