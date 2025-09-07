module FFT #(parameter N, parameter I, parameter F) (
  input reset,
  input enable,
  input clk,
  input go,
  input mem0_load,
  input mem1_load,
  input [I+F-1:0] mem0_external_load1_real, mem0_external_load1_imag,
  input [I+F-1:0] mem0_external_load2_real, mem0_external_load2_imag, 
  input [I+F-1:0] mem1_external_load1_real, mem1_external_load1_imag,
  input [I+F-1:0] mem1_external_load2_real, mem1_external_load2_imag,
  output done
);
  
  wire [$clog2(N)-1:0] twiddle_address;
  wire mem0_RW;
  wire [$clog2(N)-1:0] mem0_address1, mem0_address2;
  wire [$clog2(N)-1:0] mem1_address1, mem1_address2;
  wire [I+F-1:0] top_real, top_imag;
  wire [I+F-1:0] bottom_real, bottom_imag;
  wire [I+F-1:0] even_real, even_imag;
  wire [I+F-1:0] odd_real, odd_imag;
  wire [I+F-1:0] twiddle_real;
  wire [I+F-1:0] twiddle_imag;
  
  control #(.N(N), .I(I), .F(F)) FFT_control (
    .reset(reset),
    .enable(enable),
    .clk(clk),
    .go(go),
    .mem0_load(mem0_load),
    .mem1_load(mem1_load),
    .twiddle_address(twiddle_address),
    .mem0_RW(mem0_RW),
    .mem0_address1(mem0_address1),
    .mem0_address2(mem0_address2),
    .mem1_address1(mem1_address1),
    .mem1_address2(mem1_address2),
    .done(done)
  );
  
  memory #(.N(N), .I(I), .F(F)) FFT_memory (
    .reset(reset),
    .enable(enable),
    .clk(clk),
    .mem0_RW(mem0_RW),
    .top_real(top_real),
    .top_imag(top_imag),
    .bottom_real(bottom_real),
    .bottom_imag(bottom_imag),
    .mem0_load(mem0_load),
    .mem1_load(mem1_load),
    .mem0_external_load1_real(mem0_external_load1_real),
    .mem0_external_load1_imag(mem0_external_load1_imag),
    .mem0_external_load2_real(mem0_external_load2_real),
    .mem0_external_load2_imag(mem0_external_load2_imag),
    .mem1_external_load1_real(mem1_external_load1_real),
    .mem1_external_load1_imag(mem1_external_load1_imag),
    .mem1_external_load2_real(mem1_external_load2_real),
    .mem1_external_load2_imag(mem1_external_load2_imag),
    .mem0_address1(mem0_address1),
    .mem0_address2(mem0_address2),
    .mem1_address1(mem1_address1),
    .mem1_address2(mem1_address2),
    .even_real(even_real),
    .even_imag(even_imag),
    .odd_real(odd_real),
    .odd_imag(odd_imag)
  );
  
  butterfly #(.I(I), .F(F)) FFT_butterfly (
    .reset(reset),
    .enable(enable),
    .clk(clk),
    .even_real(even_real),
    .even_imag(even_imag),
    .odd_real(odd_real),
    .odd_imag(odd_imag),
    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag),
    .top_real(top_real),
    .top_imag(top_imag),
    .bottom_real(bottom_real),
    .bottom_imag(bottom_imag)
  );
  
  twiddle #(.N(N), .I(I), .F(F)) FFT_twiddle (
    .reset(reset),
    .enable(enable),
    .clk(clk),
    .address(twiddle_address),
    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag)
  );
  
endmodule

