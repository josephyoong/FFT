/*
Control


*/

module control (
    clk,
    rst,
    i_load,
    i_transform,
    i_read,
    o_RAM1_re_wr_en,
    o_RAM1_im_wr_en,
    o_RAM2_re_wr_en,
    o_RAM2_im_wr_en,
    o_RAM1_re_rd_en,
    o_RAM1_im_rd_en,
    o_RAM2_re_rd_en,
    o_RAM2_im_rd_en,
    o_ROM_rd_en,
    o_RAM1_re_wr_addr,
    o_RAM1_im_wr_addr,
    o_RAM2_re_wr_addr,
    o_RAM2_im_wr_addr,
    o_RAM1_re_rd_addr,
    o_RAM1_im_rd_addr,
    o_RAM2_re_rd_addr,
    o_RAM2_im_rd_addr,
    o_ROM_rd_addr,
    o_ctrl_RAM1_re_data,
    o_ctrl_RAM1_im_data,
    o_ctrl_RAM2_re_data,
    o_ctrl_RAM2_im_data,
    o_ctrl_data_re,
    o_ctrl_data_im,
    o_ctrl_even_odd_re,
    o_ctrl_even_odd_im,
    o_done_transform
);

parameter N = 8;
parameter I = 4; 
parameter F = 4;

input clk;
input rst;
input i_load;
input i_transform;
input i_read;
output reg o_RAM1_re_wr_en;
output reg o_RAM1_im_wr_en;
output reg o_RAM2_re_wr_en;
output reg o_RAM2_im_wr_en;
output reg o_RAM1_re_rd_en;
output reg o_RAM1_im_rd_en;
output reg o_RAM2_re_rd_en;
output reg o_RAM2_im_rd_en;
output reg o_ROM_rd_en;
output [log2(N)-1:0] o_RAM1_re_wr_addr;
output [log2(N)-1:0] o_RAM1_im_wr_addr;
output [log2(N)-1:0] o_RAM2_re_wr_addr;
output [log2(N)-1:0] o_RAM2_im_wr_addr;
output [log2(N)-1:0] o_RAM1_re_rd_addr;
output [log2(N)-1:0] o_RAM1_im_rd_addr;
output [log2(N)-1:0] o_RAM2_re_rd_addr;
output [log2(N)-1:0] o_RAM2_im_rd_addr;
output [log2(N)-1:0] o_ROM_rd_addr;
output reg [1:0] o_ctrl_RAM1_re_data;
output reg [1:0] o_ctrl_RAM1_im_data;
output reg [1:0] o_ctrl_RAM2_re_data;
output reg [1:0] o_ctrl_RAM2_im_data;
output reg o_ctrl_data_re;
output reg o_ctrl_data_im;
output reg o_ctrl_even_odd_re;
output reg o_ctrl_even_odd_im;
output reg o_done_transform;

reg r_transform_0;
reg r_transform_1;
wire start_transform;
reg [2:0] r_state;

wire [log2(log2(N))-1:0] counter_stage_count;
reg en_counter_stage;
reg counter_stage_rst;
wire counter_stage_max;

wire [log2(N)-1:0] counter_pair_count;
reg en_counter_pair;
reg counter_pair_rst;
wire counter_pair_max;

wire [log2(N)-1:0] even_addr;
wire [log2(N)-1:0] odd_addr;
wire [log2(N)-1:0] top_addr;
wire [log2(N)-1:0] bot_addr;
wire [log2(N)-1:0] twi_addr;
reg [log2(N)-1:0] rd_addr;
reg [log2(N)-1:0] wr_addr;
reg r_toggle;

parameter IDLE = 3'd0, PERFORMING = 3'd1, FINISH = 3'd2;

// detect when transform is started
always @(posedge clk) begin
    if (rst) begin
        r_transform_0 <= 0;
        r_transform_1 <= 0;
    end
    else begin
        r_transform_0 <= i_transform;
        r_transform_1 <= r_transform_0;
    end
end
assign start_transform = (r_transform_1 & !r_transform_0);

// state transitions
always @(posedge clk) begin
    if (rst) begin
        r_state <= IDLE;
    end else begin
        case (r_state) 
            IDLE: r_state <= start_transform ? PERFORMING : IDLE;
            PERFORMING: r_state <= (counter_stage_count == ((log2(N))-1)) ? FINISH : PERFORMING;
            FINISH: r_state <= IDLE;
            default: r_state <= IDLE;
        endcase
    end
