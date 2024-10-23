#include "jogo.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


// tela de apresentação do jogo
void jogo_apresenta()
{
    printf(" $$$$$$\\                                                      $$\\           $$\\   $$\\ \n");
    printf("$$  __$$\\                                                     $$ |          $$ |  $$ |\n");
    printf("$$ /  \\__| $$$$$$\\  $$$$$$$\\  $$$$$$$\\   $$$$$$\\   $$$$$$$\\ $$$$$$\\         $$ |  $$ |\n");
    printf("$$ |      $$  __$$\\ $$  __$$\\ $$  __$$\\ $$  __$$\\ $$  _____|\\_$$  _|        $$$$$$$$ | \n");
    printf("$$ |      $$ /  $$ |$$ |  $$ |$$ |  $$ |$$$$$$$$ |$$ /        $$ |          \\_____$$ |\n");
    printf("$$ |  $$\\ $$ |  $$ |$$ |  $$ |$$ |  $$ |$$   ____|$$ |        $$ |$$\\             $$ |\n");
    printf("\\$$$$$$  |\\$$$$$$  |$$ |  $$ |$$ |  $$ |\\$$$$$$$\\ \\$$$$$$$\\   \\$$$$  |            $$ | \n");
    printf(" \\______/  \\______/ \\__|  \\__|\\__|  \\__| \\_______| \\_______|   \\____/             \\__|\n");

    printf("> clique \"enter\" para jogar: ");
    char ch;
    do
    {
        ch = getchar();
    }
    while (ch != '\n');
}


// preenche todos os índices to tabuleiro com "NENHUMA" ficha
void jogo_inicializa(Ficha *tabuleiro)
{
    // percorre os índices do tabuleiro
    for (int i = 0; i < N_LINHAS; i++)
    {
        for (int j = 0; j < N_COLUNAS; j++)
        {
            // preenche o índice na linha i, coluna j com "NENHUMA" ficha
            tabuleiro[i * N_COLUNAS + j] = NENHUMA;
        }
    }
}


// muda de quem é a vez de jogar
void jogo_muda_vez(Ficha *vez)
{
    if (*vez == AMARELA)
    {
        *vez = VERMELHA;
    }
    else
    {
        *vez = AMARELA;
    }
}


// valida e realiza a jogada do jogador
void jogo_faz_jogada(Ficha *tabuleiro, Ficha vez, int *linha, int *coluna)
{
    // mensagem para pedir pro jogador fazer uma jogada
    printf("> Vez do ");
    if (vez == AMARELA)
    {
        printf("amarelo: ");
    }
    else
    {
        printf("vermelho: ");
    }

    int col;  // guarda a coluna em que o jogador quer inserir uma ficha
    // pede uma jogada para o jogador até fazer uma jogada válida
    do 
    {
        scanf("%d", &col);
    } 
    while (col < 0 || col >= N_COLUNAS || tabuleiro[5 * N_COLUNAS + col] != NENHUMA);

    // procura a primeira linha vazia na coluna escolhida
    for (int i = 0; i < N_COLUNAS; i++)
    {
        if (tabuleiro[i * N_COLUNAS + col] == NENHUMA)
        {
            // realiza a jogada
            tabuleiro[i * N_COLUNAS + col] = vez;
            // atualiza as variáveis linha e coluna
            *linha = i;
            *coluna = col;
            break;
        }
    }

}


// retorna o valor da ficha em uma posição (ou -1 se estiver fora dos limites)
static int get_ficha(Ficha *tabuleiro, int linha, int coluna)
{
    if (linha < 0 || linha >= N_LINHAS || coluna < 0 || coluna >= N_COLUNAS)
    {
        // fora do tabuleiro
        return -1;
    }
    return tabuleiro[linha * N_COLUNAS + coluna];
}


// verifica se tem quatro fichas da mesma cor enfileradas
bool jogo_acabou(Ficha *tabuleiro, int linha, int coluna)
{
    // obtem o valor da ficha no índice atual
    int ficha_atual = get_ficha(tabuleiro, linha, coluna);
    // se não tiver ficha aqui
    if (ficha_atual == NENHUMA)
    {  
        return false;
    }

    // direções: {linha, coluna} -> horizontal, vertical, diagonal principal, diagonal secundária
    int direcoes[4][2] = {{1, 0}, {0, 1}, {1, 1}, {1, -1}};  // {linha, coluna}

    // verificamos cada direção
    for (int d = 0; d < 4; d++)
    {
        int n_fichas_seguidas = 1;       // conta o número de fichas iguais seguidas em uma direção        
        int delta_lin = direcoes[d][0];  // variação das linhas
        int delta_col = direcoes[d][1];  // variação das colunas

        // verifica no sentido positivo
        for (int k = 1; k < 4; k++)
        {
            // se achar uma ficha igual
            if (ficha_atual == get_ficha(tabuleiro, linha + k * delta_lin, coluna + k * delta_col))
            {
                // incrementa o número de fichas seguidas
                n_fichas_seguidas++;
            }
            // se não encontrar uma ficha igual
            else
            {
                // para de procurar nesse sentido
                break;
            }
        }

        // verifica no sentido negativo
        for (int k = 1; k < 4; k++)
        {
            // se achar uma ficha igual
            if (ficha_atual == get_ficha(tabuleiro, linha - k * delta_lin, coluna - k * delta_col))
            {
                // incrementa o número de fichas seguidas
                n_fichas_seguidas++;
            }
            // se não encontrar uma ficha igual
            else
            {
                // para de procurar nesse sentido
                break;
            }
        }

        // se tiverem 4 ou mais fichas iguais seguidas
        if (n_fichas_seguidas >= 4)
        {
            return true;  // vitória!
        }
    }

    return false;  // ninguém venceu ainda
}


#include <stdio.h>
#include <stdbool.h>

bool jogo_quer_jogar()
{
    printf("-=-=-=-=-=- GAME OVER -=-=-=-=-=-\n");
    printf("> Jogar de novo? [s/n]\n");
    char resposta;
    do
    {
        resposta = getchar();
        // Limpa o buffer de entrada para evitar múltiplas leituras do "Enter"
        while (getchar() != '\n');
    }
    while (resposta != 'n' && resposta != 'N' && resposta != 's' && resposta != 'S');

    if (resposta == 's' || resposta == 'S')
    {
        return true;  // Quer jogar novamente
    }
    return false;     // Não quer jogar novamente
}



// imprime o tabuleiro
void jogo_desenha_tabuleiro(Ficha *tabuleiro)
{
    // percorre os índices do tabuleiro
    for (int i = N_LINHAS - 1; i >= 0; i--)
    {
        printf("%d ", i);
        for (int j = 0; j < N_COLUNAS; j++)
        {
            printf("[");
            switch (tabuleiro[i * N_COLUNAS + j])
            {
                case 0:
                    printf(" ");
                    break;
                case 1:
                    printf("◇");
                    break;
                case 2:
                    printf("◆");
                    break;
            }
            printf("] ");
        }
        printf("\n");
    }
    printf("   0   1   2   3   4   5   6\n");
}
