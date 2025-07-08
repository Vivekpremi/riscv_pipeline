//write back cycle
`include "8x1mux.v"
module writeback(
    input clk,
    input reset,
    input [31:0] ALUOutW, // ALU output from memory stage
    input [31:0] ReadDataMemW, // Data read from memory
    input [31:0] LUI_or_AUIPCW, // LUI or AUIPC value for writeback stage
    input [31:0] PCPlus4W, // PC + 4 for writeback stage
    input [31:0] PCW,
    input [2:0] ResultSrcW, // Result source selection for writeback stage
    input RegWriteW, // Register write enable signal for writeback stage
    input [4:0] rdW, // Destination register for writeback stage
    output [31:0] ResultW2F, // Data to be written back to register file
    output RegWriteW2F, // Register write enable signal for register file
    output [4:0] rdW2F, // Destination register from writeback to  decode stage
    //output to execute stage
    output [31:0] ResultW2E,
    //output to hazard unit
    output RegWriteW2H,
    output [4:0] rdW2H // Destination register for writeback stage
);



mux8x1 result_mux(
    .a(ALUOutW), // ALU result
    .b(LUI_or_AUIPCW), // LUI or AUIPC
    .c({{24{ReadDataMemW[7]}},ReadDataMemW[7:0]}), // lb
    .d({{16{ReadDataMemW[15]}},ReadDataMemW[15:0]}), // lh
    .e(ReadDataMemW), // lw
    .f({24'b0,ReadDataMemW[7:0]}), // lbu
    .g({16'b0,ReadDataMemW[15:0]}), // lhu
    .h(PCPlus4W), // jump
    .sel(ResultSrcW),
    .y(ResultW2F)
);
assign RegWriteW2H = RegWriteW;
assign RegWriteW2F = RegWriteW;
assign ResultW2E = ResultW2F;
assign rdW2F = rdW; // Destination register for writeback stage
assign rdW2H = rdW; // Destination register for writeback stage
endmodule


