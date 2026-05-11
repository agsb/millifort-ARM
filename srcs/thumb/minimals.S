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

@---------------------------------------------------------------------
@
@ the minimal primitives 
@ 
@---------------------------------------------------------------------

@---------------------------------------------------------------------
@
@  djb2 hash cleared of bit 31
@
@---------------------------------------------------------------------
@ symbols ! @ + 0# : ;
.equ hash_store, 0x0002B584 
.equ hash_fetch, 0x0002B5E5 
.equ hash_plus,  0x0002B58E 
.equ hash_zeroq, 0x00596816 
.equ hash_colon, 0x0002B59F 

.equ hash_semis, 0x8002B59E @# unique with FLAG_IMM 

@---------------------------------------------------------------------
@ uppercase KEY EMIT EXIT NAND U@
.equ hash_KEY,   0x0B87F112
.equ hash_EMIT,  0x7C7C87D0
.equ hash_NAND,  0x7C8254C0
.equ hash_USERAT, 0x005973B0
.equ hash_EXIT,  0x7C7CC745

@---------------------------------------------------------------------

.equ init_minimals, last_next

@---------------------------------------------------------------------
@ ( -- ) ; aka figforth semis
def_word "EXIT", "exit", hash_EXIT, init_minimals

        bl unnest

@---------------------------------------------------------------------
@ ( -- ), ; aka figforth colon 
def_word ":", "colon", hash_colon, it_exit
@ save here, panic if semis not follow elsewhere
        
        ldr fst, [ usr, #HEAP ]
        
        str fst, [ usr, #PEEK ]

@ stat is 'compile' == 1
        
        mov fst, #COMPILE
        
        str fst, [ usr, #STAT ]

@ make a header

create:

@ copy last into (here)
        
        ldr fst, [ usr, #LAST ]
        
        bl comma

@ get a hash of the next token
        
        bl token

@ copy hash into (here)

        mov fst, trd

docomma:

        bl comma

        bl next 

@---------------------------------------------------------------------
@ ( -- ) ; aka figforth semicolon
def_word ";", "semis", hash_semis, it_colon 
@ update last, panic if colon not lead elsewhere 
        
        ldr fst, [ usr, #PEEK ]
        
        str fst, [ usr, #LAST ]

@ stat is 'execute' == 0
        
        mov fst, #EXECUTE

        str fst, [ usr, #STAT ]

finish:
@ compound words must ends with exit
        
        ldr fst, =is_exit

        bl docomma

@---------------------------------------------------------------------
@ ( -- c ) 
def_word "KEY", "key", hash_KEY, it_semis 

        bl _getc

        bl push1

@---------------------------------------------------------------------
@ ( c -- ) 
def_word "EMIT", "emit", hash_EMIT, it_key
        
        bl pull2

        bl _putc

        bl save1

@---------------------------------------------------------------------
@ ( a w -- ),  [a] = w
def_word "!", "store", hash_store, it_emit
        
        bl pull2

        str snd, [ fst, #0 ]

drop1:
        add trd, trd, #CELL

        bl save1

@---------------------------------------------------------------------
@ ( a -- w ), w = [a]
def_word "@", "fetch", hash_fetch, it_store
        
        bl pull2
        
        ldr fst, [ fst, #0 ]
        
        bl back1

@---------------------------------------------------------------------
@ ( w1 w2 -- w), NOT(w1 AND w2)
def_word "NAND", "nand", hash_NAND, it_fetch

        bl pull2

        and fst, snd, fst
        
        mvn fst, fst

        bl keep1

@---------------------------------------------------------------------
@ ( w1 w2 -- w), w = w1 + w2  
def_word "+", "plus", hash_plus, it_nand
        
        bl pull2

        add fst, snd, fst

        bl keep1

@---------------------------------------------------------------------
@ ( 0 -- FALSE) | ( n -- TRUE), not zero at top ?
def_word "0#", "zeroq", hash_zeroq, it_plus

        bl pull2
        
        cmp fst, #0
        beq back1

        mov fst, #0
        sub fst, #1
        
        bl back1

@---------------------------------------------------------------------
@ beware variables order
@ ( -- _user ) return an reference to _user structure
def_word "U@", "userat", hash_USERAT, it_zeroq
        
        mov fst, usr 

push1:
        ldr trd, [ usr, #SPTR ]
        
back1:
        sub trd, trd, #CELL

keep1:
        str fst, [ trd, #0 ]

save1:
        str trd, [ usr, #SPTR ]
        
        bl next

@---------------------------------------------------------------------

pull2:
        
        ldr trd, [ usr, #SPTR ]
        
        ldr fst, [ trd, #0 ]
        
        add trd, trd, #CELL

        ldr snd, [ trd, #0 ]

        bx lr 

@---------------------------------------------------------------------

.equ last_next, it_userat

@---------------------------------------------------------------------

.ifdef extras 

@---------------------------------------------------------------------
@
@  djb2 hash cleared of bit 31
@
@---------------------------------------------------------------------

.equ hash_DOCODE, 0x0059697A
.equ hash_ABORT, 0x0A1DFF4F
.equ hash_BYE, 0x0B87C61B
.equ hash_DOT, 0x0002B58B
.equ hash_HEX, 0x0002B581
.equ hash_NAN, 0x0B87D404 
.equ hash_LSHIFT, 0x2C5784C9 
.equ hash_RSHIFT, 0x416E6B97

@---------------------------------------------------------------------

.set init_extras, last_next

@---------------------------------------------------------------------
@ ( -- ) push 0x80000000 #; Not a Number and flag IMMEDIATE and error
def_word "NAN", "nan", hash_NAN, init_extras
by_erro:
by_zero:
by_under:        
by_over:

        mov fst, #0x80
        lsl fst, #24
        
        bl push1

@---------------------------------------------------------------------
@ ( w1 w2 -- w1<<w2 ) #; shift left
def_word "LSHIFT", "lshift", hash_LSHIFT, it_nan

        bl pull2
        
        lsl snd, fst
        
        mov fst, snd
        
        bl keep1

@---------------------------------------------------------------------
@ ( w1 w2 -- w1>>w2 ) #; shift right
def_word "RSHIFT", "rshift", hash_RSHIFT, it_lshift

        bl pull2
        
        lsr snd, fst
        
        mov fst, snd

        bl keep1

@---------------------------------------------------------------------
@ ( -- ) execute a jump and link
def_word ";$", "docode", hash_DOCODE, it_rshift 

        # jump and link to there 

        blx ipt
        
        # at there, save ra, do whatever, load ra,
        # end with  jalr s1, 0 (ra)
        # to return here, with s1 (is IP) to next cell 

        bl next

@---------------------------------------------------------------------
@ ( -- ) ae abort
def_word "ABORT", "aborts", hash_ABORT, it_docode

        bl abort

@---------------------------------------------------------------------
@ ( -- ) exit forth
def_word "BYE", "byes", hash_BYE, it_aborts

        bl _exit

@---------------------------------------------------------------------
@ ( w -- ) #; @
def_word "$", "hex", hash_HEX, it_byes

        bl number

        bl push1
        
@---------------------------------------------------------------------
@ ( w -- ) #; @
def_word ".", "dot", hash_DOT, it_hex

        bl pull2

        bl tohex

        bl save1
        
@---------------------------------------------------------------------

.equ last_next, it_dot

@---------------------------------------------------------------------
@ code a 32-bit word in ASCII hexadecimal
@ safe inside Forth words
@ 
tohex:

        save_lr

        mov snd, fst
        
        mov trd, #32

        # rolls 
100:
        cmp trd, #0
        beq 300f

        sub trd, trd, #4

        mov fst, snd
        lsr fst, trd
        mov hsh, #15
        and fst, hsh
        mov hsh, #48
        orr fst, hsh
        cmp fst, #58
        blt 200f
        add fst, #7
200:
        bl _putc
        
        bl 100b

300:

        load_lr

        bx lr 

@----------------------------------------------------------------------
@ code a ASCII $0-9A-F hexadecimal to value
@ safe inside Forth words
number:

        save_lr

        # clear result

        mov trd, #0

        mov snd, #80
        lsl snd, #24

        # skip spaces 
nskip:
        bl _getc
        cmp fst, #BL
        ble nskip

ndigit:

        bl digit

        cmp fst, snd
        beq nodigit

        lsl trd, trd, #4

        add trd, trd, fst
        
        # scan spaces 
nscan:
        bl _getc
        cmp fst, #BL
        blt nscan

        bne ndigit

isdigit:

        mov fst, trd 

nodigit:

        load_lr

        bx lr 

@ verify valid digit and convert it
digit:

100:
        #; valid digit, 0-9 and A-F  
        sub fst, fst, #48
        cmp fst, #0
        blt 400f

        #; 0-9 ?
        cmp fst, #10
        blt 200f

        #; normalize gap ascii 9 to A
        sub fst, fst, #7

        #; A to F ? No esoteric bases !
        cmp fst, #16
        bgt 400f

200:
        #; fst [ 0 .. 16 ]
        
        # ldr hst, [ usr, #BASE ]
        # bgt fst, hst, 400f

        bx lr 

400:
@ is_error, NaN

        mov fst, snd

        bx lr 

@---------------------------------------------------------------------
.endif
@---------------------------------------------------------------------

