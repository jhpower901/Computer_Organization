module alu
(
	input [15:0] A_i,
	input [15:0] B_i,
	input [5:0]  alu_sel_i,

	output     [4:0]    flags_o, // F, L, C, N, Z
	output reg [15:0]   alu_o
);

`include "ALU_modes.vh"

reg CARRYIN_w;
wire CARRYOUT_nw;
wire [1:0] alu_ovf_w;
wire [15:0] cla_sum_w;
   
cla16
	cla16_0(
		.A_i(A_i),
		.B_i(B_i),
		.CARRYIN_i(CARRYIN_w),
		.CARRYOUT_no(CARRYOUT_nw),
		.flag_overflow_o(alu_ovf_w),
		.sum_o(cla_sum_w)
	);

/* TODO: Please write down codes for flags_o[4], ..., [0]
 * [4:0] flags_o = {F, L, C, N, Z} in order
 * F flag : overflow / underflow @ signed ADD/ SUB
 * L flag : B<A @ unsigned CMP -> cla16에서 B-A < 0
 * 
 * C flag : overflow / underflow @unsigned ADD/SUB
 * N flag : B<A @ signed CMP -> 결과가 음수일 때
 * Z flag : A==B @ CMP -> sum이 0일 때
 */
assign flags_o = {alu_ovf_w[1], alu_ovf_w[0], alu_ovf_w[0], alu_ovf_w[1] | cla_sum_w[15], (~|cla_sum_w) & ~|alu_ovf_w};

always @(*) begin
	CARRYIN_w = 1'b0;
	alu_o = cla_sum_w;

	case (alu_sel_i)
	ALU_SEL_SUB:
		CARRYIN_w = 1'b1;
	ALU_SEL_CMP:
		CARRYIN_w = 1'b1;
	ALU_SEL_AND:
		alu_o = A_i & B_i;
	ALU_SEL_OR:
		alu_o = A_i | B_i;
	ALU_SEL_XOR:
		alu_o = A_i ^ B_i;
	default:
		;
	endcase
end

endmodule

