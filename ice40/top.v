module top (
    clk,
    rst,
    load,
    transform,
    read,
    load_data_RAM1_re,
    load_data_RAM1_im,
    load_data_RAM2_re,
    load_data_RAM2_im,
    done_transform
);

// Parameters
parameter N = 8;
parameter I = 4;
parameter F = 4;

// Inputs
input clk;
input rst;
input load;
input transform;
input read;
input [I+F-1:0] load_data_RAM1_re;
input [I+F-1:0] load_data_RAM1_im;
input [I+F-1:0] load_data_RAM2_re;
input [I+F-1:0] load_data_RAM2_im;

// Outputs
output done_transform;

// Local parameters for address widths
localparam ADDR_WIDTH = log2(N);
localparam ROM_ADDR_WIDTH = log2(N/2);

// Wires
wire RAM1_re_wr_en;
wire RAM1_im_wr_en;
wire RAM2_re_wr_en;
wire RAM2_im_wr_en;
wire RAM1_re_rd_en;
wire RAM1_im_rd_en;
wire RAM2_re_rd_en;
wire RAM2_im_rd_en;
wire ROM_rd_en;
wire [ADDR_WIDTH-1:0] RAM1_re_wr_addr;
wire [ADDR_WIDTH-1:0] RAM1_im_wr_addr;
wire [ADDR_WIDTH-1:0] RAM2_re_wr_addr;
wire [ADDR_WIDTH-1:0] RAM2_im_wr_addr;
wire [ADDR_WIDTH-1:0] RAM1_re_rd_addr;
wire [ADDR_WIDTH-1:0] RAM1_im_rd_addr;
wire [ADDR_WIDTH-1:0] RAM2_re_rd_addr;
wire [ADDR_WIDTH-1:0] RAM2_im_rd_addr;
// wire [ROM_ADDR_WIDTH-1:0] ROM_rd_addr;
wire [ADDR_WIDTH-1:0] ROM_rd_addr;
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

// Instantiate memory module
(* syn_noprune *) memory top_memory (
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

// Instantiate butterfly module
(* syn_noprune *) butterfly top_butterfly (
    .clk(clk),
    .rst(rst),

    .i_en(1'b1),  // You had this unconnected - added a default value
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

// Instantiate control module
(* syn_noprune *) control top_control (
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
    .o_ctrl_even_odd_im(ctrl_even_odd_im),
    .o_done_transform(done_transform)
);

// Custom log2 function to replace $clog2
function integer log2;
    input integer value;
    begin
        value = value - 1;
        for (log2 = 0; value > 0; log2 = log2 + 1)
            value = value >> 1;
    end
endfunction
    
endmodule