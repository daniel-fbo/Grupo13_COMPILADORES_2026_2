# Lista de Lexemas e Significados

## Palavras-Chave

int - Declara variável do tipo inteiro
float - Declara variável do tipo decimal
char - Declara variável do tipo caractere
void - Indica que a função não retorna valor
if - Inicia uma estrutura condicional
else - Define o bloco alternativo do if
while - Inicia uma repetição com teste no início
for - Inicia uma repetição com contador
return - Retorna um valor de uma função
break - Interrompe o loop atual
continue - Pula para a próxima iteração do loop

## Operadores Aritméticos

+ - Soma
- - Subtração
* - Multiplicação
/ - Divisão
% - Resto da divisão (módulo)
++ - Incrementa em 1
-- - Decrementa em 1

## Operadores Relacionais (Comparação)

== - Igual a
!= - Diferente de
< - Menor que
> - Maior que
<= - Menor ou igual a
>= - Maior ou igual a

## Operadores Lógicos

&& - E lógico (as duas condições devem ser verdadeiras)
|| - Ou lógico (pelo menos uma condição deve ser verdadeira)
! - Negação (inverte o valor lógico)

## Atribuição

= - Atribui um valor à variável
+= - Soma e atribui
-= - Subtrai e atribui
*= - Multiplica e atribui
/= - Divide e atribui

## Delimitadores e Pontuação

( - Abre parêntese (expressões, funções)
) - Fecha parêntese
{ - Abre bloco de código
} - Fecha bloco de código
[ - Abre colchete (arrays)
] - Fecha colchete
, - Separa argumentos ou variáveis
; - Fim de comando

## Comentários (descartados pelo lexer)

// - Comentário de linha única
/* ... */ - Comentário de bloco

## Identificadores e Valores

[a-zA-Z_][a-zA-Z0-9_]* - Nome de variável ou função
[0-9]+ - Número inteiro
[0-9]+\.[0-9]+ - Número decimal
'[^'\\n]' - Caractere único entre aspas simples
\"[^\"\\n]*\" - Texto entre aspas duplas