// pipeline
`include "fetch.v"
`include "decode.v"
`include "execute.v"
`include "memory.v"
`include "writeback.v"
`include "hazardunit.v"

module pipeline(
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
   
    output        MemWrite_M,
    output [31:0] WriteDataM, DataAdrM, ReadDataM,
    output [31:0] PCW, Result, ALUResultW, WriteDataW
);

 
    


wire MemWrite_M;
wire [31:0] MemWriteData_M,ALUOut_M;

assign MemWrite_M  = (Ext_MemWrite && reset) ? 1'b1 : MemWriteM;
assign MemWriteData_M  = (Ext_MemWrite && reset) ? Ext_WriteData : MemWriteDataM;
assign ALUOut_M    = reset ? Ext_DataAdr : ALUOutM;

assign DataAdrM = ALUOut_M;
assign ReadDataM = ReadDataMemM;
assign WriteDataM = MemWriteData_M;
assign WriteDataW = WriteDataMemW;
assign ALUResultW =  ALUOutW;
// fetch stage

wire [31:0] PCD,instrD,PCPlus4D;
wire Branch_or_Jump_taken,pc_write;
fetch fetch(
    .clk(clk), 
    .reset(reset), 
    .ALUOut_E2F(ALUOut_E2F),
    .PCTarget_E2F(PCTarget_E2F), 
    .PCSrc_E2F(PCSrc_E2F),
    
    .PCD(PCD),
    .instrD(instrD),
    .PCPlus4D(PCPlus4D),
    //inputs from hazard unit
    .Branch_or_Jump_taken(Branch_or_Jump_taken),
    .pc_write(pc_write)
);


wire [31:0] RD1E,RD2E,PCPlus4E,PCE,extended_immE;
wire [4:0] rdE,rs1D2H,rs2D2H;
wire [2:0] ResultSrcE,funct3E;
wire [3:0] ALUControlE;
wire MemWriteE,RegWriteE,ALUSrcE,BranchE,JumpE,op3E,op5E,id_ex_flush,is_loadE;
wire [1:0] StoreSrcE;

// decode stage
decode decode(
    .clk(clk),
    .reset(reset),
    .instrD(instrD), // Instruction fetched
    .PCD(PCD), // Program Counter from fetch stage
    .PCPlus4D(PCPlus4D), // PC + 4 from fetch stage
    .ResultW(ResultW2F), // Result from writeback stage
    .RegWriteW(RegWriteW), // Register write enable signal from writeback stage
    .rdW(rdW), // Destination register from writeback stage
//datapath signals
    .RD1E(RD1E), // Read data 1 from register file
    .RD2E(RD2E), // Read data 2 from register file
    .PCPlus4E(PCPlus4E), // PC + 4 to execute stage
    .PCE(PCE), // Program Counter to execute stage
    .extended_immE(extended_immE), // Sign-extended immediate value
    .rdE(rdE),
    .rs1E(rs1E),.rs2E(rs2E),

//controller signals
    .ALUControlE(ALUControlE), // ALU control signal
    .ResultSrcE(ResultSrcE), // Result source selection
    .MemWriteE(MemWriteE), // Memory write enable signal
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE), // ALU source selection
    .StoreSrcE(StoreSrcE), // Store source selection
    .BranchE(BranchE), // Branch signal
    .JumpE(JumpE), // Jump signal
    .op3E(op3E), // Additional control signal for instruction type
    .op5E(op5E),
    .is_loadE(is_loadE),
    .funct3E(funct3E), // funct3 field from instruction

    // inputs from hazard unit
    .Branch_or_Jump_taken(Branch_or_Jump_taken), // Signal indicating if branch or jump is taken
    .id_ex_flush(id_ex_flush),
    //outputs to hazardunit
    .rs1D2H(rs1D2H),.rs2D2H(rs2D2H)
);

//execute stage
wire [31:0] ALUOutM,MemWriteDataM,LUI_or_AUIPCM,PCPlus4M,PCM,PCTarget_E2F,ALUOut_E2F,ALUOutM2E,ResultW2E;
wire [1:0] PCSrc_E2F;
wire MemWriteM,RegWriteM,is_loadE2H;
wire [2:0] ResultSrcM;
wire [1:0] RD1Esrc,RD2Esrc;
wire [4:0] rs1E,rs1E2H,rs2E,rs2E2H,rdM;
execute execute(
    .clk(clk),
    .reset(reset),
    .RD1E(RD1E), // Read data 1 from decode stage
    .RD2E(RD2E), // Read data 2 from decode stage
    .PCPlus4E(PCPlus4E), // PC + 4 from decode stage
    .PCE(PCE), // Program Counter from decode stage
    .extended_immE(extended_immE), // Sign-extended immediate value
    .ALUControlE(ALUControlE), // ALU control signal>>>>>
    .ResultSrcE(ResultSrcE), // Result source selection
    .MemWriteE(MemWriteE), // Memory write enable signal
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE), // ALU source selection>>>>>
    .StoreSrcE(StoreSrcE), // Store source selection>>>>>
    .BranchE(BranchE), // Branch signal>>>>
    .JumpE(JumpE), // Jump signal>>>>
    .op3E(op3E), // Additional control signal for instruction type>>>>>>>
    .op5E(op5E),
    .is_loadE(is_loadE),
    .funct3E(funct3E), // funct3 field from instruction>>>>>>>
    .rdE(rdE),
    .rs1E(rs1E),
    .rs2E(rs2E),
