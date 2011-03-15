LIB=-lfl
CC=gcc
 
turing: turing.c
	$(CC) -Wall -o turing turing.c $(LIB) -lcurses -g

turing.c: turing.lex
	flex -oturing.c turing.lex
