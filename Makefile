#      make          -> monta o interpretador
#      make teste    -> monta e já roda os exemplos
#      make clean    -> apaga tudo que foi gerado (deixa a pasta limpa)
#
#  Como ler as regras deste arquivo?
#  Cada regra tem este formato:
#
#      o_que_eu_quero_criar: do_que_eu_preciso_para_criar
#          comando que cria

#  a linha do comando precisa começar com um tab


# compilador de C
CC = gcc

# flag
CFLAGS = -Wall


SRC = src

# nome do programa final que vai ser criado
BIN = interpretador

#  Regra principal -> executa a PRIMEIRA regra do arquivo, all: criar o
#  interpretador

all: $(BIN)


#  PASSO 1 - O Bison lê a gramática
$(SRC)/analisadorSintatico.tab.c: $(SRC)/analisadorSintatico.y
	bison -d -o $(SRC)/analisadorSintatico.tab.c $(SRC)/analisadorSintatico.y


#  PASSO 2 - O Flex lê as regras de palavras
$(SRC)/lex.yy.c: $(SRC)/analisadorLexico.l $(SRC)/analisadorSintatico.tab.c
	flex -o $(SRC)/lex.yy.c $(SRC)/analisadorLexico.l


#  PASSO 3 - O gcc junta tudo num programa só
$(BIN): $(SRC)/analisadorSintatico.tab.c $(SRC)/lex.yy.c $(SRC)/ast.c $(SRC)/interpretador.c
	$(CC) $(CFLAGS) -o $(BIN) $(SRC)/analisadorSintatico.tab.c $(SRC)/lex.yy.c $(SRC)/ast.c $(SRC)/interpretador.c -lm


#  make teste
teste: $(BIN)
	./$(BIN) exemplos/expressoes.js
	./$(BIN) exemplos/condicionais.js
	./$(BIN) exemplos/loops.js

#  make clean
clean:
	rm -f $(BIN) $(SRC)/lex.yy.c $(SRC)/analisadorSintatico.tab.c $(SRC)/analisadorSintatico.tab.h

#  .PHONY avisa ao make que "all", "teste" e "clean" são só NOMES de
#  tarefas, e não arquivos de verdade
.PHONY: all teste clean