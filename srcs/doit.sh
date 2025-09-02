#!/usr/bin/bash

# crude script

make clean ; make

qemu-arm sector-armv6.elf \
 -display none -bios none -serial mon:stdio -smp 1 -machine virt

