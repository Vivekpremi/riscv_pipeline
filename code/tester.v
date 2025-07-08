//test fetch cycle
`timescale 1ns/1ns

module tester;

    reg clk;
    reg reset;
    reg [31:0] ALUOut;
    reg [31:0] PCTarget;
    reg [1:0] PCSrc;

    wire [31:0] PCD;
    wire [31:0] instrD;
    wire [31:0] PCPlus4D;

    fetch uut (
        .clk(clk),
        .reset(reset),
        .ALUOut(ALUOut),
        .PCTarget(PCTarget),
        .PCSrc(PCSrc),
        .PCD(PCD),
        .instrD(instrD),
        .PCPlus4D(PCPlus4D)
    );

    initial begin
        $dumpfile("fetch.vcd");
        $dumpvars(0,uut);
        // Initialize signals
        clk = 0;
        reset = 1;
        ALUOut = 32'h00000000;
        PCTarget = 32'h00000000;
        PCSrc = 2'b00;

        // Release reset after some time
        #10 reset = 0;

        // Simulate clock
        // Toggle clock every 5 time units
    end
always begin
        clk =1; 
        #5
        clk =0;
        #5;
    end

    initial begin

#10 
PCSrc =2'b00;
PCTarget = 32'h00000004; // Example target address
ALUOut = 32'h00000008; // Example ALU output    

        // Wait for a few clock cycles to observe the output
        #50;

        // Change PCSrc to test different paths
        PCSrc = 2'b01; // Change to ALUOut
        PCTarget = 32'h00000001; // Example target address
        ALUOut = 32'h00000002;
        #20;
        
        PCSrc = 2'b10; // Change to PCTarget
        PCTarget = 32'h00000006; // Example target address
        ALUOut   = 32'h00000008;
        #20;

        PCSrc = 2'b11; // Change to PCPlus4
        PCTarget = 32'h00000000; // Example target address
        ALUOut = 32'h00000009;
        #20;

        // Finish simulation
        $finish;
    end

endmodule
