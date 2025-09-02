/*
#---------------------------------------------------------------------
 
  Copyright 2025 Alvaro Gomes Sobral Barcellos <@agsb>
 
  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 2 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

#----------------------------------------------------------------------
*/

/*
    A MilliForth for ARMV6 
 
    original for the ARMV6, by Alvaro G. S. Barcellos, 2025
 
    https://github.com/agsb 

    see the disclaimer file in this repository.
 
    read notes in this repository.
 
    THIS VERSION USES ONLY HASH HEADERS.

    Stacks moves backwards, decrease and push, pull and increase.

    Made for a little endian RiscV, cell size of 4 bytes, 32-bit

    This version relies on the .data, .text, .rodata, .bss sections 
    being in this order, the dictionary will continue at end of .bss.

    Not working yet :)

*/

#---------------------------------------------------------------------
# using pre-processor CPP (GNU GCC)
# for alias register names 
# beware about changes
# a3, a0, a1, a2, a7 are used by ecalls in _putc and _getc
# a4, a5, a6 are generics

#include "defines.S"

#---------------------------------------------------------------------
# generics alias 

# as FORTH 1983

.equ FALSE, 0

.equ TRUE, -1

# usefull

.equ ONE, 1

.equ TWO, 2

.equ CELL, 4

.equ NL, 10    # \n

.equ CR, 13    # \r

.equ BL, 32    # space

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

#---------------------------------------------------------------------
# primitives djb2 hash cleared of bit 31
.equ hash_key,   0x0B876D32 
.equ hash_emit,  0x7C6B87D0 
.equ hash_store, 0x0002B584 
.equ hash_fetch, 0x0002B5E5 
.equ hash_nand,  0x7C727500 
.equ hash_plus,  0x0002B58E 
.equ hash_notzero, 0x00596816 
.equ hash_userat, 0x00596F90
.equ hash_colon, 0x0002B59F 
.equ hash_semis, 0x8002B59E # unique with FLAG_IMM 
.equ hash_exit,  0x7C6BBE85 

#---------------------------------------------------------------------
# macro to define the header of words in dictionary
#
.global def_word

.macro def_word name, label, last, hash
#.p2align 2, 0x00
h_\label:
        .word \last
        .word \hash
\label:
.endm

#---------------------------------------------------------------------
# for deep, more than one, nested calls, use callee
#
.global pushra

.macro pushra
        #addi sp, sp, -4   
        #str   ra, 0(sp)    
.endm

.global pullra

.macro pullra
        #ldr   ra, 0(sp)    
        #addi sp, sp, +4   
.endm

#----------------------------------------------------------------------
# easy pretty print one char
#
.global putchar

.macro putchar value
       #li a3, \value
       bl _putc
.endm

#----------------------------------------------------------------------
.section .data

# There is no spoon.

#----------------------------------------------------------------------
.section .bss
.p2align 2, 0x0

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

#----------------------------------------------------------------------
# and this is it

_user:
# user parameter offsets
.skip 8 * CELL

# reserved for locals 
_locals:
.skip 8 * CELL

# data stack grows backward
_spb:       # bottom 
.skip spz
sp0: .word 0x0

# return stack grows backward
_rpb:       # bottom
.skip rpz
rp0: .word 0x0

# tib grows forward
_tib:       
.skip tibz

#xxx
# pad grows forward
_pad:       
.skip padz

# start of user dictionary 
h_here: .word 0x0

#-----------------------------------------------------------------------
# at end of .bss (.heap) 
#----------------------------------------------------------------------

#----------------------------------------------------------------------
.text 
.p2align 2, 0x0

#----------------------------------------------------------------------
.globl _start

_start:

#----------------------------------------------------------------------
# do any system inits
main:
# just for sake

        # fence

        # bl _init

        # bl _exit 

#----------------------------------------------------------------------
# do what need be only once
cold:
# load user pointer address

        adr usr, #_user
        
