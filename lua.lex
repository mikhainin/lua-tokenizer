%{
#include "y.tab.h"
#include "parser.h"
# include <string>


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
							comment(commentBuf);
							BEGIN 0;
							
							resetComment();
							
							return T_COMMENT;
							
						} else {
							commentBuf.append(toCompare);
						}
						
					}

"--"			   { BEGIN L_LINE_COMMENT; }


<L_LINE_COMMENT>.  { commentBuf += *yytext; }
<L_LINE_COMMENT>\n {
						BEGIN 0;
						linecomment(commentBuf);
						// yylval = startStringChar;
						resetComment();
						nextline();
						return T_COMMENT;
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
							// yylval = startStringChar;
							return T_STRING;
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
                                            	return T_STRING;
                                           } else {
                                           	    stringBuf += *yytext;
                                           }
									  }
<L_SQUARE_BRACKET_STRING>.     { stringBuf += *yytext; }
			

"=="       { return T_EQ; }
"~="       { return T_NE; }
"<"        { return T_LT; }
"<="       { return T_LE; }
">"        { return T_GT; }
">="       { return T_GE; }
"+"        { return T_PLUS; }
"-"        { return T_MINUS; }
"*"        { return T_MULT; }
"/"        { return T_DIVIDE; }
")"        { return T_RPAREN; }
"("        { return T_LPAREN; }
"{"        { return T_LEFT_BRACE; }
"}"        { return T_RIGHT_BRACE; }
"["        { return T_LEFT_SQUARE_BRACE; }
"]"        { return T_RIGHT_SQUARE_BRACE; }
"="        { return T_ASSIGN; }
"and"      { return T_AND; }
"or"       { return T_OR; }
"not"      { return T_NOT; }
"in"       { return T_IN; }
";"        { return T_SEMICOLON; }
"if"       { return T_IF; }
"then"     { return T_THEN; }
"else"     { return T_ELSE; }
"elseif"   { return T_ELSEIF; }
"whils"    { return T_WHILE; }
"do"       { return T_DO; }
"for"      { return T_FOR; }
"end"      { return T_END; }
"function" { return T_FUNCTION; }
"local"    { return T_LOCAL; }
"repeat"   { return T_REPEAT; }
"until"    { return T_UNTIL; }
"break"    { return T_BREAK; }
","        { return T_COMMA; }
"return"   { return T_RETURN; }
"nil"      { return T_NIL; }
"false"    { return T_FALSE; }
"true"     { return T_TRUE; }
".."       { return T_CONCAT; }
"."        { return T_DOT; }
":"        { return T_COLON; }
"#"        { return T_TABLELEN; }
[0-9]+(\.[0-9]+)?           { yylval = atoi(yytext); return T_NUMBER; }
0x[0-9a-fA-F]               { yylval = atoi(yytext); return T_NUMBER; }
[a-zA-Z_][a-zA-Z_0-9]*      { return T_NAME; }
\          { ; }
\n         { nextline(); }
\t         { ; }

.          { yyerror("illegal token"); }

%%
#ifndef yywrap
int yywrap() { return 1; }
#endif
