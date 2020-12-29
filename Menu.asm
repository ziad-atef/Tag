.model small
.stack 64
.data


;START PHOTO DATA
    StartWidth EQU 301
    StartHeight EQU 200
    StartFilename DB 'start.bin', 0
    StartFilehandle DW ?
    StartData DB StartWidth*StartHeight dup(0)
    
GAME_START_STR DB '  ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  db   '                                                                    ',0ah,0dh
  DB   '                ====================================================',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh                                        
  DB   '               ||            *        TAG GAME        *            ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||--------------------------------------------------||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||   Please Enter the name of the first player      ||',0ah,0dh
  DB   '               ||                with color Red                    ||',0ah,0dh
  DB   '               ||                then press Enter                  ||',0ah,0dh  
  DB   '               ||                                                  ||',0ah,0dh 
  DB   '               ||   Please Enter the name of the second player     ||',0ah,0dh
  DB   '               ||                with color Yellow                 ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||         Then press Enter to start play           ||',0ah,0dh 
  DB   '               ||       **MAX 7 CHARCHTERS FOR EACH PLAYER**       ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||         If you want to go to chat mode           ||',0ah,0dh
  DB   '               ||                   Press ''C''                    ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '                ====================================================',0ah,0dh
  DB   '$',0ah,0dh 
WINNER_NAME DB '       ', '$'
;SCORE_WINNER DB ' '
;SCORE_LOSER DB ' ' 
GAME_OVER_STR DB '  ', 0ah,0dh
  DB   '                ====================================================',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh                                        
  DB   '               ||            *        TAG GAME        *            ||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||--------------------------------------------------||',0ah,0dh
  DB   '               ||                                                  ||',0ah,0dh
  DB   '               ||                    GAME OVER                     ||',0ah,0dh
  DB   '                ====================================================',0ah,0dh
  DB   '$',0ah,0dh

CONGRATULATIONS DB 'Congratulations ', '$'
SCOREIS DB 'The Score is ', '$'
ENDL DB 0ah, 0dh

PLAYER_1_NAME DB 30, ?, 30 dup('$')
PLAYER_2_NAME DB 30, ?, 30 dup('$')


.code
main proc

mov ah, 09
mov dx, offset GAME_START_STR
int 21h

mov ah, 0ah
mov dx, offset PLAYER_1_NAME
int 21h

mov ah, 0ah
mov dx, offset PLAYER_2_NAME
int 21h

mov ah, 07
int 21h

cmp ah, 43h
je clearScreen

clearScreen:
mov ah, 06
mov al, 10
mov bh, 07
mov cx, 0000
mov dx, 184fh
int 10h
jmp gameOver

gameOver:
mov ah, 09
mov dx, offset GAME_OVER_STR
int 21h

main endp

end main