`timescale 1ns / 1ps

module pc(
    input clk,
    input rst_n,
    input wire [31:0] npc,
    output reg [31:0] pc_reg
    );

    reg cnt;

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            pc_reg <= 32'b0;
            cnt <= 1'b0;
        end else if(!cnt) begin
            cnt <= cnt + 1;
        end else begin
            pc_reg <= npc;
        end
    end
endmodule
