#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

#include "expr.h"

#define NEW(X) malloc(sizeof(X))

Expr *parse_sexp(Sexp *sexp) {
	assert(sexp != NULL);

	Expr *expr = NEW(Expr);
	assert(expr != NULL);

	switch (sexp->sexp_type) {
	case Atomic:
		assert(sexp->size > 0);
		// FIXME temporary string reader
		switch (sexp->sexp_data.string[0]) {
		case '+':
			expr->e_type = PLUS;
			break;
		default:
			expr->e_type = LIT;
			Value *val = NEW(Value);
			assert(val != NULL);
			val->v_type = INT_T;
			IntV *v_int = NEW(IntV);
			assert(v_int != NULL);
			v_int->value = atoll(sexp->sexp_data.string);
			val->v_data.v_int = v_int;
			expr->e_data.e_lit = val;
		}
		break;
	case Apply:
		if (sexp->size == 0) {
			expr->e_type = EMPTY;
		} else {
			expr->e_type = APPLY;
			ApplyE *apply = NEW(ApplyE);
			assert(apply != NULL);
			apply->func = parse_sexp(sexp->sexp_data.apply[0]);
			apply->size = (size_t) sexp->size - 1;
			apply->args = calloc(apply->size, sizeof(Expr *));
			for (int i = 0; i < apply->size; i++) {
				apply->args[i] = parse_sexp(sexp->sexp_data.apply[i + 1]);
			}
			expr->e_data.e_apply = apply;
		}
	}

	return expr;
}

void free_expr(Expr *expr) {
	assert(0);
}

void print_expr(Expr *expr) {
	assert(expr != NULL);

	switch (expr->e_type) {
	case APPLY:
		printf("(APPLY ");
		ApplyE *apply = expr->e_data.e_apply;
		print_expr(apply->func);
		printf(" TO");
		for (int i = 0; i < apply->size; i++) {
			printf(" ");
			print_expr(apply->args[i]);
		}
		printf(")");
		break;
	case PLUS:
		printf("+");
		break;
	case LIT:
		printf("<literal>");
		break;
	case EMPTY:
		printf("()");
		break;
	}
}
