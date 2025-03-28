#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>

#include "int.h"
#include "expr.h"
#include "value.h"
#include "poopcrap.h"
#include "type.h"

struct _int {
	uint64_t i_value;
};

static struct _int *wrap_int(uint64_t num) {
	struct _int* obj = malloc(sizeof(struct _int));
	assert(obj != NULL);
	obj->i_value = num;

	return obj;
}

static uint64_t value_to_int(Value *value) {
	assert(value != NULL);
	assert_type(INT_T, value);
	
	struct _int *data = v_data(value);

	return data->i_value;
}

Value *int_to_value(uint64_t num) {
	return alloc_value(INT_T, wrap_int(num));
}

/* operations on integers */

Value *i_add(Value *fst, Value *snd) {
	fst = e_eval(fst);
	snd = e_eval(snd);

	return int_to_value(value_to_int(fst) + value_to_int(snd));
}

Value *i_print(Value *value) {
	assert(value != NULL);
	assert_type(INT_T, value);

	struct _int *data = v_data(value);
	printf("%ld", data->i_value);
	return poop_to_crap();
}
