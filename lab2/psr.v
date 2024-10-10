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
        case (alu_sel_i)
            ALU_SEL_ADD: {flags_o[4], flags_o[2]} = {flags_i[4], flags_i[2]};
            ALU_SEL_SUB: {flags_o[4], flags_o[2]} = {flags_i[4], flags_i[2]};
            ALU_SEL_CMP: {flags_o[3], flags_o[1], flags_o[0]} = {flags_i[3], flags_i[1], flags_i[0]};
            default:;
        endcase
    end
end

endmodule

