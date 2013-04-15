#include <iostream>
#include <fstream>
#include <string>
#include <assert.h>

#include "parser.hpp"

#include "lua_driver.hh"

lua_driver::~lua_driver () {
	for(auto p : expressionNodes) {
		delete p;
	}
	expressionNodes.clear();
}

void lua_driver::error (const yy::location& l, const std::string& m) {
	std::cout << "error: " << l << ": " << m << std::endl;
}

void lua_driver::error (const std::string& m) {
	std::cout << "error: " << m << std::endl;
}

int lua_driver::parse (const std::string& f) {

	    std::ifstream in_file( f.c_str() );
	    if( ! in_file.good() ) exit( EXIT_FAILURE );
	    scanner = new Scanner( &in_file );

	    /* check to see if its initialized */
	    assert( scanner != nullptr );
	    parser = new yy::parser( (*scanner) /* scanner */,
	                                (*this) /* driver */ );
	    // parser->set_debug_level(7);

	    assert( parser != nullptr );
	    if( parser->parse() )
	    {
	       std::cerr << "Parse failed!!\n";
	    }
}

void lua_driver::addNode(Node *n) {
	n->setLocation(scanner->lineno());
	expressionNodes.push_back(n);
}

const std::vector<Node *> lua_driver::getNodes() const {
	return scanner->getNodes();
}


const std::vector<Node *> Scanner::getNodes() const {
	return nodes;
}

void Scanner::addAndAssinNode(Node *n) {
	yylval->node = n;
	n->setLocation(lineno());
	nodes.push_back(n);
}

Scanner::~Scanner() {
	for(auto p : nodes) {
		delete p;
	}
	nodes.clear();
}
