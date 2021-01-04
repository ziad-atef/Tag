;-------------------------------------------------------------Drawing level 1 macros---------------------------------------------------------------------------
drawRectangle macro x, y, color, height, width ;x, y are the starting position (top left corner)
    local whilePlatformBeingDrawn
    mov cx,x                        
    mov dx,y                                
    whilePlatformBeingDrawn:
        drawPixel_withoutXY color
        inc cx ;the x-coordinate
        subtractAndCheck cx, x, width ;Keep adding Pixels till Cx-P_x=widthPlatform
        JNG whilePlatformBeingDrawn 
        mov cx, x
        inc dx
        subtractAndCheck dx, y, height
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

subtractAndCheck macro A,B,C ;checks if A-B=C and returns 0 if that's true
push ax
            mov ax,A
            sub ax,B
            cmp ax,C
pop ax
ENDM subtractAndCheck

.286
.model small
.stack 64
.data

    player1_x dw 00d    ;initial x coordinate for player 1
    player1_y dw 182d   ;initial y coordinate for player 1
    player_size dw 7d   ;square area for both players
    player2_x dw 312d   ;initial x coordinate for player 2
    player2_y dw 182d   ;initial y coordinate for player 2
    oldTime db 0        ; a temp variable to keep calculating time correctly 
                        ;where each second is compared to the second preceding it

    X1 db 0             ;current x coordinate of player 1   CHECK
    Y1 db 2             ;current y coordinate of player 1
    X2 db 0              ;current x coordinate of player 2
    Y2 db 2                ;current y coordinate of player 2

	moveSpeed            dw 8d
	gravity              dw 5d

	player1JumpState     db 0
	player2JumpState     db 0
	player1FallState     db 0
	player2FallState     db 0
	player1JumpPos       dw ?
	player2JumpPos       dw ?


	platformsCount       DW 8                                                    	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
	Xpoints              DW 0,95,10,220,95,10,220,95
	Ypoints              DW 190,160,130,130,100,70,70,35
	Pcolors              DB 10,200,200,200,200,200,200,200
	Pwidths              DW 320,120,80,80,120,80,80,120
	Pheights             DW 10,3,3,3,3,3,3,3

	tag                  db 0
	p1_tag_x             dw 3d
	p1_tag_y             dw 177d
	p2_tag_x             dw 315d
	p2_tag_y             dw 177d

	;cheesecake
	;variables for the timer
	compareTemp          db ?                                                    	; a variable which holds the current second at any moment,
	; this is used in order to detect if a second has actually passed or not

	secondsBuffer        db 6 dup (?)                                            	; an array to hold the ascii code of seconds to be printed
	curSec               db 60                                                   	;a variable that has the current value to be printed
	roundTime            db -1d                                                  	;sets the time the user wants to end the round at

	collisionTimer       db 0                                                    	;cur value of the change timer when a collision occurs
	curCollisionSec      db 4                                                    	;starts at the max value we want the collision timer to be, in our case it is 4
	collisionCompareTemp db ?

	collisionRunning     db 0                             	; a variable to keep track of whether the collision timer is already running


    MODE				DB		1					;1 is the mainscreen, 2 is chatting, 3 is game
    ;PLAYER1POS			DB		10 					;Y position of the top of  player 
    ;PLAYER2POS			DB		10 					;Y position of the top of  player 
    ;PLAYERSIZE			DB		?					;HEIGHT OF THE PADDLE
    ;playerspeed			db		5					;speed of the player

    PLAYER1NAME			DB		15,?,15 DUP('$'),'$'
    PLAYER2NAME			DB		15,?,15 DUP('$'),'$'
    P1winsText          DB      'PLAYER 1 WINS$'
    P2winsText          DB      'PLAYER 2 WINS$'

    SERVING				DB		1					;0 is the no one serving, 1 is player 1 is serving, 2 is player 2
    ;player1score		db		30H					;scores are 0 ascii
    ;player2score		db		30H
    recievedchatinv		db		0					;0 for didn't recieve invite, 1 for recieved invite
    recievedgameinv		db		0					;0 for didn't recieve invite, 1 for recieved invite
    readytochat			db		0
    readytogame			db		0
    chatbyte			db		?
    ourcursor			dw		?
    othercursor         dw		?
    ;--------------------------splashscreen strings----------------------------------------;
    SPLASH1				DB		'Enter first player name:$'
    NAME1				DB		'Player 1:$'
    SPLASH2				DB		'Press Enter key to continue$'
    SPLASH3	    		DB		'Enter second player name:$'
    NAME2				DB		'Player 2:$'		;not used in phase 3
    SPLASH4				DB		'Press Enter key to continue$'

    ;SPLASH3				DB		'WAITING FOR THE OTHER USER TO ENTER NAME...$'
    ;--------------------------------------------------------------------------------------;


    ;---------------------------gamemode strings-----------------------------------------;
    PAUSEDSTRING		DB		'Game is paused$'
    PAUSEDSPACE			DB		'Press SPACE to continue ',01H,'$'
    PAUSEDESCAPE		DB		'Press ESC to quit to main menu$'
    ESCTOPAUSE			DB		'Press ESC to pause the game$'

    SCORE				DB		"'s score:$"
    PLAYERWONSTRING		DB		' WINS!!!!!!!!!!!$'
    WONESC				DB		'Press ESC to exit the game$'
    WONSPACE            DB		'Press SPACE to go to main menu$'
    ;--------------------------------------------------------------------------------------;

    ;---------------------------mainscreen strings-----------------------------------------;
    MAINSCREEN1			DB		'->To start chatting press F1$'
    MAINSCREEN2			DB		'->To start TAG game press F2$'
    MAINSCREEN3			DB		'->To exit the game press ESC$'
    MAINSCREEN7			DB		'PLEASE WAIT WHILE THE OTHER USER SELECTS THE LEVEL$'
    ;--------------------------------------------------------------------------------------;

    ;---------------------------chat strings-----------------------------------------;
    MAINSCREEN4			DB		'GAME$'
    MAINSCREEN5			DB		'CHAT$'
    MAINSCREEN6			DB		'->To exit the game press ESC$'
    CHATEXIT			DB		'TO EXIT CHAT PRESS EXIT$'
    ;--------------------------------------------------------------------------------------;



                                                    ;the includes are here so that they can work with the datasegment
    ;INCLUDE GUI.INC									;contains some general purpose functions that could be used
    ;INCLUDE MENUGUI.INC								;responsible for drawing all main menu
    ;INCLUDE MENUIN.INC								;responsible for getting the input in the main menu mode
    ;INCLUDE GAMEGUI.INC			
    ;INCLUDE GAMEIN.INC			
    ;INCLUDE CHAT.INC

            
