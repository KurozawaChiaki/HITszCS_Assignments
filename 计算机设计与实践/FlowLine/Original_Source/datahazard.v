module datahazard(
    input  wire [31:0] ID_inst,
    input  wire [31:0] EX_inst,
    input  wire [31:0] MEM_inst,
    input  wire [31:0] WB_inst,
      
    input  wire        EX_rfwe,
    input  wire        MEM_rfwe,
    input  wire        WB_rfwe,
      
    input  wire [31:0] ID_pc,
    input  wire [31:0] EX_pc,
      
    input  wire        re1,
    input  wire        re2,
    input  wire [1:0]  EX_wdsel,
      
    input  wire [31:0] EX_rfwd,
    input  wire [31:0] MEM_rfwd,
    input  wire [31:0] WB_rfwd,
    
    output reg         dpc_control,
    output reg  [1:0]  rd1_sel,
    output reg  [1:0]  rd2_sel,
    
    output reg  [31:0] fw1,
    output reg  [31:0] fw2
    );
    
    // pc control for lw-use
    always @(*) begin
        if(ID_pc == EX_pc) begin
            dpc_control = 1'b0;            
        end else if(ID_inst[19:15] != 5'd0 && ID_inst[19:15] == EX_inst[11:7] && EX_rfwe && re1 && EX_wdsel == 2'd3) begin
            dpc_control = 1'b1;
        end else if(ID_inst[24:20] != 5'd0 && ID_inst[24:20] == EX_inst[11:7] && EX_rfwe && re2 && EX_wdsel == 2'd3) begin
            dpc_control = 1'b1;
        end else begin
            dpc_control = 1'b0;
        end
    end
    
    // rd1_sel
    always @(*) begin
        if(ID_inst[19:15] == 5'd0) begin   
            rd1_sel = 2'd0;
        end else if(ID_pc != EX_pc && ID_inst[19:15] == EX_inst[11:7] && EX_rfwe && re1 && EX_wdsel != 2'd3) begin    
            rd1_sel = 2'd1;
        end else if(ID_inst[19:15] == MEM_inst[11:7] && MEM_rfwe && re1) begin                   
            rd1_sel = 2'd1;
        end else if(ID_inst[19:15] == WB_inst[11:7] && WB_rfwe && re1) begin                       
            rd1_sel = 2'd1;
        end else begin
            rd1_sel = 2'd0;           
        end
    end
    
    // rd2_sel
    always @(*) begin
        if(ID_inst[24:20] == 5'd0) begin
            rd2_sel = 2'd0;
        end else if(ID_pc != EX_pc && ID_inst[24:20] == EX_inst[11:7] && EX_rfwe && re2 && EX_wdsel != 2'd3) begin  
            rd2_sel = 2'd1;
        end else if(ID_inst[24:20] == MEM_inst[11:7] && MEM_rfwe && re2) begin                   
            rd2_sel = 2'd1;
        end else if(ID_inst[24:20] == WB_inst[11:7] && WB_rfwe && re2) begin                        
            rd2_sel = 2'd1;
        end else begin                   
            rd2_sel = 2'd0;
        end
    end
    
    // forward1
    always @(*) begin
        if(ID_inst[19:15] == 5'd0) begin
            fw1 = 32'b0;
        end else if(ID_pc != EX_pc && ID_inst[19:15] == EX_inst[11:7] && EX_rfwe && re1 && EX_wdsel != 2'd3) begin  
            fw1 = EX_rfwd;
        end else if(ID_inst[19:15] == MEM_inst[11:7] && MEM_rfwe && re1) begin                   
            fw1 = MEM_rfwd;
        end else if(ID_inst[19:15] == WB_inst[11:7] && WB_rfwe && re1) begin                     
            fw1 = WB_rfwd;
        end else begin
            fw1 = 32'b0;
        end
    end
    
    // forward2
    always @(*) begin
        if(ID_inst[24:20] == 5'd0) begin
            fw2 = 32'b0;
        end else if(ID_pc != EX_pc && ID_inst[24:20] == EX_inst[11:7] && EX_rfwe && re2 && EX_wdsel != 2'd3) begin
            fw2 = EX_rfwd;
        end else if(ID_inst[24:20] == MEM_inst[11:7] && MEM_rfwe && re2) begin                   
            fw2 = MEM_rfwd;
        end else if(ID_inst[24:20] == WB_inst[11:7] && WB_rfwe && re2) begin                     
            fw2 = WB_rfwd;
        end else begin                        
            fw2 = 32'b0;
        end
    end
    
endmodule
