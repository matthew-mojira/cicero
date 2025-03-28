#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "value.h"
#include "int.h"
#include "func.h"
#include "type.h"
#include "expr.h"
#include "poopcrap.h"

struct _value {
	Type  v_type;
	void *v_data;
};

Value *alloc_value(Type type, void *data) {
	Value *value = malloc(sizeof(struct _value));
	assert(value != NULL);

	value->v_type = type;
	value->v_data = data;

	return value;
}

void free_value(Value *value) {
	// TODO
	assert(0);
}

Type v_type(Value *value) {
	assert(value != NULL);

	return value->v_type;
}

void *v_data(Value *value) {
	assert(value != NULL);

	return value->v_data;
}

/* operations on values */
Value *v_typeof(Value *value) {
	assert(value != NULL);

	Type *data = malloc(sizeof(Type));
	assert(data != NULL);
	*data = v_type(value);

	return alloc_value(TYPE_T, data);
}

/* a polymorphic printing function */
Value *v_print(Value *value) {
	assert(value != NULL);

 	switch (v_type(value)) {
 	case INT_T:
 		return i_print(value);
 	case FUNC_T:
 		return f_print(value);
	case TYPE_T:
		return t_print(value);
	case POOPCRAP_T:
		return p_print(value);
	case EXPR_T:
		return e_print(value);
 	}

	fprintf(stderr, "Unrecognized type in print");
	assert(0);
	return NULL;
}
