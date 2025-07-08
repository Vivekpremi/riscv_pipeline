//decode cycle

`include "reg_file.v"
`include "sign_ext.v"
`include "controller.v"

module decode(
    input clk,
    input reset,
    input [31:0] instrD, // Instruction fetched
    input [31:0] PCD, // Program Counter from fetch stage
    input [31:0] PCPlus4D, // PC + 4 from fetch stage
    input [31:0] ResultW, // Result from writeback stage
    input RegWriteW, // Register write enable signal from writeback stage
    input [4:0] rdW, // Destination register from writeback stage
//datapath signals
    output [31:0] RD1E, // Read data 1 from register file
    output [31:0] RD2E, // Read data 2 from register file
    output  [31:0] PCPlus4E, // PC + 4 to execute stage
    output  [31:0] PCE, // Program Counter to execute stage
    output [31:0] extended_immE, // Sign-extended immediate value
    output [4:0] rdE,
    output [4:0] rs1E,rs2E,

//controller signals
    output [3:0] ALUControlE, // ALU control signal
    output [2:0] ResultSrcE, // Result source selection
    output MemWriteE, // Memory write enable signal
    output RegWriteE,
    output ALUSrcE, // ALU source selection
    output [1:0] StoreSrcE, // Store source selection
    output BranchE, // Branch signal
    output JumpE, // Jump signal
    output op3E, // Additional control signal for instruction type
    output op5E,
    output is_loadE,
    output [2:0] funct3E, // funct3 field from instruction

    // inputs from hazard unit
    input wire Branch_or_Jump_taken, // Signal indicating if branch or jump is taken
    input wire id_ex_flush,
    //outputs to hazard unit
    output wire [4:0] rs1D2H,rs2D2H
);

wire [4:0] rs1D, rs2D, rdD; // source and destination registers
wire [31:0] RD1D, RD2D; // read data from registers
wire [31:0] wdD; // write data to registers
wire weD; // write enable signal

assign rs1D = instrD[19:15]; // rs1 field from instruction
assign rs2D = instrD[24:20]; // rs2 field from instruction
assign rdD = instrD[11:7]; // rd field from instruction


reg [31:0] RD1_D, RD2_D,PC_D,PCPlus4_D; // registers to hold read data
reg [4:0] rd_D,rs1_D,rs2_D; // register to hold destination register

assign wdD = ResultW; // write data is the result from writeback stage

reg_file reg_file(
  .clk(clk),
  .rs1(rs1D), // source register 1
  .rs2(rs2D), // source register 2
  .rd(rdW),  // destination register
  .wd(wdD),  // write data
  .we(weD),         // write enable
  .rd1(RD1D), //read data 1
  .rd2(RD2D)  //read data 2
);

wire [31:0] extended_immD; // sign-extended immediate value
wire [24:0] semi_instrD; // semi-instruction for sign extension
wire [1:0] ImmSrcD; // immediate source selection
wire [2:0] opcode654D; // opcode for instruction type

assign opcode654D = instrD[6:4]; // extract opcode bits
assign semi_instrD = instrD[31:7]; // extract semi-instruction bits

reg [31:0] extended_imm_D;

sign_extender sign_extender(
    .imm_src(ImmSrcD),
    .semi_instr(semi_instrD),
    .opcode654(opcode654D),
    .sign_extended_imm(extended_immD)
);


wire [3:0] ALUControlD; // ALU control signal
wire [2:0] ResultSrcD; // Result source selection
wire MemWriteD; // Memory write enable signal
wire ALUSrcD; // ALU source selection
wire [1:0] StoreSrcD; // Store source selection
wire RegWriteD; // Register write enable signal
wire BranchD; // Branch signal
wire JumpD; // Jump signal
wire op3D; // Additional control signal for instruction type
wire op5D;
wire is_loadD;
wire [2:0] funct3D;
reg [2:0] ResultSrc_D,funct3_D;
reg [3:0] ALUControl_D;
reg MemWrite_D,RegWrite_D,ALUSrc_D,Branch_D,Jump_D,op3_D,op5_D,is_load_D; // registers to hold control signals
reg [1:0] StoreSrc_D;

assign weD = RegWriteW; // write enable control signal from writeback stage

controller controller(
    .instr(instrD),
    .ALUControl(ALUControlD),
    .ResultSrc(ResultSrcD),
    .MemWrite(MemWriteD),
    .ALUSrc(ALUSrcD),
    .StoreSrc(StoreSrcD),
    .ImmSrc(ImmSrcD),
    .RegWrite(RegWriteD),
    .Branch(BranchD),
    .Jump(JumpD),
    .op3(op3D),
    .op5(op5D), // Additional control signal for instruction type
    .is_load(is_loadD),
    .funct3(funct3D) // funct3 field from instruction
);

initial begin

RD1_D <= 32'b0;
        RD2_D <= 32'b0;
        PC_D <= 32'b0;
        PCPlus4_D <= 32'b0;
        extended_imm_D <= 32'b0;
        ALUControl_D <= 4'b0;
        ResultSrc_D <= 3'b0;
        MemWrite_D <= 1'b0;
        RegWrite_D<=1'b0;
        ALUSrc_D <= 1'b0;
        StoreSrc_D <= 2'b0;
        Branch_D <= 1'b0;
        Jump_D <= 1'b0;
        op3_D <= 1'b0;
        op5_D<=1'b0;
        is_load_D <= 1'b0;
        funct3_D <= 3'b0;
        rd_D<= 5'b0;
        rs1_D<=5'b0;
        rs2_D<=5'b0;

end
always@(posedge clk or posedge reset) begin
    if (reset) begin
        RD1_D <= 32'b0;
        RD2_D <= 32'b0;
        PC_D <= 32'b0;
        PCPlus4_D <= 32'b0;
        extended_imm_D <= 32'b0;
        ALUControl_D <= 4'b0;
        ResultSrc_D <= 3'b0;
        MemWrite_D <= 1'b0;
        RegWrite_D<=1'b0;
        ALUSrc_D <= 1'b0;
        StoreSrc_D <= 2'b0;
        Branch_D <= 1'b0;
        Jump_D <= 1'b0;
        op3_D <= 1'b0;
        op5_D<=1'b0;
        is_load_D <= 1'b0;
        funct3_D <= 3'b0;
        rd_D<= 5'b0;
        rs1_D<= 5'b0;
        rs2_D<= 5'b0;
    end
    else if(Branch_or_Jump_taken || id_ex_flush)  begin
        RD1_D <= 32'b0; // reset read data 1
        RD2_D <= 32'b0; // reset read data 2
        PC_D <= 32'b0; // reset program counter
        PCPlus4_D <= 32'b0; // reset PC + 4
        extended_imm_D <= 32'b0; // reset sign-extended immediate value
        ALUControl_D <= 4'b0; // reset ALU control signal
        ResultSrc_D <= 3'b0; // reset result source selection
        MemWrite_D <= 1'b0; // reset memory write enable signal
        RegWrite_D<=1'b0;
        ALUSrc_D <= 1'b0; // reset ALU source selection
        StoreSrc_D <= 2'b0; // reset store source selection
        Branch_D <= 1'b0; // reset branch signal
        Jump_D <= 1'b0; // reset jump signal
        op3_D <= 1'b0; // reset additional control signal for instruction type
        op5_D <= 1'b0; // reset additional control signal for instruction type
        is_load_D <= 1'b0;
        funct3_D<=3'b0;
        rd_D<=5'b0;
        rs1_D<= 5'b0;
        rs2_D<= 5'b0;
    end
     else begin
        RD1_D <= RD1D; // update read data 1
        RD2_D <= RD2D; // update read data 2
        PC_D <= PCD; // update program counter
        PCPlus4_D <= PCPlus4D; // update PC + 4
        extended_imm_D <= extended_immD; // update sign-extended immediate value
        ALUControl_D <= ALUControlD; // update ALU control signal
        ResultSrc_D <= ResultSrcD; // update result sourfce selection
        MemWrite_D <= MemWriteD; // update memory write enable signal
        RegWrite_D <= RegWriteD;
        ALUSrc_D <= ALUSrcD; // update ALU source selection
        StoreSrc_D <= StoreSrcD; // update store source selection
        Branch_D <= BranchD; // update branch signal
        Jump_D <= JumpD; // update jump signal
        op3_D <= op3D; // update additional control signal for instruction type
        op5_D <= op5D; // update additional control signal for instruction type
        is_load_D <= is_loadD;
        funct3_D <= funct3D; // update funct3 field from instruction
        rd_D <= rdD; // update destination register
        rs1_D<= rs1D;
        rs2_D<= rs2D;
    end
end

assign RD1E = RD1_D; // output read data 1 to execute stage
assign RD2E = RD2_D; // output read data 2 to execute stage
assign PCPlus4E = PCPlus4_D; // output PC + 4 to execute
assign PCE = PC_D; // output program counter to execute stage
assign extended_immE = extended_imm_D; // output sign-extended immediate value to
assign ALUControlE = ALUControl_D; // output ALU control signal to execute stage
assign ResultSrcE = ResultSrc_D; // output result source selection to execute stage
assign MemWriteE = MemWrite_D; // output memory write enable signal to execute stage
assign RegWriteE = RegWrite_D;
assign ALUSrcE = ALUSrc_D; // output ALU source selection to execute
assign StoreSrcE = StoreSrc_D; // output store source selection to execute stage
assign BranchE = Branch_D; // output branch signal to execute stage
assign JumpE = Jump_D; // output jump signal to execute stage
assign op3E = op3_D; // output additional control signal for instruction type to execute stage
assign op5E = op5_D; // output additional control signal for instruction type to execute stage
assign funct3E = funct3_D; // output funct3 field from instruction to execute stage
assign rdE = rd_D; // output destination register to execute stage
assign rs1E = rs1_D;
assign rs2E= rs2_D;
assign is_loadE = is_load_D;
endmodule


