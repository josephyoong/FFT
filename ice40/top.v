/*
Top

hello

*/

module top #(
    parameter
    N,
    I,
    F
) (
    input clk,
    input rst,
    input load,
    input transform,
    input read,
    input [I+F-1:0] load_data_RAM1_re,
    input [I+F-1:0] load_data_RAM1_im,
    input [I+F-1:0] load_data_RAM2_re,
    input [I+F-1:0] load_data_RAM2_im
);

wire RAM1_re_wr_en;
wire RAM1_im_wr_en;
wire RAM2_re_wr_en;
wire RAM2_im_wr_en;
wire RAM1_re_rd_en;
wire RAM1_im_rd_en;
wire RAM2_re_rd_en;
wire RAM2_im_rd_en;
wire ROM_rd_en;
wire [$clog2(N)-1:0] RAM1_re_wr_addr;
wire [$clog2(N)-1:0] RAM1_im_wr_addr;
wire [$clog2(N)-1:0] RAM2_re_wr_addr;
wire [$clog2(N)-1:0] RAM2_im_wr_addr;
wire [$clog2(N)-1:0] RAM1_re_rd_addr;
wire [$clog2(N)-1:0] RAM1_im_rd_addr;
wire [$clog2(N)-1:0] RAM2_re_rd_addr;
wire [$clog2(N)-1:0] RAM2_im_rd_addr;
wire [$clog2(N/2)-1:0] ROM_rd_addr;
wire [I+F-1:0] top_re;
wire [I+F-1:0] top_im;
wire [I+F-1:0] bot_re;
wire [I+F-1:0] bot_im;
wire [1:0] ctrl_RAM1_re_data;
wire [1:0] ctrl_RAM1_im_data;
wire [1:0] ctrl_RAM2_re_data;
wire [1:0] ctrl_RAM2_im_data;
wire ctrl_data_re;
wire ctrl_data_im;
wire ctrl_even_odd_re;
wire ctrl_even_odd_im;
wire [I+F-1:0] even_re;
wire [I+F-1:0] even_im;
wire [I+F-1:0] odd_re;
wire [I+F-1:0] odd_im;
wire [I+F-1:0] twi_re;
wire [I+F-1:0] twi_im;

memory #(.N(N), .I(I), .F(F)) top_memory (
    .clk(clk),
    .rst(rst),

    .i_RAM1_re_wr_en(RAM1_re_wr_en),
    .i_RAM1_im_wr_en(RAM1_im_wr_en),
    .i_RAM2_re_wr_en(RAM2_re_wr_en),
    .i_RAM2_im_wr_en(RAM2_im_wr_en),
    .i_RAM1_re_rd_en(RAM1_re_rd_en),
    .i_RAM1_im_rd_en(RAM1_im_rd_en),
    .i_RAM2_re_rd_en(RAM2_re_rd_en),
    .i_RAM2_im_rd_en(RAM2_im_rd_en),
    .i_ROM_rd_en(ROM_rd_en),
    .i_RAM1_re_wr_addr(RAM1_re_wr_addr),
    .i_RAM1_im_wr_addr(RAM1_im_wr_addr),
    .i_RAM2_re_wr_addr(RAM2_re_wr_addr),
    .i_RAM2_im_wr_addr(RAM2_im_wr_addr),
    .i_RAM1_re_rd_addr(RAM1_re_rd_addr),
    .i_RAM1_im_rd_addr(RAM1_im_rd_addr),
    .i_RAM2_re_rd_addr(RAM2_re_rd_addr),
    .i_RAM2_im_rd_addr(RAM2_im_rd_addr),
    .i_ROM_rd_addr(ROM_rd_addr),
    .i_load_data_RAM1_re(load_data_RAM1_re),
    .i_load_data_RAM1_im(load_data_RAM1_im),
    .i_load_data_RAM2_re(load_data_RAM2_re),
    .i_load_data_RAM2_im(load_data_RAM2_im),
    .i_top_re(top_re),
    .i_top_im(top_im),
    .i_bot_re(bot_re),
    .i_bot_im(bot_im),
    .ctrl_RAM1_re_data(ctrl_RAM1_re_data),
    .ctrl_RAM1_im_data(ctrl_RAM1_im_data),
    .ctrl_RAM2_re_data(ctrl_RAM2_re_data),
    .ctrl_RAM2_im_data(ctrl_RAM2_im_data),
    .ctrl_data_re(ctrl_data_re),
    .ctrl_data_im(ctrl_data_im),
    .ctrl_even_odd_re(ctrl_even_odd_re),
    .ctrl_even_odd_im(ctrl_even_odd_im),
    
    .o_even_re(even_re),
    .o_even_im(even_im),
    .o_odd_re(odd_re),
    .o_odd_im(odd_im),
    .o_twi_re(twi_re),
    .o_twi_im(twi_im)
);

butterfly #(.I(I), .F(F)) top_butterfly (
    .clk(clk),
    .rst(rst),

    .i_en(),
    .i_even_re(even_re),
    .i_even_im(even_im),
    .i_odd_re(odd_re),
    .i_odd_im(odd_im),
    .i_twi_re(twi_re),
    .i_twi_im(twi_im),

    .o_top_re(top_re),
    .o_top_im(top_im),
    .o_bot_re(bot_re),
    .o_bot_im(bot_im)
);

control #(.N(N), .I(I), .F(F)) top_control (
    .clk(clk),
    .rst(rst),

    .i_load(load),
    .i_transform(transform),
    .i_read(read),

    .o_RAM1_re_wr_en(RAM1_re_wr_en),
    .o_RAM1_im_wr_en(RAM1_im_wr_en),
    .o_RAM2_re_wr_en(RAM2_re_wr_en),
    .o_RAM2_im_wr_en(RAM2_im_wr_en),
    .o_RAM1_re_rd_en(RAM1_re_rd_en),
    .o_RAM1_im_rd_en(RAM1_im_rd_en),
    .o_RAM2_re_rd_en(RAM2_re_rd_en),
    .o_RAM2_im_rd_en(RAM2_im_rd_en),
    .o_ROM_rd_en(ROM_rd_en),

    .o_RAM1_re_wr_addr(RAM1_re_wr_addr),  
    .o_RAM1_im_wr_addr(RAM1_im_wr_addr), 
    .o_RAM2_re_wr_addr(RAM2_re_wr_addr),  
    .o_RAM2_im_wr_addr(RAM2_im_wr_addr),  
    .o_RAM1_re_rd_addr(RAM1_re_rd_addr),  
    .o_RAM1_im_rd_addr(RAM1_im_rd_addr),  
    .o_RAM2_re_rd_addr(RAM2_re_rd_addr),  
    .o_RAM2_im_rd_addr(RAM2_im_rd_addr),  
    .o_ROM_rd_addr(ROM_rd_addr),

    .o_ctrl_RAM1_re_data(ctrl_RAM1_re_data),       
    .o_ctrl_RAM1_im_data(ctrl_RAM1_im_data),       
    .o_ctrl_RAM2_re_data(ctrl_RAM2_re_data),       
    .o_ctrl_RAM2_im_data(ctrl_RAM2_im_data),       
    .o_ctrl_data_re(ctrl_data_re),      
    .o_ctrl_data_im(ctrl_data_im),      
    .o_ctrl_even_odd_re(ctrl_even_odd_re),      
    .o_ctrl_even_odd_im(ctrl_even_odd_im)
);
    
endmodule