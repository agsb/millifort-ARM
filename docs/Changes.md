# Changes

## Todo

    1. parameters for gcc

    2. def_word macro, need resolve how to update
        link for each word to point the previous,
        linked list

    3.  Code could start at align 2 or must be at align 4 ?

    4.  How use of compressed ISA ?

## Done

_" there is no spoon "_

the dictionary does use of DJB2 hash instead size+names and the flag IMMEDIATE is at bit 31.

Hash values for primitives included:

.equ hash_key, 0B876D32 
.equ hash_emit, 7C6B87D0 
.equ hash_store, 0002B584 
.equ hash_fetch, 0002B5E5 
.equ hash_add, 0002B58E 
.equ hash_colon, 0002B59F 
.equ hash_semis, 8002B59E   # with FLAG_IMMEDIATE 
.equ hash_nand, 7C727500 
.equ hash_exit, 7C6BBE85 
.equ hash_bye, 0B874AFB 
.equ hash_notequal, 00596816 
.equ hash_userat, 005970D6 

Default GCCFLAGS = -nostartfiles -nodefaultlibs -march=rv32ic -mabi=ilp32 -static -Os

Moved start of user dictionary of compiled words (.ends:) to end of .bss, so dictionary starts at .heap (relies in .dat, .text, .rodata, .bss linker order).

    
## DOES

04/08/2025

_A hell of Makefiles_

Start of project.

Start the port code of Risc-V to ARM7.


