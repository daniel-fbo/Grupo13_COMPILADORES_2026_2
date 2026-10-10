%{
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include "analisadorSintatico.tab.h"

extern int num_erros;
extern int linha_anterior;

static int linha = 1;

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = linha;

static void erroLexico(const char *formato, ...) {
    va_list args;

    fprintf(stderr, "Erro lexico na linha %d: ", linha);
    va_start(args, formato);
    vfprintf(stderr, formato, args);
    va_end(args);
    fprintf(stderr, "\n");
    num_erros++;
}

static char escape(char c) {
    switch (c) {
    case 'n': return '\n';
    case 't': return '\t';
    case 'r': return '\r';
    case '0': return '\0';
    default:  return c;
    }
}

static char *textoDaString(const char *conteudo, int tamanho) {
    char *texto = malloc(tamanho + 1);
    int n = 0;

    if (texto == NULL) {
        perror("sem memoria para a string");
        exit(1);
    }
    for (int i = 0; i < tamanho; i++) {
        if (conteudo[i] == '\\') texto[n++] = escape(conteudo[++i]);
        else                     texto[n++] = conteudo[i];
    }
    texto[n] = '\0';
    return texto;
}
%}

%option noyywrap
%option nounput noinput

%x COMENTARIO

DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTNUM      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+
STRING      \"([^\"\n\\]|\\.)*\"
CHARLIT     \'([^\'\n\\]|\\.)\'

%%

%{
    linha_anterior = yylloc.first_line;
%}

 /* ---------- espacos e comentarios ---------- */

[ \t\r]+                { }
\n                      { linha++; }
"//".*                  { }

"/*"                    { BEGIN(COMENTARIO); }
<COMENTARIO>"*/"        { BEGIN(INITIAL); }
<COMENTARIO>\n          { linha++; }
<COMENTARIO>[^*\n]+     { }
<COMENTARIO>"*"         { }
<COMENTARIO><<EOF>>     {
    erroLexico("comentario de bloco nao foi fechado");
    yyterminate();
}

 /* ---------- palavras-chave (antes de ID) ---------- */

"int"       { return INT; }
"float"     { return FLOATKW; }
"char"      { return CHARKW; }
"void"      { return VOID; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }
"for"       { return FOR; }
"return"    { return RETURN; }
"break"     { return BREAK; }
"continue"  { return CONTINUE; }

 /* ---------- literais e identificadores ---------- */

{FLOATNUM}  {
    yylval.floatValue = atof(yytext);
    return FLOATNUM_LIT;
}
{INTNUM}    {
    long long valor = strtoll(yytext, NULL, 10);

    if (valor > INT_MAX) {
        erroLexico("o numero %s nao cabe em um int", yytext);
        valor = 0;
    }
    yylval.intValue = (int)valor;
    return INTNUM_LIT;
}
{CHARLIT}   {
    yylval.charValue = (yytext[1] == '\\') ? escape(yytext[2]) : yytext[1];
    return CHARNUM_LIT;
}
{STRING}    {
    yylval.strValue = textoDaString(yytext + 1, yyleng - 2);
    return STRING_LIT;
}
\"([^\"\n\\]|\\.)*  { erroLexico("string nao foi fechada"); }

{ID}        {
    yylval.strValue = strdup(yytext);
    return ID;
}

 /* ---------- operadores de dois caracteres (antes dos de um) ---------- */

"=="        { return EQ; }
"!="        { return NEQ; }
"<="        { return LE; }
">="        { return GE; }
"&&"        { return AND; }
"||"        { return OR; }
"++"        { return INC; }
"--"        { return DEC; }
"+="        { return PLUS_ASSIGN; }
"-="        { return MINUS_ASSIGN; }
"*="        { return TIMES_ASSIGN; }
"/="        { return DIVIDE_ASSIGN; }

 /* ---------- operadores de um caractere e pontuacao ---------- */

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
"%"         { return MOD; }
"="         { return ASSIGN; }
"<"         { return LT; }
">"         { return GT; }
"!"         { return NOT; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"["         { return LBRACKET; }
"]"         { return RBRACKET; }
";"         { return SEMI; }
","         { return COMMA; }

.           { erroLexico("caractere invalido '%s'", yytext); }

%%
