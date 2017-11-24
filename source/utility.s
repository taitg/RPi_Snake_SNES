/*
CPSC 359 Assignment 4, W2016
Geordie Tait 10013837

Contains variables and functions for handing miscellaneous utility functions
including number-to-ASCII, random numbers, and interrupt handling

PLEASE NOTE: Some commenting was done at home without the ability to
             compile, I don't think I broke anything but if I did please
             let me know ASAP so I can fix it and resubmit before it's
             too late. Thanks!
*/

.section    .data
.align      4

// buffer for number-to-ASCII
.globl      buffer
buffer:
    .rept   8
    .byte   0
    .endr

// variables for xorshift / random number generation
rand1:
    .int    1
rand2:
    .int    2
rand3:
    .int    3
rand4:
    .int    4

// data for interrupt handling
IntTable:
    // Interrupt Vector Table (16 words)
    ldr     pc, reset_handler
    ldr     pc, undefined_handler
    ldr     pc, swi_handler
    ldr     pc, prefetch_handler
    ldr     pc, data_handler
    ldr     pc, unused_handler
    ldr     pc, irq_handler
    ldr     pc, fiq_handler

reset_handler:      .word InstallIntTable
undefined_handler:  .word hang
swi_handler:        .word hang
prefetch_handler:   .word hang
data_handler:       .word hang
unused_handler:     .word hang
irq_handler:        .word irqHandler
fiq_handler:        .word hang

.section    .text

//----------------------------------------------------------------------------
/* Converts a given integer to an ASCII string and stores it in memory
 * Args:
 *  r0 - memory address for string
 *  r1 - number to convert
 * Return:
 *  r0 - length of the string
*/
.globl      itoa
itoa:
    push    { r4-r6, lr }
    // r4 = temp. holder for address
    // r5 = push loop counter (number of digits)
    // r6 = pop loop counter

    mov     r4, r0      // move the buffer address into r4 (from r0)
    mov     r0, r1      // move the number into r0 (from r1)

    mov     r5, #0      // initialize push loop counter (r5) to 0
pushLoop:
    mov     r1, #10     // divisor (10) into r1

    bl      divide      // branch to divide function

    add     r5, #1      // increment loop counter (r5)
    push    { r1 }      // push the remainder of division (r1) onto the stack
    cmp     r0, #0      // compare quotient (r0) to 0
    bne     pushLoop    //   branch to pushLoop if not equal

    mov     r6, #0      // initialize pop loop counter (r6) to 0
popLoop:
    pop     { r1 }      // pop digit off the stack into r1
    add     r1, #48     // raise the digit by 48 (number to ascii)
    strb    r1, [r4, r6]    // store digit in buffer, offset by counter (r6)
    add     r6, #1      // increment pop loop counter (r6)
    cmp     r6, r5      // compare pop counter (r5) to push counter (r6)
    blo     popLoop     //   branch to popLoop if less

    mov     r0, r5      // put length of string (r5) into r0

    pop     { r4-r6, pc }

//----------------------------------------------------------------------------
/* Clears the buffer used for itoa function
*/
.globl      ClearBuffer
ClearBuffer:
    push    { r4-r6, lr }
    mov     r4, #0
    mov     r5, #0
    ldr     r6, =buffer

clearLoop:
    strb    r5, [r6, r4]
    add     r4, #1
    cmp     r4, #8
    blo     clearLoop

    pop     { r4-r6, pc }

//----------------------------------------------------------------------------
/* Divides a number by another, producing a quotient and a remainder
 *  based on code demonstrated by Harriet Bazley at
 *  http://www.tofla.iconbar.com/tofla/pubs/arc/index.htm
 * Args:
 *  r0 - dividend
 *  r1 - divisor
 * Return:
 *  r0 - quotient
 *  r1 - remainder
*/
.globl      divide
divide:
    mov     r2, r1
    mov     r1, r0

    cmp     r2, #0
    beq     divDone

    mov     r0, #0
    mov     r3, #1

divStart:
    cmp     r2, r1
    movls   r2, r2, lsl #1
    movls   r3, r3, lsl #1
    bls     divStart

divNext:
    cmp     r1, r2
    subcs   r1, r1, r2
    addcs   r0, r0, r3

    movs    r3, r3, lsr #1
    movcc   r2, r2, lsr #1

    bcc     divNext

divDone:
    bx      lr

//----------------------------------------------------------------------------
/* Returns the length of a given null-terminated ascii string
 * Args:
 *  r0 - string's memory address
 * Return:
 *  r1 - length of the string
*/
.globl      strLen
strLen:
    // r1 = loop counter (length)
    // r2 = current byte

    mov     r1, #0          // initialize loop counter (r1) to 0
strLenLoop:
    ldrb    r2, [r0, r1]    // load byte of address offset by loop counter
    cmp     r2, #0          // compare byte to 0
    beq     strLenDone      //  branch to strLenDone if equal
    add     r1, #1          //  else increment counter and
    bal     strLenLoop      //      branch to strLenLoop

strLenDone:
    bx      lr              // return

//----------------------------------------------------------------------------
/* Produces a random integer using xorshift algorithm
 *  (from Wikipedia)
*/
.globl      xorShift
xorShift:
    ldr     r0, =rand1
    ldr     r0, [r0]

    mov     r1, r0, lsl #11
    eor     r0, r1

    mov     r1, r0, asr #8
    eor     r0, r1

    ldr     r2, =rand2
    ldr     r2, [r2]
    ldr     r1, =rand1
    str     r2, [r1]

    ldr     r2, =rand3
    ldr     r2, [r2]
    ldr     r1, =rand2
    str     r2, [r1]

    ldr     r2, =rand4
    ldr     r2, [r2]
    ldr     r1, =rand3
    str     r2, [r1]

    mov     r1, r2, asr #19
    eor     r2, r1
    eor     r0, r2, r0

    ldr     r1, =rand4
    str     r0, [r1]

    bx      lr

