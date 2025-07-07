// ALU DECODER


module alu_decoder(

    input [1:0] alu_op,
    input [2:0] funct3,
	 input op5,
    input funct7_bit5, // 5th bit of funct7

    output reg [3:0] alu_control
);

always@(*) begin
    case(alu_op)
        2'b00: alu_control = 4'b0000; // ALU operation for load/store (add)
        2'b01: alu_control = 4'b0001; // ALU operation for branch (subtract)
        2'b10: begin // R-type instructions
            case(funct3)
                3'b000: alu_control = (funct7_bit5 && op5) ? 4'b0001 : 4'b0000; // add,addi,sub
                3'b001: alu_control = 4'b0100; // SLL,SLLI
                3'b010: alu_control = 4'b0101; // SLT,SLTI
                3'b011: alu_control = 4'b1001; // SLTU
                3'b100: alu_control = 4'b0111; // XOR,XORI
                3'b101: alu_control = (funct7_bit5) ? 4'b1000 : 4'b0110; // SRL or SRA
                3'b110: alu_control = 4'b0011; // OR
                3'b111: alu_control = 4'b0010; // AND
            endcase
        end
        default: alu_control = 4'b0000; // Default case, no operation
    endcase
end

endmodule