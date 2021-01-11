drawPlatform macro x, y, color, height, width ;x, y are the starting position (top left corner)
    local whilePlatformBeingDrawn
    mov cx,x                        
    mov dx,y                                
    whilePlatformBeingDrawn:
        drawPixel_withoutXY color
        inc cx ;the x-coordinate
        checkDifference cx, x, width ;Keep adding Pixels till Cx-P_x=widthPlatform
        JNG whilePlatformBeingDrawn 
        mov cx, x
        inc dx
        checkDifference dx, y, height
    JNG whilePlatformBeingDrawn
endm drawPlatform

graphicsMode macro Mode  ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
    mov ah,00h
    mov al,Mode
    int 10h
ENDM graphicsMode

drawPixel_withoutXY macro color ;Assumes that spatial parameters are already initialized.
    mov ah,0ch
    mov al,color
    int 10h
ENDM drawPixel_withoutXY

drawPixel macro color, row, column
    mov ah,0ch
    mov bh,00h ;Page no.
    mov al,color
    mov dx,row
    mov cx,column
    int 10h
ENDM drawPixel

colorScreen macro color
	mov ah,06       ;Scroll (Zero lines anyway)
    mov al,00h      ;to blank the screen
	mov bh,color    ;color to blank the screen with
	mov cx,0000h    ;start from row 0, column 0
	mov dx,1450h    ;2 thirds of the current resolution 640x480
	int 10h
ENDM colorScreen

checkDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM checkDifference

.model small
.stack 64
.data
	platformsCount  DW 13                                                	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
	;[0] is the ground
	Xpoints         DW 0,20,460,140,20,460,140,20,615,20,615,317,317
	Ypoints         DW 315,270,270,210,150,150,100,276,276,111,111,171,61
	Pcolors         DB 10,8,8,8,8,8,8,8,8,8,8,8,8
	Pwidths         DW 640,160,160,360,160,160,360,5,5,5,5,6,6
	Pheights        DW 20,5,5,5,5,5,5,38,38,38,38,38,38
    
	secondToCompare db ?                                                 	; a variable which hols the current second at any moment,
	; this is used in order to detect if a second has actually passed or not
	secondsBuffer   db 6 dup (?)                                         	; an array to hold the ascii code of seconds to be printed
	curSec          db 61                                                	;a variable that has the current value to be printed
	roundTime       db -1                                                	;sets the time the user wants to end the round at

.code
main proc far
	               mov          ax,@data
	               mov          ds,ax

	               graphicsMode 12h                                                             	;Graphics mode 320x200 , 10 makes the game screen small and changes color
	              
	               colorScreen  3

	display_time:  
	               call         drawLevel2

	;gets the current system time
	               mov          ah, 2ch
	               int          21h                                                             	;seconds return in dh
                
	;TIMER (1 SECOND).
	               cmp          dh, secondToCompare
	               je           display_time                                                    	;keeps repeating the loop until a change has occured, now it is known that a second has actually passed
	               mov          secondToCompare, dh

	; bh will be used as a temp reg for round time if rount time is reached the loop stops
	               mov          bh,roundTime
	               sub          curSec,1
	               cmp          curSec,bh
	               jz           exitLoop
	;mov bh, curSec

	;converting seconds value to string, this is a more general code for the one in sheetIII
	               xor          ax, ax                                                          	;will hold the value of the number to be converted to string
	               mov          al, curSec                                                      	;seconds are moved to al
	               lea          si, secondsBuffer                                               	;variable where the string will be stored
	               call         number2string

	               call         displayTimeMid

	;keep repeating the loop
	               jmp          display_time

	exitLoop:      
	               int          20h

				  
main endp
	;Procedures go here.

drawLevel2 proc
	               MOV          SI,0000h                                                        	;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
	               MOV          DI,0000h                                                        	;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
	               MOV          BX,platformsCount
	               ADD          BX,BX
	DrawPlatforms2:
	               drawPlatform Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]
	               inc          DI
	               add          SI,2
	               CMP          SI,BX
	               JNZ          DrawPlatforms2

	               ret
drawLevel2 endp

number2string proc near
	;FILL BUF WITH DOLLARS.
	               push         si
	               call         dollars
	               pop          si

	               mov          bx, 10                                                          	;DIGITS ARE EXTRACTED DIVIDING BY 10.
	               mov          cx, 0                                                           	;COUNTER FOR EXTRACTED DIGITS.
	cycle1:        
	               mov          dx, 0                                                           	;NECESSARY TO DIVIDE BY BX.
	               div          bx                                                              	;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
	               push         dx                                                              	;PRESERVE DIGIT EXTRACTED FOR LATER.
	               inc          cx                                                              	;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
	               cmp          ax, 0                                                           	;IF NUMBER IS
	               jne          cycle1                                                          	;NOT ZERO, LOOP.
	;NOW RETRIEVE PUSHED DIGITS.
	cycle2:        
	               pop          dx
	               add          dl, 48                                                          	;CONVERT DIGIT TO CHARACTER.
	               mov          [ si ], dl
	               inc          si
	               loop         cycle2

	               ret
number2string endp

	;------------------------------------------
	;FILLS VARIABLE WITH '$'.
	;USED BEFORE CONVERT NUMBERS TO STRING, BECAUSE
	;THE STRING WILL BE DISPLAYED.
	;PARAMETER : SI = POINTING TO STRING TO FILL.

dollars proc near
	               mov          cx, 6
	six_dollars:   
	               mov          bl, '$'
	               mov          [ si ], bl
	               inc          si
	               loop         six_dollars

	               ret
dollars endp

displayTimeMid proc
	;move cursor to top middle of the screen
	               mov          ah,2
	               mov          dx,0027h
	               int          10h
                
	; display string
	               mov          ah, 9
	               lea          dx, secondsBuffer
	               int          21h
	               ret
displayTimeMid endp


end main