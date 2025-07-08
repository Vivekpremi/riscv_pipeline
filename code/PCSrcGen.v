//PCSrcGen


module PCSrcGen(
    input Jump,
    input Branch,
    input Z,S,U,op3,
    input [2:0] funct3,
    output [1:0] PCSrc,
    output Branch_or_Jump_taken
);
wire Branch_condition;

assign Branch_condition = (funct3 == 3'b000 && Z) || //BEQ
                        (funct3 == 3'b001 && !Z) || //BNE
                        (funct3 == 3'b100 && S) || //BLT
                        (funct3 == 3'b101 && !S) || //BGE
                        (funct3 == 3'b110 && U) || //BLTU
                        (funct3 == 3'b111 && !U); //BGEU

 assign PCSrc = ((Branch && Branch_condition) || (Jump  && op3)) ? 2'b01 :
                (Jump && ~op3) ? 2'b10 :
                2'b00;
                
assign Branch_or_Jump_taken = (Branch && Branch_condition) ;

endmodule


