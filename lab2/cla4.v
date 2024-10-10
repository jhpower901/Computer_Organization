module cla4
(
    input [3:0] a_i,        //B+A propagate
    input [3:0] b_i,        //B+A generate
    input       carry_i,

    output       prop_o,    // group-propagate to LCU
    output       gen_o,     // group-generate to LCU
    output [3:0] carry_o    // [0] is cout of [0], [3] is cout of [3]
);

assign prop_o = a_i[0] & a_i[1] & a_i[2] & a_i[3];

assign gen_o = b_i[3] | (a_i[3] & b_i[2]) |
         (a_i[2] & a_i[3] & b_i[1]) |
         (a_i[1] & a_i[2] & a_i[3] & b_i[0]);

assign carry_o[0] = b_i[0] | (a_i[0] & carry_i);
 
assign carry_o[1] = b_i[1] | (a_i[1] & b_i[0]) |
            (a_i[0] & a_i[1] & carry_i);
 
assign carry_o[2] = b_i[2] | (a_i[2] & b_i[1]) |
            (a_i[1] & a_i[2] & b_i[0]) |
            (a_i[0] & a_i[1] & a_i[2] & carry_i);
             
assign carry_o[3] = b_i[3] | (a_i[3] & b_i[2]) |
            (a_i[2] & a_i[3] & b_i[1]) |
            (a_i[1] & a_i[2] & a_i[3] & b_i[0]) |
            (a_i[0] & a_i[1] & a_i[2] & a_i[3] & carry_i);

endmodule

