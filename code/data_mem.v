//data memory


module data_mem(
    input clk,
    input [31:0] address,// may be read or write
    input [31:0] write_data,
    input we, // write enable
    output  [31:0] read_data

);

reg [31:0] data_memory [0:63];// 32 X 64

assign read_data = data_memory[address[31:2]%64];


always @(posedge clk) begin
    if(we) begin
        data_memory[address[31:2]%64] <= write_data;
    end
end

endmodule