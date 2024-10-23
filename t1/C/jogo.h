#ifndef JOGO_H
#define JOGO_H

#include <stdbool.h>


// Número de linhas no tabuleiro
#define N_LINHAS 6

// Número de colunas no tabuleiro
#define N_COLUNAS 7

// tipo para representar o conteúdo de um espaço no tabuleiro
enum _fichas
{
    NENHUMA,    // 0 = espaço vazio
    VERMELHA,   // 1 = ficha vermelha
    AMARELA     // 2 = ficha amarela
};
typedef enum _fichas Ficha;


// tela de apresentação do jogo
void jogo_apresenta();

// preenche todos os índices to tabuleiro com "NENHUMA" ficha
void jogo_inicializa(Ficha *tabuleiro);

// muda de quem é a vez de jogar
void jogo_muda_vez(Ficha *vez);

// valida e realiza a jogada do jogador
void jogo_faz_jogada(Ficha *tabuleiro, Ficha vez, int *linha, int *coluna);

// verifica se tem quatro fichas da mesma cor enfileradas
bool jogo_acabou(Ficha *tabuleiro,  int linha, int coluna);

// pergunta ao usuário se ainda quer jogar
bool jogo_quer_jogar();

// imprime o tabuleiro
void jogo_desenha_tabuleiro(Ficha *tabuleiro);


#endif
