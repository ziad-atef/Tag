;-------------------------------------------------------------Drawing level 1 macros---------------------------------------------------------------------------


drawRectangle macro x, y, color, height, width ;x, y are the starting position (top left corner)
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
endm drawRectangle

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
	mov dx,184fh    ;to the end of the screen
	int 10h
ENDM colorScreen

checkDifference macro A,B,C ;checks if A-B=C and yields 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM checkDifference
.286
.model small
.stack 64
.data
    player1_x dw 00d
    player1_y dw 182d
    player_size dw 7d
    player2_x dw 312d
    player2_y dw 182d
    oldTime db 0

    X1 db 0
    Y1 db 2
    X2 db 0
    Y2 db 2

    moveSpeed dw 8d
    gravity dw 5d

    player1JumpState db 0
    player2JumpState db 0
    player1FallState db 0
    player2FallState db 0
    player1JumpPos dw ?
    player2JumpPos dw ?


    platformsCount DW 8                             	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
	Xpoints        DW 0,95,10,220,95,10,220,95
	Ypoints        DW 190,160,130,130,100,70,70,35
	Pcolors        DB 10,200,200,200,200,200,200,200
	Pwidths        DW 320,120,80,80,120,80,80,120
	Pheights       DW 10,3,3,3,3,3,3,3

    tag                  db 0
    p1_tag_x             dw 3d
	p1_tag_y             dw 177d
	p2_tag_x             dw 315d
	p2_tag_y             dw 177d

    ;cheesecake
	;variables for the timer
	compareTemp          db ?                             	; a variable which holds the current second at any moment,
	; this is used in order to detect if a second has actually passed or not
	secondsBuffer        db 6 dup (?)                     	; an array to hold the ascii code of seconds to be printed
	curSec               db 60                            	;a variable that has the current value to be printed
	roundTime            db -1d                           	;sets the time the user wants to end the round at

	collisionTimer       db 0                             	;cur value of the change timer when a collision occurs
	curCollisionSec      db 4                             	;starts at the max value we want the collision timer to be, in our case it is 4
	collisionCompareTemp db ?
	collisionRunning     db 0                             	; a variable to keep track of whether the collision timer is already running


.code     

main proc far             
    mov ax,@data
    mov ds,ax  

    graphicsMode  13h

    mov ah,0Bh
    mov bh,00h
    mov bl,00h
    int 10h
    
    display_time:  
	;gets the current system time
	               mov           ah, 2ch
	               int           21h                                                             	;seconds return in dh

	;TIMER (1 SECOND).
	               cmp           dh, compareTemp                                                 	;time
	               je            time                                                            	;keeps repeating the loop until a change has occured, now it is known that a second has actually passed
	;cheesecake: the loop is supposed to go back to label display_time
	;but i changed it to go to label time so that the code flows normally
	               mov           compareTemp, dh

	; bh will be used as a temp reg for round time if rount time is reached the loop stops
	               mov           bh,roundTime                                                    	;time
	               dec           curSec
	               cmp           curSec,bh
	               jz            exitLoop

	;converting seconds value to string, this is a more general code for the one in sheetIII
	               xor           ax, ax                                                          	;will hold the value of the number to be converted to string
	               mov           al, curSec                                                      	;seconds are moved to al
	               lea           si, secondsBuffer                                               	;variable where the string will be stored
	;tried moving the previous three lines inside proc number2string but failed
	               call          number2string
				   
	;code for the collision timer
	               mov           ah, 2ch
	               int           21h                                                             	;seconds return in dh
					
					
	               cmp           dh, collisionCompareTemp
	               je            time  ;keeps repeating the loop until a change has occured, 
				   					   ;now it is known that a second has actually passed
	               mov           collisionCompareTemp, dh ; if a second has passed move this current sec to the temp variable
				   										  ; to keep comparing with the upcoming seconds
	               

	               mov           bh,collisionTimer		
	               dec           curCollisionSec 
	               cmp           curCollisionSec,bh		;if the collision timer has reached zero we want to reset the timer
				   										;else keep going with the code
	               jnz            time 
				   ;if the colision timer reaches zero we will reset the timer

				   mov curCollisionSec,4  ;this code block is responsible for resetting the timer
					mov bh,0
					mov collisionRunning,0

    time:
    call drawLevel1
    call draw_player1
    call draw_player2
    call printTimeMid 

    mov ah,2ch
    int 21h
    cmp dl,oldTime
    je time
    mov oldTime,dl
    
    call KeyClick
    call Move
    call PlayerStatus
    call Level1BoundariesCheck
    call checkCollision
    colorScreen 80
    
    jmp           display_time
