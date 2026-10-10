#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* ---------- alocacao ---------- */

static void *exigir(void *ponteiro) {
    if (ponteiro == NULL) {
        perror("sem memoria para a arvore sintatica");
        exit(1);
    }
    return ponteiro;
}

No *novoNo(TipoNo tipo, int linha, No *f0, No *f1, No *f2, No *f3) {
    No *no = exigir(calloc(1, sizeof(No)));

    no->tipo = tipo;
    no->linha = linha;
    no->filho[0] = f0;
    no->filho[1] = f1;
    no->filho[2] = f2;
    no->filho[3] = f3;
    return no;
}

static No *novoNoComNome(TipoNo tipo, int linha, char *nome, No *filho) {
    No *no = novoNo(tipo, linha, filho, NULL, NULL, NULL);

    no->nome = nome;
    return no;
}

/* ---------- expressoes ---------- */

No *novoInt(int linha, int valor) {
    No *no = novoNo(NO_INT, linha, NULL, NULL, NULL, NULL);

    no->valor_int = valor;
    return no;
}

No *novoFloat(int linha, float valor) {
    No *no = novoNo(NO_FLOAT, linha, NULL, NULL, NULL, NULL);

    no->valor_float = valor;
    return no;
}

No *novoString(int linha, char *texto) {
    return novoNoComNome(NO_STRING, linha, texto, NULL);
}

No *novoVar(int linha, char *nome) {
    return novoNoComNome(NO_VAR, linha, nome, NULL);
}

No *novoBinario(int linha, Operador op, No *esquerda, No *direita) {
    No *no = novoNo(NO_BINARIO, linha, esquerda, direita, NULL, NULL);

    no->op = op;
    return no;
}

No *novoUnario(int linha, Operador op, No *operando) {
    No *no = novoNo(NO_UNARIO, linha, operando, NULL, NULL, NULL);

    no->op = op;
    return no;
}

No *novoAtrib(int linha, char *nome, No *valor) {
    return novoNoComNome(NO_ATRIB, linha, nome, valor);
}

/* "x += valor" entra na arvore como "x = x + valor" */
No *novoAtribComposta(int linha, char *nome, Operador op, No *valor) {
    No *variavel = novoVar(linha, exigir(strdup(nome)));

    return novoAtrib(linha, nome, novoBinario(linha, op, variavel, valor));
}

No *novoIncDec(int linha, char *nome, Operador op, int prefixo) {
    No *no = novoNoComNome(NO_INCDEC, linha, nome, NULL);

    no->op = op;
    no->prefixo = prefixo;
    return no;
}

No *novoChamada(int linha, char *nome, No *argumentos) {
    return novoNoComNome(NO_CHAMADA, linha, nome, argumentos);
}

/* ---------- comandos ---------- */

No *novoDecl(int linha, char *nome, No *valor_inicial) {
    return novoNoComNome(NO_DECL, linha, nome, valor_inicial);
}

/* ---------- listas e liberacao ---------- */

No *anexar(No *lista, No *no) {
    No *ultimo = lista;

    if (lista == NULL) return no;
    while (ultimo->prox != NULL) ultimo = ultimo->prox;
    ultimo->prox = no;
    return lista;
}

void liberarArvore(No *no) {
    while (no != NULL) {
        No *prox = no->prox;

        for (int i = 0; i < MAX_FILHOS; i++) liberarArvore(no->filho[i]);
        free(no->nome);
        free(no);
        no = prox;
    }
}
