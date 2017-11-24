/*
CPSC 359 Assignment 4: Video game (Snake)
University of Calgary   W2016
Geordie Tait    10013837

An implementation of the classic video game Snake in ARM assembly.

The game map is a 32x24 grid including one tile of border around the edges
and 20 (normal mode) or 40 (hard mode) walls scattered randomly throughout
the middle. The player starts with 3 lives and loses 1 upon impacting a
border, a wall, or itself. Extra lives can be collected and appear in random
locations every 100 score points. 30 seconds after beginning the game (and
subsequently every 10 seconds), a speed upgrade appears in a random location.
This causes the snake to change in appearance (based on the current speed
level) and increase in speed. There are a total of 5 speed levels, and
collecting speed upgrades past this point only increases score points. Apples,
lives, and speed upgrades each award the player 10 score points. The exit door
appears once the snake has eaten 20 apples, and entering it wins the game.


PLEASE NOTE: Some commenting was done at home without the ability to
             compile, I don't think I broke anything but if I did please
             let me know ASAP so I can fix it and resubmit before it's
             too late. Thanks!
*/

.section    .init
.globl     _start

_start:
    b       main
    
.section    .text

//----------------------------------------------------------------------------
/* Main program function
*/
.globl      main
main:
// Initialization
    bl      InstallIntTable     // Install int table for interrupt handling
	bl	    EnableJTAG          // Enable JTAG
    bl      InitFrameBuffer     // Initialize frame buffer
    bl      InitSNES            // Initialize SNES controller functions
    bl      InitIRQ             // Initialize IRQ (timer) interrupts

    bl      MainMenu            // Show the main menu and get player's choice
    cmp     r0, #1
    beq     quitGame
    
    bl      InitGame            // If selected, start the game

quitGame:
    bl      ClearScreen         // When game is over clear the game
    bal     haltLoop$           //  and branch to haltLoop$

//----------------------------------------------------------------------------
/* End of the program
*/
haltLoop$:
	b	    haltLoop$

