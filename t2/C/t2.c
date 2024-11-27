/*
Escreva o procedimento double p(double x) (equação 1), em assembly para o MIPS.
Escreva um programa para apresentar o resultado de p(x), para x = -20 e para x = 20.
Quais os valores calculados de p(x)?
p(x) = x² se x > 10; x/1-x se x <= 10
*/

#include <stdio.h>
#include <stdlib.h>

// retorna x² se x > 10, caso contrário, retorna x/1-x
double p(double x);


int main()
{
    double n1, n2;
    n1 = p(-20);
    n2 = p(20);

    // deve imprimir -1.05263157895
    printf("p(-20) = %f\n", n1);
    // deve imprimir 400
    printf("p(20) = %f\n", n2);
}


// retorna x² se x > 10, caso contrário, retorna x/1-x
double p(double x)
{
    if (x > 10)
    {
        return x * x;
    }
    return x / (1 - x);
}
