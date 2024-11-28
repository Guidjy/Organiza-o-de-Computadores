########################################################################################################################
# *** Procedimentos do display de bitmap ***
# 
# >>> screen_init2:
#     inicializa a tela gráfica
#
# >>> coordinates_to_address: 
#     retorna o endereço da memória da tela gráfica, correspondente a coordenada (x,,y).
#     Argumentos
#     $a0 : coordenada x na tela (row)
#     $a1 : coordenada y na tela (column)
#     retorno
#     $v0 : endereço de memória da correspondente coordenada retangular (x,y). Retorna -1 se houve um erro
#
# >>> set_foreground_color:
#     Escolhe a cor de desenho dos pixels
#     Argumento
#     $a0 : Cor no formato hexadecimal 0x00RRGGBB
#
# >>> set_background_color:
#     Escolhe a cor do fundo da tela
#     Argumento
#     $a0 : Cor no formato hexadecimal 0x00RRGGBB
#
# >>> put_pixel:
#     Escreve um pixel na ferramenta bitmap display na cor da variável screen_color
#     Argumentos
#     $a0 : posição row do pixel
#     $a1 : posição column do pixel
#
# >>> draw_line:
#     Desenho de uma linha de um ponto P0(x0, y0) para P1(x1, y1)
#     Argumentos do procedimento
#     $a0 : x0      coordenada x do ponto P0
#     $a1 : y0      coordenada y do ponto P0
#     $a2 : x1      coordenada x do ponto P1
#     $a3 : y1      coordenada y do ponto P1
#
# >>> draw_rectangle:
#     Desenha um retangulo com as coordenadas P0(x0, y0) e P1(x1, y1)
#     Argumentos do procedimento
#     $a0 : x0      coordenada x do ponto P0     
#     $a1 : y0      coordenada y do ponto P0
#     $a2 : x1      coordenada x do ponto P1 
#     $a3 : y1      coordenada y do ponto P1
#
# >>> draw_circle:
#     Desenho de um círculo com centro no ponto P0(x0, y0) de raio r. 
#     Argumentos do procedimento:
#     $a0 : x0      coordenada x do centro do círculo
#     $a1 : y0      coordenada y do centro do círculo
#     $a2 : raio    raio r do circulo com centro em P0(x0, y0)
#
#
# > em síntse:
# (a) screen_init2:             Inicializa a tela gráfica, versão otimizada
# (b) coordinates_to_address:   retorna o endereço da memória da tela gráfica, correspondente a coordenada (x,,y)
# (c) set_foreground_color:     Escolhe a cor de desenho dos pixels
# (d) set_background_color:     Escolhe a cor do fundo da tela
# (e) put_pixel:                Escreve um pixel na ferramenta bitmap display na cor da variável screen_color
# (f) draw_line:                Desenho de uma linha usando o algoritmo de Bresenham, de um ponto P0(x0, y0) para P1(x1, y1)
# (g) draw_rectangle:           Desenha um retangulo com as coordenadas P0(x0, y0) e P1(x1, y1)
# (h) draw_circle:              Desenho de um círculo com centro no ponto P0(x0, y0) de raio r.

########################################################################################################################

# executa no início da execução
init:
	jal main
	jal exit 

# inclui os procedimentos fornecidos pelo professor
.include "display_bitmap.asm"

########################################################################################################################

# variáveis do jogo
.data
tabuleiro:		.space 168	# vetor que representa o tabuleiro de connect 4
linha:			.word 0		# armazenar a jogada de um jogador
coluna:			.word 0		# armazenar a jogada de um jogador
vez:			.word 0		# indica de qual jogador é a vez de jogar
buffer:			.space 1	# espaço para armazenar 1 caractere
string_apresentacao:	.asciiz "> Clique 'enter' para jogar:"
string_jogada1:		.asciiz "> Vez do "
string_jogada2:		.asciiz "vermelho: "
string_jogada3:		.asciiz "amarelo: "
string_fim1:		.asciiz "-=-=-=-=-=- GAME OVER -=-=-=-=-=-"
string_fim2:		.asciiz "> Jogar de novo? [s/n]"
newline:    		.asciiz "\n"

########################################################################################################################

.text

# testes das funções de display de bitmap
main:
	# *** mapa dos registradores ***
	# $s0 = endereço base de tabuleiro
	# $s1 = endereço da variável linha
	# $s2 = endereço da variável coluna
	# $s3 = endereço da variável vez
	
# prólogo
	addiu $sp, $sp, -4	# ajusta a pilha
        sw $ra, 0($sp)         	# guarda na pilha o endereço de retorno
	
# corpo do programa

	# carrega as variáveis
	la $s0, tabuleiro	# $s0 = endereço base de tabuleiro
	la $s1, linha		# $s1 = endereço da variável linha
	la $s2, coluna		# $s2 = endereço da variável coluna
	la $s3, vez		# $s3 = endereço da variável vez
	
	# deixa os pixeis de desenho brancos
	li $a0, AQUA
	jal set_foreground_color
	
	# deixa os pixeis do fundo da tela azul marinho
	li $a0, NAVY
	jal set_background_color
	
	# inicializa a tela gráfica 
	jal screen_init2
	
	### inicializa o vetor do tabuleiro
	# $t0 = i
	# $t1 = 0
	# $t2 = endereço de tabuleiro[i]
    	move $t0, $zero		# $t0 = 0
    	# (for int i = 0; i < 42; i++)
    	inicializa_vetor:
    		# guarda número gerado em tabuleiro[i]
    		sll $t2, $t0, 2			# $t2 = i * 4
    		add $t2, $t2, $s0		# $t2 = endereço de tabuleiro[i]
    		li $t1, 0			# $t1 = 0
    		sw $t1, 0($t2)			# tabuleiro[i] = rand() % 3
    			
    		# condição do laço
    		addi $t0, $t0, 1		# i++
    		blt $t0, 42, inicializa_vetor	# volta para o início do laço se i < 42
    	
    	# tela de apresentação do jogo
    	jal jogo_apresenta
    	
    	# desenha o tabuleiro
    	jal desenha_tabuleiro
    	
    	# laço principal do jogo
    	partida:
    		# muda de quem é a vez de jogar
    		la $a0, vez		# $a0 = endereço da variável vez
    		jal muda_vez		# muda de quem é a vez de jogar
    		sw $v0, 0($s3)		# atualiza o valor da variável vez
    		
    		# pede para o jogador realizar uma jogada
    		move $a0, $s0		
    		move $a1, $s1
    		move $a2, $s2
    		move $a3, $s3
    		jal faz_jogada
    		
    		# teste
    		move $a0, $s0
    		lw $a1, ($s1)
    		lw $a2, ($s2)
    		jal get_ficha
    		
    		# desenha as fichas
    		move $a0, $s0		# $a0 = endereço base do vetor tabuleiro
    		jal desenha_fichas	# desenha as fichas do tabuleiro
    		
    		# verifica se a partida acabou
    		move $a0, $s0		# $a0 = endereço base do vetor tabuleiro
    		lw $a1, 0($s1)
    		lw $a2, 0($s2)
    		lw $a3, 0($s3)
    		jal jogo_acabou
    		
    		beq $v0, $zero, partida

    	
    	# fim de jogo
    	jal jogo_quer_jogar
    	
    	# se quiser jogar, volta para o início do programa. Se não, encerra
    	beq $v0, 1, main
    	
