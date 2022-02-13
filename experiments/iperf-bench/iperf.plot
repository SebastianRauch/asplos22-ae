#!/usr/bin/gnuplot
set term pdf enhanced font 'Arial,16'

# use logscale, display powers of two
set logscale x 2
set logscale y 2
set format x '2^{%L}'

set key at graph 0.95, 0.40
set key spacing 1.5

set xtics scale 0.5
set ytics scale 0.5

set yrange [0:4]
set xrange [16:16384]
set grid

set ylabel "iPerf Throughput (Gb/s)" offset 2,0
set xlabel "Receive Buffer Size (Bytes)" offset 2,0

set style line 1 \
	linecolor rgb '#0060ad' \
	linetype 1 linewidth 2 \
	pointtype 7 pointsize 0.5

set style line 2 \
	linecolor rgb '#dd181f' \
	linetype 1 linewidth 2 \
	pointtype 7 pointsize 0.5

set style line 3 \
	linecolor rgb '#33cc33f' \
	linetype 1 linewidth 2 \
	pointtype 7 pointsize 0.5

plot 'results/iperf.dat' 	index 0 with linespoints linestyle 1 title "Unikraft", \
	 ''						index 1 with linespoints linestyle 2 title "FlexOS MPK", \
	 ''						index 2 with linespoints linestyle 3 title "FlexOS VM/EPT"
