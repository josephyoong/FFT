/*
Memory

1 clk edge to read or write

load    }
top     }   ->  RAM ->  { even
bottom  }               { odd

*/

module memory (
    clk,
    rst,
    i_RAM1_re_wr_en,
    i_RAM1_im_wr_en,
    i_RAM2_re_wr_en,
    i_RAM2_im_wr_en,
    i_RAM1_re_rd_en,
    i_RAM1_im_rd_en,
    i_RAM2_re_rd_en,
    i_RAM2_im_rd_en,
    i_ROM_rd_en,
    i_RAM1_re_wr_addr,
    i_RAM1_im_wr_addr,
    i_RAM2_re_wr_addr,
    i_RAM2_im_wr_addr,
    i_RAM1_re_rd_addr,
    i_RAM1_im_rd_addr,
    i_RAM2_re_rd_addr,
    i_RAM2_im_rd_addr,
    i_ROM_rd_addr,
    i_load_data_RAM1_re,
    i_load_data_RAM1_im,
    i_load_data_RAM2_re,
    i_load_data_RAM2_im,
    i_top_re,
    i_top_im,
    i_bot_re,
    i_bot_im,
    ctrl_RAM1_re_data,
    ctrl_RAM1_im_data,
    ctrl_RAM2_re_data,
    ctrl_RAM2_im_data,
    ctrl_data_re,
    ctrl_data_im,
    ctrl_even_odd_re,
    ctrl_even_odd_im,
    o_even_re,
    o_even_im,
    o_odd_re,
    o_odd_im,
    o_twi_re,
    o_twi_im
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input clk;
input rst;
input i_RAM1_re_wr_en;
input i_RAM1_im_wr_en;
input i_RAM2_re_wr_en;
input i_RAM2_im_wr_en;
input i_RAM1_re_rd_en;
input i_RAM1_im_rd_en;
input i_RAM2_re_rd_en;
input i_RAM2_im_rd_en;
input i_ROM_rd_en;
input [log2(N)-1:0] i_RAM1_re_wr_addr;
input [log2(N)-1:0] i_RAM1_im_wr_addr;
input [log2(N)-1:0] i_RAM2_re_wr_addr;
input [log2(N)-1:0] i_RAM2_im_wr_addr;
input [log2(N)-1:0] i_RAM1_re_rd_addr;
input [log2(N)-1:0] i_RAM1_im_rd_addr;
input [log2(N)-1:0] i_RAM2_re_rd_addr;
input [log2(N)-1:0] i_RAM2_im_rd_addr;
input [log2(N)-1:0] i_ROM_rd_addr;
input [I+F-1:0] i_load_data_RAM1_re;
input [I+F-1:0] i_load_data_RAM1_im;
input [I+F-1:0] i_load_data_RAM2_re;
input [I+F-1:0] i_load_data_RAM2_im;
input [I+F-1:0] i_top_re;
input [I+F-1:0] i_top_im;
input [I+F-1:0] i_bot_re;
input [I+F-1:0] i_bot_im;
input [1:0] ctrl_RAM1_re_data;
input [1:0] ctrl_RAM1_im_data;
input [1:0] ctrl_RAM2_re_data;
input [1:0] ctrl_RAM2_im_data;
input ctrl_data_re;
input ctrl_data_im;
input ctrl_even_odd_re;
input ctrl_even_odd_im;
output [I+F-1:0] o_even_re;
output [I+F-1:0] o_even_im;
output [I+F-1:0] o_odd_re;
output [I+F-1:0] o_odd_im;
output [I+F-1:0] o_twi_re;
output [I+F-1:0] o_twi_im;

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

MUX3to1 MUX3to1_RAM1_re_data (
    .control(ctrl_RAM1_re_data),
    .in00(i_load_data_RAM1_re),
    .in01(i_top_re),
    .in10(i_bot_re),
    .out(RAM1_re_wr_data)
);
defparam MUX3to1_RAM1_re_data.WIDTH = I+F;

MUX3to1 MUX3to1_RAM1_im_data (
    .control(ctrl_RAM1_im_data),
    .in00(i_load_data_RAM1_im),
    .in01(i_top_im),
    .in10(i_bot_im),
    .out(RAM1_im_wr_data)
);
defparam MUX3to1_RAM1_im_data.WIDTH = I+F;

MUX3to1 MUX3to1_RAM2_re_data (
    .control(ctrl_RAM2_re_data),
    .in00(i_load_data_RAM2_re),
    .in01(i_top_re),
    .in10(i_bot_re),
    .out(RAM2_re_wr_data)
);
defparam MUX3to1_RAM2_re_data.WIDTH = I+F;

MUX3to1 MUX3to1_RAM2_im_data (
    .control(ctrl_RAM2_im_data),
    .in00(i_load_data_RAM2_im),
    .in01(i_top_im),
    .in10(i_bot_im),
    .out(RAM2_im_wr_data)
);
defparam MUX3to1_RAM2_im_data.WIDTH = I+F;

RAM RAM1_re (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM1_re_wr_en),
    .i_wr_addr(i_RAM1_re_wr_addr),
    .i_wr_data(RAM1_re_wr_data),
    .i_rd_en(i_RAM1_re_rd_en),
    .i_rd_addr(i_RAM1_re_rd_addr),
    .o_rd_data(RAM1_re_rd_data)
);
defparam RAM1_re.N = N;
defparam RAM1_re.I = I;
defparam RAM1_re.F = F;