end

// state outputs
always @(*) begin
    // Default values
    en_counter_stage = 0;
    counter_stage_rst = 0;
    en_counter_pair = 0;
    counter_pair_rst = 0;
    o_RAM1_re_wr_en = 0;
    o_RAM1_im_wr_en = 0;
    o_RAM2_re_wr_en = 0;
    o_RAM2_im_wr_en = 0;
    o_RAM1_re_rd_en = 0;
    o_RAM1_im_rd_en = 0;
    o_RAM2_re_rd_en = 0;
    o_RAM2_im_rd_en = 0;
    o_ROM_rd_en = 0;
    o_ctrl_data_re = 0;
    o_ctrl_data_im = 0;

    case (r_state)
        IDLE: begin
            counter_stage_rst = 1;
            counter_pair_rst = 1;
            o_done_transform = 0;
        end
        PERFORMING: begin
            en_counter_stage = counter_pair_max;
            en_counter_pair = r_toggle;
            o_RAM1_re_wr_en     = counter_stage_count[0] ? 0 : 1;
            o_RAM1_im_wr_en     = counter_stage_count[0] ? 0 : 1;
            o_RAM2_re_wr_en     = counter_stage_count[0] ? 1 : 0;
            o_RAM2_im_wr_en     = counter_stage_count[0] ? 1 : 0;
            o_RAM1_re_rd_en     = counter_stage_count[0] ? 1 : 0;
            o_RAM1_im_rd_en     = counter_stage_count[0] ? 1 : 0;
            o_RAM2_re_rd_en     = counter_stage_count[0] ? 0 : 1;
            o_RAM2_im_rd_en     = counter_stage_count[0] ? 0 : 1;
            o_ROM_rd_en         = 1;
            o_ctrl_data_re      = counter_stage_count[0] ? 0 : 1;
            o_ctrl_data_im      = counter_stage_count[0] ? 0 : 1;
            o_done_transform = 0;
        end
        FINISH: begin
            o_done_transform = 1;
        end
        default: begin
            counter_stage_rst = 1;
            counter_pair_rst = 1;
            o_done_transform = 0;
        end
    endcase
end

counter counter_stage (
    .clk(clk),
    .rst(counter_stage_rst),
    .i_en(en_counter_stage),
    .o_count(counter_stage_count),
    .max(counter_stage_max)
);
defparam counter_stage.WIDTH = log2(log2(N));
defparam counter_stage.MAX = log2(N)-1;

counter counter_pair (
    .clk(clk),
    .rst(counter_pair_rst),
    .i_en(en_counter_pair),
    .o_count(counter_pair_count),
    .max(counter_pair_max)
);
defparam counter_pair.WIDTH = log2(N);
defparam counter_pair.MAX = (N/2)-1;  

addr_gen addr_gen_inst (
    .i_stage(counter_stage_count),
    .i_pair(counter_pair_count),
    .o_top_addr(top_addr),
    .o_bot_addr(bot_addr),
    .o_even_addr(even_addr),
    .o_odd_addr(odd_addr),
    .o_twi_addr(twi_addr)
);
defparam addr_gen_inst.N = N;

// determine rd and wr addr. even then odd, top then bot
always @(posedge clk) begin
    if (rst) begin
        r_toggle <= 0;
    end else begin
        r_toggle <= ~r_toggle;
    end
end

always @(*) begin
    if (r_toggle) begin
        rd_addr = even_addr;
        o_ctrl_even_odd_re = 0;
        o_ctrl_even_odd_im = 0;
        wr_addr = top_addr;
        o_ctrl_RAM1_re_data = 2'b01;
        o_ctrl_RAM1_im_data = 2'b01;
        o_ctrl_RAM2_re_data = 2'b01;
        o_ctrl_RAM2_im_data = 2'b01;
    end
    else begin
        rd_addr = odd_addr;
        o_ctrl_even_odd_re = 1;
        o_ctrl_even_odd_im = 1;
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

function integer log2;
    input integer value;
    begin
        value = value - 1;
        for (log2 = 0; value > 0; log2 = log2 + 1)
            value = value >> 1;
    end
endfunction

endmodule