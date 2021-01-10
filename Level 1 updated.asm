;I,cheesecake, have included and might include macros at the beginning of the code to easily use in visual code
;I recommend using lots of macros and procs since they make the job a lot more modular and easier
;Credit goes to Essam for his well-thought-of advice

;IMPORTANT: CHANGES TO THIS FILE ARE :1-CHANGES TO THE GRAPHIC MODE IN MAIN
                                     ;2-CHANGES TO PLATFORMS ARRAY IN DATA
                                     ;3-CHANGES TO THE BACKGROUND COLOR IN MAIN
                                     ;4-CHANGES TO BACKGROUND COLOR COORDINATES IN COLOR SCREEN

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
	platformsCount DW 8                         	;a variable to include the number of platforms in order to use in loops to reference in macros

	; the following arrays contain the x,y,color,width,and height of all platforms
	; the number of elements in each array is platformsCount
    ;[0] is the ground
	Xpoints        DW 0,150,20,440,150,20,440,150
	Ypoints        DW 315,270,220,220,160,100,100,50
	Pcolors        DB 10,8,8,8,8,8,8,8
	Pwidths        DW 640,300,150,150,300,150,150,300
	Pheights       DW 20,5,5,5,5,5,5,5

	; Xpoints        DW 0,95,10,220,95,10,220,95
	; Ypoints        DW 315,160,130,130,100,70,70,35
	; Pcolors        DB 10,200,200,200,200,200,200,200
	; Pwidths        DW 640,120,80,80,120,80,80,120
	; Pheights       DW 20,3,3,3,3,3,3,3

.code
main proc far
	              mov          ax,@data
	              mov          ds,ax

	              graphicsMode 12h        	;Graphics mode 320x200 , 10 makes the game screen small and changes color
	              
	              colorScreen  3

	              call         drawLevel1
	              int          20h
				  
main endp
	;Procedures go here.

drawLevel1 proc
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

	              ret
drawLevel1 endp

end main      