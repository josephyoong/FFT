/*
Memory

1 clk edge to read or write

load    }
top     }   ->  RAM ->  { even
bottom  }               { odd

*/

module memory #(
    parameter 
    N,
    I,
    F
) (
    input clk,
    input rst,

    input i_RAM1_re_wr_en,
    input i_RAM1_im_wr_en,
    input i_RAM2_re_wr_en,
    input i_RAM2_im_wr_en,
    input i_RAM1_re_rd_en,
    input i_RAM1_im_rd_en,
    input i_RAM2_re_rd_en,
    input i_RAM2_im_rd_en,
    input i_ROM_rd_en,
    input [$clog2(N)-1:0] i_RAM1_re_wr_addr,
    input [$clog2(N)-1:0] i_RAM1_im_wr_addr,
    input [$clog2(N)-1:0] i_RAM2_re_wr_addr,
    input [$clog2(N)-1:0] i_RAM2_im_wr_addr,
    input [$clog2(N)-1:0] i_RAM1_re_rd_addr,
    input [$clog2(N)-1:0] i_RAM1_im_rd_addr,
    input [$clog2(N)-1:0] i_RAM2_re_rd_addr,
    input [$clog2(N)-1:0] i_RAM2_im_rd_addr,
    input [$clog2(N/2)-1:0] i_ROM_rd_addr,
    input [I+F-1:0] i_load_data_RAM1_re,
    input [I+F-1:0] i_load_data_RAM1_im,
    input [I+F-1:0] i_load_data_RAM2_re,
    input [I+F-1:0] i_load_data_RAM2_im,
    input [I+F-1:0] i_top_re,
    input [I+F-1:0] i_top_im,
    input [I+F-1:0] i_bot_re,
    input [I+F-1:0] i_bot_im,
    input [1:0] ctrl_RAM1_re_data,
    input [1:0] ctrl_RAM1_im_data,
    input [1:0] ctrl_RAM2_re_data,
    input [1:0] ctrl_RAM2_im_data,
    input ctrl_data_re,
    input ctrl_data_im,
    input ctrl_even_odd_re,
    input ctrl_even_odd_im,
    
    output [I+F-1:0] o_even_re,
    output [I+F-1:0] o_even_im,
    output [I+F-1:0] o_odd_re,
    output [I+F-1:0] o_odd_im,
    output [I+F-1:0] o_twi_re,
    output [I+F-1:0] o_twi_im
);

wire [I+F-1:0] RAM1_re_rd_data;
wire [I+F-1:0] RAM2_re_rd_data;
wire [I+F-1:0] RAM1_im_rd_data;
wire [I+F-1:0] RAM2_im_rd_data;
wire [I+F-1:0] rd_data_re;
wire [I+F-1:0] rd_data_im;
wire [I+F-1:0] RAM1_re_wr_data;
wire [I+F-1:0] RAM2_re_wr_data;
wire [I+F-1:0] RAM1_im_wr_data;
wire [I+F-1:0] RAM2_im_wr_data;

MUX3to1 #(.WIDTH(I+F)) MUX3to1_RAM1_re_data (
    .control(ctrl_RAM1_re_data),     //
    .in00(i_load_data_RAM1_re),
    .in01(i_top_re),
    .in10(i_bot_re),
    .out(RAM1_re_wr_data)  
);

MUX3to1 #(.WIDTH(I+F)) MUX3to1_RAM1_im_data (
    .control(ctrl_RAM1_im_data),     //
    .in00(i_load_data_RAM1_im),
    .in01(i_top_im),
    .in10(i_bot_im),
    .out(RAM1_im_wr_data)  
);

MUX3to1 #(.WIDTH(I+F)) MUX3to1_RAM2_re_data (
    .control(ctrl_RAM2_re_data),     //
    .in00(i_load_data_RAM2_re),
    .in01(i_top_re),
    .in10(i_bot_re),
    .out(RAM2_re_wr_data)  
);

MUX3to1 #(.WIDTH(I+F)) MUX3to1_RAM2_im_data (
    .control(ctrl_RAM2_im_data),     //
    .in00(i_load_data_RAM2_im),
    .in01(i_top_im),
    .in10(i_bot_im),
    .out(RAM2_im_wr_data)  
);

RAM #(.N(N), .I(I), .F(F)) RAM1_re (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM1_re_wr_en),     //
    .i_wr_addr(i_RAM1_re_wr_addr),   //
    .i_wr_data(RAM1_re_wr_data),
    .i_rd_en(i_RAM1_re_rd_en),     //
    .i_rd_addr(i_RAM1_re_rd_addr),   //
    .o_rd_data(RAM1_re_rd_data)
);

RAM #(.N(N), .I(I), .F(F)) RAM1_im (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM1_im_wr_en),     //
    .i_wr_addr(i_RAM1_im_wr_addr),   //
    .i_wr_data(RAM1_im_wr_data),
    .i_rd_en(i_RAM1_im_rd_en),     //
    .i_rd_addr(i_RAM1_im_rd_addr),   //
    .o_rd_data(RAM1_im_rd_data)  
);

RAM #(.N(N), .I(I), .F(F)) RAM2_re (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM2_re_wr_en),     //
    .i_wr_addr(i_RAM2_re_wr_addr),   //
    .i_wr_data(RAM2_re_wr_data),
    .i_rd_en(i_RAM2_re_rd_en),     //
    .i_rd_addr(i_RAM2_re_rd_addr),   //
    .o_rd_data(RAM2_re_rd_data)  
);

RAM #(.N(N), .I(I), .F(F)) RAM2_im (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM2_im_wr_en),     //
    .i_wr_addr(i_RAM2_im_wr_addr),   //
    .i_wr_data(RAM2_im_wr_data),
    .i_rd_en(i_RAM2_im_rd_en),     //
    .i_rd_addr(i_RAM2_im_rd_addr),   //
    .o_rd_data(RAM2_im_rd_data)  
);

ROM #(.N(N), .I(I), .F(F)) ROM_twiddle (
    .clk(clk),
    .i_rd_en(i_ROM_rd_en),     //
    .i_rd_addr(i_ROM_rd_addr),   //
    .o_rd_data_re(o_twi_re),
    .o_rd_data_im(o_twi_im)
);

MUX2to1 #(.WIDTH(I+F)) MUX2to1_data_re (
    .control(ctrl_data_re),     //
    .in0(RAM1_re_rd_data),
    .in1(RAM2_re_rd_data),
    .out(rd_data_re)  
);

MUX2to1 #(.WIDTH(I+F)) MUX2to1_data_im (
    .control(ctrl_data_im),     //
    .in0(RAM1_im_rd_data),
    .in1(RAM2_im_rd_data),
    .out(rd_data_im)  
);

deMUX2to1 #(.WIDTH(I+F)) deMUX2to1_even_odd_re (
    .control(ctrl_even_odd_re),     //
    .in(rd_data_re),
    .out0(o_even_re),
    .out1(o_odd_re)
);

deMUX2to1 #(.WIDTH(I+F)) deMUX2to1_even_odd_im (
    .control(ctrl_even_odd_im),     //
    .in(rd_data_im),
    .out0(o_even_im),
    .out1(o_odd_im)
);
    
endmodule