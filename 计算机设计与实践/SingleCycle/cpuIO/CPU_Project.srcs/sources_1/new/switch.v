module switch(
    input  wire [23:0] din,
    output wire [31:0] dout
    );

    assign dout = {8'b0, din};

endmodule