#!/bin/bash


CPU_ISOLED1=$1
CPU_ISOLED2=$2


APP_DIR_FLEXOS_EPT="/root/.unikraft/apps/flexos-microbenchmarks-ept"
APP_DIR_FLEXOS_MPK="/root/.unikraft/apps/flexos-microbenchmarks-mpk"

OUT_DIR="/root/data"
mkdir ${OUT_DIR}

pushd ${APP_DIR_FLEXOS_EPT}
