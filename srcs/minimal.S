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
 Copyright (c) 2025, Alvaro Gomes Sobral Barcellos
 
 All rights reserved.
 
 see the disclaimer file in this repository.

*/


/*
#---------------------------------------------------------------------

 Note: 
        Use for Cortex-M0, Armv6-M, RP2040 is little-endian

        R0-R12, generic use
        
        R13, SP stack pointer
        R14, LR link register
        R15, PC program pointer
        
        PSR, Program Status Register, 
             bits 31 N, 30 Z, 29 C, 28 V

        syscall (aka ecalls) ARM/EABI uses 
        R7 _NR, R0-R6 parameters, R0 return value

        For milliforth is using r0-r6, r10, r11

*/

#---------------------------------------------------------------------
# linux ecall stuff, 29/07/2025, vide:
# https://github.com/riscv-software-src/riscv-pk/blob/master/pk/syscall.h

.equ _ZERO,      0
.equ _ONE,       1
.equ _STDIN,     0
.equ _STDOUT,    1

.equ _SBRK,     45
.equ _GETC,     63
.equ _PUTC,     64
.equ _EXIT,     93

#---------------------------------------------------------------------
.section .bss
_char:
.word   0x0

#---------------------------------------------------------------------

.section .text
.p2align 2, 0x0

#---------------------------------------------------------------------
# linux ecall for exit
_exit:
        mov r0, #_ZERO
        mov r7, #_EXIT
        swi #0

# load system call for init
_init:

        bx lr

#---------------------------------------------------------------------
# linux ecall for getc
_getc:
        mov r0, #_STDIN
        ldr r1, =_char
        mov r2, #_ONE
        mov r7, #_GETC
        swi #0

        #EOF?
        cmp r0, #0
        beq _exit

        ldrb r3, [r1]

        # echo, leave fallthrough
        # bx lr

#---------------------------------------------------------------------
# linux ecall for putc
_putc:
        mov r0, #_STDOUT
        ldr r1, =_char
        mov r2, #_ONE
        mov r7, #_PUTC
        strb r3, [r1]

_rets:
        swi #0
        bx lr

/*
#---------------------------------------------------------------------
.set FORTH_SIZE, 65536

_sbrk:
        mov r0, #0
        mov r7, #_SBRK
        swi #0
        
        # this is where here is
        mov r3, r0

        # gets more memory
        adds r0, #FORTH_SIZE
        b _rets

#---------------------------------------------------------------------
*/
