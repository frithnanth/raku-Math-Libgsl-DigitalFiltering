#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1000]
set yrange [-.2:.25]
set grid
plot 'examples/02-gaussian.dat' using 3 title 'First differenced signal' with lines
