# Código a traduzir: 

# #include <stdio.h>
# #include <stdlib.h>
#
# // retorna x² se x > 10, caso contrário, retorna x/1-x
# double p(double x);
#
#
# int main()
# {
#     double n1, n2;
#     n1 = p(-20);
#     n2 = p(20);
# 
#     // deve imprimir -1.05263157895
#     printf("p(-20) = %f\n", n1);
#     // deve imprimir 400
#     printf("p(20) = %f\n", n2);
# }
#
#
# // retorna x² se x > 10, caso contrário, retorna x/1-x
# double p(double x)
# {
#     if (x > 10)
#     {
#         return x * x;
#     }
#     return x / (1 - x);
# }

########################################################################################################################

# variáveis do programa
.data
n1:		.double -20.0		# guarda o resultado de p(-20)
n2:		.double 20.0		# guarda o resultado de p(20)
n3:		.double 10.0		# usado para comparações
buffer:		.double 0		# usado para passar argumentos de FP para procedimentos
mensagem_1:	.asciiz "p(-20) = "
mensagem_2:	.asciiz "p(20) = "
newline:	.asciiz "\n"

########################################################################################################################

.text


main:
	# *** mapa dos registradores ***
	# $f0 = n1
	# $f2 = n2
	# $f4 = p(n1)
	# $f6 = p(n2)
	
	# carregamos as variáveis
	la $t0, n1		# $t0 = endereço de n1
	l.d $f0, 0($t0)		# $f0 = valor de n1
	la $t0, n2		# $t0 = endereço de n2
	l.d $f2, 0($t0)		# $f2 = valor de n2
	
	# teste
	la $t0, buffer		# $t0 = endereço de buffer
	s.d $f0, 0($t0)		# buffer = n1
	jal p			# chama p(n1) -- p(20) --
	
	j exit
	
########################################################################################################################

# double p(double x)
# >>> argumentos do procedimento:
#	> $a0 = primeira parte do ponto flutuante de precisão dupla "x"
#	> $a1 = segunda parte do ponto flutuante de precisão dupla "x"
# >>> valor de retorno
#	> $v0 = primeira parte do ponto flutuante de precisão dupla resultante do cálculo realizado sobre "x"
#	> $v1 = segunda parte do ponto flutuante de precisão dupla resultante do cálculo realizado sobre "x"

p:
# prólogo
	# *** mapa da pilha ***
	# 0($sp) = $ra
	
	addi $sp, $sp, -4	# ajusta a pilha
	sw $ra, 0($sp)		# guarda o endereço de retorno
		
# corpo do procedimento
	# *** mapa dos registradores ***
	# $f8 = x
	# $f10 = 10.0
	
	# carrega a variável x
	la $t0, buffer		# $t0 = endereço de buffer (onde x está)
	l.d $f8, 0($t0)		# $f8 = valor de x
	
	# testa se x <= 10
	la $t0, n3		# $t0 = endereço de 3
	l.d $f10, 0($t0)	# $f10 = 10.0
	c.le.d $f8, $f10	# flag de condição do coprocessador 1 = true se x <= 10
	bc1t menor_ou_igual	# pula para "menor_oou_igual" se x <= 10
	
	maior:
		nop	# deu merda
	
	menor_ou_igual:
		nop	# menor
	
	
	
# epílogo
	lw $ra, 0($sp)		# restaura o endereço de retorno
	addi $sp, $sp, 4	# ajusta a pilha
	jr $ra			# retorna para quem chamou


########################################################################################################################

exit:
	nop
