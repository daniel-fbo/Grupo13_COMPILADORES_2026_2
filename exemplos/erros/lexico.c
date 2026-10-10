// com erro lexico o programa nao e executado: este printf nao aparece
printf("nao deveria aparecer\n");

// caracteres que nao existem na linguagem
int a = 5 @;
int b = 3 $;

// numero que nao cabe em um int
int grande = 99999999999;

// string que nao fecha na mesma linha: o resto da linha se perde,
// entao o parser tambem reclama do ')' que sumiu
printf("esqueci de fechar);

// comentario de bloco que nunca fecha
/* o arquivo acaba aqui dentro
