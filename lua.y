%skeleton "lalr1.cc" /* -*- C++ -*- */

%code requires{
   class lua_driver;
   class Scanner;
   class Node;
}

%{


#include <parser.hpp>
#include <lparser.h>
#include <lua_driver.hh>
#include <nodes.hh>

#include <string>

static int yylex(yy::parser::semantic_type *yylval,
                 Scanner  &scanner,
                 lua_driver   &driver);

%}

%union {
	Node *node;
};


%lex-param   { Scanner  &scanner  }
%parse-param { Scanner  &scanner  }

%lex-param   { lua_driver& driver }
%parse-param { lua_driver& driver }

%start ROOT

%token T_RPAREN
%token T_LPAREN
%token <node> T_SEMICOLON
%token <node> T_IF
%token <node> T_THEN
%token <node> T_ELSE
%token <node> T_ELSEIF
%token <node> T_WHILE
%token <node> T_DO
%token <node> T_NUMBER
%token <node> T_NAME
%token <node> T_FOR
%token <node> T_END
%token <node> T_FUNCTION
%token <node> T_LOCAL
%token <node> T_REPEAT
%token <node> T_UNTIL
%token <node> T_COMMENT
%token <node> T_STRING
%token <node> T_BREAK
%token <node> T_RETURN
%token <node> T_NIL
%token <node> T_FALSE
%token <node> T_TRUE
%token T_LEFT_BRACE
%token T_RIGHT_BRACE
%token T_LEFT_SQUARE_BRACE
%token T_RIGHT_SQUARE_BRACE
%token <node> T_COMMA
%token <node> T_COLON
%token <node> T_IN
%token <node> T_DOTS

%type <node> exp
%type <node> 
		block 
		binop 
		prefixexp 
		args
		explist
		fieldsep
		statement
		funcnameslist
		functioncall
		var
		unop
		laststat
		comment
		function
		tableconstructor
		parlist
		squared_expr
		field
		fieldlist
		varlist
		namelist
		funcbody
		
%right <node> T_ASSIGN

%left <node> T_OR

%right <node> T_AND

%left <node> T_EQ T_NE T_LT T_LE T_GT T_GE

%right <node> T_CONCAT

%left <node> T_PLUS T_MINUS

%left <node> T_MULT T_DIVIDE T_MODULO

%right <node> T_NOT T_TABLELEN

%right <node> T_EXPONENTIATION

%left <node> T_DOT

%%



ROOT:
  block
;



block:
  stmtseq
| stmtseq laststat
|
;

statement:
	comment                                   { $$ = $1; }
|   varlist T_ASSIGN explist  
|	functioncall

|   T_IF exp T_THEN block T_END               { $$ = driver.createNode<IfBlock>($1, $2, $4); }
|   T_IF exp T_THEN block T_ELSE block  T_END
|   T_IF exp T_THEN block elseifblock   T_END
|   T_IF exp T_THEN block elseifblock   T_ELSE block T_END
 
|   T_FOR T_NAME T_ASSIGN exp T_COMMA exp T_DO block T_END
|   T_FOR T_NAME T_ASSIGN exp T_COMMA exp T_COMMA exp T_DO block T_END
|	T_FOR namelist T_IN explist T_DO block T_END
|   T_FUNCTION funcname funcbody
|   T_LOCAL T_FUNCTION T_NAME funcbody
|   T_LOCAL namelist 
|   T_LOCAL namelist T_ASSIGN explist 
;

elseifblock:
    T_ELSEIF exp T_THEN block
|   elseifblock T_ELSEIF exp T_THEN block
;

laststat:
  T_BREAK          { $$ = $1; }
| T_RETURN         { $$ = driver.createNode<ReturnStatement>(); }
| T_RETURN explist { $$ = driver.createNode<ReturnStatement>($2); }
;

funcname:
  funcnameslist
| funcnameslist T_COLON T_NAME
;

funcnameslist:
   T_NAME 				{ $$ = $1; }
|  T_NAME T_DOT T_NAME  { $$ = driver.createNode<DotBinExpression>($2, $1, $3); }
;


stmtseq:
  stmtseq T_SEMICOLON statement /* { $$ = seq($1, $3); } */

| statement	
| statement T_SEMICOLON

| stmtseq /* one statement per line */ 
  statement /* { $$ = seq($1, $2); } */
;




varlist:
  varlist T_COMMA var    { $$ = $1; $$->as<CommaSeparatedList>()->addName($3); }
| var                    { $$ = driver.createNode<CommaSeparatedList>($1); }
;


var:
  T_NAME { $$ = $1; }
