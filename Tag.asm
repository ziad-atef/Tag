.model small
.stack 64
.data

player1_x dw 0Ah
player1_y dw 0Ah
player1_size dw 10h
oldTime db 0
.code     

draw_player1 proc

    mov ah,00h
    mov al,13h
    int 10h

    mov ah,0Bh
    mov bh,00h
    mov bl,00h
    int 10h

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
cmp ax,player1_size
jng draw
mov cx,player1_x
inc dx
mov ax,dx
sub ax,player1_y
cmp ax,player1_size
jng draw
ret
draw_player1 endp

move proc

mov ah,00h
int 16h
cmp ah,48h
je up
cmp ah,50h
je down
cmp ah,4Dh
je right
cmp ah,4Bh
je left
jmp finish
up:
cmp player1_y,00h
je finish

;dec player1_y
;call delay
;inc player1_y
;inc player1_y
jmp finish
down:
cmp player1_y,0B7h
je finish
inc player1_y
jmp finish
right:
cmp player1_x,130h
je finish
inc player1_x
jmp finish
left:
cmp player1_x,00h
je finish
dec player1_x
finish:
ret
move endp

;DELAY 500000 (7A120h).
delay proc   
  mov cx, 7      ;HIGH WORD.
  mov dx, 0A120h ;LOW WORD.
  mov ah, 86h    ;WAIT.
  int 15h
  ret
delay endp 

main proc far             
mov ax,@data
mov ds,ax      

mov ah,00h
mov al,13h
int 10h

mov ah,0Bh
mov bh,00h
mov bl,00h
int 10h

time:
    mov ah,2ch
    int 21h
    cmp dl,oldTime
    je time
    mov oldTime,dl
    call move
    call draw_player1

    jmp time
hlt 
main endp 

end main 

