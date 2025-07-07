// instruction memory


module instr_mem(
    input [31:0] PC, // Program Counter
    output  [31:0] instr // Instruction output
);


// array of 64 32-bit words or instructions
reg [31:0] instr_ram [0:511];

initial begin
   // $readmemh("rv32i_book.hex", instr_ram);
     $readmemh("rv32i_test.hex", instr_ram);
end

// word-aligned memory access
// combinational read logic
assign instr = instr_ram[PC[31:2]];

endmodule




