#ifndef EXPR_H
#define EXPR_H

#include <stdint.h>

#include "sexp.h"
#include "value.h"

typedef struct {
	enum { APPLY, PLUS, LIT, EMPTY } e_type;
	union {
		struct _ApplyE *e_apply;
		Value *e_lit;
	} e_data;
} Expr;

typedef struct _ApplyE {
	Expr *func;
	size_t size;
	Expr **args;
} ApplyE;

Expr *parse_sexp(Sexp *);
void free_expr(Expr *);

void print_expr(Expr *);

#endif
