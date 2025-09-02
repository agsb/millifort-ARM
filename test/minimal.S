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
 on arm64, armv8 linux syscalls use:
        syscal nr in X8, return X0, and parameters 
        X0 file descriptor
        X1 char * buffer
        X2 count
        X8 read (63) or write (64)
        
        Use for Cortex-M0, Armv6-M, RP2040 is little-endian

        R0-R12, generic use
        
        R13, SP stack pointer
        R14, LR link register
        R15, PC program pointer
        
        PSR, Program Status Register, 
             bits 31 N, 30 Z, 29 C, 28 V

        For milliforth is using r0-r6, r10, r11

*/

#---------------------------------------------------------------------
# linux ecall stuff, 29/07/2025, vide:
# https://github.com/riscv-software-src/riscv-pk/blob/master/pk/syscall.h

.equ _ZERO,      0
.equ _ONE,       1
.equ _STDIN,     0
.equ _STDOUT,    1
.equ _GETC,     63
.equ _PUTC,     64
.equ _EXIT,     93

#---------------------------------------------------------------------
.section .bss
_char:
.word   0x0

#---------------------------------------------------------------------
.section .text

# linux ecall for exit
_exit:
        ldr r0, _ZERO
        ldr r8, _EXIT
        svc #0

# load system call for init
_init:
        bx lr

# linux ecall for getc
_getc:
        ldr r0, _STDIN
        adr r1, _char
        ldr r2, _ONE
        ldr r8, _GETC
        svc #0
        #EOF?
        cmp r0, #0
        beq _exit
        ldrb r3, (a0)
        bx lr

# linux ecall for putc
_putc:
        ldr r0, _STDOUT
        adr r1, _char
        ldr r2, _ONE
        ldr r8, _PUTC
        strb r3, (x0)
        svc #0
        bx lr

#---------------------------------------------------------------------

.equ CELL, 4
    #ldr idx, RPTR (usr)
       
    adds r3, #-1*CELL

    #str ipt, 0 (idx)

    #str idx, RPTR (usr)
