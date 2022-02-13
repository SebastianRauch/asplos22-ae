#!/usr/bin/gnuplot
set term pdfcairo enhanced size 6,5 font 'Arial,16'

set boxwidth 0.75 relative
#set style fill border lt -1
set style fill empty
set style histogram rowstacked
set style data histograms
set key at graph 0.6, 0.9

set boxwidth 0.7

set ylabel "Latency (CPU cycles)" offset 2,0
set yrange [0:1000]
set ytics 100

set xtics scale 0.5
set ytics scale 0.5
set grid

set xtics rotate by 45 right

#set title "Gate latency"
plot 'results/results.dat' using 2:xtic(1) lc rgb 'blue' fs pattern 2 t "shared memory RTT", \
	'' using 3:xtic(1) lc rgb 'black' fs pattern 1 notitle, \
	'' using 0:($2 + $3 + 50):4 with labels notitle

