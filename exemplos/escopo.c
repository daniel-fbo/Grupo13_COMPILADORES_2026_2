int x = 1;

// a variavel de um bloco esconde a de fora, e some no '}'
{
    int x = 2;
    printf("no bloco: %d\n", x);
    {
        int x = 3;
        printf("no bloco de dentro: %d\n", x);
    }
    printf("de volta ao bloco: %d\n", x);
}
printf("fora: %d\n", x);

// sem declarar de novo, o bloco altera a variavel de fora
{
    x = x + 10;
}
printf("alterada por um bloco: %d\n", x);

// o corpo de um if tambem e um escopo
if (x > 0) {
    int so_aqui = 5;
    printf("dentro do if: %d\n", so_aqui);
}

// a variavel do for so existe dentro dele
for (int i = 0; i < 2; i++) {
    int dobro = i * 2;
    printf("i=%d dobro=%d\n", i, dobro);
}

int i = 99;
printf("o i de fora e outro: %d\n", i);
