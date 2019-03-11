; Single Cycle Computer (SCC) Assignment 2a
; Created by <Bryan Tyrrell>
; Creation date: <20/02/2019>
; viciLogic Single Cycle Computer: https://www.vicilogic.com/static/ext/SCC/
;
; Description
; This program counts up in near 1 second intervals and shows the count
; value on the 7 segment display if the user asserts right or left
; a 4 bit paddle in memory address 83h will move either right or left



; Register use 

; R2 used to set the balls next state(ONLY USED TO STORE R0 VALUE CAN BE USED EVERYWHERE ELSE)
; R1 used to remember the ball address in memory screen
; R0 used to remember the ball 1 bit in the row


;Memory address use 
;
; ASSEMBLY INSTRUCTION      ; DECRIPTION
main:
  CALL SetupPaddle;               ; SetUp Function to set initial regiester values
  CALL SystemControl        ; Run main paddle control loop indefinitely
  END





SetupPaddle:                      

; Set up paddle
  MOVDPTR 000Ch             ; move hex address Ch to SFR15
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3this will be the paddle row address
  XOR R2,R2,R2              ; good pratice to clear the register before using them for the first time
  SETBR R2, 7               ; Set bit at index 7 in R2 to 1 this is creating the initial 4 bit paddle
  SETBR R2, 8               ; Set bit at index 8 in R2 to 1 this is creating the initial 4 bit paddle
  SETBR R2, 9               ; Set bit at index 9 in R2 to 1 this is creating the initial 4 bit paddle
  MOVBAMEM @R3, R2          ; This writes the paddle value in R2(03C0h) to memory address 13 in stack memory
  XOR R2,R2,R2              ; finished with r2
  XOR R3,R3,R3              ; finished with r3


; set up interrupt
  INV R0, R0                ; Inverts R0 from all 0s to 1s

  MOVDPTR 17Dh              ; Move the hex value 17Ch to SFR15
  MOVSFRR R1, SFR15         ; Then move the value(17Ch) in SFR15 to R1

  
  MOVRSFR SFR9, R1         ; Then move the value(17Ch) in R1 to SFR9(TMRH_LDVAL)
  MOVRSFR SFR8, R0         ; Then move the value(17Ch) in R0 to SFR8(TMRL_LDVAL)
  MOVRSFR SFR2, R1         ; Then move the value(17Ch) in R1 to SFR2(TMRH)
  MOVRSFR SFR1, R0         ; Then move the value(17Ch) in R0 to SFR1(TMRL)


  MOVDPTR 79h              ; Move the hex value 79h(1111001) to SFR15
  MOVSFRR R7, SFR15        ; Then move the value(79h) in SFR15 to R7
  MOVRSFR SFR0, R7         ; Then move the value(79h) in R7 to SFR0

  XOR R1,R1,R1
  XOR R0,R0,R0 
  XOR R7,R7,R7
  
; set up section for ball and starting address
  MOVDPTR 0012h             ; move hex address 16h to SFR15
  MOVSFRR R1, SFR15         ; move hex value Ch from sfr15 to R3this will be the paddle row address
  SETBR R0,8                ; sets the dot
  MOVBAMEM @R1, R0          ; This writes the paddle value in R2(h) to memory address 20 in stack memory

XOR R2,R2,R2
XOR R3,R3,R3

; SET UP DIRECTION OF BALL
MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,0                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
  
  RET;





SystemControl:
  NOP
PaddleControlLoop:          ; This paddlecontrol loop will run infinitly due to interrupt           
NOP
ORG 116;
  CALL IncrementNumber      ; Increment the second count in memory
  CALL MovePaddle           ; Check if the input port (R4) is asserted high and if so move paddle
  CALL IsBallAbovePaddle    ; Check if the ball is above the paddle 
  RETI;

  RET;






IncrementNumber:            ; IncrementNumber Function label
  SETBSFR SFR5, 0           ; Set bit 0 in SFR to 1 this will turn on the first LED
  XOR R6,R6,R6
  MOVSFRR R6, SFR4         ; Since R5 has counted to 0 store the memory address in it
  INC R6, R6 
  MOVRSFR SFR4,R6
  XOR R6,R6,R6
  CLRBSFR SFR5, 0           ; Deassert the 0 index in the LED display
  RET

