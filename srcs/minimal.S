/*

 Copyright (c) 2025, Alvaro Gomes Sobral Barcellos
 All rights reserved.
 
 see the disclaimer file in this repository.

 minimal elf with exit code
*/

#define ecall   svc #0   
#define call    bl   
#define ret     bx lr

#---------------------------------------------------------------------
# linux svc #0 stuff, 29/07/2025, vide:
# https://github.com/riscv-software-src/riscv-pk/blob/master/pk/syscall.h

.equ ONE,       1
.equ STDIN,     0
.equ STDOUT,    1
.equ GETC,     63
.equ PUTC,     64
.equ EXIT,     93

#---------------------------------------------------------------------
.section .bss

.ifndef _pad
_pad:
.skip 32
.endif

#---------------------------------------------------------------------
.section .text

.ifndef _start
.globl _start
_start:
.endif

# load system call for exit
_exit:
        mov r0,  #STDIN
        mov r7,  #EXIT
        ecall

# load system call for init
_init:
        ret

# linux svc #0 for getc
_getc:
        mov r0,  #STDIN
        ldr r1, =_pad
        mov r2,  #ONE
        mov r7,  #GETC
        ecall
        ldr r3, [r1]
        ret

# linux svc #0 for putc
_putc:
        str r3, [r1]
        mov r0,  #STDOUT
        ldr r1, =_pad
        mov r2,  #ONE
        mov r7,  #PUTC
        ecall
        ret

# just not necessary

.if 0
# linux svc #0 for puts
_puts:
        # pointer to msg
        add r1, t3, zero
        # lenght of msg
        add r2, t4, zero

        mov r0,  #STDOUT
        mov r7,  #PUTC
        ecall
        j _init
.endif


