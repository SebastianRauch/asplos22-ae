#!/bin/bash

CPU_ISOLED1=$1
CPU_ISOLED2=$2

REPS=10

APP_DIR_FLEXOS="/root/flexos/apps"
APP_DIR_UNIKRAFT="/root/unikraft-mainline/apps"
APP_DIR_LINUX="/root/linux-userland"

# run benchmark and save raw measurement data
benchmark() {
	runscript=$1 		# script to run benchmark
	reps=$2			# number of repetitions
	tmpdir=$3		# directory for raw output
	fname_raw="raw"		# prefix for raw output files

	rm -rf $tmpdir
	mkdir -p $tmpdir

	for ((i = 0; i < $reps; i++)) ; do
		script ${tmpdir}/${fname_raw}_$i -c "${runscript} $CPU_ISOLED1 $CPU_ISOLED2"
	done
}

parse_raw() {
	dir=$1			# directory containing the raw data
	file_out=$2		# where to write processed data to
	header="$3"		# header

	rm -f $file_out
	echo ${header} > $file_out
	for file_raw in ${dir}/* ; do
		cat $file_raw \
		| sed -r "s/\x1B\[(([0-9]+)(;[0-9]+)*)?[m,K,H,f,J]//g" \
		| sed "s/\r//g" \
	 	| sed "s/.*TOTAL/TOTAL/g" \
		| awk '/TOTAL/ {printf "%3.0f\n", 1000 * $2}' >> $file_out
	done
}

# calculate averages and put them all into one file
summarize_data() {
	files=("$@")
	for f in "${files[@]}"; do
		if [ ! -f $f ]; then
			echo "# $f not found"
			continue
		fi
		label=$(awk 'NR==1 {print}' $f)
		stats=$(do_statistics $f)
		echo "\"$label\" $stats"
	done
}

function do_statistics() {
	avg=$(awk 'NR > 1 {sum+=$1} END {printf "%3.0f", sum / (NR - 1)}' "$1")
	sdev=$(awk -v OFMT='%f' -v a="$avg" 'NR > 1 {sum+=($1 - a) * ($1 - a)} END {printf "%3.2f\n", sqrt(sum / (NR - 2))}' "$1")
	echo "$avg $sdev"
}


TMPDIR_FCALLS="data/flexos-fcalls"
TMPDIR_EPT2="data/flexos-ept2"
TMPDIR_MPK3="data/flexos-mpk3"
TMPDIR_UNIKRAFT_KVM="data/unikraft-kvm"
TMPDIR_UNIKRAFT_LINUXU="data/unikraft-linuxu"
TMPDIR_LINUX="data/linux"
TMPDIR_GENODE_SEL4="data/genode-sel4"

DATADIR="data"

# benchmark fcalls
benchmark ${APP_DIR_FLEXOS}/sqlite-fcalls/kvm-start.sh $REPS $TMPDIR_FCALLS
parse_raw $TMPDIR_FCALLS ${DATADIR}/flexos-fcalls.dat "flexos-fcalls"

# benchmark ept2
benchmark ${APP_DIR_FLEXOS}/sqlite-ept2/kvm-start.sh $REPS $TMPDIR_EPT2
parse_raw $TMPDIR_EPT2 ${DATADIR}/flexos-ept2.dat "EPT2"

# benchmark mpk3 (if PKU available)
cat /proc/cpuinfo | grep -q pku
if [ $? -eq 0 ] ; then
	benchmark ${APP_DIR_FLEXOS}/sqlite-mpk3/kvm-start.sh $REPS $TMPDIR_MPK3
	parse_raw $TMPDIR_MPK3 ${DATADIR}/flexos-mpk3.dat "MPK3"
else
    echo "skipping MPK benchmark because PKU is unavailable"
fi

# benchmark unikraft-kvm
benchmark ${APP_DIR_UNIKRAFT}/app-sqlite-kvm/kvm-start.sh $REPS $TMPDIR_UNIKRAFT_KVM
parse_raw $TMPDIR_UNIKRAFT_KVM ${DATADIR}/unikraft-kvm.dat "Unikraft (kvm)"

# benchmark unikraft-linuxu
benchmark ${APP_DIR_UNIKRAFT}/app-sqlite-linuxu/linuxu-start.sh $REPS $TMPDIR_UNIKRAFT_LINUXU
parse_raw $TMPDIR_UNIKRAFT_LINUXU ${DATADIR}/unikraft-linuxu.dat "Unikraft (linuxu)"

# benchmark linux userland
benchmark ${APP_DIR_LINUX}/linux-process-start.sh $REPS $TMPDIR_LINUX
parse_raw $TMPDIR_LINUX ${DATADIR}/linux.dat "Linux"

#benchmark Genode (seL4)
benchmark /genode/genode-sel4-start.sh $REPS $TMPDIR_GENODE_SEL4
parse_raw $TMPDIR_GENODE_SEL4 ${DATADIR}/genode-sel4.dat "Genode (seL4)"

cd $DATADIR
summarize_data "linux.dat" "flexos-fcalls.dat" "flexos-ept2.dat" "flexos-mpk3.dat" "genode-sel4.dat" "unikraft-kvm.dat" "unikraft-linuxu.dat" > summary.dat
