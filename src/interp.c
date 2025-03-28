#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>

#include "interp.h"
#include "int.h"
#include "expr.h"
#include "func.h"

#define IS_BUILTIN(S) (!strcmp(expr->e_data.e_id, S))

Value *eval_expr(Expr *expr) {
	assert(expr != NULL);

	Value *value = NULL;

	switch (expr->e_type) {
	case LIT:
		value = expr->e_data.e_lit;
		break;
	case APPLY:
		ApplyE *apply = expr->e_data.e_apply;

		Value *func = eval_expr(apply->func);
		assert(func != NULL);
		
		Value **args = calloc(apply->size + 1, sizeof(Value *));
		assert(args != NULL);
		for (int i = 0; i < apply->size; i++) {
			Value *arg = eval_expr(apply->args[i]);
			assert(arg != NULL);
			args[i] = arg;
		}

		value = f_call(func, args);
		break;
	case ID:
		if (IS_BUILTIN("+")) {
			value = builtin_to_value(2, i_add);
		} else {
			assert(0);
		}
		break;
	default:
		// TODO implement
		assert(0);
	}

	return value;
}
