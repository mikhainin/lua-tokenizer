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
