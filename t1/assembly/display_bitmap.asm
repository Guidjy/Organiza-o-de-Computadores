#***********************************************************************************************************************
# Autor: Giovani Baratto (GBTO) - UFSM - CT - DELC
# e-mail: giovani.baratto@ufsm.br
# Descrição: Procedimentos, variáveis e constantes para usar com a ferramenta bitmap display. 
# 
# Como usar:
# antes do procedimento main, inclua a seguite linha:
# .include "display_bitmap.asm"
# O arquivo display_bitmap.asm deve estar no mesmo diretório do arquivo com o procedimento main.
# Você poderá usar os seguintes procedimentos deste arquivo no seu programa.
# (a) coordinates_to_address:   retorna o endereço da memória da tela gráfica, correspondente a coordenada (x,,y)
# (b) set_foreground_color:     Escolhe a cor de desenho dos pixels
# (c) set_background_color:     Escolhe a cor do fundo da tela
# (d) screen_init:              Inicializa a tela gráfica
# (e) screen_init2:             Inicializa a tela gráfica, versão otimizada
# (f) put_pixel:                Escreve um pixel na ferramenta bitmap display na cor da variável screen_color
# (g) draw_rectangle:           Desenha um retangulo com as coordenadas P0(x0, y0) e P1(x1, y1)
# (h) draw_circle:              Desenho de um círculo com centro no ponto P0(x0, y0) de raio r.
# (i) draw_line:                Desenho de uma linha usando o algoritmo de Bresenham, de um ponto P0(x0, y0) para P1(x1, y1)
#
# Configure a ferramenta bitmap display com os seguintes parâmetros:
# Unit Width in Pixels              8
# Unit Height in Pixels             8
# Display Width in Pixels           512
# Display Height in Pixels          512
# Base address for display          0x      10010000 (static data) 
# 
#***********************************************************************************************************************
#                                                                                                  1         1         1
#        1         2         3         4         5         6         7         8         9         0         1         2
#23456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
#           M       O                   #

########################################################################################################################
# dimensões da tela
.eqv UNIT_WIDTH     8                   # unidade da largura em pixels
.eqv UNIT_HEIGHT    8                   # unidade da altura em pixels
.eqv DISPLAY_WIDTH  512                 # largura da tela gráfica em pixels
.eqv DISPLAY_HEIGHT 512                 # altura da tela gráfica em pixels
.eqv SCREEN_WIDTH   64                  # largura da tela: DISPLAY_WIDTH/UNIT-WIDTH
.eqv SCREEN_HEIGHT  64                  # altura da tela: DISPLAY_HEIGHT/UNIT_HEIGHT
.eqv SCREEN_MEMORY_DIMENSION 16384      # tamanho da memória utilizada pela tela gráfica =  64 x 64 x 4 bytes
.eqv DISPLAY_MEMORY_BASE 0x10010000     # endereço base da memória da tela gráfica

# Tabela de cores em formato hexadecimal com nomes em português
.eqv BLACK	        0x00000000         	# Preto
.eqv SILVER	        0x00C0C0C0	        # Prata
.eqv GRAY	        0x00808080	        # Cinza
.eqv WHITE	        0x00FFFFFF	        # Branco
.eqv MAROOM	        0x00800000	        # Marrom
.eqv RED	        0x00FF0000	        # Vermelho
.eqv PURPLE	        0x00800080	        # Roxo
.eqv FUCHSIA	    	0x00FF00FF          	# Rosa	
.eqv GREEN	        0x00008000	        # Verde
.eqv LIME	        0x0000FF00	        # Limão
.eqv OLIVE	        0x00808000	        # Oliva
.eqv YELLOW	        0x00FFFF00	        # Amarelo
.eqv NAVY	        0x00000080	        # Marinho
.eqv BLUE	        0x000000FF	        # Azul
.eqv TEAL	        0x00008080	        # Ciano
.eqv AQUA	        0x0000FFFF              # Aqua
########################################################################################################################

.data DISPLAY_MEMORY_BASE
########################################################################################################################
dm:                 .space SCREEN_MEMORY_DIMENSION # memória do display = 64 x 64 x 4 bytes
screen_color:       .word WHITE         # cor dos pixels desenhados
screen_background_color: .word BLUE     # cor do fundo da tela
########################################################################################################################


.text

