
//
//  Print "Hello world"
//
    .global _start

_start:
    mov  w8,64       // write system call
    mov  w0,1        // file (stdout)
    adr  x1,message  // message string
    mov  w2,len      // message length
    svc  0

    mov  w8,93       // exit system call
    mov  w0,0        // return code
    svc  0

message:
    .ascii "Hello world\n"
    len = . - message


