#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* ---------- estado ---------- */

typedef struct {
    Tipo tipo;
    int i;
    float f;
} Valor;

typedef struct Simbolo {
    const char *nome;
    Tipo tipo;
    Valor valor;
    struct Simbolo *prox;
} Simbolo;

typedef enum { SEM_SINAL, SINAL_BREAK, SINAL_CONTINUE } Sinal;

static Simbolo *tabela = NULL;
static Simbolo *inicio_escopo = NULL;
static Sinal sinal = SEM_SINAL;
static int interrompido = 0;
static int num_erros_execucao = 0;

static void erroExecucao(int linha, const char *formato, ...) {
    va_list args;

    fflush(stdout);
    fprintf(stderr, "Erro de execucao na linha %d: ", linha);
    va_start(args, formato);
    vfprintf(stderr, formato, args);
    va_end(args);
    fprintf(stderr, "\n");
    num_erros_execucao++;
}

/* ---------- valores ---------- */

static Valor valorInt(int i) {
    Valor v = { TIPO_INT, i, 0 };
    return v;
}

static Valor valorFloat(float f) {
    Valor v = { TIPO_FLOAT, 0, f };
    return v;
}

static float comoFloat(Valor v) {
    return v.tipo == TIPO_FLOAT ? v.f : (float)v.i;
}

static int verdadeiro(Valor v) {
    return v.tipo == TIPO_FLOAT ? v.f != 0 : v.i != 0;
}

static Valor converter(Valor v, Tipo destino) {
    if (destino == TIPO_FLOAT) return valorFloat(comoFloat(v));
    if (v.tipo == TIPO_FLOAT)  v = valorInt((int)v.f);
    if (destino == TIPO_CHAR)  v.i = (char)v.i;
    return v;
}

/* ---------- tabela de simbolos ---------- */

static Simbolo *buscar(const char *nome, Simbolo *ate) {
    for (Simbolo *s = tabela; s != ate; s = s->prox)
        if (strcmp(s->nome, nome) == 0) return s;
    return NULL;
}

static Simbolo *variavelDe(No *no) {
    Simbolo *s = buscar(no->nome, NULL);

    if (s == NULL)
        erroExecucao(no->linha, "variavel '%s' nao foi declarada", no->nome);
    return s;
}

static void desempilharAte(Simbolo *marca) {
    while (tabela != marca) {
        Simbolo *s = tabela;

        tabela = s->prox;
        free(s);
    }
}

static Simbolo *abrirEscopo(void) {
    Simbolo *escopo_de_fora = inicio_escopo;

    inicio_escopo = tabela;
    return escopo_de_fora;
}

static void fecharEscopo(Simbolo *escopo_de_fora) {
    desempilharAte(inicio_escopo);
    inicio_escopo = escopo_de_fora;
}

/* ---------- expressoes ---------- */

static Valor avaliar(No *no);

static Valor operarFloat(No *no, float x, float y) {
    switch (no->op) {
    case OP_SOMA:     return valorFloat(x + y);
    case OP_SUB:      return valorFloat(x - y);
    case OP_MUL:      return valorFloat(x * y);
    case OP_DIV:      return valorFloat(x / y);
    case OP_IGUAL:    return valorInt(x == y);
    case OP_DIF:      return valorInt(x != y);
    case OP_MENOR:    return valorInt(x < y);
    case OP_MAIOR:    return valorInt(x > y);
    case OP_MENOR_IG: return valorInt(x <= y);
    case OP_MAIOR_IG: return valorInt(x >= y);
    default:
        erroExecucao(no->linha, "o operador '%%' so aceita numeros inteiros");
        return valorInt(0);
    }
}

static Valor operarInt(No *no, int x, int y) {
    if (no->op == OP_DIV || no->op == OP_MOD) {
        if (y == 0) {
            erroExecucao(no->linha, "divisao por zero");
            return valorInt(0);
        }
        if (x == INT_MIN && y == -1) {
            erroExecucao(no->linha, "estouro de inteiro na divisao");
            return valorInt(0);
        }
    }

    switch (no->op) {
    case OP_SOMA:     return valorInt(x + y);
    case OP_SUB:      return valorInt(x - y);
    case OP_MUL:      return valorInt(x * y);
    case OP_DIV:      return valorInt(x / y);
    case OP_MOD:      return valorInt(x % y);
    case OP_IGUAL:    return valorInt(x == y);
    case OP_DIF:      return valorInt(x != y);
    case OP_MENOR:    return valorInt(x < y);
    case OP_MAIOR:    return valorInt(x > y);
    case OP_MENOR_IG: return valorInt(x <= y);
    case OP_MAIOR_IG: return valorInt(x >= y);
    default:          return valorInt(0);
    }
}

