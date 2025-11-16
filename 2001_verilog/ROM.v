/*

*/

module ROM (
    clk,
    i_rd_en,
    i_rd_addr,
    o_rd_data_re,
    o_rd_data_im
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input clk;
input i_rd_en;
input [log2(N/2)-1:0] i_rd_addr;
output reg [I+F-1:0] o_rd_data_re;
output reg [I+F-1:0] o_rd_data_im;

// For N=8, I=4, F=4:
// - Memory depth: 4 (N/2)
// - Data width: 8 bits (I+F)
// - Address width: 2 bits (log2(4))
wire [I+F-1:0] r_mem_re [0:(N/2)-1];
wire [I+F-1:0] r_mem_im [0:(N/2)-1];

// Twiddle factors for 8-point FFT
// W_8^k = e^(-j*2πk/8)
assign r_mem_re[0] = 8'b00010000;  // W_8^0 = 1.000 + 0.000j
assign r_mem_im[0] = 8'b00000000;

assign r_mem_re[1] = 8'b00001101;  // W_8^1 = 0.707 - 0.707j (0.7071 ≈ 0.1011 in binary)
assign r_mem_im[1] = 8'b11110011;  // -0.7071 ≈ 0.1011 in 2's complement

assign r_mem_re[2] = 8'b00000000;  // W_8^2 = 0.000 - 1.000j
assign r_mem_im[2] = 8'b11110000;

assign r_mem_re[3] = 8'b11110011;  // W_8^3 = -0.707 - 0.707j
assign r_mem_im[3] = 8'b11110011;

always @(posedge clk) begin
    if (i_rd_en) begin
        o_rd_data_re <= r_mem_re[i_rd_addr];
        o_rd_data_im <= r_mem_im[i_rd_addr];
    end else begin
        o_rd_data_re <= 0;
        o_rd_data_im <= 0;
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