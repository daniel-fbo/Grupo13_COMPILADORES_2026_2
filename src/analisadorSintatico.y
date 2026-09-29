%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *mensagem);
extern int line_num;
extern FILE *yyin;

int num_erros = 0;        /* erros lexicos + sintaticos (o lexer tambem soma aqui) */
int num_comandos = 0;     /* comandos de nivel mais externo reconhecidos */
int profundidade_laco = 0; /* > 0 quando estamos dentro de um while/for */
%}

/* --- SECAO 1: DECLARACOES --- */

/* mensagens de erro, ver yyreport_syntax_error */
%define parse.error custom

%union {
    int intValue;
    float floatValue;
    char charValue;
    char *strValue;
}

/* tokens com valor semantico (precisam bater com os "return" do aquivo .l)
   o texto entre aspas e so o nome que aparece nas mensagens de erro */
%token <intValue>   INTNUM_LIT   "numero inteiro"
%token <floatValue> FLOATNUM_LIT "numero decimal"
%token <charValue>  CHARNUM_LIT  "caractere"
%token <strValue>   STRING_LIT   "string"
%token <strValue>   ID           "identificador"

/* palavras-chave (sem valor semantico associado) */
%token INT "int" FLOATKW "float" CHARKW "char" VOID "void"
%token IF "if" ELSE "else" WHILE "while" FOR "for"
%token RETURN "return" BREAK "break" CONTINUE "continue"

/* operadores de dois caracteres */
%token EQ "==" NEQ "!=" LE "<=" GE ">=" AND "&&" OR "||" INC "++" DEC "--"
%token PLUS_ASSIGN "+=" MINUS_ASSIGN "-=" TIMES_ASSIGN "*=" DIVIDE_ASSIGN "/="

/* operadores de um caractere e pontuacao */
%token PLUS "+" MINUS "-" TIMES "*" DIVIDE "/" MOD "%" ASSIGN "=" LT "<" GT ">" NOT "!"
%token LPAREN "(" RPAREN ")" LBRACE "{" RBRACE "}" LBRACKET "[" RBRACKET "]"
%token SEMI ";" COMMA ","

/* libera as strings (strdup do lexer) que o parser descarta ao se recuperar de um erro */
%destructor { free($$); } <strValue>

/* precedencia: de MENOR para MAIOR prioridade */
%left OR
%left AND
%left EQ NEQ
%left LT GT LE GE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%precedence NOT UMINUS

/* "else" pendurado: if (a) if (b) x; else y;  -> o else fica com o if mais proximo */
%precedence SEM_ELSE
%precedence ELSE

%%

/* --- SECAO 2: GRAMATICA --- */

programa:
      %empty
    | programa comando        { num_comandos++; }
    ;

lista_comandos:
      %empty
    | lista_comandos comando
    ;

comando:
      declaracao SEMI
    | expr SEMI
    | SEMI                                          /* comando vazio */
    | bloco
    | condicional
    | laco
    | BREAK SEMI {
          if (profundidade_laco == 0) yyerror("'break' fora de um laco");
      }
    | CONTINUE SEMI {
          if (profundidade_laco == 0) yyerror("'continue' fora de um laco");
      }
    | RETURN expr_opcional SEMI
    | error SEMI              { yyerrok; }          /* recuperacao: pula ate o ';' */
    ;

bloco:
      LBRACE lista_comandos RBRACE
    ;

/* ---- declaracao de variaveis: int a;  int a = 1, b = 2; ---- */

declaracao:
      tipo lista_declarados
    ;

tipo:
      INT
    | FLOATKW
    | CHARKW
    ;

lista_declarados:
      declarado
    | lista_declarados COMMA declarado
    ;

declarado:
      ID                      { free($1); }
    | ID ASSIGN expr          { free($1); }
    ;

/* ---- if / else / else if ---- */

condicional:
      IF condicao comando %prec SEM_ELSE
    | IF condicao comando ELSE comando
    ;

