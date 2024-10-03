module decoder
(
    input [15:0]    inst_i,
    input [4:0]     psr_flags_i,

    output reg [4:0] TRI_SEL,
    output reg [5:0] ALU_SEL,
    output reg       WR,
    output reg       JMP,
    output reg       BR,
    output reg       IMM_EX_SEL,
    output reg       MUX_SEL0,
    output reg       MUX_SEL1,
    output reg       SHIFT_IMM,
    output reg       LUI,
    output reg       WE
);

`include "ALU_modes.vh"
`include "opcodes.vh"

parameter TRI_SEL_MEM = 5'b10000;
parameter TRI_SEL_PC  = 5'b01000;
parameter TRI_SEL_REG = 5'b00100;
parameter TRI_SEL_ALU = 5'b00010;
parameter TRI_SEL_SHI = 5'b00001;
   
wire [3:0] opcode;
wire [3:0] Rdest;
wire [7:0] imm;
wire [3:0] opcode_ex;
wire [3:0] Rsrc;

assign opcode = inst_i[15:12];
assign Rdest = inst_i[11:8];
assign imm = inst_i[7:0];
assign opcode_ex = inst_i[7:4];
assign Rsrc = inst_i[3:0];

always @(*) begin
    ////////////////////////////////////////////////////////////////////////////
    // WE set
    ////////////////////////////////////////////////////////////////////////////
    WE = 1'b0;   // default value
    if ((opcode == MEM_OP) && (opcode_ex == STOR_OPex))
        WE = 1'b1;

    ////////////////////////////////////////////////////////////////////////////
    // LUI set
    ////////////////////////////////////////////////////////////////////////////
    LUI = 1'b0;   // default value
    if (opcode == LUI_OP)
        LUI = 1'b1;

    ////////////////////////////////////////////////////////////////////////////
    // SHIFT_IMM set
    ////////////////////////////////////////////////////////////////////////////
    SHIFT_IMM = 1'b0;   // default value
    if ((opcode == SHI_OP) && (opcode_ex[3:1] == SHII_OPex))
        SHIFT_IMM = 1'b1;

    ////////////////////////////////////////////////////////////////////////////
    // MUX_SEL set
    ////////////////////////////////////////////////////////////////////////////
    MUX_SEL0 = 1'b0;   // default value
    MUX_SEL1 = 1'b0;   // default value

    if ( (opcode == ADDI_OP) || (opcode == SUBI_OP) || (opcode == CMPI_OP) ||
         (opcode == ANDI_OP) || (opcode == ORI_OP) || (opcode == XORI_OP) ||
         (opcode == MOVI_OP) || (opcode == LUI_OP) )
    begin
        MUX_SEL0 = 1'b1;
        MUX_SEL1 = 1'b1;
    end

    IMM_EX_SEL = 1'b0;
    if ( (opcode == ADDI_OP) || (opcode == SUBI_OP) || (opcode == CMPI_OP) )
        IMM_EX_SEL = 1'b1;

    ////////////////////////////////////////////////////////////////////////////
    // JMP set
    ////////////////////////////////////////////////////////////////////////////
    JMP = 1'b0;   // default value
    /* TODO: write logic for JMP, you need to consider JAL and Jcond */

    ////////////////////////////////////////////////////////////////////////////
    // BR set
    ////////////////////////////////////////////////////////////////////////////
    BR = 1'b0;   // default value
    /* TODO: write logic for JMP, you need to consider JAL and Jcond */

    ////////////////////////////////////////////////////////////////////////////
    // WR set
    ////////////////////////////////////////////////////////////////////////////
    WR = 1'b0;   // default value
    if ( ((opcode == ALU_OP) && (opcode_ex == ADD_OPex)) ||
         ((opcode == ALU_OP) && (opcode_ex == SUB_OPex)) ||
         ((opcode == ALU_OP) && (opcode_ex == AND_OPex)) ||
         ((opcode == ALU_OP) && (opcode_ex == OR_OPex)) ||
         ((opcode == ALU_OP) && (opcode_ex == XOR_OPex)) ||
         ((opcode == ALU_OP) && (opcode_ex == MOV_OPex)) ||
         (opcode == ADDI_OP) || (opcode == SUBI_OP) || (opcode == ANDI_OP) ||
         (opcode == ORI_OP) || (opcode == XORI_OP) || (opcode == MOVI_OP) ||
         (opcode == SHI_OP) || (opcode == LUI_OP) ||
         ((opcode == MEM_OP) && (opcode_ex == LOAD_OPex)) ||
         ((opcode == MEM_OP) && (opcode_ex == JAL_OPex)) // LOAD, JAL
     ) begin
        WR = 1'b1;
    end

    ////////////////////////////////////////////////////////////////////////////
    // ALU_SEL set
    ////////////////////////////////////////////////////////////////////////////
    ALU_SEL = ALU_SEL_OR;   // default operation
    if ( ((opcode == ALU_OP) && (opcode_ex == ADD_OPex)) ||
         (opcode == ADDI_OP) )
        ALU_SEL = ALU_SEL_ADD;
   
    else if ( ((opcode == ALU_OP) && (opcode_ex == SUB_OPex)) ||
         (opcode == SUBI_OP) )
       ALU_SEL = ALU_SEL_SUB;
   
    else if ( ((opcode == ALU_OP) && (opcode_ex == CMP_OPex)) ||
         (opcode == CMPI_OP) )
       ALU_SEL = ALU_SEL_CMP;
   
    else if ( ((opcode == ALU_OP) && (opcode_ex == AND_OPex)) ||
         (opcode == ANDI_OP) )
       ALU_SEL = ALU_SEL_AND;
   
    else if ( ((opcode == ALU_OP) && (opcode_ex == XOR_OPex)) ||
         (opcode == XORI_OP) )
       ALU_SEL = ALU_SEL_XOR;
   
    ////////////////////////////////////////////////////////////////////////////
    // TRI_SEL set
    ////////////////////////////////////////////////////////////////////////////
    TRI_SEL = TRI_SEL_REG;   // default value
    if ((opcode == MEM_OP) && (opcode_ex == LOAD_OPex))
        TRI_SEL = TRI_SEL_MEM;
   
    else if ((opcode == MEM_OP) && (opcode_ex == JAL_OPex))
        TRI_SEL = TRI_SEL_PC;
   
    else if (((opcode == ALU_OP) && (opcode_ex != MOV_OPex)) ||
        (opcode == ADDI_OP) || (opcode == SUBI_OP) || 
        (opcode == CMPI_OP) || (opcode == ANDI_OP) || 
        (opcode == ORI_OP) || (opcode == XORI_OP))
        TRI_SEL = TRI_SEL_ALU;
   
    else if (((opcode == SHI_OP) && (opcode_ex == SHII_OPex)) ||
        (opcode == LUI_OP))
        TRI_SEL = TRI_SEL_SHI;

end

endmodule

