/*
@---------------------------------------------------------------------
 
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

@----------------------------------------------------------------------
*/

/*
@----------------------------------------------------------------------

    A MilliForth for RISCV 
 
    original for the RISCV, by Alvaro G. S. Barcellos, 2025
 
    https://github.com/agsb 

    see the disclaimer file in this repository.
 
    read notes in this repository.
 
    Stacks moves backwards, decrease then push, pull then increase.

    Made for a little endian RiscV, cell size of 4 bytes, 32-bit

    This version relies on the .text, .rodata, .data, .bss sections 
    being in this order, the dictionary continues at .bss.

        THIS VERSION USES ONLY HASH HEADERS. NO NAMES, NO SIZES

        THIS VERSION USES STREAMS. NO TIB, NO LINES, NO CONTROLS

        USE ONLY ASCII TOKENS IN MIXED CASE AND BETWEEN SPACES

@----------------------------------------------------------------------
*/

@---------------------------------------------------------------------
@ using pre-processor CPP (GNU GCC) for alias names 
@---------------------------------------------------------------------

#include "defines.S"

#include "registers.S" 

@---------------------------------------------------------------------
@ macro to define the header of words in dictionary
@
.global def_word

.macro def_word name, label, hash, last
it_\label:
        .word \last
        .word \hash
is_\label:
.endm

@---------------------------------------------------------------------
@ Riscv does not have automatic, and hidden, SP push/pull
@ for two level nested calls, use save_lr and load_ra
@ ever use as macro

@ one deep

.macro  save_lr
        push { lr }
.endm

.macro  load_lr
        pop { lr }
.endm

@----------------------------------------------------------------------
@ Nothing here, void.
.section .data
.p2align 4, 0x0

@ There is no spoon.

@----------------------------------------------------------------------
@ but always in RAM :)
.section .bss
.p2align 4, 0x0

@ void at top of bss 

@ all forth variables and stacks by offset of _user
@ beware change offsets

@ user stack of parameter, for offsets vide defines.S
_user:
.skip user_size, 0x0

@ data stack grows backward, bottom 
_spz:
.skip sp_size, 0x0
_sp0: 
        @ top of data stack, keep
        .word 0x0

@ return stack grows backward, bottom
_rpz:
.skip rp_size, 0x0
_rp0: 
        @ top of return stack, keep
        .word 0x0

@----------------------------------------------------------------------
@ NOTE:
@----------------------------------------------------------------------

@ user dictionary 
.word 0x0

@ at start of memory
h_where: 
.skip RAM_LIMIT - ( h_where - _user )
@ to end of  memory
h_there:

@----------------------------------------------------------------------
.text 
.p2align 2, 0x0

@---------------------------------------------------------------------
@ xxx
.ifdef tools

@include "puthex.S"

.endif

@----------------------------------------------------------------------
.globl _start

@.p2align 4, 0x00

_start:

@----------------------------------------------------------------------
@ go ! go ! go !
main:

@ do any system initializations
@ call _init

@----------------------------------------------------------------------
@ do what need be only once
cold:
@ load constant pointer address

        ldr r9, =_user

        @la nib, _nibs
        
        @la bow, is_warp

@ xxx 
.ifdef beatme
        @# beat
        li t0, 0
        @# tick
        li t1, 0
        @# tack
        li t2, 0
.endif

@.end