.code

main proc far
	                      mov           ax,@data
	                      mov           ds,ax

	                      call          getusername
	                      call          mainscreenui
	                      call          menuinput

	                      graphicsMode  13h

	                      mov           ah,0Bh
	                      mov           bh,00h
	                      mov           bl,00h
	                      int           10h
    
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
	                      je            time                                                            	;keeps repeating the loop until a change has occured,
	;now it is known that a second has actually passed
	                      mov           collisionCompareTemp, dh                                        	; if a second has passed move this current sec to the temp variable
	; to keep comparing with the upcoming seconds
	               

	                      mov           bh,collisionTimer
	                      dec           curCollisionSec
	                      cmp           curCollisionSec,bh                                              	;if the collision timer has reached zero we want to reset the timer
	;else keep going with the code
	                      jnz           time
	;if the colision timer reaches zero we will reset the timer

	                      mov           curCollisionSec,4                                               	;this code block is responsible for resetting the timer
	                      mov           bh,0
	                      mov           collisionRunning,0

	time:                 
    
	                      call          drawLevel1
	                      call          draw_player1
	                      call          draw_player2
	                      call          printTimeMid
	                      call          writePlayerNames

	                      mov           ah,2ch
	                      int           21h
	                      cmp           dl,oldTime
	                      je            time
	                      mov           oldTime,dl
    
	                      call          KeyClick
	                      call          Move
	                      call          PlayerStatus
	                      call          Level1BoundariesCheck
	                      call          checkCollision
	                      colorScreen   80
    
	                      jmp           display_time
	exitLoop:             


        call drawLevel1
        mov ah,0
        mov al,3
        int 10h

        mov ah,2          		;Move Cursor to upper middle of screen
		mov dx,0031d     		
		int 10h 

	                      cmp           tag,0
	                      je            player2win
	                      mov           ah,9
	                      mov           dx,offset P1winsText
	                      int           21h
	                      jmp           nameWritten

	player2win:           
	                      mov           ah,9
	                      mov           dx,offset P2winsText
	                      int           21h

	;mov ax,4c00h
	;int 21h
    
	nameWritten:          int           20h