module control #(parameter N, parameter I, parameter F) (
  input reset, enable, clk,
  input go,
  input mem0_load, mem1_load,
  output [$clog2(N)-1:0] twiddle_address,
  output mem0_RW, // 1 -> mem0 read and mem1 write, 0 -> mem0 write and mem1 read
  output [$clog2(N)-1:0] mem0_address1, mem0_address2,
  output [$clog2(N)-1:0] mem1_address1, mem1_address2,
  output done
);
  
  reg [$clog2(N)-1:0] twiddle_address_reg;
  reg mem0_RW_reg [0:1];
  reg [$clog2(N)-1:0] read_address1_reg, read_address2_reg;
  reg [$clog2(N)-1:0] write_address1_reg, write_address2_reg;
  reg [$clog2($clog2(N))-1:0] stage;
  reg [$clog2(N/2)-1:0] pair;
  reg [2:0] pair_cycle;
  reg [$clog2(N)-1:0] count;
  reg done_reg;
  
  always @(posedge go) begin
    mem0_RW_reg[1] <= 0;
    mem0_RW_reg[0] <= 1;
  end
  
  always @(posedge clk) begin
    if (reset) begin
      count <= 0;
      stage <= 0;
      pair <= 0;
      pair_cycle <= 0;
      mem0_RW_reg[1] <= 1;
      mem0_RW_reg[0] <= 1;
      done_reg <= 0;
    end
    else if (enable) begin
      if (mem0_load) begin
        count <= count + 1;
        mem0_RW_reg[1] <= 0;
        //mem0_RW_reg[0] <= 0;
      end
      else if (mem1_load) begin
        count <= count + 1;
        mem0_RW_reg[0] <= 1;
        //mem0_RW_reg[0] <= 1;
      end
      else if (go) begin
        mem0_RW_reg[1] <= mem0_RW_reg[0];
        if (pair_cycle == 7) begin // 8 clock cycles
          pair_cycle <= 0;
          if (pair == (N/2)-1) begin
            pair <= 0;
            mem0_RW_reg[0] <= ~mem0_RW_reg[1];
            if (stage == ($clog2(N))-1) begin
              stage <= 0;
              done_reg <= 1;
            end
            else begin
              stage <= stage + 1;
            end
          end
          else begin
            pair <= pair + 1;
          end
        end
        else begin
          pair_cycle <= pair_cycle + 1;
        end
      end
    end
  end
  
  address_generator #(.N(N)) address (
    .clk(clk),
    .stage(stage),
    .pair(pair),
    .mem0_load(mem0_load),
    .mem1_load(mem1_load),
    .count(count),
    .read_address1_reg(read_address1_reg),
    .read_address2_reg(read_address2_reg),
    .write_address1_reg(write_address1_reg),
    .write_address2_reg(write_address2_reg),
    .twiddle_address_reg(twiddle_address_reg)
  );
  
  assign twiddle_address = twiddle_address_reg;
  
  assign mem0_address1 = mem0_RW_reg[1] ? read_address1_reg : write_address1_reg;
  assign mem0_address2 = mem0_RW_reg[1] ? read_address2_reg : write_address2_reg;
  assign mem1_address1 = mem0_RW_reg[1] ? write_address1_reg : read_address1_reg;
  assign mem1_address2 = mem0_RW_reg[1] ? write_address2_reg : read_address2_reg;
    
  assign mem0_RW = mem0_RW_reg[1];
  assign done = done_reg;
  
endmodule

module address_generator #(parameter N) (
  input clk,
  input [$clog2($clog2(N))-1:0] stage,
  input [$clog2(N/2)-1:0] pair,
  input mem0_load, mem1_load,
  input [$clog2(N)-1:0] count,
  output reg [$clog2(N)-1:0] read_address1_reg, read_address2_reg,
  output reg [$clog2(N)-1:0] write_address1_reg, write_address2_reg,
  output reg [$clog2(N)-1:0] twiddle_address_reg
);
  
  wire [$clog2(N)-1:0] ad1 = 2 * pair;
  wire [$clog2(N)-1:0] ad2 = (2 * pair) + 1;
  
  wire [$clog2(N)-1:0] read_address1, read_address2;
  
  wire [$clog2(N)-1:0] ad1_rev, ad2_rev;

  bit_reverse #($clog2(N)) br1 (.in(ad1), .out(ad1_rev));
  bit_reverse #($clog2(N)) br2 (.in(ad2), .out(ad2_rev));  
  
  always @(posedge clk) begin
    if (mem0_load || mem1_load) begin
      write_address1_reg <= 2 * count;
      write_address2_reg <= (2 * count) + 1;
      read_address1_reg <= 0;
      read_address2_reg <= 0;
      twiddle_address_reg <= 0;
    end
    else if (stage == 0) begin
      read_address1_reg <= ad1_rev;
      read_address2_reg <= ad2_rev;
      write_address1_reg <= ad1;
      write_address2_reg <= ad2;
      twiddle_address_reg <= 0; // twiddle factor = 1 + 0i
    end
    else begin
      read_address1_reg <= read_address1;
      read_address2_reg <= read_address2;
      write_address1_reg <= read_address1;
      write_address2_reg <= read_address2;
      twiddle_address_reg <= pair & ~((1 << (($clog2(N)-1) - stage)) - 1);
    end
  end
  
  rotate_left #($clog2(N)) address1_read_generator (
    .in(ad1), 
    .rotate(stage), 
    .out(read_address1)
  );
  
  rotate_left #($clog2(N)) address2_read_generator (
    .in(ad2), 
    .rotate(stage), 
    .out(read_address2)
  );
  
