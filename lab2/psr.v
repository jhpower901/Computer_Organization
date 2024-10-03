/*
 * Program status register
 * FLCNZ for each bit [4:0]
 */

module psr
(
    input       rst_i,
    input       clk_i,
    input [5:0] alu_sel_i,
    input [4:0] flags_i,        //FLCNZ
    
    output reg [4:0] flags_o    //selected FLCNZ
);

`include "ALU_modes.vh"

always @(posedge rst_i or posedge clk_i) begin
    if (rst_i == 1'b1)
        flags_o <= 0;
    else begin
        /* TODO: write down codes for propagating flags */
    end
end

endmodule