# epílogo
        lw $ra, 0($sp)		# restaura o endereço de retorno
        addiu $sp, $sp, 4       # restaura a pilha
        jr $ra                  # retorna ao procedimento chamador
        
########################################################################################################################

# desenha a tela de apresentação do jogo
jogo_apresenta:

# prólogo
	addi $sp, $sp, -4		# ajusta a pilha
	sw $ra, 0($sp)			# guarda o endereço de retorno

# corpo do procedimento

	# muda a cor de desenho
	li $a0, RED
	jal set_foreground_color	# muda a cor de desenho para vermelho
	
	# desenha o título
	
	# C
	li $a0, 16
	li $a1, 3
	li $a2, 24
	li $a3, 3
	jal draw_line
	li $a0, 16
	li $a1, 4
	li $a2, 24
	li $a3, 4
	jal draw_line
	li $a0, 16
	li $a1, 5
	li $a2, 16
	li $a3, 8
	jal draw_line
	li $a0, 17
	li $a1, 5
	li $a2, 17
	li $a3, 8
	jal draw_line
	li $a0, 23
	li $a1, 5
	li $a2, 23
	li $a3, 8
	jal draw_line
	li $a0, 24
	li $a1, 5
	li $a2, 24
	li $a3, 8
	jal draw_line
	
	# O
	li $a0, 16
	li $a1, 12
	li $a2, 24
	li $a3, 12
	jal draw_line
	li $a0, 16
	li $a1, 13
	li $a2, 24
	li $a3, 13
	jal draw_line
	li $a0, 16
	li $a1, 16
	li $a2, 24
	li $a3, 16
	jal draw_line
	li $a0, 16
	li $a1, 17
	li $a2, 24
	li $a3, 17
	jal draw_line
	li $a0, 16
	li $a1, 14
	li $a2, 16
	li $a3, 15
	jal draw_line
	li $a0, 17
	li $a1, 14
	li $a2, 17
	li $a3, 15
	jal draw_line
	li $a0, 23
	li $a1, 14
	li $a2, 23
	li $a3, 15
	jal draw_line
	li $a0, 24
	li $a1, 14
	li $a2, 24
	li $a3, 15
	jal draw_line
	
	# N
	li $a0, 16
	li $a1, 21
	li $a2, 24
	li $a3, 21
	jal draw_line
	li $a0, 16
	li $a1, 26
	li $a2, 24
	li $a3, 26
	jal draw_line
	li $a0, 16
	li $a1, 22
	li $a2, 18
	li $a3, 22
	jal draw_line
	li $a0, 18
	li $a1, 23
	li $a2, 20
	li $a3, 23
	jal draw_line
	li $a0, 20
	li $a1, 24
	li $a2, 22
	li $a3, 24
	jal draw_line
	li $a0, 22
	li $a1, 25
	li $a2, 24
	li $a3, 25
	jal draw_line
	
	# N
	li $a0, 16
	li $a1, 30
	li $a2, 24
	li $a3, 30
	jal draw_line
	li $a0, 16
	li $a1, 35
	li $a2, 24
	li $a3, 35
	jal draw_line
	li $a0, 16
	li $a1, 31
	li $a2, 18
	li $a3, 31
	jal draw_line
	li $a0, 18
	li $a1, 32
	li $a2, 20
	li $a3, 32
	jal draw_line
	li $a0, 20
	li $a1, 33
	li $a2, 22
	li $a3, 33
	jal draw_line
	li $a0, 22
	li $a1, 34
	li $a2, 24
	li $a3, 34
	jal draw_line
	
	# E
	li $a0, 16
	li $a1, 39
	li $a2, 24
	li $a3, 39
	jal draw_line
	li $a0, 16
	li $a1, 40
	li $a2, 24
	li $a3, 40
	jal draw_line
	li $a0, 16
	li $a1, 41
	li $a2, 16
	li $a3, 44
	jal draw_line
	li $a0, 24
	li $a1, 41
	li $a2, 24
	li $a3, 44
	jal draw_line
	li $a0, 20
	li $a1, 41
	li $a2, 20
	li $a3, 43
	jal draw_line
	
	# C
	li $a0, 16
	li $a1, 48
	li $a2, 24
	li $a3, 48
	jal draw_line
	li $a0, 16
	li $a1, 49
	li $a2, 24
	li $a3, 49
	jal draw_line
	li $a0, 16
	li $a1, 50
	li $a2, 16
	li $a3, 53
	jal draw_line
	li $a0, 17
	li $a1, 50
	li $a2, 17
	li $a3, 53
	jal draw_line
	li $a0, 23
	li $a1, 50
	li $a2, 23
	li $a3, 53
	jal draw_line
	li $a0, 24
	li $a1, 50
	li $a2, 24
	li $a3, 53
	jal draw_line
	li $a0, 16
	li $a1, 57
	li $a2, 16
	li $a3, 62
	jal draw_line
	li $a0, 17
	li $a1, 57
	li $a2, 17
	li $a3, 62
	jal draw_line
	li $a0, 18
	li $a1, 59
	li $a2, 24
	li $a3, 59
	jal draw_line
	li $a0, 18
	li $a1, 60
	li $a2, 24
	li $a3, 60
	jal draw_line
	
	# 4
	li $a0, 30
	li $a1, 25
	li $a2, 42
	li $a3, 25
	jal draw_line
	li $a0, 30
	li $a1, 26
	li $a2, 42
	li $a3, 26
	jal draw_line
	li $a0, 30
	li $a1, 27
	li $a2, 42
	li $a3, 27
	jal draw_line
	li $a0, 30
	li $a1, 37
	li $a2, 53
	li $a3, 37
	jal draw_line
	li $a0, 30
	li $a1, 38
	li $a2, 53
	li $a3, 38
	jal draw_line
	li $a0, 30
	li $a1, 39
	li $a2, 53
	li $a3, 39
	jal draw_line
	li $a0, 40
	li $a1, 28
	li $a2, 40
	li $a3, 36
	jal draw_line
	li $a0, 41
	li $a1, 28
	li $a2, 41
	li $a3, 36
	jal draw_line
	li $a0, 42
	li $a1, 28
	li $a2, 42
	li $a3, 36
	jal draw_line
	
	# desenha as sombras das letras
	
	li $a0, YELLOW
	jal set_foreground_color	# muda a cor do fundo para amarelo
	
	# C
	li $a0, 17
	li $a1, 2
	li $a2, 25
	li $a3, 2
	jal draw_line
	li $a0, 25
	li $a1, 2
	li $a2, 25
	li $a3, 7
	jal draw_line
	li $a0, 18
	li $a1, 5
	li $a2, 18
	li $a3, 8
	jal draw_line
	
	# O
	li $a0, 17
	li $a1, 11
	li $a2, 25
	li $a3, 11
	jal draw_line
	li $a0, 25
	li $a1, 11
	li $a2, 25
	li $a3, 16
	jal draw_line
	li $a0, 18
	li $a1, 14
	li $a2, 18
	li $a3, 15
	jal draw_line
	
	# N
	li $a0, 17
	li $a1, 20
	li $a2, 25
	li $a3, 20
	jal draw_line
	li $a0, 19
	li $a1, 22
	li $a2, 21
	li $a3, 22
	jal draw_line
	li $a0, 21
	li $a1, 23
	li $a2, 23
	li $a3, 23
	jal draw_line
	li $a0, 23
	li $a1, 24
	li $a2, 25
	li $a3, 24
	jal draw_line
	li $a0, 25
	li $a1, 25
	jal put_pixel
	
	# N
	li $a0, 17
	li $a1, 29
	li $a2, 25
	li $a3, 29
	jal draw_line
	li $a0, 19
	li $a1, 31
	li $a2, 21
	li $a3, 31
	jal draw_line
	li $a0, 21
	li $a1, 32
	li $a2, 23
	li $a3, 32
	jal draw_line
	li $a0, 23
	li $a1, 33
	li $a2, 25
	li $a3, 33
	jal draw_line
	li $a0, 25
	li $a1, 34
	jal put_pixel
	
	# E
	li $a0, 17
	li $a1, 38
	li $a2, 25
	li $a3, 38
	jal draw_line
	li $a0, 25
	li $a1, 38
	li $a2, 25
	li $a3, 43
	jal draw_line
	li $a0, 17
	li $a1, 41
	li $a2, 17
	li $a3, 43
	jal draw_line
	li $a0, 21
	li $a1, 41
	li $a2, 21
	li $a3, 42
	jal draw_line
	
	# C
	li $a0, 17
	li $a1, 47
	li $a2, 25
	li $a3, 47
	jal draw_line
	li $a0, 25
	li $a1, 47
	li $a2, 25
	li $a3, 52
	jal draw_line
	li $a0, 18
	li $a1, 50
	li $a2, 18
	li $a3, 52
	jal draw_line
	
	# T
	li $a0, 17
	li $a1, 56
	li $a2, 18
	li $a3, 56
	jal draw_line
	li $a0, 18
	li $a1, 57
	li $a2, 18
	li $a3, 58
	jal draw_line
	li $a0, 19
	li $a1, 58
	li $a2, 25
	li $a3, 58
	jal draw_line
	li $a0, 25
	li $a1, 59
	jal put_pixel
	
	# 4
	li $a0, 31
	li $a1, 24
	li $a2, 43
	li $a3, 24
	jal draw_line
	li $a0, 43
	li $a1, 25
	li $a2, 43
	li $a3, 36
	jal draw_line
	li $a0, 54
	li $a1, 37
	li $a2, 54
	li $a3, 38
	jal draw_line
	li $a0, 31
	li $a1, 36
	li $a2, 39
	li $a3, 36
	jal draw_line
	li $a0, 44
	li $a1, 36
	li $a2, 54
	li $a3, 36
	jal draw_line
	
	# "clique 'enter' para jogar"
	# imprime uma newline
	la $a0, newline				# $a0 = endereço de newline
	li $v0, 4				# syscall para imprimir uma string
	syscall					# imrpime uma newline
	# exibe a mensagem
	la $a0, string_apresentacao 	# carrega o endereço da string em $a0
	li $v0, 4			# código de syscall para imprimir uma string
	syscall
	
	# repete até o usuário digitar 'enter'
	input_loop1:
		# lê um caractére
		la $a0, buffer		  # $a0 recebe o buffer para o caratere
		li $a1, 2		  # lê até 2 caractéres (inclui o '\0')
		li $v0, 8		  # código de syscall para ler uma string
		syscall			  # lê um caractere
		# Verifica se o caractere é '\n'
		lb $t0, buffer		  # $t0 = caractere digitado pelo usuário
		li $t1, 10		  # $t1 = código ASCII para '\n'
		bne $t0, $t1, input_loop1 # volta para input loop se o caractere digitado não for enter
		

