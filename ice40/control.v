/*
Control


*/

module control #(
    parameter 
    N,
    I,
    F
) (
    input clk,
    input rst,

    input i_load,
    input i_transform,
    input i_read,

    output reg o_RAM1_re_wr_en,
    output reg o_RAM1_im_wr_en,
    output reg o_RAM2_re_wr_en,
    output reg o_RAM2_im_wr_en,
    output reg o_RAM1_re_rd_en,
    output reg o_RAM1_im_rd_en,
    output reg o_RAM2_re_rd_en,
    output reg o_RAM2_im_rd_en,
    output reg o_ROM_rd_en,

    output [$clog2(N)-1:0] o_RAM1_re_wr_addr,  
    output [$clog2(N)-1:0] o_RAM1_im_wr_addr,  
    output [$clog2(N)-1:0] o_RAM2_re_wr_addr,  
    output [$clog2(N)-1:0] o_RAM2_im_wr_addr,  
    output [$clog2(N)-1:0] o_RAM1_re_rd_addr,  
    output [$clog2(N)-1:0] o_RAM1_im_rd_addr,  
    output [$clog2(N)-1:0] o_RAM2_re_rd_addr,  
    output [$clog2(N)-1:0] o_RAM2_im_rd_addr,  
    output [$clog2(N/2)-1:0] o_ROM_rd_addr,

    output reg [1:0] o_ctrl_RAM1_re_data,       
    output reg [1:0] o_ctrl_RAM1_im_data,       
    output reg [1:0] o_ctrl_RAM2_re_data,       
    output reg [1:0] o_ctrl_RAM2_im_data,       
    output reg o_ctrl_data_re,      
    output reg o_ctrl_data_im,      
    output reg o_ctrl_even_odd_re,      
    output reg o_ctrl_even_odd_im       
);

reg r_transform [0:1];
reg start_transform;
reg [2:0] r_state;

wire [$clog2($clog2(N))-1:0] counter_stage_count;
reg en_counter_stage;
reg counter_stage_rst;
wire counter_stage_max;

wire [$clog2(N)-1:0] counter_pair_count;
reg en_counter_pair;
reg counter_pair_rst;
wire counter_pair_max;

wire [$clog2(N)-1:0] even_addr;
wire [$clog2(N)-1:0] odd_addr;
wire [$clog2(N)-1:0] top_addr;
wire [$clog2(N)-1:0] bot_addr;
wire [$clog2(N/2)-1:0] twi_addr;
reg [$clog2(N)-1:0] rd_addr;
reg [$clog2(N)-1:0] wr_addr;
reg r_toggle;

parameter IDLE = 2'd0, PERFORMING = 2'd1, FINISH = 2'd2;

// detect when transform is started
always @(posedge clk) begin
    if (rst) begin
        r_transform[0] <= 0;
        r_transform[1] <= 0;
    end
    else begin
        r_transform[0] <= i_transform;
        r_transform[1] <= r_transform[0];
    end
end
assign start_transform = (r_transform[1] & !r_transform[0]);

// state transitions
always @(posedge clk) begin
    case (r_state) 
    IDLE: r_state <= start_transform ? PERFORMING : IDLE;
    PERFORMING: r_state <= (counter_stage_count == (($clog2(N))-1)) ? FINISH : PERFORMING;
    FINISH: r_state <= IDLE;
    endcase
end

