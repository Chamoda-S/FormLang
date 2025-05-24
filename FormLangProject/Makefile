formgen: parser.tab.c lex.yy.c
	gcc -o formgen parser.tab.c lex.yy.c -lfl

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

clean:
	rm -f formgen parser.tab.c parser.tab.h lex.yy.c output.html
