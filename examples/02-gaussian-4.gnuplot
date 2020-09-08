#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1000]
set yrange [-.0015:.0015]
set grid
plot 'examples/02-gaussian.dat' using 5 title 'Second order Gaussian smoothed signal' with lines
