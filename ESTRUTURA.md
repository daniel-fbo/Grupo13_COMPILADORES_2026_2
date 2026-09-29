# Estrutura do projeto (documento provisório)

> **Provisório.** Escrito para o grupo se localizar enquanto o interpretador
> ainda está sendo construído. Deve ser atualizado ou apagado quando o
> `README.md` passar a cobrir isso.

## Visão geral

O projeto é um **interpretador** de um subconjunto de C. Diferente de um
compilador, ele não gera código de máquina: lê o programa, monta uma árvore
na memória e executa percorrendo essa árvore.

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

---

## Arquivos escritos por nós

### `src/analisadorLexico.l` — o analisador léxico (Flex)

O primeiro estágio. Recebe o texto puro e o quebra em **tokens**: as menores
unidades com significado (`if`, `123`, `+`, `;`).

Tem três seções separadas por `%%`:

1. **Definições** — o `#include "analisadorSintatico.tab.h"` (que traz os
   nomes dos tokens gerados pelo Bison) e os apelidos de regex (`DIGIT`,
   `ID`, `FLOATNUM`...), para não repetir a mesma expressão várias vezes.
2. **Regras** — pares *padrão → ação*. A ação quase sempre é
   `return ALGUM_TOKEN;`, entregando o token ao parser.
3. **Código auxiliar** — vazia aqui.

Dois detalhes de ordem importam muito, porque o Flex, em empate de tamanho,
escolhe a regra que aparece **primeiro**:

- As palavras-chave (`"if"`, `"while"`...) vêm **antes** da regra de `{ID}`.
  Sem isso, `if` seria lido como um identificador chamado "if".
- Os operadores de dois caracteres (`==`, `<=`, `++`) vêm **antes** dos de um
  (`=`, `<`, `+`). Sem isso, `==` viraria dois `=` seguidos.

Quando o token carrega um valor (um número, um nome de variável), ele é
guardado em `yylval` antes do `return` — é assim que o valor chega ao parser.
A variável `line_num` conta as quebras de linha e só serve para as mensagens
de erro.

Funções e variáveis da biblioteca padrão de C (`printf`, `scanf`) **não** são
palavras-chave: o lexer as devolve como `ID`, que é o comportamento correto.

### `src/analisadorSintatico.y` — o analisador sintático (Bison)

O segundo estágio. Recebe os tokens e verifica se a sequência forma um
programa válido, segundo a **gramática**. Também tem três seções:

1. **Declarações** — o `%union` (os tipos de valor que um token pode
   carregar), a lista de `%token` (que precisa bater exatamente com os
   `return` do `.l`) e a precedência dos operadores. As linhas
   `%left PLUS MINUS` e `%left TIMES DIVIDE MOD` são o que faz
   `2 + 3 * 4` valer 14 e não 20.
2. **Gramática** — as regras de produção. Cada uma tem uma ação em `{ }` onde
   `$1`, `$2`... são os valores dos símbolos do lado direito, e `$$` é o valor
   que a regra devolve.
3. **Código auxiliar** — `yyerror()` (chamada pelo Bison quando a entrada não
   casa com nenhuma regra) e o `main()` do programa.

**Estado atual:** a gramática só reconhece expressões aritméticas com
inteiros (`+ - * /` e parênteses), avaliadas na hora, direto na ação. Ainda
não há regras para `if`, `while`, `for`, declaração de variável nem `%`.

A regra `linha: error SEMI { yyerrok; }` é **recuperação de erro**: se uma
linha não fizer sentido, o parser descarta tokens até achar um `;` e continua,
em vez de abortar na primeira falha.

### `src/ast.h` — a interface da árvore sintática

**Vazio.** Deve declarar o `struct` do nó da AST (que tipo de nó é, seus
filhos, o valor que carrega), o `enum` com os tipos de nó e os protótipos das
funções de criação. É o arquivo que tanto o `.y` quanto o `interpretador.c`
vão incluir.

### `src/ast.c` — a construção da árvore

**Vazio.** Deve implementar o que o `ast.h` declara: as funções que alocam um
nó e o ligam aos filhos, além da função que libera a árvore no final.

Quem chama essas funções são as ações da gramática. Em vez de calcular o valor
na hora (como o `.y` faz hoje), a ação passa a **montar um nó**:

```c
expr PLUS expr   { $$ = novoNo(NO_SOMA, $1, $3); }
```

### `src/interpretador.c` — a execução

**Vazio.** Deve conter a função que recebe a raiz da AST e a percorre
recursivamente, executando cada nó conforme seu tipo: um nó de soma avalia os
dois filhos e devolve a soma; um nó `if` avalia a condição e executa só um dos
ramos; um nó `while` reavalia a condição a cada volta.

Também é aqui que mora a **tabela de símbolos**: a estrutura que guarda o
valor atual de cada variável.

### `Makefile` — a receita de build

Automatiza os três passos. Cada regra tem a forma
`alvo: dependências` seguida do comando (que **precisa** começar com TAB).

| Comando | O que faz |
|:---|:---|
| `make` | Gera o parser com o Bison, o lexer com o Flex, compila tudo com o gcc e produz o binário `interpretador`. |
| `make teste` | Compila e roda os três arquivos de `exemplos/`. |
| `make clean` | Apaga o binário e todos os arquivos gerados. |

O `make` só refaz um passo se a dependência dele for mais nova que o
resultado — por isso `lex.yy.c` depende do `.tab.c`: o Flex precisa do
cabeçalho de tokens que o Bison gera.

### `listaDeRegras.md` — a especificação dos lexemas

A tabela de tudo que o lexer deve reconhecer, agrupada por categoria
(palavras-chave, operadores, delimitadores, literais). É a referência a
consultar antes de mexer no `.l`, e a lista contra a qual conferir se o lexer
está completo.

### `README.md` — apresentação do projeto

Descrição curta, o subconjunto da linguagem aceito e os integrantes do grupo.

> **Pendência:** ainda menciona `console.log`, resíduo de quando o projeto era
> sobre JavaScript. Em C, o certo é `printf`.

### `.gitignore`

Hoje ignora apenas `.idea/`. **Vale acrescentar** os arquivos gerados pelo
build, que não devem ir para o repositório: `interpretador`,
`src/lex.yy.c`, `src/analisadorSintatico.tab.c` e `src/analisadorSintatico.tab.h`.

---

## `exemplos/` — programas de teste

| Arquivo | Conteúdo | Roda hoje? |
|:---|:---|:---|
| `expressoes.c` | Precedência, associatividade, divisão inteira, parênteses aninhados, divisão por zero. | **Sim** |
| `condicionais.c` | `if`, `else`, `else if` encadeado, `&&`, `\|\|`, `!`, `if` aninhado. | Não |
| `loops.c` | `while`, `for`, `++`, `--`, `+=`, `*=`, `break`, `continue`, loops aninhados. | Não |

Os dois últimos passam pelo **lexer** sem nenhum erro léxico (todos os tokens
são reconhecidos), mas falham no **parser**, porque a gramática ainda não tem
regras para esses comandos. Eles funcionam como especificação: o objetivo é
que rodem sem alteração quando a gramática estiver pronta.

---

## Arquivos gerados (não editar, não commitar)

Criados pelo `make` a partir do `.l` e do `.y`. Qualquer alteração neles é
perdida no próximo build; o que se edita é sempre o arquivo-fonte.

| Arquivo | Gerado por | O que é |
|:---|:---|:---|
| `src/analisadorSintatico.tab.c` | `bison` | O parser em C. |
| `src/analisadorSintatico.tab.h` | `bison -d` | Os nomes dos tokens, incluído pelo lexer. |
| `src/lex.yy.c` | `flex` | O lexer em C. |
| `interpretador` | `gcc` | O executável final. |

---

## Próximos passos sugeridos

1. Fazer o `main()` (em `analisadorSintatico.y`) **abrir o arquivo passado na
   linha de comando** e apontar `yyin` para ele. Hoje ele lê de `stdin` e
   ignora `argv`, então `make teste` não testa nada de fato.
2. Definir o nó da AST em `ast.h` e implementar `ast.c`.
3. Trocar as ações da gramática: em vez de calcular na hora, montar os nós.
4. Escrever o percurso da árvore em `interpretador.c`.
5. Estender a gramática: declaração de variáveis, `if/else`, `while`, `for`.