static Valor avaliarBinario(No *no) {
    Valor a, b;

    if (no->op == OP_E)
        return valorInt(verdadeiro(avaliar(no->filho[0])) && verdadeiro(avaliar(no->filho[1])));
    if (no->op == OP_OU)
        return valorInt(verdadeiro(avaliar(no->filho[0])) || verdadeiro(avaliar(no->filho[1])));

    a = avaliar(no->filho[0]);
    b = avaliar(no->filho[1]);

    if (a.tipo == TIPO_FLOAT || b.tipo == TIPO_FLOAT)
        return operarFloat(no, comoFloat(a), comoFloat(b));
    return operarInt(no, a.i, b.i);
}

static Valor avaliarIncDec(No *no) {
    int passo = no->op == OP_SOMA ? 1 : -1;
    Simbolo *s = variavelDe(no);
    Valor antes, depois;

    if (s == NULL) return valorInt(0);

    antes = s->valor;
    if (antes.tipo == TIPO_FLOAT) depois = valorFloat(antes.f + passo);
    else                          depois = valorInt(antes.i + passo);
    s->valor = converter(depois, s->tipo);

    return no->prefixo ? s->valor : antes;
}

/* ---------- printf ---------- */

static Valor executarPrintf(No *chamada) {
    No *arg = chamada->filho[0];
    const char *p;
    int impressos = 0;

    if (arg == NULL || arg->tipo != NO_STRING) {
        erroExecucao(chamada->linha, "o primeiro argumento do printf tem que ser uma string");
        return valorInt(0);
    }
    p = arg->nome;
    arg = arg->prox;

    while (*p != '\0') {
        char formato[32];
        size_t n;
        Valor v;

        if (*p != '%')    { putchar(*p);  impressos++; p += 1; continue; }
        if (p[1] == '%')  { putchar('%'); impressos++; p += 2; continue; }

        n = 1 + strspn(p + 1, "-+ 0123456789.");
        if (p[n] == '\0' || strchr("difc", p[n]) == NULL || n + 2 > sizeof formato) {
            erroExecucao(chamada->linha, "formato invalido no printf (use %%d, %%f, %%c ou %%%%)");
            break;
        }
        memcpy(formato, p, n + 1);
        formato[n + 1] = '\0';
        p += n + 1;

        if (arg == NULL) {
            erroExecucao(chamada->linha, "falta um argumento para o '%s' do printf", formato);
            break;
        }
        v = avaliar(arg);
        arg = arg->prox;

        if (formato[n] == 'f') impressos += printf(formato, comoFloat(v));
        else                   impressos += printf(formato, converter(v, TIPO_INT).i);
    }

    for (; arg != NULL; arg = arg->prox) avaliar(arg);
    return valorInt(impressos);
}

/* ---------- avaliacao ---------- */

static Valor avaliar(No *no) {
    Simbolo *s;
    Valor v;

    switch (no->tipo) {
    case NO_INT:
        return valorInt(no->valor_int);

    case NO_FLOAT:
        return valorFloat(no->valor_float);

    case NO_VAR:
        s = variavelDe(no);
        return s != NULL ? s->valor : valorInt(0);

    case NO_BINARIO:
        return avaliarBinario(no);

    case NO_UNARIO:
        v = avaliar(no->filho[0]);
        if (no->op == OP_NAO)     return valorInt(!verdadeiro(v));
        if (v.tipo == TIPO_FLOAT) return valorFloat(-v.f);
        return valorInt(-v.i);

    case NO_ATRIB:
        v = avaliar(no->filho[0]);
        s = variavelDe(no);
        if (s == NULL) return valorInt(0);
        s->valor = converter(v, s->tipo);
        return s->valor;

    case NO_INCDEC:
        return avaliarIncDec(no);

    case NO_STRING:
        erroExecucao(no->linha, "uma string so pode aparecer como texto do printf");
        return valorInt(0);

    case NO_CHAMADA:
        if (strcmp(no->nome, "printf") == 0) return executarPrintf(no);
        erroExecucao(no->linha, "a funcao '%s' nao existe (a linguagem so tem printf)", no->nome);
        return valorInt(0);

    default:
        erroExecucao(no->linha, "no de tipo %d nao e uma expressao", no->tipo);
        interrompido = 1;
        return valorInt(0);
    }
}

