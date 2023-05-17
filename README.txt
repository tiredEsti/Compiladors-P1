# Calculator
This is a simple command-line calculator program that can evaluate mathematical expressions. It supports basic mathematical operations (addition, subtraction, multiplication, division, and exponentiation) and functions (sin, cos, tan), as well as strings and string concatenation.

## Implementation Details
The program uses a combination of Flex and Bison to tokenize and parse the input expressions. The tokenized expressions are then evaluated using a simple algorithm. Variables are saved in has table according to the provided symtab functionality.

* calc.y: Bison grammar file that defines the grammar rules for the calculator
* lex.l: Flex file that defines the regular expressions for the lexer
* symtab.c: Symbol table implementation for storing variables and their values
* functions.c: Implementation of mathematical functions
* calc.tab.c and calc.tab.h: Generated files from Bison
* lex.yy.c: Generated file from Flex

## Compiling and Running the Program
To compile the program, you need to have Flex and Bison installed. You can then use the provided Makefile to build the program:

Copy code
```
make
```
This will create the calc executable.

To run the program, simply execute the calc executable and enter an expression:

Copy code
```
./calc input.txt
```
To clean the object files and executables copy code
```
make clean
```
## Details
* The program supports basic mathematical operations (+,-,*,/,**) and additionally trigonometric functions (sin,cos,tan) and string. Numerical values must be integers or floats
* Exponential numbers are also supported
* The program detects lexic, syntax and sematic errors and is able to recover ignoring the bogus instruction
* Errors detected in the function file are passed to bison by declaring the type of an error result as "UNDEFINED". Bison catches UNDEFINED type variables, displays and handles errors
* The errflag global variable en calc.y is used to differentiate semantic and syntax errors, when YYERROR is thrown
* The program generates a log file which saves details of the instructions recieved by bison line by line
* The input.txt provided includes a test of all the main functions error handling
* Any warnings come from the provided symtab files
* A message is displayed indicating when EOF is detected and executed completed
* File errors 