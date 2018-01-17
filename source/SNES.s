/*
SNAKE for Raspberry Pi
Geordie Tait

Contains functions for initializing and handling SNES controller input

*/


.section    .data
.align      4

// amount of time to wait for next controller input
.globl  inputDelay
inputDelay:
    .int    250000
    
.section    .text

//----------------------------------------------------------------------------
/* Initializes GPIO for SNES controller (clock, latch, or data line)
 * Args:
 *  r0 - pin number (9, 10 or 11)
 *  r1 - function code (0 or 1)
*/
.globl      Init_GPIO
Init_GPIO:
    mov     r3, r1          // put function code (r1) into r3
    mov     r2, #7          // r2 = b0111

    cmp     r0, #9          // compare given pin# (r0) to 9
    beq     initLatch       //  branch to initLatch if equal
    cmp     r0, #10         // compare given pin# (r0) to 10
    beq     initData        //  branch to initData if equal
    cmp     r0, #11         // compare given pin# (r0) to 11
    beq     initClock       //  branch to initClock if equal
    bal     initRet         // else branch to initRet

initClock:
// Initializing SNES clock line (directly from slides)
//  set GPIO pin 11 (CLK) to output
    ldr     r0, =0x20200004 // address for GPFSEL1
    ldr     r1, [r0]        // copy GPFSEL1 into r1
    lsl     r2, #3          // index of 1st bit for pin11
                            // r2 = 0 111 000
    bic     r1, r2          // clear pin11 bits
    lsl     r3, #3          // r3 = 0 001 000
    bal     initDone

initLatch:
// Initializing SNES latch line
//  set GPIO pin 9 (latch) to output
    ldr     r0, =0x20200000 // address for GPFSEL0
    ldr     r1, [r0]        // copy GPFSEL0 into r1
    lsl     r2, #27         // index of 1st bit for pin9
                            // r2 = 0 111 000 ...
    bic     r1, r2          // clear pin11 bits
    lsl     r3, #27         // r3 = 0 001 000 ...
    bal     initDone

initData:
// Initializing SNES data line
//  set GPIO pin 10 (data) to input (code 0)
    ldr     r0, =0x20200004 // address for GPFSEL1
    ldr     r1, [r0]        // copy GPFSEL1 into r1
    bic     r1, r2          // clear pin10 bits

initDone:
    orr     r1, r3          // set pin function in r1
    str     r1, [r0]        // write back to GPFSEL{n}

initRet:
    bx      lr              // return

//----------------------------------------------------------------------------
/* Initializes SNES latch, data and clock lines via GPIO
*/
.globl      InitSNES
InitSNES:
    push    { lr }

    mov     r0, #9          // Initialize GPIO pin 9 (latch)
    mov     r1, #1          //  to 1 (output)
    bl      Init_GPIO
    mov     r0, #10         // Initialize GPIO pin 10 (data)
    mov     r1, #0          //  to 0 (input)
    bl      Init_GPIO
    mov     r0, #11         // Initialize GPIO pin 11 (clock)
    mov     r1, #1          //  to 1 (output)
    bl      Init_GPIO

    pop     { pc }

//----------------------------------------------------------------------------
/* Writes given value to GPIO latch line (pin 9) (from lecture slides)
 * Args:
 *  r1 - value to write (0 or 1)
*/
.globl      Write_Latch
Write_Latch:
    mov     r0, #9          // pin 9 (latch)
    ldr     r2, =0x20200000 // base GPIO reg
    mov     r3, #1
    lsl     r3, r0          // align bit for pin 9
    teq     r1, #0
    streq   r3, [r2, #40]   // GPCLR2
    strne   r3, [r2, #28]   // GPSET0
    bx      lr              // return

//----------------------------------------------------------------------------
/* Writes given value to GPIO clock line (pin 11) (from lecture slides)
 * Args:
 *  r1 - value to write (0 or 1)
*/
.globl      Write_Clock
Write_Clock:
    mov     r0, #11         // pin 11 (clock)
    ldr     r2, =0x20200000 // base GPIO reg
    mov     r3, #1
    lsl     r3, r0          // align bit for pin 9
    teq     r1, #0
    streq   r3, [r2, #40]   // GPCLR2
    strne   r3, [r2, #28]   // GPSET0
    bx      lr              // return

//----------------------------------------------------------------------------
/* Reads from GPIO data line (pin 10)
 * Return:
 *  r0 - data line value (0 or 1)
*/
.globl      Read_Data
Read_Data:
    mov     r0, #10         // pin 10 (data)
    ldr     r2, =0x20200000 // base GPIO reg
    ldr     r1, [r2, #52]   // GPLEV0
    mov     r3, #1
    lsl     r3, r0          // align pin 10 bit
    and     r1, r3          // mask everything else
    teq     r1, #0
    moveq   r0, #0          // return 0 (was r4)
    movne   r0, #1          // return 1 (was r4)
    bx      lr              // return


//----------------------------------------------------------------------------
/* Returns a 16-bit number representing which SNES buttons are pressed
 * Return:
 *  r0 - button states
*/
.globl      Read_SNES
Read_SNES:
    push    { r4, r5, lr }
    // r4 = buttons
    // r5 = loop counter

    mov     r4, #0          // r4: register for sampling buttons
    mov     r1, #1
    bl      Write_Clock     // writeGPIO(Clock, #1)

    mov     r1, #1
    bl      Write_Latch     // writeGPIO(LATCH, #1)

    mov     r0, #12         // signal to SNES to sample buttons
    bl      Wait            // Wait(12 microsec)

    mov     r1, #0
    bl      Write_Latch     // writeGPIO(LATCH, #0)

    mov     r5, #0          // initialize loop counter i (r5) to 0
pulseLoop:
    mov     r0, #6
    bl      Wait            // Wait(6 microsec)

    mov     r1, #0          // writeGPIO(Clock, #0)
    bl      Write_Clock     // for falling edge

    mov     r0, #6
    bl      Wait            // Wait(6 microsec)

    bl      Read_Data       // readGPIO(Data, b)
                            // read bit i = b (into r0)

    mov     r4, r4, lsl #1  // left shift buttons register by 1
    add     r4, r0          // add the value we just read

    mov     r1, #1          // writeGPIO(CLOCK, #1)
    bl      Write_Clock     // rising edge, new cycle

    add     r5, #1          // increment loop counter i (r5) for next button

    cmp     r5, #16         // compare loop counter (r5) to 16
    blo     pulseLoop       //  branch to pulseLoop if less

    mov     r0, r4          // put the result (buttons) into r0
    pop     { r4, r5, lr }
    bx      lr              // return


//----------------------------------------------------------------------------
/* Returns the bit at a given index of a 16-bit integer
 * Args:
 *  r0 - the number
 *  r1 - index of bit to get value of
 * Return:
 *  r1 - the desired bit
*/
.globl      getBit
getBit:
    mov     r2, #1          // r2 = b(...00001)
    mov     r2, r2, lsl r1  // left shift r2 by r1
    and     r1, r0, r2      // r1: AND r0 with r2 to select only desired bit
    bx      lr              // return