endmodule

module bit_reverse #(parameter n) (
  input  [n-1:0] in,
  output [n-1:0] out
);
  genvar i;
  generate
    for (i = 0; i < n; i = i+1) begin : rev
      assign out[i] = in[n-1-i];
    end
  endgenerate
endmodule


module rotate_left #(parameter n) (
  input [n-1:0] in,
  input [$clog2(n)-1:0] rotate,
  output [n-1:0] out
);
  
  assign out = (in << rotate) | (in >> (n - rotate));
  
endmodule   

module memory #(parameter N, parameter I, parameter F) (
  input reset, enable, clk,
  input mem0_RW,
  input [I+F-1:0] top_real, top_imag,
  input [I+F-1:0] bottom_real, bottom_imag,
  input mem0_load, mem1_load,
  input [I+F-1:0] mem0_external_load1_real, mem0_external_load1_imag,
  input [I+F-1:0] mem0_external_load2_real, mem0_external_load2_imag, 
  input [I+F-1:0] mem1_external_load1_real, mem1_external_load1_imag,
  input [I+F-1:0] mem1_external_load2_real, mem1_external_load2_imag, 
  input [$clog2(N)-1:0] mem0_address1, mem0_address2,
  input [$clog2(N)-1:0] mem1_address1, mem1_address2,
  output [I+F-1:0] even_real, even_imag,
  output [I+F-1:0] odd_real, odd_imag
);
  
  reg mem0_load_reg[0:1]; // pipelining
  reg mem1_load_reg[0:1]; // pipelining
  
  always @(posedge clk) begin
    mem0_load_reg[0] <= mem0_load;
    mem1_load_reg[0] <= mem1_load;
    mem0_load_reg[1] <= mem0_load_reg[0];
    mem1_load_reg[1] <= mem1_load_reg[0];
  end
  
  wire mem1_RW = ~mem0_RW;
  
  wire [I+F-1:0] mem0_data_in1_real = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem0_external_load1_real : top_real;
  wire [I+F-1:0] mem0_data_in1_imag = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem0_external_load1_imag : top_imag;
  wire [I+F-1:0] mem0_data_in2_real = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem0_external_load2_real : bottom_real;
  wire [I+F-1:0] mem0_data_in2_imag = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem0_external_load2_imag : bottom_imag;
  
  wire [I+F-1:0] mem1_data_in1_real = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem1_external_load1_real : top_real;
  wire [I+F-1:0] mem1_data_in1_imag = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem1_external_load1_imag : top_imag;
  wire [I+F-1:0] mem1_data_in2_real = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem1_external_load2_real : bottom_real;
  wire [I+F-1:0] mem1_data_in2_imag = (mem0_load_reg[1] | mem0_load_reg[0]) ? mem1_external_load2_imag : bottom_imag;
  
  wire [I+F-1:0] mem0_real_data_out1;
  wire [I+F-1:0] mem0_real_data_out2;
  wire [I+F-1:0] mem0_imag_data_out1;
  wire [I+F-1:0] mem0_imag_data_out2;
  wire [I+F-1:0] mem1_real_data_out1;
  wire [I+F-1:0] mem1_real_data_out2;
  wire [I+F-1:0] mem1_imag_data_out1;
  wire [I+F-1:0] mem1_imag_data_out2;
  
  wire [I+F-1:0] mem0_real_r0, mem0_real_r1, mem0_real_r2, mem0_real_r3, mem0_real_r4, mem0_real_r5, mem0_real_r6, mem0_real_r7;
  
  wire [I+F-1:0] mem0_imag_r0, mem0_imag_r1, mem0_imag_r2, mem0_imag_r3, mem0_imag_r4, mem0_imag_r5, mem0_imag_r6, mem0_imag_r7;
  
  wire [I+F-1:0] mem1_real_r0, mem1_real_r1, mem1_real_r2, mem1_real_r3, mem1_real_r4, mem1_real_r5, mem1_real_r6, mem1_real_r7;
  
  wire [I+F-1:0] mem1_imag_r0, mem1_imag_r1, mem1_imag_r2, mem1_imag_r3, mem1_imag_r4, mem1_imag_r5, mem1_imag_r6, mem1_imag_r7;
  
  dualportRAM #(.N(N), .I(I), .F(F)) mem0_real (
    .reset(reset), 
    .enable(enable), 
    .clk(clk),
    .RW(mem0_RW),
    .data_in1(mem0_data_in1_real), 
    .data_in2(mem0_data_in2_real),
    .address1(mem0_address1), 
    .address2(mem0_address2),
    .data_out1(mem0_real_data_out1), 
    .data_out2(mem0_real_data_out2),
    .r0(mem0_real_r0), .r1(mem0_real_r1), .r2(mem0_real_r2), .r3(mem0_real_r3),
    .r4(mem0_real_r4), .r5(mem0_real_r5), .r6(mem0_real_r6), .r7(mem0_real_r7)
  );

  dualportRAM #(.N(N), .I(I), .F(F)) mem0_imag (
    .reset(reset), 
    .enable(enable), 
    .clk(clk),
    .RW(mem0_RW),
    .data_in1(mem0_data_in1_imag), 
    .data_in2(mem0_data_in2_imag),
    .address1(mem0_address1), 
    .address2(mem0_address2),
    .data_out1(mem0_imag_data_out1), 
    .data_out2(mem0_imag_data_out2),
    .r0(mem0_imag_r0), .r1(mem0_imag_r1), .r2(mem0_imag_r2), .r3(mem0_imag_r3),
    .r4(mem0_imag_r4), .r5(mem0_imag_r5), .r6(mem0_imag_r6), .r7(mem0_imag_r7)
  );

  dualportRAM #(.N(N), .I(I), .F(F)) mem1_real (
    .reset(reset), 
    .enable(enable), 
    .clk(clk),
    .RW(mem1_RW),
    .data_in1(mem1_data_in1_real), 
    .data_in2(mem1_data_in2_real),
    .address1(mem1_address1), 
    .address2(mem1_address2),
    .data_out1(mem1_real_data_out1), 
    .data_out2(mem1_real_data_out2),
    .r0(mem1_real_r0), .r1(mem1_real_r1), .r2(mem1_real_r2), .r3(mem1_real_r3),
    .r4(mem1_real_r4), .r5(mem1_real_r5), .r6(mem1_real_r6), .r7(mem1_real_r7)
  );

  dualportRAM #(.N(N), .I(I), .F(F)) mem1_imag (
    .reset(reset), 
    .enable(enable), 
    .clk(clk),
    .RW(mem1_RW),
    .data_in1(mem1_data_in1_imag), 
    .data_in2(mem1_data_in2_imag),
    .address1(mem1_address1), 
    .address2(mem1_address2),
    .data_out1(mem1_imag_data_out1), 
    .data_out2(mem1_imag_data_out2),
    .r0(mem1_imag_r0), .r1(mem1_imag_r1), .r2(mem1_imag_r2), .r3(mem1_imag_r3),
    .r4(mem1_imag_r4), .r5(mem1_imag_r5), .r6(mem1_imag_r6), .r7(mem1_imag_r7)
  );

  
  assign even_real = mem0_RW ? mem0_real_data_out1 : mem1_real_data_out1;
  assign even_imag = mem0_RW ? mem0_imag_data_out1 : mem1_imag_data_out1;
  assign odd_real = mem0_RW ? mem0_real_data_out2 : mem1_real_data_out2;
  assign odd_imag = mem0_RW ? mem0_imag_data_out2 : mem1_imag_data_out2;
  
