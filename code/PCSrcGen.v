//PCSrcGen


module PCSrcGen(
    input Jump,
    input Branch,
    input Z,S,U,op3,
    input [2:0] funct3,
    output [1:0] PCSrc
);
wire Branch_condition;

assign Branch_condition = (funct3 == 3'b000 && Z) || //BEQ
                        (funct3 == 3'b001 && !Z) || //BNE
                        (funct3 == 3'b100 && S) || //BLT
                        (funct3 == 3'b101 && !S) || //BGE
                        (funct3 == 3'b110 && U) || //BLTU


 assign PCSrc = ((Branch && Branch_condition) || (Jump  && opcode[3])) ? 2'b01 :
                (Jump && ~opcode[3]) ? 2'b10 :
                2'b00;

endmodule


