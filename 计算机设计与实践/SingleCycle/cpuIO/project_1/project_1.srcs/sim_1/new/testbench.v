`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/07/09 12:54:05
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench();

reg clk;
reg rst_n;

initial begin
    clk   = 0;
    rst_n = 0;
    #20;
    rst_n = 1;
    #200000;
    $finish;
end

top TOP(
    .clk(clk),
    .rst_n(rst)
);

always #5 clk <= ~clk;

endmodule
