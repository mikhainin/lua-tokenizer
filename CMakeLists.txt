cmake_minimum_required(VERSION 2.8)

project(lua_parser)

find_package(BISON)
find_package(FLEX)

FLEX_TARGET(LuaScanner lua.lex ${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp)
BISON_TARGET(LuaParser lua.y   ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp COMPILE_FLAGS --debug)

ADD_FLEX_BISON_DEPENDENCY(LuaScanner LuaParser)

SET(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=gnu++11)
add_definitions(-DYYDEBUG=1)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_executable(
	lua_parser
	nodes.cc
	lua_driver.cc
	lparser.cc
	${BISON_LuaScanner_OUTPUTS}
	${FLEX_LuaParser_OUTPUTS}
	${CMAKE_CURRENT_BINARY_DIR}/lexer.cpp
	${CMAKE_CURRENT_BINARY_DIR}/parser.cpp
	)