########################################################################################################################
# retorna o endereço da memória da tela gráfica, correspondente a coordenada (x,,y)
# usamos a equação
# ADDRESS = DISPLAY_MEMORY_BASE + (SCREEN_WIDTH*(row*4)) + (column*4)
# Argumentos
# $a0 : coordenada x na tela (row)
# $a1 : coordenada y na tela (column)
# retorno
# $v0 : endereço de memória da correspondente coordenada retangular (x,y). Retorna -1 se houve um erro
#
# TODO: Para fazer
# adicionar um código para verificar se as coordenadas estão dentro dos valores da tela:
# 0 < x < (SCREEN_WIDTH-1) e 
# 0 < y < (SCREEN_HEIGHT-1)
########################################################################################################################
coordinates_to_address:
########################################################################################################################
# prólogo
# corpo do programa
            # verificamos os limites das coordenadas row e collumn
            slti    $t0, $a0, 0         # $t0 = 1 se x < 0
            bnez    $t0, cta_error      # Se x < 0, ir para o rótulo de erro
            slti    $t1, $a1, 0         # $t1 = 1 se y < 0
            bnez    $t1, cta_error      # Se y < 0, ir para o rótulo de erro
            sltiu   $t2, $a0, SCREEN_WIDTH  # $t2 = 1 se x < SCREEN_WIDTH
            beqz    $t2, cta_error      # Se x >= SCREEN_WIDTH, ir para o rótulo de erro
            sltiu   $t3, $a1, SCREEN_HEIGHT  # $t3 = 1 se y < SCREEN_HEIGHT
            beqz    $t3, cta_error      # Se y >= SCREEN_HEIGHT, ir para o rótulo de erro
            # calculamos o endereço de memória
            li      $t0, SCREEN_WIDTH   # $t0 <- SCREEN_WIDTH
            sll     $a0, $a0, 2         # $a0 <- ROW*4
            mul     $v0, $a0, $t0       # [hi:lo] <- $a0*$t0; $v0 <- lo; $v0 <- SCREEN_WIDTH*(ROW*4)
            sll     $a1, $a1, 2         # $a1 <- COLUMN *4
            add     $v0, $v0, $a1       # $v0 <- (SCREEN_WIDTH*(ROW*4)) + (COLUMN*4)
            li      $t0, DISPLAY_MEMORY_BASE # $t0 <- DISPLAY_MEMORY_BASE
            add     $v0, $t0, $v0       # $v0 <- DISPLAY_MEMORY_BASE + (SCREEN_WIDTH*(ROW*4)) + (COLUMN*4)
            j       cta_epilogo         # terminamos o procedimento
cta_error:
            li      $v0, -1                  # Retorna -1 como valor de erro
# epílogo
cta_epilogo:
            jr	    $ra                 # retorna ao procedimento chamador
########################################################################################################################





########################################################################################################################
# Escolhe a cor de desenho dos pixels
#
# Argumento
# $a0       :   Cor no formato hexadecimal 0x00RRGGBB
########################################################################################################################
set_foreground_color:
# prólogo
# corpo do procedimento
            la      $t0, screen_color
            sw      $a0, 0($t0)
# epílogo
            jr	    $ra                 # retorne ao procedimento chamador
########################################################################################################################



########################################################################################################################
# Escolhe a cor do fundo da tela
#
# Argumento
# $a0       :   Cor no formato hexadecimal 0x00RRGGBB
########################################################################################################################
set_background_color:
# prólogo
# corpo do procedimento
            la      $t0, screen_background_color
            sw      $a0, 0($t0)
# epílogo
            jr	    $ra                 # retorne ao procedimento chamador
########################################################################################################################





########################################################################################################################
# inicializa a tela gráfica
# Argumentos
# Sem argumentos
# 
# Mapa da Pilha
# $ra :           $sp + 12    endereço de retorno
# $s0 :           $sp + 8     posição x do pixel (row)
# $s1 :           $sp + 4     posição y do pixel (column)
# screen_color:   $sp + 0     cor do pixel que será desenhado
########################################################################################################################
screen_init:
########################################################################################################################
# prólogo
            addiu   $sp, $sp, -16       # ajustamos a pilha
            sw      $ra, 12($sp)        # armazenamos $ra na pilha
            sw      $s0, 8($sp)         # armazenamos $s0 na pilha
            sw      $s1, 4($sp)         # armazenamos $s1 na pilha
