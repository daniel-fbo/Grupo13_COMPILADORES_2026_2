// erro de execucao nao para o programa: a expressao vale 0 e ele continua
printf("comecou\n");

// divisao e resto por zero
8 / 0;
8 % 0;

// variavel usada sem ter sido declarada
x = 5;
printf("%d\n", y);

// variavel declarada duas vezes no mesmo escopo
int a = 1;
int a = 2;

// o '%' so aceita inteiros
5.5 % 2;

// a unica funcao que existe e o printf
raiz(16);

// printf com argumento faltando, formato desconhecido e sem o texto
printf("%d\n");
printf("%s\n", 2);
printf(3);

// string fora do printf
a = "texto";

// divisao que nao cabe em um int
int menor = -2147483647 - 1;
menor / -1;

printf("chegou ao fim, a vale %d\n", a);
