#include <assert.h>
#include <stdlib.h>
#include <stdio.h>

#include "func.h"
#include "type.h"
#include "poopcrap.h"
#include "value.h"

/* TODO support user-defined functions data representation */

struct _func {
	size_t f_params;
	Value *(* f_func)();
	/* type of the parameter is unknown, but you should assume that it is
	 * exactly {f_params} of type {Value *}.
	 */
};

Value *builtin_to_value(size_t params, Value *(*func)()) {
	assert(func != NULL);

	struct _func *obj = malloc(sizeof(struct _func));
	assert(obj != NULL);
	obj->f_params = params;
	obj->f_func = func;

	return alloc_value(FUNC_T, obj);
}

Value *f_call(Value *func, Value **argv) {
	assert(func != NULL);
	assert_type(FUNC_T, func);

	assert(argv != NULL);
	size_t argc;
	for (argc = 0; argv[argc]; argc++);

	struct _func *f = v_data(func);
	assert(f->f_params == argc);

	Value *value;
	switch (argc) {
	case 0:
		value = f->f_func();
		break;
	case 1:
		value = f->f_func(argv[0]);
		break;
	case 2:
		value = f->f_func(argv[0], argv[1]);
		break;
	case 3:
		value = f->f_func(argv[0], argv[1], argv[2]);
		break;
	default:
		// TODO implement
		assert(0);
	}
	return value;
}

Value *f_print(Value *value) {
	assert(value != NULL);
	assert_type(FUNC_T, value);

	printf("<func>");
	return poop_to_crap();
}
