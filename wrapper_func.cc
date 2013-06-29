#include "nodes.hh"
#include "wrapper_func.hh"

bool isComment(const Node *const n) {
	return n->is<Comment>();
}

bool isIfBlock(const Node *const n) {
	return n->is<IfBlock>();
}

bool isIfToken(const Node* const n) {
	return n->is<IfToken>();
}

bool isBinExpression(const Node* const n) {
	return n->is<BinExpression>();
}

bool isFunction(const Node* const n) {
	return n->is<Function>();
}

Comment * asComment(Node *n) {
	return n->as<Comment>();
}

IfBlock* asIfBlock(Node* n) {
	return n->as<IfBlock>();
}


IfToken* asIfToken(Node* n) {
	return n->as<IfToken>();
}

BinExpression* asBinExpression(Node* n) {
	return n->as<BinExpression>();
}

Function* asFunction(Node* n) {
	return n->as<Function>();
}
