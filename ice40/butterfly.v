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

module butterfly #(
    parameter 
    I,
    F
) (
    input clk,
    input rst,

    input i_en,
    input [I+F-1:0] i_even_re,
    input [I+F-1:0] i_even_im,
    input [I+F-1:0] i_odd_re,
    input [I+F-1:0] i_odd_im,
    input [I+F-1:0] i_twi_re,
    input [I+F-1:0] i_twi_im,

    output reg [I+F-1:0] o_top_re,
    output reg [I+F-1:0] o_top_im,
    output reg [I+F-1:0] o_bot_re,
    output reg [I+F-1:0] o_bot_im
);

wire [I+F-1:0] twi_odd_re;
wire [I+F-1:0] twi_odd_im;
reg [I+F-1:0] shift_even_re [0:2];
reg [I+F-1:0] shift_even_im [0:2];

// 1st, 2nd, 3rd clk edges (data flow)
complex_multiplier #(.I(I), .F(F)) twiddler (
    .clk(clk),
    .rst(rst),
    .i_en(i_en),
    .i_data1_re(i_odd_re),
    .i_data1_im(i_odd_im),
    .i_data2_re(i_twi_re),
    .i_data2_im(i_twi_im),
    .o_data_re(twi_odd_re), 
    .o_data_im(twi_odd_re)  
);

always @(posedge clk) begin
    if (rst) begin
        for (int i=0; i<3; i++) begin
            shift_even_re[i] <= 0;
            shift_even_im[i] <= 0;
        end

        o_top_re <= 0;
        o_top_im <= 0;
        o_bot_re <= 0;
        o_bot_im <= 0;
    end
    else if (i_en) begin
        // 1st, 2nd, 3rd clk edges (data flow)
        shift_even_re[0] <= i_even_re;
        shift_even_im[0] <= i_even_im;
        for (int i=1; i<3; i++) begin
            shift_even_re[i] <= shift_even_re[i-1];
            shift_even_im[i] <= shift_even_im[i-1];
        end

        // 4th clk edge (data flow)
        o_top_re <= shift_even_re[2] + twi_odd_re;
        o_top_im <= shift_even_im[2] + twi_odd_im;
        o_bot_re <= shift_even_re[2] - twi_odd_re;
        o_bot_im <= shift_even_im[2] - twi_odd_im;
    end
end

endmodule