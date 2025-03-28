#include <assert.h>
#include <stdio.h>

#include "type.h"
#include "value.h"
#include "poopcrap.h"

/* constructor */
Value *poop_to_crap(void) {
	return alloc_value(POOPCRAP_T, NULL); // null indicates no data from obj
}

/* operations on poopcraps */
Value *p_print(Value *value) {
	assert(value != NULL);
	assert_type(POOPCRAP_T, value);

	printf("<poopcrap>");
	return poop_to_crap();
}
