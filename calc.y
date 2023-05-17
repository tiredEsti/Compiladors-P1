%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdbool.h>
	#include <math.h>

	int errflag = 0;

	extern FILE* yyin;
	extern int yylineno;

	extern int yywrap( );
	extern int yylex();
	extern void yyerror(char *explanation);

	FILE* flog;

	int yyterminate()
	{
	  return 0;
	}
%}
%code requires {
  	#include "symtab.h"
	#include "functions.h"
}

%union {
    variable var;
};

%token <var> FL INT BOOL STR B_ID ID A_ID ADD SUB MUL DIV MOD POW BOOLOP SIN COS TAN
%token ASSIGN LPAREN RPAREN AND OR NOT EOL END SCOMMENT MCOMMENT LERR
%type <var> statement statement_list arithmetic_op1 arithmetic_op2 arithmetic_op3 boolean_op1 boolean_op2 boolean_op3 boolean_arithmetic exp arithmetic boolean trigonometric

%start program

%%
program : statement_list;

statement_list : statement_list statement | statement;

statement: ID ASSIGN exp EOL 	{	
									if($3.type == UNDEFINED){
										yyerror($3.value.sval);
									} else {
										sym_enter($1.name, &$3); 
										printf("NOM: %s, TYPE: %s, VALUE: %s\n", $1.name, typeToString($3), valueToString($3));
										fprintf(flog, "Line %d, ASSIGNATION %s := %s\n", yylineno, $1.name, valueToString($3)); }yylineno++; }
		| exp EOL				{	if($1.type == UNDEFINED){
										yyerror($1.value.sval);
									} else {
										printf("TYPE: %s, VALUE: %s\n", typeToString($1), valueToString($1));
										if ($1.name == NULL) fprintf(flog, "Line %d, unsaved EXPRESSION with value %s\n", yylineno, valueToString($1));
										else fprintf(flog, "Line %d, EXPRESSION %s with value %s\n", yylineno, $1.name, valueToString($1));}yylineno++;}
		| exp 					{	if($1.type == UNDEFINED){
										yyerror($1.value.sval);
									} else {	printf("TYPE: %s, VALUE: %s\n", typeToString($1), valueToString($1));
												if ($1.name == NULL) fprintf(flog, "Line %d, unsaved EXPRESSION with value %s\n", yylineno, valueToString($1));
												else fprintf(flog, "Line %d, EXPRESSION %s with value %s\n", yylineno, $1.name, valueToString($1));}yylineno++;}
		| EOL					{yylineno++;}
		| SCOMMENT			{ fprintf(flog, "Line %d, SINGLE LINE COMMENT DETECTED\n", yylineno);yylineno++; }
		| MCOMMENT			{ fprintf(flog, "Line %d, MULTIPLE LINE COMMENT DETECTED\n", yylineno);yylineno++; }
		| END					{yyerror("End of the file, execution COMPLETED\n"); YYABORT;}
		| LERR EOL			{yyerror("LEXICAL ERROR: invalid character.\n");yylineno++; }
		| LERR 				{yyerror("LEXICAL ERROR: invalid character.\n");}
		| error	EOL			{	if (errflag == 1){ errflag = 0;}
								else {	printf("\tSYNTAX ERROR: no matching rule found\n");
    									fprintf(flog,"\tSYNTAX ERROR: no matching rule found\n");} yylineno++;};
exp: arithmetic | boolean;

arithmetic: arithmetic_op1 | arithmetic ADD arithmetic_op1	{$$ = arithmeticCalc($1, $2, $3);}
		| arithmetic SUB arithmetic_op1 					{$$ = arithmeticCalc($1, $2, $3);}
		| ADD arithmetic_op1								{	if($2.type == STRING){
																	variable aux;
																	aux.type = STRING;
																	aux.value.sval = "";
																	$$ = arithmeticCalc(aux, $1, $2);
																} else ($$ = $2);
															};
		| SUB arithmetic_op2								{	$$.type = $2.type; 
																if($2.type == INTEGER){$$.value.ival = (-1)* $2.value.ival;
																} else if($2.type == FLOAT) {
																	$$.value.fval = (-1)* $2.value.fval;
																} else {
																	variable aux;
																	aux.type = STRING;
																	aux.value.sval = "";
																	$$ = arithmeticCalc(aux, $1, $2);
																}
															};

