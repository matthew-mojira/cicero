#include <assert.h>
#include <stdio.h>

#include "value.h"
#include "poopcrap.h"
#include "type.h"

Value *b_true(void) {
	return alloc_value(BOOL_T, (void *) 1);
}

Value *b_false(void) {
	return alloc_value(BOOL_T, (void *) 0);
}

int istrue(Value *value) {
	assert(value != NULL);
	assert_type(BOOL_T, value);

	return v_data(value);
}

/* operations on bools */
Value *b_print(Value *value) {
	assert(value != NULL);
	assert_type(BOOL_T, value);

	printf(v_data(value) ? "true" : "false");

	return poop_to_crap();
}
