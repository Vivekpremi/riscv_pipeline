//sign extender

module sign_extender(
    input [1:0] imm_src, 
    input [24:0] semi_instr, 
    input [2:0] opcode654,
    output wire [31:0] sign_extended_imm 
);

    assign sign_extended_imm = (imm_src == 2'b00) ? ((opcode654 == 2'b010) ? {{20{semi_instr[24]}}, {semi_instr[24:18]}, {semi_instr[4:0]}} : {{20{semi_instr[24]}}, semi_instr[24:13] }) : // S-type , I-type & Jalr
                               (imm_src == 2'b01) ? {semi_instr[24:5], 12'b0} : // U-type
                               (imm_src == 2'b10) ? {{19{semi_instr[24]}}, semi_instr[24], semi_instr[0], semi_instr[23:18], semi_instr[4:1], 1'b0} :    // B-type
                               (imm_src == 2'b11) ? {{11{semi_instr[24]}}, semi_instr[24], semi_instr[12:5], semi_instr[13], semi_instr[23:14], 1'b0} : // Jal
                               32'b0; // Default case

endmodule
