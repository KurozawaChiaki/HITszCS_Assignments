module branchhazard(
    input  wire [31:0] IF_pc,
    input  wire [31:0] ID_pc,
      
    input  wire        dpc_control,    // from data hazard
    input  wire [31:0] IF_inst,
    input  wire [31:0] ID_inst,
      
    input  wire [31:0] ID_npc,
     
    output reg  [31:0] IF_npc
    );
    
    always @(*) begin
        if(dpc_control)                                IF_npc = IF_pc;           // dataHazard bubble
        else if(ID_pc == IF_pc && ID_inst[6] == 1'b1)  IF_npc = ID_npc;          // jal/jalr/B excute
        else if(IF_inst[6] == 1'b1)                    IF_npc = IF_pc;           // jal/jalr/B bubble
        else                                           IF_npc = IF_pc + 32'd4;
    end
    
endmodule
