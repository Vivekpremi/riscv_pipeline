//mux 2x1

module mux2x1(
    input [31:0] a, b,
    input sel,
    output reg [31:0] y
);
    assign y = (sel) ? b : a; // Select between a and b based on sel
endmodule
