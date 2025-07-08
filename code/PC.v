//PC reg

module pc(
    input [31:0] PCNext, // next PC value
    input clk,  
    input pc_we,        // clock signal
    input rst,          // reset signal
    output [31:0] PC // current PC value
);

reg [31:0] pc;
    always@(posedge clk or posedge rst) begin
        if(rst) pc<=32'b0;
        else if(pc_we) pc<=PCNext;
        else pc<=pc;
    end

    assign PC = pc;
endmodule