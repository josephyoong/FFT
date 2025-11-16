/*
Block RAM

*/

module RAM (
    clk,
    rst,
    i_wr_en,
    i_wr_addr,
    i_wr_data,
    i_rd_en,
    i_rd_addr,
    o_rd_data
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input clk;
input rst;
input i_wr_en;
input [log2(N)-1:0] i_wr_addr;
input [I+F-1:0] i_wr_data;
input i_rd_en;
input [log2(N)-1:0] i_rd_addr;
output reg [I+F-1:0] o_rd_data;

reg [I+F-1:0] r_mem [0:N-1];
integer i;

always @(posedge clk) begin
    if (rst) begin
        o_rd_data <= 0;
        for (i = 0; i < N; i = i + 1) begin
            r_mem[i] <= 0;
        end
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

function integer log2;
    input integer value;
    begin
        value = value - 1;
        for (log2 = 0; value > 0; log2 = log2 + 1)
            value = value >> 1;
    end
endfunction
    
endmodule