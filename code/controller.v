// controller --> main_decoder + ALU_decoder 

`include "main_decoder.v"
`include "alu_decoder.v"

module controller(
    input [31:0] instr,
    //input Z, N, S, U, V, C,
    
    //output   [1:0] PCSrc,
    output [3:0] ALUControl, 
    output   [2:0] ResultSrc,
    output   MemWrite,
    output   ALUSrc,
    output   [1:0] StoreSrc,
    output   [1:0] ImmSrc,
    output   RegWrite,
    //output   [1:0] AluOp,
    output   Branch,
    output   Jump,
    output   op3,
    output   op5,
    output is_load,
    output [2:0] funct3
);



wire [1:0] AluOp;
assign funct3 = instr[14:12];
assign is_load = (instr[6:0]==0000011);
main_decoder main_decoder_inst(
    .opcode(instr[6:0]),
    .funct3(instr[14:12]),
    // .Z(Z),
    // .N(N),
    // .S(S),
    // .U(U),
    // .V(V),
    // .C(C),
    
    //.PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .StoreSrc(StoreSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite),
    .AluOp(AluOp),
    .Branch(Branch),
    .Jump(Jump),
    .op3(op3),
    .op5(op5)
);


alu_decoder alu_decoder_inst(
    .alu_op(AluOp),
	 .op5(instr[5]),
    .funct3(instr[14:12]),
    .funct7_bit5(instr[30]),
    
    .alu_control(ALUControl)
);


endmodule