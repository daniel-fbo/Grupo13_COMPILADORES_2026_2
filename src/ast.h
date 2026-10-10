#ifndef AST_H
#define AST_H

/* ---------- tipos e operadores ---------- */

typedef enum { TIPO_INT, TIPO_FLOAT, TIPO_CHAR } Tipo;

typedef enum {
    OP_SOMA, OP_SUB, OP_MUL, OP_DIV, OP_MOD,
    OP_IGUAL, OP_DIF, OP_MENOR, OP_MAIOR, OP_MENOR_IG, OP_MAIOR_IG,
    OP_E, OP_OU,
    OP_NEG, OP_NAO
} Operador;

/* ---------- nos da arvore ---------- */

typedef enum {
    NO_INT, NO_FLOAT, NO_STRING, NO_VAR,
    NO_BINARIO, NO_UNARIO, NO_ATRIB, NO_INCDEC, NO_CHAMADA,

    NO_DECL, NO_EXPR_CMD, NO_BLOCO,
    NO_IF, NO_WHILE, NO_FOR,
    NO_BREAK, NO_CONTINUE, NO_RETURN
} TipoNo;

#define MAX_FILHOS 4

typedef struct No {
    TipoNo tipo;
    int linha;

    Operador op;
    int prefixo;
    Tipo tipo_var;
    int valor_int;
    float valor_float;
    char *nome;

    struct No *filho[MAX_FILHOS];
    struct No *prox;
} No;

/* ---------- construcao ---------- */

No *novoNo(TipoNo tipo, int linha, No *f0, No *f1, No *f2, No *f3);

No *novoInt(int linha, int valor);
No *novoFloat(int linha, float valor);
No *novoString(int linha, char *texto);
No *novoVar(int linha, char *nome);
No *novoBinario(int linha, Operador op, No *esquerda, No *direita);
No *novoUnario(int linha, Operador op, No *operando);
No *novoAtrib(int linha, char *nome, No *valor);
No *novoAtribComposta(int linha, char *nome, Operador op, No *valor);
No *novoIncDec(int linha, char *nome, Operador op, int prefixo);
No *novoChamada(int linha, char *nome, No *argumentos);
No *novoDecl(int linha, char *nome, No *valor_inicial);

/* ---------- listas e liberacao ---------- */

No *anexar(No *lista, No *no);
void liberarArvore(No *no);

#endif
