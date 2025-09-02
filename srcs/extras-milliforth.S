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

        extra words and routines for milliforth-riscv

*/

#---------------------------------------------------------------------
#
# djb2 hash cleared of bit 31
#
.equ hash_sfr, 0x00596858
.equ hash_exec, 0x7C6BC01E
.equ hash_docode, 0x0059695B 
.equ hash_donext, 0x0059697A
.equ hash_bye, 0x0B874AFB
.equ hash_abort, 0x0A1DFF4F
.equ hash_splist, 0x005966B8
.equ hash_rplist, 0x005966B9
.equ hash_dump, 0x7C6B2FE9
.equ hash_words, 0x0B6953F8
.equ hash_see, 0x0B878F36
.equ hash_dot, 0x0002B58B

.equ hash_cell,     0x7C70B163
.equ hash_cellplus, 0x0A86DDE8
.equ hash_cellless, 0x0A86DDEE

.macro mhex rg
        mov r3, #\rg
        bl puthex
        putchar ' '
.endm

.macro mhit it
        putchar '\n'
        putchar \it
        putchar ' '
.endm

#---------------------------------------------------------------------
# extras links to last primitive

#---------------------------------------------------------------------
# ( w -- w/2 ) #; shift right
def_word "2/", "sfr", into_extras, hash_sfr

        bl pull2
        
        lsr fst, #1
        
        b keep1

#---------------------------------------------------------------------
# ( a -- ) execute a word address at top of data stack
# not change the data stack
def_word "exec", "exec", h_sfr, hash_exec
        
        bl pull2
        
        mov wrd, fst

        b pick

#---------------------------------------------------------------------
# ( -- ) execute a jump to a reference at IP
def_word ":$", "docode", h_exec, hash_docode
        
        bx ipt

#---------------------------------------------------------------------
# ( -- ) execute a jump to next
def_word ";$", "donext", h_docode, hash_donext
        
        b next

#---------------------------------------------------------------------
# ( -- ) exit forth
def_word "bye", "byes", h_donext, hash_bye
        
        b _exit

#---------------------------------------------------------------------
# ( -- ) ae abort
def_word "abort", "aborts", h_byes, hash_abort
        
        b abort

#---------------------------------------------------------------------
# ( -- ) ae list of data stack
def_word ".S", "splist", h_aborts, hash_splist

        bl stackS

        b next

#----------------------------------------------------------------------
# ( -- ) ae list of return stack
def_word ".R", "rplist", h_splist, hash_rplist

        bl stackR
        
        b next