RAM RAM1_im (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM1_im_wr_en),
    .i_wr_addr(i_RAM1_im_wr_addr),
    .i_wr_data(RAM1_im_wr_data),
    .i_rd_en(i_RAM1_im_rd_en),
    .i_rd_addr(i_RAM1_im_rd_addr),
    .o_rd_data(RAM1_im_rd_data)
);
defparam RAM1_im.N = N;
defparam RAM1_im.I = I;
defparam RAM1_im.F = F;

RAM RAM2_re (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM2_re_wr_en),
    .i_wr_addr(i_RAM2_re_wr_addr),
    .i_wr_data(RAM2_re_wr_data),
    .i_rd_en(i_RAM2_re_rd_en),
    .i_rd_addr(i_RAM2_re_rd_addr),
    .o_rd_data(RAM2_re_rd_data)
);
defparam RAM2_re.N = N;
defparam RAM2_re.I = I;
defparam RAM2_re.F = F;

RAM RAM2_im (
    .clk(clk),
    .rst(rst),
    .i_wr_en(i_RAM2_im_wr_en),
    .i_wr_addr(i_RAM2_im_wr_addr),
    .i_wr_data(RAM2_im_wr_data),
    .i_rd_en(i_RAM2_im_rd_en),
    .i_rd_addr(i_RAM2_im_rd_addr),
    .o_rd_data(RAM2_im_rd_data)
);
defparam RAM2_im.N = N;
defparam RAM2_im.I = I;
defparam RAM2_im.F = F;

ROM ROM_twiddle (
    .clk(clk),
    .i_rd_en(i_ROM_rd_en),
    .i_rd_addr(i_ROM_rd_addr),
    .o_rd_data_re(o_twi_re),
    .o_rd_data_im(o_twi_im)
);
defparam ROM_twiddle.N = N;
defparam ROM_twiddle.I = I;
defparam ROM_twiddle.F = F;

MUX2to1 MUX2to1_data_re (
    .control(ctrl_data_re),
    .in0(RAM1_re_rd_data),
    .in1(RAM2_re_rd_data),
    .out(rd_data_re)
);
defparam MUX2to1_data_re.WIDTH = I+F;

MUX2to1 MUX2to1_data_im (
    .control(ctrl_data_im),
    .in0(RAM1_im_rd_data),
    .in1(RAM2_im_rd_data),
    .out(rd_data_im)
);
defparam MUX2to1_data_im.WIDTH = I+F;

deMUX2to1 deMUX2to1_even_odd_re (
    .control(ctrl_even_odd_re),
    .in(rd_data_re),
    .out0(o_even_re),
    .out1(o_odd_re)
);
defparam deMUX2to1_even_odd_re.WIDTH = I+F;

deMUX2to1 deMUX2to1_even_odd_im (
    .control(ctrl_even_odd_im),
    .in(rd_data_im),
    .out0(o_even_im),
    .out1(o_odd_im)
);
defparam deMUX2to1_even_odd_im.WIDTH = I+F;

function integer log2;
    input integer value;
    begin
        value = value - 1;
        for (log2 = 0; value > 0; log2 = log2 + 1)
            value = value >> 1;
    end
endfunction
    
endmodule