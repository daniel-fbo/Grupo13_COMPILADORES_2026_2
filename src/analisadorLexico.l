#include "parser.tab.h"   /* gerado pelo Bison: bison -d parser.y */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

%option noyywrap

/* ---- definições reutilizáveis (macros de regex) ---- */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTNUM      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+
STRING      \"([^\"\n\\]|\\.)*\"
CHARLIT     \'([^\'\n\\]|\\.)\'

%%

 /* ---- espaços, tabs, comentários ---- */
[ \t]+                 { /* ignora espaços e tabs */ }
\n                      { line_num++; }
"//".*                  { /* comentário de linha, ignora */ }
"/*"([^*]|\*+[^*/])*\*+"/"   { /* comentário de bloco, ignora */ }

 /* ----palavras reservadas do C (tem que ser antes da regra de ID pois a ordem importa) ---- */
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

 /* ---- literais (números, char, string) ---- */
{FLOATNUM}  {
    yylval.floatValue = atof(yytext);
    return FLOATNUM_LIT;
}
{INTNUM}    {
    yylval.intValue = atoi(yytext);
    return INTNUM_LIT;
}
{CHARLIT}   {
    yylval.charValue = yytext[1];
    return CHARNUM_LIT;
}
{STRING}    {
    yylval.strValue = strdup(yytext);
    return STRING_LIT;
}

 /* ----identificador (DEPOIS das palavras-chave)---- */
{ID}        {
    yylval.strValue = strdup(yytext);
    return ID;
}

 /* ---- operadores de DOIS caracteres (antes dos de um) ---- */
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

 /* ---- operadores de UM caractere e pontuação ---- */
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

 /* ---- para mensagens de erro caso alguma coisa não seja reconhecida ---- */
.           {
    fprintf(stderr, "Erro lexico na linha %d: caractere invalido '%s'\n",
            line_num, yytext);
}


%%