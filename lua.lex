%{
class lua_driver;

#include <lua_driver.hh>
#include <lparser.h>
#include <nodes.hh>
# include <string>
typedef yy::parser::token token;
#include <parser.hpp>

std::string commentBuf;
int commentLevel = 0;
std::string commentEndLex;

void resetComment() {
	commentBuf.clear();
	commentEndLex.clear();
	commentLevel = 0;
}



char startStringChar;
std::string stringBuf;
std::string squareStringEndLex;
int squareBracketStringLevel = 0;

void resetString() {
	stringBuf.clear();
	squareStringEndLex.clear();
	squareBracketStringLevel = 0;
}

%}

%option noyywrap nounput batch debug
%option yyclass="Scanner"
%option c++
%option yylineno

%x L_COMMENT_START
%x L_COMMENT

%x L_LINE_COMMENT

%x L_QUOTE_STRING

%x L_SQUARE_BRACKET_STRING_START
%x L_SQUARE_BRACKET_STRING

%%


"--["                  { BEGIN L_COMMENT_START; }
<L_COMMENT_START>"="   { ++commentLevel; }
<L_COMMENT_START>"["   { 
							BEGIN L_COMMENT;
							commentEndLex = ']';
							commentEndLex.append(commentLevel, '=');
							commentEndLex += ']';
						}

<L_COMMENT_START>.	    { yyerror("illegal token"); }

<L_COMMENT>\n    { commentBuf += *yytext; nextline(); }
<L_COMMENT>.     { commentBuf += *yytext; }

<L_COMMENT>\]=*\]   {
						const std::string toCompare(yytext, yyleng);
						if ( commentEndLex == toCompare ) {
							// comment(commentBuf);
							BEGIN 0;
							
							
							yylval->node = createNode<BlockCommentToken>(commentBuf, squareBracketStringLevel);
							resetComment();
							return token::T_COMMENT;
							
						} else {
							commentBuf.append(toCompare);
						}
						
					}

"--"			   { BEGIN L_LINE_COMMENT; }


<L_LINE_COMMENT>.  { commentBuf += *yytext; }
<L_LINE_COMMENT>\n {
						BEGIN 0;
						
						yylval->node = createNode<LineCommentToken>(commentBuf);
						
						resetComment();
						nextline();
						return token::T_COMMENT;
					}



'|\"		{
			resetString();
			startStringChar = *yytext;
			BEGIN L_QUOTE_STRING;
		}
			
<L_QUOTE_STRING>\n    { stringBuf += *yytext; nextline(); }
<L_QUOTE_STRING>'|\"  {
						if (*yytext == startStringChar) {
							BEGIN 0;
							yylval->node = createNode<StringToken>(stringBuf, startStringChar);
							return token::T_STRING;
						} else {
							stringBuf += *yytext;
						}
				 }
				 
<L_QUOTE_STRING>.     { stringBuf += *yytext; }



"["=*"["   {
				BEGIN L_SQUARE_BRACKET_STRING;
				squareBracketStringLevel = yyleng - 2;
				squareStringEndLex = ']';
				squareStringEndLex.append(squareBracketStringLevel, '=');
				squareStringEndLex += ']';
		   }
		   
<L_SQUARE_BRACKET_STRING>\n    { stringBuf += *yytext; nextline(); }
<L_SQUARE_BRACKET_STRING>"]"=*"]"     {
                                           const std::string toCompare(yytext, yyleng);
                                           if ( toCompare == squareStringEndLex ) {
                                            	BEGIN 0;
                                            	yylval->node = createNode<StringToken, std::string, char, int>(stringBuf, '[', squareBracketStringLevel);
                                            	return token::T_STRING;
                                           } else {
                                           	    stringBuf += *yytext;
                                           }
									  }
<L_SQUARE_BRACKET_STRING>.     { stringBuf += *yytext; }
			

