// texto puro e escapes
printf("texto simples\n");
printf("coluna 1\tcoluna 2\n");
printf("aspas \"assim\" e barra \\ assim\n");

// %d e %i: inteiros
printf("%d + %i = %d\n", 2, 3, 2 + 3);

// %f: decimais
printf("%f\n", 3.14159);

// %c: caracteres
printf("%c%c%c\n", 'o', 'i', '!');
printf("o codigo de %c e %d\n", 'A', 'A');

// %%: o proprio sinal de porcentagem
printf("100%%\n");

// largura e precisao
printf("[%5d]\n", 42);
printf("[%-5d]\n", 42);
printf("[%05d]\n", 42);
printf("[%.2f]\n", 3.14159);
printf("[%8.3f]\n", 3.14159);

// printf devolve quantos caracteres imprimiu
int n = printf("abc\n");
printf("imprimiu %d caracteres\n", n);
