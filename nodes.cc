
#include "nodes.hh"



Node::~Node() {
}

void Node::addChildren() {
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
	: Comment()
	, text(text) {
}

std::string LineCommentToken::toString() {
	return "-- " + text;
}

std::string LineCommentToken::getText() {
	return text;
}

BlockCommentToken::BlockCommentToken(
		const std::string& text,
		int level)
			: Comment()
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

std::string BlockCommentToken::getText() {
	return text;
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

IfToken::IfToken() : KeywordToken("if") {
}
void IfToken::setBlock(IfBlock* block) {
	ifblock = block;
}

IfBlock* IfToken::getBlock() {
	return ifblock;
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


IfBlock::IfBlock(Node* ifToken, Node* expr, Node* body, Node *els, Node *elsIf)
		: Node()
		, expr(expr)
		, body(body)
		, els(els)
		, elsIf(elsIf)
{
	addChildren(expr, body, els, elsIf);
	ifToken->as<IfToken>()->setBlock(this);
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

Node *IfBlock::getBody() {
	return body;
}

Node *IfBlock::getElseIfBlock() {
	return elsIf;
}

Node *IfBlock::getElseBlock() {
	return els;
}



ElseIfClause::ElseIfClause(Node* expr, Node* body) : Node(), expr(expr), body(body) {
	addChildren(expr, body);
}

std::string ElseIfClause::toString() {
	if (elseIf) {
		return
				"elseif " +
				expr->toString() +
				"then\n" +
				body->toString() +
				"\n" +
				elseIf->toString();
	}
	return "elseif " +
			expr->toString() +
			"then\n" +
			body->toString()
			;
}

void ElseIfClause::addElseIfClause(ElseIfClause* elseIf) {
	addChildren(elseIf);
	this->elseIf = elseIf;
}

ElseIfClause* ElseIfClause::elseIfClause() {
	return elseIf;
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
	addChildren(prefixexp, methodName, args);
}

std::string MethodCall::toString() {
	return getPrefixexp()->toString() + ':' + methodName->toString() + getArgs()->toString();
}

SquareParens::SquareParens(Node* expr): Node(), expr(expr) {
	addChildren(expr);
}

std::string SquareParens::toString() {
	return '[' + expr->toString() + ']';
}

TableField::TableField(Node* expr, Node* name) : Node(), expr(expr), name(name) {
	addChildren(expr, name);
}

std::string TableField::toString() {
	if (name) {
		return name->toString() + " = " + expr->toString();
	}
	return expr->toString();
}

CommaSeparatedList::CommaSeparatedList(Node* name) : Node() {
	addChildren(name);
	names.push_back(name);
}

std::string CommaSeparatedList::toString() {
	auto p = names.begin();
	std::string res = (*p)->toString();

	for( ++p ; p != names.end() ; ++p) {
		res += ", ";
		res += (*p)->toString();
	}
	return res;
}

void CommaSeparatedList::addName(Node *name) {
	addChildren(name);
	names.push_back(name);
}

FunctionBody::FunctionBody(Node* body, Node* parlist) : Node(), body(body), parlist(parlist) {
	addChildren(body, parlist);
}

std::string FunctionBody::toString() {
	std::string res = "(";
	if (parlist) {
		res += parlist->toString();
	}
	res += ")\n";
	if (body) {
		res += body->toString() + "\n";
	}
	return res;
}

Function::Function(Node* body, Node* name) : Node(), body(body), name(name)  {
	addChildren(body, name);
}

std::string Function::toString() {
	if (name) {
		return "function " + name->toString()  + body->toString() + "\nend";
	}
	return "function " + body->toString() + "\nend";
}

TableConstructor::TableConstructor(Node* fieldlist) : Node(), fieldlist(fieldlist) {
	addChildren(fieldlist);
}

std::string TableConstructor::toString() {
	if (fieldlist) {
		return '{' + fieldlist->toString() + '}';
	}
	return "{}";
}

LocalClause::LocalClause(Node* statement) : Node(), statement(statement) {
	addChildren(statement);
}

std::string LocalClause::toString() {
	return "local " + statement->toString();
}

StatementSequence::StatementSequence(Node* statement) : Node() {
	if (statement) {
		addChildren(statement);
		statements.push_back(statement);
	}
}

std::string StatementSequence::toString() {
	if (statements.empty()) {
		return "";
	}

	auto p = statements.begin();
	std::string res = (*p)->toString();
	res += "\n";
	for(++p; p != statements.end(); ++p) {
		res += "\n";
		res += (*p)->toString();
	}
	return res;
}

void StatementSequence::addStatement(Node* statement) {
	addChildren(statement);
	statements.push_back(statement);
}

void StatementSequence::addLastStatement(Node* statement) {
	addStatement(statement);
	lastStatement = statement;
}
