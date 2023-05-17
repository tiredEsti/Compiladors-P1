%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "structs.h"
  #include "symtab.h"
  extern FILE *yyin;
  extern FILE* yyout;
  #include "calc.tab.h"

%}

%option noyywrap
%x IN_COMMENT

int [0-9]*
float [0-9]*\.[0-9]*([eE][-+]?[0-9]+)?
string \".*\"



%%


{float}         { yylval.var.type = FLOAT; yylval.var.value.fval = atof(yytext); return FL; }
{int}           { yylval.var.type = INTEGER; yylval.var.value.ival = atoi(yytext); return INT; }
"true"          { yylval.var.type = BOOLEAN; yylval.var.value.bval = 1; return BOOL; }
"false"         { yylval.var.type = BOOLEAN; yylval.var.value.bval = 0; return BOOL; }
{string}        { yylval.var.type = STRING; int len = yyleng-2; yylval.var.value.sval = (char*)malloc(sizeof(char)*len+1); strncpy(yylval.var.value.sval, yytext+1, len); return STR; }

":="            { return ASSIGN; }
"+"             { yylval.var.type = STRING; yylval.var.value.sval = "+"; return ADD; }
"-"             { yylval.var.type = STRING; yylval.var.value.sval = "-"; return SUB; }
"*"             { yylval.var.type = STRING; yylval.var.value.sval = "*"; return MUL; }
"/"             { yylval.var.type = STRING; yylval.var.value.sval = "/"; return DIV; }
"%"             { yylval.var.type = STRING; yylval.var.value.sval = "%"; return MOD; }
"**"            { yylval.var.type = STRING; yylval.var.value.sval = "**"; return POW; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"=="            { yylval.var.type = STRING; yylval.var.value.sval = "=="; return BOOLOP; }
">"             { yylval.var.type = STRING; yylval.var.value.sval = ">"; return BOOLOP; }
">="            { yylval.var.type = STRING; yylval.var.value.sval = ">="; return BOOLOP; }
"<"             { yylval.var.type = STRING; yylval.var.value.sval = "<"; return BOOLOP; }
"<="            { yylval.var.type = STRING; yylval.var.value.sval = "<="; return BOOLOP; }
"<>"            { yylval.var.type = STRING; yylval.var.value.sval = "<>"; return BOOLOP; }

"and"           { return AND; }
"or"            { return OR; }
"not"           { return NOT; }

"sin"            { yylval.var.type = STRING; yylval.var.value.sval = "sin"; return SIN; }
"cos"           { yylval.var.type = STRING; yylval.var.value.sval = "cos"; return COS; }
"tan"           { yylval.var.type = STRING; yylval.var.value.sval = "tan"; return TAN; }



"\n"            { return EOL; }
"\t"            {}
"\r"            {}
" "             {}



"//".*"\n"       { return SCOMMENT; }                  /* one line comments */



<INITIAL>{
"/*"            BEGIN(IN_COMMENT);
}
<IN_COMMENT>{
"*/"            BEGIN(INITIAL);
[^*\n]+                             /* eat comment in chunks */
"*"                                 /* eat the lone star */
\n    { return MCOMMENT;}
}

[a-zA-Z0-9]*   { yylval.var.name = (char*)malloc(sizeof(char)*yyleng+1); strncpy(yylval.var.name, yytext, yyleng); 
                  variable aux;
                  if (sym_lookup(yytext, &aux) == SYMTAB_NOT_FOUND){
                    return ID;
                  } 
                  else {  if (aux.type == BOOLEAN) return B_ID;
                          else return A_ID;
                  }
              }

. {return LERR;}


<<EOF>>                 { return END; }

%%