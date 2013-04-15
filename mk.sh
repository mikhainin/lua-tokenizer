#!/bin/sh

set -e 
set -x

#yacc -d lua.y 
bison --warnings=all --verbose -d lua.y
flex lua.lex 

#g++  -DYYDEBUG=1 lex.yy.cc parser.cc  y.tab.c  -std=gnu++11
g++  -DYYDEBUG=1 lex.yy.cc lparser.cc  lua.tab.c lua_driver.cc nodes.cc -std=gnu++11
set +x

echo '========================================='
