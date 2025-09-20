
#----------------------------------------------------------------------
# easy pretty print one char
#
.globl putchar

.macro putchar value

        mov a3, #\value

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
.globl mhey

.macro mhey rg

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
.globl putxy

puthex:

        pushra

        add  s2, zero, a3
        
        addi s5, zero, ':'

        addi a3, zero, ' '
        
        call _putc

        srli s3, s2, 24
        call 100f
        srli s3, s2, 16
        call 100f
        srli s3, s2, 8
        call 100f
        srli s3, s2, 0
        call 100f

        add  a3, zero, s2

        pullra

        ret

100:

        pushra 

        andi s3, s3, 0xFF
        
        srli s4, s3, 4
        call 200f
        
        srli s4, s3, 0
        call 200f

        pullra

        ret

200:
        pushra

        andi s4, s4, 0x0F
        ori  s4, s4, 48
        blt  s4, s5, 300f
        addi s4, s4, 7
300:
        add a3, zero, s4

        call _putc
        
        pullra

        ret

#---------------------------------------------------------------------
