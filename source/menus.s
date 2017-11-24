/*
CPSC 359 Assignment 4, W2016
Geordie Tait 10013837

Contains variables and functions for handling and displaying game menus

PLEASE NOTE: Some commenting was done at home without the ability to
             compile, I don't think I broke anything but if I did please
             let me know ASAP so I can fix it and resubmit before it's
             too late. Thanks!
*/


.section    .data
.align      4

// strings for menu and prompt items
startStr:
    .asciz  "Start Game"
quitStr:
    .asciz  "Quit Game"
restartStr:
    .asciz  "Restart Game"
gameoverStr:
    .asciz  "GAME OVER"
winStr:
    .asciz  "You win!"
loseStr:
    .asciz  "You lose."
pressStr:
    .asciz  "Press any button"
normalStr:
    .asciz  "Normal"
hardStr:
    .asciz  "Hard"

.section    .text

//----------------------------------------------------------------------------
/* Displays the specified menu
 * Args:
 *  r0 - type of menu to produce
 *       0 = main menu      1 = in-game menu
 *       2 = game lost      3 = game won
 *       4 = difficulty menu
*/
.globl      DisplayMenu
DisplayMenu:
    push    { r4, lr }
    type    .req r4

    mov     type, r0

    // draw the background
    ldr     r0, =bkgdMenu
    ldr     r1, =318
    ldr     r2, =216
    bl      DrawBackground

    // check the menu type and branch
    cmp     type, #1
    beq     ingameMenu
    cmp     type, #2
    beq     endPromptLose
    cmp     type, #3
    beq     endPromptWin
    cmp     type, #4
    beq     diffMenu

    // draw strings for main menu
    ldr     r0, =startStr
    ldr     r1, =455
    ldr     r2, =420
    ldr     r3, =0xFFFF
    bl      DrawText

    ldr     r0, =quitStr
    ldr     r1, =460
    ldr     r2, =460
    ldr     r3, =0xFFFF
    bl      DrawText

    bal     dmDone

ingameMenu:
    // draw strings for in-game menu
    ldr     r0, =restartStr
    ldr     r1, =455
    ldr     r2, =420
    ldr     r3, =0xFFFF
    bl      DrawText

    ldr     r0, =quitStr
    ldr     r1, =460
    ldr     r2, =460
    ldr     r3, =0xFFFF
    bl      DrawText

    bal     dmDone

endPromptLose:
    // draw strings for the game lost prompt
    ldr     r0, =gameoverStr
    ldr     r1, =468
    ldr     r2, =400
    ldr     r3, =0xF800
    bl      DrawText

    ldr     r0, =loseStr
    ldr     r1, =470
    ldr     r2, =420
    ldr     r3, =0xFFFF
    bl      DrawText

    bal     endPromptDone

endPromptWin:
    // draw strings for the game won prompt
    ldr     r0, =gameoverStr
    ldr     r1, =468
    ldr     r2, =400
    ldr     r3, =0xF800
    bl      DrawText

    ldr     r0, =winStr
    ldr     r1, =475
    ldr     r2, =420
    ldr     r3, =0xFFFF
    bl      DrawText

endPromptDone:
    // draw press any button string
    ldr     r0, =pressStr
    ldr     r1, =430
    ldr     r2, =460
    ldr     r3, =0xFFFF
    bl      DrawText

    bal     dmDone

diffMenu:
    // draw strings for difficulty menu
    ldr     r0, =normalStr
    ldr     r1, =475
    ldr     r2, =420
    ldr     r3, =0xFFFF
    bl      DrawText

    ldr     r0, =hardStr
    ldr     r1, =480
    ldr     r2, =460
    ldr     r3, =0xFFFF
    bl      DrawText

dmDone:
    .unreq  type
    pop     { r4, pc }  // return

//----------------------------------------------------------------------------
/* The main menu of the game
 *  (Start game, Quit game)
 * Return:
 *  r0 - 0 = start game, 1 = quit game
*/
.globl  MainMenu
MainMenu:
    push    { r4, lr }
    choice  .req r4

    // clear screen
    bl      ClearScreen

    // display the menu
    mov     r0, #0
    bl      DisplayMenu

    // set initial choice and draw selector
    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =415
    ldr     r2, =411
    bl      DrawSprite32

mmLoop:
    bl      GetMenuInput    // get user input from SNES

    cmp     r0, #10
    beq     mmSelect
    cmp     r0, #11
    beq     mmSelect
    cmp     r0, #7
    beq     mmChoose
    cmp     r0, #12
    beq     mmChoose

    bal     mmLoop

// change selection
mmSelect:
    cmp     choice, #0
    beq     mmSelectDown

    mov     r0, #0
    bl      DisplayMenu

    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =415
    ldr     r2, =411
    bl      DrawSprite32

    bal     mmSelectDone

mmSelectDown:
    mov     r0, #0
    bl      DisplayMenu

    mov     choice, #1
    ldr     r0, =sprSelector
    ldr     r1, =420
    ldr     r2, =451
    bl      DrawSprite32

mmSelectDone:
    // wait for delay time
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait

    bal     mmLoop

// make a choice
mmChoose:
    mov     r0, choice

    .unreq  choice
    pop     { r4, pc }

