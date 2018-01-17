/*
SNAKE for Raspberry Pi
Geordie Tait

Contains variables and functions for initializing and playing
a game of Snake

*/

.section    .data

// variable for delay time between frames
.globl      frameDelay
.align      4
frameDelay:
    .int    0

// delay times for speed levels 1-5
.globl      speed1
speed1:
    .int   115000

.globl      speed2
speed2:
    .int   105000

.globl      speed3
speed3:
    .int   95000

.globl      speed4
speed4:
    .int   85000

.globl      speed5
speed5:
    .int   75000

// array representing the game map:
//  32x24 grid = 768 cells
//  0 = floor
//  1 = border
//  2 = wall
.globl      gameMap
.align      4
gameMap:
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    .byte   1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

// array representing the snake:
//  maximum length = 40
//  first byte = x coordinate in game map
//  second = y coordinate
//  third = direction of the snake segment
//  fourth = direction of previous segment
.globl      snakeArray
.align      4
snakeArray:
    .rept   40
    .byte   0, 0, 0, 0
    .endr

// the current length of the snake
.globl      snakeLength
snakeLength:
    .byte   3

// the current direction of the snake
//  0 = up      1 = right
//  2 = down    3 = left
.globl      snakeDir
snakeDir:
    .byte   1

// flag which is set when the snake hits a wall/border
.globl      snakeHit
snakeHit:
    .byte   0

// flag which is set when the length should be incremented
.globl      snakeInc
snakeInc:
    .byte   0

// the current speed level (0-4)
.globl      snakeSpeed
snakeSpeed:
    .byte   0

// the number of apples the snake has eaten
.globl      appleCount
appleCount:
    .byte   0

// (x, y) coordinates of apple, exit, life pack, speed pack
.globl      appleLoc
appleLoc:
    .byte   0, 0

.globl      exitLoc
exitLoc:
    .byte   0, 0

.globl      lifeLoc
lifeLoc:
    .byte   0, 0

.globl      speedLoc
speedLoc:
    .byte   0, 0

// flag which is set when a value pack should be generated:
//  set by timer interrupt
.globl      packTime
packTime:
    .byte   0

// flag which is set when the score/lives have been updated
.globl      updateValues
updateValues:
    .byte   1

// flag which is set when input has been given for that frame
.globl      gotInput
gotInput:
    .byte   0

// flag which is set when the user has selected "hard" mode
.globl      gameMode
gameMode:
    .byte   0

// the current number of lives the player has
.globl      playerLives
playerLives:
    .byte   3

// the current player score
.globl      playerScore
playerScore:
    .byte   0

// flag which is set when the player has won the game
.globl      winCond
winCond:
    .byte   0

// flag which is set when the player has lost the game
.globl      lossCond
lossCond:
    .byte   0

// strings for displaying score and lives
scoreStr:
    .asciz  "Score: "

livesStr:
    .asciz  "Lives: "

.section    .text

//----------------------------------------------------------------------------
/* Initializes the game then starts the game
*/
.globl      InitGame
InitGame:
    push    { r4-r5, lr }
    address .req r4
    value   .req r5

    // display difficulty menu and get input
    bl      DifficultyMenu
    cmp     r0, #0
    bne     hardMode

    mov     value, #0       // set normal mode
    bal     diffReady

hardMode:
    mov     value, #1       // set hard mode

diffReady:
    ldr     address, =gameMode  // store the game mode
    strb    value, [address]

    // reset values in case previous game
    bl      ResetValues

    bl      InitRandom      // initialize random number generator
    bl      InitWalls       // initialize walls

    // start the clock at 30 seconds
    mov     r0, #0
    bl      StartClock

    bl      PlayGame        // start the game

    .unreq  address
    .unreq  value
    pop     { r4-r5, pc }   // return

//----------------------------------------------------------------------------
/* The main game function containing the game loop
*/
.globl      PlayGame
PlayGame:
    push    { r4-r10, lr }
    win     .req r4
    lose    .req r5
    hit     .req r6
    address .req r7
    value   .req r8
    delay   .req r9
    packs   .req r10

beginGame:
    bl      InitTiles       // draw the border, walls, and floor
    bl      InitSnake       // initialize the snake

    // make new apple
    mov     r0, #0
    bl      NewObject

    // set update values flag
    mov     value, #1
    ldr     address, =updateValues
    strb    value, [address]

