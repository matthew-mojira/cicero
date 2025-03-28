#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "expr.h"
#include "int.h"
#include "func.h"
#include "value.h"
#include "bool.h"
#include "poopcrap.h"

#define NEW(X) malloc(sizeof(X))
#define IS_BUILTIN(S) (!strcmp(expr->e_data.e_id, S))

typedef struct {
	enum { APPLY, ID } e_type;
	union {
		char *e_id;
		struct _ApplyE *e_apply;
	} e_data;
} Expr;

typedef struct _ApplyE {
	Value *func;
	size_t size;
	Value **args; // args is also nul-terminated array (assume Value * null is not valid)
} ApplyE;

Value *parse_sexp(Sexp *sexp) {
	assert(sexp != NULL);

	Expr *expr = NEW(Expr);

	switch (sexp->sexp_type) {
	case Atomic:
		assert(sexp->size > 0);

		expr->e_type = ID;
		size_t len = strlen(sexp->sexp_data.string); // does not include NUL byte 
		expr->e_data.e_id = calloc(sizeof(char), len + 1);
		strncpy(expr->e_data.e_id, sexp->sexp_data.string, len + 1);
		break;
	case Apply:
		expr->e_type = APPLY;
		ApplyE *apply = NEW(ApplyE);
		assert(apply != NULL);
		apply->func = parse_sexp(sexp->sexp_data.apply[0]);
		apply->size = (size_t) sexp->size - 1;
		apply->args = calloc(apply->size + 1, sizeof(Expr *));
		for (int i = 0; i < apply->size; i++) {
			apply->args[i] = parse_sexp(sexp->sexp_data.apply[i + 1]);
		}
		expr->e_data.e_apply = apply;
	}

	assert(expr != NULL);
	return alloc_value(EXPR_T, expr);
}

/* operations on exprs */
Value *e_eval(Value *input) {
	assert(input != NULL);
	assert_type(EXPR_T, input);

	Expr *expr = v_data(input);
	Value *value = NULL;

	switch (expr->e_type) {
	case APPLY:
		ApplyE *apply = expr->e_data.e_apply;

		Value *func = e_eval(apply->func);
		assert(func != NULL);
		value = f_call(func, apply->args);
		break;
	case ID:
		if (IS_BUILTIN("+")) {
			value = builtin_to_value(2, i_add);
		} else if (IS_BUILTIN("typeof")) {
			value = builtin_to_value(1, v_typeof);
		} else if (IS_BUILTIN("print")) {
			value = builtin_to_value(1, v_print);
		} else if (IS_BUILTIN("eval")) {
			value = builtin_to_value(1, e_eval);
		} else if (IS_BUILTIN("noeval")) {
			value = builtin_to_value(1, e_noeval);
		} else if (IS_BUILTIN("if")) {
			value = builtin_to_value(3, v_if);
		} else if (IS_BUILTIN("istrue")) {
			value = builtin_to_value(1, v_istrue);
		} else if (IS_BUILTIN("true")) {
			value = b_true();
		} else if (IS_BUILTIN("false")) {
			value = b_false();
		} else {
			char *str = expr->e_data.e_id;
			assert(strlen(str) > 0);
			
			switch (str[0]) {
			case '0'...'9':
			case '-':
			case '+':
				char *end;
				long num = strtol(str, &end, 10);
				// assert entire number matched
				if (*end == '\0') {
					value = int_to_value(num);
					break;
				}
			default:
				fprintf(stderr, "Unrecognized identifier: %s\n", str);
				value = NULL;
			}
		}
	}

	return value;
}


Value *e_print(Value *value) {
	assert(value != NULL);
	assert_type(EXPR_T, value);

	Expr *expr = v_data(value);

	switch (expr->e_type) {
	case APPLY:
		printf("(");
		ApplyE *apply = expr->e_data.e_apply;
		e_print(apply->func);
		for (int i = 0; i < apply->size; i++) {
			printf(" ");
			e_print(apply->args[i]);
		}
		printf(")");
		break;
	case ID:
		printf("%s", expr->e_data.e_id);
		break;
	}

	return poop_to_crap();
}

Value *e_noeval(Value *value) {
	assert(value != NULL);
	assert_type(EXPR_T, value);

	return value;
}
