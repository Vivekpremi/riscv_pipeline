module alu(
    input       [31:0] A, B,       // operands
    input       [3:0] ALUCtrl,         // ALU control
    output reg  [31:0] alu_out,    // ALU output
    output      Z,N,V,C,S,U             // zero flag
);
wire Cout;
wire [31:0] sum;

assign {Cout,sum} = (ALUCtrl[0])? A + ~B + 1 : A + B ; // Sum for addition and subtraction
always @(*) begin
    case (ALUCtrl)
        4'b0000:  alu_out = sum;       // ADD
        4'b0001:  alu_out = sum;  // SUB
        4'b0010:  alu_out = A & B;       // AND
        4'b0011:  alu_out = A | B;       // OR
        4'b0100:  alu_out = A << B[4:0];//slli
        4'b0101:  alu_out = {31'b0,S};//slt,slti
        4'b0110:  alu_out = A >> B[4:0];// srl,srli
        4'b0111:  alu_out = A ^ B;       // XOR
        4'b1000:  alu_out = $signed(A) >>> B[4:0];// Srai,sra
        4'b1001:  alu_out = {31'b0,U};        //sltu
        default:  alu_out = 0;
    endcase
end

assign Z = (alu_out == 0) ? 1'b1 : 1'b0;
assign N= alu_out[31]; // Negative flag
assign S= ($signed(A) < $signed(B)); // Signed comparison for SLT and SLTI
assign U = (A < B); // Unsigned comparison for SLTU
assign V = ((sum[31] ^ A[31]) & 
                      (~(ALUCtrl[0] ^ B[31] ^ A[31])) &
                      (~ALUCtrl[1]));
assign C= Cout && ~ALUCtrl[0];

endmodule
