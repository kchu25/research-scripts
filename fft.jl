using FFTW

using Flux
d = reshape([1, 2, 3], (3,1,1))
x = reshape([1,0,0,0], (4,1,1))

conv(x, d, pad=0)
conv(x, d, pad=2)

d_pad = vcat(d, [0,0,0]); 
x_pad = vcat(x, [0,0]);


fft(d_pad) .* fft(x_pad)
rfft(d_pad) .* rfft(x_pad)


ifft(fft(d_pad) .* fft(x_pad))
irfft(rfft(d_pad) .* rfft(x_pad), 6)


####################################

d = reshape([1, 2, 3,0,0,0], (6,1,1))
x = reshape([1,0,0,0,1,0,0,0], (8,1,1))

d_pad = vcat(d, [0,0,0,0,0,0,0]); 
x_pad = vcat(x, [0,0,0,0,0]);


round.(Real.(ifft(fft(d_pad) .* fft(x_pad))), digits=2)
irfft(rfft(d_pad) .* rfft(x_pad), 13)
round.(Real.(irfft(rfft(d_pad) .* rfft(x_pad), 13)), digits=2)
