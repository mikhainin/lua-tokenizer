
%{
#include "parser.h"
/* #include <string> */
#define YYDEBUG 1
%}
/*
%union {
	int ival;
	std::string sval;
};
*/
%start ROOT

%token T_EQ
%token T_NE
%token T_LT
%token T_LE
%token T_GT
%token T_GE
%token T_PLUS
%token T_MINUS
%token T_MULT
%token T_DIVIDE
%token T_RPAREN
%token T_LPAREN
%token T_ASSIGN
%token T_AND
%token T_OR
%token T_NOT
%token T_SEMICOLON
%token T_IF
%token T_THEN
%token T_ELSE
%token T_ELSEIF
%token T_WHILE
%token T_DO
%token T_NUMBER
%token T_NAME
%token T_FOR
%token T_END
%token T_FUNCTION
%token T_LOCAL
%token T_REPEAT
%token T_UNTIL
%token T_COMMENT
%token T_STRING
%token T_BREAK
%token T_RETURN
%token T_NIL
%token T_FALSE
%token T_TRUE
%token T_LEFT_BRACE
%token T_RIGHT_BRACE
%token T_LEFT_SQUARE_BRACE
%token T_RIGHT_SQUARE_BRACE
%token T_COMMA
%token T_DOT
%token T_COLON
%token T_CONCAT
%token T_TABLELEN
%token T_IN

%%



ROOT:
  block
;


stat:
	comment
|   varlist T_ASSIGN explist  
|	functioncall

|   T_IF exp T_THEN block T_END
|   T_IF exp T_THEN block T_ELSE block T_END
|   T_IF exp T_THEN block elseifblock T_END
|   T_IF exp T_THEN block elseifblock T_ELSE block T_END
 
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
  T_BREAK
| T_RETURN
| T_RETURN explist
;

funcname:
  funcnameslist
| funcnameslist T_COLON T_NAME
;

funcnameslist:
   T_NAME
|  T_NAME T_DOT  T_NAME
;


stmtseq:
  stmtseq T_SEMICOLON stat /* { $$ = seq($1, $3); } */

| stat	
| stat T_SEMICOLON

| stmtseq /* one statement per line */ 
  stat /* { $$ = seq($1, $2); } */
;


block:
  stmtseq
| stmtseq laststat
|
;



varlist:
  var T_COMMA varlist
| var
;


var:
  T_NAME
| prefixexp T_LEFT_SQUARE_BRACE exp T_RIGHT_SQUARE_BRACE
| prefixexp T_DOT T_NAME
;

namelist:
  namelist T_COMMA T_NAME
| T_NAME 
;

explist:
  exp T_COMMA explist
| exp 
;


exp:
  T_NIL
| T_FALSE
| T_TRUE
| T_NUMBER 
| T_STRING 
| "..." 
| function 
| prefixexp 
| tableconstructor 
| exp binop exp 
| unop exp 
| exp comment
| comment exp
;

prefixexp:
  var
| functioncall
| T_LPAREN exp T_RPAREN
;

binop:
  T_PLUS
| T_MINUS
| T_MULT
| T_DIVIDE
| '^' 
| '%'
| T_CONCAT
| T_LT
| T_LE
| T_GT
| T_GE
| T_EQ
| T_NE
| T_AND
| T_OR
;


unop:
  T_MINUS
| T_NOT 
| T_TABLELEN
;


function:
  T_FUNCTION funcbody
;


funcbody:
  T_LPAREN T_RPAREN block T_END
| T_LPAREN parlist T_RPAREN block T_END
;

parlist:
  namelist
| namelist T_COMMA "..."
| "..."
;


tableconstructor:
  T_LEFT_BRACE T_RIGHT_BRACE
| T_LEFT_BRACE fieldlist T_RIGHT_BRACE
;


fieldlist:
  field
| field fieldsep fieldlist
| field fieldsep
;


field:
  T_LEFT_SQUARE_BRACE exp T_RIGHT_SQUARE_BRACE T_ASSIGN exp 
| T_NAME T_ASSIGN exp 
| exp
;


fieldsep: 
   T_COMMA | T_SEMICOLON
;


functioncall:
  prefixexp args 
| prefixexp T_COLON T_NAME args
;


args:
  T_LPAREN T_RPAREN 
| T_LPAREN explist T_RPAREN 
| tableconstructor 
| T_STRING
;


comment:
    comment T_COMMENT
|	T_COMMENT
;

