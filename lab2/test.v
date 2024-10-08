`timescale 1ns/1ns
module test ();
    reg [4:0] binary;
    integer i;
    initial begin
        for (i = -16; i < 16; i = i + 1) begin
            #1;
            binary = i;
            $display("%d: %5b", i, binary);
        end
    end
endmodule