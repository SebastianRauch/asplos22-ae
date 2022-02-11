#!/bin/bash

CPU_ISOLED1=$1
CPU_ISOLED2=$2

APP_DIR_FLEXOS_EPT="/root/.unikraft/apps/flexos-microbenchmarks-ept"
APP_DIR_FLEXOS_MPK="/root/.unikraft/apps/flexos-microbenchmarks-mpk"
APP_DIR_SYSCALL="/root/linux_syscall"

OUT_DIR="/root/data"
mkdir ${OUT_DIR}

eptdat=${OUT_DIR}/ept.dat
lbdat=${OUT_DIR}/lower_bounds.dat
mpkdat=${OUT_DIR}/mpk.dat
syscalldat=${OUT_DIR}/linux_syscall.dat

merge_output() {
	tmp=mktemp
	outfile=$1
	lbout=$2

	# cleanup raw output
	awk '/^#[:space:]*/,EOF {print $0}' $eptdat > $tmp
	head -n 4 $tmp > $eptdat
	rdtsc_oh=$(awk '/rdtsc_overhead/{print $4}' $eptdat)

	awk '/^#[:space:]*/,EOF {print $0}' $lbdat > $tmp
	head -n 2 $tmp > $lbdat

	awk '/^#[:space:]*/,EOF {print $0}' $mpkdat > $tmp
	head -n 4 $tmp > $mpkdat

	awk '/^#[:space:]*/,EOF {print $0}' $syscalldat > $tmp
	head -n 4 $tmp > $syscalldat


	awk '/#/{print "# name  " $5}' $eptdat > $outfile
	awk -v s="$rdtsc_oh" '/fcall_0/{print      "fcall   " ($4 - s)}' $eptdat >> $outfile
	awk -v s="$rdtsc_oh" '/remotecall_0/{print "mpk     " ($4 - s)}' $mpkdat >> $outfile
	awk -v s="$rdtsc_oh" '/remotecall_0/{print "ept     " ($4 - s)}' $eptdat >> $outfile
	awk -v s="$rdtsc_oh" '/syscall/{print      "syscall " ($4 - s)}' $syscalldat >> $outfile


	awk '/#/{print "# name  " $5}' $eptdat > $lbout
	awk -v s="$rdtsc_oh" '/remotecall_0/{print "ept     " ($4 - s)}' $eptdat >> $lbout
	awk -v s="$rdtsc_oh" '/lower_bound/{print  "shmem   " ($4 - s)}' $eptdat >> $lbout
}


pushd ${APP_DIR_FLEXOS_EPT}
script $eptdat bash -c "./kvm-start.sh run images/microbench_ept ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill

script $lbdat bash -c "./kvm-start.sh run images/lower_bounds ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd

pushd ${APP_DIR_FLEXOS_MPK}
script $mpkdat -c "./kvm-start.sh run images/microbench_mpk ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd

pushd ${APP_DIR_SYSCALL}
script $syscalldat -c "taskset -c ${CPU_ISOLED1} ./syscall-test"
popd

merge_output results.dat lb_shmem.dat
