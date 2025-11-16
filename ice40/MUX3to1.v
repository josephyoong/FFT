/*

*/

module MUX3to1 (
    control,
    in00,
    in01,
    in10,
    out
);

parameter WIDTH = 8;

input [1:0] control;
input [WIDTH-1:0] in00;
input [WIDTH-1:0] in01;
input [WIDTH-1:0] in10;
output reg [WIDTH-1:0] out;

always @(*) begin
    case (control)
    2'b00: out = in00;
    2'b01: out = in01;
    2'b10: out = in10;
    default: out = in00;
    endcase
end
    
endmodule