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

.model small
.stack 64
.data
	platformsCount DW 8                             	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
	Xpoints        DW 0,95,10,220,95,10,220,95
	Ypoints        DW 190,160,130,130,100,70,70,35
	Pcolors        DB 10,200,200,200,200,200,200,200
	Pwidths        DW 320,120,80,80,120,80,80,120
	Pheights       DW 10,3,3,3,3,3,3,3

	;First Platform
	P1_x           dw 160                           	;x
	P1_y           dw 100                           	;y
	P1_c           db 60                            	;color
	P1_w           dw 50                            	;width
	P1_h           dw 5                             	;height

	;Second Platform (Ground)
	P2_x           dw 0                             	;x
	P2_y           dw 190                           	;y
	P2_c           db 10                            	;color
	P2_w           dw 320                           	;width
	P2_h           dw 10                            	;height

	;Third Platform
	P3_x           dw 70                            	;x
	P3_y           dw 20                            	;y
	P3_c           db 15                            	;color
	P3_w           dw 80                            	;width
	P3_h           dw 5                             	;height

.code
main proc far
	              mov          ax,@data
	              mov          ds,ax

	              MOV          AH,0
	              MOV          AL,13h
	              int          10h

	              call         drawLevel1
	              int          20h
main endp
	;Procedures go here.

drawLevel1 proc
	              colorScreen  80
	              MOV          SI,0000h                                                        	;used as an iterator to reference points in Xpoints,Ypoints Pheights, Pwidths
	              MOV          DI,0000h                                                        	;used as an iterator with half the value of SI because colors array is a Byte not a word so we will need to iterate over half the value
	              MOV          BX,platformsCount
	              ADD          BX,BX
	DrawPlatforms:
	              drawPlatform Xpoints[SI], Ypoints[SI], Pcolors[DI], Pheights[SI], Pwidths[SI]
	              inc          DI
	              add          SI,2
	              CMP          SI,BX
	              JNZ          DrawPlatforms

drawLevel1 endp

end main      