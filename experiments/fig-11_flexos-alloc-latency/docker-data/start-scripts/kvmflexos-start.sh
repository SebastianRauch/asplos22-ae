#!/bin/bash

CPU_ISOLED1=$3
CPU_ISOLED2=$4

function run {
	taskset -c ${CPU_ISOLED1} /root/qemu-guest -k $1 \
		-m 1024 -a "" -i /root/img.cpio -p ${CPU_ISOLED2}
}

function killimg {
	killall -9 qemu-system-x86 qemu-guest $0
}

die() { echo "$*" 1>&2 ; exit 1; }

if [ $# -gt 2 ]; then
    die "Usage:\t$0 run <image>\n\t$0 kill"
elif [ $# -eq 0 ]; then
    die "Usage:\t$0 run <image>\n\t$0 kill"
else
    case "$1" in
        run)
	    run $2
            ;;
        kill)
	    killimg
            ;;
        *)
            die "'$1': unsupported argument."
            ;;
    esac
fi
