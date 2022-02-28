#!/usr/bin/gnuplot
#set term svg enhanced font 'Arial,12' size 450,360

set term pdfcairo enhanced size 6,5 font 'Arial,16'

set boxwidth 0.75 relative
#set style fill border lt -1
set style fill empty
set style histogram rowstacked
set style data histograms
set key at graph 0.45, 0.9

set boxwidth 0.7

set ylabel "Latency (CPU cycles)" offset 2,0
set yrange [0:1000]
set ytics 100

set xtics scale 0.5
set ytics scale 0.5
set grid

set xtics rotate by -45

#set title "Gate latency"
plot 'results.dat' using 2:xtic(1) lc rgb 'black' fs pattern 6 t "shared memory RTT", \
	'' using 3:xtic(1) lc rgb 'blue' fs pattern 2 notitle, \
	'' using 0:($2 + $3 + 50):4 with labels notitle