# epílogo
	lw $ra, 0($sp)			# restaura o endereço de retorno
	addi $sp, $sp, 4		# ajusta a pilha
	jr $ra

########################################################################################################################
        
# desenha o tabuleiro no display de bitmap
desenha_tabuleiro:
	# *** mapa dos registradores ***
	# $s0 = *parei de usar no meio do desenvolvimento do procedimento
	# $s1 = i
	# $s2 = linha/coluna para começar desenho
	# $s3 = j

# prólogo
	
	# guarda os registradores na pilha
	addiu $sp, $sp, -20	# ajusta a pilha
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
		
# corpo do programa
		
	# limpa a tela
	li $a0, AQUA
	jal set_foreground_color
	# for (int i = 0; i < 63; i++)
	li $s1, 0			# int i = 0
	limpa_tela:
		move $a0, $s1		# lin0 = i
		li $a1, 0		# col0 = 0
		move $a2, $s1		# lin1 = i
		li $a3, 63		# col1 = 63
		jal draw_line		# desenha uma linha horizontal
		addi $s1, $s1, 1	# i++
		blt $s1, 63, limpa_tela # while i < 63
	
		
	li $a0, BLUE			# $a0 = hex de azul
	jal set_foreground_color	# muda a cor do desenho para azul
	
	# desenha as linhas vertiais
	# for (int i = 0; i < 8; i++)
	li $s1, 0			# $s1 = 0 (int i = 0)
	desenha_linhas_verticais:
		li $t0, 8		# $t0 = 8
		mult $s1, $t0		# i * 8
		mflo $s2		# $s2 = i * 8
		addi $s2, $s2, 4	# $s2 += 4 para deixar uma margem na esquerda
		# $s2 é a coluna sobre a qual deve-se desenhar uma linha
		li $a0, 3		# lin0 = 3
		move $a1, $s2		# col0 = $a1
		li $a2, 51		# lin1 = 51
		move $a3, $s2		# col1 = $a1
		jal draw_line		# desenha a linha vertical
		addi $s1, $s1, 1	# i++
		blt $s1, 8, desenha_linhas_verticais	# volta para o início do laço se i < 8
	
	# desenha as linhas horizontais
	# for (int i = 0; i < 7; i++)
	li $s1, 0		# $s1 = 0 (int i = 0)
	desenha_linhas_horizontais:
		li $t0, 8		# $t0 = 8
		mult $s1, $t0		# i * 8
		mflo $s2		# $s2 = i * 8
		addi $s2, $s2, 3	# $s2 += 3 para deixar uma margem em cima
		# $s2 é a linha sobre a qual deve-se desenhar uma linha
		move $a0, $s2		# lin0 = $s2
		li $a1, 4		# col0 = 4
		move $a2, $s2		# lin1 = $s2
		li $a3, 60		# col1 = 60
		jal draw_line		# desenha a linha horizontal
		addi $s1, $s1, 1	# i++
		blt $s1, 7, desenha_linhas_horizontais	# volta para o início do laço se i < 7
	
	# desenha as bordas do tabuleiro
	li $a0, 2		# lin0 = 2
	li $a1, 4		# col0 = 4
	li $a2, 2		# lin1 = 2
	li $a3, 60		# col1 = 60
	jal draw_line		# desenha a borda superior
	li $a0, 52		# lin0 = 52
	li $a1, 4		# col0 = 4
	li $a2, 52		# lin1 = 52
	li $a3, 60		# col1 = 60
	jal draw_line		# desenha a borda inferior
	li $a0, 2		# lin0 = 2
	li $a1, 3		# col0 = 3
	li $a2, 52		# lin1 = 52
	li $a3, 3		# col1 = 2
	jal draw_line		# desenha a borda da esquerda
	li $a0, 2		# lin0 = 2
	li $a1, 61		# col0 = 61
	li $a2, 52		# lin1 = 52
	li $a3, 61		# col1 = 61
	jal draw_line		# desenha a borda da direita
	
	# muda a cor de desenho
	li $a0, TEAL		
	jal set_foreground_color
	
	# desenha as bordas da tela
	li $a0, 0		# lin0 = 0
	li $a1, 0		# col0 = 0
	li $a2, 63		# lin1 = 63
	li $a3, 0		# col1 = 0
	jal draw_line		
	li $a0, 0		# lin0 = 0
	li $a1, 1		# col0 = 1
	li $a2, 63		# lin1 = 63
	li $a3, 1		# col1 = 1
	jal draw_line		
	li $a0, 0		# lin0 = 0
	li $a1, 2		# col0 = 2
	li $a2, 63		# lin1 = 63
	li $a3, 2		# col1 = 2
	jal draw_line		
	li $a0, 0		# lin0 = 0
	li $a1, 63		# col0 = 63
	li $a2, 63		# lin1 = 63
	li $a3, 63		# col1 = 63
	jal draw_line
	li $a0, 0		# lin0 = 0
	li $a1, 62		# col0 = 62
	li $a2, 63		# lin1 = 63
	li $a3, 62		# col1 = 62
	jal draw_line
	li $a0, 0		# lin0 = 0
	li $a1, 0		# col0 = 0
	li $a2, 0		# lin1 = 0
	li $a3, 63		# col1 = 63
	jal draw_line
	li $a0, 1		# lin0 = 1
	li $a1, 0		# col0 = 0
	li $a2, 1		# lin1 = 1
	li $a3, 63		# col1 = 63
	jal draw_line
	li $a0, 63		# lin0 = 63
	li $a1, 0		# col0 = 0
	li $a2, 63		# lin1 = 63
	li $a3, 63		# col1 = 63
	jal draw_line
	li $a0, 62		# lin0 = 62
	li $a1, 0		# col0 = 0
	li $a2, 62		# lin1 = 62
	li $a3, 63		# col1 = 63
	jal draw_line
	
	# desenha os números
	
	li $a0, BLACK		
	jal set_foreground_color
	
	# 0
	li $a0, 55
	li $a1, 8
	jal put_pixel
	li $a0, 55
	li $a1, 7
	jal put_pixel
	li $a0, 56
	li $a1, 7
	jal put_pixel
	li $a0, 57
	li $a1, 7
	jal put_pixel
	li $a0, 58
	li $a1, 7
	jal put_pixel
	li $a0, 59
	li $a1, 7
	jal put_pixel
	li $a0, 60
	li $a1, 8
	jal put_pixel
	li $a0, 60
	li $a1, 9
	jal put_pixel
	li $a0, 59
	li $a1, 9
	jal put_pixel
	li $a0, 58
	li $a1, 9
	jal put_pixel
	li $a0, 57
	li $a1, 9
	jal put_pixel
	li $a0, 56
	li $a1, 9
	jal put_pixel
	li $a0, 55
	li $a1, 8
	jal put_pixel
	#bomborasclart
	
	# 1
	li $a0, 55
	li $a1, 16
	li $a2, 60
	li $a3, 16
	jal draw_line
	li $a0, 56
	li $a1, 15
	jal put_pixel
	li $a0, 60
	li $a1, 15
	li $a2, 60
	li $a3, 17
	jal draw_line
	
	# 2
	li $a0, 55
	li $a1, 23
	li $a2, 55
	li $a3, 25
	jal draw_line
	li $a0, 56
	li $a1, 25
	jal put_pixel
	li $a0, 57
	li $a1, 24
	jal put_pixel
	li $a0, 58
	li $a1, 23
	li $a2, 60
	li $a3, 23
	jal draw_line
	li $a0, 60
	li $a1, 23
	li $a2, 60
	li $a3, 25
	jal draw_line
	
	# 3
	li $a0, 55
	li $a1, 31
	li $a2, 55
	li $a3, 33
	jal draw_line
	li $a0, 56
	li $a1, 33
	jal put_pixel
	li $a0, 57
	li $a1, 32
	jal put_pixel
	li $a0, 58
	li $a1, 33
	li $a2, 59
	li $a3, 33
	jal draw_line
	li $a0, 60
	li $a1, 32
	li $a2, 60
	li $a3, 31
	jal draw_line
	
	# 4
	li $a0, 55
	li $a1, 41
	li $a2, 60
	li $a3, 41
	jal draw_line
	li $a0, 57 
	li $a1, 41
	li $a2, 57
	li $a3, 39
	jal draw_line
	li $a0, 57
	li $a1, 39
	li $a2, 55
	li $a3, 39
	jal draw_line
	
	# 5
	li $a0, 55
	li $a1, 49
	li $a2, 55
	li $a3, 47
	jal draw_line
	li $a0, 55
	li $a1, 47
	li $a2, 57
	li $a3, 47
	jal draw_line
	li $a0, 57
	li $a1, 47
	li $a2, 57
	li $a3, 49
	jal draw_line
	li $a0, 57
	li $a1, 49
	li $a2, 59
	li $a3, 49
	jal draw_line
	li $a0, 60
	li $a1, 48
	li $a2, 60
	li $a3, 47
	jal draw_line
	
	# 6
	li $a0, 55
	li $a1, 57
	li $a2, 55
	li $a3, 56
	jal draw_line
	li $a0, 56
	li $a1, 55
	li $a2, 60
	li $a3, 55
	jal draw_line
	li $a0, 60
	li $a1, 56
	jal put_pixel
	li $a0, 59
	li $a1, 57
	li $a2, 57
	li $a3, 57
	jal draw_line
	li $a0, 57
	li $a1, 56
	jal put_pixel
	
