/* ---------- declaracoes ---------- */

%code requires {
#include "ast.h"
}

%code {
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *mensagem);
int interpretar(No *programa);
extern FILE *yyin;

int num_erros = 0;
int linha_anterior = 1;

static int profundidade_laco = 0;
static No *raiz = NULL;

static void erroSintatico(int linha, const char *formato, ...);
}

%define parse.error custom
%locations

%union {
    int intValue;
    float floatValue;
    char charValue;
    char *strValue;
    Tipo tipo;
    No *no;
}

%token FIM_ARQUIVO 0 "fim do arquivo"

%token <intValue>   INTNUM_LIT   "numero inteiro"
%token <floatValue> FLOATNUM_LIT "numero decimal"
%token <charValue>  CHARNUM_LIT  "caractere"
%token <strValue>   STRING_LIT   "string"
%token <strValue>   ID           "identificador"

%token INT "int" FLOATKW "float" CHARKW "char" VOID "void"
%token IF "if" ELSE "else" WHILE "while" FOR "for"
%token RETURN "return" BREAK "break" CONTINUE "continue"

%token EQ "==" NEQ "!=" LE "<=" GE ">=" AND "&&" OR "||" INC "++" DEC "--"
%token PLUS_ASSIGN "+=" MINUS_ASSIGN "-=" TIMES_ASSIGN "*=" DIVIDE_ASSIGN "/="

%token PLUS "+" MINUS "-" TIMES "*" DIVIDE "/" MOD "%" ASSIGN "=" LT "<" GT ">" NOT "!"
%token LPAREN "(" RPAREN ")" LBRACE "{" RBRACE "}" LBRACKET "[" RBRACKET "]"
%token SEMI ";" COMMA ","

%destructor { free($$); } <strValue>
%destructor { liberarArvore($$); } <no>

%type <no>   comando lista_comandos bloco
%type <no>   declaracao lista_declarados declarado
%type <no>   condicional condicao laco inicio_for expr_opcional
%type <no>   expr operacao primario argumentos lista_argumentos
%type <tipo> tipo

/* precedencia: da menor para a maior */
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence NOT UMINUS

%precedence SEM_ELSE
%precedence ELSE

%%

/* ---------- programa e comandos ---------- */

programa:
      %empty
    | programa comando        { raiz = anexar(raiz, $2); }
    ;

lista_comandos:
      %empty                  { $$ = NULL; }
    | lista_comandos comando  { $$ = anexar($1, $2); }
    ;

comando:
      declaracao SEMI         { $$ = $1; }
    | expr SEMI               { $$ = novoNo(NO_EXPR_CMD, @1.first_line, $1, NULL, NULL, NULL); }
    | SEMI                    { $$ = NULL; }
    | bloco
    | condicional
    | laco
    | BREAK SEMI {
          if (profundidade_laco == 0) erroSintatico(@1.first_line, "'break' fora de um laco");
          $$ = novoNo(NO_BREAK, @1.first_line, NULL, NULL, NULL, NULL);
      }
    | CONTINUE SEMI {
          if (profundidade_laco == 0) erroSintatico(@1.first_line, "'continue' fora de um laco");
          $$ = novoNo(NO_CONTINUE, @1.first_line, NULL, NULL, NULL, NULL);
      }
    | RETURN expr_opcional SEMI { $$ = novoNo(NO_RETURN, @1.first_line, $2, NULL, NULL, NULL); }
    | error SEMI              { yyerrok; $$ = NULL; }
    ;

bloco:
      LBRACE lista_comandos RBRACE { $$ = novoNo(NO_BLOCO, @1.first_line, $2, NULL, NULL, NULL); }
    ;

/* ---------- declaracao de variaveis ---------- */

declaracao:
      tipo lista_declarados {
          for (No *d = $2; d != NULL; d = d->prox) d->tipo_var = $1;
          $$ = $2;
      }
    ;

