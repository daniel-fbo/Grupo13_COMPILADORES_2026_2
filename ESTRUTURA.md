# Estrutura do projeto

Guia para se localizar no código do interpretador. O que a linguagem aceita e como
compilar e rodar estão no [README.md](README.md).

## Visão geral

O projeto é um **interpretador** de um subconjunto de C. Diferente de um compilador,
ele não gera código de máquina: lê o programa, monta uma árvore na memória e executa
percorrendo essa árvore.

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

```
.
├── Makefile
├── README.md
├── ESTRUTURA.md
├── listaDeRegras.md
├── src/
│   ├── analisadorLexico.l
│   ├── analisadorSintatico.y
│   ├── ast.h
│   ├── ast.c
│   └── interpretador.c
└── exemplos/
    ├── variaveis.c  expressoes.c  condicionais.c  loops.c
    ├── printf.c  escopo.c  completo.c
    └── erros/
        └── lexico.c  sintatico.c  execucao.c
```

---

## `src/analisadorLexico.l` — o analisador léxico (Flex)

O primeiro estágio. Recebe o texto puro e o quebra em **tokens**: as menores unidades
com significado (`if`, `123`, `+`, `;`).

Tem três seções separadas por `%%`:

1. **Definições** — os `#include`, as funções auxiliares (`erroLexico`, `escape`,
   `textoDaString`) e os apelidos de regex (`DIGIT`, `ID`, `FLOATNUM`...).
2. **Regras** — pares *padrão → ação*. A ação quase sempre é `return ALGUM_TOKEN;`,
   entregando o token ao parser.
3. **Código auxiliar** — vazia.

A ordem das regras importa, porque o Flex, em empate de tamanho, escolhe a que aparece
**primeiro**:

- As palavras-chave (`"if"`, `"while"`...) vêm **antes** da regra de `{ID}`. Sem isso,
  `if` seria lido como um identificador chamado "if".
- Os operadores de dois caracteres (`==`, `<=`, `++`) vêm **antes** dos de um (`=`, `<`,
  `+`). Sem isso, `==` viraria dois `=` seguidos.

Quando o token carrega um valor (um número, um nome de variável), ele é guardado em
`yylval` antes do `return`. Os escapes são resolvidos aqui: `'\n'` chega ao parser
valendo 10, e uma string chega **sem as aspas** e com `\n`, `\t`, `\"`, `\\` já trocados
pelo caractere de verdade.

Sobre as linhas:

- `linha` conta as quebras de linha, e a macro `YY_USER_ACTION` copia esse número para
  `yylloc` a cada token. É o que permite ao parser saber a linha de cada pedaço do
  programa (o `@1.first_line` do `.y`).
- O bloco `%{ %}` no começo das regras roda a cada chamada de `yylex` e guarda em
  `linha_anterior` a linha do token entregue antes. O parser usa esse valor para apontar
  um `;` esquecido na linha em que ele faltou.

O comentário de bloco (`/* ... */`) usa um estado exclusivo, `COMENTARIO`, para continuar
contando as linhas lá dentro e para avisar quando o arquivo acaba sem o `*/`.

`printf` **não** é palavra-chave: o lexer o devolve como `ID`, e quem o reconhece pelo
nome é o interpretador, na hora de executar a chamada.

Erros léxicos: caractere inválido, string que não fecha na linha, comentário de bloco que
não fecha e número inteiro que não cabe em um `int`.

## `src/analisadorSintatico.y` — o analisador sintático (Bison)

O segundo estágio. Recebe os tokens, verifica se a sequência forma um programa válido
segundo a **gramática** e monta a AST. Também tem três seções:

1. **Declarações** — o `%union` (os tipos de valor que um token ou uma regra pode
   carregar, incluindo `No *`), a lista de `%token` (que precisa bater com os `return`
   do `.l`), os `%type` (o que cada regra devolve) e a precedência dos operadores. O
   texto entre aspas ao lado de cada token é o nome que aparece nas mensagens de erro.