# corpo do programa
            # guardamos a cor de desenho dos pixeis. Restauramos no final do procedimento.
            la      $t0, screen_color   # $t0 <- endereço de screen_color
            lw      $t1, 0($t0)         # $t1 <- screen_color
            sw      $t1, 0($sp)         # armazenamos screen_color na pilha
            # fazemos screen_color igual a screen_background_color
            la      $t2, screen_background_color # $t2 <- endereço de screen_backgroud_color
            lw      $t3, 0($t2)         # $t3 <- screen_background_color
            sw      $t3, 0($t0)         # screen_color = screen_background_color
# for(row=0; row<SCREEN_WIDTH; row++) //para cada linha da tela
#   for(column=0; column< SCREEN_COLUMN, column++) //para cada coluna da tela
#     put_pixel(row, column); // coloque um  pixel na cor screen_background_color
si_for1_inicializa:
            li      $s0, 0              # row = 0
            j       si_for1_verifica    # desviamos para verificar se o laço deve ser executado
si_for1_codigo:
si_for2_inicializa:
            li      $s1, 0              # column = 0
            j       si_for2_verifica    # desviamos para verificar se o laço deve ser executado
si_for2_codigo:
            move	$a0, $s0            # $a0 <- row
            move    $a1, $s1            # $a1 <- column
            jal     put_pixel           # desenhamos um pixel em (row, column) na cor screen_background_color
si_for2_incrementa:
            addiu   $s1, $s1, 1         # column++
si_for2_verifica:
            slti    $t0, $s1, SCREEN_HEIGHT # $t0=1 se column<SCREEN_COLUMN
            bne     $t0, $zero, si_for2_codigo # executa o laço for2 se column<SCREEN_COLUMN
si_for2_fim:
si_for1_incrementa:
            addiu   $s0, $s0, 1         # row++
si_for1_verifica:
            slti    $t0, $s0, SCREEN_WIDTH # $t0=1 se row<SCREEN_WIDTH
            bne     $t0, $zero, si_for1_codigo # executa o laço for1 se row<SCREEN_WIDTH
si_for1_fim:
# epílogo
            la      $t0, screen_color   # $t0 <- endereço de screen_color
            lw      $t1, 0($sp)         # $t1 <- valor de screen_color na chamada a este procedimento
            sw      $t1, 0($t0)         # restaura o valor original de screen_color
            lw      $s1, 4($sp)         # restaura o registrador $s1
            lw      $s0, 8($sp)         # restaura o registrador $s0
            lw      $ra, 12($sp)        # restaura o endereço de retorno
            addiu   $sp, $sp, 16        # restaura a pilha
            jr	    $ra                 # retorna ao procedimento chamador            
########################################################################################################################




########################################################################################################################
# inicializa a tela gráfica, versão otimizada
# Argumentos
# Sem argumentos
#
# Mapa da Pilha
# $ra :           $sp + 12    endereço de retorno
# $s0 :           $sp + 8     posição x do pixel (row)
# $s1 :           $sp + 4     posição y do pixel (column)
# screen_color:   $sp + 0     cor do pixel que será desenhado
########################################################################################################################
screen_init2:
# prólogo
# corpo do procedimento
si2_for_inicializa:  
            # carregamos um ponteiro com o endereço inicial da memória da tela gráfica
            la	    $t0, dm             # $t0 <- ponteiro para o primeiro endereço da memória para a tela gráfica
            # carregamos um ponteiro com o primeiro endereço de memória após o segmento da memória para a tela gráfica
            li      $t1, SCREEN_MEMORY_DIMENSION # $t1 <- tamanho da memória destinada para a tela gráfica
            add     $t2, $t0, $t1       # $t2 <- ponteiro para o primeiro endereço após a memória para a tela gráfica
            la      $t3, screen_background_color # $t3 <- endereço de screen_background_color
            lw      $t4, 0($t3)         # $t4 <- cor de fundo da tela gráfica
            j       si2_for_verifica  # verificamos se o ponteiro em t0 aponta para um endereço na tela gráfica
si2_for_codigo:
            sw      $t4, 0($t0)         # faz a cor do pixel igual a screen_backgroud_color
si2_for_incrementa:     
            addi    $t0, $t0, 4         # aponta para o endereço de memória do próximo pixel
