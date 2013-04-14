#include <string>
#include <iostream>
#include <FlexLexer.h>

extern char *yytext;
extern int yylineno;

int lineno = 1;

int oper(const std::string &op, ...) {
	std::cout << "oper " << yytext << std::endl;
	return -2;
}

void nextline() {
	++lineno;
    std::cout << "line " << std::endl;
}

void yyerror(const char *s) {
    // fprintf(stdout, "%s\n", s);
    std::cout << "lineno: " << lineno << " e: " << s << ": " << yytext << std::endl;
}

void execute(int i) {
    std::cout << "execute " << i << std::endl;
}

int seq(int,int) {
	std::cout << "seq " << std::endl;
	return -3;
}

int name(int i) {
	std::cout << "name: " << yytext << " " << i << std::endl;
	return -i;
}


void comment(const std::string &comment) {
	std::cout << "comment: " << comment << std::endl;
}

void linecomment(const std::string &comment) {
	std::cout << "linecomment: " << comment << std::endl;
}



int yyparse ();

extern int yydebug;

int main() {

	// yydebug = 1;

	yyparse();

    return 0;
}

