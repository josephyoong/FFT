/*
Complex Multiplier

Multiplies two complex numbers together
(a+bi)(c+di) = ac + adi + bci - bd = (ac-bd) + (ad+bc)i

QI.F Format

3 clk edges

*/

module complex_multiplier #(
    parameter I,
    parameter F
) (
    input clk,
    input rst,

    input i_en,
    input [I+F-1:0] i_data1_re,
    input [I+F-1:0] i_data1_im,
    input [I+F-1:0] i_data2_re,
    input [I+F-1:0] i_data2_im,

    output reg [I+F-1:0] o_data_re,
    output reg [I+F-1:0] o_data_im
);

reg [2*(I+F)-1:0] prod1;
reg [2*(I+F)-1:0] prod2;
reg [2*(I+F)-1:0] prod3;
reg [2*(I+F)-1:0] prod4;
reg [2*(I+F)-1:0] prod1_rnd;
reg [2*(I+F)-1:0] prod2_rnd;
reg [2*(I+F)-1:0] prod3_rnd;
reg [2*(I+F)-1:0] prod4_rnd;

always @(posedge clk) begin
    if (rst) begin
        prod1 <= 0;
        prod2 <= 0;
        prod3 <= 0;
        prod4 <= 0;

        prod1_rnd <= 0;
        prod2_rnd <= 0;
        prod3_rnd <= 0;
        prod4_rnd <= 0;

        o_data_re <= 0;
        o_data_im <= 0;
    end
    else if (i_en) begin
        // 1st clk edge (data flow) - can reduce multiplier size since mult by <1
        prod1 <= i_data1_re * i_data2_re; // ac 
        prod2 <= i_data1_re * i_data2_im; // ad
        prod3 <= i_data1_im * i_data2_re; // bc
        prod4 <= i_data1_im * i_data2_im; // bd

        // 2nd clk edge (data flow)
        prod1_rnd <= (prod1 + (1<<(F-1)));
        prod2_rnd <= (prod2 + (1<<(F-1)));
        prod3_rnd <= (prod3 + (1<<(F-1)));
        prod4_rnd <= (prod4 + (1<<(F-1)));

        // 3rd clk edge (data flow)
        o_data_re <= prod1_rnd[2*(I+F)-1-I:F] - prod4_rnd[2*(I+F)-1-I:F]; // ac - bd
        o_data_im <= prod2_rnd[2*(I+F)-1-I:F] + prod3_rnd[2*(I+F)-1-I:F]; // ad + bc
    end
end

endmodule