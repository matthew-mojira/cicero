#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>

#include "interp.h"
#include "expr.h"

#define IS_BUILTIN(S) (!strcmp(expr->e_data.e_id, S))


Value *builtin_add(Value *val1, Value *val2) {
	assert(val1 != NULL);
	assert(val2 != NULL);
	// first assert types are correct
	assert(val1->v_type == INT_T);
	assert(val2->v_type == INT_T);

	// allocate space for return
	Value *value = malloc(sizeof(Value));
	assert(value != NULL);

	value->v_type = INT_T;

	IntV *int_v = malloc(sizeof(IntV));
	int_v->value = val1->v_data.v_int->value + val2->v_data.v_int->value;

	value->v_data.v_int = int_v;

	return value;
}

Value *eval_expr(Expr *expr) {
	assert(expr != NULL);

	Value *value;

	switch (expr->e_type) {
	case LIT:
		value = expr->e_data.e_lit;
		break;
	case APPLY:
		ApplyE *apply = expr->e_data.e_apply;
		assert(apply->func != NULL);
	
		Value *v_func = eval_expr(apply->func);
		assert(v_func->v_type == FUNC_T);
		
		FuncV *func = v_func->v_data.v_func;
		assert(func->n_params == apply->size);

		switch (func->n_params) {
		case 0:
			value = func->func();
		case 1:
			Value *arg0;
			arg0 = eval_expr(apply->args[0]);
			value = func->func(arg0);
			break;
		case 2:
			Value *arg1;
			arg0 = eval_expr(apply->args[0]);
			arg1 = eval_expr(apply->args[1]);
			value = func->func(arg0, arg1);
			break;
		default:
			assert(0);
		}
		break;
	case ID:
		if (IS_BUILTIN("+")) {
			value = malloc(sizeof(Value));
			assert(value != NULL);
			value->v_type = FUNC_T;

			FuncV *func = malloc(sizeof(FuncV));
			assert(func != NULL);
			func->n_params = 2;
			func->func = builtin_add;

			value->v_data.v_func = func;
		} else {
			assert(0);
		}
	default:
	}

	return value;
}
