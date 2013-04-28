#pragma once

#include "parser.hpp"
#include "nodes.hh"

#include <map>
#include <string>
#include <vector>
#include <memory>

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

  void addNode(Node *);
  void setRootNode(Node *rootNode);
  Node *getRootNode();

private:
  std::string file;
  bool trace_parsing;
  std::shared_ptr<yy::parser> parser;
  std::shared_ptr<Scanner> scanner;
  std::vector<Node *> expressionNodes;
  Node *rootNode = nullptr;
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

    template<class T, typename... Args>
    Node *createNode(Args... args) {
    	Node *n = new T(args...);
    	addAndAssinNode(n);
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


