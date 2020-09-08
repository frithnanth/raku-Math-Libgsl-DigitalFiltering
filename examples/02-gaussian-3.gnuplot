#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1000]
set yrange [-.005:.025]
set grid
plot 'examples/02-gaussian.dat' using 4 title 'First order Gaussian smoothed signal' with lines
