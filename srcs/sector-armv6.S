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

    Made for a little endian, cell size of 4 bytes, 32-bit

    This version relies on the .data, .text, .rodata, .bss sections 
    being in this order, the dictionary will continue at end of .bss.

    Not working yet :)

*/

#---------------------------------------------------------------------
# using pre-processor CPP (GNU GCC)
# for alias register names 
# beware about changes
# r3, r0, r1, r2, r7 are used by ecalls in _putc and _getc
# r4, r5, r6 are generics

#include "defines.S"

#---------------------------------------------------------------------

# .equ debug, YES

# .equ dismiss, YES

# .equ postpones, YES

#---------------------------------------------------------------------
# macro to define the header of words in dictionary
#
.global def_word

.set h_last, 0

.macro def_word name, label, hash
.p2align 2, 0x0
h_\label:
        .int h_last
        .word \hash
\label:
        .set h_last, h_\label
.endm

#---------------------------------------------------------------------
# for deep, more than one, nested calls
# also does return
#
.global pushra
.macro pushra
        push { r3, lr }
.endm

.global pullra
.macro pullra
        pop { r3, pc }
.endm

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

# easy pretty print one char
#
.global putchar

.macro putchar value
       mov a3, #\value
       bl _putc
.endm

#----------------------------------------------------------------------
.section .data

# There is no spoon.

#----------------------------------------------------------------------
.section .bss
.p2align 2, 0x0

#----------------------------------------------------------------------
# This is it

_user:
# user parameter offsets
.skip 8 * CELL

# scratch workspace, generic use. 
_pack:
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

# start of user dictionary 
h_here: .word 0x0

#----------------------------------------------------------------------
.text 
.p2align 2, 0x0

# xxx
.ifdef debug

#include "puthex.S"

.endif

#----------------------------------------------------------------------
.globl _start

_start:

#----------------------------------------------------------------------
# do any system inits
init:
# just for sake

        # bl _init

#----------------------------------------------------------------------
# do what need be only once
cold:
# load user pointer address

        ldr usr, =_user
        