si2_for_verifica:
            # enquanto o ponteiro $t0 for menor $t2, ele aponta para a tela gráfica
            slt     $t5, $t0, $t2
            bne     $t5, $zero, si2_for_codigo
# epílogo
            jr	    $ra                 # retorna ao procedimento chamador
########################################################################################################################




########################################################################################################################
# Escreve um pixel na ferramenta bitmap display na cor da variável screen_color
# Argumentos
# $a0 : posição row do pixel
# $a1 : posição column do pixel
#
# Mapa da Pilha
# $ra :     $sp+0   endereço de retorno
########################################################################################################################
put_pixel:
########################################################################################################################
# prólogo
            addiu   $sp, $sp, -4        # ajustamos a pilha
            sw      $ra, 0($sp)         # armazenamos na pilha o endereço de retorno
# corpo do procedimento
            # encontramos o endereço na memoria da tela gráfica que corresponde às coordenadas (x,y) do pixel
            jal     coordinates_to_address # $v0 retorna o endereço de memória
            # carregamos a cor de desenho dos pixels
            la      $t0, screen_color   # $t0 <- endereço de screen_color
            lw      $t1, 0($t0)         # $t1 <- screen_color
            # gravamos na memória da tela gráfica a cor: fazemos o pixel em (row, column) ter a cor screen_color
            sw      $t1, 0($v0)
# epílogo
            lw	    $ra, 0($sp)         # restauramos o endereço de retorno
            addiu   $sp, $sp, 4         # restauramos a pilha
            jr      $ra                 # retornamos ao procedimento chamador
########################################################################################################################



########################################################################################################################
# Desenha um retangulo com as coordenadas P0(x0, y0) e P1(x1, y1)
#
# Parâmetros do procedimento
# $a0           :   x0      coordenada x do ponto P0     
# $a1           :   y0      coordenada y do ponto P0
# $a2           :   x1      coordenada x do ponto P1 
# $a3           :   y1      coordenada y do ponto P1
#           
########################################################################################################################
draw_rectangle:
########################################################################################################################
# prólogo
            addiu  $sp, $sp, -20     # alocamos espaço para 5 elementos
            sw    $a3, 16($sp)      # armazena os argumentos na pilha
            sw    $a2, 12($sp)
            sw    $a1, 8($sp)
            sw    $a0, 4($sp)
            sw    $ra, 0($sp)       # armazena o endereço de retorno na pilha
# corpo do procedimentos
            add   $a2, $zero, $a0
            jal   draw_line
            lw    $a0, 4($sp)
            lw    $a1, 8($sp)
            lw    $a2, 12($sp)
            lw    $a3, 8($sp)
            jal draw_line
            lw    $a0, 12($sp)
            lw    $a1, 8($sp)
            lw    $a2, 12($sp)
            lw    $a3, 16($sp)
            jal draw_line
            lw    $a0, 4($sp)
            lw    $a1, 12($sp)
            lw    $a2, 12($sp)
            lw    $a3, 16($sp)
            jal draw_line
# epílogo
            lw    $ra, 0($sp)       # restaura o endereço de retorno  
            addiu $sp, $sp, 20      # restauramos a pilha
            jr    $ra               # retorna ao procedimento chamador
########################################################################################################################


########################################################################################################################
# Desenho de um círculo com centro no ponto P0(x0, y0) de raio r. 
#
# O algooritmo para o desenho foi encontado em https://en.wikipedia.org/wiki/Midpoint_circle_algorithm
#
# parâmetros do procedimento:
# $a0       :   x0      coordenada x do centro do círculo
# $a1       :   y0      coordenada y do centro do círculo
# $a2       :   raio    raio r do circulo com centro em P0(x0, y0)
#           
########################################################################################################################
draw_circle:
########################################################################################################################
# prólogo
            addi  $sp, $sp, -40
            sw    $a2, 36($sp)
            sw    $a1, 32($sp)
            sw    $a0, 28($sp)
            sw    $ra, 24($sp)
            sw    $s5, 20($sp) # remover
            sw    $s4, 16($sp)
            sw    $s3, 12($sp)
            sw    $s2, 8($sp)
            sw    $s1, 4($sp)
            sw    $s0, 0($sp)
# corpo do procedimentos
    

#     int x = radius-1;
            addi $s0, $a2, -1
#     int y = 0;
            add  $s1, $zero, $zero