endmodule

module dualportRAM #(parameter N, parameter I, parameter F) (
  input reset, enable, clk,
  input RW, // 1 -> read, 0 -> write
  input [I+F-1:0] data_in1, data_in2,
  input [$clog2(N)-1:0] address1, address2,
  output [I+F-1:0] data_out1, data_out2,
  
  output [I+F-1:0] r0,
  output [I+F-1:0] r1,
  output [I+F-1:0] r2,
  output [I+F-1:0] r3,
  output [I+F-1:0] r4,
  output [I+F-1:0] r5,
  output [I+F-1:0] r6,
  output [I+F-1:0] r7
);
  
  reg [I+F-1:0] register [0:N-1];
  reg [I+F-1:0] data_out1_reg, data_out2_reg;
  
  int k;
  
  always @(posedge clk) begin
    if (reset) begin
      for (k=0; k<N; k=k+1) begin
        register[k] <= 0;
      end
    end
    else if (enable) begin
      if (RW) begin // read
        data_out1_reg <= register[address1];
        data_out2_reg <= register[address2];
      end
      else begin // write
        register[address1] <= data_in1;
        register[address2] <= data_in2;
      end
    end
  end
  
  assign data_out1 = data_out1_reg;
  assign data_out2 = data_out2_reg;
  
  assign r0 = register[0];
  assign r1 = register[1];
  assign r2 = register[2];
  assign r3 = register[3];
  assign r4 = register[4];
  assign r5 = register[5];
  assign r6 = register[6];
  assign r7 = register[7];
  