MovePaddle:                 ; MovePaddle Function label
  XOR R4,R4,R4
  MOVSFRR R4, SFR12         ; Move the input from user into R4

  JNZ R4, ShiftPaddle       ; If input value has been entered by the user R7 will not be zero and jump to Shift paddle

  XOR R4,R4,R4
  RET                       ; Return

ShiftPaddle:                ; ShiftPaddle Function label
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 10              ; Set bit 10(Right shift) in R7 to one
  AND R7,R4,R7              ; Check if input from R4 and R7 match will return 1 if it does

  JNZ R7,CheckShiftRightWall; If R7 not zero, this means right shift bit is set and jump to CheckShiftRightWall

  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 11              ; Set bit 10(left shift) in R7 to one
  AND R7,R4,R7              ; Check if input from R4 and R7 match will return 1 if it does

  JNZ R7,CheckShiftLeftWall ; If R7 not zero, this means right shift bit is set and jump to CheckShiftLeftWall

  XOR R7,R7,R7
  RET;

CheckShiftRightWall:        ; CheckShiftRightWall Function label(checks if paddle is touching the right wall)
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 0               ; Set bit at index 0 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 1               ; Set bit at index 1 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 2               ; Set bit at index 2 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  XOR R7,R2,R7              ; If values match R7 will be 0 else R7 value will not be 0 meaning its not touching the right edge

  JNZ R7,ShiftRight         ; If R7 not 0 jump to ShiftRight

  XOR R4,R4,R4              ; Since right shift has priority clear the input Register R4 as action is complete
  XOR R7,R7,R7              ; Make sure R7 value is 0
  RET;

CheckShiftLeftWall:         ; CheckShiftLeftWall Function label
  XOR R7,R7,R7              ; Make sure R7 value is 0
  SETBR R7, 15              ; Set bit at index 15 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 14              ; Set bit at index 14 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  SETBR R7, 13              ; Set bit at index 13 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
  XOR R7,R2,R7              ; If values match R7 will be 0 else R7 value will not be 0 meaning its not touching the left edge

  JNZ R7,ShiftLeft          ; If R7 not 0 jump to ShiftLeft
  XOR R7,R7,R7              ; Make sure R7 value is 0
  RET;

ShiftRight:                 ; ShiftRight Function label
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  MOVDPTR 000Ch             ; move hex address Ch to SFR15
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3this will be the paddle row address
  MOVAMEMR R2,@R3
  SHRL R2, 1                ; Logical shift the paddle 1 bit right
  MOVBAMEM @R3, R2          ; Set the new paddle value in R2 to memory address in R3
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  XOR R2,R2,R2              ; Make sure R7 value is 0
  RET;

ShiftLeft:                  ; ShiftLeft Function label
  
  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  XOR R7,R7,R7              ; Make sure R7 value is 0
  MOVDPTR 000Ch             ; move hex address Ch to SFR15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3this will be the paddle row address
  MOVAMEMR R2,@R3
  SHLL R2, 1;               ; Logical shift the paddle 1 bit left
  MOVBAMEM @R3, R2          ; Set the new paddle value in R2 to memory address in R3
  XOR R7,R7,R7              ; Make sure R7 value is 0
  XOR R2,R2,R2
  RET;

IsBallAbovePaddle:

  MOVDPTR 000Dh             ; CHECK IF THE BALL IS ABOVE THE PADDLE
  MOVSFRR R3, SFR15         ; Move the address of the row above the paddle into SFR15
  XOR R3,R1,R3              ; If it is above the paddle r3 will be 0 as the ball is in the row above paddle
  JZ R3,IsBallColidedWithPaddle; if ball above paddle jump to is ball collide with paddle 
  JNZ R3, SetDotDirection      ; Else jump to dot move because its not at the paddle
RET;