#----------------------------------------------------------------------
# wipe the dictionary
warm:
# next heap free cell  (end of .bss)

        ldr fst, =h_here
        str fst, [usr, #HERE]

# link list of headers, aka dictionary

        ldr fst, =h_last
        str fst, [usr, #LAST]
        
#---------------------------------------------------------------------
# reset TIB
reset:

        ldr fst, =_tib
        str fst, [usr, #TOIN]

#---------------------------------------------------------------------
# unexpected end of dictionary
miss:

# xxx
.ifdef dismiss

        j abort

# wipe remains compiled

       	putchar '\n'
# trd id BL
100:
       	lb fst, 0 (idx)
       	call _putc
	beq fst, trd, 100f
	addi idx, idx, ONE
	j 100b
100:
        putchar ' '
 	putchar '?'

wipe:
        # compiling ?
        ldr fst, [usr, #STAT]
        cmp fst, #0
        bne 100f

        # wipe remains
        ldr fst, [usr, #HEAD]
        str fst, [usr, #HERE]
100:
        b error

.endif 


# reset stacks

error:

# xxx 
.ifdef debug

        putchar '\n'
        putchar '?'
        putchar '?'
        putchar '\n'
.endif

#---------------------------------------------------------------------
abort:
# reset data stack
        
        ldr fst, =sp0 
        str fst, [usr, #SPTR]

#---------------------------------------------------------------------
quit:
# reset return stack
        
        ldr fst, =rp0 
        str fst, [usr, #RPTR]

# stat is 'interpret' == \0
        
        mov fst, #0
        str fst, [usr, #STAT]

#---------------------------------------------------------------------
okey:

# bl prompt_okey

# xxx
.ifdef debug

        ldr fst, [usr, #STAT]
        cmp fst, #0
        bne tick

        putchar '\n'
        putchar 'O'
        putchar 'K'
        putchar '\n'

.endif

#---------------------------------------------------------------------
# get a hash of the next token
tick:
        
        bl token

#---------------------------------------------------------------------         
# search for a hash in dictionary linked list 
#
find:

# get the latest link
        
        ldr lnk, [usr, #LAST]

100:
# verify end of dictionary, take care to abort
        
        cmp lnk, #0
        beq miss    

# linked list
        
        mov fst, lnk

# move next link 
        
        ldr lnk, [fst, #0]

# move to hash
        
        adds fst, #CELL

        ldr wrd, [fst]

# mask the FLAG and hold it in snd

        ldr snd, =FLAG_IMM

        ands snd, wrd

        eor wrd, snd

# compare
        
        cmp hsh, wrd

        bne 100b

# wrd points to or start of code or list of references

        adds fst, #CELL

#---------------------------------------------------------------------         
eval:
# executing ? if state == 0
        
        ldr wrd, [usr, #STAT]
        
        cmp wrd, #0

        beq execute

.ifdef postpones
# postpone ? if state < 0
        
        cmp wrd, #0

        blt postpone
.endif
        
# immediate ? 

        cmp snd, #0

        bne immediate      

#---------------------------------------------------------------------         
.ifdef postpones
# reset state to compile
postpone:
        addi trd, zero, ONE
        sw trd, [usr, #STAT]
        adds wrd, ONE
        sw wrd, STAT (usr)
.endif

# compiling ? if state != 0
compile:

        bl docomma

        b tick

#---------------------------------------------------------------------         
execute:
immediate:

        ldr ipt, =tickpt

        b pick

# zzzz
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

        ldrb snd, [idx, #0]

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
  
        ldr idx, =_tib
        
        str idx, [usr, #TOIN]

# ever start with a space
        
        mov fst, #BL

# loop and fill the TIB until \n
# no test end of buffer 
300:
        strb fst, [idx, #0]
        
        adds idx, #ONE

# get next char

        bl _getc

# echo it, if need

        # bl _putc

# cast to 7-bit ascii only 

        # and fst, fst, #127

# \n ^J ends the line

        cmp fst, #NL
        bne 300b

# at end-of-line
400:

# replace \n with space 
        mov fst, #BL
        strb fst, [idx, #0]

# mark eol with \0
        mov fst, #0
        strb fst, [idx, #1]

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

.ifdef dismiss

	mov wrd, idx

.endif

        # easy 5381
   
        ldr hsh, =DJB2

100:
        ldrb fst, [idx, #0]
        
        cmp fst, #BL
        beq 200f

        mov snd, hsh

        lsl hsh, hsh, #SFHT
        
        add hsh, snd
        
        eor hsh, fst
        
        adds idx, #ONE
        
        b 100b

#---------------------------------------------------------------------
200:    

# mask forth flag 
mask:

        ldr fst, =MASK_IMM
        
        and hsh, fst

#---------------------------------------------------------------------
# save toin

        str idx, [usr, #TOIN]

.ifdef dismiss

        mov idx, wrd

.endif

        pullra

#---------------------------------------------------------------------
docomma:
        
        ldr idx, [usr, #HERE]
      
        str fst, [idx]
      
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
        
        ldr fst, [idx, #0]

        adds idx, #CELL

        ldr snd, [idx, #0]

        bx lr

#---------------------------------------------------------------------
# ( -- c ) 
def_word "key", "key", hash_key

        bl _getc

        b push1

#---------------------------------------------------------------------
# ( c -- ) 
def_word "emit", "emit", hash_emit
        
        bl pull2

        bl _putc

        b save1

#---------------------------------------------------------------------
# ( a w -- ),  [a] = w
def_word "!", "store", hash_store
        
        bl pull2

        str snd, [fst, #0]

drop1:
        adds idx, #CELL

        b save1

#---------------------------------------------------------------------
# ( a -- w ), w = [a]
def_word "@", "fetch", hash_fetch
        
        bl pull2
        
        ldr fst, [fst, #0]
        
        b back1

#---------------------------------------------------------------------
# ( w1 w2 -- w), NOT(w1 AND w2)
def_word "nand", "nand", hash_nand
        
        bl pull2

        and fst, snd

        mvn fst, fst 
        
        b keep1

#---------------------------------------------------------------------
# ( w1 w2 -- w), w = w1 + w2  
def_word "+", "plus", hash_plus
        
        bl pull2

        add fst, snd
        
        b keep1

#---------------------------------------------------------------------
# ( 0 -- FALSE) | ( n -- TRUE), not #0 at top ?
def_word "0#", "zeroq", hash_notzero

        bl pull2
        
isfalse:

        cmp fst, #0
        beq next

istrue:
        
        mov fst, #TRUE
        
        b back1

#---------------------------------------------------------------------
# ( -- state ), return an reference
def_word "u@", "userat", hash_userat
        
        ldr fst, [usr, #0] 

push1:
        ldr idx, [usr, #SPTR]
        
back1:
        subs idx, #CELL

keep1:
        str fst, [idx, #0]

save1:
        str idx, [usr, #SPTR]
        
        b next

#---------------------------------------------------------------------
def_word ":", "colon", hash_colon
# save here, panic if semis not follow elsewhere
        
        ldr fst, [usr, #HERE]
        
        str fst, [usr, #HEAD]

# stat is 'compile' == 1
        
        mov fst, #ONE
        
        str fst, [usr, #STAT]

# make a header:

create:

# copy last into (here)
        
        ldr fst, [usr, #LAST]
        
        bl docomma

# get following token
        
        bl token
        
# copy hash into (here)

        mov fst, hsh

comma:

        bl docomma

        b next 

#---------------------------------------------------------------------
def_word ";", "semis", hash_semis 
# update last, panic if colon not lead elsewhere 
        
        ldr fst, [usr, #HEAD]
        
        str fst, [usr, #LAST]

# stat is 'interpret' == 0
        
        mov fst, #0

        str fst, [usr, #STAT]

# compound words must ends with exit
        
        ldr fst, =exit

        b comma

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
def_word "exit", "exit", hash_exit
unnest: #; exit
# return pull, ipt = (rpt), rpt += cell 
        
        ldr idx, [usr, #RPTR]
        
        ldr ipt, [idx], #CELL
        
        # adds idx, #CELL
        
        str idx, [usr, #RPTR]

next:
# wrd = (ipt) #; ipt += cell
        
        ldr wrd, [ipt]
        
        adds ipt, #CELL

pick:
# compare address, if is a primitive then jumps 
        
        ldr idx, =ends
        
        cmp fst, idx

        bge nest

jump: 
# jump to primitive
        
        blx fst

nest:   #; enter
# return push, rp -= cell, (rpt) = ipt
        
        ldr idx, [usr, #RPTR]
        
        # subs idx, #CELL
        
        str ipt, [idx, #-CELL]!
        
        str idx, [usr, #RPTR]

move: 
# indirect access 
        
        mov ipt, fst
        
        b next

#---------------------------------------------------------------------
# the outer loop, need for indirect

tickpt:
        
        .word okey

#----------------------------------------------------------------------
# system dependences, linux ecall
#

#include "minimal.S"

#---------------------------------------------------------------------
# any other primitives after exit
#---------------------------------------------------------------------

.ifdef debug

.equ EXTRAS, YES

#----------------------------------------------------------------------
.ifdef EXTRAS

.set into_extras, h_exit

#include "extras-armv6.S"

.set h_last, from_extras

.endif

.endif

#----------------------------------------------------------------------
.ifndef EXTRAS

.set h_last, h_exit

.endif

#---------------------------------------------------------------------
# Beware, ends must be at last word in primitive ditionary !
#---------------------------------------------------------------------

ends:

# .word 0xDEADBEEF

#---------------------------------------------------------------------
.end