endmodule

module butterfly #(parameter I, parameter F) (reset, enable, clk, even_real, even_imag, odd_real, odd_imag, twiddle_real, twiddle_imag, top_real, top_imag, bottom_real, bottom_imag);
  input reset, enable, clk;
  input signed [I+F-1:0] even_real;
  input signed [I+F-1:0] even_imag;
  input signed [I+F-1:0] odd_real;
  input signed [I+F-1:0] odd_imag;
  input signed [I+F-1:0] twiddle_real;
  input signed [I+F-1:0] twiddle_imag;
  output signed [I+F-1:0] top_real;
  output signed [I+F-1:0] top_imag;
  output signed [I+F-1:0] bottom_real;
  output signed [I+F-1:0] bottom_imag;
  
  wire signed [I+F-1:0] twiddled_odd_real, twiddled_odd_imag;
  reg signed [I+F-1:0] twiddled_odd_real_reg, twiddled_odd_imag_reg;
  
  reg signed [I+F-1:0] top_real_reg, top_imag_reg, bottom_real_reg, bottom_imag_reg;
  
  reg signed [I+F-1:0] even_real_pipe[3:0]; // pipelining
  reg signed [I+F-1:0] even_imag_pipe[3:0]; // pipelining
  
  complex_multiplier #(I, F) multiplier (
    .clk(clk), 
    .in1_real(odd_real), 
    .in1_imag(odd_imag), 
    .in2_real(twiddle_real), 
    .in2_imag(twiddle_imag), 
    .out_real(twiddled_odd_real), 
    .out_imag(twiddled_odd_imag)
  );
  
  always @(posedge clk) begin
    if (reset) begin
        even_real_pipe[0] <= 0;
        even_real_pipe[1] <= 0;
        even_real_pipe[2] <= 0;
        even_imag_pipe[0] <= 0;
        even_imag_pipe[1] <= 0;
        even_imag_pipe[2] <= 0;
    end 
    else if (enable) begin
        even_real_pipe[0] <= even_real;
        even_real_pipe[1] <= even_real_pipe[0];
        even_real_pipe[2] <= even_real_pipe[1];
        even_real_pipe[3] <= even_real_pipe[2];
        
      even_imag_pipe[0] <= even_imag;
      even_imag_pipe[1] <= even_imag_pipe[0];
      even_imag_pipe[2] <= even_imag_pipe[1];
      even_imag_pipe[3] <= even_imag_pipe[2];
    end
  end
  
  always @(posedge clk) begin
    twiddled_odd_real_reg <= twiddled_odd_real;
    twiddled_odd_imag_reg <= twiddled_odd_imag;
  end
  
  always @(posedge clk) begin
    if (reset) begin
      twiddled_odd_real_reg <= 0;
      twiddled_odd_imag_reg <= 0;
      top_real_reg <= 0;
      top_imag_reg <= 0;
      bottom_real_reg <= 0;
      bottom_imag_reg <= 0;
    end
    else if (enable) begin // adders
      top_real_reg <= even_real_pipe[3] + twiddled_odd_real_reg;
      top_imag_reg <= even_imag_pipe[3] + twiddled_odd_imag_reg;
      bottom_real_reg <= even_real_pipe[3] - twiddled_odd_real_reg;
      bottom_imag_reg <= even_imag_pipe[3] - twiddled_odd_imag_reg;
    end
  end
  
  assign top_real = top_real_reg;
  assign top_imag = top_imag_reg;
  assign bottom_real = bottom_real_reg;
  assign bottom_imag = bottom_imag_reg;
  
