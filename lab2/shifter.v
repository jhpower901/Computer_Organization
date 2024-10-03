module shifter
(
	input [15:0]    data_i,
	input [4:0]     rl_shift_amt_i,
	input           lui_i,

	output [15:0]   data_o
);

wire [30:0] stage_0;
wire [22:0] stage_1;
wire [18:0] stage_2;
wire [16:0] stage_3;
wire [15:0] stage_4;

/* TODO: Please write down codes for each stage */

assign data_o = (lui_i == 1'b1) ? {data_i[7:0], 8'h0} : stage_4;

endmodule

