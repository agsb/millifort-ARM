.equ CELL, 4
.equ SPTR, 0 * CELL
.equ RPTR, 1 * CELL

#include "defines.S"

.text

_start:

main:

        # return pull, ipt = (rpt), rpt += cell

        ldr idx, [usr, RPTR],
        ldr ipt, [idx]
        add idx, idx, +1 * CELL
        sdr idx, [usr, RPTR]

        # return push, rp -= cell, (rpt) = ipt

        ldr idx, [usr, RPTR],
        add idx, idx, -1 * CELL
        sdr ipt, [idx], CELL
        sdr idx, [usr, RPTR]


