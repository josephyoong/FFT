/*
Butterfly

   .==-.                   .-==.
   \()8`-._  `.   .'  _.-'8()/
   (88"   ::.  \./  .::   "88)
    \_.'`-::::.(#).::::-'`._/
      `._... .q(_)p. ..._.'
        ""-..-'|=|`-..-""
              ,|=|.
             ((/^\))

4 clk edges

top = even + (twiddle * odd)
bottom = even - (twiddle * odd)

*/

module butterfly (
    clk,
    rst,
    i_en,
    i_even_re,
    i_even_im,
    i_odd_re,
    i_odd_im,
    i_twi_re,
    i_twi_im,
    o_top_re,
    o_top_im,
    o_bot_re,
    o_bot_im
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input clk;
input rst;
input i_en;
input [I+F-1:0] i_even_re;
input [I+F-1:0] i_even_im;
input [I+F-1:0] i_odd_re;
input [I+F-1:0] i_odd_im;
input [I+F-1:0] i_twi_re;
input [I+F-1:0] i_twi_im;
output reg [I+F-1:0] o_top_re;
output reg [I+F-1:0] o_top_im;
output reg [I+F-1:0] o_bot_re;
output reg [I+F-1:0] o_bot_im;

wire [I+F-1:0] twi_odd_re;
wire [I+F-1:0] twi_odd_im;
reg [I+F-1:0] shift_even_re_0;
reg [I+F-1:0] shift_even_re_1;
reg [I+F-1:0] shift_even_re_2;
reg [I+F-1:0] shift_even_im_0;
reg [I+F-1:0] shift_even_im_1;
reg [I+F-1:0] shift_even_im_2;

complex_multiplier twiddler (
    .clk(clk),
    .rst(rst),
    .i_en(i_en),
    .i_data1_re(i_odd_re),
    .i_data1_im(i_odd_im),
    .i_data2_re(i_twi_re),
    .i_data2_im(i_twi_im),
    .o_data_re(twi_odd_re),
    .o_data_im(twi_odd_im)
);

always @(posedge clk) begin
    if (rst) begin
        shift_even_re_0 <= 0;
        shift_even_re_1 <= 0;
        shift_even_re_2 <= 0;
        shift_even_im_0 <= 0;
        shift_even_im_1 <= 0;
        shift_even_im_2 <= 0;
        o_top_re <= 0;
        o_top_im <= 0;
        o_bot_re <= 0;
        o_bot_im <= 0;
    end
    else if (i_en) begin
        shift_even_re_0 <= i_even_re;
        shift_even_im_0 <= i_even_im;
        shift_even_re_1 <= shift_even_re_0;
        shift_even_im_1 <= shift_even_im_0;
        shift_even_re_2 <= shift_even_re_1;
        shift_even_im_2 <= shift_even_im_1;

        o_top_re <= shift_even_re_2 + twi_odd_re;
        o_top_im <= shift_even_im_2 + twi_odd_im;
        o_bot_re <= shift_even_re_2 - twi_odd_re;
        o_bot_im <= shift_even_im_2 - twi_odd_im;
    end
end

endmodule
