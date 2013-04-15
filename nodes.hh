#pragma once
#include <string>
#include <vector>

class Node {
public:

	virtual ~Node();

	template<class T>
	bool is() const {
		return dynamic_cast<const T*>(this) != 0;
	}

	template<class T>
	const T* as() const {
		return dynamic_cast<const T*>(this);
	}

	template<class T>
	T* as() {
		return dynamic_cast<T*>(this);
	}

	void attachChildrenNode(Node *n);

	template<typename T, typename... Args>
	void addChildren(T firstArg, Args... args);

	void addChildren(); //

	void setLocation(int lineNo);

	virtual std::string toString() = 0;

	int lineNo = 0;
	std::vector<Node*> childrenNodes;
	Node *parentNode = nullptr;
};


class StringToken : public Node {
public:
	StringToken(const std::string &text, char quote, int level = 0);
	virtual std::string toString();
private:
	std::string text;
	char quote = '\'';
	int level = 0;
};


class NumberToken : public Node {
public:
	NumberToken(const std::string &text);
	virtual std::string toString();
private:
	std::string text;
};




class LineCommentToken : public Node {
public:
	LineCommentToken(const std::string &text);
	virtual std::string toString();
private:
	std::string text;
};

class BlockCommentToken : public Node {
public:
	BlockCommentToken(const std::string &text, int level);
	virtual std::string toString();
private:
	std::string text;
	int level = 0;
};

class OperatorToken : public Node {
public:
	OperatorToken(const std::string &text);
	virtual std::string toString();
private:
	std::string text;
};

class KeywordToken : public Node {
public:
	KeywordToken(const std::string &text);
	virtual std::string toString();
private:
	std::string text;

};

class Expression : public Node {
protected:
	inline Expression() : Node() {}
};

class BinExpression : public Expression {
public:
	BinExpression(Node*op, Node *left, Node *right);
	virtual std::string toString();
	Node *getOp();
	Node *getLeft();
	Node *getRight();
private:
	Node *op = nullptr;
	Node *left = nullptr;
	Node *right = nullptr;
};

class AndBinExpression : public BinExpression {
public:
	AndBinExpression(Node*op, Node *left, Node *right);
};

class DotBinExpression : public BinExpression {
public:
	DotBinExpression(Node*op, Node *left, Node *right);
	virtual std::string toString();
};

class UnaryExpression : public Node {
public:
	UnaryExpression(Node *op, Node *arg);
	virtual std::string toString();
private:
	Node *op = nullptr;
	Node *arg = nullptr;
};



class IfBlock : public Node {
public:
	IfBlock(Node* expr, Node* body);
	virtual std::string toString();
	Node *getExpr();
private:
	Node *expr = nullptr;
	Node *body = nullptr;
};

class ReturnStatement : public Node {
public:
	ReturnStatement(Node *explist = nullptr);
	virtual std::string toString();
private:
	Node *explist = nullptr;
};

class Prefixexp : public Node {

};

class Parens : public Node {
public:
	Parens(Node *expr = nullptr);
	virtual std::string toString();
private:
	Node *expr = nullptr;
};

class Explist : public Node {
public:
	Explist(Node *expr, Explist *explist = nullptr);
	virtual std::string toString();
private:
	Node *expr = nullptr;
	Explist *explist = nullptr;
};

class FunctionCall : public Node {
public:
	FunctionCall(Node *prefixexp, Node *args);
	virtual std::string toString();
	Node *getPrefixexp();
	Node *getArgs();
private:
	Node *prefixexp = nullptr;
	Node *args = nullptr;
};

class MethodCall : public FunctionCall {
public:
	MethodCall(Node *prefixexp, Node *methodName, Node *args);
	virtual std::string toString();
private:
	Node *methodName = nullptr;
};
