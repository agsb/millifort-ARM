#!/usr/bin/bash

# crude script

make clean && make

qemu-system-arm -device loader,file=sector-armv6.elf \
        -M microbit -nographic -serial stdio

# qemu-arm sector-armv6.elf \
# -display none -bios none -serial mon:stdio -smp 1 -machine virt

