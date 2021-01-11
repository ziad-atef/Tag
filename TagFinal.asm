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

Initialize macro
mov player1_x, 00d
mov player1_y, 182d
mov player2_x, 312d
mov player2_y, 182d
mov oldTime,0
mov X1, 0
mov Y1, 2
mov X2, 0
mov Y2, 2
mov player1JumpState, 0
mov player2JumpState, 0
mov player1FallState, 0
mov player2FallState, 0
mov EndRound, 0
mov curSec, 60
ENDM Initialize
.286
.model small
.stack 64
.data
	User                 DB 15,?,15 DUP('$'),'$'
	OtherUser            DB 15,?,15 DUP('$'),'$'
    
	OtherNameEntered     DB 0

	otherNameRecieved    DB 0
	NameSent             DB 0

	SentChatInvite       DB 0
	ReceivedChatInvite   DB 0

	SentGameInvite       DB 0
	RecievedGameinvite   DB 0

	ChatMode             DB 0
	GameMode             Db 0

	VALUE                db ?

    player1coordinates db -1,0	;x,y
    player2coordinates  db  -1,13
	endChat	db	0

	isPlayer1            db 0
	player1key           db 0
	player2key           db 0
	player1_x            dw 00d                                                  	;initial x coordinate for player 1
	player1_y            dw 182d                                                 	;initial y coordinate for player 1
	player_size          dw 7d                                                   	;square area for both players
	player2_x            dw 312d                                                 	;initial x coordinate for player 2
	player2_y            dw 182d                                                 	;initial y coordinate for player 2
	oldTime              db 0                                                    	; a temp variable to keep calculating time correctly
	;where each second is compared to the second preceding it

	X1                   db 0                                                    	;current x coordinate of player 1   CHECK
	Y1                   db 2                                                    	;current y coordinate of player 1
	X2                   db 0                                                    	;current x coordinate of player 2
	Y2                   db 2                                                    	;current y coordinate of player 2

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

	EndRound             db 0
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

	collisionRunning     db 0                                                    	; a variable to keep track of whether the collision timer is already running


	MODE                 DB 1                                                    	;1 is the mainscreen, 2 is chatting, 3 is game
	;PLAYER1POS			DB		10 					;Y position of the top of  player
	;PLAYER2POS			DB		10 					;Y position of the top of  player
	;PLAYERSIZE			DB		?					;HEIGHT OF THE PADDLE
	;playerspeed			db		5					;speed of the player

	PLAYER1NAME          DB 15,?,15 DUP('$'),'$'
	PLAYER2NAME          DB 15,?,15 DUP('$'),'$'
	P1winsText           DB 'PLAYER 1 WINS$'
	P2winsText           DB 'PLAYER 2 WINS$'

	SERVING              DB 1                                                    	;0 is the no one serving, 1 is player 1 is serving, 2 is player 2
	;player1score		db		30H					;scores are 0 ascii
	;player2score		db		30H
	recievedchatinv      db 0                                                    	;0 for didn't recieve invite, 1 for recieved invite
	recievedgameinv      db 0                                                    	;0 for didn't recieve invite, 1 for recieved invite
	readytochat          db 0
	readytogame          db 0
	chatbyte             db ?
	ourcursor            dw ?
	othercursor          dw ?
	;--------------------------splashscreen strings----------------------------------------;
	SPLASH1              DB 'Enter your name:$'
	NAME1                DB 'Name:$'
	SPLASH2              DB 'Press Enter key to continue$'
	SPLASH3              DB 'Enter second player name:$'
	NAME2                DB 'Player 2:$'                                         	;not used in phase 3
	SPLASH4              DB 'Press Enter key to continue$'

	;SPLASH3				DB		'WAITING FOR THE OTHER USER TO ENTER NAME...$'
	;--------------------------------------------------------------------------------------;


	;---------------------------gamemode strings-----------------------------------------;
	PAUSEDSTRING         DB 'Game is paused$'
	PAUSEDSPACE          DB 'Press SPACE to continue ',01H,'$'
	PAUSEDESCAPE         DB 'Press ESC to quit to main menu$'
	ESCTOPAUSE           DB 'Press ESC to pause the game$'

	SCORE                DB "'s score:$"
	PLAYERWONSTRING      DB ' WINS!!!!!!!!!!!$'
	WONESC               DB 'Press ESC to exit the game$'
	WONSPACE             DB 'Press SPACE to go to main menu$'
	;--------------------------------------------------------------------------------------;

	;---------------------------mainscreen strings-----------------------------------------;
	MAINSCREEN1          DB '->To start chatting press F1$'
	MAINSCREEN2          DB '->To start TAG game press F2$'
	MAINSCREEN3          DB '->To exit the game press ESC$'
	MAINSCREEN7          DB 'PLEASE WAIT WHILE THE OTHER USER SELECTS THE LEVEL$'
	;--------------------------------------------------------------------------------------;

	;---------------------------chat strings-----------------------------------------;
	MAINSCREEN4          DB 'GAME$'
	MAINSCREEN5          DB 'CHAT$'
	MAINSCREEN6          DB '->To exit the game press ESC$'
	CHATEXIT             DB 'TO EXIT CHAT PRESS EXIT$'
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
	                   mov        ax,@data
	                   mov        ds,ax
	                   call       initializeUART
	                   call       getusername
	start:             
	                   Initialize
	                   call       mainscreenui
	                   call       menuinput

                        cmp ChatMode ,1
                        je ChatModeLabel  

                        CMP GameMode,1
                        je GameModeLabel

                        jmp start
    ChatModeLabel:

    GameModeLabel:

