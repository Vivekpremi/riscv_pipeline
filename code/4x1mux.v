//4X1 mux


module mux4x1(
    input [31:0] a, b, c, d,
    input [1:0] sel,
    output  [31:0] y
);
    assign y = (sel == 2'b00) ? a : 
               (sel == 2'b01) ? b : 
               (sel == 2'b10) ? c : 
               d; // Select between a, b, c, and d based on sel

endmodule