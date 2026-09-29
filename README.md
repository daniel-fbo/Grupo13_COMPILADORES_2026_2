# Grupo13_COMPILADORES_2026_2

## Interpretador de C

Projeto desenvolvido na disciplina de Compiladores 1, na Universidade de Brasília (UnB).

É um interpretador para uma pequena porção da linguagem C, feito em C com Flex e Bison.
O programa lê o código, reconhece os tokens, monta uma árvore sintática (AST) e depois
percorre essa árvore executando os comandos, sem gerar código de máquina.

O caminho que o código percorre é sempre este:

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

A linguagem aceita apenas:

- variáveis numéricas (`int`, `float`, `char`), com ou sem valor inicial (`int a = 1, b;`)
- atribuição (`=`, `+=`, `-=`, `*=`, `/=`) e incremento/decremento (`++`, `--`)
- expressões matemáticas (`+`, `-`, `*`, `/`, `%`, menos unário, parênteses)
- comparações (`==`, `!=`, `<`, `>`, `<=`, `>=`) e operadores lógicos (`&&`, `||`, `!`)
- condicionais (`if`, `else`, `else if`)
- laços de repetição (`while` e `for`), com `break` e `continue`
- `printf` para mostrar resultados

Não há arrays, ponteiros, structs nem declaração de funções. Strings só aparecem como texto do `printf`.

## Integrantes

- [Anna Julia Aparecida Silva Primo](https://github.com/annaaju)
- [Daniel Filipe Borges de Oliveira](https://github.com/daniel-fbo)
- [Maria Eduarda de Oliveira Gomes](https://github.com/eduarda-ogomes)
- [Matheus Moretti Soares](https://github.com/Boynic3)