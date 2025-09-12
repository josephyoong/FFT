module testbench();
  parameter N = 8;
  parameter I = 8;
  parameter F = 8;
  
  reg reset, enable, clk, go, mem0_load, mem1_load;
  reg [I+F-1:0] mem0_external_load1_real, mem0_external_load1_imag, mem0_external_load2_real, mem0_external_load2_imag, mem1_external_load1_real, mem1_external_load1_imag,  mem1_external_load2_real, mem1_external_load2_imag;
  wire done;
  
  FFT #(.N(N), .I(I), .F(F)) dut (
    .reset(reset),
    .enable(enable),
    .clk(clk),
    .go(go),
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
    .done(done)
  );
  
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, testbench);
    
    clk = 1;
    reset = 1;
    enable = 0;
    go = 0;
    
    #20
    reset = 0;
    enable = 1;
    mem0_load = 1;
    mem1_load = 0;
    mem0_external_load1_imag = 16'h0000;
    mem0_external_load2_imag = 16'h0000;
    
    #10
    mem0_external_load1_real = 16'h0100; // addr 0
    mem0_external_load2_real = 16'hFFA5; // addr 1
    
    #10
    mem0_external_load1_real = 16'hFF80; // addr 2
    mem0_external_load2_real = 16'h005A; // addr 3
    
    #10
    mem0_external_load1_real = 16'h0000; // addr 4
    mem0_external_load2_real = 16'h005A; // addr 5
    
    #10
    mem0_external_load1_real = 16'hFF80; // addr 6
    mem0_external_load2_real = 16'hFFA5; // addr 7
    mem0_load = 0;
    go = 1;
    
    
    #1200
    $finish;
  end
endmodule