// state outputs
always @(*) begin
    case (r_state)
    IDLE: begin
        // stage counter
        en_counter_stage = 0;
        counter_stage_rst = 1;
        // pair counter 
        en_counter_pair = 0;
        counter_pair_rst = 1;
    end
    PERFORMING: begin
        // stage counter
        en_counter_stage = counter_pair_max;
        counter_stage_rst = 0;
        // pair counter 
        en_counter_pair = r_toggle;
        counter_pair_rst = 0;
        // memory 
        o_RAM1_re_wr_en     = counter_stage_count[0] ? 0 : 1;
        o_RAM1_im_wr_en     = counter_stage_count[0] ? 0 : 1;
        o_RAM2_re_wr_en     = counter_stage_count[0] ? 1 : 0;
        o_RAM2_im_wr_en     = counter_stage_count[0] ? 1 : 0;
        o_RAM1_re_rd_en     = counter_stage_count[0] ? 1 : 0;
        o_RAM1_im_rd_en     = counter_stage_count[0] ? 1 : 0;
        o_RAM2_re_rd_en     = counter_stage_count[0] ? 0 : 1;
        o_RAM2_im_rd_en     = counter_stage_count[0] ? 0 : 1;
        o_ROM_rd_en         = 1;
        // mux control
        o_ctrl_data_re      = counter_stage_count[0] ? 0 : 1;
        o_ctrl_data_im      = counter_stage_count[0] ? 0 : 1;
    end
    FINISH: begin
        // stage counter
        en_counter_stage = 0;
        counter_stage_rst = 0;
        // pair counter 
        en_counter_pair = 0;
        counter_pair_rst = 0;
        // memory 
        o_RAM1_re_wr_en = 0;
        o_RAM1_im_wr_en = 0;
        o_RAM2_re_wr_en = 0;
        o_RAM2_im_wr_en = 0;
        o_RAM1_re_rd_en = 0;
        o_RAM1_im_rd_en = 0;
        o_RAM2_re_rd_en = 0;
        o_RAM2_im_rd_en = 0;
        o_ROM_rd_en     = 0;
    end
    endcase
end

counter #(.WIDTH($clog2($clog2(N))), .MAX($clog2(N))) counter_stage (
    .clk(clk),
    .rst(rst),
    .i_en(en_counter_stage),
    .o_count(counter_stage_count),
    .max(counter_stage_max)
);

counter #(.WIDTH($clog2(N)), .MAX(N/2)) counter_pair (
    .clk(clk),
    .rst(rst),
    .i_en(en_counter_pair),
    .o_count(counter_pair_count),
    .max(counter_pair_max)
);

addr_gen #(.N(N)) addr_gen_inst (
    .i_stage(counter_stage_count),
    .i_pair(counter_pair_count),
    .o_top_addr(top_addr),
    .o_bot_addr(bot_addr),
    .o_even_addr(even_addr),
    .o_odd_addr(odd_addr),
    .o_twi_addr(twi_addr)
);

// determine rd and wr addr. even then odd, top then bot
always @(posedge clk) begin
    r_toggle <= ~r_toggle;
end
always @(*) begin
    if (r_toggle) begin
        // even
        rd_addr = even_addr;
        o_ctrl_even_odd_re = 0;
        o_ctrl_even_odd_im = 0;
        // top
        wr_addr = top_addr;
        o_ctrl_RAM1_re_data = 2'b01;
        o_ctrl_RAM1_im_data = 2'b01;
        o_ctrl_RAM2_re_data = 2'b01;
        o_ctrl_RAM2_im_data = 2'b01;
    end
    else begin
        // odd
        rd_addr = odd_addr;
        o_ctrl_even_odd_re = 1;
        o_ctrl_even_odd_im = 1;
        // bottom
        wr_addr = bot_addr;
        o_ctrl_RAM1_re_data = 2'b10;
        o_ctrl_RAM1_im_data = 2'b10;
        o_ctrl_RAM2_re_data = 2'b10;
        o_ctrl_RAM2_im_data = 2'b10;
    end
end

assign o_RAM1_re_wr_addr   = wr_addr;
assign o_RAM1_im_wr_addr   = wr_addr;
assign o_RAM2_re_wr_addr   = wr_addr;
assign o_RAM2_im_wr_addr   = wr_addr;
assign o_RAM1_re_rd_addr   = rd_addr;
assign o_RAM1_im_rd_addr   = rd_addr;
assign o_RAM2_re_rd_addr   = rd_addr;
assign o_RAM2_im_rd_addr   = rd_addr;
assign o_ROM_rd_addr       = twi_addr;

endmodule