
#include "nodes.hh"



Node::~Node() {
}

void Node::setLocation(int lineNo) {
	this->lineNo = lineNo;
}

void Node::attachChildrenNode(Node *n) {
	if (n) {
		childrenNodes.push_back(n);
		n->parentNode = this;
	}
}

template<typename T, typename... Args>
void Node::addChildren(T firstArg, Args... args) {
	attachChildrenNode(firstArg);
	if (sizeof...(Args) > 0) {
		addChildren(args...);
	}
}

StringToken::StringToken(
		  const std::string& text
		, char quote
		, int level)
			: Node()
			, text(text)
			, quote(quote)
			, level(level) {
}


std::string StringToken::toString() {
	if (quote == '[') {
		std::string res = "[";
		res.append(level, '=');
		res += '[';
		res += text;

		res += ']';
		res.append(level, '=');
		res += ']';

		return res;
	} else {
		return quote + text + quote;
	}
}

NumberToken::NumberToken(const std::string& text)
			: Node()
			, text(text){
}


std::string NumberToken::toString() {
	return text;
}

LineCommentToken::LineCommentToken(const std::string& text)
	: Node()
	, text(text) {
}

std::string LineCommentToken::toString() {
	return "--" + text;
}

BlockCommentToken::BlockCommentToken(
		const std::string& text,
		int level)
			: Node()
			, text(text)
			, level(level)
		{
}

std::string BlockCommentToken::toString() {
	std::string res = "--[";
	res.append(level, '=');
	res += '[';
	res += text;

	res += ']';
	res.append(level, '=');
	res += ']';

	return res;
}

OperatorToken::OperatorToken(const std::string& text) : Node(), text(text) {
}

std::string OperatorToken::toString() {
	return text;
}

KeywordToken::KeywordToken(const std::string& text) : Node(), text(text) {
}

std::string KeywordToken::toString() {
	return text;
}

BinExpression::BinExpression(Node* op, Node* left, Node* right) : Expression(), op(op), left(left), right(right) {
}

std::string BinExpression::toString() {
	return left->toString() + ' ' + op->toString() + ' ' + right->toString();
}

Node* BinExpression::getOp() {
	return op;
}

Node* BinExpression::getLeft() {
	return left;
}

Node* BinExpression::getRight() {
	return right;
}

AndBinExpression::AndBinExpression(Node*op, Node *left, Node *right) :BinExpression(op, left, right)  {
}


DotBinExpression::DotBinExpression(Node*op, Node *left, Node *right) : BinExpression(op, left, right) {
}

std::string DotBinExpression::toString() {
	return getLeft()->toString() + getOp()->toString() + getRight()->toString();
}


UnaryExpression::UnaryExpression(Node *op, Node *arg) : Node(), op(op), arg(arg) {
}

std::string UnaryExpression::toString() {
	if (op->toString() == "not") {
		return "not " + arg->toString();
	}
	return op->toString() + arg->toString();
}


IfBlock::IfBlock(Node* expr, Node* body) : Node(), expr(expr), body(body) {
	addChildren(expr, body);
}

std::string IfBlock::toString() {
	return "if " +
			expr->toString() +
			" then\n" +
			body->toString() +
			"\nend\n";
}



Node* IfBlock::getExpr() {
	return expr;
}

ReturnStatement::ReturnStatement(Node* explist) : Node(), explist(explist) {
	addChildren(explist);
}

std::string ReturnStatement::toString() {
	if (explist) {
		return "return " + explist->toString();
	}
	return "return";
}



Parens::Parens(Node *expr) : Node(), expr(expr) {
	addChildren(expr);
}

std::string Parens::toString() {
	if (expr) {
		return '(' + expr->toString() + ')';
	}
	return "()";
}



Explist::Explist(Node *expr, Explist *explist) : Node(), expr(expr), explist(explist) {
	addChildren(expr, explist);
}

std::string Explist::toString() {
	if (explist) {
		return expr->toString() + ", " + explist->toString();
	}
	return expr->toString();
}

FunctionCall::FunctionCall(Node* prefixexp, Node* args) : Node(), prefixexp(prefixexp),  args(args) {
}

std::string FunctionCall::toString() {
	return prefixexp->toString() + args->toString();
}

Node* FunctionCall::getPrefixexp() {
	return prefixexp;
}

Node* FunctionCall::getArgs() {
	return args;
}

MethodCall::MethodCall(Node* prefixexp, Node* methodName, Node* args) : FunctionCall(prefixexp, args), methodName(methodName) {
}

std::string MethodCall::toString() {
	return getPrefixexp()->toString() + ':' + methodName->toString() + getArgs()->toString();
}