main endp

getusername proc
		
	; Graphic mode
	                      mov           ax, 0eh
	                      int           10h
		
	                      call          clearinputbuffer
		
	                      mov           ah,2                                                            	;Move Cursor to upper middle of screen
	                      mov           dx,0A1Dh
	                      int           10h
		
	                      mov           ah, 9                                                           	;Display 'Please enter your name:'
	                      mov           dx, offset SPLASH1
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor to lower middle of screen
	                      mov           dx,0E1Dh
	                      int           10h

	                      mov           ah, 9                                                           	;Display 'press enter to continue'
	                      mov           dx, offset SPLASH2
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor, to middle of screen
	                      mov           dx,0C1Dh
	                      int           10h
		
	                      mov           ah, 9                                                           	;Display 'Player 1:'
	                      mov           dx, offset NAME1
	                      int           21h
		
	emptyname1:           
	                      mov           ah,0AH                                                          	;Read name from keyboard
	                      mov           dx,offset PLAYER1NAME
	                      int           21h
	                      cmp           player1name+1,0
	                      je            emptyname1

	                      call          clearinputbuffer
		
	                      mov           ah,2                                                            	;Move Cursor to upper middle of screen
	                      mov           dx,0A1Dh
	                      int           10h
		
	                      mov           ah, 9                                                           	;Display 'Please enter your name:'
	                      mov           dx, offset SPLASH3
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor to lower middle of screen
	                      mov           dx,0E1Dh
	                      int           10h

	                      mov           ah, 9                                                           	;Display 'press enter to continue'
	                      mov           dx, offset SPLASH4
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor, to middle of screen
	                      mov           dx,0C1Dh
	                      int           10h
		
	                      mov           ah, 9                                                           	;Display 'Player 1:'
	                      mov           dx, offset NAME2
	                      int           21h
		
	emptyname2:           
	                      mov           ah,0AH                                                          	;Read name from keyboard
	                      mov           dx,offset PLAYER2NAME
	                      int           21h
	                      cmp           player2name+1,0
	                      je            emptyname2
		
	;call exchangenames
			
	                      ret
getusername endp

clearinputbuffer proc
		
	                      mov           al,0
	                      mov           ah,0CH
	                      int           21h                                                             	;this clears the buffer, then moves al to ah and executes the int 21h again only if al=1,6,7,8,0AH

	                      ret
clearinputbuffer endp

mainscreenui proc
		
	; mov recievedchatinv,0
	; mov recievedgameinv,0
	                      call          writetext
	                      call          drawnotification
	                      ret
mainscreenui endp

