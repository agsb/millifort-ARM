#---------------------------------------------------------------------
#       CPU: Cortex-M0, Armv6-M, RP2040 is little-endian
#       for alias register names 

# forth struct pointer, constant 
usr .req r7

# instruction pointer, preserved
ipt .req r6

# memory index 
idx .req r0

# hash value
hsh .req r1

# link pointer
lnk .req r2

# word pointer
wrd .req r3

# generic
fst .req r4

# generic
snd .req r5

