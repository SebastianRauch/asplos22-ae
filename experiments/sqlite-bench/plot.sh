#!/bin/bash

# file containing the measurennts in the format (3 columns)
# label exec_time_avg exec_time_variance
data_file=$1

# gnuplot script used for plotting
gnuplot_script=$2

# where to save output to
out_file=$3

tmpfile="$(mktemp)"
# remove line starting with #
grep -v "^#" $data_file > $tmpfile

arg=$(echo "dfile=\"$tmpfile\"")
gnuplot -e ${arg} $gnuplot_script > $out_file

rm $tmpfile