writetext proc

	                      mov           serving,1                                                       	;each time the user goes to the main menu, serving should be set to player 1
		
	                      MOV           AH,0                                                            	;CHANGE TO GRAPHICS MODE, THIS CLEARS THE SCREEN
	                      MOV           AL,0EH                                                          	;640x200 pixels and 80x25 text but only 16 colors, al=13h 320x200 and 256 colors
	                      INT           10H
		
	                      mov           bh,0
	                      mov           ah,2                                                            	;Move Cursor to upper middle of screen
	                      mov           dx,0A1Ah
	                      int           10h
		
	                      mov           ah, 9                                                           	;Display 'To start chatting press f1'
	                      mov           dx, offset mainscreen1
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor to lower middle of screen
	                      mov           dx,0C1Ah
	                      int           10h

	                      mov           ah, 9                                                           	;Display 'To start Pong game press F2'
	                      mov           dx, offset mainscreen2
	                      int           21h
		
	                      mov           ah,2                                                            	;Move Cursor, to middle of screen
	                      mov           dx,0E1Ah
	                      int           10h
		
	                      mov           ah,9                                                            	;Display 'To end the program press ESC'
	                      mov           dx,offset mainscreen3
	                      int           21h
		
	                      ret
writetext endp

showwaitmessage proc
		
	                      MOV           AH,0                                                            	;CHANGE TO GRAPHICS MODE, THIS CLEARS THE SCREEN
	                      MOV           AL,0EH                                                          	;640x200 pixels and 80x25 text but only 16 colors, al=13h 320x200 and 256 colors
	                      INT           10H
		
	                      mov           ah,2                                                            	;Move Cursor to lower middle of screen
	                      mov           dx,0C0Ch
	                      int           10h

	                      mov           ah, 9                                                           	;Display 'To start Pong game press F2'
	                      mov           dx, offset MAINSCREEN7
	                      int           21h
		
	                      ret
showwaitmessage endp

drawnotification proc
		
	                      mov           bh,00
	                      mov           AH,0CH                                                          	;draw pixel int condition
	                      mov           al,09h                                                          	;set the purple colour
	                      mov           dx,166
		
	menu1:                
	                      mov           cx,04
	menu2:                
	                      int           10h
	                      inc           cx
	                      cmp           cx,636
	                      jne           menu2
	                      inc           dx
	                      cmp           dx,167
	                      jne           menu1
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1615h                                                        	;a5er el screen
	                      int           10h
		
	                      mov           ah,09
	                      mov           dx,offset PLAYER1NAME+2
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1615h                                                        	;a5er el screen
	                      add           dl,player1name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      int           10h
		
	                      mov           ah,09
	                      mov           dx,offset PLAYER2NAME+2
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      add           dl,player2name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      add           dl,player2name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      add           dl,player2name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      add           dl,player2name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1815h                                                        	;a5er el screen
	                      add           dl,player2name+1                                                	;add playername length
	                      int           10h
		
	                      mov           ah,02
	                      mov           dl, 3AH                                                         	;then write the score after adding all that
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1526h                                                        	;a5er el screen
	                      int           10h
		
	                      mov           ah,09
	                      mov           dx,offset MAINSCREEN4
	                      int           21h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1535h                                                        	;a5er el screen
	                      int           10h
		
	                      mov           ah,09
	                      mov           dx,offset MAINSCREEN5
	                      int           21h
		
	                      call          drawindicators
		
	                      ret
drawnotification endp

