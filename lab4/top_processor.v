module top_processor
(
    //clk & reset
    CLK,
    RESET,
    //instruction memory
    IMEM_ADDRESS,
    IMEM_DATA,
    //data memory
    DMEM_ADDRESS,
    DMEM_DATA_WRITE,
    DMEM_DATA_READ,
    DMEM_WRITE_ENABLE
);

input  CLK;
input  RESET;
output [15:0] IMEM_ADDRESS;
input  [15:0] IMEM_DATA;
output [15:0] DMEM_ADDRESS;
output [15:0] DMEM_DATA_WRITE;
input  [15:0] DMEM_DATA_READ;
output DMEM_WRITE_ENABLE;

wire [15:0] PC_OUT;
wire [15:0] SRC;
wire [15:0] DEST;
wire [15:0] INST_REG_OUT;
wire [7:0] IMM;
wire [7:0] DISP;
wire [3:0] ADDR_A;
wire [3:0] ADDR_B;
wire [4:0] PSR_FLCNZ_IN;
wire [4:0] PSR_FLCNZ_OUT;
wire [4:0] TRI_SEL;
wire [5:0] ALU_SEL;
wire WR;
wire JMP;
wire BR;
wire IMM_EX_SEL;
wire MUX_SEL0;
wire MUX_SEL1;
wire SHIFT_IMM;
wire LUI;
wire WE;
wire [15:0] MUX0_IN_0;
wire [15:0] MUX0_IN_1;
wire [15:0] MUX0_OUT;
wire [15:0] MUX1_IN_0;
wire [15:0] MUX1_IN_1;
wire [15:0] MUX1_OUT;
wire [4:0] MUX2_IN_0;
wire [4:0] MUX2_IN_1;
wire [4:0] MUX2_OUT;
wire [15:0] TRI_BUF0_IN;
wire [15:0] TRI_BUF1_IN;
wire [15:0] TRI_BUF2_IN;
wire [15:0] TRI_BUF3_IN;
wire [15:0] TRI_BUF4_IN;
wire [15:0] RF_DATA_IN;
   
assign IMEM_ADDRESS = PC_OUT;

assign DMEM_ADDRESS = SRC;
assign DMEM_DATA_WRITE = DEST;
assign DMEM_WRITE_ENABLE = WE;

assign MUX0_IN_0 = SRC;
assign MUX0_IN_1[15:8] = (IMM_EX_SEL == 1'b0) ? 8'h0 : {8{IMM[7]}};
assign MUX0_IN_1[7:0] = IMM;
mux16_2to1
    mux16_2to1_0(
        MUX_SEL0,
        MUX0_IN_0, MUX0_IN_1,
        MUX0_OUT
    );

assign MUX1_IN_0 = DEST;
assign MUX1_IN_1[15:8] = (IMM_EX_SEL == 1'b0) ? 8'h0 : {8{IMM[7]}};
assign MUX1_IN_1[7:0] = IMM;
mux16_2to1
    mux16_2to1_1(
        .MUXSEL(MUX_SEL1),
        .Din0(MUX1_IN_0),
        .Din1(MUX1_IN_1),
        .Dout(MUX1_OUT)
    );

assign MUX2_IN_0 = SRC[4:0];
assign MUX2_IN_1 = IMM[4:0];
mux5_2to1
    mux5_2to1_0(
        .MUXSEL(SHIFT_IMM),
        .Din0(MUX2_IN_0),
        .Din1(MUX2_IN_1),
        .Dout(MUX2_OUT)
    );

tristate_buf16
    tristate_buf16_0(
        .ENABLE(TRI_SEL[0]),
        .Din(TRI_BUF0_IN),
        .Dout(RF_DATA_IN)
    );

tristate_buf16
    tristate_buf16_1(
        .ENABLE(TRI_SEL[1]),
        .Din(TRI_BUF1_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF2_IN = MUX0_OUT;
tristate_buf16
    tristate_buf16_2(
        .ENABLE(TRI_SEL[2]),
        .Din(TRI_BUF2_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF3_IN = PC_OUT;
tristate_buf16
    tristate_buf16_3(
        .ENABLE(TRI_SEL[3]),
        .Din(TRI_BUF3_IN),
        .Dout(RF_DATA_IN)
    );

assign TRI_BUF4_IN = DMEM_DATA_READ;
tristate_buf16
    tristate_buf16_4(
        .ENABLE(TRI_SEL[4]),
        .Din(TRI_BUF4_IN),
        .Dout(RF_DATA_IN)
    );

`include "../lab1/register_file.v"
`include "..lab2/ALU_modes.vh"
`include "..lab2/alu.v"
`include "..lab2/cla4.v"
`include "..lab2/cla16.v"
`include "..lab2/lcu4.v"
`include "..lab2/psr.v"
`include "..lab2/shifter.v"
`include "..lab3/decoder.v"
`include "..lab3/instruction_reg.v"
`include "..lab3/opcodes.vh"
`include "..lab3/pc.v"

/* TODO: Please wire all components: shifter, RF, PSR, PC, IR, ALU, decoder */
shifter u_shift(
    .data_i(data_i),
    .rl_shift_amt_i(rl_shift_amt),
    .lui_i(lui),

    .data_o(data_o)
);

register_file u_rf(
    .rst_i(RESET),
    .clk_i(CLK),
    .wr_i(wr),
    .data_i(wdata_w),
    .addr_a_i(addrA),
    .addr_b_i(addrB),

    .data_a_o(dout_a_w),
    .data_b_o(dout_b_w)
);

alu u_alu(
    .A_i(data_a),
    .B_i(data_b),
    .alu_sel_i(alu_sel),

    .flags_o(flags_w),
    .alu_o(alu_w)
);

psr u_psr(
    .rst_i(RESET),
    .clk_i(CLK),
    .alu_sel_i(alu_sel),
    .flags_i(flags_w),

    .flags_o(flags_o)
);

pc u_pc(
    .rst_i(RESET),
    .clk_i(CLK),
    .jump_i(jmp),
    .branch_i(br),
    .displacement_i(disp_w),
    .jump_tgt_i(jmp_tgt),

    .addr_imem_o(inst_ptr)
);

instruction_reg u_ir(
    .rst_i(RESET),
    .clk_i(CLK),
    .jump_i(jmp),
    .branch_i(br),
    .inst_i(inst_i),

    .inst_o(inst_w),
    .imm_o(imm_w),
    .displacement_o(disp_w),
    .addr_a_o(addrA),
    .addr_b_o(addrB)
);

decoder u_id(
    .inst_i(inst_w),
    .psr_flags_i(psr_flags),

    .TRI_SEL(),
    .ALU_SEL(),
    .WR(),
    .JMP(jmp),
    .BR(br),
    .MUX_SEL0(),
    .MUX_SEL1(),
    .SHIFT_IMM(),
    .LUI(),
    .WE()
);
endmodule

