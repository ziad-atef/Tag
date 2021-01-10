
.MODEL SMALL
.STACK 64
.DATA
	VALUE              db ?
	player1coordinates db -1,0	;x,y
    player2coordinates  db  -1,13
	endChat	db	0

    ; tod
    ; 
.CODE

MAIN PROC FAR
	               MOV  AX, @DATA
	               MOV  DS,AX

	               mov  SI,offset player1coordinates
	               LEA  DI, player2coordinates
                
	               mov  ah,0
	               mov  al,3
	               int  10h
    
	               call initializeUART

	               call colorhalf1
				   call colorhalf2

				;    mov  ah,02h	;move cursor
				;    mov  dl, 0
	            ;    mov  dh, 0
	  			;    int  10h
	;move cursor to beginning of the screen
	chat:          
    
	;Check that Transmitter Holding Register is Empty
	               mov  dx , 3FDH                   	; Line Status Register
	AGAIN:         In   al , dx                     	;Read Line Status
	               test al , 00100000b
	               JZ   receive                     	;Not empty (This line may need to change)

    
	               mov  ah,01h	;checks keyboard buffer
	               int  16h		;if nth is there check if u received sth
	               jz   receive

	               mov  ah,0h                       	;get key input
	               int  16h                         	;input in al,if any

				   call chatAuxKeys1
                   mov  VALUE,al
					
	               mov  ah,02h	;move cursor
                   inc byte ptr [si]

				   call checkEndHalf1	
				   call checkNewLine1

				   mov  dl, byte ptr [si]
	               mov  dh, byte ptr [si+1]
	  			   int  10h

	               mov  ah,9                        	;Display
	               mov  bh,0                        	;Page 0
	               mov  cx,1h                       	;5 times
	               mov  bl,09eh                     	;
	               mov al,VALUE
				   int  10h
    

	;If empty put the VALUE in Transmit data register
	               mov  dx , 3F8H                   	; Transmit data register
	               mov  al,VALUE
	               out  dx , al



	receive:       
	;Check that Data is Ready
	               mov  dx , 3FDH                   	; Line Status Register
	CHK:           in   al , dx
	               test al , 1
	               JZ   lbl                         	;Not Ready (This line may need to change)
	;If Ready read the VALUE in Receive data register
	               mov  dx , 03F8H
	               in   al , dx
	               mov  VALUE , al


                  ;check if enter ascii
                  ;inc byte ptr[di+1]
                  ;jump over the next block


	               mov  ah,02h
                   inc byte ptr [di]
	               mov  dl, byte ptr [di]
	               mov  dh, byte ptr [di+1]
				   int 10h

					call checkEndHalf2
					call checkNewLine2

	               mov  al,VALUE
	               mov  ah,9                        	;Display
	               mov  bh,0                        	;Page 0
	               mov  cx,1h                       	;5 times
	               mov  bl,074h                     	;
	               int  10h
	
	lbl:           cmp endChat,1
				   jz exitChat
	               jmp  chat

exitChat:	       INT 20h
MAIN ENDP

initializeUART proc
	;	Set Divisor Latch Access Bit
	               mov  dx,3fbh                     	; Line Control Register
	               mov  al,10000000b                	;Set Divisor Latch Access Bit
	               out  dx,al                       	;Out it

	;	Set LSB byte of the Baud Rate Divisor Latch register.
	               mov  dx,3f8h
	               mov  al,0ch
	               out  dx,al

	;	Set MSB byte of the Baud Rate Divisor Latch register.
	               mov  dx,3f9h
	               mov  al,00h
	               out  dx,al

	;	Set port configuration
	               mov  dx,3fbh
	               mov  al,00011011b
	               out  dx,al
	               ret
initializeUART ENDP


colorhalf1 proc
	               mov  ah,06h                      	; function 6
	               mov  al,0h                       	; scroll by 1 line   (al=0 change color)
	               mov  bh,9Eh                      	; normal video attribute
	               mov  ch,0h                       	; upper left Y
	               mov  cl,0h                       	; upper left X
	               mov  dh,12d                      	; lower right Y
	               mov  dl,79d                      	; lower right X
	               int  10h
				   ret
				   colorhalf1 endp

colorhalf2 proc
	               mov  ah,06h                      	; function 6
	               mov  al,0h                       	; scroll by 1 line   (al=0 change color)
	               mov  bh,74h                      	; normal video attribute
	               mov  ch,13d                      	; upper left Y
	               mov  cl,0d                       	; upper left X
	               mov  dh,24d                      	; lower right Y
	               mov  dl,79d                      	; lower right X
	               int  10h
	               ret
colorhalf2 endp



checkNewLine1 proc
	 cmp byte ptr[si],80				;check for end of current line
	 jb dontNewLine1
	mov byte ptr [si],0
	add byte ptr [si+1],1
	dontNewLine1: ret
checkNewLine1 endp

checkNewLine2 proc
	 cmp byte ptr[di],80				;check for end of current line
	 jb dontNewLine2
	mov byte ptr [di],0
	add byte ptr [di+1],1
	dontNewLine2: ret
checkNewLine2 endp

checkEndHalf1 proc
	cmp byte ptr[si+1],13		;check for end of first half
	jnz dontScroll1
	mov ah,06h
	mov bh,74h
	mov al,01h
	mov cx,0h
	mov dx,7911d
	int 10h

	sub byte ptr[si+1],1
	mov byte ptr[si],0

	call colorhalf1		;this does the job but better be removed and the actual problem should be fixed
	mov byte ptr[si+1],0
	mov byte ptr[si],0
dontScroll1: ret
checkEndHalf1 endp

checkEndHalf2 proc
	cmp byte ptr[si+1],24			;check for end of second half
	jb dontScroll2
	mov ah,06h
	mov bh,74h
	mov al,01h
	mov cx,0h
	mov dx,7924d
	int 10h

	sub byte ptr[di+1],1
	mov byte ptr[di],0

	
	call colorhalf2		;this does the job but better be removed and the actual problem should be fixed
	mov byte ptr[si+1],0
	mov byte ptr[si],0

dontScroll2: ret
checkEndHalf2 endp

chatAuxKeys1	proc
	cmp VALUE, 0Dh
	jnz next1

	mov byte ptr[si],-1
	add byte ptr[si+1],1

next1:
	cmp VALUE ,8
	jnz next2
	SUB byte ptr[si],2

next2: cmp VALUE, 27	; temporarily set to esc ascii because f3 key needs the function bitton to be pressed as well which somehow alters he ascii
		jne retToMain1
		MOV endChat,1

retToMain1: ret
chatAuxKeys1 endp
END MAIN