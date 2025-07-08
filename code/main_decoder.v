// main decoder


module main_decoder(
    input [6:0] opcode,
    input [2:0] funct3,
    //input Z,N,S,U,V,C,

   // output [1:0] PCSrc,
    output [2:0] ResultSrc,
    output op3,op5,
    output MemWrite,
    output ALUSrc,
    output [1:0] StoreSrc,
    output [1:0]ImmSrc,
    output RegWrite,
    output [1:0] AluOp,
    output Branch,
    output Jump
);
wire Branch_condition;
wire [10:0] controls;


// PCPlus4 00 
// PCTarget 01 // covers branch instructions and jal
// JALR Aluout 10 
//
//  assign PCSrc = (Branch || (Jump  && opcode[3])) ? 2'b01 :
//                 (Jump && ~opcode[3]) ? 2'b10 :
//                 2'b00;

                            //ResultSrc
//ALU 0110011   @Rtype         000
//AUIPC 0010111                001
       //op       funct3
// lb 0000011 && 000           010
// lh 0000011 && 001           011
// lw 0000011 && 010           100
// lbu 0000011 && 100          101
// lhu 0000011 && 101          110
//jump                          111
assign ResultSrc = (opcode == 7'b0110011) ? 3'b000 : //R-type
                   (opcode == 7'b0010111 || opcode == 7'b0110111) ? 3'b001 : //AUIPC or LUI
                   (opcode == 7'b0000011 && funct3 == 3'b000) ? 3'b010 : //lb
                   (opcode == 7'b0000011 && funct3 == 3'b001) ? 3'b011 : //lh
                   (opcode == 7'b0000011 && funct3 == 3'b010) ? 3'b100 : //lw
                   (opcode == 7'b0000011 && funct3 == 3'b100) ? 3'b101 : //lbu
                   (opcode == 7'b0000011 && funct3 == 3'b101) ? 3'b110 : //lhu
                   (Jump)? 3'b111 : 3'b000; //default

assign MemWrite = (opcode == 7'b0100011) ? 1'b1 : 1'b0; //store

assign StoreSrc = (funct3 == 3'b000) ? 2'b00 : //sb
                  (funct3 == 3'b001) ? 2'b01 : //sh
                  (funct3 == 3'b010) ? 2'b10 : //sw
                  2'b11; //default

assign ALUSrc = (opcode == 7'b0110011 || opcode==7'b1100011) ? 1'b0 : 1'b1; //0 for R type else 1

// AUIPC 0010111    001
// LUI 0110111      010
// Branch 1100011   011
// JAL 1101111      100
// default          000
assign ImmSrc = (opcode == 7'b0010111 || opcode == 7'b0110111) ? 2'b01 : //U-type
                (opcode == 7'b1100011) ? 2'b10 : //Branch
                (opcode == 7'b1101111) ? 2'b11 : //JAL
                2'b00; //default
//

assign RegWrite = (opcode == 7'b0010011 || opcode == 7'b0000011  || opcode == 7'b0110011 || opcode == 7'b0110111|| opcode == 7'b0010111  || opcode == 7'b1101111 || opcode == 7'b1100111) ? 1'b1 : 1'b0; //I-type,R-type,AUIPC,LUI,JAL,JALR

assign AluOp = (opcode == 7'b0000011 || opcode == 7'b0100011) ? 2'b00 : //load and store
               (opcode == 7'b1100011) ? 2'b01 : //Branch
               2'b10; //default

assign Branch = (opcode == 7'b1100011) ;//&&  Branch_condition; //Branch instruction

// assign Branch_condition = (funct3 == 3'b000 && Z) || //BEQ
//                         (funct3 == 3'b001 && !Z) || //BNE
//                         (funct3 == 3'b100 && S) || //BLT
//                         (funct3 == 3'b101 && !S) || //BGE
//                         (funct3 == 3'b110 && U) || //BLTU
//                         (funct3 == 3'b111 && !U); //BGEU

assign Jump = (opcode == 7'b1101111) || (opcode == 7'b1100111); //JAL and JALR

assign op3 = opcode[3];
assign op5 = opcode[5];
endmodule