exitLoop:

    hlt 
main endp 

;-------------------------------------------------------------------Moving player Procedures--------------------------------------------------------------------------------

Move PROC
    ;player1
    cmp X1, 1
    jne left1
        mov CX, player1_x
        add CX, moveSpeed
        mov player1_x, CX
        jmp up1

    left1:
    cmp X1, 2
    jne up1
        mov CX, player1_x
        sub CX, moveSpeed
        mov player1_x, CX
        jmp up1

    up1:
    cmp Y1, 1
    jne player2
        mov Y1, 2
        cmp player1JumpState, 1
        je player2
        cmp player1FallState, 1
        je player2
        mov player1JumpState, 1
        mov CX, player1_y
        sub CX, 40
        mov player1JumpPos, CX

    player2:
    cmp X2, 1
    jne left2
        mov CX, player2_x
        add CX, moveSpeed
        mov player2_x, CX
        jmp up2

    left2:
    cmp X2, 2
    jne up2
        mov CX, player2_x
        sub CX, moveSpeed
        mov player2_x, CX
        jmp up2

    up2:
    cmp Y2, 1
    jne EndMove
        mov Y2, 2
        cmp player2JumpState, 1
        je EndMove
        cmp player2FallState, 1
        je EndMove
        mov player2JumpState, 1
        mov CX, player2_y
        sub CX, 40
        mov player2JumpPos, CX
    EndMove:
    ret
Move ENDP

PlayerStatus PROC
    ;player1ascend
    cmp player1JumpState, 1
    jne player1descend
        mov CX, player1_y
        sub CX, gravity
        mov player1_y, CX
        cmp CX, player1JumpPos
        ja player2ascend
            mov player1JumpState, 0
            mov player1FallState, 1
            jmp player2ascend

    player1descend:
    cmp player1FallState, 1
    jne player2ascend
        mov CX, player1_y
        add CX, gravity
        mov player1_y, CX

    player2ascend:
    cmp player2JumpState, 1
    jne player2descend
        mov CX, player2_y
        sub CX, gravity
        mov player2_y, CX
        cmp CX, player2JumpPos
        ja player2ascend
            mov player2JumpState, 0
            mov player2FallState, 1
            ret

    player2descend:
    cmp player2FallState, 1
    jne EndPlayerStatus
        mov CX, player2_y
        add CX, gravity
        mov player2_y, CX

    EndPlayerStatus:
ret
PlayerStatus ENDP

KeyClick PROC

    mov SI, 4
    last4clicks:

        mov ah,1
        int 16H

        jz endPress

        mov ah,0
        int 16H

        call KeyAction
    
    dec SI
    cmp SI,0
    jnz last4clicks

    RET

    endPress:
    RET
KeyClick ENDP

KeyAction PROC

    ;PLAYER 2 KEYS
        CMP AH, 72            ;UP
        JE player2up

        CMP AH, 75            ;LEFT
        JE player2left  

        CMP AH, 77            ;RIGHT
        JE player2right 
        
        cmp AH, 80            ;DOWN
        JE player2down

    ;PLAYER 1 KEYS
        CMP AL, 77H
        JE player1up    ; w      
        CMP AL, 57H
        JE player1up    ; W

        CMP AL, 61H
        JE player1left   ; a      
        CMP AL, 41H
        JE player1left   ; A

        CMP AL, 64H
        JE player1right  ; d      
        CMP AL, 44H
        JE player1right  ; D

        CMP AL, 53H     
        JE player1down   ;S
        CMP AL, 73H
        JE player1down   ;s

    RET


    ;PLAYER 2 ACTIONS
        player2up:
            MOV Y2, 1
            RET

        player2right:                                    ;set player direction to up
            MOV X2, 1  ;1 MEANS GO RIGHT
            RET        
        
        player2left: 
            MOV X2, 2  ;2 MEANS GO LEFT
            RET

        player2down:
            MOV X2, 0
            MOV Y2, 2

    ;PLAYER 1 ACTIONS
        player1up:
            MOV Y1, 1
            RET
        
        player1right:
            MOV X1, 1
            RET
            
        player1left:
        MOV X1, 2
        RET
        
        player1down:
            MOV X1, 0
            MOV Y1, 2
    END_KEY_ACTIONS:

    RET
