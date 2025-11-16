/*

*/

module MUX2to1 (
    control,
    in0,
    in1,
    out
);

parameter WIDTH = 8;

input control;
input [WIDTH-1:0] in0;
input [WIDTH-1:0] in1;
output [WIDTH-1:0] out;

assign out = control ? in1 : in0;
    
endmodule