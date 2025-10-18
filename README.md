# Fast Fourier Transform (FFT) Module, Verilog.
Performs the FFT on an input signal.

## Outline of the Data Flow 
1. The input signal is stored in memory.
2. The control generates memory addresses to send an input pair of samples to the butterfly, and one twiddle factor to the butterfly.
3. The butterfly computes the output pair of numbers and sends these to memory.
4. The control cycles through new pairs of addresses to complete the FFT.

## Testbench
The input signal is a superposition of two cos waves with distinct frequencies, so we would expect the output FFT to have energy at two distinct frequencies. The results of the testbench confirms this.
