// reg file
//2 rd 1 wr file


module reg_file(
    input clk,
    input [4:0] rs1, // source register 1
    input [4:0] rs2, // source register 2
    input [4:0] rd,  // destination register
    input [31:0] wd,  // write data
    input we,         // write enable
    output [31:0] rd1, //read data 1
    output [31:0] rd2  //read data 2
);

reg [31:0] reg_file [0:31]; // 32 registers of 32 bits each

// Initialize the register file to zero
integer i;
initial begin
    for(i=0;i<32;i=i+1)begin
        reg_file[i]=32'b0;
    end
end

// Write logic
always@(posedge clk) begin
   
        if (we && rd != 0) begin
            reg_file[rd] <= wd; // write to rd if we and rd != 0
        end

end

// Combinational read logic
assign rd1 = (rs1 == 0) ? 32'b0 : reg_file[rs1];
assign rd2 = (rs2 == 0) ? 32'b0 : reg_file[rs2];

endmodule