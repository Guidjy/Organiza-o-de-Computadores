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
string_fim1:		.asciiz "-=-=-=-=-=- GAME OVER -=-=-=-=-=-"
string_fim2:		.asciiz "> Jogar de novo? [s/n]"

########################################################################################################################

.text

# testes das funções de display de bitmap
main:
	# *** mapa dos registradores ***
	# $s0 = endereço base de tabuleiro
	# $s1 = endereço da variável linha
	# $s2 = endereço da variável coluna
	# $s3 = endereço da variável vez
	# $t0 = coordenada x0
	# $t1 = coordenada y0
	# $t2 = coordenada x1
	# $t3 = coordenada y1
	
# prólogo
	addiu $sp, $sp, -4	# ajusta a pilha
        sw $ra, 0($sp)         	# guarda na pilha o endereço de retorno
	
# corpo do programa

	# carrega as variáveis
	la $s0, tabuleiro	# $s0 = endereço base de tabuleiro
	
	# deixa os pixeis de desenho brancos
	li $a0, AQUA
	jal set_foreground_color
	
	# deixa os pixeis do fundo da tela azul marinho
	li $a0, NAVY
	jal set_background_color
	
	# inicializa a tela gráfica 
	jal screen_init2
	
	### inicializa o vetor do tabuleiro para tesagem
	# $t0 = i
	# $t1 = número aleatório entre 0 - 2
	# $t2 = endereço de tabuleiro[i]
    	move $t0, $zero		# $t0 = 0
    	# (for int i = 0; i < 42; i++)
    	inicializa_vetor:
    		# gera um número aleatório
    		li $v0, 42       		# syscall para gerar número aleatório
		li $a0, 1			# argumento para a syscall
		li $a1, 3			# limite superior para o valor do int gerado
    		syscall				# $a0 = número aleatório
    		move $t1, $a0			# $t1 = número aleatório
    		
    		# guarda número gerado em tabuleiro[i]
    		sll $t2, $t0, 2			# $t2 = i * 4
    		add $t2, $t2, $s0		# $t2 = endereço de tabuleiro[i]
    		sw $t1, 0($t2)			# tabuleiro[i] = rand() % 3
    		
    		# imprime vetor para testar
    		lw $t3, 0($t2)			# $t3 = valor de tabuleiro[i]
    		li $v0, 1			# código de syscall para imprimir um inteiro
    		move $a0, $t3			# passa $t3 para impressão
    		syscall
    		# imprime um espaço vazio
    		li $v0, 11            		# Código de syscall para imprimir um caractere
		li $a0, ' '           		# Caractere de espaço
		syscall               		# Chama a syscall para imprimir o espaço
    			
    		# condição do laço
    		addi $t0, $t0, 1		# i++
    		blt $t0, 42, inicializa_vetor	# volta para o início do laço se i < 42
    	# imprime uma newline
	li $a0, 10           # Carrega o valor ASCII de '\n' (10) no registrador $a0
    	li $v0, 11           # Código de serviço para imprimir caractere
    	syscall              # Chama o serviço de sistema para imprimir o caractere
    	
    	# tela de apresentação do jogo
    	jal jogo_apresenta
    	
    	# desenha o tabuleiro
    	jal desenha_tabuleiro
    	
    	# desenha as fichas
    	move $a0, $s0		# $a0 = endereço base de tabuleiro
    	jal desenha_fichas
    	
    	# fim de jogo
    	jal jogo_quer_jogar
    	
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
	
	# for (int i = 5; i >= 0; i--) para iterar pelas linhas (elas tem que ser imprimadas de baixo para cima
	li $s1, 5			# int i = 5
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
			sll $a1, $s1, 3		# $a1 = linha * 8
			addi $a1, $a1, 7
			sll $a2, $s2, 3		# $a2 = coluna * 8
			addi $a2, $a2, 8
			jal desenha_ficha
			
			
			
			# testes do laço
			addi $s2, $s2, 1	# j++
			blt $s2, 7, for_colunas	# j < 7
			
		# testes do laço
		addi $s1, $s1, -1		# i--
		bge $s1, $zero, for_linhas 	# i >= 0
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

exit:
	nop
