#!/usr/bin/gnuplot

set term qt persist
set xrange [0:500]
set yrange [-10:35]
set grid
plot 'examples/01-gaussian.dat' using 1 title 'Data' with lines, 'examples/01-gaussian.dat' using 2 title 'Smoothed data for α=0.1' with lines, 'examples/01-gaussian.dat' using 3 title 'Smoothed data for α=3' with lines, 'examples/01-gaussian.dat' using 4 title 'Smoothed data for α=10' with lines
