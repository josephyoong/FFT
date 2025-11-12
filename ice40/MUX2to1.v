/*

*/

module MUX2to1 #(
    parameter
    WIDTH
) (
    input control,
    input [WIDTH-1:0] in0,
    input [WIDTH-1:0] in1,

    output [WIDTH-1:0] out
);

assign out = control ? in1 : in0;
    
endmodule