KeyAction ENDP

;============================================================================================================================================================================

;-------------------------------------------------------------------Players Drawing Procedures----------------------------------------------------------------------------------

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
    cmp           tag, 0
	jnz           no_tag

	    pusha
	    mov           ax, player1_x
	    add           ax, 3d
	    mov           p1_tag_x, ax
	    mov           bx, player1_y
	    sub           bx, 5d
	    mov           p1_tag_y, bx
	    drawRectangle p1_tag_x, p1_tag_y, 4, 4, 1
	    popa
	no_tag:        
ret
draw_player1 endp

draw_player2 proc
    mov cx,player2_x
    mov dx,player2_y 
    draw1:
    mov ah,0ch
    mov al,0fh
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
    cmp           tag, 1
	jnz           no_tag1
                   
	    pusha
	    mov           ax, player2_x
	    add           ax, 3d
	    mov           p2_tag_x, ax
	    mov           bx, player2_y
	    sub           bx, 5d
	    mov           p2_tag_y, bx
	    drawRectangle p2_tag_x, p2_tag_y, 13, 4, 1
	    popa
	no_tag1:       
ret
draw_player2 endp

;==============================================================================================================================================================================

;--------------------------------------------------------------------Level1 Drawing Procedures--------------------------------------------------------------------------------

drawLevel1 proc
	              MOV          SI,0000h                                                        	;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
	              MOV          DI,0000h                                                        	;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
	              MOV          BX,platformsCount
	              ADD          BX,BX
	DrawPlatforms:
	              drawRectangle Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]
	              inc          DI
	              add          SI,2
	              CMP          SI,BX
	              JNZ          DrawPlatforms

	              ret
drawLevel1 endp

;================================================================================================================================================================================

;--------------------------------------------------------------------Level1 Boundaries Check-------------------------------------------------------------------------------------

Level1BoundariesCheck PROC
;player1
cmp player1FallState, 1
jne p1sitting
    cmp player1_y,27d
    je p1platform1
    cmp player1_y,62d
    je p1platform2
    cmp player1_y,92d
    je p1platform1
    cmp player1_y,122d
    je p1platform2
    cmp player1_y,152d
    je p1platform1
    cmp player1_y,182d
    je p1ground

    jmp p1RightBound

    p1platform1:
    mov player1FallState, 1
    cmp player1_x, 87
    jb p1RightBound
    cmp player1_x, 215
    ja p1RightBound
    jmp p1ground

    p1platform2:
    mov player1FallState, 1
    cmp player1_x, 2
    jb p1RightBound
    cmp player1_x, 300
    ja p1RightBound
    cmp player1_x, 90
    jb p1ground
    cmp player1_x, 220
    jb p1RightBound

    p1ground:
    mov player1FallState,0h
    jmp p1RightBound
    ret

p1sitting:
    cmp player1_y,27d
    je p1platform1
    cmp player1_y,62d
    je p1platform2
    cmp player1_y,92d
    je p1platform1
    cmp player1_y,122d
    je p1platform2
    cmp player1_y,152d
    je p1platform1
    cmp player1_y,182d
    je p1ground

p1RightBound:
    cmp player1_x, 312
    jbe p1LeftBound
    mov CX, player1_x
    sub CX, moveSpeed
    mov player1_x, CX
    
p1LeftBound:
    cmp player1_x, 1
    jnl p1UpperBound
    mov CX, player1_x
    add CX, moveSpeed
    mov player1_x, CX
p1UpperBound:
;player2
cmp player2FallState, 1
jne p2sitting
    cmp player2_y,27d
    je p2platform1
    cmp player2_y,62d
    je p2platform2
    cmp player2_y,92d
    je p2platform1
    cmp player2_y,122d
    je p2platform2
    cmp player2_y,152d
    je p2platform1
    cmp player2_y,182d
    je p2ground

    jmp p2RightBound

    p2platform1:
    mov player2FallState, 1
    cmp player2_x, 87
    jb p2RightBound
    cmp player2_x, 215
    ja p2RightBound
    jmp p2ground

    p2platform2:
    mov player2FallState, 1
    cmp player2_x, 2
    jb p2RightBound
    cmp player2_x, 300
    ja p2RightBound
    cmp player2_x, 90
    jb p2ground
    cmp player2_x, 220
    jb p2RightBound

    p2ground:
    mov player2FallState,0h
    jmp p2RightBound
    ret

