
.MODEL SMALL
.STACK 64
.DATA
	VALUE              db ?
	player1coordinates db 0,0
    player2coordinates  db  0,13

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

	               call divide_color


	;move cursor to beginning of the screen
	chat:          
    
	;Check that Transmitter Holding Register is Empty
	               mov  dx , 3FDH                   	; Line Status Register
	AGAIN:         In   al , dx                     	;Read Line Status
	               test al , 00100000b
	               JZ   receive                     	;Not empty (This line may need to change)

    
	               mov  ah,01h
	               int  16h
	               jz   receive

	               mov  ah,0h                       	;get key input
	               int  16h                         	;input in al,if any

                    mov  VALUE,al

	               mov  ah,02h
	               mov  dl, byte ptr [si]
	               mov  dh, byte ptr [si+1]
                   inc byte ptr [si]
	               int  10h

	               mov  ah,9                        	;Display
	               mov  bh,0                        	;Page 0
	               mov  cx,1h                       	;5 times
	               mov  bl,09eh                     	;
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
	               mov  dl, byte ptr [di]
	               mov  dh, byte ptr [di+1]
                   inc byte ptr [di]
	               int  10h

	               mov  al,VALUE
	               mov  ah,9                        	;Display
	               mov  bh,0                        	;Page 0
	               mov  cx,1h                       	;5 times
	               mov  bl,074h                     	;
	               int  10h
	lbl:           
	               jmp  chat
	               hlt
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


divide_color proc
	               mov  ah,06h                      	; function 6
	               mov  al,0h                       	; scroll by 1 line   (al=0 change color)
	               mov  bh,9Eh                      	; normal video attribute
	               mov  ch,0h                       	; upper left Y
	               mov  cl,0h                       	; upper left X
	               mov  dh,12d                      	; lower right Y
	               mov  dl,79d                      	; lower right X
	               int  10h

	               mov  ah,06h                      	; function 6
	               mov  al,0h                       	; scroll by 1 line   (al=0 change color)
	               mov  bh,74h                      	; normal video attribute
	               mov  ch,13d                      	; upper left Y
	               mov  cl,0d                       	; upper left X
	               mov  dh,24d                      	; lower right Y
	               mov  dl,79d                      	; lower right X
	               int  10h
	               ret
divide_color endp

END MAIN