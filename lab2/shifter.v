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
/* 오른쪽 shift 연산만을 이용해 양방향 shift 구현
 * amount가 음수일 때 오른쪽 shift, 양수일 때 왼쪽 shift
 * <Right shift> key: abs = ~amount + 1
 * 오른쪽 shift는 음수의 절댓값 만큼 이동시켜야 하므로, stage_0에서 1만큼 오른쪽 shift
 * 이후 amount를 반전하여 해당하는 크기만큼 shift (2의 보수 절댓값)
 * <Left shift> key: 왼쪽으로 15bit shift 후 되돌려 놓기
 * 왼쪽으로 정보 손실 없이 15bit shift 시킨 후 amount 반전시켜 오른쪽으로 돌려놓는다
 * amount == 00001 인 경우
 * {data, 15'b0} -> {data, 7'b0} -> {data, 3'b0} -> {data, 1'b0} -> {data[14:0], 1'b0}
 * 결과적으로 왼쪽으로 한 bit shift 된다.
 * amount를 반전시켜 이용하는 것이 핵심
 */
assign stage_0 = rl_shift_amt_i[4] == 1'b0 ? {data_i, 15'b0} : {1'b0, data_i[15:1]};
assign stage_1 = rl_shift_amt_i[3] == 1'b0 ? stage_0[30:8] : stage_0[22:0];
assign stage_2 = rl_shift_amt_i[2] == 1'b0 ? stage_1[22:4] : stage_1[18:0];
assign stage_3 = rl_shift_amt_i[1] == 1'b0 ? stage_2[18:2] : stage_2[16:0];
assign stage_4 = rl_shift_amt_i[0] == 1'b0 ? stage_3[16:1] : stage_3[15:0];

//lui input: treat rl_shift_amt_i ad dont'care and simply shift left for 8 bits
assign data_o = (lui_i == 1'b1) ? {data_i[7:0], 8'h0} : stage_4;

endmodule