#     int dx = 1;
            addi $s2, $zero, 1
#     int dy = 1;
            addi $s3, $zero, 1
#     int err = dx - (radius << 1);
            sll  $s4, $a2, 1
            sub  $s4, $s2, $s4
# 
while1_inicio_draw_circle:
#     while (x >= y)
            j while1_testa_condicao_draw_circle
#     {
while1_codigo_draw_circle:
          
#         putpixel(x0 + x, y0 + y);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            add $a0, $a0, $s0
            add $a1, $a1, $s1

            jal put_pixel
#         putpixel(x0 + y, y0 + x);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            add $a0, $a0, $s1
            add $a1, $a1, $s0

            jal put_pixel
#         putpixel(x0 - y, y0 + x);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            sub $a0, $a0, $s1
            add $a1, $a1, $s0

            jal put_pixel
#         putpixel(x0 - x, y0 + y);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            sub $a0, $a0, $s0
            add $a1, $a1, $s1
            jal put_pixel
#         putpixel(x0 - x, y0 - y);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            sub $a0, $a0, $s0
            sub $a1, $a1, $s1
            jal put_pixel
#         putpixel(x0 - y, y0 - x);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            sub $a0, $a0, $s1
            sub $a1, $a1, $s0
            jal put_pixel
#         putpixel(x0 + y, y0 - x);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            add $a0, $a0, $s1
            sub $a1, $a1, $s0

            jal put_pixel
#         putpixel(x0 + x, y0 - y);
            lw  $a0, 28($sp)
            lw  $a1, 32($sp)
            add $a0, $a0, $s0
            sub $a1, $a1, $s1

            jal put_pixel
           
            lw $a2, 36($sp)
            
if1_inicio_draw_circle:           
#         if (err <= 0)
            bgtz  $s4, if1_fim_draw_circle
#         {
#             y++;
            addi  $s1, $s1, 1
#             err += dy;
            add   $s4, $s4, $s3
#             dy += 2;
            addi  $s3, $s3, 2
#         }
if1_fim_draw_circle:
#         
if2_inicio_draw_circle:
#         if (err > 0)
            blez $s4, if2_fim_draw_circle
#         {
#             x--;
            addi $s0, $s0, -1
#             dx += 2;
            addi $s2, $s2, 2
#             err += dx - (radius << 1);
            sll  $t0, $a2, 1
            sub  $t0, $s2, $t0
            add  $s4, $s4, $t0
#         }
if2_fim_draw_circle:
while1_testa_condicao_draw_circle:
#     while (x >= y)
            bge $s0, $s1, while1_codigo_draw_circle
#     }
while1_fim_draw_circle:

# epílogo
            lw    $s0, 0($sp)
            lw    $s1, 4($sp)
            lw    $s2, 8($sp)
            lw    $s3, 12($sp)
            lw    $s4, 16($sp)
            lw    $s5, 20($sp) # remover
            lw    $ra, 24($sp)
            addi  $sp, $sp, 40
            jr    $ra               # retornamos ao procedimento chamador
########################################################################################################################





