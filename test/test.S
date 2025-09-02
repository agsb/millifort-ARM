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
 syscal nr in X8, return X0, parameters 
       X0 file descriptor
       X1 char * buffer
       X2 count
       X8 read (63) or write (64)

        from aapcs64.pdf:

        SP,     stack pointer
        r30,    LR, linker register
        r29,    FP, frame pointer

        r19-r28, callee-saved registers
        r18, plataform or temporary
        r17, IP1
        r16, IP0
        r9-r15, temporary registers
        r8, indirect result register
        r0-r7, parameters and results registers

        for milliforth is using r0-r6, r10, r11

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

/*
        linux syscalls uses x0 to x5
        

*/
#---------------------------------------------------------------------
.section .text

_start:
        mov r0, #0
        mov r8, #93
        svc #0

.end
# load system call for exit
_exit:
        ldr r0, _ZERO
        ldr r8, _EXIT
        svc #0

# load system call for init
# pass system parameters to program 
_init:
        ret

# linux ecall for getc
_getc:
        ldr r0, _STDIN
        la  r1, _char
        ldr r2, _ONE
        ldr r8, _GETC
        svc #0
        ldb r3, (a0)
        
        #EOF?
        beq r0, _exit

        ret

# linux ecall for putc
_putc:
        ldr r0, _STDOUT
        la  r1, _char
        ldr r2, _ONE
        ldr r8, _PUTC
        sdb r3, (x0)
        svc #0
        ret

#---------------------------------------------------------------------