#----------------------------------------------------------------------
# ( a b -- a b ) dumps memory between a and b
def_word "dump", "dump", h_rplist, hash_dump

        bl pull2
        
        # xxx 
        
        ldr fst, [usr, #HERE]

        ldr snd, =h_here

        bl dumps

        b drop1

#----------------------------------------------------------------------
# ( -- ) list all words in compiled dictionary, 
def_word "words", "words", h_dump, hash_words

        bl wordf

        b next

#----------------------------------------------------------------------
# ( -- ) list last word in dictionary, 
def_word "see", "sees", h_words, hash_see

        bl wordu

        b next

#----------------------------------------------------------------------
# ( u -- u ) print tos in hexadecimal
def_word ".", "dot", h_sees, hash_dot

        bl pull2

        bl puthex

        b next


#---------------------------------------------------------------------
# ( -- w ) size of a cell 
def_word "cell", "cell", h_dot, hash_cell

        mov fst, #4

        b push1

#---------------------------------------------------------------------

.set from_extras, h_cell

#---------------------------------------------------------------------
#
# Note: 
#       nested user calls must save ra, relies in pushra and pullra
#       these routines uses Sn registers
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# code a 32-bit word in ASCII hexadecimal 
#
puthex:

        pushra

        bl saves

        mov r5, #58

        lsr r3, r2, #24
        bl 100f

        lsr r3, r2, #16
        bl 100f
        
        lsr r3, r2, #8
        bl 100f
        
        #lsr r3, r2, #0
        bl 100f

        b returns

100:

        pushra 

        and r3, #0xFF
        
        lsr r4, r3, #4
        bl 200f
        
        #lsr r4, r3, #0
        bl 200f

        pullra

200:
        pushra

        and r4, r4, #15
        orr  r4, r4, #48
        cmp r4, r5
        blt 300f
        add r4, r4, #7
300:
        mov r3, r4

        bl _putc
        
        pullra

#----------------------------------------------------------------------
saves:
        push { r0, r1, r2, r3, r4, r5, r6 }

        bx lr

#----------------------------------------------------------------------
loads:
        pop { r0, r1, r2, r3, r4, r5, r6 }
        
        bx lr

returns:

        bl loads

        pullra 

#----------------------------------------------------------------------
# shows all words at dictionary
wordf:
        pushra 

        bl saves

# get the latest link
        
        ldr r6, [usr, #LAST]
        
        putchar '\n'

100:
# verify end of dictionary
        
        cmp r6, #0
        beq returns

        mov r5, r6

        ldr r6, [r5]

        bl wordt

        ldr r4, =h_here
        cmp r6, r4
        blt returns

        b 100b

#----------------------------------------------------------------------
# shows one word at dictionary
wordu:
        pushra 

        bl saves

        ldr r5, [usr, #LAST]

        bl wordt

        b returns

#----------------------------------------------------------------------
# show entry in dictionary
wordt:

        pushra

# set the end-of-word as exit address

        putchar '\n'
        putchar '#'

100:
        putchar '\n'
        
        mhex r5
        
        ldr r4, [r5]
        
        mhex r4
       
        adds r5, #4

        ldr r3, =exit
        cmp r4, r3
        bne 100b

        pullra

#----------------------------------------------------------------------
stackS:

        pushra 

        bl saves

        putchar '\n'
        putchar 'S'

        ldr r6, [usr, #SPTR]
        ldr r5, =sp0

        bl stackp

        b returns

#----------------------------------------------------------------------
stackR:

        pushra 

        bl saves

        putchar '\n'
        putchar 'R'

        ldr r6, [usr, #RPTR]
        ldr r5, =rp0

        bl stackp

        b returns

#----------------------------------------------------------------------
stackp:
        
        pushra

        putchar '='

        mhex r5

        putchar '['
        putchar ' '

        cmp r5, r6
        beq 200f

100:
        subs r5, #CELL
        ldr r4, [r5]
        mhex r4

        cmp r5, r6
        bne 100b

200:
        putchar ']'

        pullra 

#----------------------------------------------------------------------
# 
dumps:
    
        pushra 

        bl saves

        # last (tos)
        mov r5, r3

        mhex r5

        # init (nos)
        mov r6, r4

        mhex a6

        # many
        sub r5, r6

        mhex a5

        putchar '\n'

100:
        mov r7, #8
        putchar '\n'
        mhex r6
        putchar ':'
        putchar ' '
200:
        ldr r4, [r6]
        mhex r4
        adds r6, #CELL
        subs r5, #CELL
        
        subs r7, #1
        cmp r7, #0
        beq 100b
        cmp r7, r5
        bne 200b

        b returns

#----------------------------------------------------------------------
# 
shows:
        pushra 

        bl saves

# registers

       putchar '\n'
        putchar 'R'
        putchar ' '
        
       putchar '0'
        putchar ' '
        mhex r0
       putchar '1'
        putchar ' '
        mhex r1
       putchar '2'
        putchar ' '
        mhex r2
       putchar '3'
        putchar ' '
        mhex r3
       putchar '4'
        putchar ' '
        mhex r4
       putchar '5'
        putchar ' '
        mhex r5
       putchar '6'
        putchar ' '
        mhex r6
        
# user parameters

        putchar '\n'
        putchar 'U'
        putchar ' '
        
       putchar 'S'
        putchar ' '
        ldr r3, [usr, #STAT]
        mhex r3
       
       putchar 'L'
        putchar ' '
        ldr r3, [usr, #LAST]
        mhex r3
       
       putchar 'H'
        putchar ' '
        ldr r3, [usr, #HERE]
        mhex r3
       
       putchar 'D'
        putchar ' '
        ldr r3, [usr, #HEAD]
        mhex r3
       
       putchar 'S'
        putchar 'P'
        putchar ' '
        ldr r3, [usr, #SPTR]
        mhex r3

       putchar 'R'
        putchar 'P'
        putchar ' '
        ldr r3, [usr, #RPTR]
        mhex r3
       
        b returns

#----------------------------------------------------------------------
# code a ASCII $0-F(Z) hexadecimal in a value
#  
number:

        pushra

        bl saves

        ldr r6, #0
        add r7, #8
100:
        bl digit
        lsr r6, #4
        orr r6, r3
        subs r7, #1
        cmp r7, #0
        bne 100b

        b returns

digit:
        #; any valid digit, 0-9 and A-Z, do not care 
        ldr r3, [idx]
        # compare with '0'
        subs r3, #48
        cmp r3, #0
        blt 200f
        # compare with 10
        cmp r3, #10
        blt 100f
        # offset to 'A'
        subs r3, #7 
100:
# is_okey
        bx lr

200:
# is_error
        bx lr


