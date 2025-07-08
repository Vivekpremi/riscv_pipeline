//hazardunit


module hazardunit(
 
    input wire [4:0] rs1E, rs2E, rdM,rdW,rdE,rs1D,rs2D,
    input wire is_load,
    input wire RegWriteM,RegWriteW,
    input wire branch_taken,

    output wire[1:0] rd1Esrc,
    output wire [1:0] rd2Esrc,
    output wire Branch_or_Jump_taken,
    output pc_write,id_ex_flush
);
//

wire stall;

    assign rd1Esrc = (rs1E == rdM && RegWriteM && rdM != 5'b0) ? 2'b01 :
                     (rs1E == rdW && RegWriteW && rdW != 5'b0) ? 2'b10 : 2'b00;

    assign rd2Esrc = (rs2E == rdM && RegWriteM && rdM != 5'b0) ? 2'b01 :
                     (rs2E == rdW && RegWriteW && rdW != 5'b0) ? 2'b10 : 2'b00;
// control hazard
assign Branch_or_Jump_taken = branch_taken;

//load hazard
assign stall = (is_load)&&((rdE == rs1D|| rdE == rs2D) && rdE!=5'b0 );
assign id_ex_flush = stall;
assign pc_write = ~stall;

endmodule 