# Grupo13_COMPILADORES_2026_2

## Interpretador de C

Projeto desenvolvido na disciplina de Compiladores 1, na Universidade de Brasília (UnB).

É um interpretador para uma pequena porção da linguagem C, feito em C com Flex e Bison.
O programa lê o código, reconhece os tokens, monta uma árvore sintática (AST) e depois
percorre essa árvore executando os comandos, sem gerar código de máquina.

A linguagem aceita apenas:

- variáveis com números
- expressões matemáticas (`+`, `-`, `*`, `/`, `%`, parênteses)
- comparações e condicionais (`if` / `else`)
- laços de repetição (`while` e `for`)
- `console.log` para mostrar resultados

Não há objetos, funções, strings nem arrays.

## Integrantes

- [Anna Julia Aparecida Silva Primo](https://github.com/annaaju)
- [Daniel Filipe Borges de Oliveira](https://github.com/daniel-fbo)
- [Maria Eduarda de Oliveira Gomes](https://github.com/eduarda-ogomes)
- [Matheus Moretti Soares](https://github.com/Boynic3)