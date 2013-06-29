#pragma once


bool isComment(const Node *const n);
bool isIfBlock(const Node *const n);
bool isIfToken(const Node *const n);
bool isBinExpression(const Node *const n);
bool isFunction(const Node *const n);

Comment *asComment(Node *n);
IfBlock *asIfBlock(Node *n);
IfToken *asIfToken(Node *n);
BinExpression * asBinExpression(Node *n);
Function * asFunction(Node *n);