2. **Gramática** — as regras de produção. Cada uma tem uma ação em `{ }` onde `$1`,
   `$2`... são os valores dos símbolos do lado direito, `$$` é o valor que a regra
   devolve e `@1.first_line` é a linha do primeiro símbolo.
3. **Código auxiliar** — as funções de erro e o `main()` do programa.

As ações **não executam nada**: só montam nós. Por exemplo:

```c
operacao PLUS operacao   { $$ = novoBinario(@2.first_line, OP_SOMA, $1, $3); }
```

A precedência vai da menor para a maior: `||`, `&&`, `==` `!=`, `<` `>` `<=` `>=`,
`+` `-`, `*` `/` `%`, e por último `!` e o menos unário. É isso que faz `2 + 3 * 4`
valer 14 e não 20. A atribuição fica num nível próprio (`expr`), acima de todos os
operadores, e só aceita um identificador do lado esquerdo. `SEM_ELSE` e `ELSE` resolvem
o "else pendurado": o `else` fica com o `if` mais próximo.

O programa inteiro vira uma lista de comandos guardada na variável `raiz`.

Erros sintáticos:

- **Mensagem** — `yyreport_syntax_error` monta o texto. Quando o parser sabe o que
  faltou, a mensagem é `esperado ';' antes de 'int'`, na linha do token anterior. Quando
  há possibilidades demais, é só `';' inesperado`, na linha do próprio token.
- **`break` e `continue` fora de um laço** — detectados já aqui, sem esperar a execução:
  `profundidade_laco` conta em quantos laços o parser está dentro.
- **Recuperação** — as regras `comando: error SEMI` e `condicao: LPAREN error RPAREN`
  fazem o parser descartar tokens até achar um `;` (ou o `)` da condição) e continuar,
  em vez de abortar na primeira falha. Os `%destructor` liberam o que foi descartado.

O `main()` abre o arquivo passado na linha de comando (ou lê a entrada padrão), chama
`yyparse()` e, **só se não houve erro léxico nem sintático**, entrega a árvore para
`interpretar()`. O programa termina com código 1 se houve qualquer erro.

## `src/ast.h` e `src/ast.c` — a árvore sintática

O `ast.h` é incluído tanto pelo `.y` quanto pelo `interpretador.c`. Declara os tipos de
variável (`Tipo`), os operadores (`Operador`), os tipos de nó (`TipoNo`) e o `struct No`:
um único formato para todos os nós, com o tipo, a linha, até quatro filhos (`filho[0]`
a `filho[3]`) e o ponteiro `prox`.

O `prox` é o que forma as **listas**: os comandos de um bloco, os argumentos de uma
chamada e as variáveis de uma declaração (`int a = 1, b;` vira dois nós `NO_DECL`
encadeados).

Campos que cada nó usa:

| Nó | Representa | Campos |
|:---|:---|:---|
| `NO_INT` | número inteiro ou caractere | `valor_int` |
| `NO_FLOAT` | número decimal | `valor_float` |
| `NO_STRING` | texto do `printf` | `nome` (o texto, já sem aspas e com os escapes trocados) |
| `NO_VAR` | uso de uma variável | `nome` |
| `NO_BINARIO` | `a + b`, `a < b`, `a && b` | `op`, `filho[0]`, `filho[1]` |
| `NO_UNARIO` | `-a`, `!a` | `op`, `filho[0]` |
| `NO_ATRIB` | `x = valor` | `nome`, `filho[0]` |
| `NO_INCDEC` | `x++`, `--x` | `nome`, `op` (`OP_SOMA` ou `OP_SUB`), `prefixo` (1 em `++x`) |
| `NO_CHAMADA` | `printf(...)` | `nome`, `filho[0]` (lista de argumentos) |
| `NO_DECL` | `int x = valor` | `tipo_var`, `nome`, `filho[0]` (`NULL` sem valor inicial) |
| `NO_EXPR_CMD` | `expressao;` | `filho[0]` |
| `NO_BLOCO` | `{ ... }` | `filho[0]` (lista de comandos) |
| `NO_IF` | `if (c) a else b` | `filho[0]` condição, `filho[1]` então, `filho[2]` senão |
| `NO_WHILE` | `while (c) corpo` | `filho[0]` condição, `filho[1]` corpo |
| `NO_FOR` | `for (i; c; p) corpo` | `filho[0]` início, `filho[1]` condição, `filho[2]` passo, `filho[3]` corpo |
| `NO_BREAK`, `NO_CONTINUE` | `break;`, `continue;` | — |
| `NO_RETURN` | `return valor;` | `filho[0]` |

