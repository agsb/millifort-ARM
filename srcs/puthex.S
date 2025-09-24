
#----------------------------------------------------------------------
# easy pretty print one char
#
.globl putchar

.macro putchar value
        mov r3, #\value
        bl _putc
.endm


#---------------------------------------------------------------------
.globl mhit

.macro mhit it
        putchar '\n'
        putchar \it
        putchar ' '
.endm

#---------------------------------------------------------------------
# easy it
#
.globl mhex

.macro mhex rg
        mov r3, \rg
        pushra
        call saves
        call puthey
        call loads
        pullra 
.endm

#---------------------------------------------------------------------
# code a 32-bit word in ASCII hexadecimal, same as puthex
#
.globl puthex

puthex:

        pushra

        mov r6, r3
        
        mov a3, ' '
        
        call _putc

        srli r5, r6, #24
        call 100f

        srli r5, r6, #16
        call 100f

        srli r5, r6, #8
        call 100f

        srli r5, r6, #0
        call 100f

        mov r3, r6

        pullra

        ret

100:

        pushra 

        andi r5, #255

        srli r4, r5, #4
        call 200f
        
        srli r4, r5, #0
        call 200f

        pullra

        ret

200:
        pushra

        andi r4, #15
        ori  r4, #48
        cmp  r4, ':'
        blt  300f
        addi r4, #7
300:
        mov r3, r4

        call _putc
        
        pullra

        ret

#---------------------------------------------------------------------
