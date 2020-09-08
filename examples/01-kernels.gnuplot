#!/usr/bin/gnuplot

set term qt persist
set xrange [0:50]
set yrange [0:1]
set grid
plot 'examples/01-kernels.dat' using 1 title 'gaussian kernel for α=0.5' with lines, 'examples/01-kernels.dat' using 2 title 'gaussian kernel for α=3' with lines, 'examples/01-kernels.dat' using 3 title 'gaussian kernel for α=10' with lines