########################################################################################################################
# Desenho de uma linha usando o algoritmo de Bresenham, de um ponto P0(x0, y0) para P1(x1, y1)
# Wikipedia contributors. (2024, October 1). Bresenham's line algorithm. In Wikipedia, The Free Encyclopedia. Retrieved 
# 03:43, October 22, 2024, from https://en.wikipedia.org/w/index.php?title=Bresenham%27s_line_algorithm&oldid=1248820154
#
# void plotLine(int x0, int y0, int x1, int y1)
# {
#     int dx = abs(x1 - x0), sx = x0 < x1 ? 1 : -1;
#     int dy = -abs(y1 - y0), sy = y0 < y1 ? 1 : -1;
#     int err = dx + dy, e2; /* error value e_xy */
#     for (;;)
#     { /* loop */
#         printf("(%d, %d)", x0, y0);
#         e2 = 2 * err;
#         if (e2 >= dy)
#         { /* e_xy+e_x > 0 */
#             if (x0 == x1)
#                 break;
#             err += dy;
#             x0 += sx;
#         }
#         if (e2 <= dx)
#         { /* e_xy+e_y < 0 */
#             if (y0 == y1)
#                 break;
#             err += dx;
#             y0 += sy;
#         }
#     }
# }
#
# Argumentos do procedimento
# $a0       :       x0      coordenada x do ponto P0
# $a1       :       y0      coordenada y do ponto P0
# $a2       :       x1      coordenada x do ponto P1
# $a3       :       y1      coordenada y do ponto P1
#
# Mapa da Pilha
# $ra       :       $sp + 36        endereço de retorno
# $s0       :       $sp + 32        x0
# $s1       :       $sp + 28        y0
# $s2       :       $sp + 24        x1
# $s3       :       $sp + 20        y1
# $s4       :       $sp + 16        dx
# $s5       :       $sp + 12        sx
# $s6       :       $sp + 8         dy
# $s7       :       $sp + 4         sy
# error     :       $sp + 0         error ($t0)
# 
########################################################################################################################
draw_line:
# prólogo
            addiu   $sp, $sp, -40       # ajustamos a pilha
            sw      $ra, 36($sp)        # guardamos o endereço de retorno na pilha
            sw      $s0, 32($sp)        # guardamos os registradores $s0 a $s7 na pilha
            sw      $s1, 28($sp)        # ...
            sw      $s2, 24($sp)        # ...
            sw      $s3, 20($sp)        # ...
            sw      $s4, 16($sp)        # ...
            sw      $s5, 12($sp)        # ...
            sw      $s6, 8($sp)         # ...
            sw      $s7, 4($sp)         # ...
            # guardamos os argumentos x0, y0, x1, y1 nos registradores $s0 a $s3
            move    $s0, $a0
            move    $s1, $a1
            move    $s2, $a2
            move    $s3, $a3
# corpo do programa
# void plotLine(int x0, int y0, int x1, int y1)
# {
#     int dx = abs(x1 - x0);
            sub	    $s4, $s2, $s0
            abs     $s4, $s4  
#     int sx = x0 < x1 ? 1 : -1;
            slt     $s5, $s0, $s2
            sll     $s5, $s5, 1
            addi    $s5, $s5, -1
#     int dy = -abs(y1 - y0);
            sub     $s6, $s3, $s1
            abs     $s6, $s6
            neg     $s6, $s6
#     int sy = y0 < y1 ? 1 : -1;
            slt	    $s7, $s1, $s3
            sll     $s7, $s7, 1
            addi    $s7, $s7, -1
#     int err = dx + dy
            add     $t0, $s4, $s6
            sw      $t0, 0($sp)
#     int e2; /* error value e_xy */
dl_loop:
#     for (;;)
#     { /* loop */
#         plot(x0,y0);
            move      $a0, $s0
            move      $a1, $s1
            jal       put_pixel
            lw        $t0, 0($sp)
#         e2 = 2 * err;
            mul       $t1, $t0, 2
#         if (e2 >= dy)
            slt	    $t2, $t1, $s6
            bne       $t2, $zero, dl_if_dy_end
#         { /* e_xy+e_x > 0 */
#             if (x0 == x1) break;
            beq	    $s0, $s2, dl_end_loop
#             err += dy;
            add	    $t0, $t0, $s6
            sw      $t0, 0($sp)
#             x0 += sx;
            add     $s0, $s0, $s5
#         }
dl_if_dy_end:
#         if (e2 <= dx)
            slt     $t2, $s4, $t1
            bne     $t2, $zero, dl_if_dx_end
#         { /* e_xy+e_y < 0 */
#             if (y0 == y1) break;
            beq	    $s1, $s3, dl_end_loop
#             err += dx;
            add	    $t0, $t0, $s4
            sw      $t0, 0($sp)
#             y0 += sy;
            add	    $s1, $s1, $s7
#         }
dl_if_dx_end:
#     }
            j	    dl_loop
dl_end_loop:
# }
# epílogo
            lw      $s7, 4($sp)         # restauramos os registradores $s0 a $s7
            lw      $s6, 8($sp)         # ...
            lw      $s5, 12($sp)        # ...
            lw      $s4, 16($sp)        # ...
            lw      $s3, 20($sp)        # ...
            lw      $s2, 24($sp)        # ...
            lw      $s1, 28($sp)        # ...
            lw      $s0, 32($sp)        # ...
            lw	    $ra, 36($sp)        # restauramaos o endereço de retorno
            addiu   $sp, $sp, 40        # restauramos a pilha
            jr	    $ra                 # retorna ao procedimento chamador
########################################################################################################################
