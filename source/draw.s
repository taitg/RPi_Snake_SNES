/*
SNAKE for Raspberry Pi
Geordie Tait

Contains variables and functions for video output

*/

.section .data
.align 4

.globl FrameBufferInfo
FrameBufferInfo:
    .int    1024    // 0 - Width
    .int    768     // 4 - Height
    .int    1024    // 8 - vWidth
    .int    768   	// 12 - vHeight
    .int    0       // 16 - GPU - Pitch
    .int    16      // 20 - Bit Depth
    .int    0       // 24 - X
    .int    0       // 28 - Y
    .int    0       // 32 - GPU - Pointer
    .int    0       // 36 - GPU - Size

	
.align 2
.globl FrameBufferPointer
FrameBufferPointer:
	.int	0

.align      4
font:   .incbin "font.bin"

.section .text

//----------------------------------------------------------------------------
/* Initialize the Frame Buffer (from tutorial code)
 * Return:
 *  r0 - result
 */
.globl InitFrameBuffer
InitFrameBuffer:
    push    {r4, lr}
    infoAdr .req r4
	result  .req r0

    ldr     infoAdr, =FrameBufferInfo       // get framebuffer info address
    
    mov     r0, infoAdr                     // store fb info address as mail message
	add		r0,	#0x40000000					// set bit 30; tell GPU not to cache changes
    mov     r1, #1                          // mailbox channel 1
    bl      MailboxWrite                    // write message
    
    mov     r0, #1                          // mailbox channel 1
    bl      MailboxRead                     // read message
    
    teq     result, #0
    movne   result, #0
    popne   {r4, pc}                        // return 0 if message from mailbox is 0
    
