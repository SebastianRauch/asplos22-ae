#!/bin/bash

make -C /genode/build/x86_64 KERNEL=sel4 BOARD=pc run/sqlite