main endp

initializeUART proc
	;	Set Divisor Latch Access Bit
	                   mov        dx,3fbh               	; Line Control Register
	                   mov        al,10000000b          	;Set Divisor Latch Access Bit
	                   out        dx,al                 	;Out it

	;	Set LSB byte of the Baud Rate Divisor Latch register.
	                   mov        dx,3f8h
	                   mov        al,0ch
	                   out        dx,al

	;	Set MSB byte of the Baud Rate Divisor Latch register.
	                   mov        dx,3f9h
	                   mov        al,00h
	                   out        dx,al

	;	Set port configuration
	                   mov        dx,3fbh
	                   mov        al,00011011b
	                   out        dx,al
	                   ret
initializeUART ENDP

getusername proc
		
	; Graphic mode
	                   mov        ax, 0eh
	                   int        10h
		
	                   call       clearinputbuffer
		
	                   mov        ah,2                  	;Move Cursor to upper middle of screen
	                   mov        dx,0A1Dh
	                   int        10h
		
	                   mov        ah, 9                 	;Display 'Please enter your name:'
	                   mov        dx, offset SPLASH1
	                   int        21h
		
	                   mov        ah,2                  	;Move Cursor to lower middle of screen
	                   mov        dx,0E1Dh
	                   int        10h

	                   mov        ah, 9                 	;Display 'press enter to continue'
	                   mov        dx, offset SPLASH2
	                   int        21h
		
	                   mov        ah,2                  	;Move Cursor, to middle of screen
	                   mov        dx,0C1Dh
	                   int        10h
		
	                   mov        ah, 9                 	;Display 'Player 1:'
	                   mov        dx, offset NAME1
	                   int        21h
		
	emptyname1:        
	                   mov        ah,0AH                	;Read name from keyboard
	                   mov        dx,offset user
	                   int        21h
	                   cmp        user+1,0
	                   je         emptyname1
	                   call       clearinputbuffer
                          
	                   lea        si , user
	                   add        si , 2
	                   lea        di , OtherUser
	                   add        di , 2
	CHK:               
	                   mov        dx , 3FDH             	; Line Status Register
	                   In         al , dx               	;Read Line Status
	                   test       al , 00100000b
	                   JZ         receive1
	                   mov        dx , 3F8H             	; Transmit data register
	                   mov        al,1
	                   out        dx , al
	receive1:          
	                   mov        dx , 3FDH             	; Line Status Register
	                   in         al , dx
	                   test       al , 1
	                   JZ         CHK                   	;Not Ready (This line may need to change)
	;If Ready read the VALUE in Receive data register
	                   mov        dx , 03F8H
	                   in         al , dx
	                   cmp        al , 1
	                   jne        CHK

	ExchangeNames:     
	                   cmp        NameSent  , 1
	                   je         receiveName
	                   mov        dx , 3FDH             	; Line Status Register
	                   In         al , dx               	;Read Line Status
	                   test       al , 00100000b
	                   JZ         receiveName
                          

                        
	;If empty put the VALUE in Transmit data register
	                   mov        dx , 3F8H             	; Transmit data register
	                   mov        al,[si]
	                   out        dx , al
	                   inc        si
	                   inc        [User+1]
	                   cmp        [si], '$'
	                   jne        receiveName
	                   mov        NameSent , 1

	receiveName:       
	                   cmp        otherNameRecieved , 1
	                   je         CheckEndExchange

	                   mov        dx , 3FDH             	; Line Status Register
	                   in         al , dx
	                   test       al , 1
	                   JZ         CheckEndExchange

	                   mov        dx , 03F8H
	                   in         al , dx
	                   cmp        al , '$'
	                   je         EndRecieve

	                   mov        [di], al
	                   inc        di
	                   inc        [OtherUser+1]
	                   jmp        CheckEndExchange

	EndRecieve:        
	                   mov        otherNameRecieved , 1

	CheckEndExchange:  

	                   cmp        NameSent , 1
	                   jne        ExchangeNames

	                   cmp        otherNameRecieved , 1

	                   jne        ExchangeNames

	                   ret
