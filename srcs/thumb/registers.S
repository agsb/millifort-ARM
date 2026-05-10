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
 On arm64, armv8 linux syscalls use:
        syscal nr in X8, return X0, and parameters 
        X0 file descriptor
        X1 char * buffer
        X2 count
        X8 read (63) or write (64)
        
 For Cortex-M0, Armv6-M, RP2040 is little-endian

        R0-R12, generic use, R0-R7 low, R8-R11 high
        
        R13, SP stack pointer
        R14, LR link register
        R15, PC program pointer
        
        PSR, Program Status Register, bits 31 N, 30 Z, 29 C, 28 V

*/

@---------------------------------------------------------------------
@       CPU: Cortex-M0, Armv6-M, RP2040 is little-endian
@       for alias register names 
@
@       agsb@ 24/04/2026
@
@---------------------------------------------------------------------

@ proposal 

.arch armv6-m
.cpu cortex-m0

@.cpu cortex-m0plus

.thumb

@.syntax unified

@---------------------------------------------------------------------

@ hash value, svc
#define hsh r0 

@ link pointer, svc
#define lnk r1 

@ word pointer, svc
#define wrd r2 

@ generic, free
#define fst r3 

@ generic, free
#define snd r4 

@ generic, free
#define trd r5 

@ user struct pointer, constant 
#define usr r6

@ instruction pointer, preserved, svc
@ #define ipt r7 

@ instruction pointer, preserved
#define ipt r8 

@---------------------------------------------------------------------

