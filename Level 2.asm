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

getSystemTime macro
  mov  ah, 2ch
  int  21h       ;seconds return in dl
endm getSystemTime

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
	mov ch,0h
	int 10h
ENDM colorScreen

colorScreenSection macro color, from, to
	mov ah,06       ;Scroll (Zero lines anyway)
    mov al,00h      ;to blank the screen
	mov bh,color    ;color to blank the screen with
	mov ch, from
	mov dh,to
	mov cl,0
	mov dl,79
	int 10h
ENDM colorScreenSection

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
	platformsCount DW 9                                         	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
	Xpoints        DW 0, 80, 230, 10, 220, 95, 10, 220, 95
	Ypoints        DW 190, 160, 160, 130, 130, 100, 70, 70, 30
	Pcolors        DB 10, 200, 200, 200, 200, 200, 200, 200, 200
	Pwidths        DW 320, 10, 10, 80, 80, 120, 80, 80, 120
	Pheights       DW 10, 29, 29, 3, 3, 3, 3, 3, 3
	Velocities     DW 0, 0, 0, 1, 1, 0, 2, 2, 0
	previousTime   db ?
	testVelocity   dw 5
	
	;getSystemTime>>previousTime>>whenever not equal>>inc Xpoints 1/10
.code
main proc far
	              mov          ax,@data
	              mov          ds,ax

	              graphicsMode 13h                                                             	;Graphics mode 320x200
	              
	              colorScreen  53

	;               getSystemTime
	;               mov                previousTime, dl
	; whileTime:
	;               getSystemTime
	;               cmp                dl, previousTime
	;               JE                 whileTime
	;               mov                previousTime, dl
	;               colorScreenSection 53, 15, 16
	;               colorScreenSection 53, 18, 19
	              call         drawLevel2
	;   jmp                whileTime

	              int          20h
main endp
	;Procedures go here.

drawLevel2 proc
	              MOV          SI, 0000h                                                       	;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
	              MOV          DI, 0000h                                                       	;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
	              MOV          BX, platformsCount
	              ADD          BX, BX
	DrawPlatforms:
	              mov          ax, Velocities[SI]                                              	;Add into each xPoint, Velocity:
	              add          Xpoints[SI], ax
	              drawPlatform Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]

	              inc          DI
	              add          SI,2
	              CMP          SI,BX
	              JNZ          DrawPlatforms
				  
	              ret
drawLevel2 endp


end main      