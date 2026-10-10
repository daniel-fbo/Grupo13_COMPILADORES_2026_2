# Grupo13_COMPILADORES_2026_2

## Interpretador de C

Projeto desenvolvido na disciplina de Compiladores 1, na Universidade de Brasília (UnB).

É um interpretador para uma pequena porção da linguagem C, feito em C com Flex e Bison.
O programa lê o código, reconhece os tokens, monta uma árvore sintática (AST) e depois
percorre essa árvore executando os comandos, sem gerar código de máquina.

```
programa.c
   │
   ▼  analisadorLexico.l  (Flex)       — quebra o texto em TOKENS
   ▼  analisadorSintatico.y (Bison)    — junta os tokens segundo a GRAMÁTICA
   ▼  ast.c / ast.h                    — monta a ÁRVORE SINTÁTICA (AST)
   ▼  interpretador.c                  — percorre a árvore e EXECUTA
   │
   ▼  saída no terminal
```

## O que a linguagem aceita

- variáveis numéricas (`int`, `float`, `char`), com ou sem valor inicial (`int a = 1, b;`)
- atribuição (`=`, `+=`, `-=`, `*=`, `/=`) e incremento/decremento (`++`, `--`)
- expressões matemáticas (`+`, `-`, `*`, `/`, `%`, menos unário, parênteses)
- comparações (`==`, `!=`, `<`, `>`, `<=`, `>=`) e operadores lógicos (`&&`, `||`, `!`)
- condicionais (`if`, `else`, `else if`)
- laços de repetição (`while` e `for`), com `break` e `continue`
- blocos `{ }` com escopo próprio
- `printf` com `%d`, `%i`, `%f`, `%c` e `%%`
- comentários `//` e `/* */`

Não há arrays, ponteiros, structs nem declaração de funções: o programa é uma sequência
de comandos soltos, sem `#include` e sem `main`. Strings só aparecem como texto do `printf`.

```c
int soma = 0;

for (int n = 1; n <= 10; n++) {
    if (n % 2 == 0) continue;
    soma += n;
}

printf("soma dos impares: %d\n", soma);
```

## Como compilar e rodar

É preciso ter `gcc`, `make`, `flex` e `bison` (3.6 ou mais novo).

```
make                              # gera o executável ./interpretador
./interpretador programa.c        # roda um arquivo
./interpretador                   # lê o programa da entrada padrão
```

O interpretador termina com código 0 quando tudo deu certo e 1 quando houve erro
léxico, sintático ou de execução.

## Demonstração

Cada recurso tem um programa em `exemplos/`, e cada um tem o seu comando.

Um exemplo por vez, mostrando o programa numerado e a saída:

| Comando | O que mostra |
|:---|:---|
| `make variaveis` | Declaração, tipos, conversões, atribuição composta, `++` e `--` |
| `make expressoes` | Precedência, associatividade, divisão inteira, `float`, comparações e lógicos |
| `make condicionais` | `if`, `else`, `else if`, `&&`, `\|\|`, `!`, `if` aninhado |
| `make loops` | `while`, `for`, `break`, `continue`, laços aninhados |
| `make printf` | Escapes, `%d`, `%f`, `%c`, `%%`, largura e precisão |
| `make escopo` | Variável de bloco, sombreamento, escopo do `if` e do `for` |
| `make completo` | Tudo junto: fibonacci, primos, MDC, fizzbuzz, média, triângulo |
| `make erro-lexico` | Caractere inválido, número grande demais, string e comentário sem fechar |
| `make erro-sintatico` | `;` esquecido, expressão incompleta, `break` fora de laço, recuperação de erro |
| `make erro-execucao` | Divisão por zero, variável não declarada ou repetida, `printf` mal usado |

Em grupo, mostrando só a saída:

| Comando | O que roda |
|:---|:---|
| `make exemplos` | Os sete programas válidos |
| `make erros` | Os três programas com erro |
| `make demo` | Tudo |

`CODIGO=1` mostra também os programas num grupo (`make demo CODIGO=1`), e `CODIGO=0`
esconde o programa num exemplo (`make loops CODIGO=0`).

Outros comandos: `make rodar ARQ=arquivo.c` roda um arquivo qualquer, `make ajuda` lista
os comandos e `make clean` apaga o que foi gerado.

A organização do código está explicada em [ESTRUTURA.md](ESTRUTURA.md), e a lista de
lexemas em [listaDeRegras.md](listaDeRegras.md).

## Integrantes

- [Anna Julia Aparecida Silva Primo](https://github.com/annaaju)
- [Daniel Filipe Borges de Oliveira](https://github.com/daniel-fbo)
- [Maria Eduarda de Oliveira Gomes](https://github.com/eduarda-ogomes)
- [Matheus Moretti Soares](https://github.com/Boynic3)
