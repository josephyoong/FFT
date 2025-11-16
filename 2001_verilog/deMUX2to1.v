/*

*/

module deMUX2to1 (
    control,
    in,
    out0,
    out1
);

parameter WIDTH = 8;

input control;
input [WIDTH-1:0] in;
output [WIDTH-1:0] out0;
output [WIDTH-1:0] out1;

assign out0 = control ? 0 : in;
assign out1 = control ? in : 0;
    
endmodule