tipo:
      INT                     { $$ = TIPO_INT; }
    | FLOATKW                 { $$ = TIPO_FLOAT; }
    | CHARKW                  { $$ = TIPO_CHAR; }
    ;

lista_declarados:
      declarado
    | lista_declarados COMMA declarado { $$ = anexar($1, $3); }
    ;

declarado:
      ID                      { $$ = novoDecl(@1.first_line, $1, NULL); }
    | ID ASSIGN expr          { $$ = novoDecl(@1.first_line, $1, $3); }
    ;

/* ---------- condicionais ---------- */

condicional:
      IF condicao comando %prec SEM_ELSE { $$ = novoNo(NO_IF, @1.first_line, $2, $3, NULL, NULL); }
    | IF condicao comando ELSE comando   { $$ = novoNo(NO_IF, @1.first_line, $2, $3, $5, NULL); }
    ;

condicao:
      LPAREN expr RPAREN      { $$ = $2; }
    | LPAREN error RPAREN     { yyerrok; $$ = NULL; }
    ;

/* ---------- lacos ---------- */

laco:
      WHILE condicao
          { profundidade_laco++; }
      comando
          {
              profundidade_laco--;
              $$ = novoNo(NO_WHILE, @1.first_line, $2, $4, NULL, NULL);
          }
    | FOR LPAREN inicio_for SEMI expr_opcional SEMI expr_opcional RPAREN
          { profundidade_laco++; }
      comando
          {
              profundidade_laco--;
              $$ = novoNo(NO_FOR, @1.first_line, $3, $5, $7, $10);
          }
    ;

inicio_for:
      %empty                  { $$ = NULL; }
    | declaracao
    | expr
    ;

expr_opcional:
      %empty                  { $$ = NULL; }
    | expr
    ;

/* ---------- expressoes ---------- */

expr:
      ID ASSIGN expr          { $$ = novoAtrib(@2.first_line, $1, $3); }
    | ID PLUS_ASSIGN expr     { $$ = novoAtribComposta(@2.first_line, $1, OP_SOMA, $3); }
    | ID MINUS_ASSIGN expr    { $$ = novoAtribComposta(@2.first_line, $1, OP_SUB, $3); }
    | ID TIMES_ASSIGN expr    { $$ = novoAtribComposta(@2.first_line, $1, OP_MUL, $3); }
    | ID DIVIDE_ASSIGN expr   { $$ = novoAtribComposta(@2.first_line, $1, OP_DIV, $3); }
    | operacao
    ;

operacao:
      operacao OR operacao     { $$ = novoBinario(@2.first_line, OP_OU, $1, $3); }
    | operacao AND operacao    { $$ = novoBinario(@2.first_line, OP_E, $1, $3); }
    | operacao EQ operacao     { $$ = novoBinario(@2.first_line, OP_IGUAL, $1, $3); }
    | operacao NEQ operacao    { $$ = novoBinario(@2.first_line, OP_DIF, $1, $3); }
    | operacao LT operacao     { $$ = novoBinario(@2.first_line, OP_MENOR, $1, $3); }
    | operacao GT operacao     { $$ = novoBinario(@2.first_line, OP_MAIOR, $1, $3); }
    | operacao LE operacao     { $$ = novoBinario(@2.first_line, OP_MENOR_IG, $1, $3); }
    | operacao GE operacao     { $$ = novoBinario(@2.first_line, OP_MAIOR_IG, $1, $3); }
    | operacao PLUS operacao   { $$ = novoBinario(@2.first_line, OP_SOMA, $1, $3); }
    | operacao MINUS operacao  { $$ = novoBinario(@2.first_line, OP_SUB, $1, $3); }
    | operacao TIMES operacao  { $$ = novoBinario(@2.first_line, OP_MUL, $1, $3); }
    | operacao DIVIDE operacao { $$ = novoBinario(@2.first_line, OP_DIV, $1, $3); }
    | operacao MOD operacao    { $$ = novoBinario(@2.first_line, OP_MOD, $1, $3); }
    | NOT operacao             { $$ = novoUnario(@1.first_line, OP_NAO, $2); }
    | MINUS operacao %prec UMINUS { $$ = novoUnario(@1.first_line, OP_NEG, $2); }
    | PLUS operacao %prec UMINUS  { $$ = $2; }
    | primario
    ;

