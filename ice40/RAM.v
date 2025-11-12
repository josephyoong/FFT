/*
Block RAM

*/

module RAM #(
    parameter
    N,
    I,
    F
) (
    input clk,
    input rst,

    input i_wr_en,
    input [$clog2(N)-1:0] i_wr_addr,
    input [I+F-1:0] i_wr_data,
    input i_rd_en,
    input [$clog2(N)-1:0] i_rd_addr,

    output reg [I+F-1:0] o_rd_data
);

reg [I+F-1:0] r_mem [0:N-1];

initial begin
    for (int i=0; i<N; i++) begin
        r_mem[i] <= 0;
    end
end

always @(posedge clk) begin
    if (rst) begin
        o_rd_data <= 0;
    end
    else begin 
        if (i_wr_en) begin
            r_mem[i_wr_addr] <= i_wr_data;
        end
        if (i_rd_en) begin
            o_rd_data <= r_mem[i_rd_addr];
        end
    end
end
    
endmodule