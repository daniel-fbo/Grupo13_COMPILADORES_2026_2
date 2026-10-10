// tudo junto: variaveis, expressoes, condicionais, lacos e printf

// fibonacci
int anterior = 0, atual = 1;

printf("fibonacci:");
for (int n = 0; n < 10; n++) {
    printf(" %d", anterior);
    int proximo = anterior + atual;
    anterior = atual;
    atual = proximo;
}
printf("\n");

// numeros primos ate 30
printf("primos:");
for (int numero = 2; numero <= 30; numero++) {
    int primo = 1;

    for (int divisor = 2; divisor * divisor <= numero; divisor++) {
        if (numero % divisor == 0) {
            primo = 0;
            break;
        }
    }
    if (primo) printf(" %d", numero);
}
printf("\n");

// maximo divisor comum (algoritmo de Euclides)
int a = 48, b = 36;

while (b != 0) {
    int resto = a % b;
    a = b;
    b = resto;
}
printf("mdc(48, 36) = %d\n", a);

// fizzbuzz
for (int k = 1; k <= 15; k++) {
    if (k % 15 == 0)     printf("fizzbuzz ");
    else if (k % 3 == 0) printf("fizz ");
    else if (k % 5 == 0) printf("buzz ");
    else                 printf("%d ", k);
}
printf("\n");

// media com float, pulando os multiplos de 4
float soma = 0;
int quantos = 0;

for (int v = 1; v <= 10; v++) {
    if (v % 4 == 0) continue;
    soma += v;
    quantos++;
}
printf("media de %d valores: %.2f\n", quantos, soma / quantos);

// triangulo
for (int linha = 1; linha <= 4; linha++) {
    for (int coluna = 0; coluna < linha; coluna++) printf("%c", '*');
    printf("\n");
}

// contagem regressiva com while e --
int t = 3;

while (t > 0) {
    printf("%d... ", t);
    t--;
}
printf("fim\n");
