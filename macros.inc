STARTING_PROCESS MACRO
    ; ; Open file
    ;     MOV AH, 3Dh
    ;     MOV AL, 0 ; read only
    ;     LEA DX, startFilename
    ;     INT 21h   
    ;     MOV [StartFilehandle], AX
    ;     ;ReadData
    ;     MOV AH,3Fh
    ;     MOV BX, [StartFilehandle]
    ;     MOV CX,startWidth*startHeight ; number of bytes to read
    ;     LEA DX, startData
    ;     INT 21h	
    ;     LEA BX , startData ; BL contains index at the current drawn pixel
    ;     MOV CX,0
    ;     MOV DX,0
    ;     MOV AH,0ch
        
    ;     ; Drawing loop
    ;     drawLoop:
    ;         MOV AL,[BX]
    ;         INT 10h 
    ;         INC CX
    ;         INC BX
    ;         CMP CX,startWidth
    ;     JNE drawLoop 
    ;         MOV CX , 0
    ;         INC DX
    ;         CMP DX , startHeight
    ;     JNE drawLoop
    ;         ;CloseFile
    ;         MOV AH, 3Eh
    ;         MOV BX, [startFilehandle]
    ;         INT 21h

    ; GAME_MENU:
    ;     MOV AH,0
    ;     INT 16H 
    ;     CMP AL,'1'
    ;     jne LEVEL2
    ;         MOV GAMELEVEL, 1
    ;         JMP GAME_START
    ;     LEVEL2:
    ;         CMP AL,'2'
    ;         JNE GAME_MENU
    ;         MOV GAMELEVEL, 2
    ;     JMP GAME_START

    ; JNE GAME_MENU ;PASS ONLY IF 1 OR 2 IS PRESSED 

    ;video mode
        GAME_START:
        MOV AH, 0
        MOV AL, 3h
        INT 10h
    ;DISPLAY GAME START STRING
    
        ;CLEAR SCREEN
        MOV AX, 0600H
        MOV BH, 7
        MOV CX, 0
        MOV DX ,184FH
        INT 10H

        ;DISPLAY THE START GAME STRING
        MOV AH,09
        MOV DH,0
        MOV DX,OFFSET GAME_START_STR
        INT 21H 

        ;moving the cursor AND SHOW PLAYER 1 NAME
            MOV DL, 5
            MOV DH, 5
            MOV BH, 0
            MOV AH, 02h
            int 10h

            MOV AH,09
            MOV DH,0
            MOV DX, OFFSET PLAYER1 + 7
            INT 21H
        ;moving the cursor AND SHOW PLAYER 2 NAME:
            MOV DL, 5
            MOV DH, 7
            MOV BH, 0
            MOV AH, 02h
            int 10h

            MOV AH,09
            MOV DH,0
            MOV DX,OFFSET PLAYER2 + 7
            INT 21H

        ;READ FIRST PLAYER NAME
            ;MOVE THE CURSOR THEN TAKE THE FIRST PLAYER NAME
            MOV DL, 19
            MOV DH, 5
            MOV BH, 0
            MOV AH, 02h
            int 10h

            MOV AH,0AH
            MOV DX,offset PLAYER1_NAME
            INT 21H

        ;READ SECOND PLAYER NAME
            MOV DL, 19
            MOV DH, 7
            MOV BH, 0
            MOV AH, 02h
            int 10h

            MOV AH,0AH
            MOV DX,offset PLAYER2_NAME
            INT 21H
             
             
        MOV CX,7
        MOV si,2
        NAMES: 
            CMP [PLAYER1_NAME+si],0DH
            JE NONAME1
            CMP [PLAYER1_NAME+si],'$'
            JE NONAME1
            MOV bh,[PLAYER1_NAME+si]
            MOV [PLAYER1+SI-2],BH
            NONAME1:  
            CMP [PLAYER2_NAME+si],'$'
            JE NONAME2
            CMP [PLAYER2_NAME+si],0DH
            JE NONAME2
            MOV bl,[PLAYER2_NAME+si]
            MOV [PLAYER2+SI-2],BL
            NONAME2:
            INC si
        LOOP NAMES

ENDM STARTING_PROCESS

INITIALZING_DATA MACRO
    

    MOV AX, INITIAL_P1_X
    MOV PLAYER1X, AX
    MOV AX, INITIAL_P1_Y
    MOV PLAYER1Y, AX
    MOV AX, INITIAL_P2_X
    MOV PLAYER2X, AX
    MOV AX, INITIAL_P2_Y
    MOV PLAYER2Y, AX

  
ENDM INITIALZING_DATA


DRAW_STATIC MACRO  
    ;Draw BackGround
        MOV BH,0
        MOV CX,320D
        MOV AH,0Ch
        MOV AL,BGC
        XBGC:
            MOV DX,200D
            YBGC:
                INT 10H
                DEC DX
                CMP DX, 30
                JE OUT_BKG
            JNZ YBGC
            OUT_BKG:
        LOOP XBGC

    ;Draw Frame
        MOV AH, 0CH
        MOV AL, 0fh

        
        MOV CX, 320D
        MOV DX, 30
        UPPER_FRAME: INT 10H
        LOOP UPPER_FRAME
                        
            MOV CX, 320D
            MOV DX, 199D
        LOWER_FRAME: INT 10H
        LOOP LOWER_FRAME


            MOV CX, 319D
            MOV DX, 199D
        RIGHT_FRAME: INT 10H
            DEC DX 
            CMP DX, 30
        JNZ RIGHT_FRAME
                        
            MOV CX, 1
        LEFT_FRAME: INT 10H
            INC DX 
            CMP DX, 199
        JNZ LEFT_FRAME    

    ;display player1 name in BLUE
        ;moving the cursor
            mov dl,1h
            mov dh,1h
            mov bh,0
            mov ah,02h
            int 10h
        ;preparing registers for printing
            mov bl,01h
            mov ah,0eh
            mov di,7
            mov si,0
        DrawPLayer1Name:
            ;display the name
                mov al,[player1+si]
                int 10h
            ;moving the cursor right
                inc dl
                inc si
                dec di
        jnz DrawPLayer1Name
    ;display player2 name in BLUE
        ;moving the cursor
            mov dl,20h
            mov dh,1h
            mov bh,0
            mov ah,02h
            int 10h
        ;preparing registers for printing
            mov bl,01h
            mov ah,0eh
            mov di,7
            mov si,0
        DrawPLayer2Name:
            ;display the name
                mov al,[player2+si] ;if the seconde player  
                int 10h
            ;moving the cursor right
                inc dl
                inc si
                dec di
        jnz DrawPLayer2Name
        
    ;draw Word Score
        ;move the cursor
            mov dh,1
            mov dl,11h
            mov ah,02h
            int 10h
        ;draw 'Score'
            mov ah,0eh
            mov di,5
            mov si,0
            mov bl,8
            DrawScore:
                mov al,[Score+si]
                int 10h
                inc dl
                inc si
                dec di
            jnz DrawScore
    ;draw 'Health'
        ;move cursor
            mov dl,11h
            inc dh
            mov ah,02h
            int 10h
            mov bl,7
            mov ah,0eh
            mov di,6
            mov si,0
        DrawScore1:
            mov al,[HealthString+si]
            int 10h
            inc dl
            inc si
            dec di
        jnz DrawScore1

ENDM DRAW_STATIC 