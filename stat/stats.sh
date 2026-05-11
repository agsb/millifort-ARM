#/bin/bash

# decompose assembler dumps into groups of intructions
# agsb@ 2025

cp $1 dmp

grep -E ':.[0-9a-f]{4} [0-9a-f]{4}.' dmp | \
grep -vi -E '\.word' > 32opc

grep -v -E ':.[0-9a-f]{4} [0-9a-f]{4}.' dmp | \
grep -vi -E '\.word' > 16opc

grep -E '\.word' dmp > pcc

for r in r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 ;
do
        grep -E ",${r}|${r},|\(${r}\)" dmp > ${r}.ss
        # | \
        # grep -v -E ":\s*$r|$r:" > ${r}.ss
done


