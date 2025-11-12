/*

*/

module ROM #( 
    parameter 
    N,
    I,
    F
) (
    input clk,

    input i_rd_en,
    input [$clog2(N)-1:0] i_rd_addr,

    output [I+F-1:0] o_rd_data_re,
    output [I+F-1:0] o_rd_data_im
);

reg [I+F-1:0] r_mem_re [0:(N/2)-1];
reg [I+F-1:0] r_mem_im [0:(N/2)-1];

// trig values
initial begin
    
end

always @(posedge clk) begin
    o_rd_data_re <= i_rd_en ? r_mem_re[i_rd_addr] : 0;
    o_rd_data_im <= i_rd_en ? r_mem_im[i_rd_addr] : 0;
end

endmodule