IsBallColidedWithPaddle:

  XOR R3,R3,R3              ; good pratice to clear the register before using them for the first time
  XOR R2,R2,R2              ; Make sure R7 value is 0
  MOVDPTR 000Ch             ; move hex address Ch to SFR15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3 this will be the paddle row address
  MOVAMEMR R2,@R3           ; move the value of the paddle into r2
  AND R2,R2,R0
  JNZ R2, WhichBitCollided  ;WhichBitCollided
  ; stop the interrupt
  XOR R7,R7,R7
  MOVRSFR SFR0, R7         ; Then move the value(0h) in R7 to SFR0
  END
RET;



WhichBitCollided:
  XOR R3,R3,R3              ; good pratice to clear the register
  XOR R2,R2,R2              ; Make sure R2 value is 0
  XOR R4,R4,R4              ; Make sure R4 value is 0
  XOR R7,R7,R7              ; Make sure R7 value is 0
   
  MOVDPTR 000Ch             ; Moves memory address of paddle into sfr15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3 this will be the paddle row address
  MOVAMEMR R2,@R3           ; move the value of the paddle into r2
 
  MOVRR R4,R0               ; MOVES THE DOT BIT INTO R4

 XOR R3,R3,R3
  CountdownLoop:                ;This loop will shift the padle to the right completely
      XOR R7,R7,R7
      SETBR R7, 2              ; Set bit at index 2 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
      SETBR R7, 1              ; Set bit at index 1 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
      SETBR R7, 0              ; Set bit at index 0 in R7 to 1 this is creating a value to XOR against current paddle location(R2)
      XOR R7,R2,R7              ; If values match R7 will be 0 else R7 value will not be 0 meaning its not touching the left edge
      JZ R7,PaddleShiftedWall          ;check if its touching the right wall and break if it is
      INC R3,R3                 ; decrement the counter
      SHRL R2,1                 ; shift one to the left
      JNZ R7,CountdownLoop          ;check if its touching the right wall and break if it is
  

PaddleShiftedWall:
   XOR R7,R7,R7
   MoveDotToRightWall:            ;Moves the dot to the right wall
     SHRL R4,1
     DEC R3,R3
     JNZ R3,MoveDotToRightWall
  ; the paddle and ball have been moved to the right wall
  AND R4,R2,R4 
 
  MOVDPTR 0004h             ; Moves memory address of paddle into sfr15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3 this will be the paddle row address
  XOR R3,R4,R3
  JZ R3, DotUpLeft

  MOVDPTR 0002h             ; Moves memory address of paddle into sfr15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3 this will be the paddle row address
  XOR R3,R4,R3
  JZ R3, DotUpMiddle

  MOVDPTR 0001h             ; Moves memory address of paddle into sfr15
  MOVSFRR R3, SFR15         ; move hex value Ch from sfr15 to R3 this will be the paddle row address    
  XOR R3,R4,R3
  JZ R3, DotUpRight


RET;





SetAbovePaddleBit:
 XOR R3,R3,R3              ; clear r3
 XOR R2,R2,R2
 MOVDPTR 0050h             ; address 80 in memory
 MOVSFRR R3, SFR15         ; Move the address of the row above the paddle into SFR15
 MOVAMEMR R2,@R3           ; Move the value in 80h in memory to r2
 
 SETBR R2,15               ; set bit 15 in register 2

 MOVBAMEM @R3, R2          ; move the new value back to memory

RET;



BallUpDown:
  XOR R3,R3,R3
  XOR R3,R3,R3
  MOVDPTR 0050h             ; CHECK IF THE BALL IS ABOVE THE PADDLE
  MOVSFRR R3, SFR15         ; Move the address of the row above the paddle into SFR15
  

  



RET;


DotDownMiddle:
  
  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  DEC R1,R1
  MOVBAMEM @R1, R0          ; 
  XOR R2,R2,R2
  XOR R3,R3,R3 
; SET UP DIRECTION OF BALL
  MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,0                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3


RET;

DotDownRight:
; first check if the bit ball is beside the left wall if so send the ball right
  XOR R2,R2,R2
  SETBR R2,0
  XOR R2,R0,R2
  JZ R2,DotDownLeft

