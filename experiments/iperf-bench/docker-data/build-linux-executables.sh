#!/bin/bash

OUT_DIR=executables

mkdir -p ${OUT_DIR}

set_rcvbuf() {
  sed -i "s/#define RECVBUFFERSIZE .*/#define RECVBUFFERSIZE ${1}/g" ./server.c
}

for i in {4..20}; do
	cur=$(echo 2^$i | bc)
	set_rcvbuf $cur
	gcc -O2 -o ${OUT_DIR}/server_${cur} ./server.c
done
