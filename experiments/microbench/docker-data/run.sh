#!/bin/bash

CPU_ISOLED1=$1
CPU_ISOLED2=$2

APP_DIR_FLEXOS_EPT="/root/.unikraft/apps/flexos-microbenchmarks-ept"
APP_DIR_FLEXOS_MPK="/root/.unikraft/apps/flexos-microbenchmarks-mpk"

OUT_DIR="/root/data"
mkdir ${OUT_DIR}

pushd ${APP_DIR_FLEXOS_EPT}
script ${OUT_DIR}/ept_rdtsc_serialized.dat bash -c "./kvm-start.sh run images/microbench_ept_serialize_rdtsc ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill

script ${OUT_DIR}/ept_rdtsc_not_serialized.dat bash -c "./kvm-start.sh run images/microbench_ept_no_serialize_rdtsc ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill

script ${OUT_DIR}/lower_bounds.dat bash -c "./kvm-start.sh run images/lower_bounds ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd

pushd ${APP_DIR_FLEXOS_MPK}
script ${OUT_DIR}/mpk_rdtsc_serialized.dat -c "./kvm-start.sh run images/microbench_mpk_serialize_rdtsc ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill

script ${OUT_DIR}/mpk_rdtsc_not_serialized.dat bash -c "./kvm-start.sh run images/microbenchmpkk_no_serialize_rdtsc ${CPU_ISOLED1} ${CPU_ISOLED2}"
./kvm-start.sh kill
popd
