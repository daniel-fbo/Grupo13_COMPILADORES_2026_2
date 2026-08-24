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

 /* ---- para mensagens de erro caso alguma coisa não seja reconhecida ---- */
.           {
    fprintf(stderr, "Erro lexico na linha %d: caractere invalido '%s'\n",
            line_num, yytext);
}


%%