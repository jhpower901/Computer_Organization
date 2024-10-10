/*
 * CLA does not know A & B are treated as signed or not 
 * So, it passes both F and C flags 
 * opcode selects one of them as jump/branch condition
 * If opcode is signed (e.g., signed overflow, signed compare), 
 * F will be used
 */
module cla16
(
    input [15:0]    A_i,
    input [15:0]    B_i,
    input           CARRYIN_i,

    output          CARRYOUT_no,
    output [1:0]    flag_overflow_o, 
    output [15:0]   sum_o
);

wire [15:0]     A_used_w;   //B-A를 위해 A*(singed)
wire [15:0]     prop_w;     //피연산자1, 2 half sum
wire [15:0]     gen_w;      //피연산자1, 2 half carry out
wire [15:0]     carry_w;
wire [3:0]      gprop_w;  // group-propagate
wire [3:0]      ggen_w;   // group-generate
wire [3:0]      gcarry_w; // group-carry

//carry in에 1이 들어왔을 시 B-A연산 실행, 반전 후 cla4_0 모듈의 carry_i포트 1 전달
assign A_used_w = (CARRYIN_i == 1'b0) ? A_i : ~A_i;
      
assign prop_w = A_used_w ^ B_i;
assign gen_w = A_used_w & B_i;

cla4
    cla4_0(
        .a_i(prop_w[3:0]),
        .b_i(gen_w[3:0]),
        .carry_i(CARRYIN_i),
        .prop_o(gprop_w[0]),
        .gen_o(ggen_w[0]),
        .carry_o(carry_w[3:0])
    );

cla4
    cla4_1(
        .a_i(prop_w[7:4]),
        .b_i(gen_w[7:4]),
        .carry_i(gcarry_w[0]),
        .prop_o(gprop_w[1]),
        .gen_o(ggen_w[1]),
        .carry_o(carry_w[7:4])
    );

cla4
    cla4_2(
        .a_i(prop_w[11:8]),
        .b_i(gen_w[11:8]),
        .carry_i(gcarry_w[1]),
        .prop_o(gprop_w[2]),
        .gen_o(ggen_w[2]),
        .carry_o(carry_w[11:8])
    );

cla4
    cla4_3(
        .a_i(prop_w[15:12]),
        .b_i(gen_w[15:12]),
        .carry_i(gcarry_w[2]),
        .prop_o(gprop_w[3]),
        .gen_o(ggen_w[3]),
        .carry_o(carry_w[15:12])
    );
   
lcu4
    lcu4_0(
        .gprop_i(gprop_w),
        .ggen_i(ggen_w),
        .gcarry_i(CARRYIN_i),
        .gcarry_o(gcarry_w)
    );

assign sum_o[0] = CARRYIN_i ^ prop_w[0];
assign sum_o[15:1] = carry_w[14:0] ^ prop_w[15:1];

/* TODO: please write down code for flag_overflow[0] and [1] 
 * [0] (C-flag): overflow that is meaningful for unsigned operations
 * ADD에서 carry out == 1일 때 overflow
 * SUB에서 singed_bit == 1 & carry out == 0 일 때 overflow
 * MSB까지 이용하여 표현된 unsigned operand의 경우 MSB가 1인 경우에도 carry out이 1이라면 overflow 아니다.
 * [1] (F-flag): overflow that is meaningful for signed operations (2s complement)
**/

assign flag_overflow_o = {carry_w[14] ^ gcarry_w[3],
                        ~CARRYIN_i & gcarry_w[3] | CARRYIN_i & sum_o[15] & ~gcarry_w[3]};
assign CARRYOUT_no = !gcarry_w[3];

endmodule

