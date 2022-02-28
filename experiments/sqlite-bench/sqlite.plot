#!/usr/bin/gnuplot
#set term svg
set term pdfcairo enhanced size 6,5 font 'Arial,16'

set style data histogram
set style histogram rowstacked
set style fill pattern 2
set boxwidth 0.75 relative

set ylabel "Time to complete 5000 INSERT operations (ms)"

set boxwidth 0.75
set yrange [0:400]

set ytics 50
set grid
set xtics rotate by -45

plot 'results.dat' using 2:xtic(1) lc rgb 'blue' notitle, \
				'' using 0:($2 + 15):2 with labels notitle

