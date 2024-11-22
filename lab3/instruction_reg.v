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

localparam NOP = 16'h0020;

always @(posedge rst_i or posedge clk_i) begin
    /* TODO: please write down logic for each output */
    if (rst_i) begin
        inst_o <= 16'b0;
        imm_o <= 8'b0;
        displacement_o <= 8'b0;
        addr_a_o <= 4'b0;
        addr_b_o <= 4'b0;
    end else begin
        if (jump_i | branch_i) begin
            inst_o <= NOP;
            addr_a_o <= 4'h0;          //$rs
            addr_b_o <= 4'h0;          //$rd
            imm_o <= 8'h20;            //immediate
            displacement_o <= 8'h20;   //immediate
        end else begin
            inst_o <= inst_i;
            addr_a_o <= inst_i[3:0];         //$rs
            addr_b_o <= inst_i[11:8];        //$rd
            imm_o <= inst_i[7:0];            //immediate
            displacement_o <= inst_i[7:0];   //immediate
        end
    end
end

endmodule

