# SystemVerilog Fast Fourier Transform (FFT) Module.

It takes an N-point input signal and performs the FFT. 

There are N sampled points, where N must be a power of two. Non power-of-two inputs could be transformed by padding with zeroes or periodising the signal, however this was outside the scope of this module but would be straightforward to implement. 

Numbers are represented in Q-format to represent signed and fractional numbers. The parameterised form is QI.F, where I is the length of integer bits and F is the length of fractional bits.

An outline of the module is as follows: 

The input signal is stored in memory.

The control generates memory addresses to send an input pair of numbers to the butterfly, and one twiddle factor to the butterfly.

The butterfly computes the output pair of numbers and sends these to memory.

The control cycles through new pairs of addresses to complete the FFT.
