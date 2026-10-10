// declaracao com e sem valor inicial, uma ou varias por linha
int a = 10;
int b;
float f = 2.5;
char c = 'A';
int x = 1, y = 2, z;

b = 3;
z = x + y;
printf("a=%d b=%d f=%f c=%c z=%d\n", a, b, f, c, z);

// conversao ao guardar: cada variavel fica com o proprio tipo
int truncado = 3.9;
float metade = 7 / 2;
float exata = 7 / 2.0;
char proxima = c + 1;
printf("%d %f %f %c\n", truncado, metade, exata, proxima);

// um char e um numero: vale o codigo do caractere
printf("%c vale %d\n", c, c);

// atribuicao composta
a += 5;
printf("a += 5  -> %d\n", a);
a -= 3;
printf("a -= 3  -> %d\n", a);
a *= 2;
printf("a *= 2  -> %d\n", a);
a /= 4;
printf("a /= 4  -> %d\n", a);

// incremento e decremento: o prefixado vale o valor novo, o posfixado o antigo
int i = 5;
int antes = i++;
int depois = ++i;
printf("i++ valeu %d, ++i valeu %d, i ficou %d\n", antes, depois, i);
antes = i--;
depois = --i;
printf("i-- valeu %d, --i valeu %d, i ficou %d\n", antes, depois, i);

// atribuicao encadeada e atribuicao dentro de uma expressao
x = y = 7;
z = (x = 2) + 3;
printf("x=%d y=%d z=%d\n", x, y, z);