// begin game loop
gameLoop:
    bl      SetSpeed        // set the game speed (delay) and snake colour
    bl      UpdateSnake     // advance the snake and check collisions
    bl      DisplaySnake    // draw the snake
    bl      DisplayObjects  // draw objects (apple, exit, life, speed pack)
    bl      DisplayValues   // draw the score and remaining lives

    // check win condition
    ldr     win, =winCond
    ldrb    win, [win]
    cmp     win, #1
    beq     gameOverWin     // player wins

    // check loss condition
    ldr     lose, =lossCond
    ldrb    lose, [lose]
    cmp     lose, #1
    beq     gameOverLose    // player loses

    // check if snake hit a wall
    ldr     hit, =snakeHit
    ldrb    hit, [hit]
    cmp     hit, #0
    bne     resetGame       // reset the game

    // create speed pack if flag is set
    ldr     packs, =packTime
    ldrb    packs, [packs]
    cmp     packs, #0
    beq     noPacks

    // make new speed pack if none exists
    ldr     value, =speedLoc
    ldrb    value, [value]
    cmp     value, #0
    bne     packExists
    ldr     value, =speedLoc
    ldrb    value, [value, #1]
    cmp     value, #0
    bne     packExists

    mov     r0, #3
    bl      NewObject       // make the speed pack

packExists:
    // reset value pack flag
    ldr     address, =packTime
    mov     value, #0
    strb    value, [address]

    // restart clock at 10 seconds
    mov     r0, #1
    bl      StartClock

noPacks:
    // reset input flag
    mov     value, #0
    ldr     address, =gotInput
    strb    value, [address]

    // get SNES controller input:
    //  this occurs multiple times per frame to
    //  increase responsiveness
    bl      GetInput

    // load delay value
    ldr     delay, =frameDelay
    ldr     delay, [delay]          // divide delay value by 2
    mov     delay, delay, asr #1    // (will occur twice)

    // reduce delay if hard mode
    ldr     value, =gameMode
    ldrb    value, [value]
    cmp     value, #0
    beq     easyDelay

    mov     r0, delay               // one additional normal wait in hard mode
    bl      Wait                    // (hard mode delay = 75% of normal)
    mov     delay, delay, asr #1    // divide delay by 2 if hard mode
    bal     delayReady

easyDelay:
    mov     r0, delay
    bl      Wait            // wait

delayReady:
    bl      GetInput        // get input again

    mov     r0, delay
    bl      Wait            // wait again

    bl      GetInput        // get input again

    bal     gameLoop        // restart game loop

resetGame:
    // reset snake collision flag
    ldr     address, =snakeHit
    mov     hit, #0
    strb    hit, [address]
    
    bal     beginGame       // start the game over

gameOverWin:
    mov     r0, #0
    bal gameOver            // end the game (win)

gameOverLose:
    mov     r0, #1
    bal gameOver            // end the game (loss)

gameOver:
    bl      EndPrompt       // show the appropriate game over message

    bl      MainMenu        // go back to the main menu
    cmp     r0, #1
    beq     endGame

    bl      ClearScreen
    bl      InitGame        // start new game

endGame:
    bl      ClearScreen     // clear screen and quit the game
    .unreq  win
    .unreq  lose
    .unreq  hit
    .unreq  address
    .unreq  value
    .unreq  delay
    .unreq  packs
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Draws tiles (border, wall, floor) based on the current game map
*/
.globl      InitTiles
InitTiles:
    push    { r4-r8, lr }
    tx      .req r4
    ty      .req r5
    offset  .req r6
    mapAdr  .req r7
    tile    .req r8

    mov     tx, #0
    mov     ty, #0
    mov     offset, #0
    ldr     mapAdr, =gameMap

// loop through game map and draw corresponding tile sprites
tileLoop:
    ldrb    tile, [mapAdr, offset]

    cmp     tile, #1
    beq     tileBorder
    cmp     tile, #2
    beq     tileWall

    ldr     r0, =sprFloor       // select floor sprite
    bal     tileDone

tileBorder:
    ldr     r0, =sprBorder      // select border sprite
    bal     tileDone

tileWall:
    ldr     r0, =sprFloor       // draw floor beneath walls
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32
    ldr     r0, =sprWall        // select wall sprite

tileDone:
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32        // draw the selected sprite

    add     offset, #1
    add     tx, #1
    cmp     tx, #32
    blo     tileLoop            // loop back for next sprite

    sub     tx, #32
    add     ty, #1
    cmp     ty, #24
    blo     tileLoop            // loop back for next sprite

    .unreq  tx
    .unreq  ty
    .unreq  offset
    .unreq  mapAdr
    .unreq  tile
    pop     { r4-r8, pc }       // return

//----------------------------------------------------------------------------
/* Creates a random set of walls within the game map
 *  Normal = 20 walls
 *  Hard = 40 walls
*/
.globl      InitWalls
InitWalls:
    push    { r4-r10, lr }
    tx      .req r4
    ty      .req r5
    width   .req r6
    address .req r7
    counter .req r8
    offset  .req r9
    max     .req r10

    mov     width, #32
    mov     counter, #0

// determine number of walls (max) from difficulty setting
    ldr     max, =gameMode
    ldrb    max, [max]
    cmp     max, #0
    bne     hardWalls

    mov     max, #20
    bal     wallsReady

hardWalls:
    mov     max, #40

wallsReady:
    ldr     address, =gameMap

// clear old walls in case previous game
    mov     tx, #1
    mov     ty, #1
    mov     r0, #0
wallClear:
    mla     offset, ty, width, tx
    strb    r0, [address, offset]

    add     tx, #1
    cmp     tx, #31
    blo     wallClear

    mov     tx, #1
    add     ty, #1
    cmp     ty, #23
    blo     wallClear

wallLoop:
    // get random coordinates
    mov     r0, #22
    bl      GetRandom
    add     r0, #1
    mov     ty, r0

    // check if y = 11 (no walls in starting "lane")
    cmp     ty, #11
    beq     wallLoop

    mov     r0, #30
    bl      GetRandom
    add     r0, #1
    mov     tx, r0

    // check if already a wall there
    mla     offset, ty, width, tx
    ldrb    r0, [address, offset]
    cmp     r0, #0
    bne     wallLoop

    // create wall
    mov     r0, #2
    strb    r0, [address, offset]
    add     counter, #1
    cmp     counter, max
    ble     wallLoop

    .unreq  tx
    .unreq  ty
    .unreq  width
    .unreq  address
    .unreq  counter
    .unreq  offset
    .unreq  max
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Initializes the snake array
*/
.globl      InitSnake
InitSnake:
    push    { r4-r10, lr }
    address .req r4
    tx      .req r5
    ty      .req r6
    dir     .req r7
    offset  .req r8
    length  .req r9
    counter .req r10

    // clear the snake array
    ldr     address, =snakeArray
    ldr     offset, =159
    mov     r0, #0

clearSnake:
    strb    r0, [address, offset]
    sub     offset, #1
    cmp     offset, #0
    bge     clearSnake

    // make the new snake
    mov     tx, #20
    mov     ty, #11
    mov     dir, #1
    mov     offset, #0
    mov     counter, #0
    ldr     length, =snakeLength
    ldrb    length, [length]

initSnakeLoop:
    strb    tx, [address, offset]
    add     offset, #1
    strb    ty, [address, offset]
    add     offset, #1
    strb    dir, [address, offset]
    add     offset, #1
    strb    dir, [address, offset]
    add     offset, #1

    add     counter, #1
    sub     tx, #1

    cmp     tx, #0
    beq     snakeCutoff

    cmp     counter, length
    ble     initSnakeLoop

    bal     initSnakeDone

// cut off the snake if it doesn't fit in starting "lane" (y = 11)
snakeCutoff:
    ldr     address, =snakeLength
    sub     counter, #1
    strb    counter, [address]

initSnakeDone:
    // set snake direction to right
    ldr     address, =snakeDir
    strb    dir, [address]

    .unreq  address
    .unreq  tx
    .unreq  ty
    .unreq  dir
    .unreq  length
    .unreq  counter
    .unreq  offset
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Draws the snake segments from the snake array
*/
.globl      DisplaySnake
DisplaySnake:
    push    { r4-r10, lr }
    address .req r4
    tx      .req r5
    ty      .req r6
    max     .req r7
    counter .req r8
    dir     .req r9
    prev    .req r10

    ldr     address, =snakeArray
    ldr     max, =snakeLength
    ldrb    max, [max]
    sub     max, #1
    mov     counter, #0

// loop through snake array and draw corresponding segment
snakeLoop:
    ldrb    tx, [address], #1
    ldrb    ty, [address], #1
    ldrb    dir, [address], #1
    ldrb    prev, [address], #1

    // redraw floor beneath head and tail
    cmp     counter, max
    beq     redraw

    cmp     counter, #1
    beq     redraw

    // don't redraw floor beneath if just hit a wall
    ldr     r0, =snakeHit
    ldrb    r0, [r0]
    cmp     r0, #0
    bne     noRedraw

    cmp     counter, #0
    beq     redraw

    bal     noRedraw

redraw:
    cmp     tx, #0
    beq     noRedraw
    cmp     ty, #0
    beq     noRedraw

    ldr     r0, =sprFloor
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32        // draw floor tile sprite

// draw the appropriate snake segment
noRedraw:
    cmp     counter, #0
    beq     snakeHead
    cmp     counter, max
    beq     snakeTail

    // body
    cmp     dir, prev
    beq     noTurn

    // body with turn
    cmp     dir, #0
    beq     turnU
    cmp     dir, #1
    beq     turnR
    cmp     dir, #2
    beq     turnD
    bal     turnL

turnU:
    cmp     prev, #1
    beq     turn3
    bal     turn4
turnR:
    cmp     prev, #0
    beq     turn1
    bal     turn4
turnD:
    cmp     prev, #1
    beq     turn2
    bal     turn1
turnL:
    cmp     prev, #0
    beq     turn2
    bal     turn3

turn1:
    ldr     r0, =sprBodyT1
    bal     snakeReady
turn2:
    ldr     r0, =sprBodyT2
    bal     snakeReady
turn3:
    ldr     r0, =sprBodyT3
    bal     snakeReady
turn4:
    ldr     r0, =sprBodyT4
    bal     snakeReady

// body with no turn
noTurn:
    cmp     dir, #0
    beq     bodyV
    cmp     dir, #2
    beq     bodyV

    ldr     r0, =sprBodyH
    bal     snakeReady

bodyV:
    ldr     r0, =sprBodyV
    bal     snakeReady   

// head
snakeHead:
    cmp     dir, #0
    beq     headU
    cmp     dir, #1
    beq     headR
    cmp     dir, #2
    beq     headD
    bal     headL

headU:
    ldr     r0, =sprHeadU
    bal     snakeReady
headR:
    ldr     r0, =sprHeadR
    bal     snakeReady
headD:
    ldr     r0, =sprHeadD
    bal     snakeReady
headL:
    ldr     r0, =sprHeadL
    bal     snakeReady

// tail
snakeTail:
    cmp     dir, #0
    beq     tailU
    cmp     dir, #1
    beq     tailR
    cmp     dir, #2
    beq     tailD
    bal     tailL

tailU:
    ldr     r0, =sprTailU
    bal     snakeReady
tailR:
    ldr     r0, =sprTailR
    bal     snakeReady
tailD:
    ldr     r0, =sprTailD
    bal     snakeReady
tailL:
    ldr     r0, =sprTailL

snakeReady:
// draw the snake if not 0,0
    cmp     tx, #0
    beq     noDrawSnake
    cmp     ty, #0
    beq     noDrawSnake

    ldr     r0, [r0]
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32        // draw the appropriate segment

noDrawSnake:
    add     counter, #1
    cmp     counter, max
    ble     snakeLoop           // loop back until counter = snake length

    .unreq  address
    .unreq  tx
    .unreq  ty
    .unreq  max
    .unreq  counter
    .unreq  dir
    .unreq  prev
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Updates the snake array for the next frame and handles collisions
*/
.globl      UpdateSnake
UpdateSnake:
    push    { r4-r10, lr }
    address .req r4
    offset  .req r5
    tx      .req r6
    ty      .req r7
    dir     .req r8
    prev    .req r9

    // clear old tail by drawing floor over it
    ldr     address, =snakeArray
    ldr     offset, =snakeLength
    ldrb    offset, [offset]
    sub     offset, #1

    ldrb    tx, [address, offset, lsl #2]
    add     address, #1
    ldrb    ty, [address, offset, lsl #2]

    cmp     tx, #0
    beq     beginShift
    cmp     ty, #0
    beq     beginShift

    ldr     r0, =sprFloor
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32

// shift entire snake array up by 1
beginShift:
    ldr     address, =snakeArray
    ldr     offset, =snakeLength
    ldrb    offset, [offset]
    sub     offset, #1
    mov     offset, offset, lsl #2
    sub     offset, #1

shiftLoop:
    ldrb    prev, [address, offset]
    sub     offset, #1
    ldrb    dir, [address, offset]
    sub     offset, #1
    ldrb    ty, [address, offset]
    sub     offset, #1
    ldrb    tx, [address, offset]

    add     offset, #7
    strb    prev, [address,offset]
    sub     offset, #1
    strb    dir, [address,offset]
    sub     offset, #1
    strb    ty, [address,offset]
    sub     offset, #1
    strb    tx, [address,offset]
    sub     offset, #5

    cmp     offset, #0
    bgt     shiftLoop

    add     offset, #7
    ldr     dir, =snakeDir
    ldrb    dir, [dir]
    strb    dir, [address, offset]

// add new head
    mov     prev, dir
    ldr     dir, =snakeDir
    ldrb    dir, [dir]

    cmp     dir, #0
    beq     newU
    cmp     dir, #1
    beq     newR
    cmp     dir, #2
    beq     newD
    bal     newL

newU:
    sub     ty, #1
    bal     newHead
newR:
    add     tx, #1
    bal     newHead
newD:
    add     ty, #1
    bal     newHead
newL:
    sub     tx, #1

newHead:
    strb    tx, [address], #1
    strb    ty, [address], #1
    strb    dir, [address], #1
    strb    prev, [address]

    .unreq  dir
    .unreq  prev
    objx    .req r8
    objy    .req r9
    incaddr .req r10

// check if snake should grow once more (ate apple previously)
    ldr     incaddr, =snakeInc
    ldrb    r0, [incaddr]
    cmp     r0, #0
    beq     noInc

    bl      AddLength       // increase length

    mov     r0, #0
    strb    r0, [incaddr]    

// begin checking for collisions
noInc:
    .unreq  incaddr
    width   .req r10

// check for apple collision
    mov     r0, #2
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noAppleHit
    
// make new apple
    mov     r0, #0
    bl      NewObject

// increase length
    bl      AddLength

    ldr     address, =snakeInc
    mov     r0, #1
    strb    r0, [address]

// update score
    mov     r0, #1
    bl      UpdateScore

// update apple count
    ldr     address, =appleCount
    ldrb    r0, [address]
    add     r0, #1
    strb    r0, [address]

// make new exit if apples >= 20 and doesn't exist
    cmp     r0, #20
    blo     noAppleHit

    ldr     address, =exitLoc
    ldrb    r0, [address]
    cmp     r0, #0
    bne     noAppleHit

    ldrb    r0, [address, #1]
    cmp     r0, #0
    bne     noAppleHit

    mov     r0, #1
    bl      NewObject       // make exit

noAppleHit:
// check for wall/border collision
    mov     r0, #0
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noWallHit

    mov     r0, #0
    bl      UpdateLives     // lives -= 1

noWallHit:
// check for snake collision
    mov     r0, #1
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noSnakeHit

    mov     r0, #0
    bl      UpdateLives     // lives -= 1

noSnakeHit:
// check for exit collision
    mov     r0, #3
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noExitHit

    mov     r0, #1
    ldr     address, =winCond
    strb    r0, [address]   // set win condition

noExitHit:
// check for life pack collision
    mov     r0, #4
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noLifeHit

    mov     r0, #1
    bl      UpdateLives     // lives += 1

noLifeHit:
// check for speed pack collision
    mov     r0, #5
    mov     r1, tx
    mov     r2, ty
    bl      CheckTile
    cmp     r0, #0
    beq     noSpeedHit

    bl      UpdateSpeed     // speed += 1

noSpeedHit:
    .unreq  width
    .unreq  objx
    .unreq  objy
    .unreq  offset
    .unreq  address
    .unreq  tx
    .unreq  ty
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Increases the length of the snake by 1 and sets the snakeInc flag
 *  so it grows again in the next frame (length += 2)
*/
.globl      AddLength
AddLength:
    push    { r4-r6, lr }
    address .req r4
    length  .req r5
    value   .req r6

    ldr     address, =snakeLength
    ldrb    length, [address]

// grow if < maximum length
    cmp     length, #38
    bge     lengthDone

    add     length, #1
    strb    length, [address]

// clear snake array above length
    ldr     address, =snakeArray
    add     address, length, lsl #2
    sub     address, #4
    mov     value, #0
    strb    value, [address], #1
    strb    value, [address], #1
    strb    value, [address], #1
    strb    value, [address]

lengthDone:
    .unreq  address
    .unreq  length
    .unreq  value
    pop     { r4-r6, pc }   // return

//----------------------------------------------------------------------------
/* Increases speed (up to max level 5) when snake eats a speed pack
 *  Updates score and resets speed pack
*/
.globl      UpdateSpeed
UpdateSpeed:
    push    { r4-r6, lr }
    address .req r4
    speed   .req r5
    value   .req r6

    // increment speed if < 4
    ldr     address, =snakeSpeed
    ldrb    speed, [address]

    cmp     speed, #4
    bge     speedUpdated

    add     speed, #1
    strb    speed, [address]

speedUpdated:
    // increase score by 10 (bytes = 1)
    mov     r0, #1
    bl      UpdateScore

    // reset speed pack
    mov     value, #0
    ldr     address, =speedLoc
    strb    value, [address], #1
    strb    value, [address]

    .unreq  address
    .unreq  speed
    .unreq  value
    pop     { r4-r6, pc }   // return

//----------------------------------------------------------------------------
/* Sets the frame delay and snake colour to match current speed level
*/
.globl      SetSpeed
SetSpeed:
    push    { r4-r5, lr }
    address .req r4
    speed   .req r5

    ldr     address, =frameDelay
    ldr     speed, =snakeSpeed
    ldrb    speed, [speed]

    cmp     speed, #1
    beq     speedLevel2
    cmp     speed, #2
    beq     speedLevel3
    cmp     speed, #3
    beq     speedLevel4
    cmp     speed, #4
    beq     speedLevel5

    mov     r0, #0          // speed level = 1
    ldr     speed, =speed1
    bal     speedReady

speedLevel2:
    mov     r0, #1          // speed level = 2
    ldr     speed, =speed2
    bal     speedReady

speedLevel3:
    mov     r0, #2          // speed level = 3
    ldr     speed, =speed3
    bal     speedReady

speedLevel4:
    mov     r0, #3          // speed level = 4
    ldr     speed, =speed4
    bal     speedReady

speedLevel5:
    mov     r0, #4          // speed level = 5
    ldr     speed, =speed5

speedReady:
    bl      SetSnakeColour  // set the right snake appearance
    ldr     speed, [speed]  // store the new speed
    str     speed, [address]

    .unreq  address
    .unreq  speed
    pop     { r4-r5, pc }   // return

//----------------------------------------------------------------------------
/* Checks if a given (x,y) contains something
 * Args:
 *  r0 - type of thing to check for
 *       0 = wall       1 = snake
 *       2 = apple      3 = exit
 *       4 = life pack  5 = speed pack
 *  r1 - x coordinate (in game map)
 *  r2 - y coordinate (in game map)
 * Return:
 *  r0 - 1 if contains, else 0
*/
.globl      CheckTile
CheckTile:
    push    { r4-r10, lr }
    tx      .req r4
    ty      .req r5
    objx    .req r6
    objy    .req r7
    address .req r8
    offset  .req r9
    width   .req r10

    mov     tx, r1
    mov     ty, r2

    // check type and branch appropriately
    cmp     r0, #0
    beq     wallTile
    cmp     r0, #1
    beq     snakeTile
    cmp     r0, #2
    beq     appleTile
    cmp     r0, #3
    beq     exitTile
    cmp     r0, #4
    beq     lifeTile
    cmp     r0, #5
    beq     speedTile

    bal     checkDone

// check for wall
wallTile:
    ldr     address, =gameMap
    mov     width, #32
    mla     offset, ty, width, tx
    ldrb    r0, [address, offset]

    cmp     r0, #2
    beq     wallExists
    cmp     tx, #0
    beq     wallExists
    cmp     tx, #31
    beq     wallExists
    cmp     ty, #0
    beq     wallExists
    cmp     ty, #23
    beq     wallExists
    bal     noWallExists

wallExists:         // there is a wall
    mov     r0, #1
    bal     checkDone

noWallExists:       // there isn't a wall
    mov     r0, #0
    bal     checkDone

// check for snake
snakeTile:
    ldr     address, =snakeArray
    ldr     offset, =snakeLength
    ldrb    offset, [offset]
    sub     offset, #1
    mov     offset, offset, lsl #2
    sub     offset, #3

snakeTileLoop:      // loop through snake array
    ldrb    objy, [address, offset]
    sub     offset, #1
    ldrb    objx, [address, offset]
    sub     offset, #3

    cmp     objx, tx
    beq     xTile
    bal     noSnakeTile

xTile:              // x coordinate matches
    cmp     objy, ty
    bne     noSnakeTile

    mov     r0, #1  // there is a snake there
    bal     checkDone

noSnakeTile:
    mov     r0, #0  // there isn't a snake there
    cmp     offset, #4
    bgt     snakeTileLoop
    bal     checkDone

// check for apple
appleTile:
    ldr     objx, =appleLoc
    ldrb    objx, [objx]
    ldr     objy, =appleLoc
    ldrb    objy, [objy, #1]

    cmp     tx, objx
    bne     noAppleTile
    cmp     ty, objy
    bne     noAppleTile

    mov     r0, #1      // there is an apple there
    bal     checkDone

noAppleTile:
    mov     r0, #0      // there isn't an apple there
    bal     checkDone

// check for exit
exitTile:
    ldr     objx, =exitLoc
    ldrb    objx, [objx]
    ldr     objy, =exitLoc
    ldrb    objy, [objy, #1]

    cmp     tx, objx
    bne     noExitTile
    cmp     ty, objy
    bne     noExitTile

    mov     r0, #1      // there is an exit there
    bal     checkDone

noExitTile:
    mov     r0, #0      // there isn't an exit there
    bal     checkDone

// check for life pack
lifeTile:
    ldr     objx, =lifeLoc
    ldrb    objx, [objx]
    ldr     objy, =lifeLoc
    ldrb    objy, [objy, #1]

    cmp     tx, objx
    bne     noLifeTile
    cmp     ty, objy
    bne     noLifeTile

    mov     r0, #1      // there is a life pack there
    bal     checkDone

noLifeTile:
    mov     r0, #0      // there isn't a life pack there
    bal     checkDone

// check for speed pack
speedTile:
    ldr     objx, =speedLoc
    ldrb    objx, [objx]
    ldr     objy, =speedLoc
    ldrb    objy, [objy, #1]

    cmp     tx, objx
    bne     noSpeedTile
    cmp     ty, objy
    bne     noSpeedTile

    mov     r0, #1      // there is a speed pack there
    bal     checkDone

noSpeedTile:
    mov     r0, #0      // there isn't a speed pack there

checkDone:
    .unreq  tx
    .unreq  ty
    .unreq  objx
    .unreq  objy
    .unreq  address
    .unreq  offset
    .unreq  width
    pop     { r4-r10, pc }  // return

//----------------------------------------------------------------------------
/* Makes a new object of the specified type in a random empty location
 *  that is not directly adjacent to any walls
 * Args:
 *  r0 - type of object to create
 *       0 = apple      1 = exit
 *       2 = life pack  3 = speed pack
*/
.globl      NewObject
NewObject:
    push    { r4-r9, lr }
    address .req r4
    tx      .req r5
    ty      .req r6
    width   .req r7
    type    .req r8
    offset  .req r9

    mov     width, #32
    mov     type, r0

coordLoop:
    // get random coordinates, try again if not empty
    mov     r0, #30
    bl      GetRandom
    add     r0, #1
    mov     tx, r0

    mov     r0, #22
    bl      GetRandom
    add     r0, #1
    mov     ty, r0

    mov     r1, tx
    mov     r2, ty

    // check for walls
    mov     r0, #0
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check if next to a wall
    //  (don't put objects there in case they are surrounded)
    sub     r1, #1
    mov     r0, #0
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    add     r1, #2
    mov     r0, #0
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    sub     r1, #1
    sub     r2, #1
    mov     r0, #0
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    add     r2, #2
    mov     r0, #0
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop
    sub     r2, #1

    // check for snake
    mov     r0, #1
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check for apple
    mov     r0, #2
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check for exit
    mov     r0, #3
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check for life pack
    mov     r0, #4
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check for speed pack
    mov     r0, #5
    bl      CheckTile
    cmp     r0, #0
    bne     coordLoop

    // check type and branch to appropriate label
    cmp     type, #0
    beq     newApple
    cmp     type, #1
    beq     newExit
    cmp     type, #2
    beq     newLifePack
    cmp     type, #3
    beq     newSpeedPack

    bal     newDone

// make a new apple
newApple:
    ldr     address, =appleLoc
    bal     makeNew

// make a new exit
newExit:
    ldr     address, =exitLoc
    bal     makeNew

// make a new life pack
newLifePack:
    ldr     address, =lifeLoc
    bal     makeNew

// make a new speed pack
newSpeedPack:
    ldr     address, =speedLoc

// make the new object of specified type
makeNew:
    strb    tx, [address]
    add     address, #1
    strb    ty, [address]

newDone:
    .unreq  address
    .unreq  tx
    .unreq  ty
    .unreq  width
    .unreq  type
    .unreq  offset
    pop     { r4-r9, pc }   // return

//----------------------------------------------------------------------------
/* Draws the objects that currently exist at the appropriate locations
*/
.globl      DisplayObjects
DisplayObjects:
    push    { r4-r6, lr }
    address .req r4
    tx      .req r5
    ty      .req r6

    // display apple if it exists
    ldr     tx, =appleLoc
    ldrb    tx, [tx]

    ldr     ty, =appleLoc
    add     ty, #1
    ldrb    ty, [ty]

    cmp     tx, #0
    beq     noApple
    cmp     ty, #0
    beq     noApple

    ldr     r0, =sprApple
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32

noApple:
    // display exit if it exists
    ldr     tx, =exitLoc
    ldrb    tx, [tx]

    ldr     ty, =exitLoc
    add     ty, #1
    ldrb    ty, [ty]

    cmp     tx, #0
    beq     noExit
    cmp     ty, #0
    beq     noExit

    ldr     r0, =sprExit
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32

noExit:
    // display life pack if it exists
    ldr     tx, =lifeLoc
    ldrb    tx, [tx]

    ldr     ty, =lifeLoc
    add     ty, #1
    ldrb    ty, [ty]

    cmp     tx, #0
    beq     noLifePack
    cmp     ty, #0
    beq     noLifePack

    ldr     r0, =sprLife
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32

noLifePack:
    // display speed pack if it exists
    ldr     tx, =speedLoc
    ldrb    tx, [tx]

    ldr     ty, =speedLoc
    add     ty, #1
    ldrb    ty, [ty]

    cmp     tx, #0
    beq     noSpeedPack
    cmp     ty, #0
    beq     noSpeedPack

    ldr     r0, =sprSpeed
    mov     r1, tx, lsl #5
    mov     r2, ty, lsl #5
    bl      DrawSprite32

noSpeedPack:
    .unreq  address
    .unreq  tx
    .unreq  ty
    pop     { r4-r6, pc }   // return

//----------------------------------------------------------------------------
/* Increase or decrease #lives and handle the results
 * Args:
 *  r0 - lose 1 life if 0, else add 1 life
*/
.globl      UpdateLives
UpdateLives:
    push    { r4-r6, lr }
    address .req r4
    lives   .req r5
    value   .req r6

    // check if gaining or losing life and branch
    cmp     r0, #0
    bgt     gainLife

    // losing a life
    ldr     address, =snakeHit
    mov     r0, #1          // set collision flag
    strb    r0, [address]

    // decrement player lives
    ldr     address, =playerLives
    ldrb    lives, [address]
    sub     lives, #1
    strb    lives, [address]

    // check if lives = 0 and branch
    cmp     lives, #0
    beq     noLives
    bal     ulDone

noLives:
    // set loss condition flag
    ldr     address, =lossCond
    mov     r0, #1
    strb    r0, [address]
    bal     ulDone

gainLife:
    // add 1 life
    ldr     address, =playerLives
    ldrb    lives, [address]
    add     lives, #1
    strb    lives, [address]

    // increase score by 10 (bytes = 1)
    mov     r0, #1
    bl      UpdateScore

    // reset life pack
    mov     value, #0
    ldr     address, =lifeLoc
    strb    value, [address], #1
    strb    value, [address]

ulDone:
    // set update values flag
    ldr     address, =updateValues
    mov     r0, #1
    strb    r0, [address]

    .unreq  address
    .unreq  lives
    .unreq  value
    pop     { r4-r6, pc }   // return

//----------------------------------------------------------------------------
/* Increase the player score and create life pack at 100, 200, 300, etc.
 *  (score var is multiplied by 10 before being drawn on the screen)
 * Args:
 *  r0 - amount to increase score
*/
.globl      UpdateScore
UpdateScore:
    push    { r4-r5, lr }
    address .req r4
    score   .req r5

    // add r0 to score
    ldr     address, =playerScore
    ldrb    score, [address]
    add     score, r0
    strb    score, [address]

    // set update flag
    ldr     address, =updateValues
    mov     r0, #1
    strb    r0, [address]

    // create life pack if score is multiple of 100 (bytes = 10)
    cmp     score, #0
    beq     noNewPack

    mov     r0, score
    mov     r1, #10
    bl      divide

    cmp     r1, #0
    bne     noNewPack

    mov     r0, #2
    bl      NewObject   // make the new life pack

noNewPack:
    .unreq  address
    .unreq  score
    pop     { r4-r5, pc }   // return

//----------------------------------------------------------------------------
/* Draw the current score and #lives to the screen
 *  only if updateValues flag is set
*/
.globl      DisplayValues
DisplayValues:
    push    { r4-r7, lr }
    address .req r4
    counter .req r5
    ty      .req r6
    update  .req r7

    // check if values have been updated
    ldr     address, =updateValues
    ldrb    update, [address]
    cmp     update, #0
    beq     dvDone

    // reset update flag
    mov     update, #0
    strb    update, [address]

    // redraw border underneath
    ldr     address, =sprBorderCut
    mov     counter, #0
    mov     ty, #0
resetLoop:
    mov     r0, address
    mov     r1, counter, lsl #5
    mov     r2, ty
    bl      DrawSprite32
    add     counter, #1

    cmp     counter, #7     // need 7 border tiles to cover
    blo     resetLoop

    mov     ty, #9          // y coordinate for drawing strings

    // print strings
    ldr     r0, =scoreStr
    mov     r1, #10
    mov     r2, ty
    ldr     r3, =0xFFFF
    bl      DrawText        // score text

    ldr     r0, =buffer
    ldr     r1, =playerScore
    ldrb    r1, [r1]
    mov     r2, r1
    mov     r1, r1, lsl #2  // multiply score bytes by 10
    add     r1, r2
    mov     r1, r1, lsl #1
    bl      itoa            // convert score to ASCII

    ldr     r0, =buffer
    mov     r1, #80
    mov     r2, ty
    ldr     r3, =0xFFFF
    bl      DrawText        // player score
    bl      ClearBuffer     // clear the buffer

    ldr     r0, =livesStr
    mov     r1, #130
    mov     r2, ty
    ldr     r3, =0xFFFF
    bl      DrawText        // lives text

    ldr     r0, =buffer
    ldr     r1, =playerLives
    ldrb    r1, [r1]
    bl      itoa            // convert 

    ldr     r0, =buffer
    mov     r1, #200
    mov     r2, ty
    ldr     r3, =0xFFFF
    bl      DrawText        // player lives
    bl      ClearBuffer     // clear the buffer

dvDone:
    .unreq  address
    .unreq  counter
    .unreq  ty
    .unreq  update
    pop     { r4-r7, pc }   // return

//----------------------------------------------------------------------------
/* Resets variables to their initial values
*/
.globl      ResetValues
ResetValues:
    push    { r4-r5, lr }
    address .req r4
    value   .req r5

    mov     value, #3
    ldr     address, =playerLives   // reset lives
    strb    value, [address]
    ldr     address, =snakeLength   // reset length
    strb    value, [address]
    mov     value, #0
    ldr     address, =winCond       // reset win and loss flags
    strb    value, [address]
    ldr     address, =lossCond
    strb    value, [address]
    ldr     address, =packTime      // reset speed pack flag
    strb    value, [address]
    ldr     address, =playerScore   // reset score
    strb    value, [address]
    ldr     address, =snakeInc      // reset snake inc flag
    strb    value, [address]
    ldr     address, =snakeSpeed    // reset snake speed
    strb    value, [address]
    ldr     address, =appleCount    // reset apple count
    strb    value, [address]
    ldr     address, =appleLoc      // reset object locations
    strb    value, [address], #1
    strb    value, [address]
    ldr     address, =lifeLoc
    strb    value, [address], #1
    strb    value, [address]
    ldr     address, =speedLoc
    strb    value, [address], #1
    strb    value, [address]
    ldr     address, =exitLoc
    strb    value, [address], #1
    strb    value, [address]

    .unreq  address
    .unreq  value
    pop     { r4-r5, pc }   // return

//----------------------------------------------------------------------------
/* Read button states from SNES controller and perform appropriate action
*/
.globl      GetInput
GetInput:
    push    { r4-r7, lr }
    dir     .req r4
    newdir  .req r5
    addr    .req r6
    val     .req r7

    bl      Read_SNES       // read button states
    ldr     dir, =snakeDir
    ldrb    dir, [dir]      // get current direction

    mov     r1, #12
    bl      getBit
    cmp     r1, #0
    beq     stPressed       // START pressed

    mov     r1, #8
    bl      getBit
    cmp     r1, #0
    beq     rPressed        // RIGHT pressed

    mov     r1, #9
    bl      getBit
    cmp     r1, #0
    beq     lPressed        // LEFT pressed

    mov     r1, #10
    bl      getBit
    cmp     r1, #0
    beq     dPressed        // DOWN pressed

    mov     r1, #11
    bl      getBit
    cmp     r1, #0
    beq     uPressed        // UP pressed

    bal     inputDone

stPressed:
    bl      GameMenu        // if START, show ingame menu

    cmp     r0, #1
    beq     backToMain      // quit game
    cmp     r0, #2
    beq     backToGame      // START pressed again

    // else restart game
    bal     InitGame

backToMain:
    bal     main

backToGame:
    bl      InitTiles       // redraw the game tiles
    bal     inputDone

// set the new direction if not opposite to current direction
rPressed:
    cmp     dir, #1
    beq     inputDone
    cmp     dir, #3
    beq     inputDone

    mov     newdir, #1  // right
    bal     storeDir

lPressed:
    cmp     dir, #1
    beq     inputDone
    cmp     dir, #3
    beq     inputDone

    mov     newdir, #3  // left
    bal     storeDir

dPressed:
    cmp     dir, #0
    beq     inputDone
    cmp     dir, #2
    beq     inputDone

    mov     newdir, #2  // down
    bal     storeDir

uPressed:
    cmp     dir, #0
    beq     inputDone
    cmp     dir, #2
    beq     inputDone

    mov     newdir, #0  // up

storeDir:
    // check if already got input this frame
    ldr     addr, =gotInput
    ldrb    val, [addr]
    cmp     val, #0
    bne     inputDone

    ldr     dir, =snakeDir
    strb    newdir, [dir]   // store the new direction

    // set the got input flag
    mov     val, #1
    strb    val, [addr]

inputDone:
    .unreq  dir
    .unreq  newdir
    .unreq  addr
    .unreq  val
    pop     { r4-r7, pc }   // return

