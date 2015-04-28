mex -Dchar16_t=UINT16_T -O resize.cc
mex -Dchar16_t=UINT16_T -O reduce.cc
mex -Dchar16_t=UINT16_T -O shiftdt.cc
mex -Dchar16_t=UINT16_T -O features.cc

% use one of the following depending on your setup.
% 1 is fastest, 3 is slowest.
% If you are using a Windows machine, please use 3. 

% 1) multithreaded convolution using blas
% mex -O fconvblas.cc -lmwblas -o fconv
% 2) mulththreaded convolution without blas
mex -Dchar16_t=UINT16_T -O fconvMT.cc -o fconv
% 3) basic convolution, very compatible
% mex -O fconv.cc

