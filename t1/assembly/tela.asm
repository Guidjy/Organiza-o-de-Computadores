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

# variáveis do jogo
.data
tabuleiro:	.space 168	# vetor que representa o tabuleiro de connect 4
linha:		.word 0		# armazenar a jogada de um jogador
coluna:		.word 0		# armazenar a jogada de um jogador
vez:		.word 0		# indica de qual jogador é a vez de jogar

########################################################################################################################

.text

# executa no início da execução
init:
	jal main
	jal exit 	
	
########################################################################################################################

.include "display_bitmap.asm"

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
	
	# deixa os pixeis do fundo da tela pretos
	li $a0, AQUA
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
    	
    	# desenha o tabuleiro
    	jal desenha_tabuleiro
    	
    	
    	 	
	
	
	
	
# epílogo
        lw $ra, 0($sp)		# restaura o endereço de retorno
        addiu $sp, $sp, 4       # restaura a pilha
        jr $ra                  # retorna ao procedimento chamador
        
########################################################################################################################
        
# recebe o vetor do tabuleiro como argumento e desenha as fichas na tela
# argumentos:
# $a0 : endereço base do vetor tabuleiro[42]
desenha_tabuleiro:
	# *** mapa dos registradores ***
	# $s0 = *parei de usar no meio do desenvolvimento do procedimento
	# $s1 = i
	# $s2 = linha/coluna para começar desenho
	# $s3 = j

# prólogo
	addiu $sp, $sp, -4		# ajusta a pilha
        sw $ra, 0($sp)         		# guarda na pilha o endereço de retorno
	
# corpo do programa
		
	# tá com uma linha preta esquesita no canto superior esquerdo do bitmap
	# apesar de não termos usados nenhum procedimento ainda então tem que pintar
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 50
	jal draw_line
		
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
        lw $ra, 0($sp)		# restaura o endereço de retorno
        addiu $sp, $sp, 4       # restaura a pilha
        jr $ra                  # retorna ao procedimento chamador
	
	
	
	
	
exit:
	nop
