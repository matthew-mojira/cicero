#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>

#include "interp.h"
#include "expr.h"

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
		assert(apply->func->e_type == PLUS);
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
	default:
		assert(0);
	}

	return value;
}
