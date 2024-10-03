module pc
(
    input        rst_i,
    input        clk_i,
    input        jump_i,
    input        branch_i,
    input [7:0]  displacement_i,
    input [15:0] jump_tgt_i,

    output [15:0] addr_imem_o // this is instruction pointer!
);

wire [15:0] disp_signEx_c;
wire [15:0] addr_incr_c;
wire [15:0] next_addr_imem_w;
reg [15:0] curr_addr_imem_r;

wire dummy_co_w;
wire [1:0] dummy_fc_w;

assign disp_signEx_c[15:8] = {8{displacement_i[7]}};
assign disp_signEx_c[7:0] = displacement_i;
assign addr_incr_c = (branch_i == 1'b0) ? 16'b1 : disp_signEx_c;

assign addr_imem_o = curr_addr_imem_r;

cla16
    cla16_0(
        .A_i(addr_incr_c),
        .B_i(curr_addr_imem_r),
        .CARRYIN_i(1'b0),
        .CARRYOUT_no(dummy_co_w),
        .flag_overflow_o(dummy_fc_w),
        .sum_o(next_addr_imem_w)
    );

/* TODO: please write down logic for curr_addr_imem */

endmodule

