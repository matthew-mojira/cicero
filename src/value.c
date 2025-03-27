#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "value.h"

struct _value {
	Type  v_type;
	void *v_data;
};

Value *alloc_value(Type type, void *data) {
	assert(data != NULL);

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

void print_value(Value *value) {
	assert(value != NULL);

// 	switch (value->v_type) {
// 	case INT_T:
// 		IntV *v_int = value->v_data.v_int;
// 		printf("%ld", v_int->value);
// 		break;
// 	case FUNC_T:
// 		printf("<func>");
// 		break;
// 	}
}
