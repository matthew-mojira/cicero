#include <assert.h>
#include <stdio.h>

#include "value.h"
#include "poopcrap.h"
#include "type.h"

/* operations on types */
Value *t_print(Value *value) {
	assert(value != NULL);
	assert_type(TYPE_T, value);

	Type *type = v_data(value);
	switch (*type) {
	case INT_T:
		printf("int");
		break;
	case FUNC_T:
		printf("func");
		break;
	case TYPE_T:
		printf("type");
		break;
	case POOPCRAP_T:
		printf("poopcrap");
		break;
	}

	return poop_to_crap();
}