# epílogo
	
	# restaura os registradores
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addiu, $sp, $sp, 20	# ajusta a pilha
	
	jr $ra
	
########################################################################################################################

# desenha as fichas inseridas no tabuleiro
# argumentos:
# $a0: endereço base do vetor tabuleiro[42]
desenha_fichas:

# *** mapa dos registradores ***
# $s0 = endereço base de tabuleiro[42]
# $s1 = i
# $s2 = j

# prólogo
	addiu $sp, $sp, -16		# ajusta a pilha
	# guarda os registradores
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)			
        sw $ra, 0($sp)
        
# corpo do procedimento

	# carregamso as variáveis
	move $s0, $a0			# $s0 = endereço base de tabuleiro[42]
	
	# for (int i = 0; i < 6; i++) para iterar pelas linhas (elas tem que ser imprimadas de baixo para cima)
	li $s1, 0			# int i = 5
	for_linhas:
		# for (int j = 0; j < 7; j++) para iterar pelas colunas
		li $s2, 0		# int j = 0
		for_colunas:
		
			# extraindo o valor de tabuleiro[i][j]
			li $t0, 7		# $t0 = 7 (n_colunas)
			mult $s1, $t0		# i * 7 (n_colunas)
			mflo $t0		# $t0 = i * 7
			add $t0, $t0, $s2	# $t0 = i * 7 + j
			sll $t0, $t0, 2		# $t0 *= 4
			add $t0, $t0, $s0	# $t0 = endereço de tabuleiro[i][j]
			lw $t0, 0($t0)		# $t0 = valor em tabuleiro[i][j]
			
			# desenha a ficha
			move $a0, $t0		# $a0 = cor
			# ajusta a linha para impressão de baixo para cima
			li $t0, 5
			sub $t0, $t0, $s1
			sll $a1, $t0, 3		# $a1 = linha * 8
			addi $a1, $a1, 7
			sll $a2, $s2, 3		# $a2 = coluna * 8
			addi $a2, $a2, 8
			jal desenha_ficha
			
			
			
			# testes do laço
			addi $s2, $s2, 1	# j++
			blt $s2, 7, for_colunas	# j < 7
			
		# testes do laço
		addi $s1, $s1, 1		# i++
		blt $s1, 6, for_linhas 		# i < 6
	nop