//----------------------------------------------------------------------------
/* Uses modulus to generate random number in range 0-maximum from xorshift
 * Args:
 *  r0 - maximum
 * Return:
 *  r0 - random number in the range
*/
.globl      GetRandom
GetRandom:
    push    { r4, lr }
    max     .req r4

    mov     r4, r0
    add     r4, #1
    bl      xorShift
    mov     r1, r4
    bl      divide
    mov     r0, r1

    .unreq  max
    pop     { r4, pc }

//----------------------------------------------------------------------------
/* Initializes first xorshift value to current clock value for better random
*/
.globl      InitRandom
InitRandom:
    push    { r4-r5, lr }
    address .req r4
    value   .req r5

    ldr     address, =0x20003004
    ldr     value, [address]
    ldr     address, =rand1
    str     value, [address]

    .unreq  address
    .unreq  value
    pop     { r4-r5, pc }

//----------------------------------------------------------------------------
/* Waits for a specified number of microseconds (from lecture slides)
 * Args:
 *  r0 - number of microseconds
*/
.globl      Wait
Wait:
    mov     r3, r0
    ldr     r0, =0x20003004     // address of CLO
    ldr     r1, [r0]
    add     r1, r3              // add (r3) microsec
waitLoop:
    ldr     r2, [r0]
    cmp     r1, r2              // stop when CLO = r1
    bhi     waitLoop
    bx      lr                  // return

//----------------------------------------------------------------------------
/* Initializes IRQ for timer interrupts
*/
.globl      InitIRQ
InitIRQ:
    push    { r4-r5, lr }
    addr    .req r4
    val     .req r5

    // reset CS
    ldr     addr, =0x20003000
    ldr     val, [addr]
    orr     val, #0b1010    // bits 1 and 3
    str     val, [addr]

    mov     val, #0

    // clear C1
    ldr     addr, =0x20003010
    str     val, [addr]

    // clear C3
    ldr     addr, =0x20003018
    str     val, [addr]

    // enable clock IRQ
    ldr     addr, =0x2000B210
    mov     val, #0b1010    // bits 1 and 3
    str     val, [addr]

    // enable IRQ
    mrs     r0, cpsr
    bic     r0, #0x80
    msr     cpsr_c, r0

    .unreq  addr
    .unreq  val
    pop     { r4-r5, pc }

//----------------------------------------------------------------------------
/* Installs int table for IRQ interrupts (from tutorial code)
*/
.globl      InstallIntTable
InstallIntTable:
    ldr     r0, =IntTable
    mov     r1, #0x00000000

    // load the first 8 words and store at the 0 address
    ldmia   r0!, {r2-r9}
    stmia   r1!, {r2-r9}

    // load the second 8 words and store at the next address
    ldmia   r0!, {r2-r9}
    stmia   r1!, {r2-r9}

    // switch to IRQ mode and set stack pointer
    mov     r0, #0xD2
    msr     cpsr_c, r0
    mov     sp, #0x8000

    // switch back to Supervisor mode, set the stack pointer
    mov     r0, #0xD3
    msr     cpsr_c, r0
    mov     sp, #0x8000000

    bx      lr

//----------------------------------------------------------------------------
/* Sets timer interrupt for 10 or 30 seconds from current time
 * Args:
 *  r0 - 0 = 30 seconds, 1 = 10 seconds
*/
.globl      StartClock
StartClock:
    push    { r4-r6, lr }
    addr    .req r4
    val     .req r5
    time    .req r6

    // get current clock value
    ldr     addr, =0x20003004   // clock (CLO)
    ldr     val, [addr]

    // check and branch for 30 vs. 10 seonds
    cmp     r0, #0
    bne     shortTimer

    ldr     time, =0x1C9C380    // 30 seconds
    bal     clockReady

shortTimer:
    ldr     time, =0x989680     // 10 seconds

clockReady:
    add     time, val
    ldr     addr, =0x20003010
    str     time, [addr]

    .unreq  addr
    .unreq  val
    .unreq  time
    pop     { r4-r6, pc }

//----------------------------------------------------------------------------
/* Adds a given amount of time to the timer interrupt value
 * Args:
 *  r0 - amount of time to add
*/
.globl      IncreaseClock
IncreaseClock:
    push    { r4-r5, lr }
    addr    .req r4
    val     .req r5

    ldr     addr, =0x20003010
    ldr     val, [addr]
    add     val, r0
    str     val, [addr]

    .unreq  addr
    .unreq  val
    pop     { r4-r5, pc }

//----------------------------------------------------------------------------
/* Handler for IRQ interrupts
 *  If timer interrupt detected, sets value pack flag (packTime)
*/
.globl      irqHandler
irqHandler:
    push    { r0-r12, lr }
    addr    .req r4
    val     .req r5

    // test if there is an interrupt pending in IRQ Pending 1
    ldr     addr, =0x2000B200
    ldr     val, [addr]
    tst     val, #0x100     // bit 8
    beq     irqDone

    // test if C1 caused the interrupt (IRQ pending 1)
    ldr     addr, =0x2000B204
    ldr     val, [addr]
    tst     val, #0b10      // pin 1
    beq     irqDone

    // reset CS
    ldr     addr, =0x20003000
    ldr     val, [addr]
    orr     val, #0b1010    // bits 1 and 3
    str     val, [addr]

    // set value pack flag
    ldr     addr, =packTime
    mov     val, #1
    strb    val, [addr]

irqDone:
    .unreq  addr
    .unreq  val
    pop     { r0-r12, lr }
    subs    pc, lr, #4

hang:
    b       hang

