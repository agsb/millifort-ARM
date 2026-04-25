#---------------------------------------------------------------------
#       CPU: Cortex-M0, Armv6-M, RP2040 is little-endian
#       for alias register names 
#
#       agsb@ 24/04/2026
#       svc     used in linux system calls
#
# forth struct pointer, constant 
usr .req r9

# instruction pointer, preserved
ipt .req r8

# memory index, svc 
idx .req r0

# hash value, svc
hsh .req r1

# link pointer, svc
lnk .req r2

# word pointer, svc
wrd .req r3

# generic, free
fst .req r4

# generic, free
snd .req r5

# generic, free
trd .req r6

# generic, svc
fth .req r7