// outputs from the datapath
    .ALUOutM(ALUOutM), // Output of the ALU
    .MemWriteDataM(MemWriteDataM), // Data to be written to memory
    .LUI_or_AUIPCM(LUI_or_AUIPCM), // Zero flag for branch decisions
    .PCPlus4M(PCPlus4M), // Negative flag for branch decisions
    .PCM(PCM),
    .PCTarget_E2F(PCTarget_E2F), // Target address for branch or jump from execute stage to fetch stage
    .ALUOut_E2F(ALUOut_E2F), // ALU output for the execute stage
    .rdM(rdM), // Destination register for writeback stage
// control outputs
    .PCSrc_E2F(PCSrc_E2F),// goes to fetch stage
    .MemWriteM(MemWriteM), // Memory write enable signal
    .ResultSrcM(ResultSrcM), // Result source selection
    .RegWriteM(RegWriteM), // Register write enable signal

//inputs from memory stage
    .ALUOutM2E(ALUOutM2E),
// input from writeback stage
    .ResultW2E(ResultW2E),

//inputs from hazard unit
    .RD1Esrc(RD1Esrc),
    .RD2Esrc(RD2Esrc), // Source selection for hazard detection
//outputs to hazard unit
    .is_loadE2H(is_loadE2H),
    .rs1E2H(rs1E2H), // Source register 1 for hazard detection
    .rs2E2H(rs2E2H), // Source register 2 for hazard detection
    .Branch_or_Jump_taken(Branch_or_Jump_taken) // Signal indicating if branch or jump is taken

);

wire [31:0] ALUOutW,ReadDataMemW,LUI_or_AUIPCW,PCPlus4W,PCW,ReadDataMemM,WriteDataMemW;
wire [2:0] ResultSrcW;
wire RegWriteW;
wire [4:0] rdW,rdM2H;
wire RegWriteM2H;
// memory stage
memory memory(
     .clk(clk),
     .reset(reset),
     .ALUOutM(ALUOut_M), // ALU output from execute stage
     .MemWriteDataM(MemWriteData_M), // Data to be written to memory
     .MemWriteM(MemWrite_M), // Memory write enable signal
     .LUI_or_AUIPCM(LUI_or_AUIPCM), // LUI or AUIPC value for memory stage
     .PCPlus4M(PCPlus4M), // PC + 4 from execute
     .PCM(PCM),
     .ResultSrcM(ResultSrcM), // Result source selection
     .RegWriteM(RegWriteM), // Register write enable signal
     .rdM(rdM), // Destination register for writeback stage

    .ALUOutW(ALUOutW), // ALU output for writeback stage
    .ReadDataMemM(ReadDataMemM),
    .ReadDataMemW(ReadDataMemW), // Data read from memory
    .WriteDataMemW(WriteDataMemW),
    .LUI_or_AUIPCW(LUI_or_AUIPCW), // LUI or AUIPC value for writeback stage
    .PCPlus4W(PCPlus4W), // PC + 4 for writeback stage
    .PCW(PCW),
    // control outputs
    .ResultSrcW(ResultSrcW), // Result source selection for writeback stage
    .RegWriteW(RegWriteW), // Register write enable signal for writeback stage
    .rdW(rdW), // Destination register for writeback stage
     //outputs to execute stage
    .ALUOutM2E(ALUOutM2E),
    //output to hazard unit
    .RegWriteM2H(RegWriteM2H),
    .rdM2H(rdM2H) // Destination register for hazard unit
);


wire [31:0] ResultW2F;
wire [4:0] rdW2F;
wire RegWriteW2F;
wire RegWriteW2H;
wire [4:0] rdW2H;
// writeback stage
writeback writeback(
    .clk(clk),
    .reset(reset),
    .ALUOutW(ALUOutW), // ALU output from memory stage
    .ReadDataMemW(ReadDataMemW), // Data read from memory
    .LUI_or_AUIPCW(LUI_or_AUIPCW), // LUI or AUIPC value for writeback stage
    .PCPlus4W(PCPlus4W), // PC + 4 for writeback stage
    .PCW(PCW),
    .ResultSrcW(ResultSrcW), // Result source selection for writeback stage
    .RegWriteW(RegWriteW), // Register write enable signal for writeback stage
    .rdW(rdW), // Destination register for writeback stage
    
    
    .ResultW2F(ResultW2F), // Data to be written back to register file
    .RegWriteW2F(RegWriteW2F), // Register write enable signal for register file
    .rdW2F(rdW2F), // Destination register from writeback to  decode stage

    //output to execute stage
    .ResultW2E(ResultW2E),
    //output to hazard unit
    .RegWriteW2H(RegWriteW2H),
    .rdW2H(rdW2H) // Destination register for writeback stage
);

wire B_or_J_taken;
hazardunit hazardunit(
 
    .rs1E(rs1E2H), .rs2E(rs2E2H), .rdM(rdM),.rdW(rdW),.rdE(rdE),.rs1D(rs1D2H),.rs2D(rs2D2H),
    .is_load(is_loadE2H),
    .RegWriteM(RegWriteM),.RegWriteW(RegWriteW),
    .branch_taken(B_or_J_taken),

    .rd1Esrc(RD1Esrc),
    .rd2Esrc(RD2Esrc),
    .Branch_or_Jump_taken(Branch_or_Jump_taken),
    .pc_write(pc_write),.id_ex_flush(id_ex_flush)
);
assign Result = ResultW2F;

endmodule