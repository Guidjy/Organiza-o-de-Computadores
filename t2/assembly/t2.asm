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
buffer:		.double 0		# usado para passar argumentos de FP para procedimentos
mensagem_1:	.asciiz "p(-20) = "
mensagem_2:	.asciiz "p(20) = "
newline:	.asciiz "\n"
# constantes
UM:		.double 1.0
DEZ:		.double 10.0

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
	
	# chama p(-20)
	la $t0, buffer		# $t0 = endereço de buffer
	s.d $f0, 0($t0)		# buffer = n1
	jal p			# chama p(n1) -- p(-20) --
	mov.d $f4, $f12		# $f4 = p(-20)
	
	### imprime o resultado de p(-20)
	# imprime a mensagem
	la $a0, mensagem_1	# $a0 = endereço da mensagem_1
	li $v0, 4		# $v0 = códico de syscall para imprimir uma string
	syscall			# imprime mensagem_1
	# imprime o valor de p(-20)
	# 0-0: No MIPS, o syscall para imprimir números de ponto flutuante requer
	#      valores carregados nos registradores $f12 e $f13.
	#      O valor de retorno ja esta nesse registrador entao podemos imprimir direto.
	li $v0, 3		# $v0 = código de syscall para imprimir um double
	syscall
	# imprime uma new line
	la $a0, newline		# $a0 = endereço de newline
	li $v0, 4		# $v0 = código de syscall para imprimir uma string
	syscall			# imprime "\n"
	
	# chama p(20)
	la $t0, buffer		# $t0 = endereço de buffer
	s.d $f2, 0($t0)		# buffer = n2
	jal p			# chama p(n2) -- p(20) --
	mov.d $f6, $f12		# $f6 = p(20)
	
	### imprime o resultado de p(20)
	# imprime a mensagem
	la $a0, mensagem_2	# $a0 = endereço da mensagem_2
	li $v0, 4		# $v0 = códico de syscall para imprimir uma string
	syscall			# imprime mensagem_2
	# imprime o valor de p(20)
	li $v0, 3		# $v0 = código de syscall para imprimir um double
	syscall
	# imprime uma new line
	la $a0, newline		# $a0 = endereço de newline
	li $v0, 4		# $v0 = código de syscall para imprimir uma string
	syscall			# imprime "\n"
	
	j exit
	
########################################################################################################################

# double p(double x)
# >>> argumentos do procedimento:
#	> $a0 = primeira parte do ponto flutuante de precisão dupla "x"
#	> $a1 = segunda parte do ponto flutuante de precisão dupla "x"
# >>> valor de retorno
#	> buffer = x² se x > 10; x/(1-x) se x <= 10

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
	# $f12 = valor de retorno
	
	# carrega a variável x
	la $t0, buffer		# $t0 = endereço de buffer (onde x está)
	l.d $f8, 0($t0)		# $f8 = valor de x
	
	# testa se x <= 10
	la $t0, DEZ		# $t0 = endereço da constante DEZ
	l.d $f10, 0($t0)	# $f10 = 10.0
	c.le.d $f8, $f10	# flag de condição do coprocessador 1 = true se x <= 10
	bc1t menor_ou_igual	# pula para "menor_oou_igual" se x <= 10
	
	maior:		
		mov.d $f12, $f8		# $f12 = x
		mul.d $f12, $f12, $f12  # $f12 = x²
		j p_fim
	
	menor_ou_igual:
		la $t0, UM		# $t0 = endereço da constante UM
		l.d $f12, 0($t0)	# $f12 = 1.0
		sub.d $f12, $f12, $f8	# $f12 = 1 - x
		div.d $f12, $f8, $f12	# $f12 = x/(1-x)
		j p_fim	
		
	p_fim:
	la $t0, buffer		# $t0 = endereço de buffer
	s.d $f12, 0($t0)	# buffer = valor de retorno
	
# epílogo
	lw $ra, 0($sp)		# restaura o endereço de retorno
	addi $sp, $sp, 4	# ajusta a pilha
	jr $ra			# retorna para quem chamou


########################################################################################################################

exit:
	nop
