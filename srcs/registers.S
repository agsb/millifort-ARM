@---------------------------------------------------------------------
@       CPU: Cortex-M0, Armv6-M, RP2040 is little-endian
@       for alias register names 
@
@       agsb@ 24/04/2026
@
@       svc     used in linux system calls
@
@---------------------------------------------------------------------

@ forth struct pointer, constant 
#define usr r9

@ instruction pointer, preserved
#define ipt r8 

@ forth address pointer, preserved
#define lrk r10 

@ forth address pointer, preserved
#define nib r11 

@ memory index, svc 
#define idx r0 

@ hash value, svc
#define hsh r1 

@ link pointer, svc
#define lnk r2 

@ word pointer, svc
#define wrd r3 

@ generic, free
#define fst r4 

@ generic, free
#define snd r5 

@ generic, free
#define trd r6 

@ generic, svc
#define fth r7 

@---------------------------------------------------------------------

