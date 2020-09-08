#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1]
set yrange [-1.5:1.5]
set grid
plot 'examples/03-median.dat' using 1:2 title 'Data' with lines, 'examples/03-median.dat' using 1:3 title 'Standard Median Filter' with lines, 'examples/03-median.dat' using 1:4 title 'Recursive Median Filter' with lines
