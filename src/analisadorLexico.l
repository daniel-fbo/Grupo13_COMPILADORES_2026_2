#include "parser.tab.h"   /* gerado pelo Bison: bison -d parser.y */
#include <stdlib.h>
#include <string.h>

/* ---- definições reutilizáveis (macros de regex) ---- */
DIGIT       [0-9]
LETTER      [a-zA-Z_]
ID          {LETTER}({LETTER}|{DIGIT})*
INTNUM      {DIGIT}+
FLOATNUM    {DIGIT}+"."{DIGIT}+
STRING      \"([^\"\n\\]|\\.)*\"
CHARLIT     \'([^\'\n\\]|\\.)\'

%%

 /* ---------- espaços, tabs, comentários ---------- */
[ \t]+                 { /* ignora espaços e tabs */ }
\n                      { line_num++; }
"//".*                  { /* comentário de linha, ignora */ }
"/*"([^*]|\*+[^*/])*\*+"/"   { /* comentário de bloco, ignora */ }