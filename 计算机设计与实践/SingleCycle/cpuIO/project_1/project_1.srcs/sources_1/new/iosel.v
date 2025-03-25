module iosel(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] addr,
    input  wire        dm_we,
    input  wire [31:0] dm_rd0,
    input  wire [23:0] sw,
    input  wire [31:0] din,
    output reg         led_wen,
    output reg         display_wen,
    output wire [31:0] dm_rd,
    output reg  [23:0] led,
    output wire        dm_we0,
    output reg  [31:0] content
    );
    
    assign dm_rd = wSel(addr, dm_rd0, sw);
    function [31:0] wSel(
        input [31:0] addr, 
        input [31:0] dm_rd0, 
        input [23:0] sw
    );
    begin
        case(addr)
            32'hfffff070:   wSel = {16'b0, sw[15:0]};
            32'hfffff072:   wSel = {24'b0, sw[23:16]};
            default:        wSel = dm_rd0;
        endcase
    end
    endfunction
    
    assign dm_we0 = (dm_we && (addr != 32'hfffff060) && (addr != 32'hfffff000));
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            led     <= 24'b0;
            content <= 32'b0;
        end else if(dm_we) begin
            case(addr)
                32'hfffff060: begin
                    led_wen <= 1'b1;
                    led     <= din[23:0];
                end
                32'hfffff000: begin
                    display_wen <= 1'b1;
                    content     <= din;
                end
                default: begin
                    display_wen <= 1'b0;
                    led_wen     <= 1'b0;
                    content     <= content;
                    led         <= led;
                end
            endcase
        end else begin
            led <= led;         
        end                  
    end 
    
endmodule