# epílogo
	# restaura os registradores
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)		
        addiu $sp, $sp, 16       # restaura a pilha
        jr $ra 
	
########################################################################################################################

# desenha uma única ficha
# argumentos:
# $a0: cor da ficha
# $a1: linha 
# $a2: coluna
desenha_ficha:
# *** mapa dos registradores ***
# $s0 = $a0
# $s1 = $a1
# $s2 = $a2

# prólogo
	addiu $sp, $sp, -16		# ajusta a pilha
	# guarda os registradores
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
        sw $ra, 0($sp)

# corpo do procedimento

	# carregamos as variáveis
	move $s0, $a0			# $s0 = cor
	move $s1, $a1			# $s1 = linha
	move $s2, $a2			# $s2 = coluna

	# switch(cor)
	# case 1:
	li $t0 1			# $t0 = 1
	beq $s0, $t0, amarela		# vai para amarela se $s0 == 1
	# case 2:
	addi $t0, $t0, 1		# $t0 = 2
	beq $s0, $t0, vermelha		# vai para vermelha se $s0 ==2
	# case 0:
	
	nenhuma:
		# troca a cor para AQUA
		li $a0, AQUA
		jal set_foreground_color
		j switch_cor_fim
	amarela:
		# troca a cor para YELLOW
		li $a0, YELLOW
		jal set_foreground_color
		j switch_cor_fim
	vermelha:
		# troca a cor para RED
		li $a0, RED
		jal set_foreground_color
		j switch_cor_fim
		
	switch_cor_fim:
		
	### desenha a ficha
	move $a0, $s1		
	move $a1, $s2		
	jal put_pixel
	addi $a0, $s1, 1
	addi $a1, $s2, 1
	jal put_pixel
	addi $a0, $s1, -1
	addi $a1, $s2, 1
	jal put_pixel
	addi $a0, $s1, 1
	addi $a1, $s2, -1
	jal put_pixel
	addi $a0, $s1, -1
	addi $a1, $s2, -1
	jal put_pixel
	move $a0, $s1
	addi $t0, $s2, -2
	move $a1, $t0
	move $a2, $s1
	addi $t0, $s2, 2
	move $a3, $t0
	jal draw_line
	addi $t0, $s1, -2
	move $a0, $t0
	move $a1, $s2
	addi $t0, $s1, 2
	move $a2, $t0
	move $a3, $s2
	jal draw_line
	addi $a0, $s1, 1
	addi $a1, $s2, 2
	jal put_pixel
	addi $a0, $s1, 1
	addi $a1, $s2, -2
	jal put_pixel
	addi $a0, $s1, -1
	addi $a1, $s2, 2
	jal put_pixel
	addi $a0, $s1, -1
	addi $a1, $s2, -2
	jal put_pixel
	addi $a0, $s1, 2
	addi $a1, $s2, 1
	jal put_pixel
	addi $a0, $s1, 2
	addi $a1, $s2, -1
	jal put_pixel
	addi $a0, $s1, -2
	addi $a1, $s2, 1
	jal put_pixel
	addi $a0, $s1, -2
	addi $a1, $s2, -1
	jal put_pixel
	
	