/* ---------- comandos ---------- */

static void executar(No *lista);

static void declarar(No *no) {
    Valor inicial = valorInt(0);
    Simbolo *s;

    if (buscar(no->nome, inicio_escopo) != NULL) {
        erroExecucao(no->linha, "variavel '%s' ja foi declarada", no->nome);
        return;
    }
    if (no->filho[0] != NULL) inicial = avaliar(no->filho[0]);

    s = malloc(sizeof(Simbolo));
    if (s == NULL) {
        perror("sem memoria para a tabela de simbolos");
        exit(1);
    }
    s->nome = no->nome;
    s->tipo = no->tipo_var;
    s->valor = converter(inicial, no->tipo_var);
    s->prox = tabela;
    tabela = s;
}

/* um comando que e so uma conta ("2 + 3 * 4;") mostra o resultado */
static void executarExpressao(No *expr) {
    Valor v = avaliar(expr);

    if (expr->tipo == NO_ATRIB || expr->tipo == NO_INCDEC || expr->tipo == NO_CHAMADA) return;
    if (v.tipo == TIPO_FLOAT) printf("Resultado: %f\n", v.f);
    else                      printf("Resultado: %d\n", v.i);
}

static void executarEmEscopo(No *lista) {
    Simbolo *escopo_de_fora = abrirEscopo();

    executar(lista);
    fecharEscopo(escopo_de_fora);
}

/* ---------- lacos ---------- */

static int lacoTerminou(void) {
    int parou = (sinal == SINAL_BREAK) || interrompido;

    sinal = SEM_SINAL;
    return parou;
}

static void executarWhile(No *no) {
    while (verdadeiro(avaliar(no->filho[0]))) {
        executarEmEscopo(no->filho[1]);
        if (lacoTerminou()) break;
    }
}

static void executarFor(No *no) {
    No *inicio = no->filho[0], *condicao = no->filho[1], *passo = no->filho[2];
    Simbolo *escopo_de_fora = abrirEscopo();

    if (inicio != NULL && inicio->tipo == NO_DECL) executar(inicio);
    else if (inicio != NULL)                       avaliar(inicio);

    while (condicao == NULL || verdadeiro(avaliar(condicao))) {
        executarEmEscopo(no->filho[3]);
        if (lacoTerminou()) break;
        if (passo != NULL) avaliar(passo);
    }

    fecharEscopo(escopo_de_fora);
}

/* ---------- execucao ---------- */

static void executarComando(No *no) {
    switch (no->tipo) {
    case NO_DECL:
        declarar(no);
        break;

    case NO_EXPR_CMD:
        executarExpressao(no->filho[0]);
        break;

    case NO_BLOCO:
        executarEmEscopo(no->filho[0]);
        break;

    case NO_IF:
        if (verdadeiro(avaliar(no->filho[0]))) executarEmEscopo(no->filho[1]);
        else                                   executarEmEscopo(no->filho[2]);
        break;

    case NO_WHILE:
        executarWhile(no);
        break;

    case NO_FOR:
        executarFor(no);
        break;

    case NO_BREAK:
        sinal = SINAL_BREAK;
        break;

    case NO_CONTINUE:
        sinal = SINAL_CONTINUE;
        break;

    case NO_RETURN:
        if (no->filho[0] != NULL) avaliar(no->filho[0]);
        interrompido = 1;
        break;

    default:
        erroExecucao(no->linha, "no de tipo %d nao e um comando", no->tipo);
        interrompido = 1;
        break;
    }
}

static void executar(No *lista) {
    for (No *no = lista; no != NULL && !interrompido && sinal == SEM_SINAL; no = no->prox)
        executarComando(no);
}

int interpretar(No *programa) {
    num_erros_execucao = 0;
    interrompido = 0;
    sinal = SEM_SINAL;

    executar(programa);

    desempilharAte(NULL);
    inicio_escopo = NULL;
    return num_erros_execucao;
}