drawindicators proc
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1628h                                                        	;a5er el screen
	                      int           10h
		
	                      cmp           readytogame,0
	                      je            notrgame
	                      mov           bl,02h
	                      jmp           d1
	notrgame:             
	                      mov           bl,004h                                                         	;red on black background
	d1:                   
	                      mov           ah,9                                                            	;int condition
	                      mov           bh,0                                                            	;page number
	                      mov           al,04H                                                          	;arrow sign
	                      mov           cx,1H                                                           	;1 time
	                      int           10h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1837h                                                        	;a5er el screen
	                      int           10h
		
	                      cmp           recievedchatinv,0
	                      je            notrecchat
	                      mov           bl,02h
	                      jmp           d2
	notrecchat:           
	                      mov           bl,004h                                                         	;red on black background
	d2:                   
	                      mov           ah,9                                                            	;int condition
	                      mov           bh,0                                                            	;page number
	                      mov           al,04H                                                          	;arrow sign
	                      mov           cx,1H                                                           	;1 time
	                      int           10h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1828h                                                        	;a5er el screen
	                      int           10h
		
	                      cmp           recievedgameinv,0
	                      je            notrecgame
	                      mov           bl,02h
	                      jmp           d3
	notrecgame:           
	                      mov           bl,004h                                                         	;red on black background
	d3:                   
	                      mov           ah,9                                                            	;int condition
	                      mov           bh,0                                                            	;page number
	                      mov           al,04H                                                          	;arrow sign
	                      mov           cx,1H                                                           	;1 time
	                      int           10h
		
	                      mov           ah,2                                                            	;move cursor at desired destination
	                      mov           bh,0
	                      mov           dx,1637h                                                        	;a5er el screen
	                      int           10h
		
	                      cmp           readytochat,0
	                      je            notrchat
	                      mov           bl,02h
	                      jmp           d4
	notrchat:             
	                      mov           bl,004h                                                         	;red on black background
	d4:                   
	                      mov           al,04H                                                          	;arrow sign
	                      mov           ah,9                                                            	;int condition
	                      mov           bh,0                                                            	;page number
	                      mov           cx,1H                                                           	;1 time
	                      int           10h
		
		
	                      ret
drawindicators endp

resetindicators proc
		
	                      mov           recievedchatinv,0
	                      mov           recievedgameinv,0
	                      mov           readytochat,0
	                      mov           readytogame,0
		
	                      ret
resetindicators endp

menuinput proc
		
	check:                
	                      mov           ah,1                                                            	;get key input
	                      int           16h
	                      jz            check
		
	                      cmp           ah,3bh                                                          	;cmp with f1
	;jz f1
	                      je            escape

	                      cmp           ah,3ch                                                          	;cmp with f2
	                      je            f2
		
	                      cmp           ah,01h                                                          	;cmp with esc
	                      je            escape
		
	f1:                                                                                                 	;chat mode is chosen
	                      call          clearinputbuffer
	;call sendchatinv
	;call checkchatinv
	;PUT CODE HERE TO CLEAR THE SCREEN AND CHOOSE SUITABLE VIDEO MODE FOR CHAT
	                      ret
		
	f2:                                                                                                 	;game mode is chosen
	                      call          clearinputbuffer
		
	                      MOV           AH,0
	;MOV AL,0EH			;this is here just to clear the screen from the text of main menu
	                      INT           10H
	                      ret
		
	escape:               
	                      call          outro
	                      ret
menuinput endp

outro proc
		
	; call drawoutro
	; call introsound
		
	                      mov           ah,0                                                            	;change to text mode
	                      mov           al,03h
	                      int           10h
		
	                      mov           ax,4c00h
	                      int           21h
	                      ret
outro ENDP

	;-------------------------------------------------------------------Moving player Procedures--------------------------------------------------------------------------------

Move PROC
	;player1
	                      cmp           X1, 1
	                      jne           left1
	                      mov           CX, player1_x
	                      add           CX, moveSpeed
	                      mov           player1_x, CX
	                      jmp           up1

	left1:                
	                      cmp           X1, 2
	                      jne           up1
	                      mov           CX, player1_x
	                      sub           CX, moveSpeed
	                      mov           player1_x, CX
	                      jmp           up1

	up1:                  
	                      cmp           Y1, 1
	                      jne           player2
	                      mov           Y1, 2
	                      cmp           player1JumpState, 1
	                      je            player2
	                      cmp           player1FallState, 1
	                      je            player2
	                      mov           player1JumpState, 1
	                      mov           CX, player1_y
	                      sub           CX, 40
	                      mov           player1JumpPos, CX

	player2:              
	                      cmp           X2, 1
	                      jne           left2
	                      mov           CX, player2_x
	                      add           CX, moveSpeed
	                      mov           player2_x, CX
	                      jmp           up2

	left2:                
	                      cmp           X2, 2
	                      jne           up2
	                      mov           CX, player2_x
	                      sub           CX, moveSpeed
	                      mov           player2_x, CX
	                      jmp           up2

	up2:                  
	                      cmp           Y2, 1
	                      jne           EndMove
	                      mov           Y2, 2
	                      cmp           player2JumpState, 1
	                      je            EndMove
	                      cmp           player2FallState, 1
	                      je            EndMove
	                      mov           player2JumpState, 1
	                      mov           CX, player2_y
	                      sub           CX, 40
	                      mov           player2JumpPos, CX
	EndMove:              
	                      ret
