module register_file
(
    input           rst_i,
    input           clk_i,
    input           wr_i,
    input [15:0]    data_i,
    input [3:0]     addr_a_i,
    input [3:0]     addr_b_i,

    output reg [15:0] data_a_o,
    output reg [15:0] data_b_o
);

reg [15:0] reg0_r;
reg [15:0] reg1_r;
reg [15:0] reg2_r;
reg [15:0] reg3_r;
reg [15:0] reg4_r;
reg [15:0] reg5_r;
reg [15:0] reg6_r;
reg [15:0] reg7_r;
   
always @(posedge rst_i or posedge clk_i) begin
    if (rst_i == 1'b1) begin
        reg0_r <= 16'h0;
        reg1_r <= 16'h0;
        reg2_r <= 16'h0;
        reg3_r <= 16'h0;
        reg4_r <= 16'h0;
        reg5_r <= 16'h0;
        reg6_r <= 16'h0;
        reg7_r <= 16'h0;
    end
    else begin
        /* TODO: write down your reg update code */
        if (wr_i) begin
            /* wr_i가 asset되었을 때 synchronus하게 register값 업데이트
             * demultiplexer로 합성되었으면 좋겠음
             */
            case (addr_b_i)
                0: reg0_r = data_i;
                1: reg1_r = data_i;
                2: reg2_r = data_i;
                3: reg3_r = data_i;
                4: reg4_r = data_i;
                5: reg5_r = data_i;
                6: reg6_r = data_i;
                7: reg7_r = data_i;
                default:;
            endcase
        end
    end
end

/* TODO: write down your reg reads (data_*_o) code */
/* 출력 레지스터 비동기 업데이트
 * address가 업데이트 되었을 때 output register에 비동기 업데이트
 */
always @(addr_a_i or addr_b_i) begin
    //demultiplexer로 합성되면 좋겠음
    case (addr_a_i[2:0])
        0: data_a_o = reg0_r;
        1: data_a_o = reg1_r;
        2: data_a_o = reg2_r;
        3: data_a_o = reg3_r;
        4: data_a_o = reg4_r;
        5: data_a_o = reg5_r;
        6: data_a_o = reg6_r;
        7: data_a_o = reg7_r;
        default:;
    endcase
        case (addr_b_i[2:0])
        0: data_b_o = reg0_r;
        1: data_b_o = reg1_r;
        2: data_b_o = reg2_r;
        3: data_b_o = reg3_r;
        4: data_b_o = reg4_r;
        5: data_b_o = reg5_r;
        6: data_b_o = reg6_r;
        7: data_b_o = reg7_r;
        default:;
    endcase
end
endmodule
