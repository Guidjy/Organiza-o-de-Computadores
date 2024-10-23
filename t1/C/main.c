#include "jogo.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int main()
{
    // inicializa o gerador de números aleatórios
    srand(time(0));

    // vetor que representa o tabuleiro do jogo
    Ficha tabuleiro[42];

    // variáveis para armazenar a jogada realizada
    int linha = 0;
    int coluna = 0;

    // mostra a tela de apresentação do jogo
    jogo_apresenta();

    // laço principal do jogo
    do
    {
        // limpa o terminal
        system("clear");

        // reseta as variáveis do tabuleiro
        jogo_inicializa(tabuleiro);

        // sorteia um jogador para ir primeiro
        Ficha vez = (rand() % 2) + 1;

        jogo_desenha_tabuleiro(tabuleiro);

        // laço da partida
        while (!jogo_acabou(tabuleiro, linha, coluna))
        {
            // muda de quem é a vez de jogar
            jogo_muda_vez(&vez);
            // recebe e valida a jogada de um jogador
            jogo_faz_jogada(tabuleiro, vez, &linha, &coluna);
            system("clear");
            jogo_desenha_tabuleiro(tabuleiro);
        }
    }
    while (jogo_quer_jogar());

    return 0;
}
