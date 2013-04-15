#pragma once

#include "parser.hpp"
#include "nodes.hh"

#include <map>
#include <string>
#include <vector>

class lua_driver
{
public:
   lua_driver() {};
   virtual ~lua_driver();

  std::map<std::string, int> variables;

  int result;

  // Handling the scanner.
  void scan_begin ();
  void scan_end ();
  bool trace_scanning;

  // Run the parser.  Return 0 on success.
  int parse (const std::string& f);
  // Error handling.
  void error (const yy::location& l, const std::string& m);
  void error (const std::string& m);

  const std::vector<Node *> getNodes() const;
  const std::vector<Node *> getExpressionNodes() const {
	  return expressionNodes;
  }

  template<class T, typename... Args>
  Node *createNode(Args... args) {
	  Node *n = new T(args...);
      addNode(n);
	  return n;
  }

private:
  std::string file;
  bool trace_parsing;
  yy::parser *parser;
  Scanner *scanner;
  std::vector<Node *> expressionNodes;

  void addNode(Node *);
};


#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#undef  YY_DECL
#define YY_DECL int  Scanner::yylex()


 class Scanner : public yyFlexLexer{
 public:

	Scanner(std::istream *in) : yyFlexLexer(in),
                                   yylval( nullptr ){};

	virtual ~Scanner();

    int yylex(yy::parser::semantic_type *lval)
    {
       yylval = lval;
       return( yylex() );
    }

    template<class T, class P>
    Node *createNode(const P &v) {
    	Node *n = new T(v);
    	addAndAssinNode(n);
    	return n;
    }

    template<class T, class P1, class P2>
    Node *createNode(const P1 &v1, const P2 &v2) {
    	T *n = new T(v1, v2);
    	yylval->node = n;
    	n->setLocation(lineno());
    	nodes.push_back(n);
    	return n;
    }

    template<class T, class P1, class P2, class P3>
    Node *createNode(const P1 &v1, const P2 &v2, const P2 &v3) {
    	T *n = new T(v1, v2, v3);
    	yylval->node = n;
    	n->setLocation(lineno());
    	nodes.push_back(n);
    	return n;
    }

    const std::vector<Node *> getNodes() const;

    void addAndAssinNode(Node *n);

 private:
    /* hide this one from public view */
    int yylex();
    /* yyval ptr */
    yy::parser::semantic_type *yylval;
    std::vector<Node *> nodes;
};