arithmetic_op1: arithmetic_op2 | arithmetic_op1 MUL arithmetic_op2 	{$$ = arithmeticCalc($1, $2, $3);}
		| arithmetic_op1 DIV arithmetic_op2 						{$$ = arithmeticCalc($1, $2, $3);}
		| arithmetic_op1 MOD arithmetic_op2							{$$ = arithmeticCalc($1, $2, $3);};

arithmetic_op2: arithmetic_op3 | arithmetic_op2 POW arithmetic_op3	{$$ = arithmeticCalc($1, $2, $3);};

arithmetic_op3: LPAREN arithmetic RPAREN	{$$ = $2;}
			| INT 							{ 	if($1.type == UNDEFINED){
													yyerror($1.value.sval);
												} else $$ = $1;
											}
		| FL								{ 	if($1.type == UNDEFINED){
													yyerror($1.value.sval);
												} else $$ = $1;
											}
		| STR								{ 	if($1.type == UNDEFINED){
													yyerror($1.value.sval);
												} else $$ = $1;
											}
		| A_ID								{ 	if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) {	yyerror("SEMANTIC ERROR: VARIABLE NOT FOUND.\n");errflag = 1; YYERROR;} 
												else { $$.type = $1.type; $$.value=$1.value;}}
		|ID								{ 	if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) {	yyerror("SEMANTIC ERROR: VARIABLE NOT FOUND.\n"); errflag = 1; YYERROR;} 
												else { $$.type = $1.type; $$.value=$1.value;}}
		| trigonometric LPAREN arithmetic RPAREN	{$$ = trigonometricCalc($1, $3);};

trigonometric: SIN | COS | TAN;

boolean: boolean_op1 | boolean OR boolean_op1	{$$.name = NULL; $$.type = BOOLEAN; $$.value.bval = $1.value.bval || $3.value.bval;};

boolean_op1: boolean_op2 | boolean_op1 AND boolean_op2 {$$.name = NULL; $$.type = BOOLEAN; $$.value.bval = $1.value.bval && $3.value.bval;};

boolean_op2: boolean_op3 | NOT boolean_op2 {$$.name = NULL; $$.type = BOOLEAN; $$.value.bval = !($2.value.bval);};

boolean_op3: boolean_arithmetic
	| LPAREN boolean RPAREN	{$$ = $2;}
	| BOOL 	 				{$$ = $1;}
	| B_ID					{	if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) {yyerror("SEMANTIC ERROR: VARIABLE NOT FOUND\n");errflag = 1; YYERROR;}
												else { $$.type = $1.type; $$.value=$1.value;}};

boolean_arithmetic: arithmetic BOOLOP arithmetic 	{booleanCalc($1, $2, $3);}


%%

void yyerror(char *explanation){
    if (strcmp(explanation, "End of the file, execution COMPLETED\n") == 0){
    	printf("%s", explanation);
    	fprintf(flog,"%s", explanation);
    } else{ 
    	printf("Line %d\t%s", yylineno, explanation);
    	fprintf(flog,"Line %d\t%s", yylineno, explanation);
    }
}

int main(int argc, char** argv) {
    flog = fopen("log.txt", "w");
    if(flog == NULL){
        printf("Error: Unable to open log file log.txt\n");
        return 1;
    }

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            printf("Error: Unable to open file %s\n", argv[1]);
            return 1;
        }
    }
    else {
        printf("Error: No input file specified\n");
        return 1;
    }
    yyparse();
    if(fclose(flog) != 0){
        printf("Error: Unable to close log file log.txt\n");
        return 1;
    }

    return 0;
}
