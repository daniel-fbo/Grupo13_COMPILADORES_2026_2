// precedencia: * e / antes de + e -
2 + 3 * 4;                  // 14
(2 + 3) * 4;                // 20

// associatividade a esquerda: (10 - 2) - 3, e nao 10 - (2 - 3) ---
10 - 2 - 3;                 // 5

// divisao inteira: a parte decimal e descartada
100 / 7;                    // 14

// parenteses aninhados 
((1 + 2) * (3 + 4)) / 3;    // 7

// imprime "Erro sintatico ... divisao por zero" e devolve 0
8 / 0;                      // 0


/*
 * AINDA NAO SUPORTADO pela gramatica (o lexer ja reconhece os tokens,
 * mas falta a regra no .y). Descomente conforme for implementando:
 *
 * 17 % 5;          // operador MOD
 * -7 + 2;          // menos unario
 * 2.5 + 1.5;       // ponto flutuante (FLOATNUM_LIT)
 * int x = 3; x * 2;  // variaveis
 */
