CC=gcc
CFLAGS=-g -Wall -I.

calc: calc.tab.o lex.yy.o symtab.o functions.o
	$(CC) -o $@ $^ -lm

calc.tab.o: calc.tab.c
	$(CC) $(CFLAGS) -c $<

calc.tab.c: calc.y
	bison -d $<

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c $<

lex.yy.c: lex.l
	flex $<

symtab.o: symtab.c
	$(CC) $(CFLAGS) -c $<

functions.o: functions.c
	$(CC) $(CFLAGS) -c $<

.PHONY: clean
clean:
	rm -f calc calc.tab.c calc.tab.h lex.yy.c *.o log.txt

