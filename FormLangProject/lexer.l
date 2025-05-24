%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
%}

%%

"form"      { return FORM; }
"section"   { return SECTION; }
"field"     { return FIELD; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

\"[^\"]*\" {
    yylval.str = strdup(yytext + 1);
    yylval.str[strlen(yylval.str)-1] = '\0';
    return STRING_LITERAL;
}

"{"         { return LBRACE; }
"}"         { return RBRACE; }
":"         { return COLON; }
";"         { return SEMICOLON; }

[ \t\n\r]+
.           { printf("Unknown character: %s\n", yytext); }
%%

int yywrap() {
    return 1;
}
