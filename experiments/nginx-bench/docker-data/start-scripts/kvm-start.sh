#!/bin/bash

KERNEL=$2
CPU_ISOLED1=$3
CPU_ISOLED2=$4

QEMU_GUEST="/root/qemu-guest"
BRIDGE="uk0"
BRIDGE_IP="172.130.0.1"
IP="172.130.0.2"

INITRD="/root/nginx.cpio"

cleanup() {
	ifconfig $BRIDGE down
	brctl delbr $BRIDGE
	killall qemu-system-x86_64 qemu-guest
}


run() {
	echo "Creating bridge..."
	brctl addbr ${BRIDGE} || true
	ifconfig $BRIDGE down
	ifconfig $BRIDGE $BRIDGE_IP
	ifconfig $BRIDGE up

	taskset -c $CPU_ISOLED1 $QEMU_GUEST \
		-x \
		-k $KERNEL \
		-m 1024 \
		-i $INITRD \
		-b $BRIDGE \
		-p $CPU_ISOLED2 \
		-a "netdev.ipv4_addr=${IP} netdev.ipv4_gw_addr=${BRIDGE_IP} netdev.ipv4_subnet_mask=255.255.255.0 --"
}

case $1 in
	run)
		run
		;;
	kill)
		cleanup
		;;
	*)
		echo "unknown command"
		;;
esac