#----------------------------------------------------------------------
# wipe the dictionary
warm:
# link list of headers, aka dictionary

        adr fst, h_last
        str fst, [usr, #LAST]
        
# next heap free cell  (end of .bss)
        
        adr fst, h_here
        str fst, [usr, #HERE]

#---------------------------------------------------------------------
# reset TIB
reset:

        adr fst, _tib
        str fst, [usr, #TOIN]

#---------------------------------------------------------------------
# reset stacks
error:

# xxx 
        putchar '\n'
        putchar '?'
        putchar '?'
        putchar '\n'

#---------------------------------------------------------------------
abort:
# reset data stack
        
        adr fst, sp0 
        str fst, [usr, #SPTR]

#---------------------------------------------------------------------
quit:
# reset return stack
        
        adr fst, rp0 
        str fst, [usr, #RPTR]

# stat is 'interpret' == \0
        
        str #0, [usr, #STAT]

        b okey

#---------------------------------------------------------------------
# the outer loop, need for indirect

resolvept:
        
        .word okey

#---------------------------------------------------------------------
okey:

# bl prompt_okey

# xxx
        ldr fst, [usr, #STAT]
        cmp fst, #0
        bne resolve

        putchar '\n'
        putchar 'O'
        putchar 'K'
        putchar '\n'

#---------------------------------------------------------------------
# get a hash of the next token
resolve:
        
        bl token

#---------------------------------------------------------------------         
# search for a hash in dictionary linked list 
#
tick:

# get the latest link
        
        ldr lnk, [usr, #LAST]

100:
# verify end of dictionary, take care to abort
        
        cmp lnk, #0
        beq error    

# linked list
        
        mov wrd, lnk

# move next link 
        
        ldr lnk, [wrd]

# move to hash
        
        adds wrd, #+1*CELL

        ldr fst, [wrd]

# mask the FLAG and hold it in snd

        ldr snd, #FLAG_IMM

        ands snd, fst

        eor fst, snd

# compare
        
        cmp hsh, fst
        bne 100b

#---------------------------------------------------------------------         
eval:
# wrd points to or start of code or list of references

        adds wrd, #+1*CELL

# immediate ? 

        cmp snd, #0
        bne immediate      

# executing ? if state == 0
        
        ldr fst, [usr, #STAT]
        
        cmp fst, #0
        beq execute

#---------------------------------------------------------------------         
# compiling ? if state != 0
compile:

        bl comma

        b resolve

#---------------------------------------------------------------------         
execute:
immediate:

        adr ipt, resolvept

        b pick

#---------------------------------------------------------------------
# unexpected end of dictionary
# wipe remains compiled
# xxx
miss:
        # compiling ?
        ldr fst, [usr, #STAT]
        cmp fst, #0
        bne 100f

        # wipe remains
        ldr fst, [usr, #HEAD]
        str fst, [usr, #HERE]
100:
        b error

#---------------------------------------------------------------------
# xxx
# #include "hexy.S"

#---------------------------------------------------------------------
# in place every token, no rewinds
# the counter is placed at space before word
# returns a c-str
# \0 as eol goto getline
token:

        pushra

# last position on tib
        
100:

        ldr idx, [usr, #TOIN]

# skip spaces // trd
200:

        lb snd, [idx]

        cmp snd, #0
        beq gets

        cmp snd, #BL
        bne hash

        adds idx, #ONE

        b 200b
        
#---------------------------------------------------------------------
# absolute crude getline, no overflow check, the _getc handle EOF
#
gets:
  
        adr idx, _tib
        
        str idx, [usr, #TOIN]

# ever start with a space
        
        mov fst, #BL

# loop and fill the TIB until \n
# no test end of buffer 
300:
        sb fst, [idx]
        
        adds idx, #ONE

# get next char

        bl _getc

# echo it

        bl _putc

# 7-bit ascii only 
# xxx
        andi fst, #127

# \n ^J ends the line

        cmp fst, #NL
        bne 300b

# at end-of-line
400:

# replace \n with space 
        strb trd, [idx]

# mark eol with \0
        strb #0, [idx]

        b 100b

#---------------------------------------------------------------------
.equ DJB2, 5381
.equ SFHT, 5
#----------------------------------------------------------------------
# djb2 hash function
# classic djb2 hash algorithm, with XOR, adapted from cdb_hash
# idx pointer to str
# trd holds the end of word  
# uses fst, snd, trd
# hsh returns the hash 
# idx returns next space after
hash:
djb2:
        # easy 5381
   
        ldr hsh, #DJB2

100:
        lb fst, [idx]
        
        cmp fst, #BL
        beq 100f

        mov snd, hsh

        slli hsh, hsh, SFHT
        
        add hsh, snd
        
        eor hsh, fst
        
        adds idx, #ONE
        
        b 100b

100:    

# mask forth flag 
mask:

        ldr fst, #MASK_IMM
        
        and hsh, fst

#---------------------------------------------------------------------
# save toin

        str idx, [usr, #TOIN]

        pullra

        bx lr
        
#---------------------------------------------------------------------
comma:
        
        ldr idx, [usr, #HERE]
      
        str wrd, [idx]
      
        adds idx, #CELL
      
        str idx, [usr, #HERE]

        bx lr

#---------------------------------------------------------------------
#
# the primitives 
# 
#---------------------------------------------------------------------

/*
h_name:
        .word h_link_last_name
        .word hash_this_name
name:
        asm code
        b next
*/

### version 1.5.0
#---------------------------------------------------------------------
pull2:
        
        ldr idx, [usr, #SPTR]
        
        ldr fst, [idx]
        
        adds idx, #CELL

        ldr snd, [idx]

        bx lr

#---------------------------------------------------------------------
# ( -- c ) 
def_word "key", "key", 0x0, hash_key

        bl _getc

        b push1

#---------------------------------------------------------------------
# ( c -- ) 
def_word "emit", "emit", h_key, hash_emit
        
        bl pull2

        bl _putc

        b save1

#---------------------------------------------------------------------
# ( a w -- ),  [a] = w
def_word "!", "store", h_emit, hash_store
        
        bl pull2

        str snd, [fst]

drop1:
        adds idx, #CELL

        b save1

#---------------------------------------------------------------------
# ( a -- w ), w = [a]
def_word "@", "fetch", h_store, hash_fetch
        
        bl pull2
        
        ldr fst, [fst]
        
        b back1

#---------------------------------------------------------------------
# ( w1 w2 -- w), NOT(w1 AND w2)
def_word "nand", "nand", h_fetch, hash_nand
        
        bl pull2

        and fst, snd
        
        not fst, fst

        b keep1

#---------------------------------------------------------------------
# ( w1 w2 -- w), w = w1 + w2  
def_word "+", "plus", h_nand, hash_plus
        
        bl pull2

        add fst, snd
        
        b keep1

#---------------------------------------------------------------------
# ( 0 -- FALSE) | ( n -- TRUE), not #0 at top ?
def_word "0#", "zeroq", h_plus, hash_notzero

        bl pull2
        
isfalse:

        cmp fst, #0
        beq next

istrue:
        
        mov fst, #TRUE
        
        b back1

#---------------------------------------------------------------------
# ( -- state ), return an reference
def_word "u@", "userat", h_zeroq, hash_userat
        
        ldr fst, [usr] 

push1:
        ldr idx, [usr, #SPTR]
        
back1:
        adds idx, #-1*CELL

keep1:
        str fst, [idx]

save1:
        str idx, [usr, #SPTR]
        
        b next

#---------------------------------------------------------------------
def_word ":", "colon", h_userat, hash_colon
# save here, panic if semis not follow elsewhere
        
        ldr fst, [usr, #HERE]
        
        str fst, [usr, #HEAD]

# stat is 'compile' == 1
        
        add fst, #ONE
        
        str fst, [usr, #STAT]

# make a header:

# copy last into (here)
        
        ldr wrd, [usr, #LAST]
        
        bl comma

# get following token
        
        bl token
        
# copy hash into (here)

        mov wrd, hsh

finish:

        bl comma

        b next 

#---------------------------------------------------------------------
def_word ";", "semis",  h_colon, hash_semis 
# update last, panic if colon not lead elsewhere 
        
        ldr fst, [usr, #HEAD]
        
        str fst, [usr, #LAST]

# stat is 'interpret' == 0
        
        str #0, [usr, #STAT]

# compound words must ends with exit
        
        adr wrd, exit

        b finish

#---------------------------------------------------------------------
# Minimal Indirect Thread Code Engine
#
# this is the Forth heart beat.
#
# nest aka enter or docol, unnest aka exit or semis;
#
# "why there is no 'docol at start of words ?"
#
# ( -- ) 
def_word "exit", "exit", h_semis, hash_exit
unnest: #; exit
# return pull, ipt = (rpt), rpt += cell 
        
        ldr idx, [usr, #RPTR]
        
        ldr ipt, [idx]
        
        adds idx, #+1*CELL
        
        str idx, [usr, #RPTR]

next:
# wrd = (ipt) #; ipt += cell
        
        ldr wrd, [ipt]
        
        adds ipt, #+1*CELL

pick:
# compare address, if is a primitive then jumps 
        
        adr idx, ends
        
        cmp wrd, idx

        blt jump

nest:   #; enter
# return push, rp -= cell, (rpt) = ipt
        
        ldr idx, [usr, #RPTR]
        
        adds idx, #-1*CELL
        
        str ipt, [idx]
        
        str idx, [usr, #RPTR]

move: 
# indirect access 
        
        mov ipt, wrd
        
        b next

jump: 
# jump to primitive
        
        blx (wrd)

#----------------------------------------------------------------------
# system dependences, linux ecall
#

#include "minimal.S"

#---------------------------------------------------------------------
# any other primitives after exit
#---------------------------------------------------------------------

# .equ EXTRAS, YES

.ifdef EXTRAS
#----------------------------------------------------------------------
# keep last entry of primitives

.set into_extras, h_exit

#include "extras-milliforth.S"

#----------------------------------------------------------------------
# keep last entry of extras

.set h_last, from_extras

.endif

.ifndef EXTRAS

.set h_last, h_exit

.endif

#---------------------------------------------------------------------
# Beware, ends must be at last word in primitive ditionary !
#---------------------------------------------------------------------

#---------------------------------------------------------------------
ends:

.word 0xDEADBEEF

.end

