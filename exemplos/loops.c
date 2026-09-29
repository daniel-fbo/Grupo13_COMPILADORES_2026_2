// while contando de 1 ate 5
int i = 1;

while (i <= 5) {
    printf("%d\n", i);
    i = i + 1;
}

// while com o operador de incremento
int j = 0;

while (j < 3) {
    printf("j vale %d\n", j);
    j++;
}

// for classico 
for (int k = 0; k < 5; k++) {
    printf("k vale %d\n", k);
}

// for decrescente
for (int c = 10; c > 0; c--) {
    printf("%d\n", c);
}

// atribuicao composta dentro do loop: soma de 1 ate 10
int soma = 0;

for (int n = 1; n <= 10; n++) {
    soma += n;
}

printf("a soma vale %d\n", soma);

// fatorial de 5, usando *= 
int fat = 1;

for (int m = 1; m <= 5; m++) {
    fat *= m;
}

printf("5! vale %d\n", fat);

// break: para no primeiro multiplo de 7 
for (int p = 1; p < 100; p++) {
    if (p % 7 == 0) {
        printf("achei: %d\n", p);
        break;
    }
}

// continue: imprime so os impares 
for (int q = 1; q <= 10; q++) {
    if (q % 2 == 0) {
        continue;
    }
    printf("%d\n", q);
}

// loops aninhados: tabuada de 1 a 3
for (int x = 1; x <= 3; x++) {
    for (int y = 1; y <= 3; y++) {
        printf("%d x %d = %d\n", x, y, x * y);
    }
}