pointerWait$:
    ldr     result, [infoAdr, #32]
    teq     result, #0
    beq     pointerWait$                    // loop until the pointer is set
	
	ldr		r1,		=FrameBufferPointer
	str		result,	[r1]					// store the framebuffer pointer
    
    mov     result, infoAdr                 // set result to address of fb info struct

    .unreq  result
    .unreq  infoAdr
    pop     {r4, pc}                        // return
    
//----------------------------------------------------------------------------
/* Draws a pixel to the frame buffer (from tutorial code)
 * Args:
 *  r0 - x
 *  r1 - y
 *	r2 - color
 */
.globl DrawPixel
DrawPixel:
	push	{ r4, lr }
    px      .req    r0
    py      .req    r1
	color	.req	r2
    addr    .req    r3
    
    ldr     addr,   =FrameBufferInfo
    
    height  .req    r4
    ldr     height, [addr, #4]
    sub     height, #1
    cmp     py,     height
    bhi     DrawPixelEnd$
    .unreq  height
    
    width   .req    r4
    ldr     width,  [addr, #0]
    sub     width,  #1
    cmp     px,     width
    bhi     DrawPixelEnd$

    ldr     addr,   =FrameBufferPointer
	ldr		addr,	[addr]
	
    add     width,  #1
    
    mla     px,     py, width, px       // px = (py * width) + px

    .unreq  width
    .unreq  py
    
    add     addr,   px, lsl #1			// addr += (px * 2) (ie: 16bpp = 2 bytes per pixel)
    .unreq  px
    
    strh    color,  [addr]
    
    .unreq  addr

DrawPixelEnd$:
	pop		{ r4, pc }

//----------------------------------------------------------------------------
/* Write to mailbox (from tutorial code)
 * Args:
 *  r0 - value (4 LSB must be 0)
 *  r1 - channel
 */
.globl MailboxWrite
MailboxWrite:
    tst     r0, #0b1111                     // if lower 4 bits of r0 != 0 (must be a valid message)
    movne   pc, lr                          //  return
    
    cmp     r1, #15                         // if r1 > 15 (must be a valid channel)
    movhi   pc, lr                          //  return
    
    channel .req r1
    value   .req r2
    mov     value, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
wait1$:
    status  .req r3
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x80000000             // test bit 32
    .unreq  status
    bne     wait1$                          // loop while status bit 32 != 0
    
    add     value, channel                  // value += channel
    .unreq  channel
    
    str     value, [mailbox, #0x20]         // store message to write offset
    
    .unreq  value
    .unreq  mailbox
    
    bx		lr

//----------------------------------------------------------------------------
/* Read from mailbox (from tutorial code)
 * Args:
 *  r0 - channel
 * Return:
 *  r0 - message
 */
.globl MailboxRead
MailboxRead:
    cmp     r0, #15                         // return if invalid channel (> 15)
    movhi   pc, lr
    
    channel .req r1
    mov     channel, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
rightmail$:
wait2$:
    status  .req r2
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x4000000              // test bit 30
    .unreq  status
    bne     wait2$                          // loop while status bit 30 != 0
    
    mail    .req r2
    ldr     mail, [mailbox, #0]             // retrieve message
    
    inchan  .req r3
    and     inchan, mail, #0b1111           // mask out lower 4 bits of message into inchan
    
    teq     inchan, channel
    .unreq  inchan
    bne     rightmail$                      // if not the right channel, loop
    
    .unreq  mailbox
    .unreq  channel
    
    and     r0, mail, #0xfffffff0           // mask out channel from message, store in return (r0)
    .unreq  mail
    
	bx		lr

//----------------------------------------------------------------------------
/* Draw a character to the frame buffer (from tutorial code)
 * Args:
 *  r0 - character to write
 *  r1 - x coordinate (pixels)
 *  r2 - y coordinate (pixels)
 *  r3 - colour for the character
*/
.globl      DrawChar
DrawChar:
    push    { r4-r10, lr }
    fontAdr .req r4
    px      .req r5
    py      .req r6
    colour  .req r7
    row     .req r8
    mask    .req r9
    min_x   .req r10

    mov     min_x, r1
    mov     py, r2
    mov     colour, r3

    ldr     fontAdr, =font
    add     fontAdr, r0, lsl #4

charLoop:
    mov     px, min_x
    mov     mask, #0x01
    ldrb    row, [fontAdr], #1

rowLoop:
    tst     row, mask
    beq     noPixel

    mov     r0, px
    mov     r1, py
    mov     r2, colour
    bl      DrawPixel

noPixel:
    add     px, #1
    lsl     mask, #1
    tst     mask, #0x100
    beq     rowLoop

    add     py, #1
    tst     fontAdr, #0xF
    bne     charLoop

    .unreq  fontAdr
    .unreq  px
    .unreq  py
    .unreq  colour
    .unreq  row
    .unreq  mask
    .unreq  min_x
    pop     { r4-r10, pc }

//----------------------------------------------------------------------------
/* Draws a null-terminated string to the frame buffer
 * Args:
 *  r0 - address of the string
 *  r1 - x coordinate (pixels)
 *  r2 - y coordinate (pixels)
 *  r3 - colour to draw
*/
.globl      DrawText
DrawText:
    push    { r4-r9, lr }
    address .req r4 // r0
    px      .req r5 // r1
    py      .req r6 // r2
    colour  .req r7 // r3
    offset  .req r8
    char    .req r9

    mov     address, r0
    mov     px, r1
    mov     py, r2
    mov     colour, r3
    mov     offset, #0

textLoop:
    ldrb    char, [address, offset]
    cmp     char, #0
    beq     textDone

    mov     r0, char
    mov     r1, px
    mov     r2, py
    mov     r3, colour
    bl      DrawChar

    add     offset, #1
    add     px, #10
    bal     textLoop

textDone:
    .unreq  address
    .unreq  px
    .unreq  py
    .unreq  colour
    .unreq  offset
    .unreq  char
    pop     { r4-r9, pc }

//----------------------------------------------------------------------------
/* Draws a 32x32 sprite from memory onto the frame buffer
 * Args:
 *  r0 - address of the sprite
 *  r1 - x coordinate (pixels)
 *  r2 - y coordinate (pixels)
*/
.globl      DrawSprite32
DrawSprite32:
    push    { r4-r10, lr }
    address .req r4 // r0
    px      .req r5 // r1
    py      .req r6 // r2
    offset  .req r7
    colour  .req r8
    max_x   .req r9
    max_y   .req r10

    mov     address, r0
    mov     px, r1
    mov     py, r2
    mov     offset, #0

    add     max_x, px, #32
    add     max_y, py, #32

spriteLoop:
    ldrh    colour, [address, offset]
    add     offset, #2

    cmp     colour, #0x0
    beq     noColour

    mov     r0, px
    mov     r1, py
    mov     r2, colour
    bl      DrawPixel

noColour:
    add     px, #1
    cmp     px, max_x
    blo     spriteLoop

    sub     px, #32
    add     py, #1
    cmp     py, max_y
    blo     spriteLoop

    .unreq  address
    .unreq  px
    .unreq  py
    .unreq  offset
    .unreq  colour
    .unreq  max_x
    .unreq  max_y
    pop     { r4-r10, pc }

//----------------------------------------------------------------------------
/* Draws a 387x336 background sprite onto the frame buffer
 * Args:
 *  r0 = address of the sprite
 *  r1 = x coordinate (pixels)
 *  r2 = y coordinate (pixels)
*/
.globl      DrawBackground
DrawBackground:
    push    { r4-r10, lr }
    address .req r4 // r0
    px      .req r5
    py      .req r6
    offset  .req r7
    colour  .req r8
    max_x   .req r9
    max_y   .req r10

    mov     address, r0
    mov     px, r1
    mov     py, r2
    mov     offset, #0
    ldr     max_x, =387
    add     max_x, px
    ldr     max_y, =336
    add     max_y, py

bkgdLoop:
    ldrh    colour, [address, offset]
    add     offset, #2

    mov     r0, px
    mov     r1, py
    mov     r2, colour
    bl      DrawPixel

noBkgdPixel:
    add     px, #1
    cmp     px, max_x
    blo     bkgdLoop

    ldr     r0, =387
    sub     px, r0
    add     py, #1
    cmp     py, max_y
    blo     bkgdLoop

    .unreq  address
    .unreq  px
    .unreq  py
    .unreq  offset
    .unreq  colour
    .unreq  max_x
    .unreq  max_y
    pop     { r4-r10, pc }

//----------------------------------------------------------------------------
/* Clears the screen (1024x768) by writing black pixels to the frame buffer
*/
.globl      ClearScreen
ClearScreen:
    push    { r4-r8, lr }
    px      .req r4
    py      .req r5
    colour  .req r6
    max_x   .req r7
    max_y   .req r8

    mov     px, #0
    mov     py, #0
    ldr     max_x, =1024
    ldr     max_y, =768

clearLoop:
    ldr    colour, =0x0

    mov     r0, px
    mov     r1, py
    mov     r2, colour
    bl      DrawPixel

    add     px, #1
    cmp     px, max_x
    blo     clearLoop

    sub     px, max_x
    add     py, #1
    cmp     py, max_y
    blo     clearLoop

    .unreq  px
    .unreq  py
    .unreq  colour
    .unreq  max_x
    .unreq  max_y
    pop     { r4-r8, pc }

