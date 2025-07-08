//8x1 mux

module mux8x1(
    input [31:0] a, b, c, d, e, f, g, h,
    input [2:0] sel,
    output  [31:0] y
);
    assign y = (sel == 3'b000) ? a : 
               (sel == 3'b001) ? b : 
               (sel == 3'b010) ? c : 
               (sel == 3'b011) ? d : 
               (sel == 3'b100) ? e : 
               (sel == 3'b101) ? f : 
               (sel == 3'b110) ? g : 
               h; // Select between a, b, c, d, e, f, g, and h based on sel
endmodule