/* condicao entre parenteses do if e do while.
   se a expressao tiver erro, o parser se recupera no ')' e segue com o corpo */
condicao:
      LPAREN expr RPAREN
    | LPAREN error RPAREN     { yyerrok; }
    ;

/* ---- while e for ---- */

laco:
      WHILE condicao
          { profundidade_laco++; }
      comando
          { profundidade_laco--; }
    | FOR LPAREN inicio_for SEMI expr_opcional SEMI expr_opcional RPAREN
          { profundidade_laco++; }
      comando
          { profundidade_laco--; }
    ;

inicio_for:
      %empty
    | declaracao
    | expr
    ;

expr_opcional:
      %empty
    | expr
    ;

/* ---- expressoes ----
   atribuicao fica num nivel proprio, acima de todos os operadores:
   so um identificador pode aparecer do lado esquerdo do '=' */

expr:
      ID ASSIGN expr          { free($1); }
    | ID PLUS_ASSIGN expr     { free($1); }
    | ID MINUS_ASSIGN expr    { free($1); }
    | ID TIMES_ASSIGN expr    { free($1); }
    | ID DIVIDE_ASSIGN expr   { free($1); }
    | operacao
    ;

operacao:
      operacao OR operacao
    | operacao AND operacao
    | operacao EQ operacao
    | operacao NEQ operacao
    | operacao LT operacao
    | operacao GT operacao
    | operacao LE operacao
    | operacao GE operacao
    | operacao PLUS operacao
    | operacao MINUS operacao
    | operacao TIMES operacao
    | operacao DIVIDE operacao
    | operacao MOD operacao
    | NOT operacao
    | MINUS operacao %prec UMINUS
    | PLUS operacao %prec UMINUS
    | primario
    ;

primario:
      INTNUM_LIT
    | FLOATNUM_LIT
    | CHARNUM_LIT
    | STRING_LIT              { free($1); }
    | ID                      { free($1); }
    | ID INC                  { free($1); }     /* i++ */
    | ID DEC                  { free($1); }     /* i-- */
    | INC ID                  { free($2); }     /* ++i */
    | DEC ID                  { free($2); }     /* --i */
    | ID LPAREN argumentos RPAREN { free($1); } /* chamada: printf("%d", x) */
    | LPAREN expr RPAREN
    ;

argumentos:
      %empty
    | lista_argumentos
    ;

lista_argumentos:
      expr
    | lista_argumentos COMMA expr
    ;

%%

/* --- SECAO 3: CODIGO AUXILIAR --- */

void yyerror(const char *mensagem) {
    fprintf(stderr, "Erro sintatico na linha %d: %s\n", line_num, mensagem);
    num_erros++;
}

/* chamada pelo Bison (parse.error custom) quando a entrada nao casa com a gramatica.
   monta: "encontrado X, esperado A, B ou C" */
static int yyreport_syntax_error(const yypcontext_t *ctx) {
    enum { MAX_ESPERADOS = 6 };
    yysymbol_kind_t esperados[MAX_ESPERADOS];
    int n = yypcontext_expected_tokens(ctx, esperados, MAX_ESPERADOS);
    yysymbol_kind_t lido = yypcontext_token(ctx);

    fprintf(stderr, "Erro sintatico na linha %d: ", line_num);
    if (lido == YYSYMBOL_YYEOF)
        fprintf(stderr, "fim do arquivo inesperado");
    else
        fprintf(stderr, "'%s' inesperado", yysymbol_name(lido));

    for (int i = 0; i < n; i++) {
        if (i == 0)          fprintf(stderr, ", esperado ");
        else if (i == n - 1) fprintf(stderr, " ou ");
        else                 fprintf(stderr, ", ");
        fprintf(stderr, "'%s'", yysymbol_name(esperados[i]));
    }
    fprintf(stderr, "\n");
    num_erros++;
    return 0;
}

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
        return 1;
    }
    printf("%s: OK, %d comando(s) reconhecido(s), nenhum erro lexico ou sintatico\n",
           nome, num_comandos);
    return 0;
}