primario:
      INTNUM_LIT              { $$ = novoInt(@1.first_line, $1); }
    | FLOATNUM_LIT            { $$ = novoFloat(@1.first_line, $1); }
    | CHARNUM_LIT             { $$ = novoInt(@1.first_line, $1); }
    | STRING_LIT              { $$ = novoString(@1.first_line, $1); }
    | ID                      { $$ = novoVar(@1.first_line, $1); }
    | ID INC                  { $$ = novoIncDec(@1.first_line, $1, OP_SOMA, 0); }
    | ID DEC                  { $$ = novoIncDec(@1.first_line, $1, OP_SUB, 0); }
    | INC ID                  { $$ = novoIncDec(@2.first_line, $2, OP_SOMA, 1); }
    | DEC ID                  { $$ = novoIncDec(@2.first_line, $2, OP_SUB, 1); }
    | ID LPAREN argumentos RPAREN { $$ = novoChamada(@1.first_line, $1, $3); }
    | LPAREN expr RPAREN      { $$ = $2; }
    ;

argumentos:
      %empty                  { $$ = NULL; }
    | lista_argumentos
    ;

lista_argumentos:
      expr
    | lista_argumentos COMMA expr { $$ = anexar($1, $3); }
    ;

%%

/* ---------- erros ---------- */

static void erroSintatico(int linha, const char *formato, ...) {
    va_list args;

    fprintf(stderr, "Erro sintatico na linha %d: ", linha);
    va_start(args, formato);
    vfprintf(stderr, formato, args);
    va_end(args);
    fprintf(stderr, "\n");
    num_erros++;
}

void yyerror(const char *mensagem) {
    erroSintatico(yylloc.first_line, "%s", mensagem);
}

/* quando o parser sabe o que faltou, o erro e da linha do token anterior:
   um ';' esquecido e apontado na linha em que deveria estar */
static int yyreport_syntax_error(const yypcontext_t *ctx) {
    enum { MAX_ESPERADOS = 6 };
    yysymbol_kind_t esperados[MAX_ESPERADOS];
    int n = yypcontext_expected_tokens(ctx, esperados, MAX_ESPERADOS);
    const char *lido = yysymbol_name(yypcontext_token(ctx));
    char faltou[256] = "";
    size_t usado = 0;

    if (n <= 0) {
        erroSintatico(yypcontext_location(ctx)->first_line, "'%s' inesperado", lido);
        return 0;
    }

    for (int i = 0; i < n; i++) {
        const char *separador = i == 0 ? "" : i == n - 1 ? " ou " : ", ";

        usado += snprintf(faltou + usado, sizeof faltou - usado, "%s'%s'",
                          separador, yysymbol_name(esperados[i]));
    }
    erroSintatico(linha_anterior, "esperado %s antes de '%s'", faltou, lido);
    return 0;
}

/* ---------- main ---------- */

int main(int argc, char *argv[]) {
    const char *nome = "entrada padrao";

    if (argc > 1) {
        nome = argv[1];
        yyin = fopen(nome, "r");
        if (yyin == NULL) {
            perror(nome);
            return 1;
        }
    }

    yyparse();
    if (argc > 1) fclose(yyin);

    if (num_erros > 0) {
        fprintf(stderr, "%s: %d erro(s) encontrado(s)\n", nome, num_erros);
        liberarArvore(raiz);
        return 1;
    }

    num_erros = interpretar(raiz);
    liberarArvore(raiz);
    fflush(stdout);

    if (num_erros > 0) {
        fprintf(stderr, "%s: %d erro(s) de execucao\n", nome, num_erros);
        return 1;
    }
    return 0;
}