# epílogo
	# restaura os registradores
        lw $ra, 0($sp)
        lw $s0, 4($sp)
        lw $s1, 8($sp)
        lw $s2, 12($sp)
        addiu $sp, $sp, 16       # restaura a pilha
        jr $ra
        
########################################################################################################################

# pergunta ao jogador se ele quer jogar denovo
# retorna 1 em $v0 se jogador quer jogar denovo, caso contrário, retorna 0
# valor de retorno:
# $v0 = 1 ou 0
jogo_quer_jogar:
# prólogo
	addi $sp, $sp, -4		# ajusta a pilha
	sw $ra, 0($sp)			# guarda o endereço de retorno
	
# corpo do procedimento

	# Imprime a string_fim1
    	la $a0, string_fim1   		# Carrega o endereço de string_fim1 para $a0
    	li $v0, 4             		# Código do syscall para imprimir string
    	syscall
    	# Quebra de linha
    	li $a0, 10            		# Código ASCII para '\n'
    	li $v0, 11            		# Código do syscall para imprimir caractere
    	syscall
    	# Imprime a string_fim2
    	la $a0, string_fim2   		# Carrega o endereço de string_fim2 para $a0
    	li $v0, 4             		# Código do syscall para imprimir string
    	syscall
    	
    	# Lê um caractere
    	li $v0, 8               	# Código do syscall para ler string
   	la $a0, buffer          	# Endereço para armazenar o caractere
    	li $a1, 2               	# Tamanho máximo da entrada (1 caractere + '\0')
    	syscall
    	
	# verifica se o caractere digitado é 's'
	lb $t0, buffer			# $t0 = caractere digitado pelo usuário
	li $t1, 's'			# $t0 = 's'
	beq $t0, $t1, return_true	# vai para "return_true" se $t0 = $t1
	li $v0, 0			# retorna 0
	j quer_jogar_exit		# pula pro final do procedimento
	
	return_true:
		li $v0, 1		# retorna 1
    	
	quer_jogar_exit:
# epílogo
	lw $ra, 0($sp)			# restaura o endereço de retorno
        addiu $sp, $sp, 4       	# restaura a pilha
        jr $ra                  	# retorna ao procedimento chamador

########################################################################################################################

# muda de quem é a vez de jogar
# >>> argumentos:
#	> $a0 = endereço da variável vez
# >>> valor de retorno:
#	> $v0 = 1 se for vez do vermelho, 2 se for vez do amarelo
muda_vez:
# prólogo
	addi $sp, $sp, -4	# ajusta a pilha
	sw $ra, 0($sp)		# guarda o endereço de retorno
	
# corpo do procedimento
	li $t0, 1			# $t0 = 1
	lw $t1, 0($a0)			# $t1 = vez
	beq $t0, $t1, muda_pro_amarelo  # se vez == 1
	
	muda_pro_vermelho:
		li $v0, 1		# $v0 = 1
		j muda_vez_exit		# pula pro final do procedimento
	
	muda_pro_amarelo:
		li $v0, 2		# $v0 = 2
		
	muda_vez_exit:
		nop

# epílogo
	lw $ra, 0($sp)		# restaura o endereço de retorno
	addi $sp, $sp, 4	# ajusta a pilha
	jr $ra			# retorna ao procedimento que chamou

########################################################################################################################

# valida e realiza a jogada do jogador
# >>> argumentos:
#	> $a0 = endereço base do vetor tabuleiro
#	> $a1 = endereço da variável linha
#	> $a2 = endereço da variável coluna
#	> $a3 = endereço da variável vez
faz_jogada:
# prólogo
	# *** mapa da pilha ***
	# 16($sp) = $s3
	# 12($sp) = $s2
	# 8($sp) = $s1
	# 4($sp) = $s0
	# 0($sp) = $ra
	
	addi $sp, $sp, -24		# ajusta a pilha
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s2, 12($sp)
	sw $s1, 8($sp)
	sw $s0, 4($sp)
	sw $ra, 0($sp)
	
