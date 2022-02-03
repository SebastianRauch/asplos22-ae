#!/bin/bash

QEMU_GUEST="/root/kraft/scripts/qemu-guest"
BRIDGE="uk0"
BRIDGE_IP="172.130.0.1"
IP="172.130.0.2"

KERNEL="/root/.unikraft/apps/nginx/build/nginx_kvm-x86_64"
INITRD="nginx.cpio"

function cleanup() {
	ifconfig $BRIDGE down
	brctl delbr $BRIDGE
	pkill qemu-system-x86_64
}

trap "cleanup" EXIT

run() {
	echo "Creating bridge..."
	brctl addbr ${BRIDGE} || true
	ifconfig $BRIDGE down
	ifconfig $BRIDGE $BRIDGE_IP
	ifconfig $BRIDGE up

	$QEMU_GUEST -k $1 \
		-m 1024 \
		-i $INITRD \
		-b $BRIDGE \
		-a "netdev.ipv4_addr=${IP} netdev.ipv4_gw_addr=${BRIDGE_IP} netdev.ipv4_subnet_mask=255.255.255.0 --"
}

run $KERNEL
