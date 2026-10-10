// com erro sintatico o programa nao e executado: este printf nao aparece
// o parser se recupera a cada erro e mostra todos de uma vez
printf("nao deveria aparecer\n");

// ';' esquecido: o erro e apontado na linha em que ele faltou
int a = 1
int b = 2;

// expressao incompleta
a = ;

// condicao incompleta: o parser se recupera no ')' e segue com o corpo
if (a >) {
    b = 3;
}

// break e continue so valem dentro de um laco
break;
continue;

// parentese que nao fecha
b = (a + 2;

// else sem if
else b = 4;

// tipo que a linguagem nao tem
void c;

// o operador virgula nao existe
for (int i = 0; i < 3; i++, b--) { }
