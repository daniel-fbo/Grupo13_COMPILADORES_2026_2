int a = 10;
int b = 3;

// if simples
if (a > b) {
    printf("a e maior que b\n");
}

// if / else
if (a % 2 == 0) {
    printf("a e par\n");
} else {
    printf("a e impar\n");
}

// if encadeado (else if) 
int nota = 75;

if (nota >= 90) {
    printf("A\n");
} else if (nota >= 70) {
    printf("B\n");
} else if (nota >= 50) {
    printf("C\n");
} else {
    printf("reprovado\n");
}

// operadores logicos: && , || , !
if (a > 0 && b > 0) {
    printf("os dois sao positivos\n");
}

if (a < 0 || b < 0) {
    printf("pelo menos um e negativo\n");
} else {
    printf("nenhum e negativo\n");
}

if (!(a == b)) {
    printf("a e diferente de b\n");
}

// if aninhado
if (a > 5) {
    if (b < 5) {
        printf("a grande e b pequeno\n");
    }
}

// comparacoes com resultado de expressao
if (a * b >= 30) {
    printf("o produto chegou a 30\n");
}
