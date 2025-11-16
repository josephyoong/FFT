/*
Address Generator


*/

module addr_gen (
    i_stage,
    i_pair,
    o_top_addr,
    o_bot_addr,
    o_even_addr,
    o_odd_addr,
    o_twi_addr
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input [log2(log2(N))-1:0] i_stage;
input [log2(N)-1:0] i_pair;
output reg [log2(N)-1:0] o_top_addr;
output reg [log2(N)-1:0] o_bot_addr;
output reg [log2(N)-1:0] o_even_addr;
output reg [log2(N)-1:0] o_odd_addr;
output reg [log2(N)-1:0] o_twi_addr;

wire [log2(N)-1:0] addr_index_e;
wire [log2(N)-1:0] addr_index_o;
integer i;

assign addr_index_e = (i_pair << 1);
assign addr_index_o = (i_pair << 1) + 1;

always @(*) begin
    if (i_stage == ((log2(N))-1)) begin
        for (i=0; i<(log2(N)); i=i+1) begin
            o_even_addr[i] = addr_index_e[log2(N)-1-i];
            o_odd_addr[i] = addr_index_o[log2(N)-1-i];
        end
        o_top_addr = addr_index_e;
        o_bot_addr = addr_index_o;
        o_twi_addr = 0;
    end
    else begin
        o_even_addr = (addr_index_e << i_stage) | (addr_index_e >> (log2(N) - i_stage));
        o_odd_addr = (addr_index_o << i_stage) | (addr_index_o >> (log2(N) - i_stage));
        o_top_addr = o_even_addr;
        o_bot_addr = o_odd_addr;
        o_twi_addr = i_pair & ~((1 << ((log2(N)-1) - i_stage)) - 1);
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