# corpo do procedimento
	# *** mapa dos registradores ***
	# $s0 = endereço base do vetor tabuleiro
	# $s1 = endereço da variável linha
	# $s2 = endereço da variável coluna
	# $s3 = endereço da variável vez
	# $s4 = jogada do jogador
	
	# carregamos as variáveis
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3

	# imprime mensagem pedindo jogada do jogador
	la $a0, string_jogada1			# $a0 = endereço da string string_jogada1
	li $v0, 4				# $v0 = código de syscall para imprimir uma string
	syscall					# imprime string_jogada1
	li $t0, 1				# $t0 = 1
	lw $t1, 0($s3)				# valor da variável vez
	beq $t1, $t0, vez_do_vermelho		# se vez = 1 (vermelho)
	vez_do_amarelo:
		la $a0, string_jogada2		# carrega stinrg_jogada2 para impressão
		j faz_jogada_mensagem_exit	# pula pra impressão de mensagem
	vez_do_vermelho:
		la $a0, string_jogada3		# carrega stinrg_jogada3 para impressão
	faz_jogada_mensagem_exit:
	li $v0, 4				# syscall para imprimir uma string
	syscall					# imprime stinrg_jogada2/3
	
	# repete até o jogador passar uma jogada válida
	pede_jogada:
		li $v0, 5			# syscall para ler um inteiro
		syscall				# lê um inteiro do usuário
		move $t0, $v0			# $t0 = input do usuário
	
		### realiza testes para ver se a jogada é válida
		# verifica se a coluna é maior que zero
		blt $t0, $zero, pede_jogada
		# verifica se a coluna é menor do que 7
		li $t1, 7
		bge $t0, $t1, pede_jogada
		# verifica se essa coluna está cheia
		addi $t1, $t0, 35		# pega o índice do espaço do topo dessa coluna
		sll $t1, $t1, 2			# múltiplica o índice por 4
		add $t1, $t1, $s0		# pega o endereço desse índice
		lw $t1, 0($t1)			# pega o valor nesse índice
		bne $t1, $zero, pede_jogada	# volta se esse índice tiver uma ficha
		
	move $s4, $t0				# $s4 = coluna escolhida pelo jogador
	
	# imprime uma newline
	la $a0, newline				# $a0 = endereço de newline
	li $v0, 4				# syscall para imprimir uma string
	syscall					# imrpime uma newline
	
	# procura a primeira linha vazia na coluna escolhida
	# for (int i = 0; i < N_LINHAS; i++)
	li $t0, 0				# int i = 0
	for_procura_linha_vazia:
		# if (tabuleiro[i * N_COLUNAS + col] == NENHUMA)
		li $t1, 7			# $t1 = 7
		mult $t0, $t1			# i * 7
		mflo $t1			# $t1 = i * 7
		add $t1, $t1, $s4		# $t1 = i * 7 + col_jogada
		sll $t1, $t1, 2			# $t1 *= 4
		add $t1, $t1, $s0		# $t1 = endereço de tabuleiro[i][col_jogada] 
		lw $t2, 0($t1)			# $t2 = valor em tabuleiro[i][col_jogada]
		
		# se essa linha estiver vazia ($t1 == 0)
		beq $t2, $zero, realiza_jogada
		 
		# condição do laço
		addi $t0, $t0, 1
		li $t1, 6			# $t1 = 6
		blt $t0, $t1, for_procura_linha_vazia
		
	realiza_jogada:
		lw $t3, 0($s3)		# $t2 = vez (1 ou 2)
		sw $t3, 0($t1)		# coloca uma ficha da cor devida no tabuleiro
		sw $t0, 0($s1)		# linha = i
		sw $s4, 0($s2)		# coluna = jogada
	
# epílogo

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 20		# ajusta a pilha
	jr $ra				# retorna ao procedimento que chamou

########################################################################################################################

# retorna o valor da ficha em uma posição (ou -1 se estiver fora dos limites)
# >>> argumentos:
#	> $a0 = endereço base do tabuleiro
#	> $a1 = linha
# 	> $a2 = coluna
# >>> valor de retorno:
#	> $v0 = 1 (vermelha), 2 (amarela), ou -1 (fora do limite do tabuleiro)
get_ficha:
# prólogo
	addi $sp, $sp, -4		# ajusta a pilha
	sw $ra, 0($sp)			# guarda o endereço de retorno
	
# corpo do procedimento
	# verifica se a ficha está fora dos limites do tabuleiro
	blt $a1, $zero, fora_dos_limites
	bge $a1, 6, fora_dos_limites 
	blt $a2, $zero, fora_dos_limites
	bge $a2, 7, fora_dos_limites
	
	# obtem o valor da ficha em tabuleiro[linha][coluna]
	li $t0, 7			# $t0 = n_colunas
	mult $a1, $t0			# linha * n_colunas
	mflo $t0			# $t0 = linha * n_colunas
	add $t0, $t0, $a2		# $t0 = índice da ficha em linha x coluna
	sll $t0, $t0, 2			# $t0 *= 4
	add $t0, $t0, $a0		# $t0 = endereço da ficha
	lw $v0, 0($t0)			# valor de retorno = valor da ficha (1 ou 2)
	j get_ficha_exit
	
	fora_dos_limites:
		li $v0, -1		# valor de retorno = -1
		
	get_ficha_exit:
		nop

# epílogo
	lw $ra, 0($sp)			# restaura o endereço de retorno
	addi $sp, $sp, 4		# ajusta a pilha
	jr $ra				# retorna ao procedimento que chamou
	

########################################################################################################################

# verifica se tem quatro fichas da mesma cor enfileradas
# >>> argumentos:
#	> $a0 = endereço base do tabuleiro
#	> $a1 = linha da última jogada
#	> $a2 = coluna da última jogada
#	> $a3 = vez de quem é jogar
# >>> valor de retorno:
#	> $v0 = 0 se não acabou, 1 se acabou

jogo_acabou:
# prólogo
	addi $sp, $sp, -24	# ajusta a pilha
	sw $s4, 20($sp)
	sw $s3, 16($sp)
	sw $s2, 12($sp)	
	sw $s1, 8($sp)
	sw $s0, 4($sp)	
	sw $ra, 0($sp)	

