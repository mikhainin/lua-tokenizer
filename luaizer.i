%module luaizer

%include "std_string.i"

%{
#include "lua_driver.hh"
#include "wrapper_func.hh"
%}

%include "std_vector.i"
namespace std {
   %template(NodesVector) vector<Node *>;
}



class lua_driver
{
public:
   lua_driver() {};
   virtual ~lua_driver();

  int result;

  // Run the parser.  Return 0 on success.
  int parse (const std::string& f);
  
  const std::vector<Node *> getNodes() const;
  const std::vector<Node *> getExpressionNodes() const;
  Node *getRootNode();
};

class Node {
public:
	virtual std::string toString() = 0;
};

class Comment : public Node {
public:
	virtual std::string getText() = 0;
};

class LineCommentToken : public Comment {
};

class BlockCommentToken : public Comment {
};

class IfBlock : public Node {
public:
	Node *getExpr();
	Node *getBody();
	Node *getElseIfBlock();
	Node *getElseBlock();
};

class IfToken : public Node {
public:
	IfBlock* getBlock();
};

class Expression : public Node {
};

class BinExpression : public Expression {
public:
	Node *getOp();
	Node *getLeft();
	Node *getRight();
};

class Function: public Node {
public:
	FunctionBody *getBody();
};


bool isComment(const Node *const n);
bool isIfBlock(const Node *const n);
bool isBinExpression(const Node *const n);
bool isFunction(const Node *const n);

Comment * asComment(Node *n);
IfBlock * asIfBlock(Node *n);
IfToken * asIfToken(Node *n);
BinExpression * asBinExpression(Node *n);
Function * asFunction(Node *n);

bool isIfToken(const Node *const n);
bool isBinExpression(const Node *const n);
bool isIfBlock(const Node *const n);
bool isFunction(const Node *const n);