"=="       { createNode<OperatorToken>(yytext); return token::T_EQ; }
"~="       { createNode<OperatorToken>(yytext); return token::T_NE; }
"<"        { createNode<OperatorToken>(yytext); return token::T_LT; }
"<="       { createNode<OperatorToken>(yytext); return token::T_LE; }
">"        { createNode<OperatorToken>(yytext); return token::T_GT; }
">="       { createNode<OperatorToken>(yytext); return token::T_GE; }
"+"        { createNode<OperatorToken>(yytext); return token::T_PLUS; }
"-"        { createNode<OperatorToken>(yytext); return token::T_MINUS; }
"*"        { createNode<OperatorToken>(yytext); return token::T_MULT; }
"/"        { createNode<OperatorToken>(yytext); return token::T_DIVIDE; }
"="        { createNode<OperatorToken>(yytext); return token::T_ASSIGN; }
"and"      { createNode<OperatorToken>(yytext); return token::T_AND; }
"or"       { createNode<OperatorToken>(yytext); return token::T_OR; }
"not"      { createNode<OperatorToken>(yytext); return token::T_NOT; }
"in"       { createNode<OperatorToken>(yytext); return token::T_IN; }
".."       { createNode<OperatorToken>(yytext); return token::T_CONCAT; }
"#"        { createNode<OperatorToken>(yytext); return token::T_TABLELEN; }
"^"        { createNode<OperatorToken>(yytext); return token::T_EXPONENTIATION; }
"%"        { createNode<OperatorToken>(yytext); return token::T_MODULO; }

")"        { return token::T_RPAREN; }
"("        { return token::T_LPAREN; }
"{"        { return token::T_LEFT_BRACE; }
"}"        { return token::T_RIGHT_BRACE; }
"["        { return token::T_LEFT_SQUARE_BRACE; }
"]"        { return token::T_RIGHT_SQUARE_BRACE; }
";"        { return token::T_SEMICOLON; }
"if"       { createNode<KeywordToken>(yytext); return token::T_IF; }
"then"     { createNode<KeywordToken>(yytext); return token::T_THEN; }
"else"     { createNode<KeywordToken>(yytext); return token::T_ELSE; }
"elseif"   { createNode<KeywordToken>(yytext); return token::T_ELSEIF; }
"whils"    { createNode<KeywordToken>(yytext); return token::T_WHILE; }
"do"       { createNode<KeywordToken>(yytext); return token::T_DO; }
"for"      { createNode<KeywordToken>(yytext); return token::T_FOR; }
"end"      { createNode<KeywordToken>(yytext); return token::T_END; }
"function" { createNode<KeywordToken>(yytext); return token::T_FUNCTION; }
"local"    { createNode<KeywordToken>(yytext); return token::T_LOCAL; }
"repeat"   { createNode<KeywordToken>(yytext); return token::T_REPEAT; }
"until"    { createNode<KeywordToken>(yytext); return token::T_UNTIL; }
"break"    { createNode<KeywordToken>(yytext); return token::T_BREAK; }
","        { return token::T_COMMA; }
"return"   { createNode<KeywordToken>(yytext); return token::T_RETURN; }
"nil"      { createNode<KeywordToken>(yytext); return token::T_NIL; }
"false"    { createNode<KeywordToken>(yytext); return token::T_FALSE; }
"true"     { createNode<KeywordToken>(yytext); return token::T_TRUE; }
"."        { createNode<OperatorToken>(yytext); return token::T_DOT; }
":"        { createNode<OperatorToken>(yytext);return token::T_COLON; }
[0-9]+(\.[0-9]+)?           { createNode<NumberToken>(yytext); return token::T_NUMBER; }
0x[0-9a-fA-F]               { createNode<NumberToken>(yytext); return token::T_NUMBER; }
[a-zA-Z_][a-zA-Z_0-9]*      { createNode<NumberToken>(yytext); return token::T_NAME; }
\          { ; }
\n         { nextline(); }
\t         { ; }

.          { yyerror("illegal token"); }

%%
#ifndef yywrap
int yywrap() { return 1; }
#endif
