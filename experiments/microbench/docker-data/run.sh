#!/bin/bash

CPU_ISOLED1=$1
CPU_ISOLED2=$2

APP_DIR_FLEXOS_EPT="/root/.unikraft/apps/flexos-microbenchmarks-ept"
APP_DIR_FLEXOS_MPK="/root/.unikraft/apps/flexos-microbenchmarks-mpk"
APP_DIR_SYSCALL="/root/linux_syscall"

OUT_DIR="/root/data"
mkdir ${OUT_DIR}

pushd ${APP_DIR_FLEXOS_EPT}
script ${OUT_DIR}/ept.dat bash -c "./kvm-start.sh run images/microbench_ept ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill

script ${OUT_DIR}/lower_bounds.dat bash -c "./kvm-start.sh run images/lower_bounds ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd

pushd ${APP_DIR_FLEXOS_MPK}
script ${OUT_DIR}/mpk.dat -c "./kvm-start.sh run images/microbench_mpk ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd

pushd ${APP_DIR_SYSCALL}
script ${OUT_DIR}/linux_syscall.dat -c "taskset -c ${CPU_ISOLED1} ./syscall-test"
popd