O `ast.c` implementa `novoNo` e as funções específicas (`novoInt`, `novoBinario`,
`novoAtrib`...), que alocam um nó e o ligam aos filhos; `anexar`, que põe um nó no fim de
uma lista; e `liberarArvore`, que libera tudo no final. As funções que recebem `nome`
ficam donas da string (o `strdup` do lexer): quem a libera é a `liberarArvore`.

`x += valor` entra na árvore como `x = x + valor` (`novoAtribComposta`), então o
interpretador só precisa saber executar a atribuição simples.

## `src/interpretador.c` — a execução

Percorre a árvore recursivamente. São duas funções principais:

- `avaliar(no)` — calcula uma **expressão** e devolve um `Valor`. Um nó de soma avalia
  os dois filhos e devolve a soma; `&&` e `||` só avaliam o lado direito quando o
  esquerdo não decide o resultado.
- `executar(lista)` — roda uma lista de **comandos**, chamando `executarComando` para
  cada um. Um `if` avalia a condição e executa só um dos ramos; um `while` reavalia a
  condição a cada volta.

**Valores.** Um `Valor` é sempre `int` ou `float`. Um `char` vira `int` quando entra numa
conta, e se um dos lados de uma operação é `float` a conta inteira é feita em `float`,
como em C. Ao guardar numa variável, `converter` ajusta o valor ao tipo dela: `float`
para `int` perde a parte decimal, `int` para `char` fica com um byte só.

**Tabela de símbolos.** Guarda o valor atual de cada variável. É uma pilha: a busca
começa pela variável declarada por último, então a de um bloco interno esconde a de
fora. `abrirEscopo` marca o topo da pilha e `fecharEscopo` desempilha o que foi
declarado depois da marca. Um bloco, o corpo de `if`/`while`/`for` e o `int i` de um
`for` têm escopo próprio. Variável sem valor inicial começa em zero.

**`break`, `continue` e `return`.** Funcionam por um **sinal**: quem os executa só
levanta o sinal, todos os comandos em volta param ao vê-lo, e o laço é quem o abaixa
(`lacoTerminou`). `return` encerra o programa, já que não há funções.

**`printf`.** É a única função que existe. Aceita `%d`, `%i`, `%f`, `%c` e `%%`, com
largura e precisão opcionais (`%5d`, `%.2f`), e devolve quantos caracteres imprimiu.

**Comando que é só uma conta.** `2 + 3 * 4;` imprime `Resultado: 14`. Atribuição,
`++`/`--` e `printf` não imprimem nada além do próprio efeito.

**Erros de execução.** Divisão por zero, divisão que não cabe em um `int`, variável não
declarada ou declarada duas vezes, `%` com `float`, função inexistente e `printf` mal
usado imprimem `Erro de execucao na linha N: ...`; a expressão passa a valer 0 e o
programa **continua**.

---

## `Makefile` — build e demonstração

