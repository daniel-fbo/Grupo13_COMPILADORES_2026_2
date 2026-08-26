%{
#include <stdio.h>
%}

/* Definições de padrões de token e ações */
%%

if          { printf("KW_IF\n"); }
else       { printf("KW_ELSE\n"); }
switch     { printf("KW_SWITCH\n"); }
case       { printf("KW_CASE\n"); }
do         { printf("KW_DO\n"); }
while       { printf("KW_WHILE\n"); }
for         { printf("KW_FOR\n"); }
return     { printf("KW_RETURN\n"); }
break      { printf("KW_BREAK\n"); }
continue   { printf("KW_CONTINUE\n"); }


"//".*     { /* Ignorar comentários de linha */ }

"/*"([^*]|\*+[^*/])*\*+\/    { /* Ignorar comentários de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]*  { printf("IDENT(%s)\n", yytext); }

[0-9]+(\.[0-9]+)?  { printf("NUMBER(%s)\n", yytext); }

[+\-*/=%]   { printf("OPERATOR(%s)\n", yytext); }

[ \t\n]+  { /* Não faz nada */ }

.  { printf("UNKNOWN(%s)\n", yytext); }

%%

/* Função auxiliar do Flex (quando termina o arquivo de entrada) */
int yywrap(void) {
    return 1;
}

/* Função principal: executa o analisador léxico */
int main(void) {
    yylex();
    return 0;
}
