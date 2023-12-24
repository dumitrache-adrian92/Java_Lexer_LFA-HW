# Dumitrache Adrian-George 334CC

all: JavaLexer

JavaLexer: lex.yy.c
	g++ lex.yy.c -o JavaLexer -lfl -lc

lex.yy.c: JavaLexer.l
	flex JavaLexer.l

clean:
	rm -f lex.yy.c JavaLexer