| Comando | O que faz |
|:---|:---|
| `make` | Gera o parser com o Bison, o lexer com o Flex e compila tudo no binário `interpretador`. |
| `make <exemplo>` | Roda um exemplo, mostrando o programa numerado e a saída. |
| `make exemplos` | Roda os sete programas válidos, só a saída. |
| `make erros` | Roda os três programas com erro, só a saída. |
| `make demo` | Roda tudo. |
| `make rodar ARQ=arquivo.c` | Roda um arquivo qualquer. |
| `make ajuda` | Lista os comandos. |
| `make clean` | Apaga o binário e os arquivos gerados. |

O `make` só refaz um passo se a dependência dele for mais nova que o resultado. Por isso
`lex.yy.c` depende do `.tab.c`: o Flex precisa do cabeçalho de tokens que o Bison gera.

A variável `CODIGO` decide se o programa aparece antes da saída. Vale 1 por padrão e 0
nos grupos, e pode ser trocada na linha de comando: `make demo CODIGO=1`.

Depois de cada exemplo aparece `[codigo de saida: N]`: 0 quando o programa rodou sem
erro, 1 quando houve erro léxico, sintático ou de execução.

## `exemplos/` — programas de demonstração

| Comando | Arquivo | Conteúdo |
|:---|:---|:---|
| `make variaveis` | `variaveis.c` | Declaração, tipos, conversões, atribuição composta, `++` e `--`, atribuição encadeada. |
| `make expressoes` | `expressoes.c` | Precedência, associatividade, divisão inteira, `%`, menos unário, `float`, comparações e lógicos. |
| `make condicionais` | `condicionais.c` | `if`, `else`, `else if` encadeado, `&&`, `\|\|`, `!`, `if` aninhado. |
| `make loops` | `loops.c` | `while`, `for`, `++`, `--`, `+=`, `*=`, `break`, `continue`, laços aninhados. |
| `make printf` | `printf.c` | Escapes, `%d`, `%i`, `%f`, `%c`, `%%`, largura, precisão, valor devolvido. |
| `make escopo` | `escopo.c` | Variável de bloco, sombreamento, escopo do `if` e do `for`. |
| `make completo` | `completo.c` | Tudo junto: fibonacci, primos, MDC, fizzbuzz, média, triângulo. |
| `make erro-lexico` | `erros/lexico.c` | Os quatro erros léxicos. |
| `make erro-sintatico` | `erros/sintatico.c` | Os erros sintáticos e a recuperação: todos aparecem de uma vez. |
| `make erro-execucao` | `erros/execucao.c` | Os erros de execução, com o programa seguindo até o fim. |

Os programas válidos, menos o `expressoes.c`, são C de verdade: a saída do interpretador
é a mesma de compilá-los com o gcc dentro de um `main`. O `expressoes.c` usa comandos que
são só uma conta, que em C não imprimem nada.

Não há testes automáticos: os comandos mostram a saída, sem comparar com um resultado
esperado.

## Outros arquivos

- **`listaDeRegras.md`** — a tabela de tudo que o lexer reconhece, por categoria. É a
  referência a consultar antes de mexer no `.l`.
- **`.gitignore`** — ignora as pastas das IDEs e os arquivos gerados pelo build.

Arquivos gerados pelo `make` (não editar, não commitar):

| Arquivo | Gerado por | O que é |
|:---|:---|:---|
| `src/analisadorSintatico.tab.c` | `bison` | O parser em C. |
| `src/analisadorSintatico.tab.h` | `bison -d` | Os nomes dos tokens, incluído pelo lexer. |
| `src/lex.yy.c` | `flex` | O lexer em C. |
| `interpretador` | `gcc` | O executável final. |

---

## O que não existe

- **Funções, `#include` e `main`:** o programa é uma sequência de comandos soltos.
- **Operador vírgula:** `for (...; ...; a++, b--)` é erro sintático.
- **`%s` no `printf`:** não há variáveis de string.
- **Números como `.5` e `5.`:** o lexer só reconhece decimal com dígito dos dois lados
  do ponto (`2.5`).
- **`void`, `[` e `]`:** o lexer devolve os tokens, mas nenhuma regra da gramática os
  usa (não há funções nem arrays).
