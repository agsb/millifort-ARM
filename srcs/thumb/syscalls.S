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

#---------------------------------------------------------------------
#
# Note: system swi #0s do not use ra 
#

#---------------------------------------------------------------------
# linux swi #0 stuff, 29/07/2025, vide:
# https://github.com/riscv-software-src/riscv-pk/blob/master/pk/syscall.h
# https://gpages.juszkiewicz.com.pl/syscalls-table/syscalls.html

.equ _ZERO,      0
.equ _ONE,       1
.equ _STDIN,     0
.equ _STDOUT,    1

.equ _GETC,     63
.equ _PUTC,     64
.equ _EXIT,     93

#---------------------------------------------------------------------
.section .data
_char:
        .word   0x0

#---------------------------------------------------------------------
.section .text

# load system call for exit
_exit:
        mov r7, #_EXIT
        mov r0, #_ZERO
        swi #0

# load system call for init
_init:
        
        bx lr

# linux swi #0 for getc
_getc:
        mov r7, #_GETC
        mov r0, #_STDIN
        ldr r1, =_char
        mov r2, #_ONE
        swi #0
        strb r3, [ a1, #0 ]
        
        #EOF?

        cmp r0, #0
        beq _exit

.ifndef echoo

        bx lr

.endif

# linux swi #0 for putc
_putc:
        mov r7, #_PUTC
        mov r0, #_STDOUT
        ldr r1, =_char
        mov r2, #_ONE
        ldrb r3, [ a1, #0 ]

_rets:
        swi #0
        bx lr

/*

.ifdef extras

.equ _MMAP,     192
.equ _SBRK,     45
.equ _FCNT,     55

#---------------------------------------------------------------------
_fcntl: # fd, cdm, arg
        mov r7, _FCNT 
        mov r0, r3
        mov r1, r4
        mov r2, r5
        bl _rets
        
#---------------------------------------------------------------------
_fcntls:
        ldr idx, [ usr, #SPTR ]
        ldr r0, [ idx, #0 ]
        ldr r1, [ idx, #CELL ]
        ldr r2, [ idx, #(CELL+CELL) ]
        add idx, idx, #(CELL+CELL)
        sw idx, [ usr, #SPTR ]
        mov r7, _FCNT 
        bl _rets
        
#---------------------------------------------------------------------
_sbrkq:
        mov r7, #_SBRK
        mov r0, #0x0
        swi #0
        # add memory 
        mov r7, #_SBRK
        add r0, r0, r3
        bl _rets

.endif

*/

