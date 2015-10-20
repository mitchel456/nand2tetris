// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel. When no key is pressed, the
// program clears the screen, i.e. writes "white" in every pixel.

(LOOP)
  @KBD
  D=M
  @CLEAR
  D;JEQ
  @FILL
  0;JEQ
(FILL)
  @color
  M=0
  M=M-1
  @WRITE
  0;JEQ
(CLEAR)
  @color
  M=0
  @WRITE
  0;JEQ
(WRITE)
  @8192
  D=A
  @relativepos
  M=D
(COLORLOOP)
  @relativepos
  D=M
  @LOOP
  D;JLT
  @SCREEN
  D=A+D
  @absolutepos
  M=D
  @color
  D=M
  @absolutepos
  A=M
  M=D
  @relativepos
  M=M-1
  @COLORLOOP
  0;JEQ
