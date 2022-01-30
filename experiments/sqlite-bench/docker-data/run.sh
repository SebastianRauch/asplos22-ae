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
		| awk '/TOTAL/ {print $2}' >> $file_out
	done
}

TMPDIR_FCALLS="data/flexos-fcalls"
TMPDIR_EPT2="data/flexos-ept2"
TMPDIR_MPK3="data/flexos-mpk3"
TMPDIR_UNIKRAFT_KVM="data/unikraft-kvm"
TMPDIR_UNIKRAFT_LINUXU="data/unikraft-linuxu"
TMPDIR_LINUX="data/linux"
TMPDIR_GENODE_SEL4="data/genode-sel4"


# benchmark fcalls
benchmark ${APP_DIR_FLEXOS}/sqlite-fcalls/kvm-start.sh $REPS $TMPDIR_FCALLS
parse_raw $TMPDIR_FCALLS data.flexos-fcalls "Results of SQLite benchmark with fcalls ($REPS runs):"

# benchmark ept2
benchmark ${APP_DIR_FLEXOS}/sqlite-ept2/kvm-start.sh $REPS $TMPDIR_EPT2
parse_raw $TMPDIR_EPT2 data.flexos-ept2 "Results of SQLite benchmark with EPT2 ($REPS runs):"

# benchmark mpk3 (if PKU available)
cat /proc/cpuinfo | grep -q pku
if [ $? -eq 0 ] ; then
	benchmark ${APP_DIR_FLEXOS}/sqlite-mpk3/kvm-start.sh $REPS $TMPDIR_MPK3
	parse_raw $TMPDIR_MPK3 data.flexos-mpk3 "Results of SQLite benchmark with MPK3 ($REPS runs):"
else
    echo "skipping MPK benchmark because PKU is unavailable"
fi

# benchmark unikraft-kvm
benchmark ${APP_DIR_UNIKRAFT}/app-sqlite-kvm/kvm-start.sh $REPS $TMPDIR_UNIKRAFT_KVM
parse_raw $TMPDIR_UNIKRAFT_KVM data.unikraft-kvm "Results for SQLite benchmark with Unikraft kvm ($REPS runs):"

# benchmark unikraft-linuxu
benchmark ${APP_DIR_UNIKRAFT}/app-sqlite-linuxu/linuxu-start.sh $REPS $TMPDIR_UNIKRAFT_LINUXU
parse_raw $TMPDIR_UNIKRAFT_LINUXU data.unikraft-linuxu "Results for SQLite benchmark with Unikraft Linux userspace ($REPS runs):"

# benchmark linux userland
benchmark ${APP_DIR_LINUX}/linux-process-start.sh $REPS $TMPDIR_LINUX
parse_raw $TMPDIR_LINUX data.linux "Results for SQLite benchmark with Linux ($REPS runs):"

#benchmark Genode (seL4)
benchmark /genode/genode-sel4-start.sh $REPS $TMPDIR_GENODE_SEL4
parse_raw $TMPDIR_GENODE_SEL4 data.genode-sel4 "Results for SQLite benchmark with Genode on seL4 ($REPS runs):"