; NOW MOVE THE BALL down
  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  DEC R1,R1
  SHRL R0, 1
  MOVBAMEM @R1, R0 

XOR R2,R2,R2
XOR R3,R3,R3

; SET UP DIRECTION OF BALL
  MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,1                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
RET;

DotDownLeft:
; first check if the bit ball is beside the left wall if so send the ball right
  XOR R2,R2,R2
  SETBR R2,15
  XOR R2,R0,R2
  JZ R2,DotDownRight
; NOW MOVE THE BALL down
  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  DEC R1,R1
  SHLL R0, 1
  MOVBAMEM @R1, R0 

XOR R2,R2,R2
XOR R3,R3,R3

; SET UP DIRECTION OF BALL
  MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,2                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
RET;


DotUpMiddle:

  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  INC R1,R1
  MOVBAMEM @R1, R0  


 XOR R2,R2,R2
 XOR R3,R3,R3

; SET UP DIRECTION OF BALL
MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,3                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
RET;

DotUpRight:
; first check if the bit ball is beside the right wall if so send the ball left
  XOR R2,R2,R2
  SETBR R2,0
  XOR R2,R0,R2
  JZ R2,DotUpLeft
; NOW CHECK IF THE BALL HAS REACHED THE TOP
  XOR R2,R2,R2
  MOVDPTR 001Fh             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  XOR R2,R1,R2
  JZ R2,DotDownRight
;NOW MOVE THE BALL UP
  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  INC R1,R1
  SHRL R0, 1
  MOVBAMEM @R1, R0  

XOR R2,R2,R2
XOR R3,R3,R3

; SET UP DIRECTION OF BALL
  MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  SETBR R3,4                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
RET;


DotUpLeft:
; first check if the bit ball is beside the left wall if so send the ball right
  XOR R2,R2,R2
  SETBR R2,15
  XOR R2,R0,R2
  JZ R2,DotUpRight
; NOW CHECK IF THE BALL HAS REACHED THE TOP
  XOR R2,R2,R2
  MOVDPTR 001Fh             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
  XOR R2,R1,R2
  JZ R2,DotDownLeft
; NOW MOVE THE BALL UP
  XOR R2,R2,R2
  MOVRR R2, R0
  XOR R0,R0,R0
  MOVBAMEM @R1, R0
  MOVRR R0, R2
  INC R1,R1
  SHLL R0, 1
  MOVBAMEM @R1, R0  

XOR R2,R2,R2
XOR R3,R3,R3

; SET UP DIRECTION OF BALL
MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R2, SFR15         ; move hex value 85h from sfr15 to R2 this will be the DIRECTION address
   SETBR R3,5                ; sets the direction as down
  MOVBAMEM @R2, R3          ; This writes the paddle value in R2(h) to memory address 1h

XOR R2,R2,R2
XOR R3,R3,R3
RET;



SetDotDirection:

XOR R2,R2,R2
XOR R3,R3,R3
XOR R4,R4,R4

; BALL DIRECTION
  MOVDPTR 0085h             ; move hex address 85h to SFR15
  MOVSFRR R3, SFR15         ; move hex value 85h from sfr15 to R3 this will be the DIRECTION address
  MOVAMEMR R2,@R3           ; Move the value in 85h in memory to r2

  MOVDPTR 0001h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotDownMiddle          ; go this direction

  MOVDPTR 0002h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotDownRight          ; go this direction

  MOVDPTR 0004h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotDownLeft          ; go this direction

  MOVDPTR 0008h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotUpMiddle            ; go this direction

  MOVDPTR 0010h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotUpRight             ; go this direction

  MOVDPTR 0020h             ; move hex address 1h to SFR15
  MOVSFRR R4, SFR15         ; move hex value 1h from sfr15 to R4 this will be the DIRECTION address CHECK 
  XOR R4,R2,R4              ; xor the values if 0 it means this is the direction
  JZ R4,DotUpLeft              ; go this direction
 


RET;


