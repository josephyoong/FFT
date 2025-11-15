/*
Counter


*/

module counter #(
    parameter
    WIDTH,
    MAX
) (
    input clk,
    input rst,

    input i_en,

    output reg [WIDTH-1:0] o_count,
    output max
);

always @(posedge clk) begin
    if (rst) begin
        o_count <= 0;
    end
    else if (i_en) begin
        o_count <= (o_count == MAX) ? 0 : o_count + 1;
    end
end

assign max = (o_count == MAX);

endmodule