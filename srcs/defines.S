#---------------------------------------------------------------------
# using pre-processor CPP (GNU GCC)
# for alias register names 
# do not change
# r0, r1, r2, r8 are used by ecalls

# forth struct pointer, constant 
#define usr r7

# instruction pointer, preserved
#define ipt r6

# memory index 
#define idx r0

# hash value
#define hsh r1

# link pointer
#define lnk r2

# word pointer
#define wrd r3

# generic
#define fst r4

# generic
#define snd r5

#---------------------------------------------------------------------
# generics alias 

# as FORTH 1983

.equ FALSE, 0

.equ TRUE, -1

# usefull

.equ ONE, 1

.equ TWO, 2

.equ CELL, 4

# \n
.equ NL, 10    

# \r
.equ CR, 13    

# space
.equ BL, 32    

# data stack, 36 cells 

.equ spz, 36 * CELL

# return stack, 36 cells

.equ rpz, 36 * CELL

# Terminal input buffer 80 bytes, (but 72 is enough), moves forwards

.equ tibz, 80

# PAD for temporary formating etc

.equ padz, 48

# highlander, immediate flag, unique 

# -2147483648
.equ FLAG_IMM, 0x80000000

# +2147483647
.equ MASK_IMM, 0x7FFFFFFF

<<<<<<< HEAD
=======
#----------------------------------------------------------------------
# user structure of internal Forth variables
# accessed as offsets

# data stack index
.equ SPTR, 0 * CELL

# return stack index
.equ RPTR, 1 * CELL 

# last link cell in heap dictionary linked list
.equ LAST, 2 * CELL

# next free cell in heap dictionary, aka dpt
.equ HERE, 3 * CELL

# toin next free byte in TIB
.equ TOIN, 4 * CELL

# state flag
.equ STAT, 5 * CELL

# heap forward
.equ HEAD, 6 * CELL

# heap backward
.equ TAIL, 7 * CELL

>>>>>>> 0700d3f ( sector compiled ok, need extas now)
#---------------------------------------------------------------------
# primitives djb2 hash cleared of bit 31
# semis is the unique with FLAG_IMM 

.equ hash_key,   0x0B876D32 
.equ hash_emit,  0x7C6B87D0 
.equ hash_store, 0x0002B584 
.equ hash_fetch, 0x0002B5E5 
.equ hash_nand,  0x7C727500 
.equ hash_plus,  0x0002B58E 
.equ hash_notzero, 0x00596816 
.equ hash_userat, 0x00596F90
.equ hash_colon, 0x0002B59F 
.equ hash_semis, 0x8002B59E 
.equ hash_exit,  0x7C6BBE85 

<<<<<<< HEAD
=======
#---------------------------------------------------------------------
>>>>>>> 0700d3f ( sector compiled ok, need extas now)