Move ENDP

PlayerStatus PROC
	;player1ascend
	                      cmp           player1JumpState, 1
	                      jne           player1descend
	                      mov           CX, player1_y
	                      sub           CX, gravity
	                      mov           player1_y, CX
	                      cmp           CX, player1JumpPos
	                      ja            player2ascend
	                      mov           player1JumpState, 0
	                      mov           player1FallState, 1
	                      jmp           player2ascend

	player1descend:       
	                      cmp           player1FallState, 1
	                      jne           player2ascend
	                      mov           CX, player1_y
	                      add           CX, gravity
	                      mov           player1_y, CX

	player2ascend:        
	                      cmp           player2JumpState, 1
	                      jne           player2descend
	                      mov           CX, player2_y
	                      sub           CX, gravity
	                      mov           player2_y, CX
	                      cmp           CX, player2JumpPos
	                      ja            player2ascend
	                      mov           player2JumpState, 0
	                      mov           player2FallState, 1
	                      ret

	player2descend:       
	                      cmp           player2FallState, 1
	                      jne           EndPlayerStatus
	                      mov           CX, player2_y
	                      add           CX, gravity
	                      mov           player2_y, CX

	EndPlayerStatus:      
	                      ret
PlayerStatus ENDP

KeyClick PROC

	                      mov           SI, 4
	last4clicks:          

	                      mov           ah,1
	                      int           16H

	                      jz            endPress

	                      mov           ah,0
	                      int           16H

	                      call          KeyAction
    
	                      dec           SI
	                      cmp           SI,0
	                      jnz           last4clicks

	                      RET

	endPress:             
	                      RET
KeyClick ENDP

KeyAction PROC

	;PLAYER 2 KEYS
	                      CMP           AH, 72                                                          	;UP
	                      JE            player2up

	                      CMP           AH, 75                                                          	;LEFT
	                      JE            player2left

	                      CMP           AH, 77                                                          	;RIGHT
	                      JE            player2right
        
	                      cmp           AH, 80                                                          	;DOWN
	                      JE            player2down

	;PLAYER 1 KEYS
	                      CMP           AL, 77H
	                      JE            player1up                                                       	; w
	                      CMP           AL, 57H
	                      JE            player1up                                                       	; W

	                      CMP           AL, 61H
	                      JE            player1left                                                     	; a
	                      CMP           AL, 41H
	                      JE            player1left                                                     	; A

	                      CMP           AL, 64H
	                      JE            player1right                                                    	; d
	                      CMP           AL, 44H
	                      JE            player1right                                                    	; D

	                      CMP           AL, 53H
	                      JE            player1down                                                     	;S
	                      CMP           AL, 73H
	                      JE            player1down                                                     	;s

	                      RET


	;PLAYER 2 ACTIONS
	player2up:            
	                      MOV           Y2, 1
	                      RET

	player2right:                                                                                       	;set player direction to up
	                      MOV           X2, 1                                                           	;1 MEANS GO RIGHT
	                      RET
        
	player2left:          
	                      MOV           X2, 2                                                           	;2 MEANS GO LEFT
	                      RET

	player2down:          
	                      MOV           X2, 0
	                      MOV           Y2, 2

	;PLAYER 1 ACTIONS
	player1up:            
	                      MOV           Y1, 1
	                      RET
        
	player1right:         
	                      MOV           X1, 1
	                      RET
            
	player1left:          
	                      MOV           X1, 2
	                      RET
        
	player1down:          
	                      MOV           X1, 0
	                      MOV           Y1, 2
	END_KEY_ACTIONS:      

	                      RET