@----------------------------------------------------------------------
@ wipe the dictionary
warm:
@ last link list of primitives, aka dictionary

        ldr fst, =h_last
        str fst, [usr, #LAST]

@ next heap free cell
        
        @# la fst, h_where
        ldr fst, =h_where
        str fst, [usr, #HEAP]

@---------------------------------------------------------------------
@ unexpected end of dictionary
miss:

@ xxx 
.ifdef tools

        @# emote 
        putchar '\n'
        putchar '?'
        putchar '?'
        putchar '\n'

.endif

@ xxx
.ifdef missed

        @# not compiling ? 
        ldr fst, [usr, #STAT]
        @# execute is zero
        cmp fst, #0
        beqz =100f
        
        @# wipe remains, reclaims space.
        ldr fst, [usr, #PEEK]
        str fst, [usr, #HEAP]
        mov fst, #EXECUTE
        str fst, [usr, #STAT]
100:
.endif

@---------------------------------------------------------------------
abort:
@ reset data stack
        
        @# la fst, sp0 
        ldr fst, =sp0
        str fst, [usr, #SPTR]

@---------------------------------------------------------------------
quit:
@ reset return stack
        
        @#la fst, rp0 
        ldr fst, =rp0
        str fst, [usr, #RPTR]

@---------------------------------------------------------------------
@ stat is 'interpret' == \0
        
        mov fst, #EXECUTE
        str fst, [usr, #STAT]

@---------------------------------------------------------------------
@ 
warp:

@ xxx
.ifdef tools

        @# not compiling ?
        ldr fst, [usr, #STAT]
        @# execute is zero
        cmp fst, #0
        bne =100f

        @# emote 
        putchar '\n'
        putchar 'O'
        putchar 'K'
        putchar '\n'

100:
.endif

        @# get a hash of the next token in trd
        
        bl token

@---------------------------------------------------------------------         
@ search for a hash in dictionary linked list 
@ trd have the hash of the word
@
find:

        @# get the latest link
        
        ldr lnk, [usr, #LAST]

100:
        @# verify end of dictionary 
        
        cmp lnk, #0
        beq =miss

        @# linked list
        
        mov fst, lnk

        @# copy next link 
        
        ldr lnk, [fst, #0]

        @# copy the hash
        
        add fst, fst, #CELL

        ldr hsh, [fst, #0]

        @# mask the FLAG, hold it in snd

        mov snd, #FLAG_IMM

        and snd, hsh, snd

        eor hsh, hsh, snd

        @# compare trd equ hash
        
        cmp trd, hsh
        bne =100b

        @# points to code or list, aka xt

        add fst, fst, #CELL

@---------------------------------------------------------------------         
@ snd have the flag
@ fst have the address after header
eval:
        @# what to do ?

        ldr wrd, [usr, #STAT]
        
@ XXX
.ifdef postpone
        li lnk, #POSTPONE
        cmp wrd, lnk
        bne =100f
        mov lnk, #COMPILE
        str lnk, [usr, #STAT]
        bl compile
100:
.endif
        
        @# executing ? if state == 0

        cmp wrd, #0
        beq =execute

        @# immediate ? if flaged

        cmp snd, #0
        bne =execute      

        @# compiling  
compile:
        
        bl comma

        bl warp

@ immediate:
execute:

        mov ipt, #is_warp

        bl pick

@---------------------------------------------------------------------
@ crude token
@ load a valid sequence of ascii from stream, wipes all controls, 
@ any token must be between spaces
@----------------------------------------------------------------------
@ djb2 hash function
@ classic djb2 hash algorithm, with XOR, adapted from cdb_hash
@---------------------------------------------------------------------
@ magic numbers
.equ DJB2, 5381
.equ SFHT, 5
@---------------------------------------------------------------------
@ return the hash of token in trd
@ do not change the registers !
token:
        save_lr

        @# prepare for hash

        ldr trd, #DJB2

        @# load word separator, BL is space

        mov spc, #BL

        @# skip spaces
skip:
        bl _getc

        cmp fst, spc
        ble =skip
        
        @# djb2 hash function
hash:        

        mov snd, trd

        lsl trd, trd, #SFHT
        
        add trd, trd, snd
        
        eor trd, trd, fst
        
        @# scan spaces
scan:
        bl _getc

        cmp fst, spc
        blt =scan
        
        bne =hash

        @# clear hash high bit 
mask:

        lsl trd, trd, #ONE

        lsr trd, trd, #ONE

        load_lr

        bx lr
        
@---------------------------------------------------------------------
comma:

        ldr trd, [usr, #HEAP]
      
        str fst, [trd, #0]
      
        add trd, trd, #CELL
      
        str trd, [usr, #HEAP]

        bx lr

@---------------------------------------------------------------------
@ the outer loop, need for indirect

is_warp:
        
       .word warp

@---------------------------------------------------------------------
@ Minimal Indirect Thread Code Engine
@
@ this is the Forth heart beat.
@
@ nest aka enter or docol, 
@ 
@ unnest aka exit or semis
@
@ ipt must stay preserved outside, ever.
@
@ "why there is no 'docol at start of words ?"
@
@---------------------------------------------------------------------
@ return pull 
unnest: 
        
        ldr trd, [usr, #RPTR]
        
        ldr ipt, [trd, #0]
        
        add trd, trd, #CELL
        
        str trd, [usr, #RPTR]

@ next heart beat
next:
@ xxx
.ifdef beatme
        add t0, t0, 1
.endif

        ldr fst, [ipt, #0]
        
        add ipt, ipt, #CELL

@ compare address, if is a primitive then jumps, MITC 
pick:
        
        ldr trd, =h_where
        cmp fst, trd
        bge =nest

@ jump to primitive
jump: 
@ xxx
.ifdef beatme
        add t1, t1, 1
.endif

        @# really jump and link 
        blx fst

@ return push
nest:   
@ xxx
.ifdef beatme
        add t2, t2, 1
.endif

        ldr trd, [usr, #RPTR]
        
        sub trd, trd, #CELL
        
        str ipt, [trd, #0]
        
        str trd, [usr, #RPTR]

move: 
@ resolve indirect thread
        
        mov ipt, fst
        
        bl next

@----------------------------------------------------------------------

@----------------------------------------------------------------------
@ system dependences, linux ecall
@---------------------------------------------------------------------

@include "syscalls.S"

@---------------------------------------------------------------------
@ forth words
@---------------------------------------------------------------------

@----------------------------------------------------------------------
.set last_next, 0x0

@include "minimals.S"

@----------------------------------------------------------------------
.ifdef primitives

@include "primitives.S"

.endif

@----------------------------------------------------------------------
.ifdef tools

@include "tools.S"

.endif

@----------------------------------------------------------------------
.set h_last, last_next

@---------------------------------------------------------------------
@ Beware, ends must be at last word behind native ditionary !
@ it is used to know if a 'address' is primitive or not
@---------------------------------------------------------------------

_nibs:

@---------------------------------------------------------------------
.end