getusername endp

clearinputbuffer proc
		
	                   mov        al,0
	                   mov        ah,0CH
	                   int        21h                   	;this clears the buffer, then moves al to ah and executes the int 21h again only if al=1,6,7,8,0AH

	                   ret
clearinputbuffer endp

mainscreenui proc
		
	; mov recievedchatinv,0
	; mov recievedgameinv,0
	                   call       writetext
	                   call       drawnotification
	                   ret
mainscreenui endp

writetext proc

	                   mov        serving,1             	;each time the user goes to the main menu, serving should be set to player 1
		
	                   MOV        AH,0                  	;CHANGE TO GRAPHICS MODE, THIS CLEARS THE SCREEN
	                   MOV        AL,0EH                	;640x200 pixels and 80x25 text but only 16 colors, al=13h 320x200 and 256 colors
	                   INT        10H
		
	                   mov        bh,0
	                   mov        ah,2                  	;Move Cursor to upper middle of screen
	                   mov        dx,0A1Ah
	                   int        10h
		
	                   mov        ah, 9                 	;Display 'To start chatting press f1'
	                   mov        dx, offset mainscreen1
	                   int        21h
		
	                   mov        ah,2                  	;Move Cursor to lower middle of screen
	                   mov        dx,0C1Ah
	                   int        10h

	                   mov        ah, 9                 	;Display 'To start Pong game press F2'
	                   mov        dx, offset mainscreen2
	                   int        21h
		
	                   mov        ah,2                  	;Move Cursor, to middle of screen
	                   mov        dx,0E1Ah
	                   int        10h
		
	                   mov        ah,9                  	;Display 'To end the program press ESC'
	                   mov        dx,offset mainscreen3
	                   int        21h
		
	                   ret
writetext endp

showwaitmessage proc
		
	                   MOV        AH,0                  	;CHANGE TO GRAPHICS MODE, THIS CLEARS THE SCREEN
	                   MOV        AL,0EH                	;640x200 pixels and 80x25 text but only 16 colors, al=13h 320x200 and 256 colors
	                   INT        10H
		
	                   mov        ah,2                  	;Move Cursor to lower middle of screen
	                   mov        dx,0C0Ch
	                   int        10h

	                   mov        ah, 9                 	;Display 'To start Pong game press F2'
	                   mov        dx, offset MAINSCREEN7
	                   int        21h
		
	                   ret
showwaitmessage endp

drawnotification proc
		
	                   mov        bh,00
	                   mov        AH,0CH                	;draw pixel int condition
	                   mov        al,09h                	;set the purple colour
	                   mov        dx,166
		
	menu1:             
	                   mov        cx,04
	menu2:             
	                   int        10h
	                   inc        cx
	                   cmp        cx,636
	                   jne        menu2
	                   inc        dx
	                   cmp        dx,167
	                   jne        menu1
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1615h              	;a5er el screen
	                   int        10h
		
	                   mov        ah,09
	                   mov        dx,offset user+2
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1615h              	;a5er el screen
	                   add        dl,user+1             	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   int        10h
		
	                   mov        ah,09
	                   mov        dx,offset OtherUser+2
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   add        dl,OtherUser+1        	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   add        dl,OtherUser+1        	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   add        dl,OtherUser+1        	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   add        dl,player2name+1      	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1815h              	;a5er el screen
	                   add        dl,OtherUser+1        	;add playername length
	                   int        10h
		
	                   mov        ah,02
	                   mov        dl, 3AH               	;then write the score after adding all that
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1526h              	;a5er el screen
	                   int        10h
		
	                   mov        ah,09
	                   mov        dx,offset MAINSCREEN4
	                   int        21h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1535h              	;a5er el screen
	                   int        10h
		
	                   mov        ah,09
	                   mov        dx,offset MAINSCREEN5
	                   int        21h
		
	                   call       drawindicators
		
	                   ret
drawnotification endp