endmodule                                  

module complex_multiplier #(parameter I, parameter F) (clk, in1_real, in1_imag, in2_real, in2_imag , out_real, out_imag);
  input clk;
  input signed [I+F-1:0] in1_real, in1_imag, in2_real, in2_imag; // QI.F format
  output reg signed [I+F-1:0] out_real, out_imag; // no overflow since input (twiddle) |w| =< 1
  
  reg signed [2*(I+F)-1:0] product1, product2, product3, product4; // pipelining
  
  always @(posedge clk) begin
    product1 <= in1_real * in2_real; // I+F bit multipliers
    product2 <= in1_imag * in2_imag;
    product3 <= in1_real * in2_imag;
    product4 <= in1_imag * in2_real;
  end
  
  wire signed [2*(I+F)-1:0] round1 = product1 + ($signed(1) <<< (F-1)); // rounding
  wire signed [2*(I+F)-1:0] round2 = product2 + ($signed(1) <<< (F-1));
  wire signed [2*(I+F)-1:0] round3 = product3 + ($signed(1) <<< (F-1));
  wire signed [2*(I+F)-1:0] round4 = product4 + ($signed(1) <<< (F-1));
  
  reg signed [I+F-1:0] product1_QIF, product2_QIF, product3_QIF, product4_QIF; // pipelining

  always @(posedge clk) begin
    product1_QIF <= round1[2*(I+F)-1-I:F]; // truncating to QI.F format
    product2_QIF <= round2[2*(I+F)-1-I:F]; 
    product3_QIF <= round3[2*(I+F)-1-I:F]; // not 2*(I+F)-1:I+F because of 2I
    product4_QIF <= round4[2*(I+F)-1-I:F];
  end


  always @(posedge clk) begin
    out_real <= product1_QIF - product2_QIF; // I+F bit adders
    out_imag <= product3_QIF + product4_QIF;
  end 
endmodule

module twiddle #(parameter N, parameter I, parameter F) (reset, enable, clk, address, twiddle_real, twiddle_imag);
  input reset, enable, clk;
  input [$clog2(N)-1:0] address;
  output reg [I+F-1:0] twiddle_real, twiddle_imag;
  
  reg [I+F-1:0] register_real [0:N-1];
  reg [I+F-1:0] register_imag [0:N-1];
  
  initial begin
    register_real[0] = 16'h0100; // Re{w[N,0]} = 1 Q8.8
    register_imag[0] = 16'h0000;   // Im{w[N,0]} = 0 Q8.8
    register_real[1] = 16'h00B5; // Re{w[N,1]} = 
    register_imag[1] = 16'hFF4B;   // Im{w[N,1]} = 
    register_real[2] = 16'h0000; // Re{w[N,2]} = 
    register_imag[2] = 16'hFF00;   // Im{w[N,2]} = 
    register_real[3] = 16'hFF4B; // Re{w[N,3]} = 
    register_imag[3] = 16'hFF4B;   // Im{w[N,3]} = 
  end
  
  int k;
  
  always @(posedge clk) begin
    if (reset) begin
      for (k=0; k<N; k=k+1) begin
        twiddle_real <= 0;
        twiddle_imag <= 0;
      end
    end
    else if (enable) begin
      twiddle_real <= register_real[address];
      twiddle_imag <= register_imag[address];
    end
  end
  
endmodule
