org 0x7e00
jmp 0x0000:start
videomem_addr dw 0a000h ;endereço da memoria de vídeo 
;struct rectangle
 rec_X       dw 0
 rec_Y       dw 0
 rec_largura dw 0
 rec_altura  dw 0
;tela
 tela_largura dw 320
 tela_altura dw 200
;vetor de alturas das barras:
 vet_alturas db 75,105,87,103,106,96,105,121,104,75,125
 pos_vet db 0
;cores de pixel
 preto db 0
 azul db 1
 verde db 2
 cyan db 3
 vermelho db 4
 magenta db 5
 marrom db 6
 branco db 7
 cinza db 8
 azul_claro db 9
 verde_claro db 10
 cyan_claro db 11
 rosa db 12
 magenta_claro db 13
 amarelo db 14
 branco_intenso db 15
;estrutura barra1(x,y)
 x_barra1 dw 300;posicao x da barra
 y_barra1 dw 120;posicao y da barra 
;estrutura barra2(x,y)
 x_barra2 dw 320;posicao x da barra
 y_barra2 dw 120;posicao y da barra
 vel_barra dw 4;velocidade da barra

;Informações do pássaro
    bird_x dw 120
    bird_y dw 100

    bird_up dw 25
    bird_down dw 1

    bird_x_tamanho dw 20
    bird_y_tamanho dw 20

    bird_x_posFinal dw 140
    bird_y_posFinal dw 120

    bird_contadorMax_velocidade dw 5
    bird_contador_velocidade dw 0

;funcoes para a barra:
    update_Xbarra:
        ;deslocando barra
        mov ax,[x_barra1]
        sub ax,[vel_barra]
        ;atualizando posição da barra
        mov [x_barra1],ax
    ret
    update_Ybarra:;escolher um numero aleatorio entre 125 e 75
        mov bx,[pos_vet]
        inc bx
        cmp bx,11
        jne .atualizar_y
        xor bx,bx

        .atualizar_y:

        mov [pos_vet],bx
        mov si,vet_alturas
        add si,bx
        xor ax,ax
        lodsb
        mov [y_barra1],ax
    ret
screen_clear:
    mov ax,13h
    int 10h
    ret
titulo      db 'FLAPPLY BIRD', 0
jogar       db 'Play (1)', 0
instrucoes  db 'Instruction (2)', 0
creditos    db 'Credits (3)', 0

;instrucoes
inst0 db 'INSTRUCOES', 0
inst1 db '1. Aperte espaco para nao cair', 0
inst2 db '2. Nao encoste no chao', 0
inst3 db '3. Nao encoste nos tubos',0 

;creditos
creditos1 db 'Lucas Inojosa <lims>', 0
creditos2 db 'Luis Felipe <lfro2>', 0
creditos3 db 'Kaylane Lira <kgl>', 0
creditos4 db 'Press Esc to return', 0

;parte do jogo
points dw 0
%macro imprimir_retangulo 4 ;(x,y,largura,altura)[posicao do canto superior esquerdo,tamanho]
     mov ax,%1
     mov bx,%2
     mov cx,%3
     mov dx,%4
     mov [rec_X],ax;pos x
     mov [rec_Y],bx;pos y
     mov [rec_largura],cx;largura
     mov [rec_altura],dx;altura
    call _imprimir_retangulo
%endmacro
_imprimir_retangulo:
    mov es,[videomem_addr];colocando endereço da mem de video em extra segment
    
    mov bx,[tela_largura]
    mov ax,[rec_Y]
    mul bx

    add ax,[rec_X]

    mov di,ax
    
    call clear_registers
   ;imprimindo pixels

    .print_pixel:;imprimir um pixel na memoria de video[320,200]
       ;escrevendo cor no video na posição ax
        mov bl,15

        mov [es:di],bl;só di pode determinar deslocamento
       ;atualizando posição a ser escrita 
        inc cx ;contador da coluna
        inc di
        cmp cx,[rec_largura]
        jle .nao_muda_linha
           ;zera iterador da coluna
            xor cx,cx 
            inc dx
            cmp dx,[rec_altura]

            jge .endprint_pixel

               ;atualizar linha onde pixel sera impresso
                dec di
                sub di,[rec_largura]  ; retorna pro começo
                add di,[tela_largura] ;linha de baixo
                
        .nao_muda_linha:
     jmp .print_pixel   
    .endprint_pixel:
 ret

