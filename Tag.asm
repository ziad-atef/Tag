;I,cheesecake, have included and might include macros at the beginning of the code to easily use in visual code
;I recommend using lots of macros and procs since they make the job a lot more modular and easier
;Credit goes to Essam for his well-thought-of advice

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


; graphicsMode macro Mode  ;https://stanislavs.org/helppc/int_10.html click on set video modes for all modes
;     mov ah,00h
;     mov al,Mode
;     int 10h
; ENDM graphicsMode


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

; return macro
;     int 20h
; ENDM return

colorScreen macro color
	mov ah,06 ;Scroll (Zero lines anyway)
    mov al,00h ;to blank the screen
	mov bh,color  ;color to blank the screen with
	mov cx,0000h  ;start from row 0, column 0
	mov dx,184fh ;to the end of the screen
	int 10h
ENDM colorScreen

checkDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM checkDifference

.model huge
.stack 64
.data

player1_x dw 00d
player1_y dw 182d
player_size dw 7d
player2_x dw 50d
player2_y dw 50d
moveSpeed dw 8d
jumpSpeed dw 5d
fallSpeed dw 1d
oldTime db 0
JumpState db 0
JumpState2 db 0
FallState db 1
FallState2 db 1
JumpPos dw ?
JumpPos2 dw ?
platformsCount DW 8 ;a variable to include the number of platforms in order to use in loops to reference in macros

	;cheesecake 
	;variables for the timer
	secondToCompare db ?        	; a variable which holds the current second at any moment,
	; this is used in order to detect if a second has actually passed or not
	secondsBuffer   db 6 dup (?)	; an array to hold the ascii code of seconds to be printed
	curSec          db 0        	;a variable that has the current value to be printed
	roundTime       db 60       	;sets the time the user wants to end the round at

; the following arrays contain the x,y,color,width,and height of all platforms
; the number of elements in each array is platformsCount
Xpoints  DW     0,95,10,220,95,10,220,95
Ypoints  DW     190,160,130,130,100,70,70,35
Pcolors  DB     10,200,200,200,200,200,200,200
Pwidths  DW     320,120,80,80,120,80,80,120
Pheights DW     10,3,3,3,3,3,3,3


;First Platform
P1_x  dw  160 ;x
P1_y  dw  100 ;y
P1_c db 60 ;color
P1_w dw 50 ;width
P1_h dw 5 ;height

;Second Platform (Ground)
P2_x  dw  0 ;x
P2_y  dw  190 ;y
P2_c db 10 ;color
P2_w dw 320 ;width
P2_h dw 10 ;height

;Third Platform
P3_x  dw  70 ;x
P3_y  dw  20 ;y
P3_c db 15 ;color
P3_w dw 80 ;width
P3_h dw 5 ;height

.code     
printTimeMid proc
				
			;move cursor to top middle of the screen to print the time
						mov  ah,2
						mov  dx,0013h
						int  10h
		
		
			; display time as a string
						mov  ah, 9
						lea  dx, secondsBuffer
						int  21h

						ret

printTimeMid endp
;time conversion to string not that important
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

drawLevel1  proc
    colorScreen 80
    MOV SI,0000h    ;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
    MOV DI,0000h    ;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
    MOV BX,platformsCount
    ADD BX,BX
    DrawPlatforms:
        drawPlatform Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]
        add DI,1
        add SI,2
        CMP SI,BX
        JNZ DrawPlatforms
    ret
drawLevel1 endp

draw_player1 proc
    mov cx,player1_x
    mov dx,player1_y 
    draw:
    mov ah,0ch
    mov al,0fh
    mov bh,00h
    int 10h
    inc cx
    mov ax,cx
    sub ax,player1_x
    cmp ax,player_size
    jng draw
    mov cx,player1_x
    inc dx
    mov ax,dx
    sub ax,player1_y
    cmp ax,player_size
    jng draw
    ret
draw_player1 endp

