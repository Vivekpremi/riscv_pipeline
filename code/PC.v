//PC reg

module pc(
    input [31:0] PCNext, // next PC value
    input clk,          // clock signal
    input rst,          // reset signal
    output reg [31:0] PC // current PC value
);
    always@(posedge clk or posedge rst) begin
        if(rst) PC<=32'b0;
        else PC<=PCNext;
    end
endmodule