drawindicators proc
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1628h              	;a5er el screen
	                   int        10h
		
	                   cmp        readytogame,0
	                   je         notrgame
	                   mov        bl,02h
	                   jmp        d1
	notrgame:          
	                   mov        bl,004h               	;red on black background
	d1:                
	                   mov        ah,9                  	;int condition
	                   mov        bh,0                  	;page number
	                   mov        al,04H                	;arrow sign
	                   mov        cx,1H                 	;1 time
	                   int        10h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1837h              	;a5er el screen
	                   int        10h
		
	                   cmp        recievedchatinv,0
	                   je         notrecchat
	                   mov        bl,02h
	                   jmp        d2
	notrecchat:        
	                   mov        bl,004h               	;red on black background
	d2:                
	                   mov        ah,9                  	;int condition
	                   mov        bh,0                  	;page number
	                   mov        al,04H                	;arrow sign
	                   mov        cx,1H                 	;1 time
	                   int        10h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1828h              	;a5er el screen
	                   int        10h
		
	                   cmp        recievedgameinv,0
	                   je         notrecgame
	                   mov        bl,02h
	                   jmp        d3
	notrecgame:        
	                   mov        bl,004h               	;red on black background
	d3:                
	                   mov        ah,9                  	;int condition
	                   mov        bh,0                  	;page number
	                   mov        al,04H                	;arrow sign
	                   mov        cx,1H                 	;1 time
	                   int        10h
		
	                   mov        ah,2                  	;move cursor at desired destination
	                   mov        bh,0
	                   mov        dx,1637h              	;a5er el screen
	                   int        10h
		
	                   cmp        readytochat,0
	                   je         notrchat
	                   mov        bl,02h
	                   jmp        d4
	notrchat:          
	                   mov        bl,004h               	;red on black background
	d4:                
	                   mov        al,04H                	;arrow sign
	                   mov        ah,9                  	;int condition
	                   mov        bh,0                  	;page number
	                   mov        cx,1H                 	;1 time
	                   int        10h
		
		
	                   ret
drawindicators endp

resetindicators proc
		
	                   mov        recievedchatinv,0
	                   mov        recievedgameinv,0
	                   mov        readytochat,0
	                   mov        readytogame,0
		
	                   ret
resetindicators endp

menuinput proc
	MenuStart:         
	                   cmp        SentChatInvite , 1
	                   je         ChatInviteSent

	                   cmp        ReceivedChatInvite , 1
	                   je         ChatInviteReceived
		
	check:             
	                   mov        dx , 3FDH             	; Line Status Register
	                   In         al , dx               	;Read Line Status
	                   test       al , 00100000b
	                   jz         RecieveInv
	                   mov        ah,1                  	;get key input
	                   int        16h
	                   jz         RecieveInv
	                   cmp        ah,3bh
	                   je         chat

	chat:              
	                   mov        dx , 3F8H             	; Transmit data register
	                   mov        al,ah
	                   out        dx , al
	                   mov        SentChatInvite,1
	                   jmp        MenuStart
	
	RecieveInv:        
	                   mov        dx , 3FDH             	; Line Status Register
	                   in         al , dx
	                   test       al , 1
	                   JZ         check
	                   mov        dx , 03F8H
	                   in         al , dx
	                   mov        VALUE , al

	                   cmp        VALUE , 3bh
	                   mov        ReceivedChatInvite,1
	
	                   jmp        MenuStart
    
	ChatInviteSent:    
	                   mov        dx , 3FDH             	; Line Status Register
	                   in         al , dx
	                   test       al , 1
	                   JZ         ChatInviteSent
	                   mov        dx , 03F8H
	                   in         al , dx
	                   mov        VALUE , al

	                   cmp        VALUE , 3Fh           	;F5
	                   jne        RecievedF6
	                   mov        ChatMode , 1
	                   RET

	RecievedF6:        
	                   cmp        VALUE , 40h
	                   jne        ChatInviteSent

	                   mov        SentChatInvite,0
	                   jmp        MenuStart


	ChatInviteReceived:
	                   mov        dx , 3FDH             	; Line Status Register
	                   In         al , dx               	;Read Line Status
	                   test       al , 00100000b
	                   JZ         ChatInviteReceived    	;Not empty (This line may need to change)

	                   mov        ah,01h                	;checks keyboard buffer
	                   int        16h                   	;if nth is there check if u received sth
	                   jz         ChatInviteReceived
                        
	                   cmp        ah, 3Fh
	                   jne        SendF6
	                   mov        VALUE,ah

	                   mov        dx , 3F8H             	; Transmit data register
	                   mov        al,VALUE
	                   out        dx , al
	                   mov        ChatMode , 1

	SendF6:            
	                   cmp        ah, 40h
	                   jne        ChatInviteReceived
	                   mov        VALUE,ah
	                   mov        dx , 3F8H             	; Transmit data register
	                   mov        al,VALUE
	                   out        dx , al
	                   mov        ReceivedChatInvite , 0
	                   jmp        MenuStart


	;                 cmp        ah,3bh                	;cmp with f1
	;jz f1
	;                 je         escape

	;                cmp        ah,3ch                	;cmp with f2
	;               je         f2
		
	;              cmp        ah,01h                	;cmp with esc
	;             je         escape
		
	f1:                                                 	;chat mode is chosen
	                   call       clearinputbuffer
	;call sendchatinv
	;call checkchatinv
	;PUT CODE HERE TO CLEAR THE SCREEN AND CHOOSE SUITABLE VIDEO MODE FOR CHAT
	                   ret
		
	f2:                                                 	;game mode is chosen
	                   call       clearinputbuffer
		
	                   MOV        AH,0
	;MOV AL,0EH			;this is here just to clear the screen from the text of main menu
	                   INT        10H
	                   ret
		
	escape:            
	                   call       outro
	                   ret