p2sitting:
    cmp player2_y,27d
    je p2platform1
    cmp player2_y,62d
    je p2platform2
    cmp player2_y,92d
    je p2platform1
    cmp player2_y,122d
    je p2platform2
    cmp player2_y,152d
    je p2platform1
    cmp player2_y,182d
    je p2ground

p2RightBound:
    cmp player2_x, 312
    jbe p2LeftBound
    mov CX, player2_x
    sub CX, moveSpeed
    mov player2_x, CX

p2LeftBound:
    cmp player2_x, 1
    jnl p2UpperBound
    mov CX, player2_x
    add CX, moveSpeed
    mov player2_x, CX

p2UpperBound:
ret
Level1BoundariesCheck ENDP

;====================================================================================================================================================================================

;-------------------------------------------------------------------------Timers--------------------------------------------------------------------------------------------
;FILLS VARIABLE WITH '$'.
	;USED BEFORE CONVERT NUMBERS TO STRING, BECAUSE
	;THE STRING WILL BE DISPLAYED.
	;PARAMETER : SI = POINTING TO STRING TO FILL.
dollars proc
	               mov           cx, 6
	six_dollars:   
	               mov           bl, '$'
	               mov           [si], bl
	               inc           si
	               loop          six_dollars

	               ret
dollars endp

printTimeMid proc
	;move cursor to top middle of the screen to print the time
	               mov           ah,2
	               mov           dx,0013h
	               int           10h
		
	; display time as a string
	               mov           ah, 9
	               lea           dx, secondsBuffer
	               int           21h

	               ret
printTimeMid endp

number2string proc                                                                           		;time conversion to string not that important
	;FILL BUF WITH DOLLARS.
	               push          si
	               call          dollars
	               pop           si

	               mov           bx, 10                                                          	;DIGITS ARE EXTRACTED DIVIDING BY 10.
	               mov           cx, 0                                                           	;COUNTER FOR EXTRACTED DIGITS.
	cycle1:        
	               mov           dx, 0                                                           	;NECESSARY TO DIVIDE BY BX.
	               div           bx                                                              	;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
	               push          dx                                                              	;PRESERVE DIGIT EXTRACTED FOR LATER.
	               inc           cx                                                              	;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
	               cmp           ax, 0                                                           	;IF NUMBER IS
	               jne           cycle1                                                          	;NOT ZERO, LOOP.
	;NOW RETRIEVE PUSHED DIGITS.
	cycle2:        
	               pop           dx
	               add           dl, 48                                                          	;CONVERT DIGIT TO CHARACTER.
	               mov           [si], dl
	               inc           si
	               loop          cycle2

	               ret
number2string endp
;=======================================================================================================================================================================================================================

;------------------------------------------------------------------------collision-------------------------------------------------------------------------------------------------------------------------------
checkCollision proc
	               mov           ax, player1_x
	               add           ax, player_size
	               cmp           ax, player2_x
	               JNG           exit                                                            	;first condition not satisified, no need to check anymore.

	               mov           ax, player2_x
	               add           ax, player_size
	               cmp           ax, player1_x
	               JNG           exit                                                            	;second condition

	               mov           ax, player1_y
	               add           ax, player_size
	               cmp           ax, player2_y
	               JNG           exit

	               mov           ax, player2_y
	               add           ax, player_size
	               cmp           ax, player1_y
	               JNG           exit

	               cmp           collisionRunning,1                                              	;if the collision timer is already running keep the tag as it is
	               jz            exit
				   
				   mov           collisionRunning,1
	               cmp           tag, 0
	               jz            tag_player2
	               cmp           tag, 1
	               jz            tag_player1
				   
	tag_player1:   
	               mov           tag, 0
				   mov           collisionRunning,1
	               jmp           exit
	tag_player2:   
	               mov           tag, 1
				   mov           collisionRunning,1
	exit:          
	               ret
checkCollision endp
;================================================================================================================================================================
end main 
