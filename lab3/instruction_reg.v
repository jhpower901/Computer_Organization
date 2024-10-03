module instruction_reg
(
    input        rst_i,
    input        clk_i,
    input        jump_i,
    input        branch_i,
    input [15:0] inst_i,

    output reg [15:0]   inst_o,
    output reg [7:0]    imm_o,
    output reg [7:0]    displacement_o,
    output reg [3:0]    addr_a_o,
    output reg [3:0]    addr_b_o
);

always @(posedge rst_i or posedge clk_i) begin
    /* TODO: please write down logic for each output */
end

endmodule

