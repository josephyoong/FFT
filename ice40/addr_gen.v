/*
Address Generator


*/

module addr_gen #(
    parameter 
    N
) (
    input [$clog2($clog2(N))-1:0] i_stage,
    input [$clog2(N)-1:0] i_pair,

    output reg [$clog2(N)-1:0] o_top_addr,  // wr
    output reg [$clog2(N)-1:0] o_bot_addr,  // wr
    output reg [$clog2(N)-1:0] o_even_addr, // rd
    output reg [$clog2(N)-1:0] o_odd_addr,  // rd
    output reg [$clog2(N)-1:0] o_twi_addr   // rd
);

wire [$clog2(N)-1:0] addr_index_e;
wire [$clog2(N)-1:0] addr_index_o;

assign addr_index_e = (i_pair << 1);
assign addr_index_o = (i_pair << 1) + 1;

always @(*) begin
    if (i_stage == (($clog2(N))-1)) begin                   // first stage
        for (int i=0; i<($clog2(N)-1); i++) begin
            o_even_addr[i] = addr_index_e[$clog2(N)-1-i];   // bit reversal
            o_odd_addr[i] = addr_index_o[$clog2(N)-1-i];    // bit reversal
        end
        o_top_addr = addr_index_e;
        o_bot_addr = addr_index_o;
        o_twi_addr = 0;     // twiddle factor = 1 + 0i
    end
    else begin
        o_even_addr = (addr_index_e << i_stage) | (addr_index_e >> ($clog2(N) - i_stage));  // rotate left by i_stage bits
        o_odd_addr = (addr_index_o << i_stage) | (addr_index_o >> ($clog2(N) - i_stage));   // rotate left by i_stage bits
        o_top_addr = o_even_addr;
        o_bot_addr = o_odd_addr;
        o_twi_addr = i_pair & ~((1 << (($clog2(N)-1) - i_stage)) - 1);
    end
end

endmodule