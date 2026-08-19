%{
#include <stdio.h>
%}

%%

[0-9]+      { printf("NUMERO: %s\n", yytext); }
"+"         { printf("MAIS\n"); }
"*"         { printf("VEZES\n"); }
[ \t]+      { /* ignora espaço */ }
"\n"        { printf("FIM_DE_LINHA\n"); }
.           { printf("CARACTERE DESCONHECIDO: %s\n", yytext); }

%%

int yywrap() { return 1; }

int main() {
    yylex();
    return 0;
}