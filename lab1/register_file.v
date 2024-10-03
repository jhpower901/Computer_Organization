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
    end
end

/* TODO: write down your reg reads (data_*_o) code */

endmodule
