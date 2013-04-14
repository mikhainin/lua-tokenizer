#pragma once
#include <string>
#include <iostream>

int yyparse();
int yylex();

int oper(const std::string &op, ...);
void execute(int);
// void execute(int);
int seq(int,int);
int name(int);

void comment(const std::string &comment);
void linecomment(const std::string &comment);

void nextline();
void yyerror(const char *s);
