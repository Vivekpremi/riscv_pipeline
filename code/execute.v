//execute cycle


module execute(
    input clk,
    input reset,
    input [31:0] RD1E, // Read data 1 from decode stage
    input [31:0] RD2E, // Read data 2 from decode stage
    input [31:0] PCPlus4E, // PC + 4 from decode stage
    input [31:0] PCE, // Program Counter from decode stage
    input [31:0] extended_immE, // Sign-extended immediate value
    input [2:0] ALUControlE, // ALU control signal>>>>>
    input [2:0] ResultSrcE, // Result source selection
    input MemWriteE, // Memory write enable signal
    input RegWriteE,
    input ALUSrcE, // ALU source selection>>>>>
    input [1:0] StoreSrcE, // Store source selection>>>>>
    input BranchE, // Branch signal>>>>
    input JumpE, // Jump signal>>>>
    input op3E, // Additional control signal for instruction type>>>>>>>
    input op5E,
    input [2:0] funct3E, // funct3 field from instruction>>>>>>>
    input [4:0] rdE,
// outputs from the datapath
    output [31:0] ALUOutM, // Output of the ALU
    output [31:0] MemWriteDataM, // Data to be written to memory
    output [31:0] LUI_or_AUIPCM, // Zero flag for branch decisions
    output [31:0] PCPlus4M, // Negative flag for branch decisions
    output [31:0] PCTarget_E2F, // Target address for branch or jump from execute stage to fetch stage
    output [31:0] ALUOut_E2F, // ALU output for the execute stage
    output [4:0] rdM, // Destination register for writeback stage
// control outputs
output [1:0] PCSrc_E2F,// goes to fetch stage
output MemWriteM, // Memory write enable signal
output [2:0] ResultSrcM, // Result source selection
output RegWriteM, // Register write enable signal

//inputs from memory stage
input [31:0] ALUOutM2E,
// input from writeback stage
input [31:0] ResultW2E,

//inputs from hazard unit
input wire [1:0] RD1Esrc,
input wire [1:0] RD2Esrc, // Source selection for hazard detection
//outputs to hazard unit
output [4:0] rs1E, // Source register 1 for hazard detection
output [4:0] rs2E, // Source register 2 for hazard detection
output Branch_or_Jump_taken // Signal indicating if branch or jump is taken

);
reg [4:0] rd_E;

wire Branch_or_Jump_taken; // Signal indicating if branch or jump is taken
PCSrcGen  PCSrcGen(
     .Jump(JumpE),
     .Branch(BranchE),
     .Z(Z),
     .S(S),
     .U(U),
     .op3(op3E),
     .funct3(funct3E),
     .PCSrc(PCSrc_E2F),
     .Branch_or_Jump_taken(Branch_or_Jump_taken)
); 
wire [31:0] SrcAE, SrcBE,SrcBE_hazardfree; // ALU source operands

mux4x1 mux_RD1E(
    .a(RD1E), 
    .b(ALUOut_M2E), // ALU output from execute stage
    .c(ResultW2E), // LUI or AUIPC value
    .d(32'b0), // PC + 4 value
    .sel(RD1Esrc), 
    .y(SrcAE)
);

mux4x1 mux_RD2E(
    .a(RD2E), 
    .b(ALUOut_M2E), // ALU output from execute stage
    .c(ResultW2E), // LUI or AUIPC value
    .d(32'b0), // PC + 4 value
    .sel(RD2Esrc), 
    .y(SrcBE_hazardfree)
);
mux2x1  mux_ALUSrc(
    .a(RD2E), 
    .b(extended_immE), 
    .sel(ALUSrcE), 
    .y(SrcBE)
);

// assign SrcAE = RD1E; // Source A is always RD1E

wire [31:0] ALUOutE; // ALU output for the execute stage
reg [31:0] ALUOut_E;

wire Z, N, V, C, S, U; // Flags from the ALU
alu alu(
    .A(SrcAE),
    .B(SrcBE),
    .ALUCtrl(ALUControlE),
    .alu_out(ALUOutE),
    .Z(Z),
    .N(N),
    .V(V),
    .C(C),
    .S(S),
    .U(U)
);

wire [31:0] MemWriteDataE;
reg [31:0] MemWriteData_E;

mux4x1 store_mux(
    .a({{24{RD2E[7]}},RD2E[7:0]}), //sb
    .b({{16{RD2E[15]}},RD2E[15:0]}), //sh
    .c(RD2E), //sw
    .d(32'b0), //default
    .sel(StoreSrcE),
    .y(MemWriteDataE)
);

wire [31:0] PCTargetE; // Target address for branch or jump

adder PCTarget_adder(
    .a(PCE),
    .b(extended_immE),
    .y(PCTargetE) 
);
reg [31:0] LUI_or_AUIPC_E;
wire [31:0] LUI_or_AUIPCE; 

mux2x1 LUI_or_AUIPCMux(
    .a(PCPlus4E),
    .b(PCTargetE),
    .sel(op5E), // Use op5E to select between PC + 4 and PCTarget
    .y(LUI_or_AUIPCE)
);

reg [31:0] PCPlus4_E;

// control regs
reg RegWrite_E, // Register write enable signal
reg MemWrite_E, // Memory write enable signal
reg [2:0] ResultSrc_E, // Result source selection

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ALUOut_E <= 32'b0;
        MemWriteData_E <= 32'b0;
        LUI_or_AUIPC_E <= 32'b0;
        PCPlus4_E <= 32'b0;
        RegWrite_E <= 1'b0;
        MemWrite_E <= 1'b0;
        ResultSrc_E <= 3'b0;
    end 
    
    else begin
        ALUOut_E <= ALUOutE; // Update ALU output
        MemWriteData_E <= MemWriteDataE; // Update memory write data
        LUI_or_AUIPC_E <= LUI_or_AUIPCE; // Update LUI or AUIPC value
        PCPlus4_E <= PCPlus4E; // Update PC + 4
        RegWrite_E <= RegWriteE; 
        MemWrite_E <= MemWriteE; // Update memory write enable signal
        ResultSrc_E <= ResultSrcE; // Update result source selection
        rd_E <= rdE; // Update destination register for writeback stage
    end
end
    assign ALUOutM = ALUOut_E; // Output the ALU result
    assign MemWriteDataM = MemWriteData_E; // Output the memory write data
    assign LUI_or_AUIPCM = LUI_or_AUIPC_E; // Output the LUI or AUIPC value
    assign PCPlus4M = PCPlus4_E; // Output the PC + 4 value
    assign PCTarget_E2F = PCTargetE; // Output the target address for branch or jump from execute stage to fetch stage
    assign ALUOut_E2F = ALUOutE;// Output the ALU output from execute stage to fetch stage
    // assign PCSrc_E2F = PCSrc_E2F; // Output the PC source selection for fetch stage
    assign MemWriteM = MemWrite_E; // Output the memory write enable signal
    assign ResultSrcM = ResultSrc_E; // Output the result source selection
    assign RegWriteM = RegWrite_E; // Output the register write enable signal
    assign rdM = rd_E; 

endmodule