clear_registers:
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx  
 ret
; macro
%macro delay_fps 0
    pusha
    mov ah, 86h ;função delay da bios
    mov cx, 0 ;high word
    mov dx, 16000 ;low word
    int 15h
    popa
%endmacro
initvideo:
    mov al, 13h
    mov ah, 0
    int 10h
    ret
writechar:
    mov ah, 0xe
    mov bx, 3
    int 10h
    ret

printString:
    lodsb
    mov ah, 0xe
    mov bh, 0
    mov bl, 0xf
    int 10h

    cmp al, 0
    jne printString
    ret

scan_key:
        mov ah, 1h
        int 16h
        jnz .key_pressed
        ret
               
            .key_pressed:
                mov ah, 0h
                int 16h
               
        cmp al, 32
        je pular
 ret
pular:
    call update_yBird_up
ret

update_yBird_up:
    mov ax, [bird_y]
    sub ax, [bird_up]
    mov [bird_y], ax

    mov ax, [bird_y_posFinal]
    sub ax, [bird_up]
    mov [bird_y_posFinal], ax

    mov ax, 1
    mov [bird_down], ax
ret
update_yBird_down:
    mov ax, [bird_y]
    add ax, [bird_down]
    mov [bird_y], ax

    mov ax, [bird_y_posFinal]
    add ax, [bird_down]
    mov [bird_y_posFinal], ax
ret
update_velocidade:
    inc word[bird_contador_velocidade]
    mov ax, [bird_contador_velocidade]
    mov bx, [bird_contadorMax_velocidade]
    cmp ax, bx
    je incrementa_velocidade_passaro
ret

incrementa_velocidade_passaro:
    mov ax, [bird_down]
    cmp ax, 3
    jne .somaVelocidade
    .somaVelocidade:   
        inc word[bird_down]
        mov ax, 0
        mov [bird_contador_velocidade], ax
    ret
 ret
print_bird:
    call update_velocidade
    call update_yBird_down
    imprimir_retangulo [bird_x],[bird_y],20,10
 ret 
colisao:
    ;colisão com o chão
    mov ax, [bird_y_posFinal]
    cmp ax, 200
    jge ocorreuColisao
ret

ocorreuColisao:
    ;Reiniciando vairáveis
    mov ax, 120
    mov [bird_x], ax

    mov ax, 100
    mov [bird_y], ax

    mov ax, 140
    mov [bird_x_posFinal], ax

    mov ax, 120
    mov [bird_y_posFinal], ax

    mov ax, 1
    mov [bird_down], ax
    
    mov ax, 20
    mov [bird_x_tamanho], ax

    mov ax, 20
    mov [bird_y_tamanho], ax

    mov ax, 0
    mov [bird_contador_velocidade], ax

    delay_fps
    call screen_clear 
    jmp Menu 
ret

loopGame:;loop cx[xbarra,xbarra+3]
    call scan_key
    call print_bird
    call colisao

    delay_fps               ; delay de 1/30 segundos
    call screen_clear       ; limpar tela a cada frame
 jmp loopGame
.end_game_loop:


;Inicio do programa
start:
    ;Zerando os registradores
    mov ax, 0
    mov ds, ax

    ;Chamando a função Menu
    call Menu

    jmp done

