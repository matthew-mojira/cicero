#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>

#include "interp.h"
#include "expr.h"

#define IS_BUILTIN(S) (strcmp(expr->e_data.e_id, S))


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
		
		assert(apply->size == 2);
		uint64_t fst = apply->args[0]->e_data.e_lit->v_data.v_int->value;
		uint64_t snd = apply->args[1]->e_data.e_lit->v_data.v_int->value;
		{
			value = malloc(sizeof(Value));
			assert(value != NULL);
			value->v_type = INT_T;
			IntV *v_int = malloc(sizeof (IntV));
			assert(v_int != NULL);
			v_int->value = fst + snd;
			value->v_data.v_int = v_int;
		}
		break;
	case ID:
		if (IS_BUILTIN("+")) {
			Value *value = malloc(sizeof(Value));
			assert(value != NULL);
			value->v_type = FUNC_T;

			FuncV *func = malloc(sizeof(FuncV));
			assert(func != NULL);
			func->n_params = 2;
			func->func = builtin_add;
		}
	default:
		assert(0);
	}

	return value;
}
