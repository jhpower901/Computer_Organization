module decoder
(
    input [15:0]    inst_i,         //Output from IR
    input [4:0]     psr_flags_i,    //FLCNZ flag from PSR. Order of [4:0] = {F, L, C, N, Z}

    output reg [4:0] TRI_SEL,       //Control signal(One-hot form) of Tri State Buffer
    output reg [5:0] ALU_SEL,       //ALU’s mode control
    output reg       WR,            //Register Write Enable control
    output reg       JMP,           //Jmp mux control of PC
    output reg       BR,            //Br mux control of PC
    output reg       IMM_EX_SEL,    //Extension mode control(signed or unsigned)
    output reg       MUX_SEL0,      //Data input control of ALU
    output reg       MUX_SEL1,      //Data input control of Shifter
    output reg       SHIFT_IMM,     //RLamount input control if Shifter
    output reg       LUI,           //lui(8-bit left shift) control of Shifter
    output reg       WE             //Data Memory Write Enable control
);

`include "../lab2/ALU_modes.vh"
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

function Jcond_Bcond_table;
    input [3:0] Rdest;
    input [4:0] psr_flags_i;    //FLCNZ
    begin
        case (Rdest)
            4'b0000: Jcond_Bcond_table = psr_flags_i[0];
            4'b0001: Jcond_Bcond_table = ~psr_flags_i[0];
            4'b1101: Jcond_Bcond_table = psr_flags_i[1] | psr_flags_i[0];
            4'b0010: Jcond_Bcond_table = psr_flags_i[2];
            4'b0011: Jcond_Bcond_table = ~psr_flags_i[2];
            4'b0100: Jcond_Bcond_table = psr_flags_i[3];
            4'b0101: Jcond_Bcond_table = ~psr_flags_i[3];
            4'b1010: Jcond_Bcond_table = ~psr_flags_i[3] & ~psr_flags_i[0];
            4'b1011: Jcond_Bcond_table = psr_flags_i[3] | psr_flags_i[0];
            4'b0110: Jcond_Bcond_table = psr_flags_i[1];
            4'b0111: Jcond_Bcond_table = ~psr_flags_i[1];
            4'b1000: Jcond_Bcond_table = psr_flags_i[4];
            4'b1001: Jcond_Bcond_table = ~psr_flags_i[4];
            4'b1100: Jcond_Bcond_table = ~psr_flags_i[1] & ~psr_flags_i[0];
            4'b1110: Jcond_Bcond_table = 1'b1;
            4'b1111: Jcond_Bcond_table = 1'b0;
            default:;
        endcase
    end
endfunction

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
    if ( (opcode == MEM_OP) && (opcode_ex == JAL_OPex) ||
         (opcode == MEM_OP) && (opcode_ex == Jcond_OPex) )
    begin
        JMP = Jcond_Bcond_table(Rdest, psr_flags_i);
    end

    ////////////////////////////////////////////////////////////////////////////
    // BR set
    ////////////////////////////////////////////////////////////////////////////
    BR = 1'b0;   // default value
    /* TODO: write logic for JMP, you need to consider JAL and Jcond */
    if ( (opcode == Bcond_OP) )
    begin
        BR = Jcond_Bcond_table(Rdest, psr_flags_i);
    end

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