menuinput endp

outro proc
		
	; call drawoutro
	; call introsound
		
	                   mov        ah,0                  	;change to text mode
	                   mov        al,03h
	                   int        10h
		
	                   mov        ax,4c00h
	                   int        21h
	                   ret
outro ENDP

	;================================================================================================================================================================

colorhalf1 proc
	                   mov        ah,06h                	; function 6
	                   mov        al,0h                 	; scroll by 1 line   (al=0 change color)
	                   mov        bh,9Eh                	; normal video attribute
	                   mov        ch,0h                 	; upper left Y
	                   mov        cl,0h                 	; upper left X
	                   mov        dh,12d                	; lower right Y
	                   mov        dl,79d                	; lower right X
	                   int        10h
	                   ret
colorhalf1 endp

colorhalf2 proc
	                   mov        ah,06h                	; function 6
	                   mov        al,0h                 	; scroll by 1 line   (al=0 change color)
	                   mov        bh,74h                	; normal video attribute
	                   mov        ch,13d                	; upper left Y
	                   mov        cl,0d                 	; upper left X
	                   mov        dh,24d                	; lower right Y
	                   mov        dl,79d                	; lower right X
	                   int        10h
	                   ret
colorhalf2 endp



checkNewLine1 proc
	                   cmp        byte ptr[si],80       	;check for end of current line
	                   jb         dontNewLine1
	                   mov        byte ptr [si],0
	                   add        byte ptr [si+1],1
	dontNewLine1:      ret
checkNewLine1 endp

checkNewLine2 proc
	                   cmp        byte ptr[di],80       	;check for end of current line
	                   jb         dontNewLine2
	                   mov        byte ptr [di],0
	                   add        byte ptr [di+1],1
	dontNewLine2:      ret
checkNewLine2 endp

checkEndHalf1 proc
	                   cmp        byte ptr[si+1],13     	;check for end of first half
	                   jnz        dontScroll1
	                   mov        ah,06h
	                   mov        bh,74h
	                   mov        al,01h
	                   mov        cx,0h
	                   mov        dx,7911d
	                   int        10h

	                   sub        byte ptr[si+1],1
	                   mov        byte ptr[si],0

	                   call       colorhalf1            	;this does the job but better be removed and the actual problem should be fixed
	                   mov        byte ptr[si+1],0
	                   mov        byte ptr[si],0
	dontScroll1:       ret
checkEndHalf1 endp

checkEndHalf2 proc
	                   cmp        byte ptr[si+1],24     	;check for end of second half
	                   jb         dontScroll2
	                   mov        ah,06h
	                   mov        bh,74h
	                   mov        al,01h
	                   mov        cx,0h
	                   mov        dx,7924d
	                   int        10h

	                   sub        byte ptr[di+1],1
	                   mov        byte ptr[di],0

	
	                   call       colorhalf2            	;this does the job but better be removed and the actual problem should be fixed
	                   mov        byte ptr[si+1],0
	                   mov        byte ptr[si],0

	dontScroll2:       ret
checkEndHalf2 endp

chatAuxKeys1 proc
	                   cmp        VALUE, 0Dh
	                   jnz        next1

	                   mov        byte ptr[si],-1
	                   add        byte ptr[si+1],1

	next1:             
	                   cmp        VALUE ,8
	                   jnz        next2
	                   SUB        byte ptr[si],2

	next2:             cmp        VALUE, 27             	; temporarily set to esc ascii because f3 key needs the function bitton to be pressed as well which somehow alters he ascii
	                   jne        retToMain1
	                   MOV        endChat,1

	retToMain1:        ret
chatAuxKeys1 endp

end main 