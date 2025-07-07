//memory cycle


module memory(
    input clk,
    input reset,
    input [31:0] ALUOutM, // ALU output from execute stage
    input [31:0] MemWriteDataM, // Data to be written to memory
    input MemWriteM, // Memory write enable signal
    input [31:0] LUI_or_AUIPCM, // LUI or AUIPC value for memory stage
    input [31:0] PCPlus4M, // PC + 4 from execute
    input [2:0] ResultSrcM, // Result source selection
    input RegWriteM, // Register write enable signal

    output [31:0] ALUOutW, // ALU output for writeback stage
    output [31:0] ReadDataMemW, // Data read from memory
    output [31:0] LUI_or_AUIPCW, // LUI or AUIPC value for writeback stage
    output [31:0] PCPlus4W, // PC + 4 for writeback stage
    // control outputs
    output [2:0] ResultSrcW, // Result source selection for writeback stage
    output RegWriteW // Register write enable signal for writeback stage
);

wire [31:0] ReadDataMemM;
reg [31:0] ReadDataMem_M,ALUOut_M,LUI_or_AUIPCM_M,PCPlus4_M;
reg RegWrite_M;
reg [2:0] ResultSrc_M;

data_mem data_mem(
   .clk(clk),
   .address(ALUOutM),// may be read or write
   .write_data(MemWriteDataM),
   .we(MemWriteM), // write enable
   .read_data(ReadDataMemM)
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ReadDataMem_M <= 32'b0;
        ALUOut_M <= 32'b0;
        LUI_or_AUIPCM_M <= 32'b0;
        PCPlus4_M <= 32'b0;
        RegWrite_M <= 1'b0;
        ResultSrc_M <= 3'b0;
    end else begin
        ReadDataMem_M <= ReadDataMemM; // Update read data from memory
        ALUOut_M <= ALUOutM; // Update ALU output
        LUI_or_AUIPCM_M <= LUI_or_AUIPCM; // Update LUI or AUIPC value
        PCPlus4_M <= PCPlus4M; // Update PC + 4 value
        RegWrite_M <= RegWriteM; // Enable register write if ResultSrc is not zero
        ResultSrc_M <= ResultSrcM; // Update result source selection
    end

end

assign ReadDataMemW = ReadDataMem_M; // Output the read data from memory
assign ALUOutW = ALUOut_M; // Output the ALU result
assign LUI_or_AUIPCW = LUI_or_AUIPCM_M; // Output the LUI or AUIPC value
assign PCPlus4W = PCPlus4_M; // Output the PC + 4 value
assign ResultSrcW = ResultSrc_M; // Output the result source selection
assign RegWriteW = RegWrite_M; // Output the register write enable signal

endmodule
       