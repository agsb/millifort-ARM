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


@---------------------------------------------------------------------
@
@ Note: system ecalls do not use ra 
@

@---------------------------------------------------------------------
@ linux ecall stuff, 29/07/2025, vide:
@ https://github.com/riscv-software-src/riscv-pk/blob/master/pk/syscall.h
@ https://gpages.juszkiewicz.com.pl/syscalls-table/syscalls.html

.equ _ZERO,      0
.equ _ONE,       1
.equ _STDIN,     0
.equ _STDOUT,    1

.equ _SBRK,     45
.equ _FCNT,     55
.equ _GETC,     63
.equ _PUTC,     64
.equ _EXIT,     93
.equ _MMAP,     192

@---------------------------------------------------------------------
.section .data
_char:
        .word   0x0

@---------------------------------------------------------------------
.section .text

@ load system call for exit
_exit:
        movs r7, #_EXIT
        movs r0, #_ZERO
        svc #0

@ load system call for init
_init:
        
        bx lr

@ linux ecall for getc
_getc:
        movs r7, #_GETC
        movs r0, #_STDIN
        ldr  r1, =_char
        movs r2, #_ONE
        svc #0
        ldrb r3, [r1]
        
        #EOF?

        cmp r0, #0
        beq  _exit

.ifndef echoo

        bx lr

.endif

@ linux ecall for putc
_putc:
        movs r7, #_PUTC
        movs r0, #_STDOUT
        ldr  r1, =_char
        movs r2, #_ONE
        strb r3, [r1]

_rets:
        svc #0

        bx lr

/*
.ifdef extras
@---------------------------------------------------------------------
_sbrk:
        movs a7, _SBRK
        movs a0, 0x0
        j _rets

        # this is where here is
        # mov a3, a0

        # add memory 
        movs a7, _SBRK
        add a0, a0, a3

        j _rets

@---------------------------------------------------------------------
_fcntl: # fd, cdm, arg
        movs a7, _FNCT
        movs a0, a3
        movs a1, a4
        movs a2, a5
        j _rets
        
.endif
*/

