#!/bin/bash

CPU_ISOLED1=$1
CPU_ISOLED2=$2
CPU_ISOLED3=$3
CPU_NOISOLED1=$4
CPU_NOISOLED2=$5
CPU_NOISOLED3=$6
CPU_NOISOLED4=$7

NUM_THREADS=4
NUM_CONNECTIONS=8
DURATION=10s

IP="172.130.0.2"


benchmark_kvm() {
	# TODO
	echo "TODO: implement"
}

test_fcalls() {
	pushd flexos/apps/nginx-fcalls
	./kvm-start.sh run build/nginx_kvm-x86_64 $CPU_ISOLED1 $CPU_ISOLED2

	sleep 3

	taskset -c $CPU_ISOLED3 wrk \
		-t $NUM_THREADS \
		-c $NUM_CONNECTIONS \
		-d $DURATION \
		http://${IP} > testdat.out

	./kvm-start.sh kill

	popd
}

test_mpk() {
	pushd flexos/apps/nginx-mpk2
	./kvm-start.sh run build/nginx_kvm-x86_64 $CPU_ISOLED1 $CPU_ISOLED2

	sleep 3

	taskset -c $CPU_ISOLED3 wrk \
		-t $NUM_THREADS \
		-c $NUM_CONNECTIONS \
		-d $DURATION \
		http://${IP} > testdat.out

	./kvm-start.sh kill

	popd
}

#test_fcalls
test_mpk
