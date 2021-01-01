.MODEL SMALL
.STACK 64
.data

	secondToCompare db ?        	; a variable which holds the current second at any moment,
	; this is used in order to detect if a second has actually passed or not
	secondsBuffer   db 6 dup (?)	; an array to hold the ascii code of seconds to be printed
	curSec          db 0        	;a variable that has the current value to be printed
	roundTime       db 60       	;sets the time the user wants to end the round at

.code

main proc far
	              mov  ax,@data
	              mov  ds,ax

	;change to graphic mode, should be removed in integration
	              mov  ah,00h
	              mov  al,13h
	              int  10h

	;mov bx,0000h   ; bh was used as a temp reg for the variable curSec but was removed


	display_time: 
	;gets the current system time
	              mov  ah, 2ch
	              int  21h                	;seconds return in dh
  
  
	;TIMER (1 SECOND).
	              cmp  dh, secondToCompare
	              je   display_time       	;keeps repeating the loop until a change has occured,
				  							;now it is known that a second has actually passed
	              mov  secondToCompare, dh

	; bh will be used as a temp reg for round time if rount time is reached the loop stops
	              mov  bh,roundTime
	              add  curSec,1
	              cmp  curSec,bh
	              jz   exitLoop
	;mov bh, curSec

	;converting seconds value to string, this is a more general code for the one in sheetIII
	              xor  ax, ax             	;will hold the value of the number to be converted to string
	              mov  al, curSec         	;seconds are moved to al
	              lea  si, secondsBuffer  	;variable where the string will be stored
	              call number2string

	;move cursor to top middle of the screen
	              mov  ah,2
	              mov  dx,0013h
	              int  10h
  
	; display string
	              mov  ah, 9
	              lea  dx, secondsBuffer
	              int  21h

	;keep repeating the loop
	              jmp  display_time

	exitLoop:     
	              hlt
main endp


	;------------------------------------------
	;CONVERT A NUMBER IN STRING.
	;ALGORITHM : EXTRACT DIGITS ONE BY ONE, STORE
	;THEM IN STACK, THEN EXTRACT THEM IN REVERSE
	;ORDER TO CONSTRUCT STRING (STR).
	;PARAMETERS : AX = NUMBER TO CONVERT.
	;             SI = POINTING WHERE TO STORE STRING.

number2string proc near
	;FILL BUF WITH DOLLARS.
	              push si
	              call dollars
	              pop  si

	              mov  bx, 10             	;DIGITS ARE EXTRACTED DIVIDING BY 10.
	              mov  cx, 0              	;COUNTER FOR EXTRACTED DIGITS.
	cycle1:       
	              mov  dx, 0              	;NECESSARY TO DIVIDE BY BX.
	              div  bx                 	;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
	              push dx                 	;PRESERVE DIGIT EXTRACTED FOR LATER.
	              inc  cx                 	;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
	              cmp  ax, 0              	;IF NUMBER IS
	              jne  cycle1             	;NOT ZERO, LOOP.
	;NOW RETRIEVE PUSHED DIGITS.
	cycle2:       
	              pop  dx
	              add  dl, 48             	;CONVERT DIGIT TO CHARACTER.
	              mov  [ si ], dl
	              inc  si
	              loop cycle2

	              ret
number2string endp

	;------------------------------------------
	;FILLS VARIABLE WITH '$'.
	;USED BEFORE CONVERT NUMBERS TO STRING, BECAUSE
	;THE STRING WILL BE DISPLAYED.
	;PARAMETER : SI = POINTING TO STRING TO FILL.

dollars proc near
	              mov  cx, 6
	six_dollars:  
	              mov  bl, '$'
	              mov  [ si ], bl
	              inc  si
	              loop six_dollars

	              ret
dollars endp

end main