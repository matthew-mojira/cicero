#include <assert.h>
#include <inttypes.h>
#include <stdlib.h>

#include "int.h"
#include "value.h"
#include "type.h"

struct _int {
	uint64_t i_value;
};

static Int *wrap_int(uint64_t num) {
	Int* obj = malloc(sizeof(Int));
	assert(obj != NULL);
	obj->i_value = num;

	return obj;
}

uint64_t value_to_int(Value *value) {
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
	return int_to_value(value_to_int(fst) + value_to_int(snd));
}
