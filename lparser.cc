#include <string>
#include <iostream>
#include <FlexLexer.h>
#include "lua_driver.hh"

extern char *yytext;
extern int yylineno;

int lineno = 1;

int oper(const std::string &op, ...) {
	// std::cout << "oper " << yytext << std::endl;
	return -2;
}

void nextline() {
	++lineno;
    // std::cout << "line " << std::endl;
}

void yyerror(const char *s) {
    // fprintf(stdout, "%s\n", s);
    std::cout << "lineno: " << lineno << " e: " << s  << std::endl;
}

void execute(int i) {
    std::cout << "execute " << i << std::endl;
}

int seq(int,int) {
	std::cout << "seq " << std::endl;
	return -3;
}

int name(int i) {
	// std::cout << "name: " << yytext << " " << i << std::endl;
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


void printAndClauses(Node *clause) {
	if (not clause->is<BinExpression>()) {
		std::cout << clause->toString() << std::endl;
		return;
	}
	auto bin = clause->as<BinExpression>();
	if (bin->getOp()->toString() == "and") {
		printAndClauses(bin->getLeft());
		printAndClauses(bin->getRight());
	} else {
		std::cout << clause->toString() << std::endl;
		/*
		std::cout << bin->getOp()->toString() << ": " << std::endl <<
				" left: " << bin->getLeft()->toString() << std::endl <<
				"right: " << bin->getRight()->toString() << std::endl
				;
				*/
	}
}


int main(int argc, char* argv[]) {


	// yyparse();
	lua_driver driver;
	driver.parse( argv[1] );

	/*for(auto p : driver.getNodes()) {
		std::cout << p->toString() << std::endl;
	}*/

	for( auto p : driver.getExpressionNodes() ) {
		if ( p->is<IfBlock>() ) {
			auto ifb = p->as<IfBlock>();
			std::cout << "if expr[" << ifb->lineNo <<"]: " << ifb->getExpr()->toString() << std::endl;
			for( auto expr : ifb->childrenNodes ) {
				if ( expr->is<BinExpression>() ) {
					auto bin = expr->as<BinExpression>();
					if (bin->getOp()->toString() == "and") {
						printAndClauses(bin);
						/*
						std::cout << bin->getLeft()->toString()
								 << std::endl
								 << bin->getRight()->toString()
								 << std::endl;
					 	 */
					}
				}
			}
			std::cout << std::endl;
		} else if( p->is<Comment>() ) {
			std::cout << p->toString() << std::endl;
		}
	}

    return 0;
}

