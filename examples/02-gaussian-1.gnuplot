#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1000]
set yrange [-.4:.8]
set grid
plot 'examples/02-gaussian.dat' using 1 title 'Signal' with lines, 'examples/02-gaussian.dat' using 2 title 'Gaussian smoothed signal' with lines