Menu:
    ;Carregando o video
    mov ah, 0
    mov al,12h
    int 10h

    ;Mudando a cor do background para azul escuro
    mov ah, 0bh
    mov bh, 0
    mov bl, 3
    int 10h 

    ;Colocando o Titulo
	mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 10   ;Linha
	mov dl, 34   ;Coluna
	int 10h
    mov si, titulo
    call printString

    ;Colocando a string jogar
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 13   ;Linha
	mov dl, 36   ;Coluna
	int 10h
    mov si, jogar
    call printString
    
    ;Colocando a string intrucoes
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 16   ;Linha
	mov dl, 32   ;Coluna
	int 10h
    mov si, instrucoes
    call printString
    
    ;Colocando a string creditos
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 19   ;Linha
	mov dl, 34   ;Coluna
	int 10h
    mov si, creditos
    call printString
    
    ;Selecionar a opcao do usuario
    selecao:
        ;Receber a opção
        mov ah, 0
        int 16h
        
        ;Comparando com '1'
        cmp al, 49
        je play
        
        ;Comparando com '2'
        cmp al, 50
        je instrucao
        
        ;Comparando com '3'
        cmp al, 51
        je credito
        
        ;Caso não seja nem '1' ou '2' ou '3' ele vai receber a string dnv
        jne selecao
     
play:
    call initvideo;set video mode 
    mov al,3

    mov cx,160
    mov dx,100
    call loopGame
    jmp done

;Caso seja selecionado "Instruction (2)"
instrucao:
    ;Carregando o video para limpar a tela
    mov ah, 0
    mov al,12h
    int 10h

    ;Mudando a cor do background para ciano
    mov ah, 0bh
    mov bh, 0
    mov bl, 3
    int 10h 

    ;Colocando o Titulo
	mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 5   ;Linha
	mov dl, 34   ;Coluna
	int 10h
    mov si, inst0
    call printString

    ;Colocando a string 
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 10   ;Linha
	mov dl, 23   ;Coluna
	int 10h
    mov si, inst1
    call printString
    
    ;Colocando a string 
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 13   ;Linha
	mov dl, 23   ;Coluna
	int 10h
    mov si, inst2
    call printString
    
    ;Colocando a string
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 16   ;Linha
	mov dl, 23   ;Coluna
	int 10h
    mov si, inst3
    call printString

    ;Colocando a string
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 23   ;Linha
	mov dl, 29   ;Coluna
	int 10h
    mov si, creditos4
    call printString

ESCinstrucao:    
    ;Para receber o caractere
    mov ah, 0
    int 16h

    ;Apos receber 'Esc' volta pro menu
    cmp al, 27
	je Menu
	jne ESCinstrucao

;Caso seja selecionado "Credits (3)"
credito:
    ;Carregando o video para limpar a tela
    mov ah, 0
    mov al,12h
    int 10h

    ;Mudando a cor do background para ciano
    mov ah, 0bh
    mov bh, 0
    mov bl, 3
    int 10h 

    ;Colocando o titulo
	mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 3    ;Linha
	mov dl, 29   ;Coluna
	int 10h
    mov si, creditos
    call printString

    ;Colocando a string creditos1
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 7    ;Linha
	mov dl, 10   ;Coluna
	int 10h
    mov si, creditos1
    call printString

    ;Colocando a string creditos2
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 9    ;Linha
	mov dl, 10   ;Coluna
	int 10h
    mov si, creditos2
    call printString

    ;Colocando a string creditos3
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 11   ;Linha           
	mov dl, 10   ;Coluna
	int 10h
    mov si, creditos3
    call printString

	;Colocando a string creditos4
    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 20   ;Linha
	mov dl, 10   ;Coluna
	int 10h
    mov si, creditos4
    call printString

ESCcreditos:
	;Para receber o caractere
    mov ah, 0
    int 16h

    ;Apos receber 'Esc' volta pro menu
    cmp al, 27
	je Menu
	jne ESCcreditos

score:
ret

done:
    jmp $