# corpo do procedimento
	# *** mapa dos registradores ***
	# $s0 = endereço base do vetor tabuleiro
	# $s1 = linha da última jogada
	# $s2 = coluna da última jogada
	# $s3 = vez de quem é de jogar
	# $s4 = número de fichas seguidas
	# $s5 = i
	
	# carrega as variáveis
	move $s0, $a0
	move $s1, $a1
	move $s2, $a2
	move $s3, $a3
	
	# temos que verificar se há fichas iguais no sentido horizontal, vertical, diagonal primária 
	# e diagonal secundária, tanto no sentido positivo quanto no negativo
	
	### verifica no sentido horiziontal
	li $s4, 1				# n_fichas_seguidas = 1
	# horizontal positivo
	# for (int i = 1; i < 4; i++)
	li $s5, 1			# i = 1
	for_horizontal_positivo:
		# acha a ficha em tabuleiro[linha][coluna+i]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		move $a1, $s1				# $a1 = linha
		add $a2, $s2, $s5			# $a2 = coluna + i
		jal get_ficha				# acha a ficha em tabuleiro[linha][coluna+i]
		# se as fichas não forem iguais
		bne $v0, $s3, for_horizontal_positivo_diferentes	# bomborasclart
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++	
		for_horizontal_positivo_diferentes:
		# condição do for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_horizontal_positivo
	
	# horizontal negativo
	# for (int i = 1; i < 4; i++)
	li $s5, 1			# i = 1
	for_horizontal_negativo:
		# acha a ficha em tabuleiro[linha][coluna-i]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		move $a1, $s1				# $a1 = linha
		sub $a2, $s2, $s5			# $a2 = coluna + i
		jal get_ficha				# acha a ficha em tabuleiro[linha][coluna-i]
		# se as fichas não forem iguais
		bne $v0, $s3, for_horizontal_negativo_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++	
		for_horizontal_negativo_diferentes:
		# condição do for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_horizontal_negativo
	
	bge $s4, 4, jogo_acabou_true			# se n_fichas seguidas >= 4, o jogo acabou
	
	
	### verifica no sentido vertical
	li $s4, 1			# n_fichas_seguidas = 1
	# vetical positivo
	# for (int i = 1; i < 4; i++)
	li $s5, 1			# i = 1
	for_vertical_positivo:
		# acha a ficha em tabuleiro[linha+i][coluna]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		add $a1, $s1, $s5			# $a1 = linha + i
		move $a2, $s2				# $a2 = coluna
		jal get_ficha				# acha a ficha em tabuleiro[linha+i][coluna]
		# se as fichas não forem iguais
		bne $v0, $s3, for_vertical_positivo_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_vertical_positivo_diferentes:
		#condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_vertical_positivo
	
	# vetical negativo
	# for (int i = 1; i < 4; i++)
	li $s5, 1			# i = 1
	for_vertical_negativo:
		# acha a ficha em tabuleiro[linha+i][coluna]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		sub $a1, $s1, $s5			# $a1 = linha + i
		move $a2, $s2				# $a2 = coluna
		jal get_ficha				# acha a ficha em tabuleiro[linha-i][coluna]
		# se as fichas não forem iguais
		bne $v0, $s3, for_vertical_negativo_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_vertical_negativo_diferentes:
		#condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_vertical_negativo
		
	bge $s4, 4, jogo_acabou_true			# se n_fichas seguidas >= 4, o jogo acabou
	
	
	### diagonal primária
	li $s4, 1				# n_fichas_seguidas = 1
	# diagonal primária positiva
	# for (int i = 1; i < 4; i++)
	li $s5, 1				# int i = 1
	for_diagonal_primaria_positiva:
		# acha a ficha em tabuleiro[linha+1][coluna+1]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		add $a1, $s1, $s5			# $a1 = linha + i
		add $a2, $s2, $s5			# $a2 = coluna + i
		jal get_ficha
		# se as fichas não forem iguais
		bne $v0, $s3, for_diagonal_primaria_positiva_diferentes		# BOMBOCLART
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_diagonal_primaria_positiva_diferentes:
		# condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_diagonal_primaria_positiva
		
	# diagonal primária negativa
	# for (int i = 1; i < 4; i++)
	li $s5, 1				# int i = 1
	for_diagonal_primaria_negativa:
		# acha a ficha em tabuleir[linha+1][coluna+1]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		sub $a1, $s1, $s5			# $a1 = linha - i
		sub $a2, $s2, $s5			# $a2 = coluna - i
		jal get_ficha
		# se as fichas não forem iguais
		bne $v0, $s3, for_diagonal_primaria_negativa_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_diagonal_primaria_negativa_diferentes:
		# condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_diagonal_primaria_negativa
		
	bge $s4, 4, jogo_acabou_true			# se n_fichas seguidas >= 4, o jogo acabou
		
	
	### diagonal secundária
	li $s4, 1				# n_fichas_seguidas = 1
	# diagonal secundária positiva
	# for (int i = 1; i < 4; i++)
	li $s5, 1				# int i = 1
	for_diagonal_secundaria_positiva:
		# acha a ficha em tabuleiro[linha+1][coluna-1]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		add $a1, $s1, $s5			# $a1 = linha + i
		sub $a2, $s2, $s5			# $a2 = coluna - i
		jal get_ficha				# pega o valor da ficha em tabuleiro[linha+1][coluna-1]
		# se as fichas não forem iguais
		bne $v0, $s3, for_diagonal_secundaria_positiva_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_diagonal_secundaria_positiva_diferentes:
		# condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_diagonal_secundaria_positiva
	
	# diagonal secundária negativa
	# for (int i = 1; i < 4; i++)
	li $s5, 1				# int i = 1
	for_diagonal_secundaria_negativa:
		# acha a ficha em tabuleiro[linha-1][coluna-1]
		move $a0, $s0				# $a0 = endereço base do vetor tabuleiro
		sub $a1, $s1, $s5			# $a1 = linha - i
		add $a2, $s2, $s5			# $a2 = coluna - i
		jal get_ficha				# pega o valor da ficha em tabuleiro[linha-1][coluna-1]
		# se as fichas não forem iguais
		bne $v0, $s3, for_diagonal_secundaria_negativa_diferentes
		# se forem iguais, n_fichas_seguidas++
		addi $s4, $s4, 1			# n_fichas_seguidas++
		for_diagonal_secundaria_negativa_diferentes:
		# condição for
		addi $s5, $s5, 1			# i++
		blt $s5, 4, for_diagonal_secundaria_negativa

	bge $s4, 4, jogo_acabou_true			# se n_fichas seguidas >= 4, o jogo acabou
							
	jogo_acabou_false:
		li $v0, 0			# valor de retorno = false
		j jogo_acabou_exit
		
	jogo_acabou_true:
		li $v0, 1			# valor de retorno = true
		
	jogo_acabou_exit:
		nop
	
# epílogo
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 4	# ajusta a pilha
	jr $ra			# retorna ao procedimento que chamou

########################################################################################################################

exit:
	nop

