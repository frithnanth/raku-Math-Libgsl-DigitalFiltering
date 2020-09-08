#!/usr/bin/gnuplot

set term qt persist
set xrange [0:1000]
set yrange [-30:25]
set grid
plot 'examples/04-impulse.dat' using 1:2 title 'Data' with lines, 'examples/04-impulse.dat' using 1:3 title 'Filtered data' with lines, 'examples/04-impulse.dat' using 1:4 title 'Upper limit' with lines, 'examples/04-impulse.dat' using 1:5 title 'Lower limit' with lines
