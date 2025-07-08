//fetch cycle

`include "PC.v"
`include "adder.v"
`include "instr_mem.v"
`include "4x1mux.v"


module fetch(
    input clk,
    input reset,
    input [31:0] ALUOut_E2F,
    input [31:0] PCTarget_E2F, // Target PC for branch/jump
    input [1:0] PCSrc_E2F,

    output  [31:0] PCD, // Program Counter
    output  [31:0] instrD,
    output  [31:0] PCPlus4D, // PC + 4
    //inputs from hazard unit
    input wire Branch_or_Jump_taken,
    input wire pc_write
    
);

wire [31:0] instr,PC,PCPlus4,PCNext;


reg [31:0] PC_F,instr_F,PCPlus4_F; 


pc pc_reg(
    .PCNext(PCNext), 
    .clk(clk), 
    .pc_we(pc_write),
    .rst(reset), 
    .PC(PC)
);

instr_mem instr_mem(
    .PC(PC),
    .instr(instr)
);

mux4x1 PC_mux(
    .a(PCPlus4), 
    .b(PCTarget_E2F), 
    .c(ALUOut_E2F), 
    .d(PCPlus4), 
    .sel(PCSrc_E2F), 
    .y(PCNext)
);

adder PCPlus4_adder(
    .a(PC),
    .b(32'd4),
    .y(PCPlus4)
);


initial begin
    PC_F <= 32'b0; // Reset PC to 0
    instr_F <= 32'b0; // Reset instruction to 0
     PCPlus4_F <= 32'b0; // Reset PC + 4 to 0


end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC_F <= 32'b0; // Reset PC to 0
            instr_F <= 32'b0; // Reset instruction to 0
            PCPlus4_F <= 32'b0; // Reset PC + 4 to 0
        end 
        else if(Branch_or_Jump_taken) begin
            PC_F <= 32'b0; // Update PC wi
            instr_F <= 32'h00000013; //addi x0,x0,0 it is a dummy instruction to avoid hazards
            PCPlus4_F <= 32'b0; // Reset PC + 4
        end else begin
            PC_F <= PC; // Update PC with PC + 4
            instr_F <= instr; // Update instruction with fetched instruction
            PCPlus4_F <= PCPlus4; // Update PC + 4 with PC + 4
        end
    end

assign PCD = PC_F; // Output the current PC
assign instrD = instr_F; // Output the fetched instruction
assign PCPlus4D = PCPlus4_F; // Output the PC + 4 value


endmodule