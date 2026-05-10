
@ Allocate a data segment to define new words and data
@ structures

        .set INITIAL_DATA_SEGMENT_SIZE,65536
        .text
        .align 2

set_up_data_segment:

        mov r1, #0
        mov r7, #__NR_brk
        swi 0                   @ Call brk(0) to get value of Program Break

        ldr r1, =var_HERE
        str r0, [r1]            @ Initialize HERE to point at the beginning
                                @ of data segment

        add r0, #INITIAL_DATA_SEGMENT_SIZE
        swi 0                   @ Allocate Memory

        bx      lr              @ Return

