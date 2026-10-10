CC     = gcc
CFLAGS = -Wall -Wextra
SRC    = src
BIN    = interpretador

PARSER = $(SRC)/analisadorSintatico.tab.c
LEXER  = $(SRC)/lex.yy.c
FONTES = $(PARSER) $(LEXER) $(SRC)/ast.c $(SRC)/interpretador.c

EXEMPLOS = variaveis expressoes condicionais loops printf escopo completo
ERROS    = erro-lexico erro-sintatico erro-execucao

# CODIGO=1 mostra o programa antes da saida, CODIGO=0 mostra so a saida
CODIGO = 1

# ---------- build ----------

all: $(BIN)

$(PARSER): $(SRC)/analisadorSintatico.y
	bison -d -o $@ $<

$(LEXER): $(SRC)/analisadorLexico.l $(PARSER)
	flex -o $@ $<

$(BIN): $(FONTES) $(SRC)/ast.h
	$(CC) $(CFLAGS) -o $@ $(FONTES)

# ---------- um exemplo por vez ----------

define mostrar
@printf '\n===== %s =====\n' $(1)
@if [ "$(CODIGO)" = 1 ]; then cat -n $(1); printf -- '----- saida -----\n'; fi
@./$(BIN) $(1); printf '[codigo de saida: %d]\n' $$?
endef

$(EXEMPLOS): %: exemplos/%.c $(BIN)
	$(call mostrar,$<)

$(ERROS): erro-%: exemplos/erros/%.c $(BIN)
	$(call mostrar,$<)

rodar: $(BIN)
	@test -n "$(ARQ)" || { echo "uso: make rodar ARQ=arquivo.c"; exit 1; }
	@./$(BIN) $(ARQ)

# ---------- grupos e demonstracao completa ----------

exemplos erros demo: CODIGO = 0

exemplos: $(EXEMPLOS)
erros: $(ERROS)
demo: exemplos erros

# ---------- utilidades ----------

ajuda:
	@echo "make                  compila o interpretador"
	@echo "make rodar ARQ=x.c    roda um arquivo qualquer"
	@echo "make clean            apaga o que foi gerado"
	@echo
	@echo "um exemplo por vez (mostra o programa e a saida):"
	@echo "  $(EXEMPLOS)"
	@echo "  $(ERROS)"
	@echo
	@echo "grupos (so a saida; use CODIGO=1 para ver os programas):"
	@echo "  make exemplos       todos os programas validos"
	@echo "  make erros          os tres tipos de erro"
	@echo "  make demo           tudo"

clean:
	rm -f $(BIN) $(LEXER) $(PARSER) $(PARSER:.c=.h)

.PHONY: all rodar exemplos erros demo ajuda clean $(EXEMPLOS) $(ERROS)
