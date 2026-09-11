%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *mensagem);
extern int line_num;
%}

/* --- SECAO 1: DECLARACOES --- */

%union {
    int intValue;
    float floatValue;
    char charValue;
    char *strValue;
}

/* tokens com valor semantico (precisam bater com os "return" do aquivo .l) */
%token <intValue>   INTNUM_LIT
%token <floatValue> FLOATNUM_LIT
%token <charValue>  CHARNUM_LIT
%token <strValue>   STRING_LIT ID

/* palavras-chave (sem valor semantico associado) */
%token INT FLOATKW CHARKW VOID
%token IF ELSE WHILE FOR RETURN BREAK CONTINUE

/* operadores de dois caracteres */
%token EQ NEQ LE GE AND OR INC DEC
%token PLUS_ASSIGN MINUS_ASSIGN TIMES_ASSIGN DIVIDE_ASSIGN

/* operadores de um caractere e pontuacao */
%token PLUS MINUS TIMES DIVIDE MOD ASSIGN LT GT NOT
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET SEMI COMMA

/* por enquanto so "expr" produz um valor (um inteiro) */
%type <intValue> expr

/* precedencia: de MENOR para MAIOR prioridade */
%left PLUS MINUS
%left TIMES DIVIDE MOD

%%

/* --- SECAO 2: GRAMATICA --- */

programa:
      %empty
    | programa linha
    ;

linha:
      expr SEMI          { printf("Resultado: %d\n", $1); }
    | error SEMI          { yyerrok; }
    ;

expr:
      expr PLUS  expr     { $$ = $1 + $3; }
    | expr MINUS expr     { $$ = $1 - $3; }
    | expr TIMES expr     { $$ = $1 * $3; }
    | expr DIVIDE expr    {
          if ($3 == 0) { yyerror("divisao por zero"); $$ = 0; }
          else         { $$ = $1 / $3; }
      }
    | LPAREN expr RPAREN  { $$ = $2; }
    | INTNUM_LIT          { $$ = $1; }
    ;

%%

/* --- SECAO 3: CODIGO AUXILIAR --- */

void yyerror(const char *mensagem) {
    fprintf(stderr, "Erro sintatico na linha %d: %s\n", line_num, mensagem);
}

int main(void) {
    printf("Digite expressoes terminadas com ';'. Ctrl+D para encerrar.\n");
    return yyparse();
}