| prefixexp T_LEFT_SQUARE_BRACE exp T_RIGHT_SQUARE_BRACE
| prefixexp T_DOT T_NAME { $$ = driver.createNode<DotBinExpression>($2, $1, $3); }
;

namelist:
  namelist T_COMMA T_NAME { $$ = $1; $$->as<CommaSeparatedList>()->addName($3); }
| T_NAME                  { $$ = driver.createNode<CommaSeparatedList>($1); }
;

explist:
  explist T_COMMA exp { $$ = $1; $$->as<CommaSeparatedList>()->addName($3); }
| exp                 { $$ = driver.createNode<CommaSeparatedList>($1); }
;


exp:
  T_NIL    { $$ = $1; }
| T_FALSE  { $$ = $1; }
| T_TRUE   { $$ = $1; }
| T_NUMBER { $$ = $1; }
| T_STRING { $$ = $1; }
| T_DOTS   { $$ = $1; }
| function     { $$ = $1; }
| prefixexp    { $$ = $1; }
| tableconstructor { $$ = $1; }
| binop        { $$ = $1; }
| unop         { $$ = $1; }
| exp comment  { $$ = $1; }
| comment exp  { $$ = $2; }
;

prefixexp:
  var                   { $$ = $1; }
| functioncall          { $$ = $1; }
| T_LPAREN exp T_RPAREN { $$ = driver.createNode<Parens>($2); }
;

binop:
  exp T_PLUS    exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_MINUS   exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_MULT    exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_DIVIDE  exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_EXPONENTIATION exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_MODULO  exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_CONCAT  exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_LT      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_LE      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_GT      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_GE      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_NE      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); } 
| exp T_AND     exp { $$ = driver.createNode<BinExpression>($2, $1, $3); }    
| exp T_OR      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); }
| exp T_EQ      exp { $$ = driver.createNode<BinExpression>($2, $1, $3); }
;


unop:
  T_MINUS    exp { $$ = driver.createNode<UnaryExpression>($1, $2); }
| T_NOT      exp { $$ = driver.createNode<UnaryExpression>($1, $2); }
| T_TABLELEN exp { $$ = driver.createNode<UnaryExpression>($1, $2); }
;


function:
  T_FUNCTION funcbody { $$ = driver.createNode<Function>($2); }
;


funcbody:
  T_LPAREN T_RPAREN T_END                { $$ = driver.createNode<FunctionBody>(); }
| T_LPAREN T_RPAREN block T_END          { $$ = driver.createNode<FunctionBody>($3); }
| T_LPAREN parlist T_RPAREN block T_END  { $$ = driver.createNode<FunctionBody>($4, $2); }
| T_LPAREN parlist T_RPAREN T_END        { $$ = driver.createNode<FunctionBody>(nullptr, $2); }
;

parlist:
  namelist                 { $$ = $1; }
| namelist T_COMMA T_DOTS  { $$ = $1; $$->as<CommaSeparatedList>()->addName($3); }
| T_DOTS                   { $$ = $1; }
;


tableconstructor:
  T_LEFT_BRACE T_RIGHT_BRACE
| T_LEFT_BRACE fieldlist T_RIGHT_BRACE
;


fieldlist:
  field						{ $$ = $1; } 
| field fieldsep fieldlist
| field fieldsep
;


field:
  squared_expr T_ASSIGN exp { $$ = driver.createNode<TableField>($1, $3); }
| T_NAME T_ASSIGN exp 		{ $$ = driver.createNode<TableField>($1, $3); }
| exp						{ $$ = driver.createNode<TableField>($1); }
;

squared_expr: 
	T_LEFT_SQUARE_BRACE exp T_RIGHT_SQUARE_BRACE { $$ = driver.createNode<SquareParens>($2); }
;

fieldsep: 
  T_COMMA      { $$ = $1; } 
| T_SEMICOLON  { $$ = $1; }
;


functioncall:
  prefixexp args                   { $$ = driver.createNode<FunctionCall>($1, $2); }
| prefixexp T_COLON T_NAME args    { $$ = driver.createNode<MethodCall>($1, $3, $4); }
;


args:
  T_LPAREN T_RPAREN          { $$ = driver.createNode<Parens>(); }
| T_LPAREN explist T_RPAREN  { $$ = driver.createNode<Parens>($2); }
| tableconstructor           { $$ = $1; }
| T_STRING                   { $$ = $1; }
;


comment:
	T_COMMENT { $$ = $1; }
;


%%

#include "lua_driver.hh"
void

yy::parser::error (const yy::parser::location_type& l,
                          const std::string& m)
{
  driver.error (l, m);
}


static int yylex(yy::parser::semantic_type *yylval,
                     Scanner  &scanner,
                     lua_driver   &driver)
{
   return( scanner.yylex(yylval) );
}