KeyAction ENDP

	;============================================================================================================================================================================

	;-------------------------------------------------------------------Players Drawing Procedures----------------------------------------------------------------------------------

draw_player1 proc
	                      mov           cx,player1_x
	                      mov           dx,player1_y
	draw:                 
	                      mov           ah,0ch
	                      mov           al,06h                                                          	; color of player 1 is brown
	                      mov           bh,00h
	                      int           10h
	                      inc           cx
	                      mov           ax,cx
	                      sub           ax,player1_x
	                      cmp           ax,player_size
	                      jng           draw
	                      mov           cx,player1_x
	                      inc           dx
	                      mov           ax,dx
	                      sub           ax,player1_y
	                      cmp           ax,player_size
	                      jng           draw
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
	                      mov           cx,player2_x
	                      mov           dx,player2_y
	draw1:                
	                      mov           ah,0ch
	                      mov           al,09h                                                          	;color of player 2 is blue
	                      mov           bh,00h
	                      int           10h
	                      inc           cx
	                      mov           ax,cx
	                      sub           ax,player2_x
	                      cmp           ax,player_size
	                      jng           draw1
	                      mov           cx,player2_x
	                      inc           dx
	                      mov           ax,dx
	                      sub           ax,player2_y
	                      cmp           ax,player_size
	                      jng           draw1
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
	                      MOV           SI,0000h                                                        	;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
	                      MOV           DI,0000h                                                        	;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
	                      MOV           BX,platformsCount
	                      ADD           BX,BX
	DrawPlatforms:        
	                      drawRectangle Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]
	                      inc           DI
	                      add           SI,2
	                      CMP           SI,BX
	                      JNZ           DrawPlatforms

	                      ret
drawLevel1 endp

	;================================================================================================================================================================================

	;--------------------------------------------------------------------Level1 Boundaries Check-------------------------------------------------------------------------------------