draw_player2 proc
    mov cx,player2_x
    mov dx,player2_y 
    draw1:
    mov ah,0ch
    mov al,00h
    mov bh,00h
    int 10h
    inc cx
    mov ax,cx
    sub ax,player2_x
    cmp ax,player_size
    jng draw1
    mov cx,player2_x
    inc dx
    mov ax,dx
    sub ax,player2_y
    cmp ax,player_size
    jng draw1
    ret
draw_player2 endp

player1move proc
mov  ah,01h
int  16h
jz Ascend

mov ah,00h
int 16h

cmp ah,4Dh
je right
cmp ah,4Bh
je left
cmp ah,48h
je up
jmp finish
right:
cmp player1_x,312d
je Ascend
mov bx,player1_x
add bx,moveSpeed
mov player1_x,bx
jmp Ascend
left:
cmp player1_x,00h
je Ascend
mov bx,player1_x
sub bx,moveSpeed
mov player1_x,bx
jmp Ascend
up:
cmp FallState,01h
je Descend
mov JumpState,1h
mov bx,player1_y
sub bx,40d
mov JumpPos,bx

Ascend:
cmp JumpState,0h
je  Descend
mov bx,player1_y
sub bx,jumpSpeed
mov player1_y,bx
cmp bx,JumpPos
jg Descend
mov JumpState,00h
mov FallState,01h

Descend:       ;190,160,130,130,100,70,70,35
cmp player1_y,27d
je platform1
cmp player1_y,62d
je platform2
cmp player1_y,152d
je platform1
cmp player1_y,122d
je platform2
cmp player1_y,92d
je platform1
cmp player1_y,182d
je ground
fall:
cmp FallState,0h
je finish
mov bx,player1_y
add bx,fallSpeed
mov player1_y,bx
ret

platform1:
mov FallState,1h
cmp player1_x,87d
jl fall
cmp player1_x,215d 
jg fall
jmp ground

platform2:
mov FallState,01h
cmp player1_x,02d
jl fall
cmp player1_x,300d
jg fall
cmp player1_x,90d
jl ground
cmp player1_x,220d
jl fall
mov FallState,0h

ground:
mov FallState,0h
ret

finish:
ret
player1move endp

player2move proc
    mov  ah,01h
    int  16h
    jz end

    mov ah,00h
    int 16h

    cmp al,44h
    je D
    cmp al,64h
    je D
    cmp al,41h
    je A
    cmp al,61h
    je A
    ret
    A:
    mov bx,player2_x
    sub bx,moveSpeed
    mov player2_x,bx
    ret
    D:
    mov bx,player2_x
    add bx,moveSpeed
    mov player2_x,bx
    end:
    ret
player2move endp

main proc far             
    mov ax,@data
    mov ds,ax      

    mov ah,00h
    mov al,13h
    int 10h

    mov ah,0Bh
    mov bh,00h
    mov bl,00h
    int 10h
;time			 
	display_time: 
	;gets the current system time
	mov  ah, 2ch
	int  21h                	;seconds return in dh

	;TIMER (1 SECOND).
	cmp  dh, secondToCompare	;time
	je   time       	;keeps repeating the loop until a change has occured, now it is known that a second has actually passed
				  					;cheesecake: the loop is supposed to go back to label display_time 
									;but i changed it to go to label time so that the code flows normally
	mov  secondToCompare, dh

	; bh will be used as a temp reg for round time if rount time is reached the loop stops
	mov  bh,roundTime	;time
	add  curSec,1
    cmp  curSec,bh
    jz   exitLoop

	;converting seconds value to string, this is a more general code for the one in sheetIII
	xor  ax, ax             	;will hold the value of the number to be converted to string
	mov  al, curSec         	;seconds are moved to al
	lea  si, secondsBuffer  	;variable where the string will be stored
				  							;tried moving the previous three lines inside proc number2string but failed
	call number2string		

				  

    time:
        
        mov ah,2ch
        int 21h
        cmp dl,oldTime
        je time
        mov oldTime,dl
        call player1move
        call player2move
        call drawLevel1
        call draw_player1
        call draw_player2
        call printTimeMid	;time
							;time is printed after player is drawn to avoid flickering
		jmp  display_time
        exitLoop:
    hlt 
main endp 

end main 

