#!/bin/sh

set -e 
set -x

yacc -d lua.y 
flex lua.lex 
g++  -DYYDEBUG=1 lex.yy.c parser.cc  y.tab.c  -std=gnu++11
set +x

echo '========================================='