Level1BoundariesCheck PROC
	;player1
	                      cmp           player1FallState, 1
	                      jne           p1sitting
	                      cmp           player1_y,27d
	                      je            p1platform1
	                      cmp           player1_y,62d
	                      je            p1platform2
	                      cmp           player1_y,92d
	                      je            p1platform1
	                      cmp           player1_y,122d
	                      je            p1platform2
	                      cmp           player1_y,152d
	                      je            p1platform1
	                      cmp           player1_y,182d
	                      je            p1ground

	                      jmp           p1RightBound

	p1platform1:          
	                      mov           player1FallState, 1
	                      cmp           player1_x, 87
	                      jb            p1RightBound
	                      cmp           player1_x, 215
	                      ja            p1RightBound
	                      jmp           p1ground

	p1platform2:          
	                      mov           player1FallState, 1
	                      cmp           player1_x, 2
	                      jb            p1RightBound
	                      cmp           player1_x, 300
	                      ja            p1RightBound
	                      cmp           player1_x, 90
	                      jb            p1ground
	                      cmp           player1_x, 220
	                      jb            p1RightBound

	p1ground:             
	                      mov           player1FallState,0h
	                      jmp           p1RightBound
	                      ret

	p1sitting:            
	                      cmp           player1_y,27d
	                      je            p1platform1
	                      cmp           player1_y,62d
	                      je            p1platform2
	                      cmp           player1_y,92d
	                      je            p1platform1
	                      cmp           player1_y,122d
	                      je            p1platform2
	                      cmp           player1_y,152d
	                      je            p1platform1
	                      cmp           player1_y,182d
	                      je            p1ground

	p1RightBound:         
	                      cmp           player1_x, 312
	                      jbe           p1LeftBound
	                      mov           CX, player1_x
	                      sub           CX, moveSpeed
	                      mov           player1_x, CX
    
	p1LeftBound:          
	                      cmp           player1_x, 1
	                      jnl           p1UpperBound
	                      mov           CX, player1_x
	                      add           CX, moveSpeed
	                      mov           player1_x, CX
	p1UpperBound:         
	;player2
	                      cmp           player2FallState, 1
	                      jne           p2sitting
	                      cmp           player2_y,27d
	                      je            p2platform1
	                      cmp           player2_y,62d
	                      je            p2platform2
	                      cmp           player2_y,92d
	                      je            p2platform1
	                      cmp           player2_y,122d
	                      je            p2platform2
	                      cmp           player2_y,152d
	                      je            p2platform1
	                      cmp           player2_y,182d
	                      je            p2ground

	                      jmp           p2RightBound

	p2platform1:          
	                      mov           player2FallState, 1
	                      cmp           player2_x, 87
	                      jb            p2RightBound
	                      cmp           player2_x, 215
	                      ja            p2RightBound
	                      jmp           p2ground

	p2platform2:          
	                      mov           player2FallState, 1
	                      cmp           player2_x, 2
	                      jb            p2RightBound
	                      cmp           player2_x, 300
	                      ja            p2RightBound
	                      cmp           player2_x, 90
	                      jb            p2ground
	                      cmp           player2_x, 220
	                      jb            p2RightBound

	p2ground:             
	                      mov           player2FallState,0h
	                      jmp           p2RightBound
	                      ret

	p2sitting:            
	                      cmp           player2_y,27d
	                      je            p2platform1
	                      cmp           player2_y,62d
	                      je            p2platform2
	                      cmp           player2_y,92d
	                      je            p2platform1
	                      cmp           player2_y,122d
	                      je            p2platform2
	                      cmp           player2_y,152d
	                      je            p2platform1
	                      cmp           player2_y,182d
	                      je            p2ground

	p2RightBound:         
	                      cmp           player2_x, 312
	                      jbe           p2LeftBound
	                      mov           CX, player2_x
	                      sub           CX, moveSpeed
	                      mov           player2_x, CX

	p2LeftBound:          
	                      cmp           player2_x, 1
	                      jnl           p2UpperBound
	                      mov           CX, player2_x
	                      add           CX, moveSpeed
	                      mov           player2_x, CX

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


;this proc is a more generalized code for the exercise in sheet3 where we output an integer as a string
;original code and idea is credited to https://stackoverflow.com/questions/44374434/display-timer-on-screen-in-assembly-masm-8086
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

writePlayerNames proc
    
	                      pusha

	                      mov           ah,2
	                      mov           dx,0000h
	;move cursor to beginning of the screeen

	                      mov           SI, offset PLAYER1NAME+2
    

writePlayer1:
    int 10h
    mov al,[SI]
    cmp al,13
    je player2cursor ;checks if the current char is a dollar sign, if not continue printing the name

    mov  ah, 9
    mov  bh, 0
    mov  bl, 06h  ;brown
    mov  cx, 1  
    int  10h
    add SI,1
    add dl,1
    mov ah,2
    jmp writeplayer1

player2cursor:
    
    mov ah,2
    mov dx,0040d
    sub dl,PLAYER2NAME+1
    mov SI,offset PLAYER2NAME+2

writePlayer2:   
    int 10h
    
	                      mov           al,[SI]
	                      cmp           al,13
	                      je            done
	                      mov           ah, 9
	                      mov           bh, 0
	                      mov           bl, 09h                                                         	;blue
	                      mov           cx, 1
	                      int           10h
	                      add           SI,1
	                      add           dl,1
	                      mov           ah,2
	                      jmp           writePlayer2


	done:                 popa
	                      ret
writePlayerNames endp

;================================================================================================================================================================
end main 