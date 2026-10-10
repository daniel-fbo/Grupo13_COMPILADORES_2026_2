// um comando que e so uma conta mostra "Resultado: valor"

// precedencia: * e / antes de + e -
2 + 3 * 4;                  // 14
(2 + 3) * 4;                // 20

// associatividade a esquerda: (10 - 2) - 3, e nao 10 - (2 - 3)
10 - 2 - 3;                 // 5

// divisao inteira: a parte decimal e descartada
100 / 7;                    // 14

// parenteses aninhados
((1 + 2) * (3 + 4)) / 3;    // 7

// resto da divisao: mesma precedencia de * e /
17 % 5;                     // 2
2 + 17 % 5;                 // 4

// menos unario: prioridade maior que a de * e /
-7 + 2;                     // -5
2 * -3;                     // -6
-(2 + 3);                   // -5

// ponto flutuante: se um lado e float, a conta inteira e em float
2.5 + 1.5;                  // 4.000000
7 / 2.0;                    // 3.500000

// comparacoes e operadores logicos valem 1 (verdadeiro) ou 0 (falso)
3 < 5;                      // 1
3 >= 5;                     // 0
4 == 4;                     // 1
4 != 4;                     // 0
1 && 0;                     // 0
1 || 0;                     // 1
!0;                         // 1

// comparacao tem prioridade menor que aritmetica, e && maior que ||
1 + 2 < 2 * 3;              // 1
0 && 0 || 1;                // 1

// variaveis
int x = 3;
x * 2;                      // 6
-x % 2;                     // -1