//----------------------------------------------------------------------------
/* The in-game menu accessed by pressing start while playing
 *  (Restart game, Quit game, START to exit back into current game)
 * Return:
 *  r0 - 0 = restart game, 1 = quit game, 2 = exit menu
*/
.globl  GameMenu
GameMenu:
    push    { r4-r7, lr }
    choice  .req r4
    time    .req r5
    addr    .req r6
    val     .req r7

    // get current time
    ldr     time, =0x20003004
    ldr     time, [time]

    // display the menu
    mov     r0, #1
    bl      DisplayMenu

    // set initial choice
    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =415
    ldr     r2, =411
    bl      DrawSprite32

    // wait for delay time
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait

gmLoop:
    bl      GetMenuInput    // get user input from SNES

    cmp     r0, #10
    beq     gmSelect
    cmp     r0, #11
    beq     gmSelect
    cmp     r0, #7
    beq     gmChoose
    cmp     r0, #12
    beq     gmBack

    bal     gmLoop

// change selection
gmSelect:
    cmp     choice, #0
    beq     gmSelectDown

    mov     r0, #1
    bl      DisplayMenu

    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =415
    ldr     r2, =411
    bl      DrawSprite32

    bal     gmSelectDone

gmSelectDown:
    mov     r0, #1
    bl      DisplayMenu

    mov     choice, #1
    ldr     r0, =sprSelector
    ldr     r1, =420
    ldr     r2, =451
    bl      DrawSprite32

gmSelectDone:
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait

    bal     gmLoop

// pressed START, go back to game
gmBack:
    mov     choice, #2

// make a choice
gmChoose:
    // increase timer/clock by amount of time spent in game menu
    ldr     r0, =0x20003004
    ldr     r0, [r0]
    sub     r0, time
    bl      IncreaseClock

    // make sure value pack flag wasn't set
    ldr     addr, =packTime
    mov     val, #0
    strb    val, [addr]

    mov     r0, choice

    .unreq  choice
    .unreq  time
    .unreq  addr
    .unreq  val
    pop     { r4-r7, pc }   // return

//----------------------------------------------------------------------------
/* The menu for selecting difficulty mode
 *  (Normal, Hard)
 * Return:
 *  r0 - 0 = normal, 1 = hard
*/
.globl  DifficultyMenu
DifficultyMenu:
    push    { r4, lr }
    choice  .req r4

    // display the menu
    mov     r0, #4
    bl      DisplayMenu

    // set initial choice
    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =435
    ldr     r2, =411
    bl      DrawSprite32

    // wait for delay time
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait

diffLoop:
    bl      GetMenuInput    // get user input from SNES

    cmp     r0, #10
    beq     dmSelect
    cmp     r0, #11
    beq     dmSelect
    cmp     r0, #7
    beq     dmChoose
    cmp     r0, #12
    beq     dmChoose

    bal     diffLoop

// change selection
dmSelect:
    cmp     choice, #0
    beq     dmSelectDown

    mov     r0, #4
    bl      DisplayMenu

    mov     choice, #0
    ldr     r0, =sprSelector
    ldr     r1, =435
    ldr     r2, =411
    bl      DrawSprite32

    bal     dmSelectDone

dmSelectDown:
    mov     r0, #4
    bl      DisplayMenu

    mov     choice, #1
    ldr     r0, =sprSelector
    ldr     r1, =440
    ldr     r2, =451
    bl      DrawSprite32

dmSelectDone:
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait

    bal     diffLoop

// make a choice
dmChoose:
    mov     r0, choice

    .unreq  choice
    pop     { r4, pc }  // return

//----------------------------------------------------------------------------
/* End-of-game message displayed when player wins or loses
 *  (any button to continue to main menu)
 * Args:
 *  r0 - 0 = win, 1 = loss
*/
.globl      EndPrompt
EndPrompt:
    push    { r4, lr }
    button  .req r4

    // check if won or lost and branch
    cmp     r0, #1
    beq     endLose

    mov     r0, #3
    bal     endReady

endLose:
    mov     r0, #2
    bal     endReady

endReady:
    // display the appropriate message
    bl      DisplayMenu

epLoop:
    // wait for a short delay
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    mov     r0, r0, asr #2
    bl      Wait

    bl      GetMenuInput    // get user input from SNES
    mov     button, r0

    cmp     button, #0
    beq     epLoop          // branch back if no buttons pressed

    // wait for delay time
    ldr     r0, =inputDelay
    ldr     r0, [r0]
    bl      Wait 

    .unreq  button
    pop     { r4, pc }      // return

//----------------------------------------------------------------------------
/* Reads button states from SNES for menu input
 * Return:
 *  r0 - the number of the button which was pressed, else 0
*/
.globl      GetMenuInput
GetMenuInput:
    push    { r4, lr }
    button  .req r4

    bl      Read_SNES       // read button states from SNES

    mov     button, #4
gmiLoop:
    // check for button presses
    mov     r1, button
    bl      getBit
    cmp     r1, #0
    beq     gotButton

    add     button, #1
    cmp     button, #16
    blo     gmiLoop

    bal     noButton

gotButton:
    mov     r0, button  // return which button was pressed
    bal     gmiDone

noButton:
    mov     r0, #0      // didn't get any button press

gmiDone:
    .unreq  button
    pop     { r4, pc }  // return

